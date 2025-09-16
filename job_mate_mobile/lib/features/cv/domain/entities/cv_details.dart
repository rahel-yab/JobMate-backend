import 'package:equatable/equatable.dart';

class CvDetails extends Equatable{
  final String cvId;
  final String userId;
  final String? fileName;
  final DateTime createdAt;

  const CvDetails({
    required this.cvId,
    required this.userId,
    this.fileName,
    required this.createdAt
  });
  
  @override
  
  List<Object?> get props => [cvId,userId,fileName,createdAt];

}