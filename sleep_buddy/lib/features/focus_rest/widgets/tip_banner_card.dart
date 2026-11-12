import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/focus_rest/screens/focus_style.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class TipBannerCard extends StatelessWidget {
  const TipBannerCard({
    super.key,
    this.title = 'Mẹo nhỏ cho bạn',
    this.message =
        'Áp dụng quy tắc 20–20–20: cứ 20 phút nhìn xa khoảng 6m trong 20 giây để bảo vệ mắt.',
    this.icon = const AssetImage('assets/focus_rest/lightbulb.png'),
    this.illustration = const AssetImage(
      'assets/focus_rest/eye-tip-illustration.png',
    ),
  });
  final String title, message;
  final ImageProvider icon, illustration;
  @override
  Widget build(BuildContext context) => FocusSurface(
    gradient: AppStyle.dark(context)
        ? null
        : const LinearGradient(colors: [Color(0xFFF2EFFF), Color(0xFFE8E1FF)]),
    padding: const EdgeInsets.all(13),
    child: LayoutBuilder(
      builder: (context, c) {
        final narrow =
            c.maxWidth < 320 || MediaQuery.textScalerOf(context).scale(12) > 18;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: FocusStyle.ink(context),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                fontStyle: FontStyle.italic,
                color: FocusStyle.secondary(context),
              ),
            ),
          ],
        );
        final bulb = Image(
          image: icon,
          width: 37,
          height: 37,
          excludeFromSemantics: true,
        );
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  bulb,
                  const Spacer(),
                  Image(
                    image: illustration,
                    width: 66,
                    height: 50,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              copy,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bulb,
            const SizedBox(width: 10),
            Expanded(child: copy),
            const SizedBox(width: 6),
            Image(
              image: illustration,
              width: 74,
              height: 70,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ],
        );
      },
    ),
  );
}
