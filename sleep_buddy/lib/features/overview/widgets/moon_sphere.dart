import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';

class MoonSphere extends StatelessWidget {
  final double size;

  const MoonSphere({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Stars
        Positioned(
          top: 15,
          right: size * 0.38,
          child: Icon(
            Icons.auto_awesome,
            color: ColorConstant.moonPurple.withValues(alpha: 0.35),
            size: 24,
          ),
        ),

        Positioned(
          top: 20,
          right: 10,
          child: Icon(
            Icons.auto_awesome,
            color: ColorConstant.moonPurple.withValues(alpha: 0.3),
            size: 20,
          ),
        ),

        // Sphere
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.35, -0.42),
              radius: 1.05,
              colors: [
                ColorConstant.moonHighlight,
                ColorConstant.moonWarm,
                ColorConstant.moonPink,
                ColorConstant.moonPurple,
                ColorConstant.moonShadow,
              ],
              stops: [0.0, 0.18, 0.42, 0.72, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.shadowPurple.withValues(alpha: 0.35),
                offset: const Offset(12, 22),
                blurRadius: 18,
                spreadRadius: -5,
              ),
              BoxShadow(
                color: ColorConstant.moonPink.withValues(alpha: 0.2),
                offset: const Offset(-10, -10),
                blurRadius: 30,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
