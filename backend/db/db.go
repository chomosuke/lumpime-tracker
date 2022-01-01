package db

import (
	"context"
	"net/url"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

type DB struct {
	DB        *mongo.Database
	Users     *mongo.Collection
	UserDatas *mongo.Collection
}

func InitDb(connectionString *string) (*DB, func()) {
	client, err := mongo.Connect(context.TODO(), options.Client().ApplyURI(*connectionString))
	if err != nil {
		panic(err)
	}
	// ping the database
	if err := client.Ping(context.TODO(), readpref.Primary()); err != nil {
		panic(err)
	}

	// parse the database name
	url, err := url.Parse(*connectionString)
	if err != nil {
		panic(err)
	}
	databaseName := url.Path[1:] // remove /

	db := new(DB)
	db.DB = client.Database(databaseName)
	db.Users = db.DB.Collection("users")
	db.UserDatas = db.DB.Collection("userDatas")

	return db, func() {
		if err = client.Disconnect(context.TODO()); err != nil {
			panic(err)
		}
	}
}
