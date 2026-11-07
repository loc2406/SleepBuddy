import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

abstract final class FocusStyle {
  static const purple = Color(0xFF7A52F4);

  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEFEDFF), Color(0xFFFCFBFF)],
  );

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF8E6CF6), Color(0xFF7A52F4)],
  );
  static LinearGradient pageGradient(BuildContext context) =>
      AppStyle.pageGradient(context);
  static Color ink(BuildContext context) => AppStyle.ink(context);
  static Color secondary(BuildContext context) => AppStyle.muted(context);
  static Color surface(BuildContext context) => AppStyle.surface(context);
  static Color border(BuildContext context) => AppStyle.border(context);
  static Color track(BuildContext context) => AppStyle.track(context);
}

class FocusSurface extends StatelessWidget {
  const FocusSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24.0,
    this.background = const Color(0xFFFFFEFF),
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color background;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: gradient == null ? AppStyle.surface(context) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppStyle.border(context), width: 0.8),
      boxShadow: const [
        BoxShadow(
          color: Color(0x065E3E9C),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}
