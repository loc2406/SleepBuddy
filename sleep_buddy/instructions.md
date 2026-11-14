# SleepBuddy — sổ tay kỹ thuật

Tài liệu dành cho người đọc/sửa mã nguồn. Phần giới thiệu dành cho người dùng cuối
nằm ở [`../README.md`](../README.md).

## 1. Tổng quan

SleepBuddy là ứng dụng Flutter, hiện tập trung cho Android, hoạt động **offline-first**:

- Không có backend, không đăng nhập, không đồng bộ đám mây.
- Toàn bộ dữ liệu nằm trong SQLite trên thiết bị (`sleep_buddy.db`).
- Điều hướng bằng GoRouter, quản lý trạng thái bằng Cubit (`flutter_bloc`).
- Có 5 khu vực: Tổng quan, Lịch học, Tập trung/Nghỉ, Giấc ngủ, Thống kê & Cài đặt.

Khi thêm tính năng, hãy bám theo luồng dữ liệu thật đang chạy:
**Screen → Cubit/state → DAO/service → SQLite**, không lấy dữ liệu seed/hardcode làm
chuẩn nghiệp vụ.

## 2. Công cụ và phiên bản

### 2.1 Toolchain đã kiểm tra

| Thành phần | Phiên bản |
|------------|-----------|
| Flutter | 3.47.9 (stable) |
| Dart | 3.13.7 |
| DevTools | 2.60.0 |
| Engine | Impeller (mặc định trên Android) |

`pubspec.yaml` khai báo `environment.sdk: ^3.10.0-290.4.beta` và phiên bản ứng dụng
`1.0.0+1`.

### 2.2 Thư viện chạy (dependency trực tiếp)

Phiên bản dưới đây lấy từ `pubspec.lock`:

| Package | Phiên bản | Dùng cho |
|---------|-----------|----------|
| `flutter_bloc` | 9.1.1 | Cubit/Bloc và `BlocProvider`, `BlocBuilder` |
| `go_router` | 17.2.3 | Điều hướng, query param `tab`, `taskId` |
| `sqflite` | 2.4.5 | SQLite trên Android/iOS |
| `path` | 1.9.1 | Ghép đường dẫn file database |
| `shared_preferences` | 2.5.6 | Lưu lựa chọn giao diện sáng/tối |
| `flutter_local_notifications` | 19.5.0 | Thông báo cục bộ, hẹn giờ, action |
| `timezone` | 0.10.1 | `TZDateTime`, lịch theo múi giờ địa phương |
| `flutter_timezone` | 5.1.1 | Đọc mã múi giờ của thiết bị |
| `permission_handler` | 13.0.2 | Quyền thông báo, mở cài đặt hệ thống |
| `fl_chart` | 1.3.0 | Biểu đồ tròn/cột |
| `animated_bottom_navigation_bar` | 1.4.1 | Thanh 5 tab dưới |
| `cupertino_icons` | 1.0.9 | Bộ icon |
| `flutter_launcher_icons` | 0.14.4 | Sinh icon ứng dụng từ `assets/icons/app_icon.png` |

Dev dependency: `flutter_test` (SDK) và `flutter_lints` 6.0.0.

### 2.3 Cấu hình Android

| Hạng mục | Giá trị |
|----------|---------|
| `namespace` / `applicationId` | `com.example.sleep_buddy` |
| Nhãn ứng dụng | `Sleep Buddy` |
| `compileSdk` | 37 |
| `minSdk` | `flutter.minSdkVersion` (hiện là 24 / Android 7.0) |
| `targetSdk` | `flutter.targetSdkVersion` (hiện là 36) |
| Java | 17 |
| Desugaring | `desugar_jdk_libs:2.1.4` |
| Gradle | 8.14.3 |
| AGP | 8.11.1 |
| Kotlin | 2.2.20 |
| Ký release | `signingConfigs.getByName("debug")` |

Quyền trong `AndroidManifest.xml`:

