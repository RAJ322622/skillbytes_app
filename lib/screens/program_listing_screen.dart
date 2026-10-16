
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgramListingScreen extends StatefulWidget {
  const ProgramListingScreen({super.key});

  @override
  State<ProgramListingScreen> createState() =>
      _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  final TextEditingController _searchController =
      TextEditingController();

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
      'learners': 00,
      'hours': 0,
      'icon': Icons.flutter_dash,
      'color': Color(0xFFC9DEFF),
    },
    {
      'title': 'Python Programming',
      'description':
          'Start coding with Python from basics to advanced.',
      'category': 'Programming',
      'level': 'Beginner',
      'rating': 4.7,
      'learners': 000,
      'hours': 0,
      'icon': Icons.code,
      'color': Color(0xFFFFE9BE),
    },
    {
      'title': 'Networking Basics',
      'description':
          'Understand computer networks, IP, and protocols.',
      'category': 'Networking',
      'level': 'Intermediate',
      'rating': 4.6,
      'learners': 00,
      'hours': 0,
      'icon': Icons.router,
      'color': Color(0xFFC9F8DD),
    },
    {
      'title': 'Electronics Basics',
      'description':
          'Explore basic electronics components and circuits.',
      'category': 'Electronics',
      'level': 'Beginner',
      'rating': 4.7,
      'learners': 00,
      'hours': 0,
      'icon': Icons.memory,
      'color': Color(0xFFEED5FF),
    },
    {
      'title': 'Hardware Skills',
      'description':
          'Learn about hardware tools, devices, and maintenance.',
      'category': 'Hardware Skills',
      'level': 'Intermediate',
      'rating': 4.5,
      'learners': 00,
      'hours': 00,
      'icon': Icons.handyman,
      'color': Color(0xFFC4F6F1),
    },
    {
      'title': 'Web Development',
      'description':
          'Build modern web applications using HTML, CSS and JS.',
      'category': 'Programming',
      'level': 'Advanced',
      'rating': 0,
      'learners': 000,
      'hours': 0,
      'icon': Icons.laptop_mac,
      'color': Color(0xFFFFD3E9),
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
      result.sort(
        (a, b) => (b['rating'] as double)
            .compareTo(a['rating'] as double),
      );
    } else if (_sort == 'Name') {
      result.sort(
        (a, b) => (a['title'] as String)
            .compareTo(b['title'] as String),
      );
    } else {
      result.sort(
        (a, b) => (b['learners'] as int)
            .compareTo(a['learners'] as int),
      );
    }

    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 850;

            return Row(
              children: [
                if (wide) const _Sidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(
                        controller: _searchController,
                        onSearch: (value) {
                          setState(() => _search = value);
                        },
                        wide: wide,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(wide ? 20 : 14),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const _LearningBanner(),
                              const SizedBox(height: 20),
                              _CategoryRow(
                                categories: categories,
                                selected: _category,
                                onSelected: (value) {
                                  setState(() => _category = value);
                                },
                                sort: _sort,
                                onSort: (value) {
                                  setState(() => _sort = value);
                                },
                                wide: wide,
                              ),
                              const SizedBox(height: 20),
                              if (filteredCourses.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Text('No programs found.'),
                                  ),
                                )
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
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
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// SIDEBAR

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE5EDFC)),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.wb_sunny,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SkillBytes',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFE5EDFC)),
            const SizedBox(height: 12),
            _navItem(Icons.home, 'Home', false),
            _navItem(Icons.grid_view, 'Programs', true),
            _navItem(Icons.bar_chart, 'Progress', false),
            _navItem(Icons.person_outline, 'Profile', false),
            _navItem(Icons.settings_outlined, 'Settings', false),
            _navItem(Icons.logout, 'Logout', false),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.orange,
                    size: 64,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Keep Learning!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your skills, your future!',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFE4EEFF)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected
              ? AppTheme.primaryColor
              : const Color(0xFF456087),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppTheme.primaryColor
                : const Color(0xFF456087),
            fontWeight:
                selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          // Connect these items to team navigation later.
        },
      ),
    );
  }
}

// TOP BAR

class _TopBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final bool wide;

  const _TopBar({
    required this.controller,
    required this.onSearch,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5EDFC)),
        ),
      ),
      child: Row(
        children: [
          if (!wide)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.school,
                color: Color(0xFF0866F5),
              ),
            ),
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: controller,
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: 'Search for courses, topics or skills...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFEDF3FF),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (wide) ...[
            const SizedBox(width: 24),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
                color: Color(0xFF102653),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const CircleAvatar(
              backgroundColor: Color(0xFFD9E8FF),
              child: Icon(
                Icons.person,
                color: Color(0xFF0866F5),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Hi, Learners!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}

// LEARNING BANNER

class _LearningBanner extends StatelessWidget {
  const _LearningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF1FF),
            Color(0xFFD8E7FF),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 500;

          final textContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Our',
                style: TextStyle(
                  fontSize: compact ? 24 : 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF102653),
                ),
              ),
              Text(
                'Learning Programs',
                style: TextStyle(
                  fontSize: compact ? 24 : 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0866F5),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Build skills. Learn at your own pace. Grow your career.',
                style: TextStyle(color: Color(0xFF456087)),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Start Learning'),
              ),
            ],
          );

          if (compact) {
            return textContent;
          }

          return Row(
            children: [
              Expanded(child: textContent),
              const SizedBox(width: 12),
              const Icon(
                Icons.school,
                size: 90,
                color: Color(0xFF397DF0),
              ),
            ],
          );
        },
      ),
    );
  }
}

// CATEGORIES AND SORTING

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
                  selectedColor: const Color(0xFF0866F5),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: active
                        ? Colors.white
                        : const Color(0xFF304A75),
                    fontWeight: FontWeight.w600,
                  ),
                  side: const BorderSide(
                    color: Color(0xFFE0E9FC),
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
        DropdownMenuItem(
          value: 'Popular',
          child: Text('Sort: Popular'),
        ),
        DropdownMenuItem(
          value: 'Rating',
          child: Text('Sort: Rating'),
        ),
        DropdownMenuItem(
          value: 'Name',
          child: Text('Sort: Name'),
        ),
      ],
      onChanged: (value) {
        if (value != null) onSort(value);
      },
    );
  }
}

// PROGRAM CARD

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final level = course['level'] as String;

    final Color levelColor = level == 'Beginner'
        ? const Color(0xFFD9E8FF)
        : level == 'Intermediate'
            ? const Color(0xFFD0F8D5)
            : const Color(0xFFFFD9E8);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3ECFC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C174B91),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: course['color'] as Color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                course['icon'] as IconData,
                size: 64,
                color: const Color(0xFF0866F5),
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
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  course['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102653),
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
                      color: Color(0xFF456087),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 17,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 3),
                    Text('${course['rating']}'),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${((course['learners'] as int) / 1000).toStringAsFixed(1)}K learners',
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
                      size: 17,
                      color: Color(0xFF456087),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${course['hours']} hours',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selected ${course['title']}. '
                                'Program Details navigation will be '
                                'connected next.',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Enroll',
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
