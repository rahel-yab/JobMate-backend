package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/tsigemariamzewdu/JobMate-backend/delivery/controllers"
	"github.com/tsigemariamzewdu/JobMate-backend/delivery/routes"
	groqpkg "github.com/tsigemariamzewdu/JobMate-backend/infrastructure/ai"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/ai_service"
	authinfra "github.com/tsigemariamzewdu/JobMate-backend/infrastructure/auth"
	config "github.com/tsigemariamzewdu/JobMate-backend/infrastructure/config"
	emailinfra "github.com/tsigemariamzewdu/JobMate-backend/infrastructure/email"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/job_service"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/middlewares"

	mongoclient "github.com/tsigemariamzewdu/JobMate-backend/infrastructure/db/mongo"
	// utils "github.com/tsigemariamzewdu/JobMate-backend/infrastructure/util"
	file_parser "github.com/tsigemariamzewdu/JobMate-backend/infrastructure/file_parser"
	"github.com/tsigemariamzewdu/JobMate-backend/repositories"
	"github.com/tsigemariamzewdu/JobMate-backend/usecases"
)

func main() {
	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Connect to MongoDB
	client := mongoclient.NewMongoClient()
	db := client.Database(cfg.DBName)
	defer func() {
		if err := client.Disconnect(context.Background()); err != nil {
			log.Printf("Error disconnecting MongoDB client: %v", err)
		}
	}()

	// Initialize repositories
	otpRepo := repositories.NewOTPRepository(db)
	authRepo := repositories.NewAuthRepository(db)
	userRepo := repositories.NewUserRepository(db)
	cvRepo := repositories.NewCVRepository(db)
	feedbackRepo := repositories.NewFeedbackRepository(db)
	skillGapRepo := repositories.NewSkillGapRepository(db)
	cvChatRepo := repositories.NewCVChatRepository(db)
	interviewFreeformRepo := repositories.NewInterviewFreeformRepository(db)
	interviewStructuredRepo := repositories.NewInterviewStructuredRepository(db)
	jobChatRepo := repositories.NewJobChatRepository(db)
	// use the name conversationRepo because feature branch used it
	//conversationRepo := repositories.NewConversationRepository(db)

	providersConfigs, err := config.BuildProviderConfigs()
	if err != nil {
		log.Fatal("error: ", err)
	}

	// Initialize services
	phoneValidator := &authinfra.PhoneValidatorImpl{}
	emailService := emailinfra.NewSMTPService(cfg.SMTPHost, cfg.SMTPPort, cfg.SMTPUsername, cfg.SMTPPassword, cfg.EmailFrom)

	otpSender, err := authinfra.NewOTPSenderFromEnv(cfg)
	if err != nil {
		log.Fatalf("Failed to initialize OTP sender: %v", err)
	}
	otpSenderTyped := otpSender
	jwtService := authinfra.NewJWTService(cfg.JWTSecretKey, fmt.Sprint(cfg.JWTExpirationMinutes))
	passwordService := authinfra.NewPasswordService()
	authMiddleware := authinfra.NewAuthMiddleware(jwtService)
	oauthService, err := authinfra.NewOAuth2Service(providersConfigs)
	aiService := ai_service.NewGeminiAISuggestionService("gemini-1.5-flash", cfg.AIApiKey)

	textExtractor := file_parser.NewFileTextExtractor()

	if err != nil {
		log.Fatalf("Failed to initialize OAuth2 service: %v", err)
	}


	// Initialize AI client (avoid alias/variable collision)
	geminiClient:=groqpkg.NewGeminiService(cfg)

	groqClient := groqpkg.NewGroqClient(cfg)
	// groqService:=groqpkg.NewGroqServiceAdapter(groqClient)
	

	// Initialize use cases
	otpUsecase := usecases.NewOTPUsecase(otpRepo, phoneValidator, otpSenderTyped, emailService)
	authUsecase := usecases.NewAuthUsecase(authRepo, passwordService, jwtService, cfg.BaseURL, otpRepo, time.Second*10, emailService)
	userUsecase := usecases.NewUserUsecase(userRepo, time.Second*10)
	cvUsecase := usecases.NewCVUsecase(cvRepo, feedbackRepo, skillGapRepo, aiService, textExtractor, time.Second*15)
	//chatUsecase := usecases.NewChatUsecase(conversationRepo, groqClient, cfg)


	// Initialize AI service adapter for interview and CV chat usecases
	
	cvChatUsecase := usecases.NewCVChatUsecase(cvChatRepo, cvUsecase, geminiClient)


	interviewFreeformUsecase := usecases.NewInterviewFreeformUsecase(interviewFreeformRepo, geminiClient)
	interviewStructuredUsecase := usecases.NewInterviewStructuredUsecase(interviewStructuredRepo, authRepo, geminiClient)


	// Job Matching feature
	jobRepo := job_service.NewJobService(cfg.JobDataApiKey)
	jobUsecase := usecases.NewJobUsecase(jobRepo, jobChatRepo, geminiClient)

	// Initialize controllers
	otpController := controllers.NewOtpController(otpUsecase)
	authController := controllers.NewAuthController(authUsecase)
	userController := controllers.NewUserController(userUsecase)
	oauthController := controllers.NewOAuth2Controller(oauthService, authUsecase)
	cvController := controllers.NewCVController(cvUsecase)
	//chatController := controllers.NewChatController(chatUsecase)
	cvChatController := controllers.NewCVChatController(cvChatUsecase)
	interviewFreeformController := controllers.NewInterviewFreeformController(interviewFreeformUsecase)
	interviewStructuredController := controllers.NewInterviewStructuredController(interviewStructuredUsecase)
	jobController := controllers.NewJobController(jobUsecase, jobChatRepo, groqClient)

	// Setup router (add all controllers)
	router := routes.SetupRouter(
		authMiddleware,
		userController,
		authController,
		otpController,
		oauthController,
		cvController,
		cvChatController,
		interviewFreeformController,
		interviewStructuredController,
		jobController,
	)

	router.Use(middlewares.SetupCORS(cfg.AllowedOrigins))
	router.Use(middlewares.SecurityHeaders())

	port := cfg.Port
	if port == "" {
		log.Fatal("PORT environment variable not set.")
	}

	log.Printf("Server starting on port %s...", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}