package userdata

import (
	"context"
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

func GetFilm(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	cursor, err := db.DBInst.UserDatas.Find(context.TODO(), bson.M{"userId": user.ID})
	if err != nil {
		panic(err)
	}
	var results []bson.M
	if err = cursor.All(context.TODO(), &results); err != nil {
		panic(err)
	}
	if results == nil {
		results = []bson.M{}
	}
	res := []bson.M{}
	for _, result := range results {
		res = append(
			res,
			bson.M{
				"url":  result["url"],
				"data": result["data"],
			},
		)
	}
	c.JSON(http.StatusOK, res)
}
