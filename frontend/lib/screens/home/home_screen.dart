import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/quiz_wrong_words_store.dart';
import '../learn/topic_detail_screen.dart';
import '../learn/wrong_words_topics_screen.dart';
import '../rewards/rewards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<dynamic> _topics = [];
  Map<String, dynamic>? _stats;
  List<dynamic> _learningPath = [];
  List<WrongTopicSummary> _wrongTopicSummaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthService>();
    final token = auth.token!;
    final api = ApiService(token);
    try {
      final topics = await api.getTopics();
      final stats = await api.getStats();
      final path = await api.getLearningPath();
      List<WrongTopicSummary> wrongSum = [];
      final uid = auth.user?['id'];
      if (uid is int) {
        wrongSum = await QuizWrongWordsStore.summariesForTopics(uid, topics);
      }
      setState(() {
        _topics = topics;
        _stats = stats;
        _learningPath = path;
        _wrongTopicSummaries = wrongSum;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomePage(),
                RewardsScreen(isActive: _currentIndex == 1),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, CupertinoIcons.house_fill, CupertinoIcons.house, 'Trang chủ'),
              _buildNavItem(1, CupertinoIcons.star_circle_fill, CupertinoIcons.star, 'Phần thưởng'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon,
                color: isActive ? AppColors.primary : AppColors.textGrey, size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.primary : AppColors.textGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    final user = context.watch<AuthService>().user;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Xin chào, ${user?['username'] ?? 'bạn'} 👋',
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Học từ vựng hôm nay!',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Material(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context.read<AuthService>().logout(),
                          borderRadius: BorderRadius.circular(12),
                          splashColor: Colors.white.withOpacity(0.35),
                          highlightColor: Colors.white.withOpacity(0.18),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(CupertinoIcons.square_arrow_right, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats Row (chạm từng ô để xem chi tiết theo chủ đề)
                  if (_stats != null) ...[
                    Row(
                      children: [
                        _buildStatChip(
                          CupertinoIcons.check_mark_circled_solid,
                          '${_stats!['total_learned']}',
                          'Đã học',
                          Colors.white,
                          onTap: _showLearnedBreakdown,
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          CupertinoIcons.book_fill,
                          '${_stats!['total_learning']}',
                          'Đang học',
                          Colors.white,
                          onTap: _showInProgressBreakdown,
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          CupertinoIcons.star_fill,
                          '${_stats!['xp'] ?? 0}',
                          'XP',
                          AppColors.accent,
                          onTap: _showXpInfo,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Chạm ô Đã học / Đang học để xem từng chủ đề',
                      style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Gợi ý: ôn từ sai + lộ trình
          if (_learningPath.isNotEmpty || _wrongTopicSummaries.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gợi ý cho bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    if (_wrongTopicSummaries.isNotEmpty) _buildWrongWordsHomeCard(),
                    ..._learningPath.take(2).map((item) => _buildSuggestionCard(item)),
                  ],
                ),
              ),
            ),
          ],

          // Topics
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chủ đề từ vựng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text('${_topics.length} chủ đề', style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildTopicCard(_topics[i], i),
                childCount: _topics.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String value,
    String label,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTopicFromStat(Map<String, dynamic> t) {
    final rawId = t['id'];
    if (rawId == null) return;
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopicDetailScreen(topic: {'id': id, 'name': t['name']?.toString() ?? ''}),
      ),
    ).then((_) => _loadData());
  }

  void _showLearnedBreakdown() {
    if (_stats == null) return;
    final list = (_stats!['learned_by_topic'] as List?) ?? [];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Đã học — theo chủ đề',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(CupertinoIcons.xmark_circle_fill),
                        color: AppColors.textGrey,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Số từ đã đánh dấu «đã thuộc» trong mỗi chủ đề.',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: list.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Chưa có từ nào đã học.', style: TextStyle(color: AppColors.textGrey)),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final t = Map<String, dynamic>.from(list[i] as Map);
                            final lw = t['learned_words'] ?? 0;
                            final tw = t['total_words'] ?? 0;
                            final pct = t['percent'] ?? 0;
                            return ListTile(
                              title: Text(t['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('$lw/$tw từ đã thuộc · $pct%'),
                              trailing: const Icon(CupertinoIcons.chevron_right, color: AppColors.textGrey),
                              onTap: () {
                                Navigator.pop(ctx);
                                _openTopicFromStat(t);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInProgressBreakdown() {
    if (_stats == null) return;
    final list = (_stats!['in_progress_topics'] as List?) ?? [];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.45,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Đang học — chủ đề chưa xong',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(CupertinoIcons.xmark_circle_fill),
                        color: AppColors.textGrey,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Đã bắt đầu nhưng chưa học hết từ trong chủ đề.',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: list.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Không có chủ đề đang dở.\nHọc thêm từ hoặc mở một chủ đề mới nhé!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final t = Map<String, dynamic>.from(list[i] as Map);
                            final lw = t['learned_words'] ?? 0;
                            final tw = t['total_words'] ?? 0;
                            final pct = t['percent'] ?? 0;
                            return ListTile(
                              title: Text(t['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('Tiến độ: $lw/$tw từ · $pct%'),
                              trailing: const Icon(CupertinoIcons.chevron_right, color: AppColors.textGrey),
                              onTap: () {
                                Navigator.pop(ctx);
                                _openTopicFromStat(t);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showXpInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Điểm XP'),
        content: const Text(
          'Bạn nhận XP khi:\n\n'
          '• Đánh dấu đã thuộc một từ (+10 XP)\n'
          '• Hoàn thành cả chủ đề (+50 XP)\n'
          '• Làm bài quiz (tùy điểm số câu đúng)',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _openSuggestionTopic(Map<String, dynamic> item) {
    final rawId = item['topic_id'];
    if (rawId == null) return;
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) return;
    final name = item['topic_name']?.toString() ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopicDetailScreen(topic: {'id': id, 'name': name}),
      ),
    ).then((_) => _loadData());
  }

  int get _totalWrongWordsHome =>
      _wrongTopicSummaries.fold<int>(0, (s, e) => s + e.wrongCount);

  Widget _buildWrongWordsHomeCard() {
    final total = _totalWrongWordsHome;
    final nTopics = _wrongTopicSummaries.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.deepOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WrongWordsTopicsScreen(items: _wrongTopicSummaries),
              ),
            ).then((_) => _loadData());
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepOrange.withOpacity(0.28)),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flag_rounded, color: Colors.deepOrange, size: 26),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 1)),
                          ],
                        ),
                        child: Text(
                          '$total',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ôn từ đã sai',
                        style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$total từ trong $nTopics chủ đề — chạm để chọn chủ đề',
                        style: TextStyle(color: AppColors.textGrey.withOpacity(0.95), fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_forward, color: Colors.deepOrange, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> item) {
    Color color;
    IconData icon;
    switch (item['type']) {
      case 'continue': color = AppColors.primary; icon = CupertinoIcons.play_circle_fill; break;
      case 'review': color = Colors.orange; icon = CupertinoIcons.refresh_circled_solid; break;
      default: color = AppColors.success; icon = CupertinoIcons.add_circled_solid;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _openSuggestionTopic(item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item['message']?.toString() ?? '',
                      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                Icon(CupertinoIcons.chevron_forward, color: color, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final _topicColors = [
    [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
    [const Color(0xFF4D8EFF), const Color(0xFF6B5BFF)],
    [const Color(0xFF6BCB77), const Color(0xFF4D96FF)],
    [const Color(0xFFFFD93D), const Color(0xFFFF6B6B)],
    [const Color(0xFFFF6B9D), const Color(0xFFC44DFF)],
    [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
    [const Color(0xFF11998E), const Color(0xFF38EF7D)],
    [const Color(0xFFF7971E), const Color(0xFFFFD200)],
    [const Color(0xFF667EEA), const Color(0xFF764BA2)],
    [const Color(0xFFFA709A), const Color(0xFFFEE140)],
  ];

  /// Emoji theo chủ đề — không dùng font Material/Cupertino (tránh ô vuông khi font icon lỗi).
  String _topicEmojiFor(Map<String, dynamic> topic) {
    final raw = topic['id'];
    final tid = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    if (tid != null) {
      switch (tid) {
        case 1:
          return '🐾';
        case 2:
          return '🎨';
        case 3:
          return '👨‍👩‍👧';
        case 4:
          return '🍎';
        case 5:
          return '🔢';
        case 6:
          return '✈️';
        case 7:
          return '⚽';
        case 8:
          return '💻';
        case 9:
          return '☁️';
        case 10:
          return '🧍';
      }
    }
    final name = (topic['name'] ?? '').toString().toLowerCase();
    if (name.contains('động') || name.contains('animal')) return '🐾';
    if (name.contains('màu') || name.contains('color')) return '🎨';
    if (name.contains('gia đình') || name.contains('family')) return '👨‍👩‍👧';
    if (name.contains('thực') || name.contains('food') || name.contains('ăn')) return '🍎';
    if (name.contains('số') || name.contains('number') || name.contains('đếm')) return '🔢';
    if (name.contains('du lịch') || name.contains('travel')) return '✈️';
    if (name.contains('thể thao') || name.contains('sport')) return '⚽';
    if (name.contains('công nghệ') || name.contains('tech')) return '💻';
    if (name.contains('thời tiết') || name.contains('weather')) return '☁️';
    if (name.contains('cơ thể') || name.contains('body')) return '🧍';
    return '📚';
  }

  Widget _buildTopicCard(dynamic rawTopic, int index) {
    final topic = Map<String, dynamic>.from(rawTopic as Map);
    final name = topic['name']?.toString().trim();
    final title = (name != null && name.isNotEmpty) ? name : 'Chủ đề ${topic['id'] ?? index + 1}';
    final wc = topic['word_count'];
    final wordCount = wc is int ? wc : int.tryParse(wc?.toString() ?? '') ?? 0;
    final colors = _topicColors[index % _topicColors.length];
    const borderRadius = BorderRadius.all(Radius.circular(20));

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(color: colors[0].withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
          ).then((_) => _loadData()),
          borderRadius: borderRadius,
          splashColor: Colors.white.withOpacity(0.32),
          highlightColor: Colors.white.withOpacity(0.14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                    child: Text(_topicEmojiFor(topic), style: const TextStyle(fontSize: 22, height: 1)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('$wordCount từ',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
