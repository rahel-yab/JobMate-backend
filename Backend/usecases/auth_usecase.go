package usecases

import (
	"context"
	"errors"
	"fmt"

	"time"
	"unicode"

	"github.com/tsigemariamzewdu/JobMate-backend/domain"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"

	repo "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/repositories"
	svc "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
	uc "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/usecases"

	"golang.org/x/crypto/bcrypt"
)

type AuthUsecase struct {
	AuthRepo        repo.IAuthRepository
	OTPRepo        repo.IOTPRepository      
	PasswordService svc.IPasswordService
	JWTService      svc.IJWTService
	EmailService    svc.IEmailService
	BaseURL         string
	ContextTimeout  time.Duration
}

func NewAuthUsecase(repo repo.IAuthRepository, ps svc.IPasswordService, jw svc.IJWTService, bs string,OTPRepo repo.IOTPRepository , timeout time.Duration, emailService svc.IEmailService)uc.IAuthUsecase {
	return &AuthUsecase{
		AuthRepo:        repo,
		PasswordService: ps,
		JWTService:      jw,
		BaseURL:         bs,
		OTPRepo: OTPRepo,
		ContextTimeout:  timeout,
		EmailService:    emailService,
	}
}

// register usecase

// Register handles user registration, supporting both traditional and OAuth-based flows
func (uc *AuthUsecase) Register(ctx context.Context, input *models.User, oauthUser *models.User) (*models.User, error) {

	var email *string
	if oauthUser != nil {
		email = oauthUser.Email
	} else {
		email = input.Email

		// check password strength (min 8 chars, at least one number and one letter)
		if !validatePasswordStrength(*input.Password) {
			return nil, fmt.Errorf("%w", domain.ErrWeakPassword)
		}
	}

	
	// check if email already exists
	count, err := uc.AuthRepo.CountByEmail(ctx, *email)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", domain.ErrDatabaseOperationFailed, err)
	}
	if count > 0 {
		return nil, fmt.Errorf("%w", domain.ErrEmailAlreadyExists)
	}

	
    // OTP verification (only for normal registration, not OAuth)
if oauthUser == nil {
    if input.OTP == nil {
        return nil, fmt.Errorf("%w", errors.New("input otp is empty "))
    }

    // fetch latest OTP for email - FIXED: Use GetLatestCodeByEmail instead of GetRecentRequestsByEmail
    code, err := uc.OTPRepo.GetLatestCodeByEmail(ctx, *email)
    if err != nil {
        return nil, fmt.Errorf("%w: %v", domain.ErrDatabaseOperationFailed, err)
    }
    if code == nil {
        return nil, fmt.Errorf("%w", errors.New("error getting the latest code by email"))
    }

    if code.Used || time.Now().After(code.ExpiresAt) {
        return nil, fmt.Errorf("%w", domain.ErrOTPExpired)
    }

    if err := bcrypt.CompareHashAndPassword([]byte(code.CodeHash), []byte(*input.OTP)); err != nil {
        return nil, fmt.Errorf("%w", domain.ErrInvalidOTP)
    }

    // mark OTP as used - FIXED: Method name should be MarkCodeAsUsed
    if err := uc.OTPRepo.MarkCodeAsUsed(ctx, code.ID); err != nil {
        return nil, fmt.Errorf("%w: %v", domain.ErrOTPUseFailed, err)
    }
}

	

	var hashedPassword *string
	if oauthUser == nil {
		hashed, err := uc.PasswordService.HashPassword(*input.Password)
		if err != nil {
			return nil, fmt.Errorf("%w: %v", domain.ErrPasswordHashingFailed, err)
		}
		hashedPassword = &hashed
	}

	// construct user model
	newUser := models.User{
		FirstName: chooseNonEmpty(get(input, func(u *models.User) *string { return u.FirstName }), get(oauthUser, func(u *models.User) *string { return u.FirstName })),
		LastName:  chooseNonEmpty(get(input, func(u *models.User) *string { return u.LastName }), get(oauthUser, func(u *models.User) *string { return u.LastName })),

		Email:          email,
		IsVerified: true,
		Password:       hashedPassword,
		ProfilePicture: oauthUserPicture(oauthUser),
		Provider:       oauthUserProvider(oauthUser),
		CreatedAt:      time.Now(),
		UpdatedAt:      time.Now(),
	}

	// save user to the database
	err = uc.AuthRepo.CreateUser(ctx, &newUser)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", domain.ErrUserCreationFailed, err)
	}
	


	return &newUser, nil
}

