package filmlist

import (
	"net/http"

	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
)

func GetLists(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)

	key := []string{}
	for _, list := range user.FilmLists {
		key = append(key, list.Key)
	}

	c.JSON(http.StatusOK, key)
}
