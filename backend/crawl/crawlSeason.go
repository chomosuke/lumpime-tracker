package crawl

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/PuerkitoBio/goquery"
	"github.com/chomosuke/backend/db"
	"go.mongodb.org/mongo-driver/bson"
	"golang.org/x/net/context"
)

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

func crawlSeason(res *http.Response, season int) {
	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		db.DBInst.Error.InsertOne(context.TODO(), bson.M{"error": err, "number": 7})
		panic(err)
	}

	doc.Find("a.link-title").Each(func(i int, s *goquery.Selection) {
		url, exists := s.Attr("href")
		if !exists {
			fmt.Printf("href doesn't exist for anime? season:%d", season)
		}
		url = url[:strings.LastIndex(url, "/")]
		_, err := db.DBInst.Films.UpdateOne(
			context.TODO(),
			bson.M{"url": url},
			bson.M{
				"$addToSet": bson.M{
					"seasons": season,
				},
			},
		)
		if err != nil {
			db.DBInst.Error.InsertOne(context.TODO(), bson.M{"error": err, "number": 8})
			panic(err)
		}
	})
}
