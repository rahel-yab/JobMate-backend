import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:job_mate/core/presentation/routes.dart';
import 'package:job_mate/dependency_injection.dart' as di;
import 'package:job_mate/features/auth/presentation/pages/home_page.dart';

import 'package:job_mate/features/auth/presentation/pages/splash_screen.dart';
import 'package:job_mate/features/auth/presentation/pages/login_page.dart';
import 'package:job_mate/features/auth/presentation/pages/sign_up_page.dart';
import 'package:job_mate/features/cv/presentation/pages/cv_analysis_page.dart';
import 'package:job_mate/features/interview/presentation/blocs/interview_bloc.dart';
import 'package:job_mate/features/interview/presentation/pages/interview_chat_page.dart';
import 'package:job_mate/features/interview/presentation/pages/interview_selection_page.dart';
import 'package:job_mate/features/interview/presentation/pages/structured_interview_page.dart';
// import 'package:job_mate/features/interview/presentation/pages/interview_chat_page.dart';
import 'package:job_mate/features/job_search/presentation/pages/job_search_page.dart';

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
      builder: (context, state) => const InterviewSelectionPage(),
    ),
    GoRoute(
      path: '/interview',
      builder: (context, state) => const InterviewSelectionPage(),
    ),
    GoRoute(
      path: '/interview/freeform',
      builder: (context, state) => BlocProvider(
        create: (_) => di.sl<InterviewBloc>(),
        child: const FreeformInterviewPage(),
      ),
    ),
    GoRoute(
      path: '/interview/structured',
      builder: (context, state) {
        final field = state.uri.queryParameters['field'] ?? 'Software Engineer';
        return BlocProvider(
          create: (_) => di.sl<InterviewBloc>(),
          child: StructuredInterviewPage(field: field),
        );
      },
    ),
    GoRoute(
      path: Routes.jobSearch,
      builder: (context, state) => const JobChatPage(),
    ),
  ],
);
