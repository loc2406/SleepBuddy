import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/focus_rest/screens/focus_style.dart';

class FocusHeader extends StatelessWidget {
  const FocusHeader({
    super.key,
    this.title = 'Tập trung & Nghỉ ngơi',
    this.subtitle = 'Học tập hiệu quả, nghỉ ngơi đúng cách!',
    this.onNotificationTap,
    this.hasNotification = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onNotificationTap;
  final bool hasNotification;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: FocusStyle.ink(context),
                  ),
                ),
                Image.asset(
                  'assets/focus_rest/sparkle-peach.png',
                  width: 22,
                  height: 25,
                  excludeFromSemantics: true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.5,
                color: FocusStyle.secondary(context),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
