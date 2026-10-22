import 'package:flutter/material.dart';
import '../data/course_repository.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String courseId;
  const ProgramDetailsScreen({super.key, required this.courseId});

  @override
  State<ProgramDetailsScreen> createState() =>
      _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  late Future<Course?> _courseFuture;

  @override
  void initState() {
    super.initState();
    _courseFuture =
        CourseRepository.instance.fetchCourseById(widget.courseId);
  }

  void _retry() {
    setState(() {
      _courseFuture =
          CourseRepository.instance.fetchCourseById(widget.courseId);
    });
  }

  void _refresh() {
    setState(() {
      _courseFuture = Future.value(
        CourseRepository.instance.cached
            ?.firstWhere((c) => c.id == widget.courseId),
      );
    });
  }

  void _onEnroll(Course course) {
    CourseRepository.instance.enroll(course.id);
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enrolled in ${course.title}!')),
    );
  }

  void _onContinue(Course course) {
    CourseModule? current;
    for (final m in course.modules) {
      if (m.status == ModuleStatus.inProgress) {
        current = m;
        break;
      }
    }
    if (current == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resuming "${current.title}"...')),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: FutureBuilder<Course?>(
          future: _courseFuture,
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
                    Text('Loading course...'),
                  ],
                ),
              );
            }

            // =====================================================
            // ERROR STATE
            // TODO(Muhammad): Replace with polished error UI
            // =====================================================
            if (snapshot.hasError) {
              return _errorView(
                message: 'Failed to load course',
                error: '${snapshot.error}',
                onRetry: _retry,
              );
            }

            // Not found
            final course = snapshot.data;
            if (course == null) {
              return _errorView(
                message: 'Course not found',
                error: 'No course with id "${widget.courseId}"',
                onRetry: _retry,
              );
            }

            // =====================================================
            // SUCCESS STATE
            // =====================================================
            final isEnrolled =
                course.modules.any((m) => m.status != ModuleStatus.locked);

            return Stack(
              children: [
                _buildDetails(course),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _stickyButton(
                    isEnrolled: isEnrolled,
                    onPressed: () => isEnrolled
                        ? _onContinue(course)
                        : _onEnroll(course),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stickyButton({
    required bool isEnrolled,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
            onPressed: onPressed,
            child: Text(
              isEnrolled ? 'Continue Learning' : 'Enroll Now',
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorView({
    required String message,
    required String error,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 4),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(Course course) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textColor;

    final isEnrolled =
        course.modules.any((m) => m.status != ModuleStatus.locked);

    final progress = course.modules.isEmpty
        ? 0.0
        : course.modules
                .where((m) => m.status == ModuleStatus.completed)
                .length /
            course.modules.length;

    return CustomScrollView(
      slivers: [
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
              color: course.color,
              child: Center(
                child: Icon(
                  course.icon,
                  size: 96,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
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
                    _badge(course.category, AppTheme.primaryLight,
                        AppTheme.primaryColor),
                    _badge(
                      course.level,
                      _levelColor(course.level),
                      Colors.black87,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _meta(Icons.star, '${course.rating}', Colors.orange),
                    const SizedBox(width: 16),
                    _meta(Icons.people_outline,
                        '${(course.learners / 1000).toStringAsFixed(1)}K',
                        null),
                    const SizedBox(width: 16),
                    _meta(Icons.access_time, '${course.hours}h', null),
                    const SizedBox(width: 16),
                    _meta(Icons.menu_book_outlined,
                        '${course.modules.length} modules', null),
                  ],
                ),
                const SizedBox(height: 20),
                if (isEnrolled) ...[
                  _progressBlock(isDark, progress),
                  const SizedBox(height: 20),
                ],
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "What you'll learn",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                ...course.outcomes.map(
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
                Text(
                  'Course Modules',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final m = course.modules[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: _ModuleRow(
                  index: i + 1,
                  module: m,
                  onTap: () => _onModuleTap(m),
                ),
              );
            },
            childCount: course.modules.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }

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

  Widget _progressBlock(bool isDark, double progress) {
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
              const Icon(Icons.trending_up,
                  size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              const Text(
                'Your Progress',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
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
              value: progress,
              minHeight: 8,
              backgroundColor:
                  isDark ? AppTheme.darkBorder : AppTheme.borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
            ),
          ),
        ],
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
        iconBg = const Color(0xFFFFE8D0);
        break;
      case ModuleStatus.inProgress:
        icon = Icons.play_circle_fill;
        iconColor = AppTheme.primaryColor;
        iconBg = AppTheme.primaryLight;
        break;
      case ModuleStatus.locked:
        icon = Icons.lock;
        iconColor = AppTheme.secondaryTextColor;
        iconBg =
            isDark ? AppTheme.darkBorder : const Color(0xFFF1F5F9);
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
                        color: locked
                            ? AppTheme.secondaryTextColor
                            : textColor,
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