import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import 'flashcard_screen.dart';
import '../quiz/quiz_screen.dart';

class TopicDetailScreen extends StatefulWidget {
  final Map<String, dynamic> topic;
  const TopicDetailScreen({super.key, required this.topic});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  List<dynamic> _words = [];
  Set<int> _learnedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final token = context.read<AuthService>().token!;
    final api = ApiService(token);
    try {
      final words = await api.getWordsByTopic(widget.topic['id']);
      final progress = await api.getProgressByTopic(widget.topic['id']);
      final learned = progress
          .where((p) => p['status'] == 'learned')
          .map<int>((p) => p['word_id'] as int)
          .toSet();
      setState(() {
        _words = words;
        _learnedIds = learned;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _progress => _words.isEmpty ? 0 : _learnedIds.length / _words.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(widget.topic['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${_words.length} từ vựng',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                        const SizedBox(height: 16),
                        // Progress bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tiến độ', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                                Text('${_learnedIds.length}/${_words.length}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor: Colors.white.withOpacity(0.25),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Row(
                      children: [
                        Expanded(child: _buildActionBtn(
                          icon: Icons.style_rounded,
                          label: 'Flashcard',
                          color: AppColors.primary,
                          onTap: _words.isEmpty ? null : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FlashcardScreen(words: _words, topic: widget.topic)),
                          ).then((_) => _loadWords()),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _buildActionBtn(
                          icon: Icons.quiz_rounded,
                          label: 'Quiz',
                          color: Colors.orange,
                          onTap: _words.length < 4 ? null : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => QuizScreen(words: _words, topic: widget.topic)),
                          ).then((_) => _loadWords()),
                        )),
                      ],
                    ),
                  ),
                ),

                // Word list header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, 8),
                    child: Text('Danh sách từ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  ),
                ),

                // Words
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildWordCard(_words[i]),
                      childCount: _words.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionBtn({required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey[200] : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: onTap == null ? Colors.grey[300]! : color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: onTap == null ? Colors.grey : color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: onTap == null ? Colors.grey : color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(Map<String, dynamic> word) {
    final isLearned = _learnedIds.contains(word['id']);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLearned ? AppColors.success.withOpacity(0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLearned ? AppColors.success.withOpacity(0.1) : AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isLearned ? Icons.check_rounded : Icons.book_outlined,
              color: isLearned ? AppColors.success : AppColors.textGrey,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word['english'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(word['vietnamese'], style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                if (word['pronunciation'] != null)
                  Text(word['pronunciation'], style: const TextStyle(color: AppColors.primary, fontSize: 12)),
              ],
            ),
          ),
          if (isLearned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Đã học', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
