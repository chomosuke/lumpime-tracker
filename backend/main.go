package main

import (
	"flag"
	"fmt"

	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
)

var DB *db.DB

func main() {
	// parse cmd args first
	port := flag.Int("p", 80, "port for the server")
	dbConnection := flag.String("c", "", "connection string for mongodb database")

	flag.Parse()

	// connect to database
	db, cleanup := db.InitDb(dbConnection)
	DB = db
	defer cleanup()

	// configurate and start the server.
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	r.Run(fmt.Sprintf(":%d", *port))
}
