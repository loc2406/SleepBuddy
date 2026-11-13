import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/features/focus_rest/cubit/focus_rest_cubit.dart';
import 'package:sleep_buddy/features/focus_rest/cubit/focus_rest_state.dart';
import 'package:sleep_buddy/features/focus_rest/screens/focus_style.dart';
import 'package:sleep_buddy/features/focus_rest/screens/models.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/circular_timer_dial.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/focus_backdrop.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/focus_header.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/focus_mode_switcher.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/focus_progress_card.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/recovery_guide_card.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/tip_banner_card.dart';

class FocusRestScreen extends StatefulWidget {
  const FocusRestScreen({
    super.key,
    this.taskId,
    this.onOpenPlanner,
    this.onGuideTap,
    this.guides = const [],
    this.maxContentWidth = 600,
  });

  final int? taskId;
  final VoidCallback? onOpenPlanner;
  final ValueChanged<RecoveryGuide>? onGuideTap;
  final List<RecoveryGuide> guides;
  final double maxContentWidth;

  @override
  State<FocusRestScreen> createState() => _FocusRestScreenState();
}

class _FocusRestScreenState extends State<FocusRestScreen> {
  late final FocusRestCubit _cubit;
  int? _shownSummaryTaskId;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<FocusRestCubit>();
    final currentState = _cubit.state;
    if (
        currentState.taskId != widget.taskId ||
        currentState.status == FocusRestStatus.idle ||
        currentState.status == FocusRestStatus.loading) {
      _cubit.loadTaskSession(widget.taskId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = _cubit.state;
      if (mounted && current.summaryPending) {
        _presentCompletionDialog(current);
      }
    });
  }

  @override
  void didUpdateWidget(covariant FocusRestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taskId != oldWidget.taskId) {
      _cubit.loadTaskSession(widget.taskId);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<FocusRestCubit, FocusRestState>(
    listenWhen: (_, current) => current.summaryPending,
    listener: (context, state) => _presentCompletionDialog(state),
    child: BlocBuilder<FocusRestCubit, FocusRestState>(
      builder: (context, state) {
        final subtitle = state.taskTitle == null
            ? 'Học tập hiệu quả, nghỉ ngơi đúng cách!'
            : 'Nhiệm vụ: ${state.taskTitle}';
        return Scaffold(
          backgroundColor: AppStyle.pageBackground(context),
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: FocusStyle.pageGradient(context),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, viewport) {
                  final padding = Responsive.getScreenPadding(
                    viewport.maxWidth,
                  );
                  return CustomPaint(
                    painter: const FocusBackdrop(),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: padding,
                          sliver: SliverToBoxAdapter(
                            child: _center(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  FocusHeader(
                                    title: 'Tập trung & Nghỉ ngơi',
                                    subtitle: subtitle,
                                  ),
                                  const SizedBox(height: 18),
                                  if (state.status != FocusRestStatus.idle &&
                                      state.status != FocusRestStatus.loading)
                                    FocusModeSwitcher(
                                      currentMode: state.currentMode,
                                      onModeChanged: state.isRunning
                                          ? _cubit.changeMode
                                          : null,
                                    ),
                                  if (state.status != FocusRestStatus.idle &&
                                      state.status != FocusRestStatus.loading)
                                    const SizedBox(height: 16),
                                  if (state.status == FocusRestStatus.loading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 80,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else if (state.status == FocusRestStatus.idle)
                                    _buildIdleState(state)
                                  else
                                    _buildSession(state),
                                  if (state.error != null) ...[
                                    const SizedBox(height: 12),
                                    _buildError(state.error!),
                                  ],
                                  const SizedBox(height: 14),
                                  const TipBannerCard(),
                                  const SizedBox(height: 18),
                                  Text(
                                        'Cẩm nang nghỉ ngơi',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: FocusStyle.ink(context),
                                        ),
                                      ),
                                  const SizedBox(height: 10),
                                  for (final guide in widget.guides) ...[
                                    RecoveryGuideCard(
                                      guide: guide,
                                      onTap: () =>
                                          widget.onGuideTap?.call(guide),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildIdleState(FocusRestState state) => FocusSurface(
    child: Column(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 44,
          color: FocusStyle.secondary(context),
        ),
        const SizedBox(height: 12),
        Text(
          state.error == null
              ? 'Chưa có nhiệm vụ nào đang chạy.'
              : 'Không thể mở nhiệm vụ này.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: FocusStyle.ink(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bắt đầu nhiệm vụ từ thông báo hoặc chọn một nhiệm vụ trong Lịch học.',
          textAlign: TextAlign.center,
          style: TextStyle(color: FocusStyle.secondary(context)),
        ),
        if (widget.onOpenPlanner != null) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.onOpenPlanner,
            child: const Text('Mở Lịch học'),
          ),
        ],
      ],
    ),
  );

  Widget _buildSession(FocusRestState state) => Column(
    children: [
      CircularTimerDial(
        timeText: _formatDuration(state.remaining),
        label: state.status == FocusRestStatus.completed
            ? 'Nhiệm vụ đã kết thúc'
            : 'Thời gian còn lại',
        progress: state.progress,
        centerImage: const AssetImage('assets/focus_rest/book-glow.png'),
      ),
      const SizedBox(height: 14),
      FocusSurface(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: _DurationValue(
                label: 'Thời gian học',
                value: _formatDuration(state.studyDuration),
                icon: Icons.menu_book_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DurationValue(
                label: 'Thời gian nghỉ',
                value: _formatDuration(state.restDuration),
                icon: Icons.coffee_rounded,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      FocusProgressCard(
        title: 'Tiến trình nhiệm vụ',
        countLabel: state.status == FocusRestStatus.completed
            ? 'Hoàn thành'
            : '${(state.progress * 100).round()}%',
        timeDetail:
            'Học ${_formatDuration(state.studyDuration)} · Nghỉ ${_formatDuration(state.restDuration)}',
        progress: state.progress,
      ),
    ],
  );

  Widget _buildError(Object error) => FocusSurface(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Không thể cập nhật phiên: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        IconButton(
          tooltip: 'Thử lại',
          onPressed: () => _cubit.loadTaskSession(widget.taskId),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
  );

  void _presentCompletionDialog(FocusRestState state) {
    if (!mounted ||
        !state.summaryPending ||
        _shownSummaryTaskId == state.taskId) {
      return;
    }
    _shownSummaryTaskId = state.taskId;
    unawaited(_showCompletionDialog(state));
  }

  Future<void> _showCompletionDialog(FocusRestState state) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Theme(
        data: AppStyle.dialogTheme(dialogContext),
        child: AlertDialog(
          title: const Text('Nhiệm vụ đã kết thúc!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.taskTitle != null) ...[
                Text(
                  state.taskTitle!,
                  style: TextStyle(
                    color: AppStyle.ink(dialogContext),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text('Thời gian học: ${_formatDuration(state.studyDuration)}'),
              const SizedBox(height: 6),
              Text('Thời gian nghỉ: ${_formatDuration(state.restDuration)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
    if (mounted) _cubit.acknowledgeSummary();
  }

  Widget _center(Widget child) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxContentWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );

  static String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final minuteText = minutes.toString().padLeft(2, '0');
    final secondText = seconds.toString().padLeft(2, '0');
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:$minuteText:$secondText'
        : '$minuteText:$secondText';
  }
}

class _DurationValue extends StatelessWidget {
  const _DurationValue({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 19, color: FocusStyle.secondary(context)),
      const SizedBox(width: 7),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: FocusStyle.secondary(context),
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: FocusStyle.ink(context),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
