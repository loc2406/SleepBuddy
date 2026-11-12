import 'package:flutter/material.dart';

enum LessonPriority { high, medium, low }

enum LessonStatus { notStarted, inProgress, completed }

enum LessonFilter { all, notStarted, inProgress, completed }

@immutable
class StudyLesson {
  const StudyLesson({
    required this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.status,
    this.image = const AssetImage('assets/images/book.png'),
  });

  final String id;
  final String subject;
  final String title;
  final String description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final LessonPriority priority;
  final LessonStatus status;
  final ImageProvider image;
}

@immutable
class StudySubject {
  const StudySubject({
    required this.id,
    required this.name,
    required this.colorHex,
    this.imagePath,
  });

  final int id;
  final String name;
  final String colorHex;
  final String? imagePath;
}

@immutable
class CreateStudyTaskInput {
  const CreateStudyTaskInput({
    required this.subjectId,
    required this.title,
    required this.lessonDate,
    required this.startTime,
    required this.endTime,
    this.description = '',
    this.priority = LessonPriority.medium,
  });

  final int subjectId;
  final String title;
  final String description;
  final DateTime lessonDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final LessonPriority priority;
}

/// Text and counts are provided by the caller, so filters also support APIs
/// that load only one page of lessons at a time.
@immutable
class PlannerFilterItem {
  const PlannerFilterItem({
    required this.value,
    required this.label,
    required this.count,
  });
  final LessonFilter value;
  final String label;
  final int count;
}

@immutable
class PlannerNavItem {
  const PlannerNavItem({required this.label, required this.image});
  final String label;
  final ImageProvider image;
}

const plannerNavigationItems = [
  PlannerNavItem(
    label: 'Trang chủ',
    image: AssetImage('assets/planner/home-nav.png'),
  ),
  PlannerNavItem(
    label: 'Lịch trình',
    image: AssetImage('assets/planner/calendar-nav.png'),
  ),
  PlannerNavItem(
    label: 'Tập trung',
    image: AssetImage('assets/planner/timer-nav.png'),
  ),
  PlannerNavItem(
    label: 'Nghỉ ngơi',
    image: AssetImage('assets/planner/moon-nav.png'),
  ),
  PlannerNavItem(
    label: 'Thống kê',
    image: AssetImage('assets/planner/chart-nav.png'),
  ),
];
