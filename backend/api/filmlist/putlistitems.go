package filmlist

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"net/http"

	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

func PutListItems(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)

	var filmIDList []string

	body, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		panic(err)
	}

	err = json.Unmarshal(body, &filmIDList)
	if err != nil {
		c.Status(http.StatusBadRequest)
		return
	}

	key := c.Param("key")

	var index *int
	for i, list := range user.FilmLists {
		if list.Key == key {
			index = &i
			break
		}
	}
	if index == nil {
		c.Status(http.StatusNotFound)
		return
	}

	user.FilmLists[*index].IDs = filmIDList

	result, err := db.DBInst.Users.ReplaceOne(
		context.TODO(),
		bson.M{
			"_id": user.ID,
		},
		user,
	)
	if err != nil {
		panic(err)
	}
	if result.MatchedCount != 1 {
		panic(result.MatchedCount)
	}

	c.Status(http.StatusOK)
}
