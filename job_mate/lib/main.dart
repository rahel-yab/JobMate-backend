// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job_mate/core/presentation/router.dart';
import 'package:job_mate/dependency_injection.dart' as di;
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv/cv_bloc.dart';

import 'package:job_mate/features/cv/presentation/bloc/cv_chat/cv_chat_bloc.dart';

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
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent())), // Check auth on startup
        BlocProvider(create: (_) => di.sl<CvBloc>()),
        BlocProvider(create: (_) => di.sl<CvChatBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'JobMate',
        routerConfig: router,
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