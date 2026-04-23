import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import '../../services/auth_service.dart';
import '../../data/mock_data.dart';
import '../topic/topic_detail_screen.dart';
=======
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../learn/topic_detail_screen.dart';
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
import '../rewards/rewards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD
  int _selectedIndex = 0;
=======
  int _currentIndex = 0;
  List<dynamic> _topics = [];
  Map<String, dynamic>? _stats;
  List<dynamic> _learningPath = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = context.read<AuthService>().token!;
    final api = ApiService(token);
    try {
      final topics = await api.getTopics();
      final stats = await api.getStats();
      final path = await api.getLearningPath();
      setState(() {
        _topics = topics;
        _stats = stats;
        _learningPath = path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFFF4F6FB),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          RewardsScreen(),
        ],
      ),
=======
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomePage(),
                const RewardsScreen(),
              ],
            ),
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
<<<<<<< HEAD
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8ECF4), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Trang chủ',
                isActive: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _NavItem(
                icon: Icons.emoji_events_rounded,
                label: 'Phần thưởng',
                isActive: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
=======
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
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Trang chủ'),
              _buildNavItem(1, Icons.emoji_events_rounded, Icons.emoji_events_outlined, 'Phần thưởng'),
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final username = user?['username'] ?? 'bạn';
    final topics = MockData.topics;
    final totalLearned = MockData.totalLearned;
    final inProgress = MockData.inProgressTopics;
    final xp = MockData.totalXP;

    return Column(
      children: [
        _buildHeader(username, totalLearned, inProgress, xp),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chủ đề từ vựng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: topics.length,
                  itemBuilder: (context, i) => _TopicCard(
                    topic: topics[i],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicDetailScreen(topic: topics[i]),
                        ),
                      );
                      setState(() {}); // refresh stats sau khi học
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String username, int learned, int inProgress, int xp) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4D8EFF), Color(0xFF1A5CCC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào, $username 👋',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Học từ vựng hôm nay!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _LogoutButton(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatChip(icon: '✅', value: '$learned', label: 'Đã học'),
                  const SizedBox(width: 10),
                  _StatChip(icon: '📖', value: '$inProgress', label: 'Đang học'),
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: '⭐',
                    value: '$xp',
                    label: 'XP',
                    valueColor: const Color(0xFFFFD93D),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color valueColor;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
=======

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
                      GestureDetector(
                        onTap: () => context.read<AuthService>().logout(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats Row
                  if (_stats != null) Row(
                    children: [
                      _buildStatChip(Icons.check_circle_rounded, '${_stats!['total_learned']}', 'Đã học', Colors.white),
                      const SizedBox(width: 12),
                      _buildStatChip(Icons.auto_stories_rounded, '${_stats!['total_learning']}', 'Đang học', Colors.white),
                      const SizedBox(width: 12),
                      _buildStatChip(Icons.star_rounded, '${_stats!['xp'] ?? 0}', 'XP', AppColors.accent),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Learning Path suggestions
          if (_learningPath.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gợi ý cho bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 12),
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

  Widget _buildStatChip(IconData icon, String value, String label, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
<<<<<<< HEAD
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 10,
              ),
            ),
=======
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
}

class _TopicCard extends StatelessWidget {
  final TopicModel topic;
  final VoidCallback onTap;

  const _TopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: topic.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: topic.gradientColors.first.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
=======

  Widget _buildSuggestionCard(Map<String, dynamic> item) {
    Color color;
    IconData icon;
    switch (item['type']) {
      case 'continue': color = AppColors.primary; icon = Icons.play_circle_rounded; break;
      case 'review': color = Colors.orange; icon = Icons.refresh_rounded; break;
      default: color = AppColors.success; icon = Icons.add_circle_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item['message'],
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
        ],
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
  ];

  Widget _buildTopicCard(Map<String, dynamic> topic, int index) {
    final colors = _topicColors[index % _topicColors.length];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
      ).then((_) => _loadData()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: colors[0].withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
<<<<<<< HEAD
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(topic.emoji, style: const TextStyle(fontSize: 20)),
              ),
=======
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                Text(
                  topic.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${topic.learnedCount}/${topic.totalCount} từ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: topic.progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 5,
                  ),
                ),
=======
                Text(topic['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${topic['word_count']} từ',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
              ],
            ),
          ],
        ),
      ),
    );
  }
}
<<<<<<< HEAD

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF4D8EFF).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? const Color(0xFF4D8EFF)
                  : const Color(0xFF9094A6),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF4D8EFF)
                    : const Color(0xFF9094A6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Đăng xuất',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          context.read<AuthService>().logout();
        }
      },
      icon: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            const Icon(Icons.logout, color: Colors.white, size: 18),
      ),
    );
  }
}
=======
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
