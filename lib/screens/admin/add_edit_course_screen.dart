
import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AddEditCourseScreen extends StatefulWidget {
  final Course? course;

  const AddEditCourseScreen({
    super.key,
    this.course,
  });

  @override
  State<AddEditCourseScreen> createState() =>
      _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _hoursController;
  late final TextEditingController _outcomesController;
  late final TextEditingController _modulesController;

  late String _level;
  late String _iconKey;
  late Color _courseColor;

  bool _isSaving = false;

  bool get _isEditing => widget.course != null;

  final List<Color> _availableColors = const [
    Color(0xFFC9DEFF),
    Color(0xFFFCE7F3),
    Color(0xFFFFE2C5),
    Color(0xFFD9FBE8),
    Color(0xFFE9D5FF),
    Color(0xFFFFF0B3),
    Color(0xFFCCFBF1),
    Color(0xFFFFD6D6),
  ];

  final Map<String, IconData> _availableIcons = const {
    'code': Icons.code,
    'flutter_dash': Icons.flutter_dash,
    'router': Icons.router,
    'memory': Icons.memory,
    'handyman': Icons.handyman,
    'laptop_mac': Icons.laptop_mac,
    'storage': Icons.storage,
  };

  @override
  void initState() {
    super.initState();

    final course = widget.course;

    _titleController = TextEditingController(
      text: course?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: course?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: course?.category ?? '',
    );
    _hoursController = TextEditingController(
      text: (course?.hours ?? 1).toString(),
    );
    _outcomesController = TextEditingController(
      text: course?.outcomes.join('\n') ?? '',
    );
    _modulesController = TextEditingController(
      text: course?.modules
              .map((module) => '${module.title} | ${module.duration}')
              .join('\n') ??
          '',
    );

    _level = course?.level ?? 'Beginner';
    _iconKey = _iconKeyFromData(course?.icon ?? Icons.code);
    _courseColor = course?.color ?? _availableColors.first;
  }

  String _iconKeyFromData(IconData icon) {
    for (final entry in _availableIcons.entries) {
      if (entry.value == icon) {
        return entry.key;
      }
    }
    return 'code';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _hoursController.dispose();
    _outcomesController.dispose();
    _modulesController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _saveCourse() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hours = int.tryParse(_hoursController.text.trim());

    if (hours == null || hours < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duration must be at least 1 hour.'),
        ),
      );
      return;
    }

    final existingCourse = widget.course;

    // Keep existing module IDs and statuses when editing modules
    // in the same order. New modules receive new IDs.
    final existingModules = existingCourse?.modules ?? [];

    final moduleLines = _modulesController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final modules = <CourseModule>[];

    for (var i = 0; i < moduleLines.length; i++) {
      final parts = moduleLines[i].split('|');
      final title = parts.first.trim();
      final duration = parts.length > 1
          ? parts.sublist(1).join('|').trim()
          : '10 min';

      if (title.isEmpty) continue;

      final oldModule = i < existingModules.length
          ? existingModules[i]
          : null;

      modules.add(
        CourseModule(
          id: oldModule?.id ??
              'module_${DateTime.now().microsecondsSinceEpoch}_$i',
          title: title,
          duration: duration.isEmpty ? '10 min' : duration,
          status: oldModule?.status ?? ModuleStatus.locked,
        ),
      );
    }

    final outcomes = _outcomesController.text
        .split('\n')
        .map((outcome) => outcome.trim())
        .where((outcome) => outcome.isNotEmpty)
        .toList();

    final courseId = existingCourse?.id ??
        '${_titleController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '')}_${DateTime.now().millisecondsSinceEpoch}';

    final course = Course(
      id: courseId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      level: _level,
      rating: existingCourse?.rating ?? 0.0,
      learners: existingCourse?.learners ?? 0,
      hours: hours,
      icon: _availableIcons[_iconKey] ?? Icons.code,
      color: _courseColor,
      outcomes: outcomes,
      modules: modules,
    );

    setState(() => _isSaving = true);

    try {
      await _adminService.saveCourse(course);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Course updated successfully.'
                : 'Course added successfully.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save course: $error'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Course' : 'Add Course'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _sectionTitle('Course Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  label: 'Course title',
                  hint: 'e.g. Flutter Development',
                  icon: Icons.menu_book_outlined,
                ),
                validator: (value) =>
                    _requiredValidator(value, 'Course title'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: _inputDecoration(
                  label: 'Description',
                  hint: 'Describe what learners will learn',
                  icon: Icons.description_outlined,
                ),
                validator: (value) =>
                    _requiredValidator(value, 'Description'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _categoryController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  label: 'Category',
                  hint: 'e.g. Programming',
                  icon: Icons.category_outlined,
                ),
                validator: (value) =>
                    _requiredValidator(value, 'Category'),
              ),
              const SizedBox(height: 16),

              // FIX 1: initialValue replaces deprecated value.
              DropdownButtonFormField<String>(
                initialValue: _level,
                decoration: _inputDecoration(
                  label: 'Difficulty level',
                  icon: Icons.bar_chart_outlined,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Beginner',
                    child: Text('Beginner'),
                  ),
                  DropdownMenuItem(
                    value: 'Intermediate',
                    child: Text('Intermediate'),
                  ),
                  DropdownMenuItem(
                    value: 'Advanced',
                    child: Text('Advanced'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _level = value);
                        }
                      },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _hoursController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  label: 'Duration (hours)',
                  hint: 'e.g. 12',
                  icon: Icons.schedule_outlined,
                ),
                validator: (value) {
                  final requiredError =
                      _requiredValidator(value, 'Duration');
                  if (requiredError != null) return requiredError;

                  final hours = int.tryParse(value!.trim());
                  if (hours == null || hours < 1) {
                    return 'Enter a whole number of at least 1';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),
              _sectionTitle('Course Appearance'),
              const SizedBox(height: 16),

              // FIX 2: initialValue replaces deprecated value.
              DropdownButtonFormField<String>(
                initialValue: _iconKey,
                decoration: _inputDecoration(
                  label: 'Course icon',
                  icon: Icons.interests_outlined,
                ),
                items: _availableIcons.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value, size: 21),
                        const SizedBox(width: 12),
                        Text(entry.key.replaceAll('_', ' ')),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _iconKey = value);
                        }
                      },
              ),
              const SizedBox(height: 20),

              const Text(
                'Card colour',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableColors.map((color) {
                  final selected = color.toARGB32() ==
                      _courseColor.toARGB32();

                  return InkWell(
                    onTap: _isSaving
                        ? null
                        : () => setState(() => _courseColor = color),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          width: selected ? 3 : 1,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Color(0xFF1E293B),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),
              _sectionTitle('Learning Outcomes'),
              const SizedBox(height: 8),
              const Text(
                'Enter one learning outcome per line.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _outcomesController,
                minLines: 3,
                maxLines: 7,
                decoration: _inputDecoration(
                  label: 'Learning outcomes',
                  hint: 'Understand Flutter widgets\nBuild mobile apps',
                  icon: Icons.checklist_outlined,
                ),
              ),

              const SizedBox(height: 28),
              _sectionTitle('Course Modules'),
              const SizedBox(height: 8),
              const Text(
                'Enter one module per line using: Module title | Duration\n'
                'Example: Introduction to Flutter | 20 min',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _modulesController,
                minLines: 4,
                maxLines: 12,
                decoration: _inputDecoration(
                  label: 'Modules',
                  hint: 'Introduction | 20 min\nWidgets | 30 min',
                  icon: Icons.view_list_outlined,
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : _isEditing
                            ? 'Update Course'
                            : 'Save Course',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.primaryColor,
          width: 1.5,
        ),
      ),
    );
  }
}
