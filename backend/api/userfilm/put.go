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

func Put(c *gin.Context) {
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
	if err == mongo.ErrNoDocuments {
		c.Status(http.StatusNotFound)
		return
	} else if err != nil {
		panic(err)
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
	err = db.DBInst.UserFilms.FindOne(context.TODO(), filter).Err()
	if err != mongo.ErrNoDocuments && err != nil {
		panic(err)
	}
	if err != mongo.ErrNoDocuments {
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
