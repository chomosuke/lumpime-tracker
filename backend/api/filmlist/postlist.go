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

func PostList(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	body, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		panic(err)
	}
	key := string(body)

	for _, list := range user.FilmLists {
		if list.Key == key {
			// already have key
			c.Status(http.StatusConflict)
			return
		}
	}

	_, err = db.DBInst.Users.UpdateByID(
		context.TODO(),
		user.ID,
		bson.M{
			"$push": bson.M{
				"film_lists": db.FilmList{
					Key: key,
					IDs: []string{},
				},
			},
		},
	)
	if err != nil {
		panic(err)
	}

	c.Status(http.StatusOK)
}
