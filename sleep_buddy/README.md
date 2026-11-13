# SleepBuddy — bản đồ dự án và quy ước code

Tài liệu này mô tả cấu trúc Flutter hiện tại và các mẫu code nên dùng khi mở rộng ứng dụng. Khi thực hiện task mới, ưu tiên các luồng dữ liệu thật được nêu dưới đây; không lấy dữ liệu demo/hardcode làm nguồn dữ liệu hoặc mẫu logic nghiệp vụ.

## Chạy và kiểm tra

Ứng dụng Flutter nằm trong thư mục `sleep_buddy/` của repository.

```shell
cd sleep_buddy
flutter pub get
flutter run
```

Kiểm tra code:

```shell
flutter analyze
flutter test test/features/overview/daily_goal_card_test.dart
```

## Cấu trúc tổng quát

```text
lib/
  main.dart
  core/
    config/         Cấu hình dùng chung
    constants/      Asset, màu và giá trị cố định dùng cho giao diện
    cubit/          Cubit dùng chung cấp ứng dụng
    db/             Khởi tạo SQLite và các DAO
    errors/         Kiểu lỗi dùng chung
    notifications/  Tích hợp thông báo cục bộ
    router/         Khai báo điều hướng GoRouter
    services/       Dịch vụ dùng chung
    theme/          Theme sáng/tối
    utils/          Tiện ích dùng chung
    widgets/        Widget dùng chung
  features/
    analytics/
      cubit/ model/ models/ screens/ widgets/
    focus_rest/
      cubit/ screens/ widgets/
    overview/
      cubit/ screens/ widgets/
    study_plan/
      cubit/ model/ screens/ widgets/
    sleep/
      cubit/ screens/ widgets/
    home_screen.dart
test/
```

Một số thư mục `data/` và `domain/` còn lại trong feature chưa có luồng triển khai đang được dùng rộng rãi. Không cần thêm tầng repository/use case chỉ để làm theo tên thư mục; hãy theo luồng đang hoạt động của feature liên quan.

## Điểm vào ứng dụng

- [`lib/main.dart`](lib/main.dart): khởi tạo preferences, SQLite, dữ liệu seed và thông báo; đăng ký các Cubit cấp ứng dụng.
- [`lib/core/router/app_router.dart`](lib/core/router/app_router.dart): route màn hình chính, thêm nhiệm vụ và chi tiết cẩm nang.
- [`lib/core/cubit/minute_ticker_cubit.dart`](lib/core/cubit/minute_ticker_cubit.dart): phát tick mỗi phút và khi ứng dụng quay lại foreground. Không tạo thêm timer định kỳ riêng nếu tác vụ có thể dùng ticker này.
- [`lib/core/db/app_db.dart`](lib/core/db/app_db.dart): schema SQLite hiện tại. Khi đổi schema, kiểm tra cả version và migration; không chỉ sửa `onCreate`.

## Luồng code nên dùng

### Màn hình có dữ liệu từ SQLite

Mẫu chính:

- Tổng quan: [`lib/features/overview/screens/overview_screen.dart`](lib/features/overview/screens/overview_screen.dart), [`lib/features/overview/cubit/overview_cubit.dart`](lib/features/overview/cubit/overview_cubit.dart), [`lib/features/overview/cubit/overview_state.dart`](lib/features/overview/cubit/overview_state.dart).
- Lịch học: [`lib/features/study_plan/screens/study_planner_screen.dart`](lib/features/study_plan/screens/study_planner_screen.dart), [`lib/features/study_plan/cubit/study_planner_cubit.dart`](lib/features/study_plan/cubit/study_planner_cubit.dart), [`lib/features/study_plan/cubit/study_planner_state.dart`](lib/features/study_plan/cubit/study_planner_state.dart).
- Tạo nhiệm vụ: [`lib/features/study_plan/screens/add_study_task_screen.dart`](lib/features/study_plan/screens/add_study_task_screen.dart) và [`lib/features/study_plan/cubit/add_new_study_plan_cubit.dart`](lib/features/study_plan/cubit/add_new_study_plan_cubit.dart).
- Tập trung/nghỉ ngơi: [`lib/features/focus_rest/screens/focus_rest_screen.dart`](lib/features/focus_rest/screens/focus_rest_screen.dart), [`lib/features/focus_rest/cubit/focus_rest_cubit.dart`](lib/features/focus_rest/cubit/focus_rest_cubit.dart), [`lib/features/focus_rest/cubit/focus_rest_state.dart`](lib/features/focus_rest/cubit/focus_rest_state.dart).
- Cài đặt: [`lib/features/analytics/screens/settings_screen.dart`](lib/features/analytics/screens/settings_screen.dart) và [`lib/features/analytics/cubit/settting_cubit.dart`](lib/features/analytics/cubit/settting_cubit.dart). Tên `settting_cubit.dart` hiện có ba chữ `t`; giữ nguyên đường dẫn khi sửa file này.

