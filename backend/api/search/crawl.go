package search

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/net/context"
)

func Crawl(c *gin.Context) {
	if *auth.Secret != c.GetHeader(auth.AuthHeader) {
		c.Status(http.StatusUnauthorized)
		return
	}

	err := db.DBInst.Films.Drop(context.TODO())
	if err != nil {
		panic(err)
	}

	go crawl()
	c.Status(http.StatusAccepted)
}

func crawl() {
	lastCrawledId := 1
	for id := 1; id < lastCrawledId+2000; id++ {
		url := fmt.Sprintf("https://myanimelist.net/anime/%d", id)
		res, exist := pageExist(url, http.StatusNotFound)
		if exist {
			crawlPage(res)
			lastCrawledId = id
		}
		res.Body.Close()
	}
	fmt.Printf("Last crawled id: %d\n.", lastCrawledId)
	crawlSeasons()
	fmt.Println("Crawled.")
	db.DBInst.Films.Indexes().CreateMany(context.Background(), []mongo.IndexModel{
		{Keys: bson.M{"key_words": "text"}},
		{Keys: bson.M{"status": 1}},
		{Keys: bson.M{"genres": 1}},
		{Keys: bson.M{"seasons": 1}},
		{Keys: bson.M{"url": 1}, Options: options.Index().SetUnique(true)},
	})
	fmt.Println("Index created.")
}

func getPage(url string, statusNotExist int) *http.Response {
	timeOut := 100 * time.Second
	for {
		client := &http.Client{
			CheckRedirect: func(req *http.Request, via []*http.Request) error {
				return http.ErrUseLastResponse
			},
		}
		res, err := client.Get(url)
		if err != nil {
			panic(err)
		}
		if res.StatusCode == http.StatusOK || res.StatusCode == statusNotExist {
			return res
		} else {
			fmt.Printf(
				"%d, retrying in %d seconds.\nUrl: %s\n",
				res.StatusCode,
				timeOut/time.Second,
				url,
			)
			res.Body.Close()
			time.Sleep(timeOut)
			timeOut *= 2
		}
	}
}

func pageExist(url string, statusNotExist int) (*http.Response, bool) {
	res := getPage(url, statusNotExist)
	if res.StatusCode == statusNotExist {
		return res, false
	} else if res.StatusCode == http.StatusOK {
		return res, true
	} else {
		panic(res.StatusCode)
	}
}

func crawlPage(res *http.Response) {
	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		panic(err)
	}
	var name string
	doc.Find("h1.title-name").Each(func(i int, s *goquery.Selection) {
		if i != 0 {
			fmt.Printf("multiple title for an anime? url: %s\n", res.Request.URL.String())
		}
		name = s.Text()
	})

	altNames := []string{}
	var english string
	var episodes int
	genres := []string{}
	var status string
	doc.Find("span.dark_text").Each(func(i int, s *goquery.Selection) {
		if s.Text() == "Episodes:" {
			if episodes != 0 {
				fmt.Printf("multiple Episodes field?\n url: %s\n", res.Request.URL.String())
			}
			t := s.Parent().Contents().Get(2).Data
			t = strings.TrimSpace(t)
			episodes, _ = strconv.Atoi(t)
			// invalid ep probably means it's still airing
		} else if s.Text() == "Genres:" || s.Text() == "Genre:" {
			if len(genres) != 0 {
				fmt.Printf("multiple Genre field?\n url: %s\n", res.Request.URL.String())
			}
			s.Siblings().Filter("a").Each(func(i int, s *goquery.Selection) {
				genres = append(genres, s.Text())
			})
		} else if s.Text() == "Status:" {
			if status != "" {
				fmt.Printf("multiple Status field?\n url: %s\n", res.Request.URL.String())
			}
			status = s.Parent().Contents().Get(2).Data
			status = strings.TrimSpace(status)
		} else if s.Text() == "Synonyms:" {
			t := s.Parent().Contents().Get(2).Data
			t = strings.TrimSpace(t)
			names := strings.Split(t, ", ")
			altNames = append(altNames, names...)
		} else if s.Text() == "English:" {
			if english != "" {
				fmt.Printf("multiple English field?\n url: %s\n", res.Request.URL.String())
			}
			english = s.Parent().Contents().Get(2).Data
			english = strings.TrimSpace(english)
		}
	})

	var imgUrl string
	doc.Find(fmt.Sprintf("img.lazyload[alt='%s']", name)).Each(func(i int, s *goquery.Selection) {
		if i != 0 {
			// probably character name = title name
			return
		}
		var exists bool
		imgUrl, exists = s.Attr("data-src")
		if !exists {
			fmt.Printf("no src for img?\n url: %s\n", res.Request.URL.String())
		}
	})

	var keyWords strings.Builder

	keyWords.WriteString(name)
	keyWords.WriteString(" " + english)
	for _, altName := range altNames {
		keyWords.WriteString(" " + altName)
	}

	db.DBInst.Films.InsertOne(context.TODO(), db.Film{
		Url:      res.Request.URL.String(),
		Name:     name,
		AltNames: altNames,
		English:  english,
		KeyWords: keyWords.String(),
		ImgUrl:   imgUrl,
		Episodes: episodes,
		Seasons:  []int{},
		Genres:   genres,
		Status:   status,
	})
}

const zeroYear = 1917

var seasonMap = [4]string{
	"winter",
	"spring",
	"summer",
	"fall",
}

func intToSeason(i int) (int, string) {
	year := i/4 + zeroYear
	season := seasonMap[i%4]
	return year, season
}

func crawlSeasons() {
	exists := true
	for i := 0; exists; i++ {
		year, season := intToSeason(i)
		url := fmt.Sprintf("https://myanimelist.net/anime/season/%d/%s", year, season)
		var res *http.Response
		res, exists = pageExist(url, http.StatusSeeOther)
		if exists {
			fmt.Println("crawling: " + url)
			crawlSeason(res, i)
		}
		res.Body.Close()
	}
}

func crawlSeason(res *http.Response, season int) {
	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		panic(err)
	}

	doc.Find("a.link-title").Each(func(i int, s *goquery.Selection) {
		url, exists := s.Attr("href")
		if !exists {
			fmt.Printf("href doesn't exist for anime? season:%d", season)
		}
		url = url[:strings.LastIndex(url, "/")]
		result, err := db.DBInst.Films.UpdateOne(
			context.TODO(),
			bson.M{"url": url},
			bson.M{
				"$push": bson.M{
					"seasons": season,
				},
			},
		)
		if result.MatchedCount != 1 {
			panic(result.MatchedCount)
		}
		if err != nil {
			panic(err)
		}
	})
}
