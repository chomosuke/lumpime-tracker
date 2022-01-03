package search

import (
	"context"
	"net/http"
	"strconv"
	"strings"

	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

func deleteEmpty(s []string) []string {
	var r []string
	for _, str := range s {
		if str != "" {
			r = append(r, str)
		}
	}
	return r
}

func Query(c *gin.Context) {
	query := c.Query("query")

	temps := deleteEmpty(strings.Split(c.Query("seasons"), ","))
	seasons := []int{}
	for _, temp := range temps {
		season, err := strconv.Atoi(temp)
		if err != nil {
			c.Status(http.StatusBadRequest)
			return
		}
		seasons = append(seasons, season)
	}

	genres := deleteEmpty(strings.Split((c.Query("genres")), ","))

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

	pipline := mongo.Pipeline{}

	if query != "" {
		pipline = append(
			pipline,
			bson.D{{
				Key: "$match",
				Value: bson.M{
					"$text": bson.M{
						"$search": query,
					},
				},
			}},
		)
	}

	if len(seasons) != 0 {
		pipline = append(
			pipline,
			bson.D{{
				Key: "$match",
				Value: bson.M{
					"seasons": bson.M{
						"$in": seasons,
					},
				},
			}},
		)
	}

	if len(genres) != 0 {
		pipline = append(
			pipline,
			bson.D{{
				Key: "$match",
				Value: bson.M{
					"genres": bson.M{
						"$in": genres,
					},
				},
			}},
			bson.D{{Key: "$unwind", Value: "$genres"}},
			bson.D{{
				Key: "$match",
				Value: bson.M{
					"genres": bson.M{
						"$in": genres,
					},
				},
			}},
			bson.D{{
				Key: "$group",
				Value: bson.M{
					"_id":     bson.M{"_id": "$_id"},
					"matches": bson.M{"$sum": 1},
				},
			}},
			bson.D{{
				Key:   "$project",
				Value: bson.M{"_id": "$_id._id"},
			}},
		)
	}

	var sortStage bson.D
	if len(genres) != 0 {
		sortStage = append(sortStage, bson.E{Key: "matches", Value: -1})
	}
	if query != "" {
		sortStage = append(sortStage, bson.E{Key: "score", Value: bson.M{"$meta": "textScore"}})
	}
	sortStage = append(sortStage, bson.E{Key: "seasons", Value: -1})

	pipline = append(pipline, bson.D{{Key: "$sort", Value: sortStage}})
	pipline = append(pipline, bson.D{{Key: "$project", Value: bson.M{"id": 1}}})
	pipline = append(pipline, bson.D{{Key: "$skip", Value: start}})
	pipline = append(pipline, bson.D{{Key: "$limit", Value: limit}})

	cursor, err := db.DBInst.Films.Aggregate(
		context.TODO(),
		pipline,
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