### Trách nhiệm từng lớp

1. **Screen**: dựng giao diện, lấy state bằng `BlocBuilder`, chuyển thao tác người dùng tới Cubit. Không viết SQL, gọi DAO trực tiếp hoặc giữ logic nghiệp vụ trong widget.
2. **Cubit**: tải dữ liệu, kiểm tra điều kiện, điều phối DAO/service và phát state. Khi gọi từ screen, lấy Cubit một lần:

   ```dart
   final _cubit = context.read<FeatureCubit>();
   ```

   Sau đó dùng `_cubit` cho callback thay vì gọi `context.read<FeatureCubit>()` lặp lại.
3. **State**: chứa dữ liệu cần render; ưu tiên immutable state và `copyWith`. Không giữ `BuildContext` trong state/Cubit.
4. **DAO**: là nơi truy cập SQLite và viết truy vấn. Thêm thao tác dữ liệu vào DAO hiện có của domain thay vì đặt SQL trong screen/Cubit.
5. **Model**: đặt theo phạm vi feature; giữ model giao diện riêng nếu khác model lưu trữ.

### Nguồn dữ liệu và tiện ích chính

- Nhiệm vụ học: [`lib/core/db/study_task_dao.dart`](lib/core/db/study_task_dao.dart).
- Phiên học/nghỉ: [`lib/core/db/focus_session_dao.dart`](lib/core/db/focus_session_dao.dart); mỗi lần đổi tab Phiên học/Nghỉ ngơi đóng một đoạn và bắt đầu đoạn tiếp theo trong `focus_sessions`.
- Số liệu tổng quan: [`lib/core/db/dashboard_dao.dart`](lib/core/db/dashboard_dao.dart). Biểu đồ phân bổ thời gian hỗ trợ hôm nay, hôm qua, tuần hiện tại và tháng hiện tại; các kỳ tuần/tháng lấy tổng học/nghỉ từ phiên đã lưu.
- Báo cáo: [`lib/core/db/report_dao.dart`](lib/core/db/report_dao.dart). Các chỉ số, biểu đồ giờ học, thời gian theo môn và hoàn thành kế hoạch dùng cùng kỳ ngày/tuần/tháng; biểu đồ tháng gom theo các tuần lịch (Thứ 2–Chủ nhật).
- Giấc ngủ: [`lib/core/db/sleep_dao.dart`](lib/core/db/sleep_dao.dart).
- Cài đặt: [`lib/core/db/settings_dao.dart`](lib/core/db/settings_dao.dart).
- Cẩm nang: [`lib/core/db/guide_article_dao.dart`](lib/core/db/guide_article_dao.dart) và [`lib/core/db/guide_detail_dao.dart`](lib/core/db/guide_detail_dao.dart).
- Nhắc nhiệm vụ: [`lib/core/notifications/task_reminder_notifications.dart`](lib/core/notifications/task_reminder_notifications.dart).

Nhắc bắt đầu nhiệm vụ được gửi vào đúng `scheduled_start`, không gửi sớm hơn dựa trên mức ưu tiên. Mức ưu tiên chỉ điều chỉnh độ nổi bật: cao dùng thông báo nổi bật/có âm thanh, trung bình dùng mức thông thường, thấp dùng thông báo yên lặng. Thời điểm hiển thị thực tế vẫn phụ thuộc vào quyền thông báo, cài đặt kênh của Android/iOS và chính sách tiết kiệm pin của thiết bị.

Màn hình Giấc ngủ sử dụng [`lib/features/sleep/cubit/sleep_cubit.dart`](lib/features/sleep/cubit/sleep_cubit.dart) và [`lib/features/sleep/cubit/sleep_state.dart`](lib/features/sleep/cubit/sleep_state.dart) để đọc/ghi nhật ký và kế hoạch ngủ qua `SleepDao`. Nhật ký được gắn với ngày thức dậy; giờ ngủ muộn hơn giờ thức dậy được tính là đêm hôm trước. Không cho lưu giờ thức dậy trong tương lai hoặc khoảng ngủ từ 24 giờ trở lên. Người dùng có thể ghi/chỉnh giờ ngủ, giờ thức dậy, ghi chú và cảm nhận, đồng thời chỉnh giờ ngủ mục tiêu, giờ nhắc và bật/tắt nhắc. Nhật ký mẫu không được seed; màn hình mới sẽ hiển thị trạng thái chưa ghi nhận. Nhắc ngủ dùng giờ cục bộ đã cài trong `sleep_settings` và chỉ được lên lịch khi cả nhắc ngủ lẫn thông báo ứng dụng đều bật; nếu giờ nhắc hôm nay đã qua, lịch tiếp theo là ngày mai.

