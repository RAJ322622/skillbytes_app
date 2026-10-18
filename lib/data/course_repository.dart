import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseRepository {
  CourseRepository._();
  static final CourseRepository instance = CourseRepository._();

  /// Mutable in-memory courses so enrollment + module progress persist
  /// for the app session. Swap for a real backend later.
  final List<Course> _courses = _seed();

  List<Course> get all => List.unmodifiable(_courses);

  Course? byId(String id) {
    try {
      return _courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mark a course as enrolled: first module becomes in-progress.
  void enroll(String courseId) {
    final i = _courses.indexWhere((c) => c.id == courseId);
    if (i == -1) return;
    final course = _courses[i];

    final newModules = course.modules.asMap().entries.map((e) {
      final idx = e.key;
      final m = e.value;
      if (idx == 0 && m.status == ModuleStatus.locked) {
        return m.copyWith(status: ModuleStatus.inProgress);
      }
      return m;
    }).toList();

    _courses[i] = course.copyWith(modules: newModules);
  }

  /// Mark a specific module as completed and unlock the next one.
  void completeModule(String courseId, String moduleId) {
    final ci = _courses.indexWhere((c) => c.id == courseId);
    if (ci == -1) return;
    final course = _courses[ci];

    final newModules = <CourseModule>[];
    for (int i = 0; i < course.modules.length; i++) {
      final m = course.modules[i];
      if (m.id == moduleId) {
        newModules.add(m.copyWith(status: ModuleStatus.completed));
        if (i + 1 < course.modules.length &&
            course.modules[i + 1].status == ModuleStatus.locked) {
          newModules.add(
            course.modules[i + 1]
                .copyWith(status: ModuleStatus.inProgress),
          );
        }
      } else if (newModules.length == i + 1 &&
          course.modules[i].status == ModuleStatus.locked) {
        // skip — already added via the unlock above
        continue;
      } else {
        newModules.add(m);
      }
    }

    // Deduplicate and preserve order
    final seen = <String>{};
    final deduped = <CourseModule>[];
    for (final m in newModules) {
      if (seen.add(m.id)) deduped.add(m);
    }

    _courses[ci] = course.copyWith(modules: deduped);
  }

  // ---------------------------------------------------------------------------
  // Seed data
  // ---------------------------------------------------------------------------

  static List<Course> _seed() => [
        Course(
          id: 'flutter-dev',
          title: 'Flutter Development',
          description:
              'Learn to build beautiful, cross-platform mobile apps with Flutter and Dart. From widgets to state management, this course walks you through everything you need to ship real apps.',
          category: 'Programming',
          level: 'Beginner',
          rating: 4.8,
          learners: 12000,
          hours: 6,
          icon: Icons.flutter_dash,
          color: const Color(0xFFC9DEFF),
          outcomes: const [
            'Build responsive mobile UIs with widgets',
            'Understand state management patterns',
            'Integrate APIs and handle async data',
            'Ship a complete Flutter app',
          ],
          modules: const [
            CourseModule(
              id: 'fd-1',
              title: 'UI Layouts & Widgets',
              duration: '12 min',
              status: ModuleStatus.completed,
            ),
            CourseModule(
              id: 'fd-2',
              title: 'State Management',
              duration: '18 min',
              status: ModuleStatus.inProgress,
            ),
            CourseModule(
              id: 'fd-3',
              title: 'API Integration',
              duration: '15 min',
            ),
            CourseModule(
              id: 'fd-4',
              title: 'Navigation & Routing',
              duration: '10 min',
            ),
            CourseModule(
              id: 'fd-5',
              title: 'Local Storage',
              duration: '14 min',
            ),
            CourseModule(
              id: 'fd-6',
              title: 'Publishing Your App',
              duration: '9 min',
            ),
          ],
        ),
        Course(
          id: 'python-prog',
          title: 'Python Programming',
          description:
              'Start coding with Python from the basics to advanced topics. Covers syntax, data structures, OOP, and practical scripting for real-world tasks.',
          category: 'Programming',
          level: 'Beginner',
          rating: 4.7,
          learners: 15000,
          hours: 8,
          icon: Icons.code,
          color: const Color(0xFFFFE9BE),
          outcomes: const [
            'Write clean Python code',
            'Use lists, dicts, and sets effectively',
            'Understand functions and OOP',
            'Automate tasks with scripts',
          ],
          modules: const [
            CourseModule(
              id: 'py-1',
              title: 'Python Basics',
              duration: '15 min',
              status: ModuleStatus.completed,
            ),
            CourseModule(
              id: 'py-2',
              title: 'Data Structures',
              duration: '20 min',
            ),
            CourseModule(
              id: 'py-3',
              title: 'Functions & Modules',
              duration: '18 min',
            ),
            CourseModule(
              id: 'py-4',
              title: 'Object-Oriented Python',
              duration: '22 min',
            ),
            CourseModule(
              id: 'py-5',
              title: 'File I/O & Scripting',
              duration: '16 min',
            ),
          ],
        ),
        Course(
          id: 'networking-basics',
          title: 'Networking Basics',
          description:
              'Understand how computer networks work. Covers IP addressing, protocols, routing, and hands-on network troubleshooting.',
          category: 'Networking',
          level: 'Intermediate',
          rating: 4.6,
          learners: 8500,
          hours: 5,
          icon: Icons.router,
          color: const Color(0xFFC9F8DD),
          outcomes: const [
            'Understand IP, TCP, and UDP',
            'Configure basic networks',
            'Troubleshoot connection issues',
            'Read network diagrams',
          ],
          modules: const [
            CourseModule(
              id: 'nw-1',
              title: 'Intro to Networks',
              duration: '12 min',
              status: ModuleStatus.completed,
            ),
            CourseModule(
              id: 'nw-2',
              title: 'IP Addressing',
              duration: '18 min',
              status: ModuleStatus.completed,
            ),
            CourseModule(
              id: 'nw-3',
              title: 'Routing & Switching',
              duration: '20 min',
              status: ModuleStatus.inProgress,
            ),
            CourseModule(
              id: 'nw-4',
              title: 'Protocols Deep Dive',
              duration: '16 min',
            ),
            CourseModule(
              id: 'nw-5',
              title: 'Network Troubleshooting',
              duration: '14 min',
            ),
          ],
        ),
        Course(
          id: 'electronics-basics',
          title: 'Electronics Basics',
          description:
              'Explore the fundamentals of electronics — components, circuits, and how current flows. Great starting point for hardware tinkerers.',
          category: 'Electronics',
          level: 'Beginner',
          rating: 4.7,
          learners: 6200,
          hours: 4,
          icon: Icons.memory,
          color: const Color(0xFFEED5FF),
          outcomes: const [
            'Identify common components',
            'Read circuit diagrams',
            'Use a multimeter',
            'Build simple circuits',
          ],
          modules: const [
            CourseModule(
              id: 'el-1',
              title: 'Voltage, Current, Resistance',
              duration: '10 min',
            ),
            CourseModule(
              id: 'el-2',
              title: 'Common Components',
              duration: '14 min',
            ),
            CourseModule(
              id: 'el-3',
              title: 'Reading Circuit Diagrams',
              duration: '16 min',
            ),
            CourseModule(
              id: 'el-4',
              title: 'Your First Circuit',
              duration: '18 min',
            ),
          ],
        ),
        Course(
          id: 'hardware-skills',
          title: 'Hardware Skills',
          description:
              'Learn hands-on hardware skills — assembling, repairing, and maintaining computers and devices.',
          category: 'Hardware Skills',
          level: 'Intermediate',
          rating: 4.5,
          learners: 4300,
          hours: 5,
          icon: Icons.handyman,
          color: const Color(0xFFC4F6F1),
          outcomes: const [
            'Assemble a PC from parts',
            'Diagnose hardware issues',
            'Upgrade components',
            'Maintain devices safely',
          ],
          modules: const [
            CourseModule(
              id: 'hw-1',
              title: 'Tools & Safety',
              duration: '10 min',
            ),
            CourseModule(
              id: 'hw-2',
              title: 'PC Assembly',
              duration: '22 min',
            ),
            CourseModule(
              id: 'hw-3',
              title: 'Troubleshooting',
              duration: '18 min',
            ),
            CourseModule(
              id: 'hw-4',
              title: 'Upgrades & Maintenance',
              duration: '16 min',
            ),
            CourseModule(
              id: 'hw-5',
              title: 'Mobile Device Repair',
              duration: '20 min',
            ),
          ],
        ),
        Course(
          id: 'web-dev',
          title: 'Web Development',
          description:
              'Build modern web applications with HTML, CSS, and JavaScript. Covers responsive design, DOM manipulation, and modern frameworks.',
          category: 'Programming',
          level: 'Advanced',
          rating: 4.9,
          learners: 21000,
          hours: 10,
          icon: Icons.laptop_mac,
          color: const Color(0xFFFFD3E9),
          outcomes: const [
            'Build responsive layouts',
            'Write clean HTML/CSS/JS',
            'Use modern frontend tooling',
            'Deploy production sites',
          ],
          modules: const [
            CourseModule(
              id: 'wd-1',
              title: 'HTML Foundations',
              duration: '12 min',
            ),
            CourseModule(
              id: 'wd-2',
              title: 'CSS & Layouts',
              duration: '18 min',
            ),
            CourseModule(
              id: 'wd-3',
              title: 'JavaScript Essentials',
              duration: '22 min',
            ),
            CourseModule(
              id: 'wd-4',
              title: 'DOM & Events',
              duration: '16 min',
            ),
            CourseModule(
              id: 'wd-5',
              title: 'Responsive Design',
              duration: '14 min',
            ),
            CourseModule(
              id: 'wd-6',
              title: 'Intro to Frameworks',
              duration: '20 min',
            ),
            CourseModule(
              id: 'wd-7',
              title: 'Deployment',
              duration: '10 min',
            ),
            CourseModule(
              id: 'wd-8',
              title: 'Final Project',
              duration: '30 min',
            ),
            CourseModule(
              id: 'wd-9',
              title: 'Portfolio & Next Steps',
              duration: '12 min',
            ),
            CourseModule(
              id: 'wd-10',
              title: 'Wrap-up',
              duration: '8 min',
            ),
          ],
        ),
      ];
}