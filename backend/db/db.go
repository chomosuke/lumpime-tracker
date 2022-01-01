package db

import (
	"context"
	"net/url"

	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

var DBInst Database

type Database struct {
	DB        *mongo.Database
	Users     *mongo.Collection
	UserDatas *mongo.Collection
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
	db.UserDatas = db.DB.Collection("userDatas")

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
}

type UserData struct {
	ID     *primitive.ObjectID `bson:"_id,omitempty"`
	UserID *primitive.ObjectID `bson:"userId"`
	Url    string              `bson:"url"`
	Data   interface{}         `bson:"data"`
}
