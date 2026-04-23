import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = AuthService.baseUrl;

  final String token;
  ApiService(this.token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Lấy danh sách chủ đề
  Future<List<dynamic>> getTopics() async {
    final res = await http.get(Uri.parse('$baseUrl/topics'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Lỗi lấy danh sách chủ đề');
  }

  // Lấy từ vựng theo chủ đề
  Future<List<dynamic>> getWordsByTopic(int topicId) async {
    final res = await http.get(Uri.parse('$baseUrl/words/topic/$topicId'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Lỗi lấy từ vựng');
  }

  // Tìm kiếm từ vựng
  Future<List<dynamic>> searchWords(String query) async {
    final res = await http.get(
      Uri.parse('$baseUrl/words/search?q=$query'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Lỗi tìm kiếm');
  }

  // Lưu tiến trình học
  Future<void> saveProgress(int wordId, String status) async {
    await http.post(
      Uri.parse('$baseUrl/progress'),
      headers: _headers,
      body: jsonEncode({'word_id': wordId, 'status': status}),
    );
  }

  // Lấy tiến trình học theo chủ đề
  Future<List<dynamic>> getProgressByTopic(int topicId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/progress/topic/$topicId'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  // Lưu kết quả quiz
  Future<void> saveQuizResult(int topicId, int score, int total) async {
    await http.post(
      Uri.parse('$baseUrl/progress/quiz'),
      headers: _headers,
      body: jsonEncode({'topic_id': topicId, 'score': score, 'total': total}),
    );
  }

  // Lấy thống kê
  Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(Uri.parse('$baseUrl/progress/stats'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Lỗi lấy thống kê');
  }

  // Lấy badges và XP
  Future<Map<String, dynamic>> getBadges() async {
    final res = await http.get(Uri.parse('$baseUrl/rewards/badges'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Lỗi lấy badges');
  }

  // Lấy gợi ý lộ trình học
  Future<List<dynamic>> getLearningPath() async {
    final res = await http.get(Uri.parse('$baseUrl/rewards/learning-path'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }
}
