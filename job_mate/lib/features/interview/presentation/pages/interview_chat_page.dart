// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:job_mate/core/presentation/routes.dart';
// import '../blocs/interview_bloc.dart';
// import '../blocs/interview_event.dart';
// import '../blocs/interview_state.dart';
// import '../widgets/chat_bubble.dart';
// import '../widgets/message_input.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../widgets/chat_header.dart';
// import 'package:go_router/go_router.dart';
// import 'package:job_mate/core/presentation/routes.dart';

// class InterviewPage extends StatefulWidget {
//   const InterviewPage({super.key});

//   @override
//   State<InterviewPage> createState() => _InterviewPageState();
// }

// class _InterviewPageState extends State<InterviewPage> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   int _currentIndex = 2;

//   @override
//   void initState() {
//     super.initState();
//     context.read<InterviewBloc>().add(StartInterviewSession());
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: ChatHeader(
//         onBack: () => Navigator.pop(context),
//         onToggleLanguage: () {},
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocConsumer<InterviewBloc, InterviewState>(
//               listener: (context, state) {
//                 if (state is InterviewLoaded) _scrollToBottom();
//                 if (state is InterviewError) {
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text(state.message)));
//                 }
//               },
//               builder: (context, state) {
//                 if (state is InterviewLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (state is InterviewLoaded) {
//                   return ListView.builder(
//                     controller: _scrollController,
//                     itemCount: state.messages.length,
//                     itemBuilder:
//                         (context, index) =>
//                             ChatBubble(message: state.messages[index]),
//                   );
//                 }
//                 return const Center(
//                   child: Text("Start your interview practice"),
//                 );
//               },
//             ),
//           ),
//           MessageInput(
//             controller: _controller,
//             onSend: () {
//               final text = _controller.text.trim();
//               if (text.isNotEmpty) {
//                 context.read<InterviewBloc>().add(SendMessage(text));
//                 _controller.clear();
//               }
//             },
//           ),
//         ],
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() => _currentIndex = index);
//           switch (index) {
//             case 0:
//               context.go(Routes.cvAnalysis);
//               break;
//             case 1:
//               context.go(Routes.jobSearch);
//               break;
//             case 2:
//               context.go(Routes.interviewPrep);
//               break;
//             case 3:
//               context.go(Routes.home);
//               break;
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:job_mate/core/presentation/routes.dart';

import '../blocs/interview_bloc.dart';
import '../blocs/interview_event.dart';
import '../blocs/interview_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/chat_header.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 2;

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
  void _navigateToHome() {
    // Navigate back to home using GoRouter
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatHeader(
        // onBack: () => Navigator.pop(context),
        onBack: _navigateToHome,
        onToggleLanguage: () {},
      ),
      body: Column(
        children: [
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
                  return _buildIntroCard(context);
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
          MessageInput(
            controller: _controller,
            onSend: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                context.read<InterviewBloc>().add(SendMessage(text));
                _controller.clear();
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              context.go(Routes.cvAnalysis);
              break;
            case 1:
              context.go(Routes.jobSearch);
              break;
            case 2:
              context.go(Routes.interviewPrep);
              break;
            case 3:
              context.go(Routes.home);
              break;
          }
        },
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 12),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF144A3F),
                child: Text(
                  "JM",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 330),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Perfect! Let’s practice some interview questions together. "
                    "I’ll ask you common interview questions and provide personalized feedback "
                    "to help you build confidence and improve your interview skills.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 58),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 330),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F4),
                    borderRadius: BorderRadius.circular(16),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.05),
                    //     blurRadius: 4,
                    //     offset: const Offset(0, 2),
                    //   ),
                    // ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.chat_rounded,
                            color: Color(0xFF144A3F),
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Interview Practice",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "What you'll practice:\n"
                        "• Common interview questions\n"
                        "• Personalized feedback\n"
                        "• Tips for improvement\n"
                        "• Build confidence for real interviews",
                        style: TextStyle(fontSize: 14, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<InterviewBloc>().add(
                              StartInterviewSession(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF28957F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Start Interview Practice",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }
}
