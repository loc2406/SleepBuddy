import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';
import 'package:sleep_buddy/features/analytics/widgets/guide_card.dart';
import 'package:sleep_buddy/features/sleep/cubit/sleep_cubit.dart';
import 'package:sleep_buddy/features/sleep/cubit/sleep_state.dart';
import 'package:sleep_buddy/features/sleep/widgets/app_shell.dart';
import 'package:sleep_buddy/features/sleep/widgets/sleep_cards.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({
    super.key,
    required this.guides,
    this.onGuideOpen,
    this.onMoreGuides,
    this.onNotification,
    this.maxContentWidth = 600,
  });

  final List<GuideArticle> guides;
  final ValueChanged<GuideArticle>? onGuideOpen;
  final VoidCallback? onMoreGuides;
  final VoidCallback? onNotification;
  final double maxContentWidth;

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  late final SleepCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<SleepCubit>();
  }

  @override
  Widget build(BuildContext context) => BlocListener<SleepCubit, SleepState>(
    listenWhen: (previous, current) =>
        previous.error != current.error && current.error != null,
    listener: (context, state) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.error!)));
      _cubit.clearError();
    },
    child: BlocBuilder<SleepCubit, SleepState>(
      builder: (context, state) {
        final data = state.data;
        final children = data == null
            ? <Widget>[
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  WellnessCard(
                    child: Column(
                      children: [
                        Text(
                          state.error ?? 'Chưa thể tải dữ liệu giấc ngủ.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _cubit.load,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
              ]
            : [
                SleepSummaryCard(data: data),
                SleepRecordCard(
                  bedTime: data.bedTime,
                  wakeTime: data.wakeTime,
                  onEdit: () => _editSleepRecord(data),
                ),
                SleepPlanCard(
                  bedtime: data.targetBedtime,
                  reminderTime: data.reminderTime,
                  reminderEnabled: data.reminderEnabled,
                  appNotificationsEnabled: data.appNotificationsEnabled,
                  onBedtimeTap: () => _editTargetBedtime(data.targetBedtime),
                  onReminderTimeTap: () => _editReminderTime(data.reminderTime),
                  onReminderChanged: _cubit.updateReminderEnabled,
                ),
                if (data.hasRecord)
                  SleepMoodCard(
                    selected: data.mood,
                    onChanged: _cubit.updateMood,
                  ),
                if (data.hasRecord && data.notes?.isNotEmpty == true)
                  WellnessCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ghi chú',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(data.notes!),
                      ],
                    ),
                  ),
                AdviceCard(
                  title: 'Gợi ý cho hôm nay',
                  message: data.recommendation,
                ),
                SectionHeading(
                  'Cẩm nang giấc ngủ',
                  onMore: widget.onMoreGuides,
                ),
                for (final article in widget.guides)
                  GuideCard(
                    article: article,
                    onOpen: widget.onGuideOpen == null
                        ? null
                        : (article) => widget.onGuideOpen!(article),
                  ),
              ];

        return AppShell(
          title: 'Giấc ngủ & Sức khỏe',
          subtitle: 'Ngủ đủ giấc, học tập trọn vẹn hơn.',
          maxContentWidth: widget.maxContentWidth,
          children: children,
        );
      },
    ),
  );

  Future<void> _editSleepRecord(SleepData data) async {
    final now = DateTime.now();
    final existingWakeTime = data.wakeTime;
    final existingBedTime = data.bedTime;
    var wakeDate = existingWakeTime == null
        ? DateTime(now.year, now.month, now.day)
        : DateTime(
            existingWakeTime.year,
            existingWakeTime.month,
            existingWakeTime.day,
          );
    var bedtime = TimeOfDay.fromDateTime(
      existingBedTime ?? now.subtract(const Duration(hours: 8)),
    );
    var wakeTime = TimeOfDay.fromDateTime(existingWakeTime ?? now);
    final notesController = TextEditingController(text: data.notes ?? '');

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Theme(
          data: AppStyle.dialogTheme(dialogContext),
          child: StatefulBuilder(
            builder: (dialogContext, setDialogState) => AlertDialog(
              title: Text(
                data.hasRecord ? 'Chỉnh sửa nhật ký ngủ' : 'Ghi nhận giấc ngủ',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: dialogContext,
                          initialDate: wakeDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(now.year, now.month, now.day),
                          helpText: 'Chọn ngày thức dậy',
                          builder: AppStyle.modalBuilder,
                        );
                        if (selected == null) return;
                        setDialogState(() {
                          wakeDate = DateTime(
                            selected.year,
                            selected.month,
                            selected.day,
                          );
                        });
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text('Ngày thức dậy: ${_formatDate(wakeDate)}'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        final selected = await showTimePicker(
                          context: dialogContext,
                          initialTime: bedtime,
                          helpText: 'Chọn giờ đi ngủ',
                          builder: AppStyle.modalBuilder,
                        );
                        if (selected != null) {
                          setDialogState(() => bedtime = selected);
                        }
                      },
                      child: Text('Giờ đi ngủ: ${_formatTime(bedtime)}'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final selected = await showTimePicker(
                          context: dialogContext,
                          initialTime: wakeTime,
                          helpText: 'Chọn giờ thức dậy',
                          builder: AppStyle.modalBuilder,
                        );
                        if (selected != null) {
                          setDialogState(() => wakeTime = selected);
                        }
                      },
                      child: Text('Giờ thức dậy: ${_formatTime(wakeTime)}'),
                    ),
                    Text(
                      'Nếu giờ đi ngủ muộn hơn giờ thức dậy, ứng dụng hiểu là bạn ngủ qua đêm hôm trước.',
                      style: Theme.of(dialogContext).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      maxLength: 300,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú (không bắt buộc)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    final saved = await _cubit.saveSleepRecord(
                      wakeDate: wakeDate,
                      bedTime: bedtime,
                      wakeTime: wakeTime,
                      notes: notesController.text,
                    );
                    if (saved && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      notesController.dispose();
    }
  }

  Future<void> _editTargetBedtime(TimeOfDay current) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: current,
      helpText: 'Chọn giờ ngủ mục tiêu',
      builder: AppStyle.modalBuilder,
    );
    if (selected != null) await _cubit.updateTargetBedtime(selected);
  }

  Future<void> _editReminderTime(TimeOfDay current) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: current,
      helpText: 'Chọn giờ nhắc chuẩn bị ngủ',
      builder: AppStyle.modalBuilder,
    );
    if (selected != null) await _cubit.updateReminderTime(selected);
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  static String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
