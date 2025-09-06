package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/tsigemariamzewdu/JobMate-backend/delivery/controllers"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/auth"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/middlewares"
)

func SetupRouter(authMiddleware *auth.AuthMiddleware,
	uc *controllers.UserController,
	authController *controllers.AuthController,
	otpController *controllers.OtpController,
	oauthController *controllers.OAuth2Controller,
	cvController *controllers.CVController,
	cvChatController *controllers.CVChatController,
	interviewFreeformController *controllers.InterviewFreeformController,
	interviewStructuredController *controllers.InterviewStructuredController,
	jobController *controllers.JobController,
) *gin.Engine {

	router := gin.Default()

	router.Use(middlewares.SetupCORS())
	router.Use(middlewares.SecurityHeaders())


	// register user + auth routes
	registerUserRoutes(router, authMiddleware, uc, authController)

	// add OTP route
	otpRoutes := router.Group("/auth")
	{
		otpRoutes.POST("/request-otp", otpController.RequestOTP)
		otpRoutes.POST("/request-password-reset-otp", otpController.RequestPasswordResetOTP)
	}

	// Auth routes
	authGroup := router.Group("/auth")
	NewAuthRouter(*authController, authMiddleware, *authGroup)

	RegisterOAuthRoutes(router, oauthController)

	//cv routes
	cvGroup := router.Group("/cv")
	NewCVRouter(*cvController, authMiddleware,*cvGroup)

	// CV Chat routes (protected with auth middleware)
	cvChatRoutes := router.Group("/cv/chat", authMiddleware.Middleware())
	{
		cvChatRoutes.POST("/session", cvChatController.CreateSession)
		cvChatRoutes.POST("/:chat_id/message", cvChatController.SendMessage)
		cvChatRoutes.GET("/:chat_id/history", cvChatController.GetChatHistory)
		cvChatRoutes.GET("/user", cvChatController.GetUserChats)
	}

	// Free-form Interview Chat Routes
	freeformRoutes := router.Group("/interview/freeform", authMiddleware.Middleware())
	{
		freeformRoutes.POST("/session", interviewFreeformController.CreateSession)
		freeformRoutes.POST("/:chat_id/message", interviewFreeformController.SendMessage)
		freeformRoutes.GET("/:chat_id/history", interviewFreeformController.GetChatHistory)
		freeformRoutes.GET("/user/chats", interviewFreeformController.GetUserChats)
	}

	// Structured Interview Routes
	structuredRoutes := router.Group("/interview/structured", authMiddleware.Middleware())
	{
		structuredRoutes.POST("/start", interviewStructuredController.StartInterview)
		structuredRoutes.POST("/:chat_id/answer", interviewStructuredController.SubmitAnswer)
		structuredRoutes.GET("/continue/:chat_id", interviewStructuredController.ResumeInterview)
		structuredRoutes.GET("/:chat_id/history", interviewStructuredController.GetChatHistory)
		structuredRoutes.GET("/user/chats", interviewStructuredController.GetUserChats)
	}

	// Job suggestion route
	jobRoutes := router.Group("/jobs")
	{
		jobRoutes.POST("/suggest", jobController.SuggestJobs)
	}

	return router
}

func registerUserRoutes(router *gin.Engine, authMiddleware *auth.AuthMiddleware, uc *controllers.UserController, authController *controllers.AuthController) {
	userRoutes := router.Group("/users", authMiddleware.Middleware())
	{
		userRoutes.GET("/me", uc.GetProfile)
		userRoutes.POST("/me", uc.UpdateProfile)
	}

	// refresh token

}

func NewAuthRouter(authController controllers.AuthController, authMiddleware *auth.AuthMiddleware, group gin.RouterGroup) {

	group.POST("/register", authController.Register)
	group.POST("/login", authController.Login)
	group.POST("/logout", authMiddleware.Middleware(), authController.Logout)
	group.POST("/refresh", authController.RefreshToken)
	group.POST("/reset-password", authController.ResetPassword)
}

func NewCVRouter(cvController controllers.CVController,authMiddleware *auth.AuthMiddleware, group gin.RouterGroup) {
	group.POST("/",authMiddleware.Middleware(), cvController.UploadCV)
	group.POST("/:id/analyze",authMiddleware.Middleware(), cvController.AnalyzeCV)
	group.GET("/suggestions",authMiddleware.Middleware() ,cvController.GenerateSuggestions) 
}

func RegisterOAuthRoutes(
	router *gin.Engine,
	oauthController *controllers.OAuth2Controller,
) {
	oauth := router.Group("/oauth")
	{
		oauth.GET("/:provider/login", oauthController.RedirectToProvider)
		oauth.GET("/:provider/callback", oauthController.HandleCallback)
	}
}
