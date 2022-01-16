package filmlist

import (
	"net/http"

	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
)

func GetListItems(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)

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

	c.JSON(http.StatusOK, filmList.IDs)
}
