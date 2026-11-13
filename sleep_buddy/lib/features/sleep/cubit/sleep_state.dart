import 'package:flutter/foundation.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';

@immutable
class SleepState {
  const SleepState({
    this.data,
    this.isLoading = true,
    this.isSaving = false,
    this.error,
  });

  final SleepData? data;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  SleepState copyWith({
    SleepData? data,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) => SleepState(
    data: data ?? this.data,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    error: clearError ? null : error ?? this.error,
  );
}