- `POST_NOTIFICATIONS` — Android 13+.
- `SCHEDULE_EXACT_ALARM` — nhắc đúng giờ.
- `RECEIVE_BOOT_COMPLETED` — khôi phục lịch nhắc sau khi khởi động lại máy.
- Receiver của `flutter_local_notifications` cho `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`,
  `QUICKBOOT_POWERON`.

### 2.4 Tài nguyên

`pubspec.yaml` khai báo 4 thư mục asset:

```text
assets/images/      18 ảnh
assets/focus_rest/  16 ảnh
assets/wellness/    15 ảnh
assets/icons/        1 ảnh (app_icon.png)
```

## 3. Chạy, kiểm tra và build

```shell
cd sleep_buddy
flutter pub get
flutter run
```

Mở máy ảo Android trên Windows bằng `start_emulator.bat` ở thư mục gốc (AVD
`Pixel_7_Pro`).

Kiểm tra code:

```shell
flutter analyze
flutter test
```

Build bản release:

```shell
flutter build apk --release
# Kết quả: build/app/outputs/flutter-apk/app-release.apk
```

Lưu ý:

- Bản release **đang ký bằng debug keystore**, chỉ phù hợp chia sẻ nội bộ. Trước khi
  phát hành thật, tạo keystore riêng, thêm `key.properties` (không commit), cập nhật
  `signingConfigs` trong `android/app/build.gradle.kts`, đổi `applicationId`.
- iOS có scaffold nhưng **chưa có `Podfile`**; deployment target trong
  `project.pbxproj` là 13.0. Cần chạy `flutter create .`/cấu hình Pods trước khi build.
- Web/Windows/Linux có scaffold nhưng `sqflite` chỉ hỗ trợ mobile nên chưa dùng được.

## 4. Kiến trúc và khởi động

### 4.1 Điểm vào

[`lib/main.dart`](lib/main.dart):

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `_bootstrap()` chạy lần lượt, mỗi bước bọc trong `_runStartupStep`:
   - `SharedPref.init`
   - mở `AppDatabase.instance.database`
   - `GuideArticleDao.seedIfEmpty`
   - `DemoDataDao.applyMode(DemoDataMode.populated)`
   - `TaskReminderNotifications.instance.initialize(...)`
   - xử lý payload khi mở app từ thông báo
   - `syncScheduledReminders()`
3. `runApp(const MyApp())`.

Mỗi bước khởi động được cô lập lỗi để một sự cố cục bộ (múi giờ lạ, dữ liệu cũ,
quyền thông báo bị từ chối…) không chặn `runApp`. Riêng nếu bước `notifications`
thất bại, hai bước xử lý payload và đồng bộ lịch nhắc sẽ bị bỏ qua.

### 4.2 Các Cubit cấp ứng dụng

`MyApp` bọc `MultiBlocProvider`:

| Cubit | Ghi chú |
|-------|---------|
| `MinuteTickerCubit` | Tick mỗi phút + khi app quay lại foreground; `lazy: false` |
| `OverviewCubit` | Nhận `MinuteTickerCubit` |
| `AddNewStudyPlanCubit` | Form thêm nhiệm vụ |
| `StudyPlannerCubit` | `lazy: false` |
| `FocusRestCubit` | Nhận `MinuteTickerCubit`, `lazy: false` |
| `SleepCubit` | `lazy: false` |
| `AnalyticsCubit` | Báo cáo |
| `SettingCubit` | Theme, thời lượng, thông báo |
| `LibraryCubit` | Cẩm nang |

`MaterialApp.router` dùng `appRouter`, `AppTheme.light`, `AppTheme.dark` và
`themeMode` từ `SettingCubit`.

### 4.3 Trách nhiệm từng lớp

