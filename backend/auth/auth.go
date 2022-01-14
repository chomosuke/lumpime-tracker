package auth

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/chomosuke/backend/db"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

var Secret *string

const AuthHeader = "Authorization"

const User = "user"

func Middleware(c *gin.Context) {
	token, err := jwt.Parse(c.GetHeader(AuthHeader), func(token *jwt.Token) (interface{}, error) {
		// algorithm should be what I expect
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(*Secret), nil
	})
	if err == nil {
		if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
			var user db.User
			id, _ := primitive.ObjectIDFromHex(claims["ID"].(string))
			err := db.DBInst.Users.FindOne(
				context.TODO(),
				bson.M{"_id": id},
			).Decode(&user)
			if err == nil {
				c.Set(User, user)
				c.Next()
				return
			} else if err != mongo.ErrNoDocuments {
				panic(err)
			}
		}
	}
	c.Status(http.StatusUnauthorized)
	c.Abort()
}

type claims struct {
	ID     string
	Expiry int64
}

func (c claims) Valid() error {
	if c.Expiry > time.Now().Unix() {
		return nil
	}
	return errors.New("invalid token")
}

const expiry = 2592000 // 30 days

func GetToken(userID string) string {
	token, err := jwt.NewWithClaims(jwt.SigningMethodHS512, claims{
		ID:     userID,
		Expiry: time.Now().Unix() + expiry,
	}).SignedString([]byte(*Secret))
	if err != nil {
		panic(err)
	}
	return token
}
