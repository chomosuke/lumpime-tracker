package filmlist

import (
	"context"
	"net/http"

	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

func DeleteListItem(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)

	key := c.Param("key")

	id := c.Param("id")

	var filmListIndex *int
	for i, list := range user.FilmLists {
		if list.Key == key {
			filmListIndex = &i
			break
		}
	}
	if filmListIndex == nil {
		c.Status(http.StatusNotFound)
		return
	}

	var index *int
	for i, existingID := range user.FilmLists[*filmListIndex].IDs {
		if existingID == id {
			index = &i
			break
		}
	}
	if index == nil {
		c.Status(http.StatusNoContent)
		return
	}

	user.FilmLists[*filmListIndex].IDs = append(
		user.FilmLists[*filmListIndex].IDs[:*index],
		user.FilmLists[*filmListIndex].IDs[*index+1:]...,
	)

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
