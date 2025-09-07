// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:job_mate/core/presentation/router.dart';
import 'package:job_mate/dependency_injection.dart' as di;
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv/cv_bloc.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_chat/cv_chat_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:job_mate/features/interview/presentation/blocs/interview_bloc.dart';
import 'package:job_mate/features/job_search/presentation/bloc/job_search_bloc.dart';
// import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';
// <<<<<<< HEAD
// import 'package:job_mate/features/cv/presentation/bloc/cv/cv_bloc.dart';

// import 'package:job_mate/features/cv/presentation/bloc/cv_chat/cv_chat_bloc.dart';
// =======
// import 'package:job_mate/features/cv/presentation/bloc/cv_bloc.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// >>>>>>> e551cae63743c136fa1d52fe1108c543baa8a138

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()), // Check auth on startup
        BlocProvider(create: (_) => di.sl<CvBloc>()),
        BlocProvider(create: (_) => di.sl<CvChatBloc>()),
        BlocProvider(create: (_) => di.sl<JobChatBloc>()),
        BlocProvider(create: (_) => di.sl<InterviewBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'JobMate',
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('am'), // Amharic
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF144A3F), // Dark teal
            primary: const Color(0xFF238471),   // Medium teal
            secondary: const Color(0xFF0A8C6D), // Light teal
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F9F8), // Light teal background
          useMaterial3: true,
        ),
      ),
    );
  }
}