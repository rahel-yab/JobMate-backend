import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable{
  final String? id;
  final String role;
  final String content;
  final DateTime timeStamp;

  const ChatMessage({
    this.id,
    required this.role,
    required this.content,
    required this.timeStamp,
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [id,role,content,timeStamp];
  

  
}