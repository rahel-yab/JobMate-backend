package controllers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"

	svc "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
	uc "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/usecases"

	"github.com/gin-gonic/gin"
)

type OAuth2Controller struct {
	OAuthService svc.IOAuth2Service
	AuthUsecase  uc.IAuthUsecase
}

func NewOAuth2Controller(service svc.IOAuth2Service, authUsecase uc.IAuthUsecase) *OAuth2Controller {
	return &OAuth2Controller{
		OAuthService: service,
		AuthUsecase:  authUsecase,
	}
}

func (ctrl *OAuth2Controller) RedirectToProvider(c *gin.Context) {
	provider := c.Param("provider")

	state := "random-state" 
	url, err := ctrl.OAuthService.GetAuthorizationURL(provider, state)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.Redirect(http.StatusFound, url)
}

func (ctrl *OAuth2Controller) HandleCallback(c *gin.Context) {
  ctx := c.Request.Context()
  provider := c.Param("provider")
  code := c.Query("code")

  if code == "" {
    c.JSON(http.StatusBadRequest, gin.H{"error": "Missing code in query"})
    return
  }

  // authenticate with the provider
  oauthUser, err := ctrl.OAuthService.Authenticate(ctx, provider, code)
  if err != nil {
    c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
    return
  }

  // register/login via usecase
  result, err := ctrl.AuthUsecase.OAuthLogin(ctx, oauthUser)
  if err != nil {
    c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
    return
  }

  // store refresh token in HttpOnly cookie
  http.SetCookie(c.Writer, &http.Cookie{
    Name:     "refresh_token",
    Value:    result.RefreshToken,
    Path:     "/",
    HttpOnly: true,
    Secure:   true,
    SameSite: http.SameSiteLaxMode,
    MaxAge:   int(result.ExpiresIn.Seconds()),
  })

  // safe user data
  safeUser := gin.H{
    "user_id":     result.User.UserID,
    "email":       result.User.Email,
    "firstName":   result.User.FirstName,
    "lastName":    result.User.LastName,
    "provider":    result.User.Provider,
    "access_token": result.AccessToken,
  }

  // encode user as JSON for query param
  userJSON, err := json.Marshal(safeUser)
  if err != nil {
    c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to encode user"})
    return
  }

  
  frontendURL := "https://jobmate-kappa.vercel.app"  //or deployed frontend
  redirectURL := fmt.Sprintf("%s/login?token=%s&user=%s",
    frontendURL,
    url.QueryEscape(result.AccessToken),
    url.QueryEscape(string(userJSON)),
  )

  c.Redirect(http.StatusTemporaryRedirect, redirectURL)
}

