import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/features/analytics/cubit/library_cubit.dart';
import 'package:sleep_buddy/features/analytics/cubit/library_state.dart';
import 'package:sleep_buddy/features/analytics/widgets/guide_card.dart';
import 'package:sleep_buddy/features/analytics/widgets/analytics_shell.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';
import 'package:sleep_buddy/features/sleep/widgets/choice_strip.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, this.onSectionChanged});
  final ValueChanged<AnalyticsSection>? onSectionChanged;

  @override
  State<StatefulWidget> createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _controller = TextEditingController();

  void _openGuide(BuildContext context, GuideArticle guide) {
    context.push(
      '/guide/${guide.id}',
      extra: guide,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => BlocBuilder<LibraryCubit, LibraryState>(
    builder: (context, state) => AnalyticsShell(
      title: 'Thống kê & Cài đặt',
      subtitle: 'Kiến thức nhỏ, thói quen học tập tốt hơn.',
      section: AnalyticsSection.library,
      onSectionChanged: widget.onSectionChanged,
      children: [
        TextField(
          key: const ValueKey('guide-search'),
          controller: _controller,
          onChanged: context.read<LibraryCubit>().searchArticles,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: 13, color: AppStyle.ink(c)),
          decoration: InputDecoration(
            hintText: 'Tìm cẩm nang học tập, nghỉ ngơi…',
            hintStyle: TextStyle(color: AppStyle.muted(c)),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF8D7AB7),
            ),
            filled: true,
            fillColor: AppStyle.surface(c),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: AppStyle.border(c)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: AppStyle.border(c)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        ChoiceStrip(
          values: GuideCategory.values,
          selected: state.selectedCategory,
          onChanged: context.read<LibraryCubit>().selectCategory,
          label: categoryLabel,
          keyPrefix: 'category',
          gradientSelection: false,
        ),
        const SectionHeading('Gợi ý dành cho bạn'),
        if (state.articles.isEmpty)
          WellnessCard(
            child: Text(
              'Không tìm thấy bài viết phù hợp.',
              style: TextStyle(color: AppStyle.muted(c)),
            ),
          )
        else
          ...state.articles.map(
            (article) => GuideCard(
              article: article,
              onOpen: (guide) => _openGuide(context, guide),
            ),
          ),
        const AdviceCard(
          title: 'Đọc một chút, áp dụng mỗi ngày',
          message: 'Bắt đầu với một thay đổi nhỏ trong lịch học.',
        ),
        SizedBox(height: kBottomNavigationBarHeight),
      ],
    ),
  );
}
