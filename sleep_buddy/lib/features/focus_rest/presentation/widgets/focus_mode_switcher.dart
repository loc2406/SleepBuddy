import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/focus_rest/presentation/screens/focus_style.dart';
import 'package:sleep_buddy/features/focus_rest/presentation/screens/models.dart';


class FocusModeSwitcher extends StatelessWidget {
  const FocusModeSwitcher({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  final FocusMode currentMode;
  final ValueChanged<FocusMode>? onModeChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EDFD),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTab(
                title: 'Phiên học',
                iconPath: 'assets/focus_rest/graduation-cap.png',
                active: currentMode == FocusMode.study,
                onTap: () => onModeChanged?.call(FocusMode.study),
              ),
            ),
            Expanded(
              child: _buildTab(
                title: 'Thư giãn',
                iconPath: 'assets/focus_rest/bed.png',
                active: currentMode == FocusMode.relax,
                onTap: () => onModeChanged?.call(FocusMode.relax),
              ),
            ),
          ],
        ),
      );

  Widget _buildTab({
    required String title,
    required String iconPath,
    required bool active,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: active ? null : Colors.transparent,
            gradient: active ? FocusStyle.primaryGradient : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: active
                ? const [
                    BoxShadow(
                        color: Color(0x2E7A52F4),
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 20,
                height: 20,
                color: active ? Colors.white : FocusStyle.secondary,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : FocusStyle.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
