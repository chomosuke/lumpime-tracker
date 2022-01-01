package userdata

import (
	"context"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

func Delete(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	url, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		panic(err)
	}
	filter := bson.D{
		{Key: "url", Value: string(url)},
		{Key: "userId", Value: user.ID},
	}
	result, err := db.DBInst.UserDatas.DeleteOne(context.TODO(), filter)
	if err != nil {
		panic(err)
	}
	if result.DeletedCount == 0 {
		c.Status(http.StatusNoContent)
	} else if result.DeletedCount == 1 {
		c.Status(http.StatusOK)
	} else {
		panic(fmt.Sprintf("multiple doc with same url: %s & same user: %s?", url, user.ID.Hex()))
	}
}
