package userfilm

import (
	"context"
	"net/http"

	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func Get(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.Status(http.StatusNotFound)
		return
	}
	err = db.DBInst.Films.FindOne(context.TODO(), bson.M{"_id": id}).Err()
	if err == mongo.ErrNoDocuments {
		c.Status(http.StatusNotFound)
		return
	} else if err != nil {
		panic(err)
	}

	var userFilm db.UserFilm
	err = db.DBInst.UserFilms.FindOne(
		context.TODO(),
		bson.M{"userId": user.ID, "filmId": id},
	).Decode(&userFilm)
	if err != mongo.ErrNoDocuments && err != nil {
		panic(err)
	}

	if err == mongo.ErrNoDocuments {
		// not found
		c.JSON(http.StatusOK, bson.M{})
	} else {
		c.JSON(http.StatusOK, userFilm.Data.(bson.D).Map())
	}
}