// login usecase

// Login handles user login usecase
func (uc *AuthUsecase) Login(ctx context.Context, input *models.User) (*models.LoginResult, error) {

	// find user by email 
	var user *models.User
	var err error

	if validateEmail(*input.Email) {
		user, err = uc.AuthRepo.FindByEmail(ctx, *input.Email)
	} 

	if err != nil {
		return nil, fmt.Errorf("%w: %v", domain.ErrInvalidCredentials, err)
	}

	// reject login if registered via OAuth
	if user.Provider != "" {
		return nil, fmt.Errorf("%w", domain.ErrOAuthUserCannotLoginWithPassword)
	}

	// Check if the user's email is verified
	if !user.IsVerified {
		return nil, fmt.Errorf("%w", domain.ErrEmailNotVerified)
	}

	// compare passwords
	if user.PasswordHash == nil || !uc.PasswordService.ComparePassword(*user.PasswordHash, *input.Password) {
		return nil, fmt.Errorf("%w", domain.ErrInvalidCredentials)
	}

	// generate access token (handle nil PreferredLanguage)
	lang := "en"
	if user.PreferredLanguage != nil {
		lang = string(*user.PreferredLanguage)
	}
	accessToken, expiresIn, err := uc.JWTService.GenerateAccessToken(user.UserID, lang)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", domain.ErrTokenGenerationFailed, err)
	}

	// generate refresh token
	refreshToken, err := uc.JWTService.GenerateRefreshToken(user.UserID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", domain.ErrTokenGenerationFailed, err)
	}

	

	

	// update the user (save the tokens into database)
	err = uc.AuthRepo.SaveRefreshToken(ctx, user.UserID, refreshToken)
	if err != nil {
		return nil, err
	}
	result := models.LoginResult{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    expiresIn,
		User:         user,
	}

	return &result, nil
}

// OAuthLogin logs in or registers a user via an OAuth2 provider
func (uc *AuthUsecase) OAuthLogin(ctx context.Context, oauthUser *models.User) (*models.LoginResult, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.ContextTimeout)
	defer cancel()

	if oauthUser == nil || oauthUser.Email == nil {
		return nil, domain.ErrInvalidOAuthUserData
	}

	// check if the user exists
	user, err := uc.AuthRepo.FindByEmail(ctx, *oauthUser.Email)
	if err != nil {
		// if user doesn't exist, register them
		if err == domain.ErrUserNotFound {
			user, err = uc.Register(ctx, nil, oauthUser)
			if err != nil {
				return nil, err
			}
		} else {
			return nil, domain.ErrDatabaseOperationFailed
		}
	}


	// generate access token (handle nil PreferredLanguage)
	lang := "en"
	if user.PreferredLanguage != nil {
		lang = string(*user.PreferredLanguage)
	}
	accessToken, expiresIn, err := uc.JWTService.GenerateAccessToken(user.UserID, lang)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", domain.ErrTokenGenerationFailed, err)
	}

	// generate refresh token
	refreshToken, err := uc.JWTService.GenerateRefreshToken(user.UserID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", domain.ErrTokenGenerationFailed, err)
	}

	//save only the refeshtoken

	if err := uc.AuthRepo.SaveRefreshToken(ctx, user.UserID, refreshToken); err != nil {
		return nil, fmt.Errorf("%w: %v", domain.ErrDatabaseOperationFailed, err)
	}

	

	return &models.LoginResult{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    expiresIn,
		User:         user,
	}, nil
}

// helper functions
func chooseNonEmpty(primary *string, fallback *string) *string {
	if primary != nil && *primary != "" {
		return primary
	}
	if fallback != nil && *fallback != "" {
		return fallback
	}
	return nil
}

func get(u *models.User, f func(*models.User) *string) *string {
	if u == nil {
		return nil
	}
	return f(u)
}

func oauthUserPicture(oauthUser *models.User) *string {
	if oauthUser == nil || *oauthUser.ProfilePicture == "" {
		return nil
	}
	return oauthUser.ProfilePicture
}

func oauthUserProvider(oauthUser *models.User) string {
	if oauthUser == nil {
		return ""
	}
	return oauthUser.Provider
}

