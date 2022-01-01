package main

import (
	"flag"
	"fmt"

	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-gonic/gin"
)

func main() {
	// parse cmd args first
	port := flag.Int("p", 80, "port for the server")
	dbConnection := flag.String("c", "", "connection string for mongodb database")
	auth.JWTKey = flag.String("s", "an insecure secret", "secret for authentication")

	flag.Parse()

	// connect to database
	database, cleanup := db.InitDb(dbConnection)
	db.DB = database
	defer cleanup()

	// configurate and start the server.
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	r.Use()
	r.Run(fmt.Sprintf(":%d", *port))
}
