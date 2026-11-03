import 'package:flutter/material.dart';

abstract final class FocusStyle {
  static const ink = Color(0xFF160D3E);
  static const secondary = Color(0xFF6B6094);
  static const muted = Color(0xFF8F84AD);
  static const purple = Color(0xFF7A52F4);
  static const border = Color(0xFFECE7FA);

  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEFEDFF), Color(0xFFFCFBFF)],
  );

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF8E6CF6), Color(0xFF7A52F4)],
  );
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
          color: gradient == null ? background : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: FocusStyle.border, width: 0.8),
          boxShadow: const [
            BoxShadow(
                color: Color(0x065E3E9C), blurRadius: 14, offset: Offset(0, 5)),
          ],
        ),
        child: child,
      );
}
