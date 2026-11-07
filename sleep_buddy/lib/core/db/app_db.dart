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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Bảng Môn học
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL
      )
    ''');

    // 2. Bảng Nhiệm vụ học tập (Study Tasks)
    await db.execute('''
      CREATE TABLE study_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        priority TEXT DEFAULT 'medium',
        status TEXT DEFAULT 'pending',
        scheduled_start_time TEXT,
        scheduled_end_time TEXT,
        estimated_minutes INTEGER DEFAULT 0,
        completed_at TEXT,
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');

    // 3. Bảng Phiên học tập & Nghỉ ngơi (Focus Sessions)
    await db.execute('''
      CREATE TABLE focus_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER,
        subject_id INTEGER,
        session_type TEXT NOT NULL, -- focus, short_break, long_break
        actual_duration_seconds INTEGER NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES study_tasks(id) ON DELETE SET NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL
      )
    ''');

    // 4. Bảng Nhật ký giấc ngủ (Sleep Logs)
    await db.execute('''
      CREATE TABLE sleep_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_date TEXT UNIQUE NOT NULL,
        sleep_start TEXT NOT NULL,
        sleep_end TEXT NOT NULL,
        total_sleep_minutes INTEGER NOT NULL,
        quality_score INTEGER NOT NULL,
        recommended_workload TEXT DEFAULT 'moderate',
        notes TEXT
      )
    ''');

    // // 5. Bảng Cẩm nang (Guides & Bite-sized cards)
    // await db.execute('''
    //   CREATE TABLE guides (
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     title TEXT NOT NULL,
    //     summary TEXT NOT NULL,
    //     content TEXT NOT NULL,
    //     guide_type TEXT DEFAULT 'bite_sized',
    //     tags TEXT
    //   )
    // ''');

    // // Chèn dữ liệu mẫu cho cẩm nang lúc nghỉ ngơi
    // await db.execute('''
    //   INSERT INTO guides (title, summary, content, guide_type, tags) VALUES
    //   ('Quy tắc 20-20-20', 'Mỗi 20 phút nhìn xa 20 feet (6m) trong 20 giây.', 'Giúp thư giãn các cơ mắt sau khi nhìn màn hình liên tục.', 'bite_sized', 'eye,rest'),
    //   ('Kỹ thuật hạ nhiệt cơ thể', 'Tắm nước ấm trước khi ngủ 90 phút.', 'Khi rời khỏi phòng tắm, cơ thể hạ nhiệt độ dần giúp kích thích buồn ngủ tự nhiên.', 'bite_sized', 'sleep')
    // ''');

     await db.execute('''
      CREATE TABLE guide_articles (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        read_time_label TEXT NOT NULL,
        image_path TEXT NOT NULL,
        cover_image INTEGER NOT NULL DEFAULT 0,
        display_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_guide_articles_category '
      'ON guide_articles(category)',
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}