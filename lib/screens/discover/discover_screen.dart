import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../data/mock_data.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(child: _buildHeader(context)),

            // ─── Search Bar ───
            SliverToBoxAdapter(child: _buildSearchBar(context)),

            // ─── Trending Topics ───
            SliverToBoxAdapter(child: _buildTrendingSection(context)),

            // ─── Featured Course ───
            SliverToBoxAdapter(child: _buildFeaturedCourse(context)),

            // ─── Skill Paths Section ───
            SliverToBoxAdapter(child: _buildSkillPathsHeader(context)),

            // ─── Skill Paths Grid ───
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSkillPathCard(context, mockCourses[index]),
                  childCount: mockCourses.length,
                ),
              ),
            ),

            // ─── Popular Creators ───
            SliverToBoxAdapter(child: _buildCreatorsSection(context)),

            // ─── Bottom Padding ───
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discover',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                ),
                Positioned(
                  top: 8,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.textTertiary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search topics, skills, news...',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.mic_none_rounded, color: AppTheme.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Topics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trendingTopics.length,
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isFirst ? AppTheme.primaryGradient : null,
                    color: isFirst ? null : AppTheme.chipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFirst) ...[
                        const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        trendingTopics[index],
                        style: TextStyle(
                          color: isFirst ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isFirst ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCourse(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: featuredCourse.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            // Neural network dots decoration
            ...List.generate(20, (i) {
              final x = (i * 37 % 300).toDouble() + 20;
              final y = (i * 23 % 150).toDouble() + 10;
              return Positioned(
                left: x,
                top: y,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NEW COURSE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    featuredCourse.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    featuredCourse.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillPathsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        'Your Skill Paths',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildSkillPathCard(BuildContext context, Course course) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.dividerColor, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: course.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative pattern
                      ...List.generate(8, (i) {
                        final x = (i * 27 % 150).toDouble() + 10;
                        final y = (i * 19 % 100).toDouble() + 10;
                        return Positioned(
                          left: x,
                          top: y,
                          child: Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                      Center(
                        child: Icon(
                          _getCourseIcon(course.category),
                          color: Colors.white.withOpacity(0.15),
                          size: 60,
                        ),
                      ),
                    ],
                  ),
                ),
                // Duration badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          course.duration,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info area
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Progress
                  Text(
                    course.progressText,
                    style: TextStyle(
                      color: course.progress >= 0 ? AppTheme.primaryBlue : AppTheme.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: course.progress < 0 ? 0 : course.progress,
                            backgroundColor: AppTheme.progressBg,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              course.progress >= 0 ? AppTheme.primaryBlue : AppTheme.textTertiary,
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ),
                      if (course.progress >= 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          course.progressPercent,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCourseIcon(String category) {
    switch (category) {
      case 'Web Dev':
        return Icons.code_rounded;
      case 'Design':
        return Icons.palette_rounded;
      case 'Security':
        return Icons.security_rounded;
      case 'Backend':
        return Icons.dns_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Widget _buildCreatorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'Popular Creators',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mockCreators.length,
            itemBuilder: (context, index) {
              final creator = mockCreators[index];
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: creator.avatarColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          creator.initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      creator.name,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
