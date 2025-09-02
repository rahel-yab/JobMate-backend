import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/cv/data/datasources/local/profile_local_data_source_impl.dart';
import 'features/cv/data/datasources/remote/cv_remote_data_source_impl.dart';
import 'features/cv/data/repositories/cv_repository_impl.dart';
import 'features/cv/domain/usecases/analyze_cv.dart';
import 'features/cv/domain/usecases/upload_cv.dart';
import 'features/cv/presentation/bloc/cv_bloc.dart';
import 'features/cv/presentation/pages/cv_analysis_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final local = ProfileLocalDataSourceImpl(prefs);
  final remote = CvRemoteDataSourceImpl();

  final repository = CvRepositoryImpl(remote: remote, local: local);

  final uploadCv = UploadCv(repository);
  final analyzeCv = AnalyzeCv(repository);

  runApp(MyApp(uploadCv: uploadCv, analyzeCv: analyzeCv));
}

class MyApp extends StatelessWidget {
  final UploadCv uploadCv;
  final AnalyzeCv analyzeCv;

  const MyApp({super.key, required this.uploadCv, required this.analyzeCv});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CvBloc(uploadCv: uploadCv, analyzeCv: analyzeCv),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JobMate',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const CvAnalysisPage(),
      ),
    );
  }
}
