import 'package:flutter/foundation.dart';

/// Shared filter state between Home and Courses tabs.
/// Home writes to it when a category is tapped; Courses listens.
class CourseFilter {
  CourseFilter._();

  /// null = show all, otherwise a category name like 'Programming'.
  static final ValueNotifier<String?> category =
      ValueNotifier<String?>(null);
}