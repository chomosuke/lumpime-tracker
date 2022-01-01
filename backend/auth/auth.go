package auth

import (
	"errors"
	"fmt"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
)

var JWTKey *string

const AuthHeader = "Authorization"

const User = "user"

func Middleware(c *gin.Context) {
	token, err := jwt.Parse(c.GetHeader(AuthHeader), func(token *jwt.Token) (interface{}, error) {
		// algorithm should be what I expect
		if _, ok := token.Method.(*jwt.SigningMethodECDSA); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}

		return []byte(*JWTKey), nil
	})

	if claim, ok := token.Claims.(claim); ok && token.Valid && err == nil {
		c.Set("User", claim.username)
		c.Next()
		return
	}
	c.Status(401)
}

type claim struct {
	username string
	expiry   int64
}

func (c claim) Valid() error {
	if c.expiry < time.Now().Unix() {
		return nil
	}
	return errors.New("invalid token")
}

const expiry = 2592000 // 30 days

func GetToken(username *string) *jwt.Token {
	return jwt.NewWithClaims(jwt.SigningMethodES512, claim{
		username: *username,
		expiry:   time.Now().Unix() + expiry,
	})
}
