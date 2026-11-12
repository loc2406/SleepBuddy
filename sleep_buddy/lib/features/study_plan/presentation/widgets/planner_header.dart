import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/planner_style.dart';

class PlannerHeader extends StatelessWidget {
  const PlannerHeader({
    super.key,
    required this.title,
    required this.dateLabel,
    this.onAddMissionPressed,
    this.hasUnreadNotification = true,
  });
  final String title;
  final String dateLabel;
  final VoidCallback? onAddMissionPressed;
  final bool hasUnreadNotification;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wrap permits the decorative calendar to move to the next line.
            Wrap(
              spacing: 9,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: PlannerStyle.ink(context),
                  ),
                ),
                Icon(Icons.calendar_month, color: ColorConstant.primary, size: 24,),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateLabel,
              style: TextStyle(
                fontSize: 14,
                color: PlannerStyle.secondary(context),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      IconButton(
        onPressed: onAddMissionPressed,
        tooltip: 'Thêm nhiệm vụ',
        icon: Icon(Icons.add, color: ColorConstant.primary, size: 32),
      ),
    ],
  );
}
