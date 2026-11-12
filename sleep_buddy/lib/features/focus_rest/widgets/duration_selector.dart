import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/focus_rest/screens/focus_style.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class DurationSelector extends StatelessWidget {
  const DurationSelector({
    super.key,
    required this.studyDurationText,
    required this.restDurationText,
    this.onSelectStudyDuration,
    this.onSelectRestDuration,
  });

  final String studyDurationText;
  final String restDurationText;
  final VoidCallback? onSelectStudyDuration;
  final VoidCallback? onSelectRestDuration;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isNarrow =
          constraints.maxWidth < 280 ||
          MediaQuery.textScalerOf(context).scale(13.5) > 20;
      final p1 = _buildPill(
        context: context,
        icon: Icon(
          Icons.access_time_rounded,
          size: 18,
          color: AppStyle.muted(context),
        ),
        label: studyDurationText,
        onTap: onSelectStudyDuration,
      );
      final p2 = _buildPill(
        context: context,
        icon: Icon(
          Icons.coffee_rounded,
          size: 18,
          color: AppStyle.muted(context),
        ),
        label: restDurationText,
        onTap: onSelectRestDuration,
      );
      if (isNarrow) {
        return Column(children: [p1, const SizedBox(height: 10), p2]);
      }
      return Row(
        children: [
          Expanded(child: p1),
          const SizedBox(width: 14),
          Expanded(child: p2),
        ],
      );
    },
  );

  Widget _buildPill({
    required BuildContext context,
    required Widget icon,
    required String label,
    required VoidCallback? onTap,
  }) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppStyle.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FocusStyle.border(context), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064F2D96),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: FocusStyle.ink(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: FocusStyle.secondary(context),
          ),
        ],
      ),
    ),
  );
}
