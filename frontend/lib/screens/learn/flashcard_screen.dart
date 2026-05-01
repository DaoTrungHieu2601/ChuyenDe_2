import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/speech_service.dart';

class FlashcardScreen extends StatefulWidget {
  final List<dynamic> words;
  final Map<String, dynamic> topic;
  final int initialIndex;
  const FlashcardScreen({
    super.key,
    required this.words,
    required this.topic,
    this.initialIndex = 0,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _topicComplete = false;
  late AnimationController _animController;
  late Animation<double> _animation;
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  int? _speechScore;
  String _speechTranscript = '';

  @override
  void initState() {
    super.initState();
    if (widget.words.isNotEmpty) {
      _currentIndex = widget.initialIndex.clamp(0, widget.words.length - 1);
    }
    _animController = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _speakEnglish(String? text) async {
    final t = text?.trim() ?? '';
    if (t.isEmpty) return;
    await _tts.stop();
    await _tts.speak(t);
  }

  @override
  void dispose() {
    _tts.stop();
    SpeechService.stop();
    _animController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFlipped) {
      _animController.reverse();
    } else {
      _animController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _next() {
    if (_currentIndex < widget.words.length - 1) {
      _tts.stop();
      SpeechService.stop();
      _animController.reset();
      setState(() { _currentIndex++; _isFlipped = false; _speechScore = null; _speechTranscript = ''; _isListening = false; });
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _tts.stop();
      SpeechService.stop();
      _animController.reset();
      setState(() { _currentIndex--; _isFlipped = false; _speechScore = null; _speechTranscript = ''; _isListening = false; });
    }
  }

  Future<void> _startSpeechPractice(String word) async {
    if (_isListening) return;
    if (!SpeechService.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Trình duyệt không hỗ trợ nhận giọng nói. Hãy dùng Chrome.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() { _isListening = true; _speechScore = null; _speechTranscript = ''; });
    final result = await SpeechService.recognize(word);
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _speechTranscript = result.transcript;
      _speechScore = result.score;
    });
  }

  Future<void> _markLearned() async {
    final token = context.read<AuthService>().token!;
    final api = ApiService(token);
    final word = widget.words[_currentIndex];
    final isLastCard = _currentIndex >= widget.words.length - 1;
    await api.saveProgress(word['id'], 'learned');
    if (!mounted) return;
    if (isLastCard) {
      setState(() => _topicComplete = true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text('Đã thuộc "${word['english']}"! +10 XP'),
      ]),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
    _next();
  }

  void _finishAndExit() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Chưa có từ trong chủ đề.', style: TextStyle(color: AppColors.textGrey))),
      );
    }

    if (_topicComplete) {
      return _buildTopicCompleteScreen();
    }

    final word = widget.words[_currentIndex];
    final progress = (_currentIndex + 1) / widget.words.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Top bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                      child: const Icon(Icons.close, size: 20, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_currentIndex + 1} / ${widget.words.length}',
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => _speakEnglish(word['english'] as String?),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 6),
                            Text('Nghe', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: (_isListening ? Colors.red : Colors.deepPurple).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: _isListening ? null : () => _startSpeechPractice(word['english'] as String? ?? ''),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                              color: _isListening ? Colors.red : Colors.deepPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isListening ? 'Đang nghe...' : 'Luyện phát âm',
                              style: TextStyle(
                                color: _isListening ? Colors.red : Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_speechScore != null) ...[
                const SizedBox(height: 10),
                _buildSpeechResult(word['english'] as String? ?? ''),
              ],
              const SizedBox(height: 16),

              // Card
              Expanded(
                child: GestureDetector(
                  onTap: _flip,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (_, child) {
                      final isShowingBack = _animation.value >= 0.5;
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_animation.value * 3.14159),
                        alignment: Alignment.center,
                        child: isShowingBack
                            ? Transform(
                                transform: Matrix4.identity()..rotateY(3.14159),
                                alignment: Alignment.center,
                                child: _buildCardBack(word),
                              )
                            : _buildCardFront(word),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Bottom actions
              Row(
                children: [
                  _buildCircleBtn(Icons.arrow_back_rounded, _currentIndex > 0 ? _prev : null, AppColors.border, AppColors.textDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _markLearned,
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text('Đã thuộc', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildCircleBtn(Icons.arrow_forward_rounded, _currentIndex < widget.words.length - 1 ? _next : null, AppColors.border, AppColors.textDark),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechResult(String expected) {
    final score = _speechScore!;
    final isGood = score >= 70;
    final isFail = _speechTranscript.startsWith('ERROR') || _speechTranscript == 'TIMEOUT' || _speechTranscript == 'NOT_SUPPORTED';
    final color = isFail ? Colors.orange : (isGood ? AppColors.success : Colors.red);
    final icon = isFail ? Icons.warning_amber_rounded : (isGood ? Icons.check_circle_rounded : Icons.cancel_rounded);
    final label = isFail
        ? 'Không nhận được giọng nói. Thử lại.'
        : (isGood ? 'Tốt lắm! ($score%)' : 'Chưa đúng ($score%) — Bạn nói: "$_speechTranscript"');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildTopicCompleteScreen() {
    final topicName = widget.topic['name']?.toString() ?? 'Chủ đề';
    final n = widget.words.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _finishAndExit,
                  icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.success.withOpacity(0.15), AppColors.primary.withOpacity(0.12)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🎉', style: TextStyle(fontSize: 64)),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Chúc mừng!',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bạn đã ôn xong chủ đề',
                          style: TextStyle(fontSize: 16, color: AppColors.textGrey.withOpacity(0.95)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          topicName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: AppColors.success.withOpacity(0.9), size: 22),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'Đã đánh dấu $n từ «đã thuộc» trong phiên học này.\nTiếp tục luyện quiz để ghi nhớ bền hơn nhé!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.45,
                                    color: AppColors.textDark.withOpacity(0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _finishAndExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Quay lại chủ đề', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(Map<String, dynamic> word) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Tiếng Anh', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          Text(word['english'],
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          if (word['pronunciation'] != null) ...[
            const SizedBox(height: 8),
            Text(word['pronunciation'], style: const TextStyle(color: AppColors.primary, fontSize: 18)),
          ],
          if (word['vietnamese'] != null) ...[
            const SizedBox(height: 8),
            Text(
              word['vietnamese'],
              style: TextStyle(color: AppColors.textGrey.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app_rounded, color: AppColors.textGrey, size: 16),
              const SizedBox(width: 6),
              Text('Chạm để lật', style: TextStyle(color: AppColors.textGrey.withOpacity(0.7), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Map<String, dynamic> word) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Tiếng Việt', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(word['vietnamese'],
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center),
          ),
          if (word['example_en'] != null) ...[
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(word['example_en'],
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontStyle: FontStyle.italic, fontSize: 14),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(word['example_vi'] ?? '',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback? onTap, Color bg, Color iconColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey[100] : bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: onTap == null ? Colors.grey[300] : iconColor, size: 22),
      ),
    );
  }
}
