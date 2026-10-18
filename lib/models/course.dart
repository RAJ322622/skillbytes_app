import 'package:flutter/material.dart';

class CourseModule {
  final String id;
  final String title;
  final String duration;
  final ModuleStatus status;

  const CourseModule({
    required this.id,
    required this.title,
    required this.duration,
    this.status = ModuleStatus.locked,
  });

  CourseModule copyWith({ModuleStatus? status}) {
    return CourseModule(
      id: id,
      title: title,
      duration: duration,
      status: status ?? this.status,
    );
  }
}

enum ModuleStatus { completed, inProgress, locked }

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final double rating;
  final int learners;
  final int hours;
  final IconData icon;
  final Color color;
  final List<CourseModule> modules;
  final List<String> outcomes;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.rating,
    required this.learners,
    required this.hours,
    required this.icon,
    required this.color,
    required this.modules,
    required this.outcomes,
  });

  Course copyWith({List<CourseModule>? modules}) {
    return Course(
      id: id,
      title: title,
      description: description,
      category: category,
      level: level,
      rating: rating,
      learners: learners,
      hours: hours,
      icon: icon,
      color: color,
      modules: modules ?? this.modules,
      outcomes: outcomes,
    );
  }
}