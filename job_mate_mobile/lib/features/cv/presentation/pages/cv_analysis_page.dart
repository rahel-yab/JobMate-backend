import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:job_mate/core/presentation/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source_impl.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';
import 'package:job_mate/features/cv/domain/entities/chat_session.dart';
import 'package:job_mate/features/cv/domain/entities/chat_message.dart';
import 'package:job_mate/features/cv/domain/entities/suggestion.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv/cv_bloc.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv/cv_event.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv/cv_state.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_chat/cv_chat_bloc.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_chat/cv_chat_event.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_chat/cv_chat_state.dart';
import 'package:job_mate/features/cv/presentation/widgets/chat_header.dart';
import 'package:job_mate/features/cv/presentation/widgets/cv_input_widget.dart';
import 'package:job_mate/features/cv/presentation/widgets/file_upload_widget.dart';
import 'package:job_mate/features/cv/presentation/widgets/message_input.dart';
import 'package:job_mate/features/cv/presentation/widgets/suggestion_card.dart';
import 'package:job_mate/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CvAnalysisPage extends StatefulWidget {
  const CvAnalysisPage({super.key});

  @override
  State<CvAnalysisPage> createState() => _CvAnalysisPageState();
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedDot(animation: _animation, delay: 0),
          const SizedBox(width: 4),
          _AnimatedDot(animation: _animation, delay: 200),
          const SizedBox(width: 4),
          _AnimatedDot(animation: _animation, delay: 400),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final Animation<double> animation;
  final int delay;

  const _AnimatedDot({required this.animation, required this.delay});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Interval(
            delay / 1500,
            (delay + 500) / 1500,
            curve: Curves.easeInOut,
          ),
        ),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF005148),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CvAnalysisPageState extends State<CvAnalysisPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isTextMode = true;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? uploadedFilePath;
  String? userId;
  bool isLoadingUserId = true;
  bool isSendingMessage = false;
  bool showUploadBox = true;
  String? currentChatId;
  String? currentCvId;
  List<ChatSession> chatSessions = [];
  List<ChatMessage> chatMessages = [];
  Suggestion? suggestions;
  CvFeedback? currentFeedback;
  bool isAnalyzing = false;
  bool showAnalysisComplete = false;
  bool isWaitingForChatResponse = false;
  bool isWaitingForSuggestions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserId();
      context.read<CvChatBloc>().add(GetAllCvChatSessionsEvent());
      _scrollToBottom();
    });
    _textController.addListener(() {
      setState(() {});
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadUserId() async {
    setState(() => isLoadingUserId = true);
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is UserModel) {
      userId = (authState.data as UserModel).userId;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final localDataSource = ProfileLocalDataSourceImpl(preferences: prefs);
      final profile = await localDataSource.getProfile();
      userId = profile?.userId;
    }
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Please log in.')),
      );
    }
    setState(() => isLoadingUserId = false);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => uploadedFilePath = result.files.single.path!);
    }
  }

  void _onBottomItemTapped(int index) {
    if (index != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This section is coming soon'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _toggleUploadBox() {
    setState(() {
      showUploadBox = !showUploadBox;
      if (showUploadBox) {
        showAnalysisComplete = false;
        currentFeedback = null;
        chatMessages.clear();
        isWaitingForChatResponse = false;
        isWaitingForSuggestions = false;
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && currentChatId != null) {
      setState(() {
        isSendingMessage = true;
        isWaitingForChatResponse = true;
        // Add user message immediately
        chatMessages.add(ChatMessage(
          id: 'user-${DateTime.now().millisecondsSinceEpoch}',
          role: 'user',
          content: message,
          timeStamp: DateTime.now(),
        ));
      });
      _messageController.clear();
      _scrollToBottom();
      
      context.read<CvChatBloc>().add(SendCvChatMessageEvent(
        chatId: currentChatId!,
        message: message,
        cvId: currentCvId,
      ));
    }
  }

  void _selectChat(ChatSession chat) {
    setState(() {
      currentChatId = chat.chatId;
      currentCvId = chat.cvId;
      // Use the messages from the chat session if available
      chatMessages = chat.messages.isNotEmpty ? chat.messages : [];
      showUploadBox = false;
      showAnalysisComplete = true;
      isAnalyzing = false;
      isWaitingForChatResponse = false;
      isWaitingForSuggestions = false;
    });
    
    // Always fetch the latest history from the server
    context.read<CvChatBloc>().add(GetCvChatHistoryEvent(chat.chatId));
  }

  // FIXED: Updated _openChatHistory method to use GlobalKey
  void _openChatHistory() {
    _scaffoldKey.currentState?.openDrawer();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // -----------------------
  // UI HELPERS
  // -----------------------

  Widget _buildUploadBox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 44),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.description, color: Color(0xFF005148)),
                    SizedBox(width: 8),
                    Text("CV Analysis",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),

                // Mode toggle
                Row(
                  children: [
                    _modeButton("Type/Paste", isTextMode, () {
                      setState(() => isTextMode = true);
                    }),
                    const SizedBox(width: 10),
                    _modeButton("Upload File", !isTextMode, () {
                      setState(() => isTextMode = false);
                    }),
                  ],
                ),

                const SizedBox(height: 16),

                isTextMode
                    ? CvInputWidget(controller: _textController)
                    : FileUploadWidget(
                        filePath: uploadedFilePath,
                        onPickFile: _pickFile,
                      ),

                const SizedBox(height: 16),

                _analyzeButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  String _formatTimeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
  
  return _formatDate(date);
}

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF144A3F),
              child: Text('JM', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF238471) : const Color(0xFFEAF6F4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timeStamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _feedbackBubble(CvFeedback feedback) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF144A3F),
            child: Text('JM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📄 CV Analysis",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF005148),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _section("Summary", feedback.summary),
                  _section("✅ Strengths", feedback.strengths),
                  _section("⚠️ Weaknesses", feedback.weaknesses),
                  _section("💡 Improvements", feedback.improvementSuggestions),
                  if (feedback.extractedSkills.isNotEmpty)
                    _listSection("Extracted Skills", feedback.extractedSkills),
                  if (feedback.extractedExperience.isNotEmpty)
                    _listSection("Experience", feedback.extractedExperience),
                  if (feedback.extractedEducation.isNotEmpty)
                    _listSection("Education", feedback.extractedEducation),
                  if (feedback.skillGaps != null && feedback.skillGaps!.isNotEmpty)
                    _skillGapsSection(feedback.skillGaps!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingBubble() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF144A3F),
            child: Text('JM', style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
          SizedBox(width: 8),
          TypingIndicator(),
        ],
      ),
    );
  }

  Widget _section(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF005148),
              )),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }

  Widget _listSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF005148),
              )),
          const SizedBox(height: 4),
          ...items.map((e) => Text("• $e")),
        ],
      ),
    );
  }

  Widget _skillGapsSection(List<SkillGap> skillGaps) {
    final validGaps = skillGaps.where((gap) {
      return (gap.skillName != null && gap.skillName!.isNotEmpty) ||
          (gap.importance != null && gap.importance!.isNotEmpty) ||
          (gap.improvementSuggestions != null && gap.improvementSuggestions!.isNotEmpty);
    }).toList();

    if (validGaps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Skill Gaps",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF005148),
            ),
          ),
          const SizedBox(height: 4),
          ...validGaps.map((gap) {
            final lines = <String>[];
            if (gap.skillName != null && gap.skillName!.isNotEmpty) {
              String levelInfo = '';
              if (gap.currentLevel != null) {
                levelInfo += 'Current: ${gap.currentLevel}';
              }
              if (gap.recommendedLevel != null) {
                if (levelInfo.isNotEmpty) levelInfo += ', ';
                levelInfo += 'Recommended: ${gap.recommendedLevel}';
              }
              lines.add("• ${gap.skillName}${levelInfo.isNotEmpty ? ' ($levelInfo)' : ''}");
            }
            if (gap.importance != null && gap.importance!.isNotEmpty) {
              lines.add("   Importance: ${gap.importance}");
            }
            if (gap.improvementSuggestions != null && gap.improvementSuggestions!.isNotEmpty) {
              lines.add("   Suggestions: ${gap.improvementSuggestions}");
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines.map((e) => Text(e)).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _analyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF238471),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: (userId == null ||
                isLoadingUserId ||
                (isTextMode && _textController.text.trim().isEmpty) ||
                (!isTextMode && uploadedFilePath == null))
            ? null
            : () {
                if (isTextMode) {
                  context.read<CvBloc>().add(
                        UploadCvEvent(
                          userId: userId!,
                          rawText: _textController.text.trim(),
                        ),
                      );
                } else if (uploadedFilePath != null) {
                  context.read<CvBloc>().add(
                        UploadCvEvent(
                          userId: userId!,
                          filePath: uploadedFilePath!,
                        ),
                      );
                }
              },
        child: const Text("Analyze My CV", style: TextStyle(fontSize: 16)),
      ));
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF144A3F) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(color: active ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: _onBottomItemTapped,
      selectedItemColor: const Color(0xFF0A8C6D),
      unselectedItemColor: Colors.black,
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
  void _navigateToHome() {
    // Navigate back to home using GoRouter
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CvChatBloc, CvChatState>(
      listener: (context, state) {
        if (state is CvChatSessionsLoaded) {
          setState(() => chatSessions = state.sessions);
        } else if (state is CvChatHistoryLoaded) {
          setState(() {
            chatMessages = state.history.messages;
            isWaitingForChatResponse = false;
          });
          _scrollToBottom();
        } else if (state is CvChatMessageSent) {
          setState(() {
            isSendingMessage = false;
            isWaitingForChatResponse = false;
            // Add the AI response to the chat
            chatMessages.add(state.message);
          });
          _scrollToBottom();
          
          // Get suggestions after chat response
          context.read<CvBloc>().add(GetSuggestionsEvent());
        } else if (state is CvChatSessionCreated) {
          setState(() {
            currentChatId = state.chatId;
            isWaitingForSuggestions = true;
          });
          context.read<CvChatBloc>().add(GetAllCvChatSessionsEvent());
          context.read<CvChatBloc>().add(GetCvChatHistoryEvent(state.chatId));
        } else if (state is CvChatError) {
          setState(() {
            isSendingMessage = false;
            isWaitingForChatResponse = false;
            isWaitingForSuggestions = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is CvChatLoading) {
          setState(() {
            isWaitingForChatResponse = true;
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey, // ADDED: Scaffold key for drawer access
        backgroundColor: Colors.white,
        appBar: ChatHeader(
          // onBack: () => Navigator.pop(context),
          
          onBack: _navigateToHome,
          onToggleLanguage: () {},
          onShowHistory: _openChatHistory, // CHANGED: Removed context parameter
        ),
        drawer: Drawer(
  width: MediaQuery.of(context).size.width * 0.85,
  elevation: 16,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
  ),
  child: Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
    ),
    child: Column(
      children: [
        // Header with gradient
        Container(
          height: 140,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF144A3F),
                Color(0xFF238471),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'CV Chat History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${chatSessions.length} conversation${chatSessions.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        

        // Chat list
        Expanded(
          child: chatSessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No conversations yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start analyzing your CV to begin',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  itemCount: chatSessions.length,
                  itemBuilder: (context, index) {
                    final chat = chatSessions[index];
                    final messageCount = chat.messages.length;
                    final lastMessage = messageCount > 0 
                        ? chat.messages.last.content 
                        : 'Start a conversation';
                    final lastMessageTime = messageCount > 0 
                        ? chat.messages.last.timeStamp 
                        : chat.updatedAt;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _selectChat(chat);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: currentChatId == chat.chatId 
                                  ? const Color(0xFFEAF6F4)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: currentChatId == chat.chatId
                                  ? Border.all(color: const Color(0xFF238471), width: 1.5)
                                  : Border.all(color: Colors.grey.shade200, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar with message count
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF144A3F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Chat details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header with date and message count
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Chat ${index + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF144A3F),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.chat_bubble_outline,
                                                size: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$messageCount',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // Last message preview
                                      Text(
                                        lastMessage,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Timestamp
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 10,
                                            color: Colors.grey.shade500,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatTimeAgo(lastMessageTime),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Chevron icon
                                const Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${chatSessions.length} chats',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),

        body: BlocConsumer<CvBloc, CvState>(
          listener: (context, state) {
            if (state is CvError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              setState(() {
                isAnalyzing = false;
              });
            }
            if (state is CvUploaded) {
              setState(() {
                isAnalyzing = true;
                currentCvId = state.details.cvId;
              });
              context.read<CvBloc>().add(AnalyzeCvEvent(state.details.cvId));
            }
            if (state is CvAnalyzed) {
              setState(() {
                isAnalyzing = false;
                showUploadBox = false;
                showAnalysisComplete = true;
                currentFeedback = state.feedback;
              });
              
              if (currentCvId != null) {
                context.read<CvChatBloc>().add(
                      CreateCvChatSessionEvent(currentCvId!),
                    );
              }
            }
            if (state is CvSuggestionsLoaded) {
              setState(() {
                suggestions = state.suggestions;
                isWaitingForSuggestions = false;
              });
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showUploadBox) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF144A3F),
                                child: Text('JM',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF6F4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'I would be happy to help you with your CV.\n'
                                    'You can upload your current CV or describe your background below.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (showUploadBox) _buildUploadBox(),

                        if (isAnalyzing) _typingBubble(),

                        if (currentFeedback != null) _feedbackBubble(currentFeedback!),

                        if (showAnalysisComplete) ...[
                          // Display all chat messages
                          ...chatMessages.map((m) => _buildMessageBubble(m)),
                          
                          // Show typing indicator when waiting for AI response
                          if (isWaitingForChatResponse) 
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Color(0xFF144A3F),
                                    child: Text('JM', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ),
                                  SizedBox(width: 8),
                                  TypingIndicator(),
                                ],
                              ),
                            ),
                          
                          // Show typing indicator when waiting for suggestions
                          if (isWaitingForSuggestions) 
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Color(0xFF144A3F),
                                    child: Text('JM', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ),
                                  SizedBox(width: 8),
                                  TypingIndicator(),
                                ],
                              ),
                            ),
                          
                          // Show suggestions after they load
                          if (suggestions != null)
                            SuggestionCard(
                              suggestion: suggestions!,
                              onTap: (s) => _messageController.text = s,
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (showAnalysisComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MessageInput(
                          controller: _messageController,
                          onSend: _sendMessage,
                          isLoading: isSendingMessage,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _toggleUploadBox,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Reanalyze CV",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: _bottomNavBar(),
      ),
    );
  }
}