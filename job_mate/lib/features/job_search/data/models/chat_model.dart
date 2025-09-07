import 'package:job_mate/features/cv/domain/entities/chat_message.dart';
import 'package:job_mate/features/job_search/domain/entities/chat.dart';
import 'package:job_mate/features/job_search/domain/entities/job.dart';
import 'package:job_mate/features/job_search/domain/entities/job_chat_message.dart';
import 'job_model.dart';

class ChatModel extends Chat {
  ChatModel({
    required String id,
    required String userId,
    required List<JobChatMessage> messages,
    
    required Map<String, dynamic> jobSearchQuery,
    required List<Job> jobResults,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          userId: userId,
          messages: messages,
          jobSearchQuery: jobSearchQuery,
          jobResults: jobResults,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      userId: json['user_id'],
      messages: (json['messages'] as List)
          .map((m) => JobChatMessage(
                id: m['id'],
                role: m['role'],
                content: m['message'],
                timeStamp: DateTime.parse(m['timestamp']),
              ))
          .toList(),
      jobSearchQuery: Map<String, dynamic>.from(json['job_search_query']),
      jobResults: (json['job_results'] as List?)
              ?.map((j) => JobModel.fromJson(j))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'messages': messages.map((m) => {
      'role': m.role,
      'message': m.content,
      'timestamp': m.timeStamp.toIso8601String(),
    }).toList(),
    'job_search_query': jobSearchQuery,
    'job_results': jobResults.map((j) => (j as JobModel).toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}