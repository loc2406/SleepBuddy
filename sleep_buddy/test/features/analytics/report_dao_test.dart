import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_buddy/core/db/report_dao.dart';

void main() {
  test('monthly chart bars follow calendar weeks starting on Monday', () {
    final bars = ReportDao.monthBars(DateTime(2026, 11), {
      '2026-11-01': 1.5,
      '2026-11-02': 2,
      '2026-11-08': 3,
      '2026-11-09': 4,
      '2026-11-30': 5,
    });

    expect(bars.map((bar) => bar.label).toList(), [
      'Tuần 1',
      'Tuần 2',
      'Tuần 3',
      'Tuần 4',
      'Tuần 5',
      'Tuần 6',
    ]);
    expect(bars.map((bar) => bar.hours).toList(), [1.5, 5, 4, 0, 0, 5]);
  });
}
