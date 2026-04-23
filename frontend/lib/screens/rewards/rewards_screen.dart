import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../learn/topic_detail_screen.dart';

class RewardsScreen extends StatefulWidget {
  /// Khi chuyển sang tab Phần thưởng, gọi tải lại để luôn thấy huy hiệu mới từ server.
  final bool isActive;
  const RewardsScreen({super.key, this.isActive = true});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _rewardData;
  List<dynamic> _learningPath = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void didUpdateWidget(RewardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  bool _isEarned(dynamic b) {
    final e = b['earned'];
    return e == true || e == 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        _loadError = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadError = 'Không tải được phần thưởng. Kéo xuống để thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _loadError != null && _rewardData == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_loadError!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            setState(() => _isLoading = true);
                            _loadData();
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
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
    final earned = badges.where((b) => _isEarned(b)).length;
    final nextLevel = ((xp ~/ 100) + 1) * 100;
    final progress = (xp % 100) / 100.0;
    final xpToNext = nextLevel - xp;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD93D), Color(0xFFFF6B6B)],
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
                    Text(
                      xpToNext > 0
                          ? 'Còn $xpToNext XP tới mốc $nextLevel XP'
                          : 'Bạn đã vượt mốc $nextLevel XP — tiếp tục học để lên mốc tiếp!',
                      style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text('$earned / ${badges.length} huy hiệu đã đạt',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    final badges = (_rewardData?['badges'] as List?) ?? [];
    final earned = badges.where((b) => _isEarned(b)).toList();
    final locked = badges.where((b) => !_isEarned(b)).toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                crossAxisCount: 3,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
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
                crossAxisCount: 3,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: locked.length,
              itemBuilder: (_, i) => _buildBadgeCard(locked[i], false),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge, bool isEarned) {
    final desc = (badge['description'] ?? '').toString().trim();
    final name = (badge['name'] ?? badge['code'] ?? 'Huy hiệu').toString().trim();
    final iconStr = (badge['icon'] ?? '🏅').toString().trim();
    final displayIcon = iconStr.isEmpty ? '🏅' : iconStr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
              Text(
                displayIcon,
                style: TextStyle(
                  fontSize: 36,
                  height: 1.0,
                  color: isEarned ? null : Colors.grey.shade600,
                ),
              ),
              if (!isEarned)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.lock_fill, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isEarned ? AppColors.textDark : AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Điều kiện',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(
                fontSize: 9,
                height: 1.25,
                color: isEarned ? AppColors.textDark.withOpacity(0.85) : AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  void _openLearningPathItem(Map<String, dynamic> item) {
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
                child: const Icon(CupertinoIcons.check_mark_circled_solid, size: 64, color: AppColors.success),
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
            color = AppColors.primary; icon = CupertinoIcons.play_circle_fill; badge = 'Tiếp tục';
            break;
          case 'review':
            color = Colors.orange; icon = CupertinoIcons.refresh_circled_solid; badge = 'Ôn tập';
            break;
          default:
            color = AppColors.success; icon = CupertinoIcons.add_circled_solid; badge = 'Mới';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => _openLearningPathItem(item),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
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
                          Text(item['message']?.toString() ?? '',
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
                    Icon(CupertinoIcons.chevron_forward, color: AppColors.textGrey, size: 14),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
