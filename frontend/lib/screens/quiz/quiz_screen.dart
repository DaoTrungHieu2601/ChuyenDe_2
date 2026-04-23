import 'dart:math';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../data/mock_data.dart';

class _QuizQuestion {
  final WordModel word;
  final List<String> options; // 4 đáp án
  final int correctIndex;

  const _QuizQuestion({
    required this.word,
    required this.options,
    required this.correctIndex,
  });
}

class QuizScreen extends StatefulWidget {
  final TopicModel topic;

  const QuizScreen({super.key, required this.topic});
=======
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final List<dynamic> words;
  final Map<String, dynamic> topic;
  const QuizScreen({super.key, required this.words, required this.topic});
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

<<<<<<< HEAD
class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late List<_QuizQuestion> _questions;
  int _currentIndex = 0;
  int _selectedOption = -1; // -1 = chưa chọn
  int _correctCount = 0;
  bool _answered = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
=======
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
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _questions = _generateQuestions();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
=======
    _shuffled = List.from(widget.words)..shuffle(Random());
    _animController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.elasticOut));
    _generateOptions();
    _animController.forward();
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _shakeCtrl.dispose();
    super.dispose();
  }

  List<_QuizQuestion> _generateQuestions() {
    final rng = Random();
    final words = widget.topic.words;
    final allVi = words.map((w) => w.vietnamese).toList();

    return words.map((word) {
      // 3 đáp án sai từ các từ khác
      final wrongOptions = allVi
          .where((vi) => vi != word.vietnamese)
          .toList()
        ..shuffle(rng);
      final options = [word.vietnamese, ...wrongOptions.take(3)]..shuffle(rng);
      final correctIndex = options.indexOf(word.vietnamese);

      return _QuizQuestion(
        word: word,
        options: options,
        correctIndex: correctIndex,
      );
    }).toList()
      ..shuffle(rng);
  }

  _QuizQuestion get current => _questions[_currentIndex];

  void _selectOption(int index) {
    if (_answered) return;

    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == current.correctIndex) {
        _correctCount++;
        current.word.isLearned = true;
      } else {
        _shakeCtrl.forward(from: 0);
      }
    });
  }

  void _goNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = -1;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final percent = (_correctCount / _questions.length * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              percent >= 80 ? '🏆' : percent >= 50 ? '👍' : '📚',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 12),
            Text(
              percent >= 80
                  ? 'Xuất sắc!'
                  : percent >= 50
                      ? 'Khá tốt!'
                      : 'Cố lên nhé!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1D2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctCount/${_questions.length} câu đúng ($percent%)',
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF9094A6)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Về danh sách',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ),
=======
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
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildQuestion(),
              const SizedBox(height: 16),
              Expanded(child: _buildOptions()),
              if (_answered) ...[
                const SizedBox(height: 12),
                _buildNextButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: const Border.fromBorderSide(
                  BorderSide(color: Color(0xFFE8ECF4), width: 1.5)),
            ),
            child: const Icon(Icons.close,
                size: 18, color: Color(0xFF9094A6)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_currentIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF9094A6)),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: const Color(0xFFE8ECF4),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF8C00)),
                  minHeight: 7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '$_correctCount',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF8C00),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Từ này có nghĩa là gì?',
              style: TextStyle(
                color: Color(0xFFFF8C00),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            current.word.english,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1D2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            current.word.pronunciation,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4D8EFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return ListView.builder(
      itemCount: current.options.length,
      itemBuilder: (context, i) {
        final isSelected = _selectedOption == i;
        final isCorrect = i == current.correctIndex;

        Color bgColor = Colors.white;
        Color borderColor = const Color(0xFFE8ECF4);
        Color textColor = const Color(0xFF1A1D2E);
        Color letterBg = const Color(0xFFF4F6FB);
        Widget? trailingIcon;

        if (_answered) {
          if (isCorrect) {
            bgColor = const Color(0xFF6BCB77).withOpacity(0.1);
            borderColor = const Color(0xFF6BCB77);
            textColor = const Color(0xFF6BCB77);
            letterBg = const Color(0xFF6BCB77).withOpacity(0.2);
            trailingIcon = const Icon(Icons.check_circle,
                color: Color(0xFF6BCB77), size: 20);
          } else if (isSelected && !isCorrect) {
            bgColor = const Color(0xFFFF6B6B).withOpacity(0.1);
            borderColor = const Color(0xFFFF6B6B);
            textColor = const Color(0xFFFF6B6B);
            letterBg = const Color(0xFFFF6B6B).withOpacity(0.2);
            trailingIcon = const Icon(Icons.cancel,
                color: Color(0xFFFF6B6B), size: 20);
          }
        } else if (isSelected) {
          bgColor = const Color(0xFF4D8EFF).withOpacity(0.08);
          borderColor = const Color(0xFF4D8EFF);
        }

        final optionLetter = ['A', 'B', 'C', 'D'][i];

        Widget card = GestureDetector(
          onTap: () => _selectOption(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: letterBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      optionLetter,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    current.options[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailingIcon != null) trailingIcon,
              ],
            ),
          ),
        );

        // Rung khi chọn sai
        if (_answered && isSelected && !isCorrect) {
          card = AnimatedBuilder(
            animation: _shakeAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(sin(_shakeAnim.value * pi * 4) * 6, 0),
                child: child,
              );
            },
            child: card,
          );
        }

        return card;
      },
    );
  }

  Widget _buildNextButton() {
    final isLast = _currentIndex == _questions.length - 1;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _goNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8C00),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          isLast ? 'Xem kết quả' : 'Tiếp theo →',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
=======
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
}
