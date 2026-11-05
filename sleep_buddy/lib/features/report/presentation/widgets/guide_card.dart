import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class GuideCard extends StatelessWidget {
  const GuideCard({super.key, required this.article, this.onOpen});
  final GuideArticle article;
  final ValueChanged<GuideArticle>? onOpen;
  @override
  Widget build(BuildContext c) => WellnessCard(
    padding: const EdgeInsets.all(8),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('article-${article.id}'),
        onTap: onOpen == null ? null : () => onOpen!(article),
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (c, box) {
            final narrow =
                box.maxWidth < 285 || MediaQuery.textScalerOf(c).scale(14) > 21;
            final picture = ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1.28,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE1D8FE), Color(0xFFF4EFFF)],
                    ),
                  ),
                  child: Padding(
                    padding: article.coverImage
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(16),
                    child: Image(
                      image: article.image,
                      fit: article.coverImage ? BoxFit.cover : BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            );
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelBadge(categoryLabel(article.category)),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: AppStyle.ink(c),
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppStyle.muted(c),
                        ),
                      ),
                      TextSpan(text: '  ${article.readTimeLabel}'),
                    ],
                  ),
                  style: TextStyle(fontSize: 11.5, color: AppStyle.muted(c)),
                ),
              ],
            );
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: box.maxWidth > 180 ? 180 : box.maxWidth,
                    child: picture,
                  ),
                  const SizedBox(height: 12),
                  copy,
                ],
              );
            }
            return Row(
              children: [
                SizedBox(width: box.maxWidth * .28, child: picture),
                const SizedBox(width: 13),
                Expanded(child: copy),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppStyle.tinted(c),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppStyle.purple,
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