| Lớp | Trách nhiệm | Không nên làm |
|-----|-------------|----------------|
| **Screen/Widget** | Dựng UI, `BlocBuilder`, chuyển thao tác người dùng tới Cubit | Viết SQL, gọi DAO trực tiếp, giữ logic nghiệp vụ |
| **Cubit** | Tải dữ liệu, kiểm tra điều kiện, điều phối DAO/service, phát state | Giữ `BuildContext` |
| **State** | Dữ liệu cần render; immutable + `copyWith` | Chứa service/controller |
| **DAO** | Toàn bộ truy vấn SQLite | Chứa logic UI |
| **Model** | Khuôn dữ liệu theo feature | Trộn model UI với model lưu trữ nếu khác nhau |

Khi screen cần Cubit, lấy một lần rồi dùng lại:

```dart
final _cubit = context.read<FeatureCubit>();
```

### 4.4 Điều hướng

[`lib/core/router/app_router.dart`](lib/core/router/app_router.dart):

| Route | Ý nghĩa |
|-------|---------|
| `/` | `HomeScreen`; query `tab` (0–4), `taskId`, `startRejected` |
| `/guide/:guideId` | Chi tiết cẩm nang; dữ liệu truyền qua `state.extra` |
| `/study-plan/add` | Form thêm nhiệm vụ |

Thông báo mở app bằng `appRouter.go('/?tab=...')`:

- `tab=1`: Lịch học.
- `tab=2&taskId=...`: Tập trung.
- `tab=3`: Giấc ngủ.
- `tab=1&startRejected=true`: hiện SnackBar "Khung giờ của nhiệm vụ đã kết thúc."

### 4.5 Ticker và theme

- [`lib/core/cubit/minute_ticker_cubit.dart`](lib/core/cubit/minute_ticker_cubit.dart)
  phát tick mỗi phút và khi app quay lại foreground. Không tạo timer định kỳ riêng nếu
  tác vụ có thể dùng ticker này.
- [`lib/core/config/app_style.dart`](lib/core/config/app_style.dart) chứa màu, bề mặt,
  dialog, modal. Hộp thoại/bộ chọn ngày giờ dùng `AppStyle.dialogTheme` hoặc
  `AppStyle.modalBuilder` để thống nhất ở cả theme sáng/tối.

## 5. Cấu trúc thư mục

```text
lib/
  main.dart
  core/
    config/         AppStyle dùng chung
    constants/      Asset, màu, bán kính
    cubit/          MinuteTickerCubit
    db/             AppDatabase + các DAO
    errors/         (đang trống)
    notifications/  TaskReminderNotifications
    router/         appRouter
    services/       (đang trống)
    theme/          AppTheme sáng/tối
    utils/          responsive, shared_pref
    widgets/        widget dùng chung
  features/
    analytics/
      cubit/  model/  screens/  widgets/
    focus_rest/
      cubit/  screens/  widgets/
    overview/
      cubit/  screens/  widgets/
    sleep/
      cubit/  screens/  widgets/
    study_plan/
      cubit/  model/  screens/  widgets/
    home_screen.dart
test/
```

Ghi chú:

- `core/errors/` và `core/services/` hiện **trống**; không cần tạo abstraction chỉ để
  lấp thư mục.
- Không có `presentation/` trong các feature; đường dẫn dùng trực tiếp
  `features/<name>/screens/...`.
- [`lib/features/analytics/cubit/settting_cubit.dart`](lib/features/analytics/cubit/settting_cubit.dart)
  có ba chữ `t` trong tên. Giữ nguyên tên file này khi sửa để không phá import.

Các màn hình chính:

