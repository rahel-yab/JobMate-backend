import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job_mate/features/job_search/presentation/bloc/job_search_bloc.dart';
import 'package:job_mate/features/job_search/presentation/bloc/job_search_event.dart';
import 'package:job_mate/features/job_search/presentation/bloc/job_search_state.dart';
import 'package:job_mate/features/job_search/domain/entities/chat.dart';
import 'package:job_mate/features/job_search/domain/entities/job_chat_message.dart';

class JobChatPage extends StatefulWidget {
  const JobChatPage({super.key});

  @override
  State<JobChatPage> createState() => _JobChatPageState();
}

class _JobChatPageState extends State<JobChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? currentChatId;
  bool isSendingMessage = false;
  bool isWaitingForResponse = false;
  List<JobChatMessage> chatMessages = [];

  @override
  void initState() {
    super.initState();
    context.read<JobChatBloc>().add(GetAllChatsEvent());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || isSendingMessage) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      isSendingMessage = true;
      isWaitingForResponse = true;
      // Add user message immediately
      chatMessages.add(JobChatMessage(
        role: 'user',
        content: message,
        timeStamp: DateTime.now(),
      ));
    });

    _scrollToBottom();

    // Send message to bloc
    context.read<JobChatBloc>().add(
          SendChatMessageEvent(
            message: message,
            chatId: currentChatId,
          ),
        );
  }

  Widget _buildMessageBubble(JobChatMessage message) {
    final isUser = message.role == 'user';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF238471),
              child: Icon(Icons.work, color: Colors.white, size: 16),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF238471) : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList(List<dynamic> jobs) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Jobs',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF144A3F),
            ),
          ),
          const SizedBox(height: 12),
          ...jobs.map((job) => _buildJobItem(job)).toList(),
        ],
      ),
    );
  }

  Widget _buildJobItem(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job['Title'] ?? 'No Title',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Company: ${job['Company'] ?? 'Unknown'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Location: ${job['Location'] ?? 'Not specified'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (job['Link'] != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Handle job link tap
              },
              child: Text(
                'View Job →',
                style: TextStyle(
                  color: const Color(0xFF238471),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF238471),
            child: Icon(Icons.work, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to parse job results from message content
  // This assumes the AI response might contain job data in a structured format
  // You might need to adjust this based on your actual API response format
  List<dynamic>? _parseJobResults(JobChatMessage message) {
    try {
      // If the message content is JSON containing job data
      final jsonData = json.decode(message.content);
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('jobs')) {
        return jsonData['jobs'] as List<dynamic>;
      }
    } catch (e) {
      // If it's not JSON, check if it's a regular message
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobChatBloc, JobChatState>(
      listener: (context, state) {
        if (state is JobChatLoaded) {
          setState(() {
            isSendingMessage = false;
            isWaitingForResponse = false;
            
            if (state.selectedChat != null) {
              currentChatId = state.selectedChat!.id;
              // Update chat messages from the selected chat
              chatMessages = state.selectedChat!.messages;
            }
          });
          _scrollToBottom();
        } else if (state is JobChatError) {
          setState(() {
            isSendingMessage = false;
            isWaitingForResponse = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is JobChatLoading) {
          setState(() {
            isWaitingForResponse = true;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Job Search Assistant'),
          backgroundColor: const Color(0xFF144A3F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: chatMessages.length + (isWaitingForResponse ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < chatMessages.length) {
                    final message = chatMessages[index];
                    
                    // Check if this message contains job results
                    final jobResults = _parseJobResults(message);
                    
                    if (jobResults != null && jobResults.isNotEmpty) {
                      return _buildJobList(jobResults);
                    }
                    
                    return _buildMessageBubble(message);
                  } else {
                    return _buildTypingIndicator();
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF238471),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}