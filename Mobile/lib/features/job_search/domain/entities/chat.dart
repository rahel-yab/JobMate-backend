import 'package:equatable/equatable.dart';

import 'package:job_mate/features/job_search/domain/entities/job_chat_message.dart';
import 'job.dart';

class Chat extends Equatable  {
  final String id;
  final String userId;
  // final List<ChatMessage> messages;
  final List<JobChatMessage> messages;
  final Map<String, dynamic> jobSearchQuery;
  final List<Job> jobResults;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chat({
    required this.id,
    required this.userId,
    required this.messages,
    required this.jobSearchQuery,
    required this.jobResults,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [id,userId,messages,jobSearchQuery,jobResults,createdAt,updatedAt];
}