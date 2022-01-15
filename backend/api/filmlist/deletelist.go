package filmlist

import (
	"context"
	"net/http"

	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

func DeleteList(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	key := c.Param("key")

	contains := false
	for _, list := range user.FilmLists {
		if list.Key == key {
			contains = true
			break
		}
	}
	if !contains {
		c.Status(http.StatusNoContent)
		return
	}

	result, err := db.DBInst.Users.UpdateByID(
		context.TODO(),
		user.ID,
		bson.M{
			"$pull": bson.M{
				"film_lists": bson.M{
					"key": key,
				},
			},
		},
	)
	if err != nil {
		panic(err)
	}
	if result.MatchedCount != 1 {
		panic(result.MatchedCount)
	}
	c.Status(http.StatusOK)
}
