package config

import (
	"log"
	"os"
)

// GetServerPort decides which port to use depending on environment
func GetServerPort() string {
	appEnv := os.Getenv("APP_ENV")
	port := "8080"

	if appEnv == "development" {
		// fallback to 8080 in dev if no PORT is set
		if port == "" {
			port = "8080"
		}
	} else {
		// in production, Render *must* provide PORT
		if port == "" {
			log.Fatal("PORT environment variable not set")
		}
	}

	return port
}
