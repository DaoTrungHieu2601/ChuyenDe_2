import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  // Dùng 'http://localhost:3000/api' nếu test trên iOS simulator hoặc web

  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  AuthService() {
    _restoreSession();
  }

  // Khôi phục session từ SharedPreferences khi khởi động app
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      if (savedToken != null) {
        _token = savedToken;
        final ok = await _fetchCurrentUser();
        _isLoggedIn = ok;
        if (!ok) {
          // Token hết hạn hoặc không hợp lệ → xoá
          await prefs.remove('token');
          _token = null;
        }
      }
    } catch (_) {
      // Lỗi mạng khi restore → vẫn cho vào login
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy thông tin user hiện tại từ API
  Future<bool> _fetchCurrentUser() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/auth/me'),
            headers: {'Authorization': 'Bearer $_token'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        _user = jsonDecode(utf8.decode(response.bodyBytes));
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Đăng nhập
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        _token = data['token'];
        _user = data['user'];
        _isLoggedIn = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        notifyListeners();
        return AuthResult.success(data['message'] ?? 'Đăng nhập thành công');
      }
      return AuthResult.failure(data['message'] ?? 'Đăng nhập thất bại');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return AuthResult.failure('Kết nối quá hạn, thử lại sau');
      }
      return AuthResult.failure('Không thể kết nối máy chủ');
    }
  }

  // Đăng ký
  Future<AuthResult> register(
      String username, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username.trim(),
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) {
        return AuthResult.success(data['message'] ?? 'Đăng ký thành công');
      }
      return AuthResult.failure(data['message'] ?? 'Đăng ký thất bại');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return AuthResult.failure('Kết nối quá hạn, thử lại sau');
      }
      return AuthResult.failure('Không thể kết nối máy chủ');
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    _token = null;
    _user = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    notifyListeners();
  }
}

// Kết quả trả về từ login/register
class AuthResult {
  final bool success;
  final String message;

  AuthResult.success(this.message) : success = true;
  AuthResult.failure(this.message) : success = false;
}
