package main

import (
	"flag"
	"fmt"

	"github.com/chomosuke/film-list/api/account"
	"github.com/chomosuke/film-list/api/search"
	"github.com/chomosuke/film-list/api/userdata"
	"github.com/chomosuke/film-list/auth"
	"github.com/chomosuke/film-list/db"
	"github.com/gin-contrib/cors"
	"github.com/gin-contrib/static"
	"github.com/gin-gonic/gin"
)

func main() {
	// parse cmd args first
	port := flag.Int("p", 80, "port for the server")
	dbConnection := flag.String("c", "mongodb://localhost:27017/film-list", "connection string for mongodb database")
	auth.Secret = flag.String("s", "an insecure secret", "secret for authentication")
	release := flag.Bool("r", false, "set to release mode")

	flag.Parse()

	// connect to database
	database, cleanup := db.InitDb(*dbConnection)
	db.DBInst = database
	defer cleanup()

	if *release {
		gin.SetMode(gin.ReleaseMode)
	}

	// configurate and start the server.
	r := gin.Default()

	err := r.SetTrustedProxies(nil)
	if err != nil {
		panic(err)
	}

	if !*release {
		r.Use(cors.Default())
	}

	endpoints := r.Group("/api")
	{
		endpoints.GET("/meta", search.Meta)
		endpoints.POST("/crawl", search.Crawl)
		endpoints.GET("/query", search.Query)
		endpoints.GET("/film/:id", search.Film)

		endpoints.POST("/login", account.Login)
		endpoints.POST("/register", account.Register)

		authorized := endpoints.Group("/")
		authorized.Use(auth.Middleware)
		{
			authorized.PATCH("/user", account.Patch)
			authorized.GET("/username", account.Username)

			userData := authorized.Group("/user")
			{
				userData.GET("/film/:id", userdata.GetFilm)
				userData.PUT("/film/:id", userdata.PutFilm)
				userData.GET("/data", userdata.GetData)
				userData.PUT("/data", userdata.PutData)
			}
		}
	}

	r.Use(static.Serve("/", static.LocalFile("../web_build", true)))

	r.Run(fmt.Sprintf(":%d", *port))
}
