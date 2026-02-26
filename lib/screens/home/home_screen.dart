import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../data/mock_data.dart';
import '../../providers/interaction_provider.dart';
import '../../widgets/video_player_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _activeTab = 0; // 0 = For You, 1 = My Courses

  @override
  void initState() {
    super.initState();
    // Initialize like counts from mock data
    Future.microtask(() {
      final likesNotifier = ref.read(likesProvider.notifier);
      for (final lesson in mockVideoLessons) {
        likesNotifier.initCount(lesson.id, lesson.likes);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Watch all interaction states
    ref.watch(likesProvider);
    ref.watch(savedProvider);
    ref.watch(followsProvider);

    return Stack(
      children: [
        // ─── Video Feed ───
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: mockVideoLessons.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            final lesson = mockVideoLessons[index];
            return _buildVideoCard(lesson);
          },
        ),

        // ─── Top Bar ───
        _buildTopBar(),
      ],
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Tabs
            GestureDetector(
              onTap: () => setState(() => _activeTab = 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'For You',
                    style: TextStyle(
                      color: _activeTab == 0 ? Colors.white : AppTheme.textTertiary,
                      fontWeight: _activeTab == 0 ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: _activeTab == 0 ? 30 : 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 28),
            GestureDetector(
              onTap: () => setState(() => _activeTab = 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Courses',
                    style: TextStyle(
                      color: _activeTab == 1 ? Colors.white : AppTheme.textTertiary,
                      fontWeight: _activeTab == 1 ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: _activeTab == 1 ? 30 : 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Search button
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(VideoLesson lesson) {
    final isActive = mockVideoLessons.indexOf(lesson) == _currentPage;
    return Stack(
      children: [
        // ─── Video Background ───
        Positioned.fill(
          child: LessonVideoPlayer(
            videoUrl: lesson.videoUrl,
            fallbackGradient: lesson.gradientColors,
            isActive: isActive,
          ),
        ),

        // ─── Decorative Background ───
        _buildBackgroundDecor(lesson),

        // ─── Bottom Gradient Overlay ───
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color(0xDD000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // ─── Right Side Actions ───
        Positioned(
          right: 12,
          bottom: 200,
          child: _buildActionButtons(lesson),
        ),

        // ─── Bottom Content ───
        Positioned(
          bottom: 80,
          left: 16,
          right: 70,
          child: _buildBottomContent(lesson),
        ),

        // ─── Lesson Progress Bar ───
        Positioned(
          bottom: 70,
          left: 16,
          right: 16,
          child: _buildProgressBar(lesson),
        ),
      ],
    );
  }

  Widget _buildBackgroundDecor(VideoLesson lesson) {
    return CustomPaint(
      size: Size.infinite,
      painter: _NetworkPainter(
        color: lesson.gradientColors.last.withOpacity(0.3),
      ),
    );
  }

  Widget _buildActionButtons(VideoLesson lesson) {
    final likesNotifier = ref.read(likesProvider.notifier);
    final savedNotifier = ref.read(savedProvider.notifier);
    final isLiked = likesNotifier.isLiked(lesson.id);
    final likeCount = likesNotifier.getCount(lesson.id);
    final isSaved = savedNotifier.isSaved(lesson.id);

    return Column(
      children: [
        // ─── Like ───
        GestureDetector(
          onTap: () => ref.read(likesProvider.notifier).toggle(lesson.id),
          child: Column(
            children: [
              Icon(
                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isLiked ? const Color(0xFFFF4757) : Colors.white.withOpacity(0.9),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                _formatNumber(likeCount),
                style: TextStyle(
                  color: isLiked ? const Color(0xFFFF4757) : Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ─── Comments ───
        _buildActionButton(
          icon: Icons.chat_bubble_rounded,
          label: lesson.comments.toString(),
          color: Colors.white,
        ),
        const SizedBox(height: 20),

        // ─── Save / Bookmark ───
        GestureDetector(
          onTap: () => ref.read(savedProvider.notifier).toggle(lesson.id),
          child: Column(
            children: [
              Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isSaved ? AppTheme.primaryBlue : Colors.white.withOpacity(0.9),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                isSaved ? 'Saved' : 'Save',
                style: TextStyle(
                  color: isSaved ? AppTheme.primaryBlue : Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ─── Share ───
        _buildActionButton(
          icon: Icons.share_rounded,
          label: 'Share',
          color: Colors.white,
        ),
        const SizedBox(height: 20),

        // ─── Creator avatar ───
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6F61), Color(0xFFE91E63)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              lesson.creatorAvatar.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.9), size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildBottomContent(VideoLesson lesson) {
    final followsNotifier = ref.read(followsProvider.notifier);
    final isFollowing = followsNotifier.isFollowing(lesson.creatorName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator info
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6F61), Color(0xFFE91E63)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  lesson.creatorAvatar.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              lesson.creatorName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => ref.read(followsProvider.notifier).toggle(lesson.creatorName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isFollowing ? AppTheme.primaryBlue : Colors.transparent,
                  border: Border.all(
                    color: isFollowing ? AppTheme.primaryBlue : Colors.white.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: isFollowing ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Title
        Text(
          lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        // Description
        Text(
          lesson.description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 10),

        // Hashtags
        Wrap(
          spacing: 8,
          children: lesson.hashtags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressBar(VideoLesson lesson) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lesson Progress',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '${lesson.currentTime} / ${lesson.duration}',
                style: const TextStyle(color: Color(0xFF2979FF), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: lesson.progress,
              backgroundColor: AppTheme.progressBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Network Pattern Painter (decorative)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _NetworkPainter extends CustomPainter {
  final Color color;
  _NetworkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistency
    final points = <Offset>[];

    // Generate random points
    for (int i = 0; i < 40; i++) {
      points.add(Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * 0.6 + size.height * 0.1,
      ));
    }

    // Draw connections
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance < 120) {
          final opacity = (1 - distance / 120) * 0.3;
          paint.color = color.withOpacity(opacity);
          canvas.drawLine(points[i], points[j], paint);
        }
      }
    }

    // Draw dots
    for (final point in points) {
      canvas.drawCircle(point, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
