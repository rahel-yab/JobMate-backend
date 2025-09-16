import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job_mate/features/job_search/presentation/bloc/job_search_bloc.dart';
import 'package:job_mate/features/job_search/presentation/bloc/job_search_event.dart';
import 'package:job_mate/features/job_search/presentation/bloc/job_search_state.dart';
import 'package:job_mate/features/job_search/domain/entities/chat.dart';
import 'package:job_mate/features/job_search/domain/entities/job_chat_message.dart';
import 'package:go_router/go_router.dart';
import 'package:job_mate/core/presentation/routes.dart';

class JobChatPage extends StatefulWidget {
  const JobChatPage({super.key});

  @override
  State<JobChatPage> createState() => _JobChatPageState();
}

class _JobChatPageState extends State<JobChatPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  String? currentChatId;
  bool isSendingMessage = false;
  bool isWaitingForResponse = false;
  List<JobChatMessage> chatMessages = [];
  int _currentBottomNavIndex = 1; // Jobs is at index 1

  // Animation controller for typing indicator
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    context.read<JobChatBloc>().add(GetAllChatsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Initialize typing animation
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
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
    if (isSendingMessage) return;

    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    _messageController.clear();

    setState(() {
      isSendingMessage = true;
      isWaitingForResponse = true;
      // Add user message immediately
      chatMessages.add(JobChatMessage(
        role: 'user',
        content: userMessage,
        timeStamp: DateTime.now(),
      ));
    });

    _scrollToBottom();

    // Send the user's natural language message directly
    context.read<JobChatBloc>().add(
          SendChatMessageEvent(
            message: userMessage,
            chatId: currentChatId,
          ),
        );
  }

  void _onBottomItemTapped(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });
    // Handle navigation based on index
    // You can implement navigation logic here
  }

  Widget _buildMessageBubble(JobChatMessage message) {
    final isUser = message.role == 'user';
    final time = _formatTime(message.timeStamp);

    // Check if this message contains job results
    final jobResults = _parseJobResults(message);
    if (jobResults != null && jobResults.isNotEmpty) {
      return _buildJobList(jobResults);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF005148),
              radius: 16,
              child: Icon(Icons.work_outline, color: Colors.white, size: 16),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isUser ? const Color(0xFF005148) : const Color(0xFFEAF6F4),
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
                      color:
                          isUser ? Colors.white : const Color(0xFF1A2B3C),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _buildJobList(List<dynamic> jobs) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '💼 Recommended Jobs',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF005148),
              ),
            ),
          ),
          ...jobs.map((job) => _buildJobItem(job)).toList(),
        ],
      ),
    );
  }

  Widget _buildJobItem(Map<String, dynamic> job) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EDF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job['title']?.toString() ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF005148),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (job['Type'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job['Type']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job['company']?.toString() ?? 'Unknown company',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job['location']?.toString() ??
                        'Location not specified',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (job['requirements'] != null &&
                job['requirements'] is List &&
                (job['requirements'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Requirements:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children:
                        (job['requirements'] as List).take(3).map((req) {
                      return Chip(
                        label: Text(
                          req.toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: const Color(0xFFEAF6F4),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ),
            if (job['link'] != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _launchJobUrl(job['link']?.toString());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005148),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _launchJobUrl(String? url) {
    if (url != null && url.isNotEmpty) {
      // TODO: Implement URL launching logic
      // You can use url_launcher package: launchUrl(Uri.parse(url));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening: $url')),
      );
    }
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF005148),
            radius: 16,
            child: Icon(Icons.work_outline,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedDot(0),
                _buildAnimatedDot(1),
                _buildAnimatedDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        final value = _typingAnimationController.value;
        final opacity = 0.3 + 0.7 * ((value + index * 0.2) % 1);
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF005148).withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  List<dynamic>? _parseJobResults(JobChatMessage message) {
    try {
      final jsonData = json.decode(message.content);

      if (jsonData is Map<String, dynamic> &&
          jsonData.containsKey('jobs')) {
        final jobs = jsonData['jobs'];
        if (jobs is List<dynamic>) {
          return jobs;
        }
      }

      if (jsonData is List<dynamic>) {
        return jsonData;
      }
    } catch (e) {
      print('Error parsing job results: $e');
    }
    return null;
  }
   void _navigateToHome() {
    // Navigate back to home using GoRouter
    context.go(Routes.home);
  }


  /// ✅ Fix: return type changed to `PreferredSizeWidget`
  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: const Color(0xFFEAF6F4),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        // onPressed: () => Navigator.pop(context),
        onPressed: _navigateToHome, 
      ),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF005148),
            child: Text("JM", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "JobMate",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "Your AI Career Buddy",
                style: TextStyle(fontSize: 12, color: Color(0xFF1E1E1E)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.black),
          onPressed: () {
            // TODO: Implement chat history functionality
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            onPressed: () {
              // TODO: Implement language toggle functionality
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.language,
                color: Colors.black, size: 20),
            label: const Text(
              "አማ",
              style: TextStyle(color: Colors.black, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentBottomNavIndex,
      onTap: _onBottomItemTapped,
      selectedItemColor: const Color(0xFF005148),
      unselectedItemColor: Colors.grey[600],
      backgroundColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          label: 'CV',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Jobs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Interview',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star_border),
          label: 'Skills',
        ),
      ],
    );
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
              chatMessages = state.selectedChat!.messages;
            }
          });
          _scrollToBottom();
        } else if (state is JobChatResponseReceived) {
          setState(() {
            isSendingMessage = false;
            isWaitingForResponse = false;

            final messageText = state.response['message'] as String? ?? '';
            final jobs = state.response['jobs'] as List<dynamic>?;
            final chatId = state.response['chat_id'] as String?;

            if (chatId != null) {
              currentChatId = chatId;
            }

            if (messageText.isNotEmpty) {
              chatMessages.add(JobChatMessage(
                role: 'assistant',
                content: messageText,
                timeStamp: DateTime.now(),
              ));
            }

            if (jobs != null && jobs.isNotEmpty) {
              chatMessages.add(JobChatMessage(
                role: 'assistant',
                content: json.encode({'jobs': jobs}),
                timeStamp: DateTime.now(),
              ));
            }
          });
          _scrollToBottom();
        } else if (state is JobChatError) {
          setState(() {
            isSendingMessage = false;
            isWaitingForResponse = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is JobChatLoading) {
          setState(() {
            isWaitingForResponse = true;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: _buildHeader(),
        body: Column(
          children: [
            Expanded(
              child: chatMessages.isEmpty && !isWaitingForResponse
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Find Your Dream Job',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF005148),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Just tell me what you\'re looking for! Example: "remote python developer jobs" or "marketing manager positions in new york"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: chatMessages.length +
                          (isWaitingForResponse ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < chatMessages.length) {
                          final message = chatMessages[index];
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
                border:
                    Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      decoration: InputDecoration(
                        hintText:
                            'What kind of job are you looking for?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEAF6F4),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF005148),
                    child: IconButton(
                      icon: isSendingMessage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send,
                              color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _bottomNavBar(),
      ),
    );
  }
}
