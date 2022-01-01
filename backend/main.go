package main

import (
	"flag"
	"fmt"

	"github.com/chomosuke/film-list/api/account"
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
	database, cleanup := db.InitDb(*dbConnection)
	db.DBInst = database
	defer cleanup()

	// configurate and start the server.
	r := gin.Default()

	endpoints := r.Group("/api")
	{
		endpoints.POST("/login", account.Login)
		endpoints.POST("/register", account.Register)

		authorized := endpoints.Group("/")
		authorized.Use(auth.Middleware)
		{
			authorized.PATCH("/account", account.Patch)
			authorized.GET("/username", account.Username)
		}
	}

	r.Run(fmt.Sprintf(":%d", *port))
}
