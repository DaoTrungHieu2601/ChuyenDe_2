import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class FlashcardScreen extends StatefulWidget {
  final List<dynamic> words;
  final Map<String, dynamic> topic;
  const FlashcardScreen({super.key, required this.words, required this.topic});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
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
      _animController.reset();
      setState(() { _currentIndex++; _isFlipped = false; });
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _animController.reset();
      setState(() { _currentIndex--; _isFlipped = false; });
    }
  }

  Future<void> _markLearned() async {
    final token = context.read<AuthService>().token!;
    final api = ApiService(token);
    final word = widget.words[_currentIndex];
    await api.saveProgress(word['id'], 'learned');
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

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 32),

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
