// import 'dart:convert';

// import 'package:job_mate/features/cv/data/datasources/local/cv_loacal_data_source.dart';
// import 'package:job_mate/features/cv/domain/entities/chat_session.dart';
// import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CvLocalDataSourceImpl implements CvLocalDataSource {
//   final SharedPreferences preferences;

//   static const String _cvFeedbackPrefix = 'cv_feedback_';
//   static const String _chatSessionsPrefix = 'chat_sessions_';

//   CvLocalDataSourceImpl({required this.preferences});

//   @override
//   Future<void> cacheCvFeedback(String userId, String cvId, CvFeedback feedback) async {
//     final key = '$_cvFeedbackPrefix$userId_$cvId';
//     final feedbackJson = jsonEncode({
//       'summary': feedback.summary,
//       'strengths': feedback.strengths,
//       'weaknesses': feedback.weaknesses,
//       'improvementSuggestions': feedback.improvementSuggestions,
//       'extractedSkills': feedback.extractedSkills,
//       'extractedExperience': feedback.extractedExperience,
//       'extractedEducation': feedback.extractedEducation,
//       'skillGaps': feedback.skillGaps?.map((gap) => {
//             'skillName': gap.skillName,
//             'currentLevel': gap.currentLevel,
//             'recommendedLevel': gap.recommendedLevel,
//             'importance': gap.importance,
//             'improvementSuggestions': gap.improvementSuggestions,
//           }).toList(),
//     });
//     await preferences.setString(key, feedbackJson);
//   }

//   @override
//   Future<CvFeedback?> getCvFeedback(String userId, String cvId) async {
//     final key = '$_cvFeedbackPrefix$userId_$cvId';
//     final feedbackJson = preferences.getString(key);
//     if (feedbackJson == null) return null;

//     final decoded = jsonDecode(feedbackJson) as Map<String, dynamic>;
//     return CvFeedback(
//       summary: decoded['summary'] as String?,
//       strengths: decoded['strengths'] as String?,
//       weaknesses: decoded['weaknesses'] as String?,
//       improvementSuggestions: decoded['improvementSuggestions'] as String?,
//       extractedSkills: List<String>.from(decoded['extractedSkills'] ?? []),
//       extractedExperience: List<String>.from(decoded['extractedExperience'] ?? []),
//       extractedEducation: List<String>.from(decoded['extractedEducation'] ?? []),
//       skillGaps: (decoded['skillGaps'] as List<dynamic>?)?.map((gap) => SkillGap(
//             skillName: gap['skillName'] as String?,
//             currentLevel: gap['currentLevel'] as String?,
//             recommendedLevel: gap['recommendedLevel'] as String?,
//             importance: gap['importance'] as String?,
//             improvementSuggestions: gap['improvementSuggestions'] as String?,
//           )).toList(),
//     );
//   }

//   @override
//   Future<List<CvFeedback>> getAllCvFeedback(String userId) async {
//     final keys = preferences.getKeys().where((key) => key.startsWith(_cvFeedbackPrefix + userId + '_'));
//     return Future.wait(keys.map((key) async {
//       final feedbackJson = preferences.getString(key);
//       if (feedbackJson == null) return null;
//       final decoded = jsonDecode(feedbackJson) as Map<String, dynamic>;
//       return CvFeedback(
//         summary: decoded['summary'] as String?,
//         strengths: decoded['strengths'] as String?,
//         weaknesses: decoded['weaknesses'] as String?,
//         improvementSuggestions: decoded['improvementSuggestions'] as String?,
//         extractedSkills: List<String>.from(decoded['extractedSkills'] ?? []),
//         extractedExperience: List<String>.from(decoded['extractedExperience'] ?? []),
//         extractedEducation: List<String>.from(decoded['extractedEducation'] ?? []),
//         skillGaps: (decoded['skillGaps'] as List<dynamic>?)?.map((gap) => SkillGap(
//               skillName: gap['skillName'] as String?,
//               currentLevel: gap['currentLevel'] as String?,
//               recommendedLevel: gap['recommendedLevel'] as String?,
//               importance: gap['importance'] as String?,
//               improvementSuggestions: gap['improvementSuggestions'] as String?,
//             )).toList(),
//       );
//     }).whereType<Future<CvFeedback>>());
//   }

//   @override
//   Future<void> cacheChatSession(String userId, ChatSession session) async {
//     final key = '$_chatSessionsPrefix$userId';
//     final sessionsJson = preferences.getString(key) ?? '[]';
//     final sessions = (jsonDecode(sessionsJson) as List)
//         .map((json) => ChatSession.fromJson(json as Map<String, dynamic>))
//         .toList();
//     sessions.removeWhere((s) => s.chatId == session.chatId); // Avoid duplicates
//     sessions.add(session);
//     await preferences.setString(key, jsonEncode(sessions));
//   }

//   @override
//   Future<List<ChatSession>> getAllChatSessions(String userId) async {
//     final key = '$_chatSessionsPrefix$userId';
//     final sessionsJson = preferences.getString(key) ?? '[]';
//     return (jsonDecode(sessionsJson) as List)
//         .map((json) => ChatSession.fromJson(json as Map<String, dynamic>))
//         .toList();
//   }

//   @override
//   Future<void> clearCvData(String userId) async {
//     final keys = preferences.getKeys().where((key) => key.startsWith(_cvFeedbackPrefix + userId) || key.startsWith(_chatSessionsPrefix + userId));
//     for (final key in keys) {
//       await preferences.remove(key);
//     }
//   }
// }