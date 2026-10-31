import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';

class PlanButton extends StatelessWidget {
  const PlanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            ColorConstant.gradientButtonStart,
            ColorConstant.gradientButtonEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: ColorConstant.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to planning screen
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            child: Text(
              'Lên kế hoạch hôm nay →',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ColorConstant.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}