import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Interest selection
  final List<_InterestItem> _interests = [
    _InterestItem('Web Dev', Icons.web_rounded, const Color(0xFF2979FF)),
    _InterestItem('AI / ML', Icons.psychology_rounded, const Color(0xFFE040FB)),
    _InterestItem('Design', Icons.palette_rounded, const Color(0xFFFF6F61)),
    _InterestItem('Mobile', Icons.phone_android_rounded, const Color(0xFF00E5FF)),
    _InterestItem('Security', Icons.security_rounded, const Color(0xFFFFB300)),
    _InterestItem('Backend', Icons.dns_rounded, const Color(0xFF69F0AE)),
    _InterestItem('Data Science', Icons.bar_chart_rounded, const Color(0xFF7C4DFF)),
    _InterestItem('DevOps', Icons.cloud_rounded, const Color(0xFFFF8A65)),
    _InterestItem('Blockchain', Icons.link_rounded, const Color(0xFF26C6DA)),
  ];
  final Set<String> _selectedInterests = {};

  // Daily goal
  int _selectedGoal = -1; // index: 0=5min, 1=15min, 2=30min
  final List<_GoalOption> _goals = [
    _GoalOption('5 min', 'Casual', Icons.local_cafe_rounded, 'A quick daily bite'),
    _GoalOption('15 min', 'Regular', Icons.timer_rounded, 'Build a steady habit'),
    _GoalOption('30 min', 'Serious', Icons.rocket_launch_rounded, 'Accelerate learning'),
  ];

  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isSaving = true);

    try {
      final firestore = ref.read(firestoreServiceProvider);
      final goalMinutes = [5, 15, 30][_selectedGoal];

      await firestore.updateUserProfile({
        'interests': _selectedInterests.toList(),
        'dailyGoalMinutes': goalMinutes,
        'onboardingComplete': true,
      });
    } catch (_) {
      // Still mark as complete even if save fails
    }

    if (mounted) {
      setState(() => _isSaving = false);
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Page Indicator ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.primaryBlue
                            : AppTheme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ─── Pages ───
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildInterestsPage(),
                  _buildGoalPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  PAGE 1: WELCOME
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Logo
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.play_lesson_rounded, color: Colors.white, size: 44),
          ),

          const SizedBox(height: 32),

          const Text(
            'Learn Anything\nin 60 Seconds',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 12),
          Text(
            'Bite-sized video lessons from top creators',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),

          const Spacer(),

          // Feature highlights
          _buildFeature(Icons.play_circle_rounded, 'Short Video Lessons', 'Learn complex topics in under a minute'),
          const SizedBox(height: 16),
          _buildFeature(Icons.trending_up_rounded, 'Track Your Progress', 'Build streaks and unlock achievements'),
          const SizedBox(height: 16),
          _buildFeature(Icons.groups_rounded, 'Join the Community', 'Follow creators and join study groups'),

          const Spacer(),

          // Button
          _buildPrimaryButton('Get Started', _nextPage),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  PAGE 2: PICK INTERESTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildInterestsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          const Text(
            'What do you want\nto learn?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick at least 2 topics to personalize your feed',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),

          const SizedBox(height: 28),

          // Interest grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _interests.length,
              itemBuilder: (context, index) {
                final interest = _interests[index];
                final isSelected = _selectedInterests.contains(interest.name);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(interest.name);
                      } else {
                        _selectedInterests.add(interest.name);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? interest.color.withOpacity(0.12)
                          : AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? interest.color
                            : AppTheme.dividerColor,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: interest.color.withOpacity(0.15), blurRadius: 12)]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          interest.icon,
                          color: isSelected ? interest.color : AppTheme.textTertiary,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          interest.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Icon(Icons.check_circle_rounded, color: interest.color, size: 16),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Button
          _buildPrimaryButton(
            'Continue (${_selectedInterests.length} selected)',
            _selectedInterests.length >= 2 ? _nextPage : null,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  PAGE 3: SET DAILY GOAL
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          const Text(
            'Set your\ndaily goal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How much time can you dedicate each day?',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),

          const Spacer(),

          // Goal cards
          ...List.generate(_goals.length, (index) {
            final goal = _goals[index];
            final isSelected = _selectedGoal == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () => setState(() => _selectedGoal = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.08)
                        : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.dividerColor,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.15), blurRadius: 16)]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryBlue.withOpacity(0.15)
                              : AppTheme.scaffoldBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          goal.icon,
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textTertiary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  goal.duration,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryBlue.withOpacity(0.2)
                                        : AppTheme.chipBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    goal.label,
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.primaryBlue : AppTheme.textTertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal.description,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // Button
          _buildPrimaryButton(
            _isSaving ? 'Setting up...' : 'Start Learning 🚀',
            _selectedGoal >= 0 && !_isSaving ? _finishOnboarding : null,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  SHARED BUTTON
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildPrimaryButton(String label, VoidCallback? onTap) {
    final isEnabled = onTap != null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: isEnabled ? AppTheme.primaryGradient : null,
            color: isEnabled ? null : AppTheme.textTertiary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isEnabled
                ? [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.white : AppTheme.textTertiary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helper Models ───

class _InterestItem {
  final String name;
  final IconData icon;
  final Color color;
  _InterestItem(this.name, this.icon, this.color);
}

class _GoalOption {
  final String duration;
  final String label;
  final IconData icon;
  final String description;
  _GoalOption(this.duration, this.label, this.icon, this.description);
}
