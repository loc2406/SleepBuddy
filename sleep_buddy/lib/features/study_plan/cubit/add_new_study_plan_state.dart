import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/study_plan/model/models.dart';

class AddNewStudyPlanState {
  final DateTime lessonDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final LessonPriority priority;
  final List<StudySubject> subjects;
  final StudySubject? selectedSubject;
  final bool isLoadingSubjects;
  final bool isSaving;
  final bool isAddingSubject;
  final String? subjectLoadError;

  AddNewStudyPlanState({
    DateTime? lessonDate,
    this.startTime = const TimeOfDay(hour: 0, minute: 0),
    this.endTime = const TimeOfDay(hour: 23, minute: 59),
    this.priority = LessonPriority.medium,
    this.subjects = const [],
    this.selectedSubject,
    this.isLoadingSubjects = true,
    this.isSaving = false,
    this.isAddingSubject = false,
    this.subjectLoadError,
  }) : lessonDate = lessonDate ?? DateTime.now();

  AddNewStudyPlanState copyWith({
    DateTime? lessonDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    LessonPriority? priority,
    List<StudySubject>? subjects,
    StudySubject? selectedSubject,
    bool clearSelectedSubject = false,
    bool? isLoadingSubjects,
    bool? isSaving,
    bool? isAddingSubject,
    String? subjectLoadError,
    bool clearSubjectLoadError = false,
  }) => AddNewStudyPlanState(
    lessonDate: lessonDate ?? this.lessonDate,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    priority: priority ?? this.priority,
    subjects: subjects ?? this.subjects,
    selectedSubject: clearSelectedSubject
        ? null
        : selectedSubject ?? this.selectedSubject,
    isLoadingSubjects: isLoadingSubjects ?? this.isLoadingSubjects,
    isSaving: isSaving ?? this.isSaving,
    isAddingSubject: isAddingSubject ?? this.isAddingSubject,
    subjectLoadError: clearSubjectLoadError
        ? null
        : subjectLoadError ?? this.subjectLoadError,
  );
}
