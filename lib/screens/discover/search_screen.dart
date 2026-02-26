import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../data/mock_data.dart';
import 'course_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _recentSearches = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _query = widget.initialQuery!;
    }
    // Auto-focus the search field
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) _recentSearches = _recentSearches.sublist(0, 8);
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', []);
    setState(() => _recentSearches.clear());
  }

  List<Course> get _filteredCourses {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return [...mockCourses, featuredCourse].where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q);
    }).toList();
  }

  List<Creator> get _filteredCreators {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return mockCreators.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  List<String> get _filteredTopics {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return trendingTopics.where((t) => t.toLowerCase().contains(q)).toList();
  }

  bool get _hasResults =>
      _filteredCourses.isNotEmpty ||
      _filteredCreators.isNotEmpty ||
      _filteredTopics.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Search Bar ───
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 20, 8),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search field
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.dividerColor, width: 0.5),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: (value) => setState(() => _query = value),
                        onSubmitted: (value) {
                          _addRecentSearch(value);
                        },
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search courses, topics, creators...',
                          hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textTertiary, size: 20),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  child: Icon(Icons.close_rounded, color: AppTheme.textTertiary, size: 18),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Content ───
            Expanded(
              child: _query.isEmpty ? _buildRecentSearches() : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, color: AppTheme.textTertiary.withOpacity(0.3), size: 64),
            const SizedBox(height: 16),
            Text(
              'Search for courses, topics,\nor creators',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: _clearRecentSearches,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_recentSearches.length, (index) {
            final search = _recentSearches[index];
            return GestureDetector(
              onTap: () {
                _searchController.text = search;
                setState(() => _query = search);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.dividerColor, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, color: AppTheme.textTertiary, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        search,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Icon(Icons.north_west_rounded, color: AppTheme.textTertiary, size: 16),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasResults) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: AppTheme.textTertiary.withOpacity(0.3), size: 64),
            const SizedBox(height: 16),
            Text(
              'No results for "$_query"',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Courses ───
          if (_filteredCourses.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Courses', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ..._filteredCourses.map((course) => _buildCourseResult(course)),
          ],

          // ─── Creators ───
          if (_filteredCreators.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Creators', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ..._filteredCreators.map((creator) => _buildCreatorResult(creator)),
          ],

          // ─── Topics ───
          if (_filteredTopics.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Topics', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filteredTopics.map((topic) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = topic;
                    setState(() => _query = topic);
                    _addRecentSearch(topic);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Text(
                      topic,
                      style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCourseResult(Course course) {
    return GestureDetector(
      onTap: () {
        _addRecentSearch(course.title);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerColor, width: 0.5),
        ),
        child: Row(
          children: [
            // Course thumbnail
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: course.gradientColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(course.category),
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${course.category} • ${course.duration}',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorResult(Creator creator) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: creator.avatarColors),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                creator.initial,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              creator.name,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryBlue),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'web dev':
        return Icons.web_rounded;
      case 'design':
        return Icons.design_services_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'backend':
        return Icons.dns_rounded;
      case 'ai/ml':
        return Icons.psychology_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}
