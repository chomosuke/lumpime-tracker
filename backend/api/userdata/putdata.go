package userdata

import (
	"context"
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

func PutData(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	var req interface{}
	if c.BindJSON(&req) != nil {
		return
	}

	db.DBInst.Users.UpdateByID(
		context.TODO(),
		user.ID,
		bson.M{
			"$set": bson.M{
				"data": req,
			},
		},
	)

	c.Status(http.StatusOK)
}