## Nguồn demo/hardcode — không dùng làm chuẩn dữ liệu

- [`lib/features/home_screen.dart`](lib/features/home_screen.dart) ghép tab và truyền task ID cho màn hình tập trung. Không đặt logic tính giờ hoặc hoàn thành nhiệm vụ tại đây.
- Màn hình Tập trung/Nghỉ ngơi hiện dùng dữ liệu từ `FocusRestCubit` và `FocusSessionDao`; các mẹo/cẩm nang có thể chứa nội dung trình bày tĩnh nhưng không quyết định nghiệp vụ timer.
- Route chi tiết cẩm nang trong [`lib/core/router/app_router.dart`](lib/core/router/app_router.dart) đang truyền nội dung bước hướng dẫn cố định. Không coi các nội dung này là dữ liệu cẩm nang production.
- [`lib/core/db/seed_dao.dart`](lib/core/db/seed_dao.dart) và [`lib/core/db/demo_data_dao.dart`](lib/core/db/demo_data_dao.dart) phục vụ seed/demo. `main.dart` hiện gọi seed khi khởi động; không xây tính năng thật dựa trên giả định rằng dữ liệu seed luôn tồn tại.
- [`lib/features/analytics/presentation/screens/analytics_screen.dart`](lib/features/analytics/presentation/screens/analytics_screen.dart) đọc báo cáo thật qua `ReportDao`, nhưng tự quản lý tải dữ liệu bằng `StatefulWidget`; dùng nó để hiểu nguồn báo cáo, không dùng làm mẫu Cubit mới.
- `features/new_feat/` và các thư mục feature chưa có luồng đang hoạt động không phải mẫu kiến trúc đã được xác nhận.

`SleepScreen` đọc state từ `SleepCubit`; `HomeScreen` chỉ ghép màn hình và danh sách cẩm nang. `SeedDao` không tạo nhật ký ngủ giả. Các nhật ký đã được tạo bởi bản demo cũ không bị tự động xóa.

`test/widget_test.dart` hiện là test mẫu Flutter kiểu counter, không phản ánh hành vi sản phẩm. Khi kiểm tra thay đổi, ưu tiên test có liên quan trực tiếp trong `test/`; không dùng test mẫu này làm đặc tả.

## Quy ước khi thực hiện task tiếp theo

- Trước khi sửa, lần theo luồng hiện tại: **screen → Cubit/state → DAO/service → SQLite hoặc API**.
- Với tính năng mới, ưu tiên mẫu data-driven của `overview` hoặc `study_plan`; không suy luận nghiệp vụ từ dữ liệu hardcode/seed.
- Giữ nguyên quy ước tên trạng thái và luồng cập nhật hiện có; cập nhật DAO, state, screen và các call site liên quan đồng bộ.
- Tác vụ cần cập nhật mỗi phút dùng `MinuteTickerCubit`; Cubit feature đăng ký subscription và hủy trong `close()`.
- Hộp thoại và bộ chọn ngày/giờ dùng `AppStyle.dialogTheme` hoặc `AppStyle.modalBuilder` để thống nhất màu sắc, bề mặt, viền và trạng thái chọn ở cả theme sáng/tối.
- `FocusRestCubit` dùng ticker chung để bù thời gian khi ứng dụng quay lại foreground, đồng thời chạy timer 1 giây chỉ khi có task đang tập trung để hiển thị đếm ngược/counters. Hết `scheduled_end`, Cubit đóng đoạn hiện tại, lưu tổng thời gian và chuyển task sang `completed`; notification kết thúc mở lại tab Tập trung và tổng kết.
- Hiển thị lỗi rõ ràng theo mẫu state/UI của feature; không âm thầm trả dữ liệu giả khi tải thất bại, bám sát style thiết kế của app.
- Chỉ thêm test cho hành vi mới hoặc lỗi được sửa, và chạy analyzer/test nhỏ nhất bao phủ phần thay đổi.
- Nếu xuất hiện trường hợp không được đề cập trong task, hãy hỏi lại để tôi quyết định luồng xử lí, không được tự ý quyết định.
