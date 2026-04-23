import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/quiz_wrong_words_store.dart';
import 'topic_detail_screen.dart';

/// Danh sách chủ đề còn từ sai — mở từng chủ đề để ôn «Chỉ từ sai».
class WrongWordsTopicsScreen extends StatefulWidget {
  final List<WrongTopicSummary> items;
  const WrongWordsTopicsScreen({super.key, required this.items});

  @override
  State<WrongWordsTopicsScreen> createState() => _WrongWordsTopicsScreenState();
}

class _WrongWordsTopicsScreenState extends State<WrongWordsTopicsScreen> {
  late List<WrongTopicSummary> _items;

  @override
  void initState() {
    super.initState();
    _items = List<WrongTopicSummary>.from(widget.items);
  }

  int get _totalWords => _items.fold<int>(0, (s, e) => s + e.wrongCount);

  Future<void> _reloadSummaries() async {
    final uid = context.read<AuthService>().user?['id'];
    if (uid is! int) return;
    final topicMaps = _items.map((e) => {'id': e.topicId, 'name': e.topicName}).toList();
    final fresh = await QuizWrongWordsStore.summariesForTopics(uid, topicMaps);
    if (!mounted) return;
    if (fresh.isEmpty) {
      Navigator.pop(context);
      return;
    }
    setState(() => _items = fresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ôn từ đã sai'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_totalWords từ · ${_items.length} chủ đề',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chạm chủ đề để mở flashcard / quiz chỉ các từ đó.',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Chọn chủ đề', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 10),
          ..._items.map((e) => _tile(context, e)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, WrongTopicSummary e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TopicDetailScreen(topic: {'id': e.topicId, 'name': e.topicName}),
              ),
            );
            await _reloadSummaries();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${e.wrongCount}',
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.topicName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${e.wrongCount} từ cần ôn',
                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_forward, color: AppColors.textGrey, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
