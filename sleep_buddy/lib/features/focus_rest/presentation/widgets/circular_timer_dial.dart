import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/focus_rest/presentation/screens/focus_style.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

/// Controlled timer presentation. Progress is a fraction of the circle,
/// independent of timeText, which the parent formats.
class CircularTimerDial extends StatelessWidget {
  const CircularTimerDial({
    super.key,
    required this.timeText,
    required this.label,
    required this.progress,
    required this.isPlaying,
    required this.onPlayPause,
    this.centerImage = const AssetImage('assets/focus_rest/book-glow.png'),
  });
  final String timeText, label;
  final double progress;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final ImageProvider centerImage;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final available = c.hasBoundedWidth ? c.maxWidth : 394.0;
      final diameter = math.min(available * .59, 250.0);
      final largeText =
          MediaQuery.textScalerOf(context).scale(14) > 20 || available < 300;
      final face = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(
            image: centerImage,
            width: 90,
            height: 53,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          const SizedBox(height: 8),
          Semantics(
            label: label,
            value: timeText,
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 44,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    color: AppStyle.ink(context),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.25,
              color: AppStyle.muted(context),
            ),
          ),
        ],
      );
      final button = Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .7),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2F9573E8),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: FocusStyle.primaryGradient,
          ),
          child: IconButton(
            key: const ValueKey('play-pause'),
            onPressed: onPlayPause,
            tooltip: isPlaying ? 'Tạm dừng' : 'Bắt đầu / Tiếp tục',
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      );
      if (largeText) {
        // Content can grow vertically instead of being squeezed into a fixed circle.
        return FocusSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              face,
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: progress.isFinite ? progress.clamp(0.0, 1.0) : 0,
                color: FocusStyle.purple,
                backgroundColor: AppStyle.track(context),
              ),
              const SizedBox(height: 14),
              button,
            ],
          ),
        );
      }
      return SizedBox(
        height: diameter + 27,
        child: Center(
          child: SizedBox(
            width: diameter,
            height: diameter + 27,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                SizedBox.square(
                  dimension: diameter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: AppStyle.dark(context)
                            ? const [Color(0xFF403653), Color(0xFF332B49)]
                            : const [Color(0xFFFEFDFF), Color(0xFFF3EFFF)],
                      ),
                    ),
                    child: CustomPaint(
                      painter: _DialPainter(
                        progress,
                        dark: AppStyle.dark(context),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 21,
                  right: 21,
                  height: diameter,
                  child: Center(child: face),
                ),
                Positioned(bottom: 0, child: button),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _DialPainter extends CustomPainter {
  const _DialPainter(this.progress, {required this.dark});
  final double progress;
  final bool? dark;
  @override
  void paint(Canvas canvas, Size size) {
    final isDark = dark ?? false;
    final c = size.center(Offset.zero), r = size.width / 2 - 7;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = isDark ? const Color(0xFF60546F) : const Color(0xFFD5C5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
    final p = progress.isFinite ? progress.clamp(0.0, 1.0).toDouble() : 0.0;
    if (p <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * p,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFB799FF), Color(0xFF895FFF)],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 12,
    );
    final end =
        c +
        Offset(
              math.cos(-math.pi / 2 + 2 * math.pi * p),
              math.sin(-math.pi / 2 + 2 * math.pi * p),
            ) *
            r;
    canvas.drawCircle(end, 11, Paint()..color = const Color(0xFF9570FF));
    canvas.drawCircle(end, 8.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.progress != progress || old.dark != dark;
}
