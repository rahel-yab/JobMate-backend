import 'package:go_router/go_router.dart';
import 'package:job_mate/core/presentation/routes.dart';
import 'package:job_mate/features/auth/presentation/pages/home_page.dart';

import 'package:job_mate/features/auth/presentation/pages/splash_screen.dart';
import 'package:job_mate/features/auth/presentation/pages/login_page.dart';
import 'package:job_mate/features/auth/presentation/pages/sign_up_page.dart';
import 'package:job_mate/features/cv/presentation/pages/cv_analysis_page.dart';
import 'package:job_mate/features/interview/presentation/pages/interview_chat_page.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.splashScreen,
  routes: <RouteBase>[
    GoRoute(
      path: Routes.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(path: Routes.login, builder: (context, state) => const LoginPage()),
    GoRoute(
      path: Routes.register,
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: Routes.cvAnalysis,
      builder: (context, state) => const CvAnalysisPage(),
    ),
    GoRoute(path: Routes.home, builder: (context, state) => const HomePage()),
    GoRoute(
      path: Routes.interviewPrep,
      builder: (context, state) => const InterviewPage(),
    ),
  ],
);
