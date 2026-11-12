import 'package:sqflite/sqflite.dart';
import 'package:sleep_buddy/core/db/app_db.dart';

class SeedDao {
  static Future<void> seedIfEmpty() async {
    final db = await AppDatabase.instance.database;
    final profileCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM profiles'),
    );
    if (profileCount != null && profileCount > 0) return;

    await db.transaction((tx) async {
      final now = DateTime.now();
      final createdAt = now.toIso8601String();

      await tx.insert('profiles', {
        'display_name': 'User',
        'created_at': createdAt,
      });

      // await tx.insert('sleep_settings', {
      //   'id': 1,
      //   'target_bedtime': '22:45',
      //   'reminder_time': '22:15',
      //   'reminder_enabled': 1,
      //   'target_sleep_minutes': 480,
      // });

      // final subjects = [
      //   ['Toán học', '#9470F4', 'assets/images/book.png', 0],
      //   ['Tiếng Anh', '#82A7F4', 'assets/images/book.png', 1],
      //   ['Vật lý', '#84CC9C', 'assets/images/book.png', 2],
      //   ['Lịch sử', '#FFBE68', 'assets/images/book.png', 3],
      //   ['Hóa học', '#F2A67E', 'assets/images/book.png', 4],
      //   ['Tiếng Việt', '#E38DAA', 'assets/images/book.png', 5],
      //   ['Đạo đức', '#D2A75B', 'assets/images/book.png', 6],
      //   ['Tự nhiên và Xã hội', '#77BFA3', 'assets/images/book.png', 7],
      //   ['Khoa học', '#63A6A2', 'assets/images/book.png', 8],
      //   ['Khoa học tự nhiên', '#5DA6C5', 'assets/images/book.png', 9],
      //   ['Sinh học', '#7DBE78', 'assets/images/book.png', 10],
      //   ['Địa lý', '#6DB2A4', 'assets/images/book.png', 11],
      //   ['Lịch sử và Địa lý', '#C79A6B', 'assets/images/book.png', 12],
      //   ['Tin học', '#6F9DD8', 'assets/images/book.png', 13],
      //   ['Công nghệ', '#B28A67', 'assets/images/book.png', 14],
      //   ['Giáo dục công dân', '#C0A45E', 'assets/images/book.png', 15],
      //   ['Giáo dục thể chất', '#ED8C78', 'assets/images/book.png', 16],
      //   ['Âm nhạc', '#CF8BCB', 'assets/images/book.png', 17],
      //   ['Mỹ thuật', '#E19A9A', 'assets/images/book.png', 18],
      //   ['Hoạt động trải nghiệm', '#9A91D8', 'assets/images/book.png', 19],
      //   [
      //     'Hoạt động trải nghiệm, hướng nghiệp',
      //     '#8B8FC7',
      //     'assets/images/book.png',
      //     20,
      //   ],
      //   [
      //     'Giáo dục quốc phòng và An ninh',
      //     '#A6A36A',
      //     'assets/images/book.png',
      //     21,
      //   ],
      //   ['Kinh tế và Pháp luật', '#B58C72', 'assets/images/book.png', 22],
      // ];

      // for (final subject in subjects) {
      //   await tx.insert('subjects', {
      //     'name': subject[0],
      //     'color_hex': subject[1],
      //     'image_path': subject[2],
      //     'display_order': subject[3],
      //   });
      // }

      // final subjectRows = await tx.query('subjects', columns: ['id', 'name']);
      // final subjectIds = {
      //   for (final row in subjectRows) row['name'] as String: row['id'] as int,
      // };

      // for (var offset = 0; offset < 7; offset++) {
      //   final date = _dateOnly(
      //     now.subtract(Duration(days: now.weekday - 1)),
      //   ).add(Duration(days: offset));
      //   await _seedWeekDayTasks(tx, date, subjectIds);
      // }

      // await _seedSessions(tx, now, subjectIds);
      await _seedSleep(tx, now);
      await _seedGoals(tx, now);
      await _seedGuideSteps(tx);

      final settings = {
        'study_duration_minutes': '30',
        'short_break_minutes': '5',
        'long_break_minutes': '15',
        'finish_sound_enabled': 'false',
      };
      for (final entry in settings.entries) {
        await tx.insert('app_settings', {
          'key': entry.key,
          'value': entry.value,
          'updated_at': createdAt,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  static Future<void> _seedWeekDayTasks(
    Transaction tx,
    DateTime date,
    Map<String, int> subjectIds,
  ) async {
    final dateText = _dateOnly(date).toIso8601String().substring(0, 10);
    final createdAt = DateTime.now().toIso8601String();
    final lessons = [
      [
        'Hàm số và đồ thị',
        'Ôn tập hàm bậc hai và cách vẽ đồ thị',
        'Toán học',
        '08:00',
        '09:30',
        'high',
        'completed',
      ],
      [
        'Luyện nghe IELTS',
        'Luyện Section 3 và ghi chú từ khóa',
        'Tiếng Anh',
        '10:00',
        '11:00',
        'medium',
        'inProgress',
      ],
      [
        'Điện xoay chiều',
        'Làm bài tập về mạch RLC',
        'Vật lý',
        '14:00',
        '15:30',
        'high',
        'notStarted',
      ],
      [
        'Chiến tranh thế giới thứ hai',
        'Tóm tắt diễn biến và đọc tài liệu tham khảo',
        'Lịch sử',
        '16:00',
        '17:00',
        'low',
        'completed',
      ],
    ];

    for (final lesson in lessons) {
      await tx.insert('study_tasks', {
        'subject_id': subjectIds[lesson[2]],
        'title': lesson[0],
        'description': lesson[1],
        'lesson_date': dateText,
        'scheduled_start': lesson[3],
        'scheduled_end': lesson[4],
        'priority': lesson[5],
        'status': lesson[6],
        'image_path': 'assets/images/book.png',
        'created_at': createdAt,
        'updated_at': createdAt,
      });
    }
  }

  static Future<void> _seedSessions(
    Transaction tx,
    DateTime now,
    Map<String, int> subjectIds,
  ) async {
    final data = <List<Object?>>[
      ['study', 'Toán học', 2 * 3600 + 30 * 60],
      ['break', 'Vật lý', 45 * 60],
      ['study', 'Tiếng Anh', 1 * 3600 + 45 * 60],
      ['study', 'Vật lý', 2 * 3600],
      ['study', 'Hóa học', 3 * 3600 + 30 * 60],
    ];

    for (var index = 0; index < 7; index++) {
      final day = _dateOnly(now.subtract(Duration(days: index)));
      for (final item in data) {
        final subjectName = item[1] as String;
        final seconds = item[2] as int;
        final started = day.add(Duration(hours: 8 + index, minutes: 15));
        await tx.insert('focus_sessions', {
          'subject_id': subjectIds[subjectName],
          'session_type': item[0],
          'mode': item[0] == 'study' ? 'study' : 'relax',
          'planned_duration_seconds': seconds,
          'actual_duration_seconds': seconds,
          'started_at': started.toIso8601String(),
          'ended_at': started.add(Duration(seconds: seconds)).toIso8601String(),
          'completed': 1,
        });
      }
    }
  }

  static Future<void> _seedSleep(Transaction tx, DateTime now) async {
    final yesterday = _dateOnly(now.subtract(const Duration(days: 1)));
    await tx.insert('sleep_logs', {
      'log_date': _dateOnly(now).toIso8601String().substring(0, 10),
      'sleep_start': yesterday.add(const Duration(hours: 23)).toIso8601String(),
      'sleep_end': _dateOnly(
        now,
      ).add(const Duration(hours: 6, minutes: 45)).toIso8601String(),
      'recorded_sleep_minutes': 465,
      'target_sleep_minutes': 480,
      'quality_score': 97,
      'mood': 'normal',
      'recommended_workload': 'moderate',
      'recommendation': 'Bắt đầu nhẹ nhàng và nghỉ đều giữa các phiên.',
    });
  }

  static Future<void> _seedGoals(Transaction tx, DateTime now) async {
    for (var index = 0; index < 7; index++) {
      final day = _dateOnly(now.subtract(Duration(days: index)));
      await tx.insert('daily_goals', {
        'activity_date': _dateOnly(day).toIso8601String().substring(0, 10),
        'study_goal_minutes': 300,
        'study_completed_minutes': index == 0 ? 225 : 180 + index * 15,
        'rest_goal_minutes': 480,
      });
    }

    for (var index = 0; index < 7; index++) {
      final day = _dateOnly(now.subtract(Duration(days: 6 - index)));
      await tx.insert('activity_logs', {
        'activity_date': _dateOnly(day).toIso8601String().substring(0, 10),
        'category': 'other',
        'duration_seconds': (60 + index * 10) * 60,
        'label': 'Hoạt động khác',
        'created_at': day.toIso8601String(),
      });
    }
  }

  static Future<void> _seedGuideSteps(Transaction tx) async {
    final steps = {
      'eyes': [
        [
          1,
          'Chớp mắt nhanh 10–15 lần',
          'Giúp trải đều nước mắt sinh học, chống khô rát.',
        ],
        [
          2,
          'Nhìn xa trong 20 giây',
          'Tập trung vào vật cách xa ít nhất 6 mét.',
        ],
        [3, 'Đảo mắt theo hình số 8', 'Lặp lại luân chuyển chậm 5 lần.'],
      ],
      'pomodoro': [
        [
          1,
          'Chọn một nhiệm vụ cụ thể',
          'Xác định kết quả mong muốn trước khi bắt đầu.',
        ],
        [
          2,
          'Tập trung trong 25 phút',
          'Tắt thông báo và không chuyển sang việc khác.',
        ],
        [3, 'Nghỉ ngắn trong 5 phút', 'Đứng dậy, uống nước hoặc thư giãn mắt.'],
      ],
      'sleep': [
        [1, 'Giảm ánh sáng mạnh', 'Hạ đèn và màn hình trước giờ ngủ.'],
        [2, 'Chốt lại công việc', 'Viết nhiệm vụ hôm sau để giảm suy nghĩ.'],
        [
          3,
          'Giữ giờ ngủ đều nhau',
          'Đi ngủ và thức dậy trong khung giờ ổn định.',
        ],
      ],
      'memory': [
        [1, 'Ghi lại kiến thức chính', 'Tóm tắt lại mà không nhìn tài liệu.'],
        [2, 'Chờ khoảng cách phù hợp', 'Ôn lại sau 1 ngày, 3 ngày và 7 ngày.'],
        [3, 'Tự kiểm tra', 'Dùng câu hỏi thay vì đọc lại thụ động.'],
      ],
    };

    for (final entry in steps.entries) {
      for (final step in entry.value) {
        await tx.insert('guide_steps', {
          'article_id': entry.key,
          'step_number': step[0],
          'title': step[1],
          'description': step[2],
        });
      }
    }
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
