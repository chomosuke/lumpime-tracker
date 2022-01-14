package search

import (
	"context"
	"net/http"

	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func Film(c *gin.Context) {
	var film db.Film
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.Status(http.StatusNotFound)
		return
	}
	err = db.DBInst.Films.FindOne(context.TODO(), bson.M{"_id": id}).Decode(&film)
	if err == mongo.ErrNoDocuments {
		c.Status(http.StatusNotFound)
		return
	} else if err != nil {
		panic(err)
	}

	c.JSON(http.StatusOK, gin.H{
		"url":       film.Url,
		"name":      film.Name,
		"alt_names": film.AltNames,
		"english":   film.English,
		"img_url":   film.ImgUrl,
		"episodes":  film.Episodes,
		"seasons":   film.Seasons,
		"genres":    film.Genres,
		"status":    film.Status,
	})
}
