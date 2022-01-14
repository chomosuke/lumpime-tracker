package account

import (
	"context"
	"net/http"

	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type loginReq struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

func Login(c *gin.Context) {
	var req loginReq
	if c.BindJSON(&req) != nil {
		return
	}
	var user db.User
	err := db.DBInst.Users.FindOne(context.TODO(), bson.M{
		"username": req.Username,
		"password": req.Password,
	}).Decode(&user)
	if err == mongo.ErrNoDocuments {
		c.Status(http.StatusUnauthorized)
		return
	} else if err != nil {
		panic(err)
	}
	c.String(http.StatusOK, auth.GetToken(user.ID.Hex()))
}
