package account

import (
	"context"
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

type loginReq struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

func Login(c *gin.Context) {
	var req loginReq
	if c.ShouldBindJSON(&req) != nil {
		c.Status(http.StatusUnprocessableEntity)
		return
	}
	var user db.User
	err := db.DBInst.Users.FindOne(context.TODO(), bson.D{
		{Key: "username", Value: req.Username},
		{Key: "password", Value: req.Password},
	}).Decode(&user)
	if err != nil {
		c.Status(http.StatusUnauthorized)
		return
	}
	c.String(http.StatusOK, auth.GetToken(user.ID.Hex()))
}
