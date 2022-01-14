package crawl

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/chomosuke/backend/db"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

func Crawl() {
	for {
		time.Sleep(10 * time.Second)
		crawlCycle()
	}
}

func crawlCycle() {
	var variable db.Variables
	err := db.DBInst.Variables.FindOne(context.TODO(), bson.M{}).Decode(&variable)
	if err == mongo.ErrNoDocuments {
		variable.CurrentCrawlId = 1
		variable.LastCrawledId = 0
		db.DBInst.Variables.InsertOne(context.TODO(), variable)
	} else if err != nil {
		panic(err)
	}

	if variable.CurrentCrawlId > variable.LastCrawledId+2000 {
		variable.CurrentCrawlId = 0
		variable.LastCrawledId = 0
		variable.CurrentSeasonId = 1
	}

	if variable.CurrentCrawlId != 0 {
		url := fmt.Sprintf("https://myanimelist.net/anime/%d", variable.CurrentCrawlId)
		res, exist := pageExist(url, http.StatusNotFound)
		if exist {
			crawlFilm(res)
			variable.LastCrawledId = variable.CurrentCrawlId
		}
		res.Body.Close()
		variable.CurrentCrawlId++
	}

	if variable.CurrentSeasonId != 0 {
		year, season := intToSeason(variable.CurrentSeasonId)
		url := fmt.Sprintf("https://myanimelist.net/anime/season/%d/%s", year, season)
		var res *http.Response
		res, exists := pageExist(url, http.StatusSeeOther)
		if exists {
			fmt.Println("crawling: " + url)
			crawlSeason(res, variable.CurrentSeasonId)
		} else {
			variable.CurrentCrawlId = 1
			variable.LastCrawledId = 0
			variable.CurrentSeasonId = 0
		}
		res.Body.Close()
		variable.CurrentSeasonId++
	}

	db.DBInst.Variables.ReplaceOne(context.TODO(), bson.M{}, variable)
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
