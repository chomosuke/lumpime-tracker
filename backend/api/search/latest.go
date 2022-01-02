package search

import (
	"context"
	"net/http"
	"strconv"

	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func Latest(c *gin.Context) {
	start, err := strconv.ParseInt(c.DefaultQuery("start", "0"), 10, 64)
	if err != nil {
		c.Status(http.StatusBadRequest)
		return
	}
	limit, err := strconv.ParseInt(c.DefaultQuery("limit", "50"), 10, 64)
	if err != nil {
		c.Status(http.StatusBadRequest)
		return
	}

	cursor, err := db.DBInst.Films.Find(
		context.TODO(),
		bson.M{},
		options.Find().
			SetProjection(bson.M{}).
			SetSort(bson.M{"seasons": -1}).
			SetSkip(start).
			SetLimit(limit),
	)
	if err != nil {
		panic(err)
	}

	var results []string
	for cursor.Next(context.TODO()) {
		var result db.Film
		if err := cursor.Decode(&result); err != nil {
			panic(err)
		}
		results = append(results, result.ID.Hex())
	}

	if results == nil {
		results = []string{}
	}

	c.JSON(http.StatusOK, results)
}
