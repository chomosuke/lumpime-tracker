package userdata

import (
	"context"
	"net/http"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func PutFilm(c *gin.Context) {
	user := c.MustGet(auth.User).(db.User)
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.Status(http.StatusNotFound)
		return
	}
	var req interface{}
	if c.BindJSON(&req) != nil {
		return
	}
	err = db.DBInst.Films.FindOne(context.TODO(), bson.M{"_id": id}).Err()
	if err != nil {
		c.Status(http.StatusNotFound)
		return
	}

	userData := db.UserFilm{
		UserID: user.ID,
		FilmID: &id,
		Data:   req,
	}
	filter := bson.M{
		"filmId": &id,
		"userId": user.ID,
	}
	if db.DBInst.UserFilms.FindOne(context.TODO(), filter).Err() == nil {
		result, err := db.DBInst.UserFilms.ReplaceOne(context.TODO(), filter, userData)
		if err != nil || result.MatchedCount != 1 {
			panic(err)
		}
	} else {
		_, err := db.DBInst.UserFilms.InsertOne(context.TODO(), userData)
		if err != nil {
			panic(err)
		}
	}
	c.Status(http.StatusOK)
}
