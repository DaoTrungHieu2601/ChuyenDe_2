import 'dart:math';
import 'package:flutter/material.dart';
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

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late List<_QuizQuestion> _questions;
  int _currentIndex = 0;
  int _selectedOption = -1; // -1 = chưa chọn
  int _correctCount = 0;
  bool _answered = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
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
          ],
        ),
      ),
    );
  }

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
}
