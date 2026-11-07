import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sleep_buddy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Bảng lưu hồ sơ người dùng và tên hiển thị trên ứng dụng.
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        display_name TEXT NOT NULL,
        avatar_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Bảng lưu danh mục môn học và màu hiển thị trong thống kê.
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color_hex TEXT NOT NULL,
        icon_name TEXT,
        image_path TEXT,
        display_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Bảng lưu bài học, lịch học, mức ưu tiên và trạng thái hoàn thành.
    await db.execute('''
      CREATE TABLE study_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        lesson_date TEXT NOT NULL,
        scheduled_start TEXT NOT NULL,
        scheduled_end TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'medium',
        status TEXT NOT NULL DEFAULT 'notStarted',
        image_path TEXT,
        estimated_minutes INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_study_tasks_date ON study_tasks(lesson_date)',
    );
    await db.execute(
      'CREATE INDEX idx_study_tasks_status ON study_tasks(status)',
    );
    await db.execute(
      'CREATE INDEX idx_study_tasks_date_status '
      'ON study_tasks(lesson_date, status)',
    );

    // Bảng ghi nhận các phiên học tập hoặc nghỉ ngơi thực tế.
    await db.execute('''
      CREATE TABLE focus_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER,
        subject_id INTEGER,
        session_type TEXT NOT NULL,
        mode TEXT NOT NULL DEFAULT 'study',
        planned_duration_seconds INTEGER NOT NULL DEFAULT 0,
        actual_duration_seconds INTEGER NOT NULL DEFAULT 0,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(task_id) REFERENCES study_tasks(id) ON DELETE SET NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_focus_sessions_started '
      'ON focus_sessions(started_at)',
    );
    await db.execute(
      'CREATE INDEX idx_focus_sessions_type_started '
      'ON focus_sessions(session_type, started_at)',
    );

    // Bảng lưu nhật ký giấc ngủ, chất lượng và gợi ý mỗi ngày.
    await db.execute('''
      CREATE TABLE sleep_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_date TEXT UNIQUE NOT NULL,
        sleep_start TEXT NOT NULL,
        sleep_end TEXT NOT NULL,
        recorded_sleep_minutes INTEGER NOT NULL,
        target_sleep_minutes INTEGER NOT NULL DEFAULT 480,
        quality_score INTEGER,
        mood TEXT NOT NULL DEFAULT 'normal',
        recommended_workload TEXT DEFAULT 'moderate',
        recommendation TEXT,
        notes TEXT
      )
    ''');

    // Bảng lưu cài đặt giấc ngủ dùng chung cho tất cả các ngày.
    await db.execute('''
      CREATE TABLE sleep_settings (
        id INTEGER PRIMARY KEY CHECK(id = 1),
        target_bedtime TEXT NOT NULL DEFAULT '22:45',
        reminder_time TEXT NOT NULL DEFAULT '22:15',
        reminder_enabled INTEGER NOT NULL DEFAULT 1,
        target_sleep_minutes INTEGER NOT NULL DEFAULT 480
      )
    ''');

    // Bảng lưu danh sách bài viết cẩm nang hiển thị trong thư viện.
    await db.execute('''
      CREATE TABLE guide_articles (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        tag TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL DEFAULT '',
        read_time_label TEXT NOT NULL,
        image_path TEXT NOT NULL,
        hero_image_path TEXT NOT NULL,
        golden_rule_title TEXT NOT NULL DEFAULT '',
        golden_rule_description TEXT NOT NULL DEFAULT '',
        applied_count INTEGER NOT NULL DEFAULT 0,
        cover_image INTEGER NOT NULL DEFAULT 0,
        display_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_guide_articles_category '
      'ON guide_articles(category)',
    );

    // Bảng lưu thứ tự và nội dung từng bước trong chi tiết cẩm nang.
    await db.execute('''
      CREATE TABLE guide_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        article_id TEXT NOT NULL,
        step_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        UNIQUE(article_id, step_number),
        FOREIGN KEY(article_id) REFERENCES guide_articles(id) ON DELETE CASCADE
      )
    ''');

    // Bảng lưu các bài cẩm nang mà người dùng đánh dấu yêu thích.
    await db.execute('''
      CREATE TABLE guide_bookmarks (
        article_id TEXT PRIMARY KEY,
        bookmarked_at TEXT NOT NULL,
        FOREIGN KEY(article_id) REFERENCES guide_articles(id) ON DELETE CASCADE
      )
    ''');

    // Bảng lưu số lần áp dụng và thời điểm áp dụng gần nhất của mỗi cẩm nang.
    await db.execute('''
      CREATE TABLE guide_progress (
        article_id TEXT PRIMARY KEY,
        applied_count INTEGER NOT NULL DEFAULT 0,
        last_applied_at TEXT,
        FOREIGN KEY(article_id) REFERENCES guide_articles(id) ON DELETE CASCADE
      )
    ''');

    // Bảng lưu thời gian cho các hoạt động không thuộc trực tiếp phiên tập trung.
    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_date TEXT NOT NULL,
        category TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        label TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_activity_logs_date ON activity_logs(activity_date)',
    );

    // Bảng lưu mục tiêu học, nghỉ và thời gian hoàn thành theo từng ngày.
    await db.execute('''
      CREATE TABLE daily_goals (
        activity_date TEXT PRIMARY KEY,
        study_goal_minutes INTEGER NOT NULL,
        study_completed_minutes INTEGER NOT NULL DEFAULT 0,
        rest_goal_minutes INTEGER NOT NULL DEFAULT 480
      )
    ''');

    // Bảng lưu cấu hình ứng dụng dưới dạng key-value.
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
