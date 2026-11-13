import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_buddy/features/focus_rest/cubit/focus_rest_state.dart';

void main() {
  test('progress reflects elapsed time in the scheduled task window', () {
    const state = FocusRestState(
      plannedDuration: Duration(minutes: 10),
      remaining: Duration(minutes: 4),
    );

    expect(state.progress, 0.6);
  });

  test('progress is zero for an empty schedule and clamps to valid bounds', () {
    const emptyState = FocusRestState();
    const overrunState = FocusRestState(
      plannedDuration: Duration(minutes: 10),
      remaining: Duration(minutes: 12),
    );
    const completedState = FocusRestState(
      plannedDuration: Duration(minutes: 10),
      remaining: Duration.zero,
    );

    expect(emptyState.progress, 0);
    expect(overrunState.progress, 0);
    expect(completedState.progress, 1);
  });
}
