import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/report/domain/model/guide_card.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/app_shell.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/choice_strip.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/style.dart';

/// Parent supplies the already-filtered article list. No fetching or search rules here.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen(
      {super.key,
      required this.articles,
      required this.category,
      this.searchController,
      this.onQueryChanged,
      this.onCategoryChanged,
      this.onArticleOpen,
      this.onSectionChanged,
      this.onNavigation,
      this.onNotification,
      this.maxContentWidth = 600});
  final List<GuideArticle> articles;
  final GuideCategory category;
  final TextEditingController? searchController;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<GuideCategory>? onCategoryChanged;
  final ValueChanged<GuideArticle>? onArticleOpen;
  final ValueChanged<AnalyticsSection>? onSectionChanged;
  final ValueChanged<int>? onNavigation;
  final VoidCallback? onNotification;
  final double maxContentWidth;
  @override
  Widget build(BuildContext c) => WellnessShell(
          title: 'Thống kê & Cài đặt',
          subtitle: 'Kiến thức nhỏ, thói quen học tập tốt hơn.',
          navigationIndex: 4,
          section: AnalyticsSection.library,
          onSectionChanged: onSectionChanged,
          onNavigation: onNavigation,
          onNotification: onNotification,
          maxContentWidth: maxContentWidth,
          children: [
            TextField(
                key: const ValueKey('guide-search'),
                controller: searchController,
                onChanged: onQueryChanged,
                textInputAction: TextInputAction.search,
                style: TextStyle(fontSize: 13, color: WellnessStyle.ink(c)),
                decoration: InputDecoration(
                    hintText: 'Tìm cẩm nang học tập, nghỉ ngơi…',
                    hintStyle: TextStyle(color: WellnessStyle.muted(c)),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF8D7AB7)),
                    filled: true,
                    fillColor: WellnessStyle.surface(c),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: WellnessStyle.border(c))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: WellnessStyle.border(c))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14))),
            ChoiceStrip(
                values: GuideCategory.values,
                selected: category,
                onChanged: onCategoryChanged,
                label: categoryLabel,
                keyPrefix: 'category',
                gradientSelection: false),
            const SectionHeading('Gợi ý dành cho bạn'),
            if (articles.isEmpty)
              WellnessCard(
                  child: Text('Không tìm thấy bài viết phù hợp.',
                      style: TextStyle(color: WellnessStyle.muted(c)))),
            for (final article in articles)
              GuideCard(article: article, onOpen: onArticleOpen),
            const AdviceCard(
                title: 'Đọc một chút, áp dụng mỗi ngày',
                message: 'Bắt đầu với một thay đổi nhỏ trong lịch học.'),
          ]);
}
