package db

import (
	"context"
	"net/url"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

var DBInst Database

type Database struct {
	DB        *mongo.Database
	Users     *mongo.Collection
	UserFilms *mongo.Collection
	Films     *mongo.Collection
}

func InitDb(connectionString string) (Database, func()) {
	client, err := mongo.Connect(context.TODO(), options.Client().ApplyURI(connectionString))
	if err != nil {
		panic(err)
	}
	// ping the database
	if err := client.Ping(context.TODO(), readpref.Primary()); err != nil {
		panic(err)
	}

	// parse the database name
	url, err := url.Parse(connectionString)
	if err != nil {
		panic(err)
	}
	databaseName := url.Path[1:] // remove /

	db := new(Database)
	db.DB = client.Database(databaseName)
	db.Users = db.DB.Collection("users")
	db.UserFilms = db.DB.Collection("userFilms")
	db.Films = db.DB.Collection("films")

	// create indexes
	db.Users.Indexes().CreateOne(context.Background(), mongo.IndexModel{
		Keys:    bson.M{"username": 1},
		Options: options.Index().SetUnique(true),
	})
	db.UserFilms.Indexes().CreateOne(context.Background(), mongo.IndexModel{
		Keys:    bson.M{"userId": 1, "filmId": 1},
		Options: options.Index().SetUnique(true),
	})

	return *db, func() {
		if err = client.Disconnect(context.TODO()); err != nil {
			panic(err)
		}
	}
}

type User struct {
	ID       *primitive.ObjectID `bson:"_id,omitempty"`
	Username string              `bson:"username"`
	Password string              `bson:"password"`
	Data     interface{}         `bson:"data"`
}

type UserFilm struct {
	ID     *primitive.ObjectID `bson:"_id,omitempty"`
	UserID *primitive.ObjectID `bson:"userId"`
	FilmID *primitive.ObjectID `bson:"filmId"`
	Data   interface{}         `bson:"data"`
}

type Film struct {
	ID       *primitive.ObjectID `bson:"_id,omitempty"`
	Url      string              `bson:"url"`
	Name     string              `bson:"name"`
	AltNames []string            `bson:"alt_names"`
	English  string              `bson:"english"`
	KeyWords string              `bson:"key_words"`
	ImgUrl   string              `bson:"img_url"`
	Episodes int                 `bson:"episodes"`
	Seasons  []int               `bson:"seasons"`
	Genres   []string            `bson:"genres"`
	Status   string              `bson:"status"`
}
