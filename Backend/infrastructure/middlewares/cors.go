package middlewares

import (
	"os"
	"strings"

	"github.com/gin-gonic/gin"
)

// CORS middleware
func CORS() gin.HandlerFunc {
	appEnv := os.Getenv("APP_ENV")
	allowedOrigins := os.Getenv("ALLOWED_ORIGINS")

	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")

		if appEnv == "development" {
			// open for all in dev
			c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		} else {
			// production → only allow listed origins
			origins := strings.Split(allowedOrigins, ",")
			for _, o := range origins {
				if strings.TrimSpace(o) == origin {
					c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
					break
				}
			}
		}

		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, Accept, Authorization")
		c.Writer.Header().Set("AllowCredentials", "true")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}