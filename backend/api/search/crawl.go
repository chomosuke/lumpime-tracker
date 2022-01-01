package search

import (
	"fmt"
	"net/http"
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
		fmt.Println(id)
		if res, exist := pageExist(url); exist {
			go crawlPage(res)
			lastCrawledId = id
		}
	}
	fmt.Printf("Crawled. Last crawled id: %d\n", lastCrawledId)
}

func pageExist(url string) (*http.Response, bool) {
	var res *http.Response
	timeOut := 50 * time.Second
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
		if name != "" {
			fmt.Printf("multiple title for an anime? url: %s\n", res.Request.URL.String())
		}
		name = s.Text()
	})

	db.DBInst.Films.InsertOne(context.TODO(), db.Film{
		Url:  res.Request.URL.String(),
		Name: name,
	})
}
