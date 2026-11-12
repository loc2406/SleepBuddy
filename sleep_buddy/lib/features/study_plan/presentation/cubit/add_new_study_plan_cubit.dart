import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/notifications/task_reminder_notifications.dart';
import 'package:sleep_buddy/core/db/study_task_dao.dart';
import 'package:sleep_buddy/features/study_plan/presentation/cubit/add_new_study_plan_state.dart';
import 'package:sleep_buddy/features/study_plan/presentation/model/models.dart';

enum StudyTaskSaveResult {
  saved,
  alreadySaving,
  missingSubject,
  invalidTitle,
  savedButReminderFailed,
  invalidTimeRange,
  startBeforeNow,
  endBeforeNow,
  timeConflict,
}

class AddNewStudyPlanCubit extends Cubit<AddNewStudyPlanState> {
  AddNewStudyPlanCubit() : super(AddNewStudyPlanState()) {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    emit(state.copyWith(isLoadingSubjects: true, clearSubjectLoadError: true));

    try {
      final subjects = await StudyTaskDao.getSubjects();
      if (isClosed) return;

      final selectedSubject = subjects.isEmpty ? null : subjects.first;

      emit(
        state.copyWith(
          subjects: subjects,
          selectedSubject: selectedSubject,
          clearSelectedSubject: selectedSubject == null,
          isLoadingSubjects: false,
        ),
      );
    } on Exception catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingSubjects: false,
          subjectLoadError: 'Không thể tải danh sách môn học: $error',
        ),
      );
    }
  }

  void selectLessonDate(DateTime date) {
    emit(state.copyWith(lessonDate: DateTime(date.year, date.month, date.day)));
  }

  void selectStartTime(TimeOfDay time) {
    emit(state.copyWith(startTime: time));
  }

  void selectEndTime(TimeOfDay time) {
    emit(state.copyWith(endTime: time));
  }

  void selectPriority(LessonPriority priority) {
    emit(state.copyWith(priority: priority));
  }

  void selectSubject(StudySubject? subject) {
    emit(
      subject == null
          ? state.copyWith(clearSelectedSubject: true)
          : state.copyWith(selectedSubject: subject),
    );
  }

  String? validateSubjectName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Vui lòng nhập tên môn học';
    if (name.length < 2) return 'Tên môn học quá ngắn';
    return null;
  }

  String? validateTaskTitle(String? value) =>
      value == null || value.trim().isEmpty
      ? 'Vui lòng nhập tên nhiệm vụ'
      : null;

  Future<StudySubject> addSubject(String name) async {
    final validationError = validateSubjectName(name);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    emit(state.copyWith(isAddingSubject: true));
    try {
      final subject = await StudyTaskDao.createSubject(
        name: name,
        imagePath: 'assets/images/book.png',
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            subjects: [...state.subjects, subject],
            selectedSubject: subject,
            clearSubjectLoadError: true,
          ),
        );
      }
      return subject;
    } finally {
      if (!isClosed) emit(state.copyWith(isAddingSubject: false));
    }
  }

  Future<StudyTaskSaveResult> saveTask({
    required String title,
    required String description,
  }) async {
    final formState = state;
    if (formState.isSaving) return StudyTaskSaveResult.alreadySaving;

    final selectedSubject = formState.selectedSubject;
    if (selectedSubject == null) return StudyTaskSaveResult.missingSubject;
    if (validateTaskTitle(title) != null) {
      return StudyTaskSaveResult.invalidTitle;
    }
    final startMinutes =
        formState.startTime.hour * 60 + formState.startTime.minute;
    final endMinutes = formState.endTime.hour * 60 + formState.endTime.minute;
    if (endMinutes <= startMinutes) {
      return StudyTaskSaveResult.invalidTimeRange;
    }

    final now = DateTime.now();
    final startDateTime = DateTime(
      formState.lessonDate.year,
      formState.lessonDate.month,
      formState.lessonDate.day,
      formState.startTime.hour,
      formState.startTime.minute,
    );
    final endDateTime = DateTime(
      formState.lessonDate.year,
      formState.lessonDate.month,
      formState.lessonDate.day,
      formState.endTime.hour,
      formState.endTime.minute,
    );
    if (startDateTime.isBefore(now)) {
      return StudyTaskSaveResult.startBeforeNow;
    }
    if (endDateTime.isBefore(now)) {
      return StudyTaskSaveResult.endBeforeNow;
    }

    emit(state.copyWith(isSaving: true));
    try {
      final hasConflict = await StudyTaskDao.hasTimeConflict(
        formState.lessonDate,
        formState.startTime,
        formState.endTime,
      );
      if (hasConflict) return StudyTaskSaveResult.timeConflict;

      final taskId = await StudyTaskDao.create(
        CreateStudyTaskInput(
          subjectId: selectedSubject.id,
          title: title,
          description: description,
          lessonDate: formState.lessonDate,
          startTime: formState.startTime,
          endTime: formState.endTime,
          priority: formState.priority,
        ),
      );
      try {
        await TaskReminderNotifications.instance.scheduleTask(
          id: taskId,
          title: title.trim(),
          startsAt: startDateTime,
        );
      } on Exception {
        return StudyTaskSaveResult.savedButReminderFailed;
      }
      return StudyTaskSaveResult.saved;
    } finally {
      if (!isClosed) emit(state.copyWith(isSaving: false));
    }
  }
}
