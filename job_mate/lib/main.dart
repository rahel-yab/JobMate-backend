import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job_mate/core/presentation/router.dart';
import 'package:job_mate/dependency_injection.dart' as di;
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';



void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_)=> di.sl<AuthBloc>())], 
      child: MaterialApp.router(
        title: 'JobMate',
        routerConfig: router,
    ));
    
  }
}



