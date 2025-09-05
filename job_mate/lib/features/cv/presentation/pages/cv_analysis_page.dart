import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source_impl.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_bloc.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_event.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_state.dart';
import 'package:job_mate/features/cv/presentation/widgets/chat_header.dart';
import 'package:job_mate/features/cv/presentation/widgets/cv_input_widget.dart';
import 'package:job_mate/features/cv/presentation/widgets/file_upload_widget.dart';
import 'package:job_mate/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CvAnalysisPage extends StatefulWidget {
  const CvAnalysisPage({super.key});

  @override
  State<CvAnalysisPage> createState() => _CvAnalysisPageState();
}

class _CvAnalysisPageState extends State<CvAnalysisPage>
    with SingleTickerProviderStateMixin {
  bool isTextMode = true;
  final TextEditingController _textController = TextEditingController();
  String? uploadedFilePath;
  String? userId;
  bool isLoadingUserId = true;
  final List<CvFeedback> _feedbackHistory = []; // store multiple analyses

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserId());
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

  Widget _feedbackBubble(CvFeedback feedback) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), // spacing between results
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
            child: Row(
              children: const [
                Text("Analyzing your CV"),
                SizedBox(width: 8),
                AnimatedDots(), // custom animated typing dots
              ],
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatHeader(
        onBack: () => Navigator.pop(context),
        onToggleLanguage: () {},
      ),
      body: BlocConsumer<CvBloc, CvState>(
        listener: (context, state) {
          if (state is CvError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is CvUploaded) {
            context.read<CvBloc>().add(AnalyzeCvEvent(state.details.cvId));
          }
          if (state is CvAnalyzed) {
            setState(() => _feedbackHistory.insert(0, state.feedback));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // System greeting
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

                // Input box
                Row(
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
                                Icon(Icons.description,
                                    color: Color(0xFF005148)),
                                SizedBox(width: 8),
                                Text("CV Analysis",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
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
                ),

                const SizedBox(height: 20),

                if (state is CvLoading) _typingBubble(),

                // Show all feedbacks with spacing
                ..._feedbackHistory.map((f) => _feedbackBubble(f)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}

/// Simple animated 3-dot typing indicator
class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        int dotCount = (3 * _controller.value).floor() + 1;
        return Text("." * dotCount,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005148)));
      },
    );
  }
}
