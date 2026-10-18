import 'package:flutter/material.dart';
import '../data/course_repository.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Course _course;

  @override
  void initState() {
    super.initState();
    _course = CourseRepository.instance.byId(widget.courseId) ??
        CourseRepository.instance.all.first;
  }

  bool get _isEnrolled =>
      _course.modules.any((m) => m.status != ModuleStatus.locked);

  bool get _hasProgress => _course.modules
      .any((m) => m.status == ModuleStatus.completed);

  double get _progress {
    if (_course.modules.isEmpty) return 0;
    final done = _course.modules
        .where((m) => m.status == ModuleStatus.completed)
        .length;
    return done / _course.modules.length;
  }

  CourseModule? get _currentModule {
    for (final m in _course.modules) {
      if (m.status == ModuleStatus.inProgress) return m;
    }
    return null;
  }

  void _refresh() {
    setState(() {
      _course = CourseRepository.instance.byId(widget.courseId)!;
    });
  }

  void _onEnroll() {
    CourseRepository.instance.enroll(_course.id);
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enrolled in ${_course.title}!')),
    );
  }

  void _onContinue() {
    final m = _currentModule;
    if (m == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resuming "${m.title}"...')),
    );
  }

  void _onModuleTap(CourseModule m) {
    switch (m.status) {
      case ModuleStatus.completed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reviewing "${m.title}"')),
        );
        break;
      case ModuleStatus.inProgress:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resuming "${m.title}"...')),
        );
        break;
      case ModuleStatus.locked:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete previous modules first'),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textColor;
    final bg = isDark ? AppTheme.darkBackground : AppTheme.backgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // Banner + floating back button
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: isDark
                      ? AppTheme.darkBackground.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: _course.color,
                  child: Center(
                    child: Icon(
                      _course.icon,
                      size: 96,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),

            // Body
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + badge
                    Text(
                      _course.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _badge(_course.category, AppTheme.primaryLight,
                            AppTheme.primaryColor),
                        _badge(
                          _course.level,
                          _levelColor(_course.level),
                          Colors.black87,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Metadata row
                    _metaRow(context),
                    const SizedBox(height: 20),

                    // Progress (if enrolled)
                    if (_isEnrolled) ...[
                      _progressBlock(context),
                      const SizedBox(height: 20),
                    ],

                    // Overview
                    _sectionHeader('Overview', textColor),
                    const SizedBox(height: 8),
                    Text(
                      _course.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // What you'll learn
                    _sectionHeader("What you'll learn", textColor),
                    const SizedBox(height: 10),
                    ..._course.outcomes.map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: AppTheme.accentColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                o,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Modules
                    _sectionHeader('Course Modules', textColor),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Modules list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final m = _course.modules[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _ModuleRow(
                      index: i + 1,
                      module: m,
                      onTap: () => _onModuleTap(m),
                    ),
                  );
                },
                childCount: _course.modules.length,
              ),
            ),

            // Bottom padding so the sticky button doesn't overlap content
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),

      // Sticky action button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isEnrolled ? _onContinue : _onEnroll,
              child: Text(
                _isEnrolled ? 'Continue Learning' : 'Enroll Now',
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Sub-builders ----------

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _metaRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        _meta(Icons.star, '${_course.rating}', Colors.orange),
        const SizedBox(width: 16),
        _meta(Icons.people_outline,
            '${(_course.learners / 1000).toStringAsFixed(1)}K', null),
        const SizedBox(width: 16),
        _meta(Icons.access_time, '${_course.hours}h', null),
        const SizedBox(width: 16),
        _meta(Icons.menu_book_outlined,
            '${_course.modules.length} modules', null),
      ],
    );
  }

  Widget _meta(IconData icon, String text, Color? iconColor) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? AppTheme.secondaryTextColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _progressBlock(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 6),
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${(_progress * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? AppTheme.darkBorder
                  : AppTheme.borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFFD9E8FF);
      case 'intermediate':
        return const Color(0xFFD0F8D5);
      default:
        return const Color(0xFFFFD9E8);
    }
  }
}

// ---------------------------------------------------------------------------

class _ModuleRow extends StatelessWidget {
  final int index;
  final CourseModule module;
  final VoidCallback onTap;

  const _ModuleRow({
    required this.index,
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textColor;

    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (module.status) {
      case ModuleStatus.completed:
        icon = Icons.check_circle;
        iconColor = AppTheme.accentColor;
        iconBg = const Color(0xFFD1FAE5);
        break;
      case ModuleStatus.inProgress:
        icon = Icons.play_circle_fill;
        iconColor = AppTheme.primaryColor;
        iconBg = AppTheme.primaryLight;
        break;
      case ModuleStatus.locked:
        icon = Icons.lock;
        iconColor = AppTheme.secondaryTextColor;
        iconBg = isDark
            ? AppTheme.darkBorder
            : const Color(0xFFF1F5F9);
        break;
    }

    final locked = module.status == ModuleStatus.locked;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Module $index: ${module.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: locked ? AppTheme.secondaryTextColor : textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.duration,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                locked ? Icons.lock_outline : Icons.chevron_right,
                color: AppTheme.secondaryTextColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}