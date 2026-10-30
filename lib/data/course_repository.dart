
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED: Firestore access
import '../models/course.dart';

class CourseRepository {
  CourseRepository._();
  static final CourseRepository instance = CourseRepository._();

  List<Course>? _cache;

  /// Simulate network delay so loading indicators are visible.
  static const Duration _delay = Duration(milliseconds: 700);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  // UPDATED: Load JSON defaults and merge them with Firestore courses.
  // Firestore versions override matching JSON IDs; new courses are added.
  Future<List<Course>> fetchCourses() async {
    await Future.delayed(_delay);

    // EXISTING: Load the default courses from the bundled JSON file.
    final raw = await rootBundle.loadString('assets/data/courses.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final jsonCourses = (data['courses'] as List)
        .map((j) => _courseFromJson(j as Map<String, dynamic>))
        .toList();

    // ADDED: Use a map to prevent duplicate course IDs.
    final Map<String, Course> mergedCourses = {
      for (final course in jsonCourses) course.id: course,
    };

    try {
      // ADDED: Fetch admin-managed courses from Firestore.
      final snapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      for (final doc in snapshot.docs) {
        try {
          // ADDED: Convert Firestore documents to Course models.
          final course = _courseFromFirestore(doc.id, doc.data());

          // ADDED: Firestore data overrides JSON data with the same ID.
          mergedCourses[course.id] = course;
        } catch (e) {
          // ADDED: Skip malformed Firestore course documents safely.
          debugPrint('Unable to parse course ${doc.id}: $e');
        }
      }
    } catch (e) {
      // ADDED: Keep local courses available if Firestore cannot be reached.
      debugPrint('Unable to fetch Firestore courses: $e');
    }

    // UPDATED: Refresh the cache with the combined course list.
    _cache = mergedCourses.values.toList();

    return _cache!;
  }

  /// Fetch a single course by id.
  Future<Course?> fetchCourseById(String id) async {
    // EXISTING: Uses fetchCourses(), now including Firestore courses.
    final all = await fetchCourses();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mark a course as enrolled (unlock first module if still locked).
  void enroll(String courseId) {
    final list = _cache;
    if (list == null) return;
    final i = list.indexWhere((c) => c.id == courseId);
    if (i == -1) return;
    final course = list[i];

    final newModules = course.modules.asMap().entries.map((e) {
      final idx = e.key;
      final m = e.value;
      if (idx == 0 && m.status == ModuleStatus.locked) {
        return m.copyWith(status: ModuleStatus.inProgress);
      }
      return m;
    }).toList();

    list[i] = course.copyWith(modules: newModules);
  }

  /// Complete a module and unlock the next one.
  void completeModule(String courseId, String moduleId) {
    final list = _cache;
    if (list == null) return;
    final ci = list.indexWhere((c) => c.id == courseId);
    if (ci == -1) return;
    final course = list[ci];

    final newModules = <CourseModule>[];
    for (int i = 0; i < course.modules.length; i++) {
      final m = course.modules[i];
      if (m.id == moduleId) {
        newModules.add(m.copyWith(status: ModuleStatus.completed));
        if (i + 1 < course.modules.length &&
            course.modules[i + 1].status == ModuleStatus.locked) {
          newModules.add(
            course.modules[i + 1].copyWith(status: ModuleStatus.inProgress),
          );
        }
      } else if (newModules.length == i + 1 &&
          course.modules[i].status == ModuleStatus.locked) {
        continue;
      } else {
        newModules.add(m);
      }
    }

    final seen = <String>{};
    final deduped = <CourseModule>[];
    for (final m in newModules) {
      if (seen.add(m.id)) deduped.add(m);
    }

    list[ci] = course.copyWith(modules: deduped);
  }

  /// Convenience — current in-memory list (may be null before first fetch).
  List<Course>? get cached => _cache;

  // ---------------------------------------------------------------------------
  // JSON → Model helpers
  // ---------------------------------------------------------------------------

  Course _courseFromJson(Map<String, dynamic> j) {
    return Course(
      id: j['id'] as String,
      title: j['title'] as String,
      description: j['description'] as String,
      category: j['category'] as String,
      level: j['level'] as String,
      rating: (j['rating'] as num).toDouble(),
      learners: (j['learners'] as num).toInt(),
      hours: (j['hours'] as num).toInt(),
      icon: _iconFromKey(j['icon'] as String),
      color: _colorFromHex(j['color'] as String),
      outcomes: (j['outcomes'] as List).cast<String>(),
      modules: (j['modules'] as List).map((mj) {
        final m = mj as Map<String, dynamic>;
        return CourseModule(
          id: m['id'] as String,
          title: m['title'] as String,
          duration: m['duration'] as String,
          status: _statusFromString(m['status'] as String),
        );
      }).toList(),
    );
  }

  // ADDED: Convert a Firestore document into the existing Course model.
  Course _courseFromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    // ADDED: Normalize Firestore data to the format used by the JSON parser.
    final normalized = <String, dynamic>{
      ...data,
      'id': data['id'] as String? ?? documentId,
      'title': data['title'] as String? ?? '',
      'description': data['description'] as String? ?? '',
      'category': data['category'] as String? ?? 'Programming',
      'level': data['level'] as String? ?? 'Beginner',
      'rating': data['rating'] as num? ?? 0,
      'learners': data['learners'] as num? ?? 0,
      'hours': data['hours'] as num? ?? 1,
      'icon': data['icon'] as String? ?? 'code',
      'color': data['color'] as String? ?? '#C9DEFF',
      'outcomes': (data['outcomes'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      'modules': (data['modules'] as List? ?? []).map((item) {
        final module = Map<String, dynamic>.from(item as Map);

        return <String, dynamic>{
          'id': module['id'] as String? ?? '',
          'title': module['title'] as String? ?? '',
          'duration': module['duration'] as String? ?? '10 min',
          'status': module['status'] as String? ?? 'locked',
        };
      }).toList(),
    };

    // ADDED: Reuse the existing JSON-to-model conversion.
    return _courseFromJson(normalized);
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'flutter_dash':
        return Icons.flutter_dash;
      case 'code':
        return Icons.code;
      case 'router':
        return Icons.router;
      case 'memory':
        return Icons.memory;
      case 'handyman':
        return Icons.handyman;
      case 'laptop_mac':
        return Icons.laptop_mac;
      case 'storage':
        return Icons.storage;
      default:
        return Icons.book;
    }
  }

  Color _colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16) ?? 0xCCCCCC;
    return Color(0xFF000000 | value);
  }

  ModuleStatus _statusFromString(String s) {
    switch (s) {
      case 'completed':
        return ModuleStatus.completed;
      case 'inProgress':
        return ModuleStatus.inProgress;
      default:
        return ModuleStatus.locked;
    }
  }
}