- Tổng quan: [`lib/features/overview/screens/overview_screen.dart`](lib/features/overview/screens/overview_screen.dart)
- Lịch học: [`lib/features/study_plan/screens/study_planner_screen.dart`](lib/features/study_plan/screens/study_planner_screen.dart)
- Thêm nhiệm vụ: [`lib/features/study_plan/screens/add_study_task_screen.dart`](lib/features/study_plan/screens/add_study_task_screen.dart)
- Tập trung/Nghỉ: [`lib/features/focus_rest/screens/focus_rest_screen.dart`](lib/features/focus_rest/screens/focus_rest_screen.dart)
- Giấc ngủ: [`lib/features/sleep/screens/sleep_screen.dart`](lib/features/sleep/screens/sleep_screen.dart)
- Thống kê/Cài đặt: [`lib/features/analytics/screens/analytics_screen.dart`](lib/features/analytics/screens/analytics_screen.dart)
  (bên trong chuyển giữa `ReportScreen`, `LibraryScreen`, `SettingsScreen`)
- Ghép tab: [`lib/features/home_screen.dart`](lib/features/home_screen.dart)

`HomeScreen` chỉ ghép tab và truyền `taskId`; không đặt logic tính giờ hay hoàn thành
nhiệm vụ tại đây.

## 6. Cơ sở dữ liệu

### 6.1 Thông tin chung

- File: `sleep_buddy.db`, tạo bởi [`lib/core/db/app_db.dart`](lib/core/db/app_db.dart).
- `version: 1`, bật `PRAGMA foreign_keys = ON`.
- Hiện chỉ có `onCreate`; **chưa có migration**. Khi đổi schema phải tăng version và
  thêm `onUpgrade`, không chỉ sửa `onCreate`.

13 bảng:

| Bảng | Nội dung chính |
|------|----------------|
| `profiles` | `display_name`, `avatar_path`, `created_at` |
| `subjects` | `name` (unique), `color_hex`, `icon_name`, `image_path`, `display_order` |
| `study_tasks` | `subject_id`, `title`, `lesson_date`, `scheduled_start/end`, `priority`, `status`, ảnh, `completed_at` |
| `focus_sessions` | `task_id`, `subject_id`, `session_type`/`mode`, thời lượng dự kiến/thực tế, `started_at`, `ended_at`, `completed` |
| `sleep_logs` | `log_date` (unique), `sleep_start`, `sleep_end`, phút ngủ, mục tiêu, chất lượng, cảm xúc, gợi ý, ghi chú |
| `sleep_settings` | Một dòng (`id = 1`): giờ ngủ mục tiêu, giờ nhắc, bật/tắt nhắc, số phút mục tiêu |
| `guide_articles` | Bài cẩm nang: danh mục, tiêu đề, ảnh, quy tắc vàng, thứ tự |
| `guide_steps` | Các bước của bài, unique `(article_id, step_number)` |
| `guide_bookmarks` | Bài yêu thích |
| `guide_progress` | Tiến độ đọc |
| `activity_logs` | Nhật ký hoạt động |
| `daily_goals` | Mục tiêu học/nghỉ theo ngày |
| `app_settings` | Key–value: theme, thời lượng, thông báo… |

Index đáng chú ý: `study_tasks(lesson_date)`, `study_tasks(status)`,
`study_tasks(lesson_date, status)`, `focus_sessions(started_at)`,
`focus_sessions(session_type, started_at)`, `guide_articles(category)`.

### 6.2 DAO

| DAO | Phụ trách |
|-----|-----------|
| [`study_task_dao.dart`](lib/core/db/study_task_dao.dart) | Nhiệm vụ, trạng thái, nhắc việc, thống kê hoàn thành |
| [`focus_session_dao.dart`](lib/core/db/focus_session_dao.dart) | Phiên học/nghỉ, chuyển đoạn, kết thúc nhiệm vụ |
| [`dashboard_dao.dart`](lib/core/db/dashboard_dao.dart) | Số liệu Tổng quan, thời gian theo môn |
| [`report_dao.dart`](lib/core/db/report_dao.dart) | Báo cáo ngày/tuần/tháng |
| [`sleep_dao.dart`](lib/core/db/sleep_dao.dart) | Nhật ký và cài đặt giấc ngủ |
| [`settings_dao.dart`](lib/core/db/settings_dao.dart) | `app_settings` key–value |
| [`guide_article_dao.dart`](lib/core/db/guide_article_dao.dart) | Danh sách cẩm nang |
| [`guide_detail_dao.dart`](lib/core/db/guide_detail_dao.dart) | Chi tiết/bước cẩm nang |
| [`profile_dao.dart`](lib/core/db/profile_dao.dart) | Hồ sơ người dùng |
| [`seed_dao.dart`](lib/core/db/seed_dao.dart) | Seed dữ liệu nền |
| [`demo_data_dao.dart`](lib/core/db/demo_data_dao.dart) | Chuyển chế độ demo |
| [`app_db.dart`](lib/core/db/app_db.dart) | Mở DB, tạo schema |

