import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Một chủ đề còn từ cần ôn (quiz sai gần nhất).
class WrongTopicSummary {
  final int topicId;
  final String topicName;
  final int wrongCount;
  const WrongTopicSummary({
    required this.topicId,
    required this.topicName,
    required this.wrongCount,
  });
}

/// Lưu id các từ trả lời sai trong quiz gần nhất (theo user + chủ đề), để ôn flashcard / quiz chỉ tập đó.
class QuizWrongWordsStore {
  static String _key(int userId, int topicId) => 'quiz_wrong_word_ids_${userId}_$topicId';

  static Future<Set<int>> loadWrongWordIds(int userId, int topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId, topicId));
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => (e as num).toInt()).toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveWrongWordIds(int userId, int topicId, Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    if (ids.isEmpty) {
      await prefs.remove(_key(userId, topicId));
      return;
    }
    final sorted = ids.toList()..sort();
    await prefs.setString(_key(userId, topicId), jsonEncode(sorted));
  }

  /// Các chủ đề (trong [topics]) còn ít nhất một từ sai đã lưu.
  static Future<List<WrongTopicSummary>> summariesForTopics(int userId, List<dynamic> topics) async {
    final out = <WrongTopicSummary>[];
    for (final raw in topics) {
      final t = raw as Map<String, dynamic>;
      final tid = t['id'];
      if (tid is! int) continue;
      final ids = await loadWrongWordIds(userId, tid);
      if (ids.isEmpty) continue;
      out.add(WrongTopicSummary(
        topicId: tid,
        topicName: t['name']?.toString() ?? 'Chủ đề $tid',
        wrongCount: ids.length,
      ));
    }
    return out;
  }
}
