import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/circular_timer_dial.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/duration_selector.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/focus_backdrop.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/focus_header.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/focus_mode_switcher.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/focus_progress_card.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/recovery_guide_card.dart';
import 'package:sleep_buddy/features/focus_rest/widgets/tip_banner_card.dart';
import 'models.dart';
import 'focus_style.dart';

class FocusRestScreen extends StatelessWidget {
  const FocusRestScreen({
    super.key,
    this.title = 'Tập trung & Nghỉ ngơi',
    this.subtitle = 'Học tập hiệu quả, nghỉ ngơi đúng cách!',
    this.onNotificationTap,
    this.timerImage = const AssetImage('assets/focus_rest/book-glow.png'),
    this.onEndSession,
    this.currentMode = FocusMode.study,
    this.onModeChanged,
    required this.timeText,
    required this.timerLabel,
    required this.timerProgress,
    required this.isPlaying,
    required this.onPlayPause,
    required this.studyDurationText,
    required this.restDurationText,
    this.onSelectStudyDuration,
    this.onSelectRestDuration,
    required this.progressTitle,
    required this.progressCountLabel,
    required this.progressTimeDetail,
    required this.overallProgress,
    this.onTapProgressDetail,
    this.tipTitle = 'Mẹo nhỏ cho bạn',
    this.tipMessage =
        '“Áp dụng quy tắc 20–20–20: cứ 20 phút nhìn xa 20 feet (~6m) trong 20 giây để bảo vệ mắt nhé!”',
    this.guideSectionTitle = 'Cẩm nang hồi phục',
    this.onViewMoreGuides,
    required this.guides,
    this.onGuideTap,
    this.selectedNavigationIndex = 2,
    this.onNavigationSelected,
    this.showNavigation = true,
    this.maxContentWidth = 600,
  });

  final String title, subtitle;
  final VoidCallback? onNotificationTap, onEndSession;
  final ImageProvider timerImage;
  final FocusMode currentMode;
  final ValueChanged<FocusMode>? onModeChanged;

  final String timeText;
  final String timerLabel;
  final double timerProgress;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  final String studyDurationText;
  final String restDurationText;
  final VoidCallback? onSelectStudyDuration;
  final VoidCallback? onSelectRestDuration;

  final String progressTitle;
  final String progressCountLabel;
  final String progressTimeDetail;
  final double overallProgress;
  final VoidCallback? onTapProgressDetail;

  final String tipTitle;
  final String tipMessage;

  final String guideSectionTitle;
  final VoidCallback? onViewMoreGuides;
  final List<RecoveryGuide> guides;
  final ValueChanged<RecoveryGuide>? onGuideTap;

  final int selectedNavigationIndex;
  final ValueChanged<int>? onNavigationSelected;
  final bool showNavigation;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppStyle.pageBackground(context),
    body: DecoratedBox(
      decoration: BoxDecoration(gradient: FocusStyle.pageGradient(context)),
      child: SafeArea(
        bottom: !showNavigation,
        child: LayoutBuilder(
          builder: (context, viewport) {
            final width = viewport.maxWidth;
            final padding = Responsive.getScreenPadding(width);
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
                              title: title,
                              subtitle: subtitle,
                              onNotificationTap: onNotificationTap,
                            ),
                            const SizedBox(height: 18),
                            FocusModeSwitcher(
                              currentMode: currentMode,
                              onModeChanged: onModeChanged,
                            ),
                            const SizedBox(height: 16),
                            CircularTimerDial(
                              timeText: timeText,
                              label: timerLabel,
                              progress: timerProgress,
                              isPlaying: isPlaying,
                              onPlayPause: onPlayPause,
                              centerImage: timerImage,
                            ),
                            const SizedBox(height: 4),
                            if (onEndSession != null)
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  key: const ValueKey('end-session'),
                                  onPressed: onEndSession,
                                  child: const Text('Kết thúc phiên'),
                                ),
                              ),
                            DurationSelector(
                              studyDurationText: studyDurationText,
                              restDurationText: restDurationText,
                              onSelectStudyDuration: onSelectStudyDuration,
                              onSelectRestDuration: onSelectRestDuration,
                            ),
                            const SizedBox(height: 18),
                            FocusProgressCard(
                              title: progressTitle,
                              countLabel: progressCountLabel,
                              timeDetail: progressTimeDetail,
                              progress: overallProgress,
                              onTapDetail: onTapProgressDetail,
                            ),
                            const SizedBox(height: 14),
                            TipBannerCard(title: tipTitle, message: tipMessage),
                            const SizedBox(height: 18),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 12,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  guideSectionTitle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: FocusStyle.ink(context),
                                  ),
                                ),
                                TextButton(
                                  key: const ValueKey('more-guides'),
                                  onPressed: onViewMoreGuides,
                                  child: Text(
                                    'Xem thêm  ›',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: FocusStyle.secondary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            for (final guide in guides) ...[
                              RecoveryGuideCard(
                                guide: guide,
                                onTap: () => onGuideTap?.call(guide),
                              ),
                              const SizedBox(height: kBottomNavigationBarHeight),
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

  Widget _center(Widget child) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}
