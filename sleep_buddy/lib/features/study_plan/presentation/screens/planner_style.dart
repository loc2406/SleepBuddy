import 'package:flutter/material.dart';

/// Reference image: 852 x 1846 physical pixels at approximately 2x density.
/// These are logical pixels, not dimensions scaled to the device width.
abstract final class PlannerStyle {
  static const ink = Color(0xFF160D3E);
  static const secondary = Color(0xFF6B6091);
  static const muted = Color(0xFF9489AD);
  static const purple = Color(0xFF7A52F4);
  static const border = Color(0xFFECE7FA);
  static const success = Color(0xFF319862);
  static const radius = 20.0;
  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEFEDFF), Color(0xFFFCFBFF)],
  );
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF9371FF), Color(0xFF7950F4)],
  );
}

class PlannerSurface extends StatelessWidget {
  const PlannerSurface(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.highlighted = false});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFF),
          borderRadius: BorderRadius.circular(PlannerStyle.radius),
          border: Border.all(
              color:
                  highlighted ? const Color(0xFFD9CCFF) : PlannerStyle.border,
              width: .8),
          boxShadow: const [
            BoxShadow(
                color: Color(0x05613E99), blurRadius: 12, offset: Offset(0, 4))
          ],
        ),
        child: child,
      );
}

class PlannerBadge extends StatelessWidget {
  const PlannerBadge(
      {super.key,
      required this.label,
      this.background = const Color(0xFFEDE8FF),
      this.foreground = const Color(0xFF4B2DBB),
      this.fontSize = 11.5});
  final String label;
  final Color background;
  final Color foreground;
  final double fontSize;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          child: Text(label,
              softWrap: true,
              style: TextStyle(
                  fontSize: fontSize, height: 1.2, color: foreground)),
        ),
      );
}