import 'package:flutter/material.dart';

class AppBaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final ImageProvider? backgroundImage;

  const AppBaseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = Colors.white,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        image: backgroundImage != null
            ? DecorationImage(image: backgroundImage!, fit: BoxFit.fill)
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2B1870),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}