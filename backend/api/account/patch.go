package account

import (
	"context"
	"fmt"
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

type patchReq struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func Patch(c *gin.Context) {
	var req patchReq
	if c.BindJSON(&req) != nil {
		return
	}
	user := c.MustGet(auth.User).(db.User)
	// check for username conflict
	if user.Username != req.Username &&
		req.Username != "" && // change in username
		UsernameExist(req.Username) {
		// username taken
		c.Status(http.StatusConflict)
		return
	}
	fmt.Print(req.Username)
	if req.Username != "" {
		user.Username = req.Username
	}
	if req.Password != "" {
		user.Password = req.Password
	}
	result, err := db.DBInst.Users.ReplaceOne(
		context.TODO(),
		bson.M{"_id": user.ID},
		user,
	)
	if err != nil {
		panic(err)
	}
	if result.MatchedCount != 1 {
		panic(result)
	}
	c.Status(http.StatusOK)
}
