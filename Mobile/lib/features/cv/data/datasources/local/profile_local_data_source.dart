import 'package:job_mate/features/cv/domain/entities/profile.dart';

abstract class ProfileLocalDataSource {
  Future<void> saveProfile(Profile profile);
  Future<Profile?> getProfile();
  Future<void> clearProfile();
}