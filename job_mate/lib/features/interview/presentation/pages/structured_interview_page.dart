import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:job_mate/core/presentation/routes.dart';

import '../blocs/interview_bloc.dart';
import '../blocs/interview_event.dart';
import '../blocs/interview_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/chat_header.dart';
import '../../domain/entities/interview_message.dart';

class StructuredInterviewPage extends StatefulWidget {
  final String field;

  const StructuredInterviewPage({super.key, required this.field});

  @override
  State<StructuredInterviewPage> createState() =>
      _StructuredInterviewPageState();
}

class _StructuredInterviewPageState extends State<StructuredInterviewPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentQuestionIndex = 0;
  int _totalQuestions = 6;

  @override
  void initState() {
    super.initState();
    context.read<InterviewBloc>().add(StartStructuredSession(widget.field));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatHeader(
        onBack: () => context.go('/interview'),
        onToggleLanguage: () {},
        title: 'Structured Interview',
        subtitle: '${widget.field} Practice',
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF5F9F8),
            child: BlocBuilder<InterviewBloc, InterviewState>(
              builder: (context, state) {
                if (state is InterviewLoaded) {
                  // Count questions and answers to determine progress
                  int questionsAnswered = 0;
                  for (var message in state.messages) {
                    if (message.role == 'user') {
                      questionsAnswered++;
                    }
                  }
                  _currentQuestionIndex = questionsAnswered;
                }

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of $_totalQuestions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF144A3F),
                          ),
                        ),
                        Text(
                          '${((_currentQuestionIndex / _totalQuestions) * 100).round()}% Complete',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _currentQuestionIndex / _totalQuestions,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1976D2),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Chat messages
          Expanded(
            child: BlocConsumer<InterviewBloc, InterviewState>(
              listener: (context, state) {
                if (state is InterviewLoaded) _scrollToBottom();
                if (state is InterviewError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is InterviewLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is InterviewInitial) {
                  return _buildWelcomeCard();
                }

                if (state is InterviewLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: state.messages[index]);
                    },
                  );
                }

                return const Center(child: Text("Something went wrong"));
              },
            ),
          ),

          // Message input
          BlocBuilder<InterviewBloc, InterviewState>(
            builder: (context, state) {
              bool isCompleted = false;
              if (state is InterviewLoaded) {
                // Check if interview is completed (6 questions answered)
                int userAnswers =
                    state.messages.where((msg) => msg.role == 'user').length;
                isCompleted = userAnswers >= _totalQuestions;
              }

              if (isCompleted) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '🎉 Interview Complete!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF144A3F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Great job completing your structured interview practice!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF666666)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.go('/interview'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Practice Again'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.go(Routes.home),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF28957F),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Back to Home'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return MessageInput(
                controller: _controller,
                hintText: 'Type your answer...',
                onSend: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    context.read<InterviewBloc>().add(
                      SendStructuredAnswer(text),
                    );
                    _controller.clear();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.quiz_outlined,
                    size: 48,
                    color: Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Structured Interview Practice',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF144A3F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Field: ${widget.field}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'You will be asked 6 carefully selected questions. After each answer, you\'ll receive detailed feedback to help improve your interview skills.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tips for success:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF144A3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                        'Use the STAR method (Situation, Task, Action, Result)',
                        'Be specific with examples from your experience',
                        'Take your time to think before answering',
                        'Be honest and authentic in your responses',
                      ]
                      .map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF1976D2),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<InterviewBloc>().add(
                          StartStructuredSession(widget.field),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Structured Interview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
