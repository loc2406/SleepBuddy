import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/focus_rest/screens/focus_style.dart';
import 'package:sleep_buddy/features/focus_rest/screens/models.dart';

class RecoveryGuideCard extends StatelessWidget {
  const RecoveryGuideCard({super.key, required this.guide, this.onTap});
  final RecoveryGuide guide;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => FocusSurface(
    padding: const EdgeInsets.all(8),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('guide-${guide.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, c) {
            final narrow =
                c.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0D3FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    guide.tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: FocusStyle.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  guide.title,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: FocusStyle.ink(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: FocusStyle.secondary(context),
                        ),
                      ),
                      TextSpan(text: '  ${guide.readTime}'),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: FocusStyle.secondary(context),
                  ),
                ),
              ],
            );
            final image = ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(
                aspectRatio: 1.62,
                child: Image(
                  image: guide.thumbnail,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            );
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [image, const SizedBox(height: 12), copy],
              );
            }
            return Row(
              children: [
                SizedBox(width: c.maxWidth * .36, child: image),
                const SizedBox(width: 16),
                Expanded(child: copy),
                const SizedBox(width: 7),
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFEDE6FF),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: FocusStyle.purple,
                    size: 23,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
