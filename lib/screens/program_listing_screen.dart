import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../state/course_filter.dart';

class ProgramListingScreen extends StatefulWidget {
  final ValueChanged<int> onTabChange;
  const ProgramListingScreen({super.key, required this.onTabChange});

  @override
  State<ProgramListingScreen> createState() =>
      _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';
  String _category = 'All';
  String _sort = 'Popular';

  final List<Map<String, dynamic>> courses = [
    {
      'title': 'Flutter Development',
      'description':
          'Learn to build beautiful mobile apps with Flutter.',
      'category': 'Programming',
      'level': 'Beginner',
      'rating': 4.8,
      'learners': 12000,
      'hours': 6,
      'icon': Icons.flutter_dash,
      'color': const Color(0xFFC9DEFF),
    },
    {
      'title': 'Python Programming',
      'description':
          'Start coding with Python from basics to advanced.',
      'category': 'Programming',
      'level': 'Beginner',
      'rating': 4.7,
      'learners': 15000,
      'hours': 8,
      'icon': Icons.code,
      'color': const Color(0xFFFFE9BE),
    },
    {
      'title': 'Networking Basics',
      'description':
          'Understand computer networks, IP, and protocols.',
      'category': 'Networking',
      'level': 'Intermediate',
      'rating': 4.6,
      'learners': 8500,
      'hours': 5,
      'icon': Icons.router,
      'color': const Color(0xFFC9F8DD),
    },
    {
      'title': 'Electronics Basics',
      'description':
          'Explore basic electronics components and circuits.',
      'category': 'Electronics',
      'level': 'Beginner',
      'rating': 4.7,
      'learners': 6200,
      'hours': 4,
      'icon': Icons.memory,
      'color': const Color(0xFFEED5FF),
    },
    {
      'title': 'Hardware Skills',
      'description':
          'Learn about hardware tools, devices, and maintenance.',
      'category': 'Hardware Skills',
      'level': 'Intermediate',
      'rating': 4.5,
      'learners': 4300,
      'hours': 5,
      'icon': Icons.handyman,
      'color': const Color(0xFFC4F6F1),
    },
    {
      'title': 'Web Development',
      'description':
          'Build modern web applications using HTML, CSS and JS.',
      'category': 'Programming',
      'level': 'Advanced',
      'rating': 4.9,
      'learners': 21000,
      'hours': 10,
      'icon': Icons.laptop_mac,
      'color': const Color(0xFFFFD3E9),
    },
  ];

  final List<String> categories = [
    'All',
    'Programming',
    'Networking',
    'Electronics',
    'Hardware Skills',
    'Others',
  ];

  @override
  void initState() {
    super.initState();

    final initial = CourseFilter.category.value;
    if (initial != null && categories.contains(initial)) {
      _category = initial;
    }

    CourseFilter.category.addListener(_onExternalFilter);
  }

  void _onExternalFilter() {
    final value = CourseFilter.category.value;
    final target =
        (value != null && categories.contains(value)) ? value : 'All';
    if (target != _category) {
      setState(() => _category = target);
    }
  }

  @override
  void dispose() {
    CourseFilter.category.removeListener(_onExternalFilter);
    _searchController.dispose();
    super.dispose();
  }

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  List<Map<String, dynamic>> get filteredCourses {
    final result = courses.where((course) {
      final title = (course['title'] as String).toLowerCase();
      final description =
          (course['description'] as String).toLowerCase();
      final category = course['category'] as String;

      final matchesSearch =
          title.contains(_search.toLowerCase()) ||
          description.contains(_search.toLowerCase());

      final matchesCategory = _category == 'All' ||
          category == _category ||
          (_category == 'Others' &&
              !categories
                  .where((c) => c != 'All' && c != 'Others')
                  .contains(category));

      return matchesSearch && matchesCategory;
    }).toList();

    if (_sort == 'Rating') {
      result.sort((a, b) => _num(b['rating']).compareTo(_num(a['rating'])));
    } else if (_sort == 'Name') {
      result.sort(
        (a, b) => (a['title'] as String).compareTo(b['title'] as String),
      );
    } else {
      result.sort(
        (a, b) =>
            _num(b['learners']).compareTo(_num(a['learners'])),
      );
    }

    return result;
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

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentTab: AppTab.courses,
      body: Column(
        children: [
          _TopBar(
            controller: _searchController,
            onSearch: (value) => setState(() => _search = value),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 850;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(wide ? 20 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page title
                      const Text(
                        'All Courses',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CategoryRow(
                        categories: categories,
                        selected: _category,
                        onSelected: (value) =>
                            setState(() => _category = value),
                        sort: _sort,
                        onSort: (value) =>
                            setState(() => _sort = value),
                        wide: wide,
                      ),
                      const SizedBox(height: 20),
                      if (filteredCourses.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No courses found.'),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredCourses.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: wide
                                ? (constraints.maxWidth >= 1250
                                    ? 3
                                    : 2)
                                : 1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            mainAxisExtent: wide ? 242 : 250,
                          ),
                          itemBuilder: (context, index) {
                            return _CourseCard(
                              course: filteredCourses[index],
                              onOpen: () {
                                final id = _courseIdFromTitle(
                                    filteredCourses[index]['title']
                                        as String);
                                Navigator.pushNamed(
                                    context, '/course/$id');
                              },
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      onTabSelected: (tab) => widget.onTabChange(tab.index),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  const _TopBar({
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          // Brand logo (mobile)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: controller,
                onChanged: onSearch,
                decoration: const InputDecoration(
                  hintText: 'Search courses...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Categories and sorting
// ---------------------------------------------------------------------------

class _CategoryRow extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  final String sort;
  final ValueChanged<String> onSort;
  final bool wide;

  const _CategoryRow({
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.sort,
    required this.onSort,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final active = selected == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: active,
                  onSelected: (_) => onSelected(category),
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(
                    color: active
                        ? Colors.white
                        : AppTheme.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (!wide) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _sortDropdown(),
          ),
        ] else
          Align(
            alignment: Alignment.centerRight,
            child: _sortDropdown(),
          ),
      ],
    );
  }

  Widget _sortDropdown() {
    return DropdownButton<String>(
      value: sort,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: 'Popular', child: Text('Sort: Popular')),
        DropdownMenuItem(value: 'Rating', child: Text('Sort: Rating')),
        DropdownMenuItem(value: 'Name', child: Text('Sort: Name')),
      ],
      onChanged: (value) {
        if (value != null) onSort(value);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Course card
// ---------------------------------------------------------------------------

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onOpen;

  const _CourseCard({required this.course, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textColor;

    final level = course['level'] as String;
    final levelColor = level == 'Beginner'
        ? const Color(0xFFD9E8FF)
        : level == 'Intermediate'
            ? const Color(0xFFD0F8D5)
            : const Color(0xFFFFD9E8);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: course['color'] as Color,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                course['icon'] as IconData,
                size: 56,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  course['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Text(
                    course['description'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 3),
                    Text(
                      '${course['rating']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${((course['learners'] as int) / 1000).toStringAsFixed(1)}K',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${course['hours']}h',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onOpen,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}