Thêm truy vấn vào DAO của domain tương ứng; không đặt SQL trong screen/Cubit.

### 6.3 Seed và demo

[`lib/core/db/demo_data_dao.dart`](lib/core/db/demo_data_dao.dart):

- `DemoDataMode.empty`: gọi `clearDemoData()` để xoá dữ liệu các bảng nghiệp vụ.
- `DemoDataMode.populated`: gọi `SeedDao.seedIfEmpty()`.
- `restoreDemoData()`: xoá trước, sau đó seed cẩm nang và dữ liệu nền.

`main.dart` gọi `GuideArticleDao.seedIfEmpty()` riêng trước bước `demo data`.

`SeedDao` hiện chỉ tạo hồ sơ, mục tiêu ngày, bước cẩm nang và vài giá trị
`app_settings`. Phần nhiệm vụ học, phiên học và cài đặt ngủ đang bị comment;
**không seed nhật ký ngủ**. Vì vậy lần đầu mở, Lịch học và Giấc ngủ sẽ trống. Không xây
tính năng dựa trên giả định dữ liệu seed luôn tồn tại.

## 7. Nghiệp vụ chính

### 7.1 Tổng quan

- `OverviewCubit` nghe `MinuteTickerCubit`, tải song song:
  - thời gian học/nghỉ hôm nay (`DashboardDao.getStudyAndBreakDuration`),
  - nhiệm vụ kế tiếp (`DashboardDao.getNextTask`),
  - thời gian theo môn (`DashboardDao.getStudyMinutesBySubject`).
- Biểu đồ phân bổ hỗ trợ: hôm nay, hôm qua, tuần hiện tại, tháng hiện tại. Hôm qua dùng
  `ReportPeriod.day`, tuần/tháng dùng `ReportDao.getReport`.
- Tiến độ mục tiêu ngày = số nhiệm vụ `completed` / tổng nhiệm vụ trong ngày. Không có
  nhiệm vụ thì tiến độ bằng 0.

### 7.2 Lịch học

- Enum: `LessonPriority { high, medium, low }`,
  `LessonStatus { notStarted, inProgress, completed }`,
  `LessonFilter { all, notStarted, inProgress, completed }`.
- Nhiệm vụ mới mặc định `medium` và `notStarted`.
- `StudyPlannerCubit` tải bài theo ngày/bộ lọc; `AddNewStudyPlanCubit` xử lý form.
- Chỉ nhiệm vụ `notStarted` mới được nhắc bắt đầu; `inProgress` được nhắc kết thúc.
- Khi nhiệm vụ hoàn thành, ghi `completed_at`/`updated_at`; tiến độ ngày được tính lại
  từ `study_tasks`, không cộng dồn vào `daily_goals`.

### 7.3 Tập trung/Nghỉ

- `FocusRestCubit` dùng ticker chung để bù thời gian khi app quay lại foreground, đồng
  thời chạy timer 1 giây **chỉ khi** có nhiệm vụ đang chạy để cập nhật đếm ngược.
- Khi chuyển chế độ học ↔ nghỉ, `FocusSessionDao.switchSegment` đóng đoạn hiện tại và
  mở đoạn mới trong `focus_sessions`.
