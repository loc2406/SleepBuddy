import 'package:flutter/material.dart';

/// Decorative cloud shapes only; never includes text or controls.
class FocusBackdrop extends CustomPainter {
  const FocusBackdrop();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final y = (size.height * .43).clamp(180.0, 430.0);
    final p = Paint()..color = const Color(0xFFD6C9FF).withValues(alpha: .48);
    final left = Path()
      ..moveTo(0, y - 70)
      ..cubicTo(w * .12, y - 95, w * .18, y - 40, w * .17, y - 15)
      ..cubicTo(w * .26, y - 22, w * .29, y + 20, w * .27, y + 50)
      ..lineTo(0, y + 80)
      ..close();
    canvas.drawPath(left, p);
    final right = Path()
      ..moveTo(w, y - 155)
      ..cubicTo(w * .83, y - 125, w * .89, y - 50, w * .77, y - 30)
      ..cubicTo(w * .68, y - 5, w * .72, y + 50, w * .60, y + 95)
      ..lineTo(w, y + 130)
      ..close();
    canvas.drawPath(right, p);
    p.color = const Color(0xFFFFFFFF).withValues(alpha: .65);
    canvas.drawOval(Rect.fromLTWH(-w * .18, y + 10, w * .35, 150), p);
    canvas.drawOval(Rect.fromLTWH(w * .84, y - 15, w * .4, 150), p);
    for (final point in [
      Offset(w * .16, y - 115),
      Offset(w * .88, y - 102),
      Offset(w * .80, y - 165),
    ]) {
      final star = Path()
        ..moveTo(point.dx, point.dy - 8)
        ..quadraticBezierTo(point.dx + 2, point.dy - 2, point.dx + 8, point.dy)
        ..quadraticBezierTo(point.dx + 2, point.dy + 2, point.dx, point.dy + 8)
        ..quadraticBezierTo(point.dx - 2, point.dy + 2, point.dx - 8, point.dy)
        ..quadraticBezierTo(point.dx - 2, point.dy - 2, point.dx, point.dy - 8);
      canvas.drawPath(star, Paint()..color = const Color(0xFFC1A6FF));
    }
  }

  @override
  bool shouldRepaint(covariant FocusBackdrop oldDelegate) => false;
}
