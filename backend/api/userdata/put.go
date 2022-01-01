package userdata

import (
	"context"
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

type putReq struct {
	Url  string      `json:"url" binding:"required"`
	Data interface{} `json:"data" binding:"required"`
}

func Put(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	var req putReq
	if c.BindJSON(&req) != nil {
		return
	}
	userData := db.UserData{
		UserID: user.ID,
		Url:    req.Url,
		Data:   req.Data,
	}
	filter := bson.D{
		{Key: "url", Value: req.Url},
		{Key: "userId", Value: user.ID},
	}
	if db.DBInst.UserDatas.FindOne(context.TODO(), filter).Err() == nil {
		result, err := db.DBInst.UserDatas.ReplaceOne(context.TODO(), filter, userData)
		if err != nil || result.MatchedCount != 1 {
			panic(err)
		}
	} else {
		_, err := db.DBInst.UserDatas.InsertOne(context.TODO(), userData)
		if err != nil {
			panic(err)
		}
	}
	c.Status(http.StatusOK)
}
