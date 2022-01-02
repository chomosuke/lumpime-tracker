package search

import (
	"context"
	"net/http"

	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func Film(c *gin.Context) {
	var film db.Film
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.Status(http.StatusNotFound)
		return
	}
	err = db.DBInst.Films.FindOne(context.TODO(), bson.M{"_id": id}).Decode(&film)
	if err != nil {
		c.Status(http.StatusNotFound)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"url":       film.Url,
		"name":      film.Name,
		"alt_names": film.AltNames,
		"img_url":   film.ImgUrl,
		"episodes":  film.Episodes,
		"seasons":   film.Seasons,
		"genres":    film.Genres,
		"status":    film.Status,
	})
}
