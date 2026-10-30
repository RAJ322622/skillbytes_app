
import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'add_edit_course_screen.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() =>
      _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController =
      TextEditingController();

  List<Course> _courses = [];
  bool _isLoading = true;
  bool _isImporting = false;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load courses from Firestore.
  Future<void> _loadCourses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courses =
          await _adminService.fetchCoursesFromFirestore();

      if (!mounted) return;

      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  // Search by title, category, or level.
  List<Course> get _filteredCourses {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return _courses;

    return _courses.where((course) {
      return course.title.toLowerCase().contains(query) ||
          course.category.toLowerCase().contains(query) ||
          course.level.toLowerCase().contains(query);
    }).toList();
  }

  // Open the add-course form.
  Future<void> _addCourse() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditCourseScreen(),
      ),
    );

    if (result == true && mounted) {
      await _loadCourses();
    }
  }

  // Open the edit-course form.
  Future<void> _editCourse(Course course) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCourseScreen(course: course),
      ),
    );

    if (result == true && mounted) {
      await _loadCourses();
    }
  }

  // Confirm before deleting a course.
  Future<void> _deleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete course?'),
          content: Text(
            'Are you sure you want to delete '
            '"${course.title}" from Firestore?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await _adminService.deleteCourse(course.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${course.title} deleted successfully.'),
        ),
      );

      await _loadCourses();
    } catch (error) {
      if (!mounted) return;

      _showMessage('Could not delete course: $error');
    }
  }

  // Import the existing JSON courses into an empty Firestore collection.
  Future<void> _importStarterCourses() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Import starter courses?'),
          content: const Text(
            'Import your six existing courses from courses.json '
            'into Firestore? The import will stop if Firestore '
            'already contains any course documents.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Import courses'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isImporting = true);

    try {
      final count =
          await _adminService.migrateLocalCoursesToFirestore();

      if (!mounted) return;

      _showMessage('$count courses imported successfully.');

      await _loadCourses();
    } catch (error) {
      if (!mounted) return;

      _showMessage('Import failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = _filteredCourses;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Manage Courses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh courses',
            onPressed: _loadCourses,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCourse,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildCourseBody(filteredCourses),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.accentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Library',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_courses.length} courses available',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Create and manage learning content',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseBody(List<Course> courses) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (courses.isEmpty && _courses.isNotEmpty) {
      return const Center(
        child: Text('No courses match your search.'),
      );
    }

    if (_courses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return _buildCourseCard(courses[index]);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 54,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadCourses,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isImporting
                  ? null
                  : _importStarterCourses,
              icon: _isImporting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _isImporting
                    ? 'Importing...'
                    : 'Import Starter Courses',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.library_books_outlined,
              size: 64,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 12),
            const Text(
              'No courses in Firestore yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import your existing JSON courses to get started.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed:
                  _isImporting ? null : _importStarterCourses,
              icon: _isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _isImporting
                    ? 'Importing...'
                    : 'Import Starter Courses',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppTheme.borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: course.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    course.icon,
                    size: 30,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${course.category} • ${course.level}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _courseInfo(
                            Icons.schedule,
                            '${course.hours} hours',
                          ),
                          _courseInfo(
                            Icons.star_rounded,
                            course.rating.toStringAsFixed(1),
                          ),
                          _courseInfo(
                            Icons.menu_book_outlined,
                            '${course.modules.length} modules',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Course actions',
                  onSelected: (action) {
                    if (action == 'edit') {
                      _editCourse(course);
                    } else if (action == 'delete') {
                      _deleteCourse(course);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        title: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editCourse(course),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    label: const Text('Edit Course'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'Delete course',
                  onPressed: () => _deleteCourse(course),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseInfo(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
