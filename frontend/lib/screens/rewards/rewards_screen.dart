import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../data/mock_data.dart';
=======
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

<<<<<<< HEAD
class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
=======
class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _rewardData;
  List<dynamic> _learningPath = [];
  bool _isLoading = true;
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
<<<<<<< HEAD
=======
    _loadData();
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final xp = MockData.totalXP;
    final earned = MockData.badges.where((b) => b.isEarned).length;
    final total = MockData.badges.length;

    return Column(
      children: [
        _buildHeader(xp, earned, total),
        _buildTabs(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _BadgesTab(),
              _ProgressTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int xp, int earned, int total) {
    final nextLevelXP = 500;
    final progress = (xp / nextLevelXP).clamp(0.0, 1.0);

    return Container(
=======
  Future<void> _loadData() async {
    final token = context.read<AuthService>().token!;
    final api = ApiService(token);
    try {
      final badges = await api.getBadges();
      final path = await api.getLearningPath();
      setState(() {
        _rewardData = badges;
        _learningPath = path;
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
          : NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.card,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textGrey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Huy hiệu'),
                        Tab(text: 'Lộ trình học'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildBadgesTab(),
                  _buildLearningPathTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final xp = _rewardData?['xp'] ?? 0;
    final badges = (_rewardData?['badges'] as List?) ?? [];
    final earned = badges.where((b) => b['earned'] == true || b['earned'] == 1).length;
    final nextLevel = ((xp ~/ 100) + 1) * 100;
    final progress = (xp % 100) / 100.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD93D), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
<<<<<<< HEAD
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🏅 Phần thưởng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('⭐', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$xp XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.25),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$earned/$total huy hiệu đã đạt',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF4D8EFF),
        unselectedLabelColor: const Color(0xFF9094A6),
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        indicatorColor: const Color(0xFF4D8EFF),
        indicatorWeight: 2.5,
        tabs: const [
          Tab(text: 'Huy hiệu'),
          Tab(text: 'Lộ trình học'),
        ],
      ),
    );
  }
}

class _BadgesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final earned = MockData.badges.where((b) => b.isEarned).toList();
    final locked = MockData.badges.where((b) => !b.isEarned).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Đã đạt (${earned.length})'),
          const SizedBox(height: 10),
          _BadgesGrid(badges: earned, isEarned: true),
          const SizedBox(height: 20),
          _SectionTitle(title: 'Chưa đạt (${locked.length})'),
          const SizedBox(height: 10),
          _BadgesGrid(badges: locked, isEarned: false),
=======
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phần thưởng', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(child: Text('🏆', style: TextStyle(fontSize: 32))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$xp XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                        Text('Cần $nextLevel XP', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$earned / ${badges.length} huy hiệu đã đạt',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
        ],
      ),
    );
  }
<<<<<<< HEAD
}

class _BadgesGrid extends StatelessWidget {
  final List<BadgeModel> badges;
  final bool isEarned;

  const _BadgesGrid({required this.badges, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: badges.length,
      itemBuilder: (context, i) => _BadgeCard(badge: badges[i]),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeModel badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: badge.isEarned ? 1.0 : 0.4,
                  child: Text(badge.emoji,
                      style: const TextStyle(fontSize: 56)),
                ),
                const SizedBox(height: 10),
                Text(
                  badge.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  badge.description,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF9094A6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: badge.isEarned
                        ? const Color(0xFF6BCB77).withOpacity(0.1)
                        : const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge.isEarned ? '✅ Đã đạt' : '🔒 Chưa đạt',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: badge.isEarned
                          ? const Color(0xFF6BCB77)
                          : const Color(0xFF9094A6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: badge.isEarned ? const Color(0xFFFFF8E1) : const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badge.isEarned
                ? const Color(0xFFFFD93D)
                : const Color(0xFFE8ECF4),
            width: 1.5,
          ),
          boxShadow: badge.isEarned
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD93D).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: badge.isEarned ? 1.0 : 0.35,
              child: Text(badge.emoji,
                  style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(height: 6),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badge.isEarned
                    ? const Color(0xFF1A1D2E)
                    : const Color(0xFF9094A6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!badge.isEarned) ...[
              const SizedBox(height: 2),
              const Text('🔒', style: TextStyle(fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topics = MockData.topics;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      itemBuilder: (context, i) => _TopicProgressCard(topic: topics[i]),
    );
  }
}

class _TopicProgressCard extends StatelessWidget {
  final TopicModel topic;

  const _TopicProgressCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final isDone = topic.learnedCount == topic.totalCount;
    final hasStarted = topic.learnedCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? const Color(0xFF6BCB77).withOpacity(0.4)
              : const Color(0xFFE8ECF4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: topic.gradientColors),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(topic.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: topic.progress,
                    backgroundColor: const Color(0xFFE8ECF4),
                    valueColor: AlwaysStoppedAnimation(
                      topic.gradientColors.first,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${topic.learnedCount}/${topic.totalCount} từ',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9094A6)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF6BCB77).withOpacity(0.1)
                  : hasStarted
                      ? const Color(0xFF4D8EFF).withOpacity(0.08)
                      : const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isDone
                  ? '✅ Xong'
                  : hasStarted
                      ? '📖 Đang học'
                      : '🔒 Chưa bắt đầu',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDone
                    ? const Color(0xFF6BCB77)
                    : hasStarted
                        ? const Color(0xFF4D8EFF)
                        : const Color(0xFF9094A6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1D2E),
      ),
=======

  Widget _buildBadgesTab() {
    final badges = (_rewardData?['badges'] as List?) ?? [];
    final earned = badges.where((b) => b['earned'] == true || b['earned'] == 1).toList();
    final locked = badges.where((b) => b['earned'] != true && b['earned'] != 1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (earned.isNotEmpty) ...[
            Text('Đã đạt (${earned.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: earned.length,
              itemBuilder: (_, i) => _buildBadgeCard(earned[i], true),
            ),
            const SizedBox(height: 24),
          ],
          if (locked.isNotEmpty) ...[
            Text('Chưa đạt (${locked.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: locked.length,
              itemBuilder: (_, i) => _buildBadgeCard(locked[i], false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge, bool isEarned) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEarned ? const Color(0xFFFFF8E1) : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEarned ? const Color(0xFFFFD93D) : AppColors.border),
        boxShadow: isEarned
            ? [const BoxShadow(color: Color(0x33FFD93D), blurRadius: 8, offset: Offset(0, 3))]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(badge['icon'] ?? '🏅', style: TextStyle(fontSize: 34, color: isEarned ? null : const Color(0xFF000000))),
              if (!isEarned)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
                    child: const Icon(Icons.lock, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            badge['name'],
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold,
              color: isEarned ? AppColors.textDark : AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPathTab() {
    if (_learningPath.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
              ),
              const SizedBox(height: 20),
              const Text('Tuyệt vời!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              const Text('Bạn đang học rất tốt. Tiếp tục duy trì nhé!',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _learningPath.length,
      itemBuilder: (_, i) {
        final item = _learningPath[i];
        Color color;
        IconData icon;
        String badge;

        switch (item['type']) {
          case 'continue':
            color = AppColors.primary; icon = Icons.play_circle_rounded; badge = 'Tiếp tục';
            break;
          case 'review':
            color = Colors.orange; icon = Icons.refresh_rounded; badge = 'Ôn tập';
            break;
          default:
            color = AppColors.success; icon = Icons.add_circle_rounded; badge = 'Mới';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['message'],
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(badge, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey, size: 14),
            ],
          ),
        );
      },
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
    );
  }
}
