import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../state/course_filter.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onTabChange;
  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _searchQuery = '';
  bool _showResults = false;

  static const _categories = [
    {
      'label': 'Coding',
      'filter': 'Programming',
      'icon': Icons.code,
      'color': Color(0xFFDDE7FF),
    },
    {
      'label': 'Networking',
      'filter': 'Networking',
      'icon': Icons.router,
      'color': Color(0xFFD6F5E3),
    },
    {
      'label': 'Electronics',
      'filter': 'Electronics',
      'icon': Icons.memory,
      'color': Color(0xFFEEDDFF),
    },
    {
      'label': 'Databases',
      'filter': 'Others',
      'icon': Icons.storage,
      'color': Color(0xFFFFE6CC),
    },
  ];

  static const _allCourses = [
    {
      'title': 'Flutter Development',
      'subtitle': 'Beginner • 6 modules',
      'icon': Icons.flutter_dash,
      'color': Color(0xFFC9DEFF),
    },
    {
      'title': 'Python Programming',
      'subtitle': 'Beginner • 8 modules',
      'icon': Icons.code,
      'color': Color(0xFFFFE9BE),
    },
    {
      'title': 'Networking Basics',
      'subtitle': 'Intermediate • 5 modules',
      'icon': Icons.router,
      'color': Color(0xFFC9F8DD),
    },
    {
      'title': 'Electronics Basics',
      'subtitle': 'Beginner • 4 modules',
      'icon': Icons.memory,
      'color': Color(0xFFEED5FF),
    },
    {
      'title': 'Web Development',
      'subtitle': 'Advanced • 10 modules',
      'icon': Icons.laptop_mac,
      'color': Color(0xFFFFD3E9),
    },
    {
      'title': 'Hardware Skills',
      'subtitle': 'Intermediate • 5 modules',
      'icon': Icons.handyman,
      'color': Color(0xFFC4F6F1),
    },
  ];

  List<Map<String, Object>> get _searchResults {
    if (_searchQuery.trim().isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return _allCourses
        .where((c) => (c['title'] as String).toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openCategory(BuildContext context, String filter) {
    CourseFilter.category.value = filter;
    widget.onTabChange(1);
  }

  String _courseIdFromTitle(String title) {
    switch (title) {
      case 'Flutter Development':
        return 'flutter-dev';
      case 'Python Programming':
        return 'python-prog';
      case 'Networking Basics':
        return 'networking-basics';
      case 'Electronics Basics':
        return 'electronics-basics';
      case 'Web Development':
        return 'web-dev';
      case 'Hardware Skills':
        return 'hardware-skills';
      default:
        return 'flutter-dev';
    }
  }

  void _openCourse(BuildContext context, String title) {
    final id = _courseIdFromTitle(title);
    Navigator.pushNamed(context, '/course/$id');
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentTab: AppTab.home,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingHeader(
                onNotifications: () => _showNotifications(context),
                onAvatar: () => widget.onTabChange(2),
              ),
              const SizedBox(height: 18),
              _SearchBar(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (value) => setState(() {
                  _searchQuery = value;
                  _showResults = value.trim().isNotEmpty;
                }),
                onClear: () => setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _showResults = false;
                }),
              ),
              if (_showResults) ...[
                const SizedBox(height: 8),
                _SearchResults(
                  results: _searchResults,
                  onTap: (title) => _openCourse(context, title),
                ),
              ],
              if (!_showResults) ...[
                const SizedBox(height: 16),
                _LearningBanner(
                  onBrowse: () {
                    CourseFilter.category.value = null;
                    widget.onTabChange(1);
                  },
                ),
                const SizedBox(height: 20),
                _ContinueLearningCard(
                  onTap: () =>
                      Navigator.pushNamed(context, '/course/flutter-dev'),
                ),
                const SizedBox(height: 20),
                const _StreakCard(),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: 'Explore Categories',
                  actionLabel: 'See all',
                  onAction: () {
                    CourseFilter.category.value = null;
                    widget.onTabChange(1);
                  },
                ),
                const SizedBox(height: 12),
                _CategoryGrid(
                  items: _categories,
                  onTap: (filter) => _openCategory(context, filter),
                ),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: 'Recommended',
                  actionLabel: 'See all',
                  onAction: () {
                    CourseFilter.category.value = null;
                    widget.onTabChange(1);
                  },
                ),
                const SizedBox(height: 12),
                ..._allCourses.take(3).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RecommendedTile(
                          data: c,
                          onTap: () =>
                              _openCourse(context, c['title'] as String),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
      onTabSelected: (tab) => widget.onTabChange(tab.index),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting
// ---------------------------------------------------------------------------

class _GreetingHeader extends StatelessWidget {
  final VoidCallback onNotifications;
  final VoidCallback onAvatar;

  const _GreetingHeader({
    required this.onNotifications,
    required this.onAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textColor;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Learner 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ready to learn today?',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none),
        ),
        GestureDetector(
          onTap: onAvatar,
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryLight,
            child: Icon(Icons.person, color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search courses, skills...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.close), onPressed: onClear),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Map<String, Object>> results;
  final ValueChanged<String> onTap;

  const _SearchResults({required this.results, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;

    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: border),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_off, size: 20),
            SizedBox(width: 10),
            Text('No courses match your search'),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Column(
          children: [
            for (int i = 0; i < results.length; i++) ...[
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: results[i]['color'] as Color,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    results[i]['icon'] as IconData,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  results[i]['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  results[i]['subtitle'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onTap(results[i]['title'] as String),
              ),
              if (i != results.length - 1) Divider(height: 1, color: border),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Learning Banner (moved from listing screen)
// ---------------------------------------------------------------------------

class _LearningBanner extends StatelessWidget {
  final VoidCallback onBrowse;
  const _LearningBanner({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF7A0F4D), // dark berry
                  Color(0xFF9A3A18), // dark orange
                ]
              : const [
                  Color(0xFFB31974), // berry
                  Color(0xFFF26522), // bright orange
                ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explore Our',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Learning Programs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.softGold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Build skills. Learn at your own pace.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: onBrowse,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text(
                      'Browse',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10), // Almost invisible
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20), // Subtle outline
                width: 1,
              ),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Continue Learning
// ---------------------------------------------------------------------------

class _ContinueLearningCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ContinueLearningCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue Learning',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Flutter Development — Module 2 of 6',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const LinearProgressIndicator(
                value: 0.34,
                minHeight: 8,
                backgroundColor: Color(0xFFE2E8F0),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            const Text('34% completed', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Streak
// ---------------------------------------------------------------------------

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3B2416), const Color(0xFF2C1810)]
              : [const Color(0xFFFFF4E0), const Color(0xFFFFE8C7)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentColor, AppTheme.warmOrange],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Streak',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  'Keep it up — 3 days in a row',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '3',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textColor;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Categories grid
// ---------------------------------------------------------------------------

class _CategoryGrid extends StatelessWidget {
  final List<Map<String, Object>> items;
  final ValueChanged<String> onTap;

  const _CategoryGrid({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardBg = isDark ? AppTheme.darkCard : Colors.white;
            final border =
                isDark ? AppTheme.darkBorder : AppTheme.borderColor;

            return InkWell(
              onTap: () => onTap(item['filter'] as String),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: AppTheme.primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Recommended tile
// ---------------------------------------------------------------------------

class _RecommendedTile extends StatelessWidget {
  final Map<String, Object> data;
  final VoidCallback onTap;

  const _RecommendedTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: data['color'] as Color,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                data['icon'] as IconData,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['subtitle'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications bottom sheet
// ---------------------------------------------------------------------------

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  static const _mockNotifications = [
    {
      'icon': Icons.emoji_events_outlined,
      'color': Color(0xFFFFF1D6),
      'iconColor': Colors.orange,
      'title': 'Streak unlocked!',
      'body': 'You\'re on a 3-day learning streak. Keep it going!',
      'time': '2h ago',
      'unread': true,
    },
    {
      'icon': Icons.play_circle_outline,
      'color': Color(0xFFE0E7FF),
      'iconColor': AppTheme.primaryColor,
      'title': 'Continue Flutter Development',
      'body': 'You left off at Module 3: State Management.',
      'time': '5h ago',
      'unread': true,
    },
    {
      'icon': Icons.new_releases_outlined,
      'color': Color(0xFFD6F5E3),
      'iconColor': Color(0xFF059669),
      'title': 'New course: Web Development',
      'body': 'A brand-new advanced track just dropped.',
      'time': 'Yesterday',
      'unread': false,
    },
    {
      'icon': Icons.check_circle_outline,
      'color': Color(0xFFEEDDFF),
      'iconColor': Color(0xFF7C3AED),
      'title': 'Module completed',
      'body': 'You finished "UI Layouts & Widgets". Nice work!',
      'time': '2 days ago',
      'unread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textColor;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mark all as read — coming soon'),
                      ),
                    );
                  },
                  child: const Text('Mark all read'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _mockNotifications.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: border),
                itemBuilder: (context, i) {
                  final n = _mockNotifications[i];
                  final unread = n['unread'] as bool;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: n['color'] as Color,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Icon(
                        n['icon'] as IconData,
                        color: n['iconColor'] as Color,
                        size: 22,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            n['title'] as String,
                            style: TextStyle(
                              fontWeight: unread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        n['body'] as String,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    trailing: Text(
                      n['time'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening "${n['title']}"')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}