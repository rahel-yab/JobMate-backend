import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
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

class _CvAnalysisPageState extends State<CvAnalysisPage> {
  bool isTextMode = true;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String? uploadedFilePath;
  String? userId;
  bool isLoadingUserId = true;
  final List<CvFeedback> _feedbackHistory = [];
  bool showUploadBox = true; // Toggle for upload box visibility
  String? currentChatId; // Current chat ID
  List<ChatSession> chatSessions = []; // List of all chat sessions
  List<ChatMessage> chatMessages = []; // Messages for current chat
  Suggestion? suggestions; // Suggestions data

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserId();
      context.read<CvChatBloc>().add(GetAllCvChatSessionsEvent()); // Load all chat sessions
    });
    _textController.addListener(() {
      setState(() {});
    });
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
    setState(() => showUploadBox = !showUploadBox);
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && currentChatId != null) {
      context.read<CvChatBloc>().add(SendCvChatMessageEvent(
            chatId: currentChatId!,
            message: message,
            cvId: null,
          ));
      _messageController.clear();
    }
  }

  void _selectChat(ChatSession chat) {
    setState(() {
      currentChatId = chat.chatId;
      chatMessages = chat.messages ?? [];
    });
    context.read<CvChatBloc>().add(GetCvChatHistoryEvent(chat.chatId));
  }

  void _openChatHistory(BuildContext context) {
    Scaffold.of(context).openDrawer();
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
                  if (feedback.skillGaps != null &&
                      feedback.skillGaps!.isNotEmpty)
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF144A3F),
          child: Text('JM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
        ),
        SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            child: Text("✍️ Analyzing your CV..."),
          ),
        ),
      ],
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
          (gap.improvementSuggestions != null &&
              gap.improvementSuggestions!.isNotEmpty);
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
              lines.add(
                  "• ${gap.skillName}${levelInfo.isNotEmpty ? ' ($levelInfo)' : ''}");
            }
            if (gap.importance != null && gap.importance!.isNotEmpty) {
              lines.add("   Importance: ${gap.importance}");
            }
            if (gap.improvementSuggestions != null &&
                gap.improvementSuggestions!.isNotEmpty) {
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
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatHeader(
        onBack: () => Navigator.pop(context),
        onToggleLanguage: () {},
        onShowHistory: () => _openChatHistory(context),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF144A3F)),
              child: Text('Your CV Chats',
                  style: TextStyle(color: Colors.white)),
            ),
            ...chatSessions.map((chat) => ListTile(
      title: Text("Chat ${chat.chatId}"), // ✅ fixed
      subtitle: Text("Updated: ${chat.updatedAt.toLocal()}"),
      onTap: () {
        Navigator.pop(context);
        _selectChat(chat);
      },
)),

          ],
        ),
      ),
      body: BlocConsumer<CvBloc, CvState>(
        listener: (context, state) {
          if (state is CvError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is CvUploaded) {
            context.read<CvBloc>().add(AnalyzeCvEvent(state.details.cvId));
            setState(() => showUploadBox = false);
          }
          if (state is CvAnalyzed) {
            setState(() => _feedbackHistory.insert(0, state.feedback));
          }
        },
        builder: (context, state) {
          return Column(
  children: [
    // Main scrollable area (messages + feedback)
    Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
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

            if (showUploadBox) _buildUploadBox(),

            if (!showUploadBox) ...[
              if (state is CvLoading) _typingBubble(),
              ..._feedbackHistory.map((f) => _feedbackBubble(f)),

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

    // Fixed bottom actions (message input + reanalyze button)
    if (!showUploadBox)
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
            ),
            const SizedBox(height: 8),
            ElevatedButton(
  onPressed: _toggleUploadBox,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.teal, // Teal background
    foregroundColor: Colors.white, // Text color
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Control width and height
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Slightly rounded corners
    ),
  ),
  child: const Text(
    "Reanalyze CV",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 16, // Adjust text size if needed
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
    );
  }
}
