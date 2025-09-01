import 'package:go_router/go_router.dart';
import 'package:job_mate/core/presentation/routes.dart';
import 'package:job_mate/features/auth/presentation/pages/splash_screen.dart';

final GoRouter router=GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: Routes.splashScreen,
      builder: (context, state)=> const SplashScreen(),
    ),

  ]);