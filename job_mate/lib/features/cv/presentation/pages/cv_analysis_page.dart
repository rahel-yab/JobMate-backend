import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_mate/features/cv/presentation/widgets/chat_header.dart';
import '../bloc/cv_bloc.dart';
import '../bloc/cv_event.dart';
import '../bloc/cv_state.dart';
import '../widgets/cv_input_widget.dart';
import '../widgets/file_upload_widget.dart';

class CvAnalysisPage extends StatefulWidget {
  const CvAnalysisPage({super.key});

  @override
  State<CvAnalysisPage> createState() => _CvAnalysisPageState();
}

class _CvAnalysisPageState extends State<CvAnalysisPage> {
  bool isTextMode = true;
  final TextEditingController _textController = TextEditingController();
  String? uploadedFilePath;

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

  void _showFeedbackDialog(BuildContext context, CvAnalyzed state) {
    final feedback = state.feedback;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "CV Analysis Result",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Summary"),
                Text(feedback.summary),

                const SizedBox(height: 12),
                _sectionTitle("Strengths"),
                Text(feedback.strengths),

                const SizedBox(height: 12),
                _sectionTitle("Weaknesses"),
                Text(feedback.weaknesses),

                const SizedBox(height: 12),
                _sectionTitle("Improvement Suggestions"),
                Text(feedback.improvementSuggestions),

                const SizedBox(height: 12),
                _sectionTitle("Extracted Skills"),
                ...feedback.extractedSkills.map((s) => Text("• $s")),

                const SizedBox(height: 12),
                _sectionTitle("Experience"),
                ...feedback.extractedExperience.map((e) => Text("• $e")),

                const SizedBox(height: 12),
                _sectionTitle("Education"),
                ...feedback.extractedEducation.map((ed) => Text("• $ed")),

                if (feedback.skillGaps != null &&
                    feedback.skillGaps!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sectionTitle("Skill Gaps"),
                  ...feedback.skillGaps!.map(
                    (gap) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "• ${gap.skillName} "
                            "(Current: ${gap.currentLevel}, "
                            "Recommended: ${gap.recommendedLevel})",
                          ),
                          Text("Importance: ${gap.importance}"),
                          Text("Suggestions: ${gap.improvementSuggestions}"),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is CvAnalyzed) {
            _showFeedbackDialog(context, state);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF144A3F),
                      child: Text(
                        'JM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                                Icon(
                                  Icons.description,
                                  color: Color(0xFF005148),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'CV Analysis',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () => setState(() => isTextMode = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isTextMode
                                                ? const Color(0xFF144A3F)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Type/Paste',
                                        style: TextStyle(
                                          color:
                                              isTextMode
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () =>
                                            setState(() => isTextMode = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            !isTextMode
                                                ? const Color(0xFF144A3F)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Upload File',
                                        style: TextStyle(
                                          color:
                                              !isTextMode
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF238471),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (isTextMode) {
                                    context.read<CvBloc>().add(
                                      UploadCvEvent(
                                        userId: '123',
                                        rawText: _textController.text,
                                      ),
                                    );
                                  } else if (uploadedFilePath != null) {
                                    context.read<CvBloc>().add(
                                      UploadCvEvent(
                                        userId: '123',
                                        filePath: uploadedFilePath!,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Analyze My CV',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
