import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class FlashcardScreen extends StatefulWidget {
  final TopicModel topic;

  const FlashcardScreen({super.key, required this.topic});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showFront = true;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  List<WordModel> get words => widget.topic.words;
  WordModel get currentWord => words[_currentIndex];

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipCtrl.isAnimating) return;
    if (_showFront) {
      _flipCtrl.forward();
    } else {
      _flipCtrl.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  void _goNext() {
    if (_currentIndex < words.length - 1) {
      _resetCard();
      setState(() => _currentIndex++);
    } else {
      _showFinishDialog();
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      _resetCard();
      setState(() => _currentIndex--);
    }
  }

  void _resetCard() {
    _flipCtrl.reset();
    _showFront = true;
  }

  void _markLearned() {
    setState(() {
      currentWord.isLearned = true;
    });
    if (_currentIndex < words.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _resetCard();
          setState(() => _currentIndex++);
        }
      });
    } else {
      _showFinishDialog();
    }
  }

  void _showFinishDialog() {
    final learned = words.where((w) => w.isLearned).length;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            const Text(
              'Hoàn thành!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1D2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn đã thuộc $learned/${words.length} từ',
              style: const TextStyle(fontSize: 14, color: Color(0xFF9094A6)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // đóng dialog
                  Navigator.pop(context); // về topic detail
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D8EFF),
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
              const SizedBox(height: 24),
              Expanded(child: _buildFlipCard()),
              const SizedBox(height: 24),
              _buildActions(),
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
            child: const Icon(Icons.close, size: 18, color: Color(0xFF9094A6)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_currentIndex + 1} / ${words.length}',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF9094A6)),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / words.length,
                  backgroundColor: const Color(0xFFE8ECF4),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF4D8EFF)),
                  minHeight: 7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlipCard() {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _flipAnim,
        builder: (context, child) {
          final angle = _flipAnim.value * pi;
          final showingFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showingFront
                ? _buildFrontCard()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBackCard(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D8EFF).withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4D8EFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Tiếng Anh',
              style: TextStyle(
                color: Color(0xFF4D8EFF),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            currentWord.english,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1D2E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            currentWord.pronunciation,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF4D8EFF),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app_outlined,
                  size: 16, color: Color(0xFF9094A6)),
              const SizedBox(width: 4),
              Text(
                'Chạm để lật',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9094A6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.topic.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: widget.topic.gradientColors.first.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Tiếng Việt',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            currentWord.vietnamese,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  currentWord.example,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  currentWord.exampleVietnamese,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _CircleBtn(
          icon: Icons.arrow_back_ios_new,
          onTap: _currentIndex > 0 ? _goPrev : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _markLearned,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: currentWord.isLearned
                    ? const Color(0xFF6BCB77).withOpacity(0.15)
                    : const Color(0xFF6BCB77),
                borderRadius: BorderRadius.circular(16),
                border: currentWord.isLearned
                    ? Border.all(
                        color: const Color(0xFF6BCB77), width: 1.5)
                    : null,
                boxShadow: currentWord.isLearned
                    ? null
                    : [
                        BoxShadow(
                          color:
                              const Color(0xFF6BCB77).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentWord.isLearned ? '✅' : '⭐',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentWord.isLearned ? 'Đã thuộc' : 'Đã thuộc',
                    style: TextStyle(
                      color: currentWord.isLearned
                          ? const Color(0xFF6BCB77)
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _CircleBtn(
          icon: Icons.arrow_forward_ios,
          onTap: _goNext,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _CircleBtn({required this.icon, this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.35,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF4D8EFF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isPrimary
                ? null
                : const Border.fromBorderSide(
                    BorderSide(color: Color(0xFFE8ECF4), width: 1.5)),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF4D8EFF).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isPrimary ? Colors.white : const Color(0xFF9094A6),
          ),
        ),
      ),
    );
  }
}
