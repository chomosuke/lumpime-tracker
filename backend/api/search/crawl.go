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
	"golang.org/x/net/context"
)

func Crawl(c *gin.Context) {
	if *auth.Secret != c.GetHeader(auth.AuthHeader) {
		c.Status(http.StatusUnauthorized)
		return
	}

	db.DBInst.Films.Drop(context.TODO())
	go crawl()
	c.Status(http.StatusAccepted)
}

func crawl() {
	lastCrawledId := 1
	for id := 1; id < lastCrawledId+500; id++ {
		url := fmt.Sprintf("https://myanimelist.net/anime/%d", id)
		if res, exist := pageExist(url); exist {
			go crawlPage(res)
			lastCrawledId = id
		}
	}
	fmt.Printf("Crawled. Last crawled id: %d\n", lastCrawledId)
}

func pageExist(url string) (*http.Response, bool) {
	var res *http.Response
	timeOut := 160 * time.Second
	for {
		var err error
		res, err = http.Get(url)
		if err != nil {
			panic(err)
		}
		if res.StatusCode != http.StatusForbidden {
			break
		} else {
			fmt.Printf("403ed, retrying in %d seconds.\nUrl: %s\n", timeOut/time.Second, url)
			res.Body.Close()
			time.Sleep(timeOut)
			timeOut *= 2
		}
	}
	if res.StatusCode == http.StatusNotFound {
		res.Body.Close()
		return res, false
	} else if res.StatusCode == http.StatusOK {
		return res, true
	} else {
		panic(res.StatusCode)
	}
}

func crawlPage(res *http.Response) {
	doc, err := goquery.NewDocumentFromReader(res.Body)
	defer res.Body.Close()
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

	var altNames []string
	var episodes int
	var genres []string
	var status string
	doc.Find("span.dark_text").Each(func(i int, s *goquery.Selection) {
		if s.Text() == "Episodes:" {
			if episodes != 0 {
				fmt.Printf("multiple Episodes field?\n url: %s\n", res.Request.URL.String())
			}
			t := s.Parent().Contents().Get(2).Data
			t = strings.TrimSpace(t)
			var err error
			episodes, err = strconv.Atoi(t)
			if err != nil {
				fmt.Printf("invalid Episodes text\n url: %s\n text: %s\n", res.Request.URL.String(), s.Text())
			}
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
		} else if s.Text() == "Synonyms:" || s.Text() == "English:" {
			t := s.Parent().Contents().Get(2).Data
			t = strings.TrimSpace(t)
			names := strings.Split(t, ", ")
			altNames = append(altNames, names...)
		}
	})

	var imgUrl string
	doc.Find(fmt.Sprintf("img.lazyload[alt='%s']", name)).Each(func(i int, s *goquery.Selection) {
		if i != 0 {
			fmt.Printf("multiple title img?\n url: %s\n", res.Request.URL.String())
		}
		var exists bool
		imgUrl, exists = s.Attr("data-src")
		if !exists {
			fmt.Printf("no src for img?\n url: %s\n", res.Request.URL.String())
		}
	})

	db.DBInst.Films.InsertOne(context.TODO(), db.Film{
		Url:      res.Request.URL.String(),
		Name:     name,
		AltNames: altNames,
		ImgUrl:   imgUrl,
		Episodes: episodes,
		Genres:   genres,
		Status:   status,
	})
}
