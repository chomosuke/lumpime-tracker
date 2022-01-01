package account

import (
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
)

func Username(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	c.String(http.StatusOK, user.Username)
}
