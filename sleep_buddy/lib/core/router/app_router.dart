import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_buddy/features/home_screen.dart';
import 'package:sleep_buddy/features/analytics/presentation/screens/guide_detail_screen.dart';
import 'package:sleep_buddy/features/analytics/presentation/model/guide_detail_model.dart';
import 'package:sleep_buddy/features/analytics/presentation/models/models.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/guide/:guideId',
      builder: (context, state) {
        final guide = state.extra;
        if (guide is! GuideArticle) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy bài viết')),
          );
        }

        return GuideDetailScreen(
          data: GuideDetailData(
            id: guide.id,
            tag: categoryLabel(guide.category),
            title: guide.title,
            subtitle: '',
            readTimeLabel: guide.readTimeLabel,
            appliedCountLabel: '0',
            heroImage: guide.image,
            goldenRuleTitle: 'Quy tắc vàng',
            goldenRuleDescription: 'Nghỉ mắt đều đặn trong suốt phiên học.',
            steps: const [
              GuideStep(
                number: 1,
                title: 'Chớp mắt nhanh 10–15 lần',
                description:
                    'Giúp trải đều nước mắt sinh học, chống khô rát khi nhìn màn hình.',
              ),
              GuideStep(
                number: 2,
                title: 'Đảo mắt theo hình số 8',
                description:
                    'Liếc mắt theo đường cong số 8 nằm ngang thật chậm rãi, lặp lại 5 lần.',
              ),
              GuideStep(
                number: 3,
                title: 'Nhìn xa và nhìn gần luân phiên',
                description:
                    'Tập trung vào ngón tay cách 25cm (5s), rồi nhìn vật xa 6m (5s).',
              ),
              GuideStep(
                number: 4,
                title: 'Áp lòng bàn tay ấm lên mắt (Palming)',
                description:
                    'Xoa 2 bàn tay cho nóng rồi nhẹ nhàng úp lên mắt, thư giãn 30 giây.',
              ),
            ],
          ),
          article: guide,
          onBack: () => context.pop(),
        );
      },
    ),
  ],
);
