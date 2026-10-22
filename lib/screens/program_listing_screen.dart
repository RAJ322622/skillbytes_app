import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../state/course_filter.dart';
import '../data/course_repository.dart';
import '../models/course.dart';

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

  late Future<List<Course>> _coursesFuture;

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
    _coursesFuture = CourseRepository.instance.fetchCourses();

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

  List<Course> _applyFilters(List<Course> all) {
    final result = all.where((c) {
      final matchesSearch =
          c.title.toLowerCase().contains(_search.toLowerCase()) ||
          c.description.toLowerCase().contains(_search.toLowerCase());

      final matchesCategory = _category == 'All' ||
          c.category == _category ||
          (_category == 'Others' &&
              !categories
                  .where((x) => x != 'All' && x != 'Others')
                  .contains(c.category));

      return matchesSearch && matchesCategory;
    }).toList();

    if (_sort == 'Rating') {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sort == 'Name') {
      result.sort((a, b) => a.title.compareTo(b.title));
    } else {
      result.sort((a, b) => b.learners.compareTo(a.learners));
    }

    return result;
  }

  void _retry() {
    setState(() {
      _coursesFuture = CourseRepository.instance.fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentTab: AppTab.courses,
      body: Column(
        children: [
          _TopBar(
            controller: _searchController,
            onSearch: (v) => setState(() => _search = v),
          ),
          Expanded(
            child: FutureBuilder<List<Course>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                // =====================================================
                // LOADING STATE
                // TODO(Muhammad): Replace with polished loading UI
                // =====================================================
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Loading courses...'),
                      ],
                    ),
                  );
                }

                // =====================================================
                // ERROR STATE
                // TODO(Muhammad): Replace with polished error UI
                // =====================================================
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text('Failed to load courses'),
                          const SizedBox(height: 4),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _retry,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // =====================================================
                // SUCCESS STATE
                // =====================================================
                final all = snapshot.data ?? [];
                final filtered = _applyFilters(all);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 850;
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(wide ? 20 : 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            onSelected: (v) =>
                                setState(() => _category = v),
                            sort: _sort,
                            onSort: (v) => setState(() => _sort = v),
                            wide: wide,
                          ),
                          const SizedBox(height: 20),
                          if (filtered.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text('No courses found.'),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
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
                              itemBuilder: (context, i) {
                                return _CourseCard(
                                  course: filtered[i],
                                  onOpen: () => Navigator.pushNamed(
                                    context,
                                    '/course/${filtered[i].id}',
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
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

  const _TopBar({required this.controller, required this.onSearch});

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
            children: categories.map((c) {
              final active = selected == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: active,
                  onSelected: (_) => onSelected(c),
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
      onChanged: (v) {
        if (v != null) onSort(v);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Course card
// ---------------------------------------------------------------------------

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onOpen;

  const _CourseCard({required this.course, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textColor;

    final level = course.level;
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
                color: course.color,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                course.icon,
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
                  course.title,
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
                    course.description,
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
                      '${course.rating}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${(course.learners / 1000).toStringAsFixed(1)}K',
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
                        '${course.hours}h',
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