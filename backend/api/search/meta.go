package search

import (
	"context"
	"net/http"

	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func max(a, b int32) int32 {
	if a > b {
		return a
	}
	return b
}

func Meta(c *gin.Context) {

	tmps, err := db.DBInst.Films.Distinct(context.TODO(), "genres", bson.M{})
	if err != nil {
		panic(err)
	}
	genres := []string{}
	for _, tmp := range tmps {
		if genre, ok := tmp.(string); ok {
			genres = append(genres, genre)
		}
	}

	cursor, err := db.DBInst.Films.Find(
		context.TODO(),
		bson.M{},
		options.Find().
			SetProjection(bson.M{"seasons": 1}).
			SetSort(bson.M{"seasons": -1}).
			SetLimit(1),
	)
	if err != nil {
		panic(err)
	}
	var latest bson.M
	cursor.Next(context.TODO())
	err = cursor.Decode(&latest)
	if err != nil {
		panic(err)
	}

	seasons := latest["seasons"].(bson.A)
	var newest int32
	for _, season := range seasons {
		newest = max(newest, season.(int32))
	}

	c.JSON(
		http.StatusOK,
		gin.H{
			"genres": genres,
			"newest": newest,
		},
	)
}
