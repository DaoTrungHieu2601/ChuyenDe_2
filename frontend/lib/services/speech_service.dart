import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class SpeechService {
  static bool get isSupported {
    try {
      final result = js.context['speechRecognizer']?.callMethod('isSupported');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  /// Ghi âm người dùng nói [expectedWord], trả về ({transcript, score 0–100}).
  static Future<({String transcript, int score})> recognize(String expectedWord) {
    final completer = Completer<({String transcript, int score})>();
    try {
      js.context['speechRecognizer']?.callMethod('start', [
        expectedWord,
        js.allowInterop((String transcript, int score) {
          if (!completer.isCompleted) {
            completer.complete((transcript: transcript, score: score));
          }
        }),
      ]);
    } catch (e) {
      completer.complete((transcript: 'ERROR', score: 0));
    }
    // Timeout 8 giây nếu không nhận được kết quả
    Future.delayed(const Duration(seconds: 8), () {
      if (!completer.isCompleted) {
        completer.complete((transcript: 'TIMEOUT', score: 0));
      }
    });
    return completer.future;
  }

  static void stop() {
    try {
      js.context['speechRecognizer']?.callMethod('stop');
    } catch (_) {}
  }
}
