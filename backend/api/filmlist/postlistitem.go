package filmlist

import (
	"context"
	"io/ioutil"
	"net/http"

	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

func PostListItem(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	body, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		panic(err)
	}
	id := string(body)

	key := c.Param("key")

	var filmList *db.FilmList
	for _, list := range user.FilmLists {
		if list.Key == key {
			filmList = &list
			break
		}
	}
	if filmList == nil {
		c.Status(http.StatusNotFound)
		return
	}

	_, err = db.DBInst.Users.UpdateOne(
		context.TODO(),
		bson.M{"_id": user.ID, "film_lists.key": key},
		bson.M{
			"$push": bson.M{
				"film_lists.$.ids": id,
			},
		},
	)
	if err != nil {
		panic(err)
	}

	c.Status(http.StatusOK)
}
