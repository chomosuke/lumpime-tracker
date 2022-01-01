package userdata

import (
	"context"
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

func Get(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	cursor, err := db.DBInst.UserDatas.Find(context.TODO(), bson.D{{Key: "userId", Value: user.ID}})
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
	c.JSON(http.StatusOK, results)
}
