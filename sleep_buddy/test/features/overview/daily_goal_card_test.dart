import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_buddy/features/overview/widgets/daily_gold_card.dart';

void main() {
  test('progress uses completed tasks over total tasks', () {
    final card = DailyGoalCard(
      completedTasks: 2,
      totalTasks: 4,
      remainingDuration: const Duration(hours: 3),
    );

    expect(card.progress, 0.5);
  });

  test('progress is zero when there are no tasks', () {
    final card = DailyGoalCard(
      completedTasks: 0,
      totalTasks: 0,
      remainingDuration: Duration.zero,
    );

    expect(card.progress, 0);
  });
}
