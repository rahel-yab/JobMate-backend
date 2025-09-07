import 'dart:convert';

import 'package:job_mate/features/interview/data/datasources/interview_local_data_source.dart';
import 'package:job_mate/features/interview/data/models/interview_message_model.dart';
import 'package:job_mate/features/interview/data/models/interview_session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterviewLocalDataSourceImpl implements InterviewLocalDataSource {
  final SharedPreferences prefs;
  // InterviewLocalDataSourceImpl(this.prefs);
  InterviewLocalDataSourceImpl({required this.prefs});

  static const String _freeformSessionsKey = 'interview_freeform_sessions';
  static const String _structuredSessionsKey = 'interview_structured_sessions';
  static String _freeformHistoryKey(String chatId) => 'interview_freeform_history_$chatId';
  static String _structuredHistoryKey(String chatId) => 'interview_structured_history_$chatId';

  @override
  Future<void> cacheUserFreeformChats(List<InterviewSessionModel> sessions) async {
    final list = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_freeformSessionsKey, jsonEncode(list));
  }

  @override
  Future<List<InterviewSessionModel>> getCachedUserFreeformChats() async {
    final raw = prefs.getString(_freeformSessionsKey);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(InterviewSessionModel.fromFreeformJson).toList();
    } catch (_) {
      await prefs.remove(_freeformSessionsKey);
      return [];
    }
  }

  @override
  Future<void> cacheUserStructuredChats(List<InterviewSessionModel> sessions) async {
    final list = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_structuredSessionsKey, jsonEncode(list));
  }

  @override
  Future<List<InterviewSessionModel>> getCachedUserStructuredChats() async {
    final raw = prefs.getString(_structuredSessionsKey);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list
          .map((m) => InterviewSessionModel.fromStructuredJson(m, field: m['field'] as String? ?? ''))
          .toList();
    } catch (_) {
      await prefs.remove(_structuredSessionsKey);
      return [];
    }
  }

  @override
  Future<void> cacheFreeformHistory(String chatId, List<InterviewMessageModel> messages) async {
    final list = messages.map((m) => m.toJson()).toList();
    await prefs.setString(_freeformHistoryKey(chatId), jsonEncode(list));
  }

  @override
  Future<List<InterviewMessageModel>> getCachedFreeformHistory(String chatId) async {
    final raw = prefs.getString(_freeformHistoryKey(chatId));
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map((m) => InterviewMessageModel.fromJson(m, chatId)).toList();
    } catch (_) {
      await prefs.remove(_freeformHistoryKey(chatId));
      return [];
    }
  }

  @override
  Future<void> cacheStructuredHistory(String chatId, List<InterviewMessageModel> messages) async {
    final list = messages.map((m) => m.toJson()).toList();
    await prefs.setString(_structuredHistoryKey(chatId), jsonEncode(list));
  }

  @override
  Future<List<InterviewMessageModel>> getCachedStructuredHistory(String chatId) async {
    final raw = prefs.getString(_structuredHistoryKey(chatId));
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map((m) => InterviewMessageModel.fromJson(m, chatId)).toList();
    } catch (_) {
      await prefs.remove(_structuredHistoryKey(chatId));
      return [];
    }
  }

  @override
  Future<void> clearAllInterviewCache() async {
    await prefs.remove(_freeformSessionsKey);
    await prefs.remove(_structuredSessionsKey);
  }
}


