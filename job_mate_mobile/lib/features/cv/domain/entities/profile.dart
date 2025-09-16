import 'package:equatable/equatable.dart';

class Profile extends Equatable{
  final String? cvId;
  final String userId;
  final String originalText;
  final String language;

  const Profile({
    this.cvId,
    required this.userId,
    required this.originalText,
    this.language='en',
  });

  Profile copywith({String? cvId}){
    return Profile(
      cvId: cvId??this.cvId,
      userId: userId, 
      originalText: originalText,
      language: language);
  }
  
  @override
  
  List<Object?> get props => [cvId,userId,originalText,language];

}