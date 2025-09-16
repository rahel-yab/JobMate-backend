import 'dart:convert';

import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source.dart';
import 'package:job_mate/features/cv/domain/entities/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileLocalDataSourceImpl extends ProfileLocalDataSource{
  final SharedPreferences preferences;
  // ProfileLocalDataSourceImpl(this.preferences);
  ProfileLocalDataSourceImpl({required this.preferences});
  static const String _profileKey='current_profile';

  @override
  Future<void> clearProfile()async {
    final prefs=await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  
  }

  @override
  Future<Profile?> getProfile() async{
    final prefs= await SharedPreferences.getInstance();
    final profileJson= prefs.getString(_profileKey);
    if (profileJson==null) return null;
    final map=jsonDecode(profileJson) as Map<String,dynamic>;
    return Profile(
      cvId: map['cvId'] as String?,
      userId: map['userId'] as String,
      originalText: map['originalText'] as String,
      language: map['language'] as String,
      );

  }

  @override
  Future<void> saveProfile(Profile profile)async {
    final prefs= await SharedPreferences.getInstance();
    final profileJson={
      'cvId':profile.cvId,
      'userId':profile.userId,
      'originalText':profile.originalText,
      'language':profile.language
    };
    await prefs.setString(_profileKey, jsonEncode(profileJson));

  }
}