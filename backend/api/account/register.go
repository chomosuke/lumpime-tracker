package account

import (
	"context"
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type registerReq struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

func Register(c *gin.Context) {
	var req registerReq
	if c.BindJSON(&req) != nil {
		return
	}
	if UsernameExist(req.Username) {
		// found the same user
		c.Status(http.StatusConflict)
		return
	}
	user := db.User{
		Username: req.Username,
		Password: req.Password,
	}
	result, err := db.DBInst.Users.InsertOne(context.TODO(), user)
	if err != nil {
		panic(err)
	}
	c.String(http.StatusOK, auth.GetToken(result.InsertedID.(primitive.ObjectID).Hex()))
}

func UsernameExist(username string) bool {
	return db.DBInst.Users.FindOne(context.TODO(), bson.M{
		"username": username,
	}).Err() == nil
}