- Hết `scheduled_end`, Cubit đóng đoạn cuối, lưu tổng thời gian, chuyển nhiệm vụ sang
  `completed` và phát state `FocusRestStatus.completed` kèm tổng kết.
- Thông báo kết thúc mở lại tab Tập trung và hiển thị tổng kết.
- State: `FocusRestStatus { idle, loading, running, completed }`.

### 7.4 Giấc ngủ

`SleepCubit` đọc/ghi qua `SleepDao`:

- Nhật ký gắn với **ngày thức dậy**. Nếu giờ ngủ muộn hơn giờ thức dậy, giờ ngủ được
  tính là đêm hôm trước (`sleepIntervalForWakeDate`).
- Từ chối lưu nếu giờ thức nằm trong tương lai hoặc khoảng ngủ ≥ 24 giờ.
- Cho phép ghi/chỉnh giờ ngủ, giờ thức, ghi chú, cảm nhận; chỉnh giờ ngủ mục tiêu, giờ
  nhắc và bật/tắt nhắc.
- `sleep_settings` chỉ có một dòng (`id = 1`). Mặc định: ngủ 22:45, nhắc 22:15, bật
  nhắc, mục tiêu 480 phút.
- Nhắc ngủ chỉ được lên lịch khi **cả** `sleep_settings.reminder_enabled` **và**
  `app_settings.notifications_enabled` đều bật. Nếu giờ nhắc hôm nay đã qua, chọn ngày
  mai (`nextReminderDate`).

### 7.5 Báo cáo

`ReportDao.getReport(period, now)` trả về chỉ số, biểu đồ giờ học, thời gian theo môn
và mức hoàn thành kế hoạch:

- Ngày: đúng ngày được chọn.
- Tuần: Thứ 2 → Chủ nhật.
- Tháng: từ ngày 1 đến ngày cuối tháng; biểu đồ cột gom theo **tuần lịch** bắt đầu Thứ 2.
- Các chỉ số dùng cùng khoảng thời gian với biểu đồ.

`AnalyticsScreen` tự quản lý tải báo cáo bằng `StatefulWidget` và gọi `ReportDao`
trực tiếp. Đây là ngoại lệ hiện hữu; **không dùng làm mẫu Cubit mới** cho feature khác.

### 7.6 Cài đặt và cẩm nang

- `SettingCubit` giữ: thời lượng tập trung (mặc định 30 phút), nghỉ ngắn (5), nghỉ dài
  (15), âm thanh kết thúc (tắt), thông báo (tắt), theme.
- Theme lưu bằng `shared_preferences` khóa `theme_mode`; các cài đặt còn lại lưu trong
  `app_settings`.
- Bật thông báo sẽ xin `Permission.notification`; nếu bị từ chối vĩnh viễn thì mở cài
  đặt hệ thống. Trên Android 12+ còn xin quyền báo thức chính xác. Tắt thông báo sẽ
  `cancelAll()`.
- `LibraryCubit` tải danh sách cẩm nang, tìm kiếm và lọc theo chủ đề. Route
  `/guide/:guideId` hiện dựng nội dung bước **cố định** trong router, chưa đọc
  `guide_steps`; các bảng `guide_bookmarks`/`guide_progress` chưa có UI sử dụng.

## 8. Thông báo và múi giờ

### 8.1 Khởi tạo

[`lib/core/notifications/task_reminder_notifications.dart`](lib/core/notifications/task_reminder_notifications.dart):

- Android dùng icon `ic_notification` (`android/app/src/main/res/drawable/ic_notification.png`).
  `res/raw/keep.xml` giữ icon này để trình rút gọn tài nguyên của release không xoá mất.
- iOS khai báo category `study_task_reminder` với hai action `start_task` ("Bắt đầu")
  và `later_task` ("Để sau").
- Chỉ lên lịch trên Android/iOS; web/desktop bỏ qua.

### 8.2 Kênh và mức ưu tiên

