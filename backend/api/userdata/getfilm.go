package userdata

import (
	"context"
	"net/http"

	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func GetFilm(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.Status(http.StatusNotFound)
		return
	}
	err = db.DBInst.Films.FindOne(context.TODO(), bson.M{"_id": id}).Err()
	if err != nil {
		c.Status(http.StatusNotFound)
		return
	}
	var userFilm db.UserFilm
	err = db.DBInst.UserFilms.FindOne(
		context.TODO(),
		bson.M{"userId": user.ID, "filmId": id},
	).Decode(&userFilm)
	if err != nil {
		// not found
		c.JSON(http.StatusOK, bson.M{})
	} else {
		c.JSON(http.StatusOK, userFilm.Data.(bson.D).Map())
	}
}
