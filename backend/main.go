package main

import (
	"flag"
	"fmt"
	"time"

	"github.com/chomosuke/backend/api/account"
	"github.com/chomosuke/backend/api/search"
	"github.com/chomosuke/backend/api/userdata"
	"github.com/chomosuke/backend/auth"
	"github.com/chomosuke/backend/crawl"
	"github.com/chomosuke/backend/db"
	"github.com/gin-contrib/cors"
	"github.com/gin-contrib/static"
	"github.com/gin-gonic/gin"
)

func main() {
	// parse cmd args first
	address := flag.String("a", "127.0.0.1", "address for the server")
	port := flag.Int("p", 80, "port for the server")
	dbConnection := flag.String("c", "mongodb://localhost:27017/film-list", "connection string for mongodb database")
	auth.Secret = flag.String("s", "an insecure secret", "secret for authentication")
	release := flag.Bool("r", false, "set to release mode")

	flag.Parse()

	// connect to database
	database, cleanup := db.InitDb(*dbConnection)
	db.DBInst = database
	defer cleanup()

	// start crawling
	go crawl.Crawl()

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
		config := cors.DefaultConfig()
		config.AllowAllOrigins = true
		config.AddAllowHeaders(auth.AuthHeader)
		r.Use(cors.New(config))

		r.Use(func(c *gin.Context) {
			time.Sleep(500 * time.Millisecond)
			c.Next()
		})
	}

	endpoints := r.Group("/api")
	{
		endpoints.GET("/meta", search.Meta)
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

	r.Run(fmt.Sprintf("%s:%d", *address, *port))
}