- Kênh gốc: `study_task_reminders`.
- Kênh theo ưu tiên: `study_task_reminders_high`, `_medium`, `_low`.
- Ưu tiên cao: `Importance.max` / `Priority.max`, có âm thanh.
- Trung bình: `Importance.high` / `Priority.high`.
- Thấp: `Importance.low` / `Priority.low` (yên lặng).
- Nhắc ngủ: kênh `sleep_bedtime_reminder`, importance/priority high nhưng tắt âm thanh
  và rung; ID `0x7fffffff`, payload `sleep_reminder`.
- Mức ưu tiên **chỉ** đổi độ nổi bật; thời điểm nhắc vẫn là `scheduled_start` của
  nhiệm vụ, không gửi sớm hơn.

### 8.3 Đồng bộ lịch nhắc

`syncScheduledReminders()`:

1. Nếu `notifications_enabled = false` → `cancelAll()` rồi dừng.
2. Lấy nhiệm vụ `notStarted` còn ở tương lai và `inProgress` chưa hết giờ.
3. Tính lời nhắc ngủ kế tiếp nếu được bật.
4. Huỷ các thông báo đã hẹn nhưng không còn trong danh sách hợp lệ.
5. Hẹn lại nhắc bắt đầu, nhắc kết thúc và nhắc ngủ.

Gọi đồng bộ sau khi: thêm/sửa/xóa nhiệm vụ, chuyển trạng thái, đổi cài đặt ngủ, bật/tắt
thông báo, khởi động app.

### 8.4 Xử lý khi người dùng chạm thông báo

| Payload/action | Hành vi |
|----------------|---------|
| `start_task` | Mở tab 2 với `taskId`, bắt đầu nhiệm vụ |
| Chạm thân thông báo bắt đầu | Mở tab 2 với `taskId` |
| Nhiệm vụ không còn trong khung giờ | Mở tab 1 kèm `startRejected=true` |
| Nhắc ngủ | Mở tab 3 |
| `later_task` | Bỏ qua, không mở app |

### 8.5 Xử lý múi giờ trên thiết bị lạ

Đây là lỗi đã từng làm bản release crash trước `runApp` trên một số máy Android.

- `flutter_timezone` có thể trả về mã ngoài IANA như `GMT+07:00`.
- `tz.getLocation(name)` khi đó ném `LocationNotFoundException`.
- Cách xử lý hiện tại trong `_configureLocalTimeZone()`:
  1. `tz.initializeTimeZones()`.
  2. Thử đọc mã thiết bị và `tz.setLocalLocation(tz.getLocation(name))`.
  3. Nếu mã rỗng/không hợp lệ: parse offset cố định bằng `_parseFixedOffset` (hỗ trợ
     `GMT+7`, `UTC-05:30`…).
  4. Nếu vẫn thất bại: dùng `DateTime.now().timeZoneOffset`.
  5. Tạo `tz.Location` cố định bằng `_fixedOffsetLocation`.
- Toàn bộ bước khởi tạo thông báo nằm trong `_runStartupStep`, nên lỗi không chặn
  giao diện chính.

Khi sửa phần này, giữ nguyên nguyên tắc: **luôn đảm bảo `tz.local` được đặt** trước khi
gọi `zonedSchedule`.

### 8.6 Giới hạn

- Thời điểm hiển thị thực tế còn phụ thuộc quyền thông báo, cài đặt kênh của hệ điều
  hành và chính sách tiết kiệm pin.
- `SCHEDULE_EXACT_ALARM` có thể bị người dùng tắt; khi đó nhắc có thể trễ.
- Không có cơ chế push từ xa; mọi lời nhắc đều là cục bộ.

## 9. Test và chất lượng

6 file test:

