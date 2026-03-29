import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final List<dynamic> words;
  final Map<String, dynamic> topic;
  const QuizScreen({super.key, required this.words, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late List<dynamic> _shuffled;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  late List<String> _options;
  bool _isFinished = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(widget.words)..shuffle(Random());
    _animController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.elasticOut));
    _generateOptions();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generateOptions() {
    final correct = _shuffled[_currentIndex]['vietnamese'] as String;
    final others = widget.words
        .where((w) => w['vietnamese'] != correct)
        .map<String>((w) => w['vietnamese'] as String)
        .toList()
      ..shuffle(Random());
    _options = [correct, ...others.take(3)]..shuffle(Random());
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    final isCorrect = _options[index] == _shuffled[_currentIndex]['vietnamese'];
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _shuffled.length - 1) {
      _animController.reset();
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      _generateOptions();
      _animController.forward();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final token = context.read<AuthService>().token!;
    final api = ApiService(token);
    await api.saveQuizResult(widget.topic['id'], _score, _shuffled.length);
    setState(() => _isFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildResult();
    final word = _shuffled[_currentIndex];
    final correctIndex = _options.indexOf(word['vietnamese'] as String);
    final progress = (_currentIndex + 1) / _shuffled.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Text('${_currentIndex + 1} / ${_shuffled.length}',
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(Colors.orange),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text('$_score', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Question card
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Từ này có nghĩa là gì?',
                            style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 20),
                      Text(word['english'],
                          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      if (word['pronunciation'] != null) ...[
                        const SizedBox(height: 6),
                        Text(word['pronunciation'], style: const TextStyle(color: AppColors.primary, fontSize: 17)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Options
              Expanded(
                child: ListView.separated(
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    Color bgColor = AppColors.card;
                    Color borderColor = AppColors.border;
                    Color textColor = AppColors.textDark;
                    IconData? trailingIcon;

                    if (_answered) {
                      if (i == correctIndex) {
                        bgColor = AppColors.success.withOpacity(0.1);
                        borderColor = AppColors.success;
                        textColor = AppColors.success;
                        trailingIcon = Icons.check_circle_rounded;
                      } else if (i == _selectedAnswer) {
                        bgColor = AppColors.secondary.withOpacity(0.1);
                        borderColor = AppColors.secondary;
                        textColor = AppColors.secondary;
                        trailingIcon = Icons.cancel_rounded;
                      }
                    }

                    return GestureDetector(
                      onTap: () => _selectAnswer(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: borderColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  ['A', 'B', 'C', 'D'][i],
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(_options[i], style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 15))),
                            if (trailingIcon != null) Icon(trailingIcon, color: textColor, size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (_answered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _currentIndex < _shuffled.length - 1 ? 'Tiếp theo →' : 'Xem kết quả',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final percent = (_score / _shuffled.length * 100).round();
    final isGood = percent >= 70;
    final xpEarned = _score * 5;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isGood ? [Colors.orange, const Color(0xFFFF6B6B)] : [Colors.grey[400]!, Colors.grey[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(isGood ? '🎉' : '📝', style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(isGood ? 'Xuất sắc!' : 'Cố lên!',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$_score / ${_shuffled.length} câu đúng',
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text('+$xpEarned XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Score circle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResultStat('Điểm số', '$percent%', Colors.orange),
                  const SizedBox(width: 16),
                  _buildResultStat('Đúng', '$_score câu', AppColors.success),
                  const SizedBox(width: 16),
                  _buildResultStat('Sai', '${_shuffled.length - _score} câu', AppColors.secondary),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Quay lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
