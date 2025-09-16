import 'package:equatable/equatable.dart';

class JobChatMessage extends Equatable {
  final String? id;
  final String role;
  final String content;
  final DateTime timeStamp;

  const JobChatMessage({
    this.id,
    required this.role,
    required this.content,
    required this.timeStamp,
  });
  
  @override
  List<Object?> get props => [id, role, content, timeStamp];
}