// Logout invalidates a user's refresh token so they cannot refresh their session.
func (uc *AuthUsecase) Logout(ctx context.Context, userID string,token string) error {
	if userID == "" {
		return domain.ErrInvalidInput
	}

	// Revoke/delete the token instead of touching the user record
	err := uc.AuthRepo.FindAndInvalidate(ctx, userID, token)
	if err != nil {
		return domain.ErrDatabaseOperationFailed
	}

	return nil
}


func (uc *AuthUsecase) RefreshToken(ctx context.Context, incomingToken string) (*string, time.Duration, error) {
    emptyToken := ""

    if incomingToken == "" {
        return &emptyToken, 0, fmt.Errorf("%w", domain.ErrInvalidInput)
    }

    // Find the refresh token in DB
    storedToken, err := uc.AuthRepo.FindRefreshToken(ctx, incomingToken)
    if err != nil {
        return &emptyToken, 0, domain.ErrTokenVerificationFailed
    }

    // Check if revoked or expired
    if storedToken.IsRevoked || storedToken.ExpiresAt.Before(time.Now()) {
        return &emptyToken, 0, domain.ErrTokenVerificationFailed
    }

    // Fetch user
	user, err := uc.AuthRepo.FindByID(ctx, storedToken.UserID)
    if err != nil {
        return &emptyToken, 0, domain.ErrDatabaseOperationFailed
    }

    lang := "en"
    if user.PreferredLanguage != nil {
        lang = string(*user.PreferredLanguage)
    }

    // Generate new access token
    newAccessToken, expiryTime, err := uc.JWTService.GenerateAccessToken(user.UserID, lang)
    if err != nil {
        return &emptyToken, 0, domain.ErrTokenGenerationFailed
    }

    // Optionally, rotate refresh token
    newRefreshToken, err := uc.JWTService.GenerateRefreshToken(user.UserID)
    if err != nil {
        return &emptyToken, 0, domain.ErrTokenGenerationFailed
    }

    // Save the new refresh token and revoke the old one
    err = uc.AuthRepo.SaveRefreshToken(ctx, user.UserID, newRefreshToken)
    if err != nil {
        return &emptyToken, 0, domain.ErrDatabaseOperationFailed
    }

    // Revoke the old refresh token
    err = uc.AuthRepo.FindAndInvalidate(ctx, user.UserID, incomingToken)
    if err != nil {
        return &emptyToken, 0, domain.ErrDatabaseOperationFailed
    }

    return &newAccessToken, expiryTime, nil
}


// function to validate password strength

func validatePasswordStrength(password string) bool {
	if len(password) < 8 {
		return false
	}

	hasLetter := false
	hasNumber := false

	for _, c := range password {
		switch {
		case unicode.IsLetter(c):
			hasLetter = true
		case unicode.IsNumber(c):
			hasNumber = true
		}
	}

	return hasLetter && hasNumber
}
// ResetPassword resets user password after OTP verification
func (uc *AuthUsecase) ResetPassword(ctx context.Context, email, otp, newPassword string) error {
	// Get latest password reset OTP (same pattern as registration)
	code, err := uc.OTPRepo.GetLatestPasswordResetCodeByEmail(ctx, email)
	if err != nil {
		return errors.New("failed to get verification code")
	}
	if code == nil {
		return errors.New("no valid verification code found")
	}

	// Check if OTP is expired or used (same pattern as registration)
	if code.Used || time.Now().After(code.ExpiresAt) {
		return errors.New("verification code expired or already used")
	}

	// Verify OTP (same pattern as registration)
	if err := bcrypt.CompareHashAndPassword([]byte(code.CodeHash), []byte(otp)); err != nil {
		return errors.New("invalid verification code")
	}

	// Mark OTP as used (same pattern as registration)
	if err := uc.OTPRepo.MarkCodeAsUsed(ctx, code.ID); err != nil {
		return errors.New("failed to mark code as used")
	}

	// Validate new password strength
	if !validatePasswordStrength(newPassword) {
		return fmt.Errorf("%w", domain.ErrWeakPassword)
	}

	// Hash new password
	hashedPassword, err := uc.PasswordService.HashPassword(newPassword)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}

	// Update user password
	if err := uc.AuthRepo.UpdatePasswordByEmail(ctx, email, hashedPassword); err != nil {
		return fmt.Errorf("failed to update password: %w", err)
	}

	return nil
}
