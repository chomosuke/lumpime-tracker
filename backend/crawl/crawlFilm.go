package crawl

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/PuerkitoBio/goquery"
	"github.com/chomosuke/backend/db"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/net/context"
)

func crawlFilm(res *http.Response) {
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

	var film db.Film
	db.DBInst.Films.FindOne(
		context.TODO(),
		bson.M{"url": res.Request.URL.String()},
	).Decode(&film)
	if err != mongo.ErrNoDocuments && err != nil {
		panic(err)
	}

	_, err = db.DBInst.Films.ReplaceOne(
		context.TODO(),
		bson.M{"url": res.Request.URL.String()},
		db.Film{
			Url:      res.Request.URL.String(),
			Name:     name,
			AltNames: altNames,
			English:  english,
			KeyWords: keyWords.String(),
			ImgUrl:   imgUrl,
			Episodes: episodes,
			Seasons:  film.Seasons,
			Genres:   genres,
			Status:   status,
		},
		options.Replace().SetUpsert(true),
	)
	if err != nil {
		panic(err)
	}
}
