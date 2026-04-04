import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD93D), Color(0xFFFF6B6B)],
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
        ],
      ),
    );
  }
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
    );
  }
}