| File | Nội dung |
|------|----------|
| `test/core/notifications/task_reminder_notifications_test.dart` | Độ nổi bật/âm thanh theo mức ưu tiên |
| `test/features/analytics/report_dao_test.dart` | Cột tháng gom theo tuần lịch bắt đầu Thứ 2 |
| `test/features/focus_rest/focus_rest_state_test.dart` | Tiến độ theo thời gian, trường hợp lịch rỗng/clamp |
| `test/features/overview/daily_goal_card_test.dart` | Tiến độ = hoàn thành/tổng, bằng 0 khi rỗng |
| `test/features/sleep/sleep_cubit_test.dart` | Khoảng ngủ theo ngày thức, giờ nhắc hôm nay/ngày mai |
| `test/widget_test.dart` | **Template counter cũ**, không phản ánh sản phẩm |

- Không dùng `test/widget_test.dart` làm đặc tả. Ưu tiên test liên quan trực tiếp.
- Chỉ thêm test cho hành vi mới hoặc lỗi vừa sửa; chạy analyzer và test nhỏ nhất bao
  phủ phần thay đổi.
- `flutter analyze` hiện còn cảnh báo cũ: unused import, `withOpacity` deprecated,
  `_seedWeekDayTasks`/`_seedSessions` chưa dùng. Không cần sửa nếu không đụng file đó.

## 10. Quy ước khi làm task tiếp theo

1. Trước khi sửa, lần theo luồng hiện tại:
   **screen → Cubit/state → DAO/service → SQLite**.
2. Tính năng mới ưu tiên mẫu data-driven của `overview` hoặc `study_plan`; không suy
   luận nghiệp vụ từ dữ liệu hardcode/seed.
3. Giữ nguyên tên state, luồng cập nhật và chữ ký hàm hiện có; cập nhật đồng bộ DAO,
   state, screen và mọi call site.
4. Không thêm tầng repository/use case chỉ để đúng tên thư mục.
5. Tác vụ cần cập nhật mỗi phút dùng `MinuteTickerCubit`; Cubit feature đăng ký
   subscription và huỷ trong `close()`.
6. Hộp thoại/bộ chọn ngày giờ dùng `AppStyle.dialogTheme` hoặc `AppStyle.modalBuilder`.
7. Hiển thị lỗi rõ ràng theo mẫu state/UI của feature; không âm thầm trả dữ liệu giả khi
   tải thất bại. Bám sát style thiết kế sẵn có.
8. Nếu gặp trường hợp chưa được mô tả, **hỏi lại** thay vì tự chọn luồng xử lý.

### Checklist thêm một tính năng

- [ ] Xác định feature và DAO liên quan.
- [ ] Thêm model/state field bằng `copyWith` nếu cần.
- [ ] Viết truy vấn trong DAO, không viết SQL ở screen.
- [ ] Thêm method vào Cubit và xử lý lỗi rõ ràng.
- [ ] Nối UI bằng `BlocBuilder`/`BlocListener`.
- [ ] Cập nhật `syncScheduledReminders()` nếu dữ liệu ảnh hưởng thông báo.
- [ ] Thêm test cho hành vi mới/lỗi vừa sửa.
- [ ] Chạy `flutter analyze` và test liên quan.

## 11. Giới hạn và nợ kỹ thuật đã biết

- `android/app/build.gradle.kts` còn `applicationId = com.example.sleep_buddy` và ký
  release bằng debug key.
- Chưa có migration DB; `version` vẫn là 1.
- iOS chưa có `Podfile`; web/desktop chưa hỗ trợ do `sqflite`.
- `core/errors/` và `core/services/` trống.
- `settting_cubit.dart` sai chính tả nhưng phải giữ nguyên.
- `test/widget_test.dart` là template counter.
- Route chi tiết cẩm nang dùng nội dung bước cố định thay vì `guide_steps`;
  `guide_bookmarks`/`guide_progress` chưa có UI.
- `AnalyticsScreen` dùng `StatefulWidget` thay vì Cubit cho phần báo cáo.
- Một số cảnh báo analyzer cũ chưa được dọn.
- Dữ liệu chỉ nằm trên máy, chưa có sao lưu/khôi phục hay đồng bộ nhiều thiết bị.
