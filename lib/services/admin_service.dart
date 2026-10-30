
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/course_repository.dart';
import '../models/course.dart';

class AdminService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _courses =>
      _firestore.collection('courses');

  // ==================================================
  // 1. ADMIN AUTHORIZATION
  // ==================================================

  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;

    if (user == null) return false;

    final adminDoc = await _firestore
        .collection('admins')
        .doc(user.uid)
        .get();

    return adminDoc.exists;
  }

  Future<void> _requireAdmin() async {
    final authorized = await isCurrentUserAdmin();

    if (!authorized) {
      throw Exception(
        'Access denied. An authorized admin account is required.',
      );
    }
  }

  // ==================================================
  // 2. CHECK FIRESTORE COURSES
  // ==================================================

  Future<bool> hasFirestoreCourses() async {
    await _requireAdmin();

    final snapshot = await _courses.limit(1).get();

    return snapshot.docs.isNotEmpty;
  }

  // ==================================================
  // 3. FETCH COURSES FROM FIRESTORE
  // ==================================================

  Future<List<Course>> fetchCoursesFromFirestore() async {
    await _requireAdmin();

    final snapshot = await _courses.get();

    final courses = snapshot.docs.map((doc) {
      return _courseFromFirestore(
        doc.id,
        doc.data(),
      );
    }).toList();

    courses.sort(
      (a, b) => a.title.toLowerCase().compareTo(
            b.title.toLowerCase(),
          ),
    );

    return courses;
  }

  // ==================================================
  // 4. MIGRATE EXISTING JSON COURSES TO FIRESTORE
  // ==================================================

  Future<int> migrateLocalCoursesToFirestore() async {
    await _requireAdmin();

    // Stop if Firestore already contains any courses.
    // This protects existing Firestore data.
    final existing = await _courses.limit(1).get();

    if (existing.docs.isNotEmpty) {
      throw Exception(
        'Firestore already contains courses. '
        'Migration stopped to protect existing data.',
      );
    }

    final localCourses =
        await CourseRepository.instance.fetchCourses();

    if (localCourses.isEmpty) {
      return 0;
    }

    // Firestore batches support at most 500 operations.
    // This migration writes the current starter course set.
    final batch = _firestore.batch();

    for (final course in localCourses) {
      final document = _courses.doc(course.id);

      batch.set(document, {
        ..._courseToMap(course),
        'isPublished': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    return localCourses.length;
  }

  // ==================================================
  // 5. ADD OR UPDATE A COURSE
  // ==================================================

  Future<void> saveCourse(Course course) async {
    await _requireAdmin();

    if (course.id.trim().isEmpty) {
      throw Exception('Course ID cannot be empty.');
    }

    if (course.title.trim().isEmpty) {
      throw Exception('Course title cannot be empty.');
    }

    final document = _courses.doc(course.id);
    final existing = await document.get();

    final data = <String, dynamic>{
      ..._courseToMap(course),
      'isPublished': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await document.set(
      data,
      SetOptions(merge: true),
    );
  }

  // ==================================================
  // 6. DELETE A COURSE
  // ==================================================

  Future<void> deleteCourse(String courseId) async {
    await _requireAdmin();

    if (courseId.trim().isEmpty) {
      throw Exception('Course ID cannot be empty.');
    }

    await _courses.doc(courseId).delete();
  }

  // ==================================================
  // 7. DASHBOARD STATISTICS
  // ==================================================

  Future<Map<String, int>> getDashboardStats() async {
    await _requireAdmin();

    final results = await Future.wait([
      _courses.count().get(),
      _firestore.collection('learners').count().get(),
      _firestore.collection('feedback').count().get(),
    ]);

    return {
      'courses': results[0].count ?? 0,
      'learners': results[1].count ?? 0,
      'feedback': results[2].count ?? 0,
    };
  }

  // ==================================================
  // 8. CONVERT COURSE MODEL TO FIRESTORE DATA
  // ==================================================

  Map<String, dynamic> _courseToMap(Course course) {
    return {
      'id': course.id,
      'title': course.title,
      'description': course.description,
      'category': course.category,
      'level': course.level,
      'rating': course.rating,
      'learners': course.learners,
      'hours': course.hours,
      'icon': _iconToKey(course.icon),
      'color': _colorToHex(course.color),
      'outcomes': course.outcomes,
      'modules': course.modules.map((module) {
        return {
          'id': module.id,
          'title': module.title,
          'duration': module.duration,
          'status': module.status.name,
        };
      }).toList(),
    };
  }

  // ==================================================
  // 9. CONVERT FIRESTORE DATA TO COURSE MODEL
  // ==================================================

  Course _courseFromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final rawModules = data['modules'] as List? ?? [];
    final rawOutcomes = data['outcomes'] as List? ?? [];

    return Course(
      id: documentId,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Programming',
      level: data['level'] as String? ?? 'Beginner',
      rating: (data['rating'] as num? ?? 0).toDouble(),
      learners: (data['learners'] as num? ?? 0).toInt(),
      hours: (data['hours'] as num? ?? 1).toInt(),
      icon: _iconFromKey(
        data['icon'] as String? ?? 'code',
      ),
      color: _colorFromHex(
        data['color'] as String? ?? '#C9DEFF',
      ),
      outcomes: rawOutcomes
          .map((item) => item.toString())
          .toList(),
      modules: rawModules.map((item) {
        final module = Map<String, dynamic>.from(
          item as Map,
        );

        return CourseModule(
          id: module['id'] as String? ?? '',
          title: module['title'] as String? ?? '',
          duration: module['duration'] as String? ?? '10 min',
          status: _statusFromString(
            module['status'] as String? ?? 'locked',
          ),
        );
      }).toList(),
    );
  }

  // ==================================================
  // 10. ICON CONVERSION
  // ==================================================

  String _iconToKey(IconData icon) {
    if (icon == Icons.flutter_dash) return 'flutter_dash';
    if (icon == Icons.code) return 'code';
    if (icon == Icons.router) return 'router';
    if (icon == Icons.memory) return 'memory';
    if (icon == Icons.handyman) return 'handyman';
    if (icon == Icons.laptop_mac) return 'laptop_mac';
    if (icon == Icons.storage) return 'storage';

    return 'code';
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'flutter_dash':
        return Icons.flutter_dash;
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
      case 'code':
      default:
        return Icons.code;
    }
  }

  // ==================================================
  // 11. COLOR CONVERSION
  // ==================================================

  String _colorToHex(Color color) {
    final argb = color.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Color _colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16) ?? 0xC9DEFF;

    if (cleaned.length == 8) {
      return Color(value);
    }

    return Color(0xFF000000 | value);
  }

  // ==================================================
  // 12. MODULE STATUS CONVERSION
  // ==================================================

  ModuleStatus _statusFromString(String value) {
    switch (value) {
      case 'completed':
        return ModuleStatus.completed;
      case 'inProgress':
        return ModuleStatus.inProgress;
      default:
        return ModuleStatus.locked;
    }
  }
}

