import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/core/db/guide_detail_dao.dart';
import 'package:sleep_buddy/features/analytics/model/guide_detail_model.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';

class GuideDetailScreen extends StatefulWidget {
  const GuideDetailScreen({
    super.key,
    required this.data,
    this.article,
    this.onBack,
  });

  final GuideDetailData data;
  final GuideArticle? article;
  final VoidCallback? onBack;

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  GuideDetailData? _databaseData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.article == null) return;
    final data = await GuideDetailDao.getByArticle(widget.article!);
    if (!mounted || data == null) return;
    setState(() => _databaseData = data);
  }

  @override
  Widget build(BuildContext context) {
    final data = _databaseData ?? widget.data;
    return Scaffold(
      backgroundColor: AppStyle.dark(context)
          ? const Color(0xFF1C1729)
          : const Color(0xFFEFEDFF),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppStyle.dark(context)
                ? [const Color(0xFF1C1729), const Color(0xFF221B30)]
                : [const Color(0xFFEFEDFF), const Color(0xFFFCFBFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _buildCircleButton(
                      context: context,
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'Quay lại',
                      onTap: widget.onBack,
                      key: const ValueKey('guide-back'),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Chi tiết cẩm nang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppStyle.ink(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WellnessCard(
                        padding: const EdgeInsets.all(8),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8E1FF), Color(0xFFF5EFFF)],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 1.8,
                            child: Image(
                              image: data.heroImage,
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      WellnessCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                LabelBadge(data.tag),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: AppStyle.muted(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${data.readTimeLabel}  •  ${data.appliedCountLabel}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppStyle.muted(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppStyle.ink(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: AppStyle.muted(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      AdviceCard(
                        title: data.goldenRuleTitle,
                        message: data.goldenRuleDescription,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Các bước thực hành',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppStyle.ink(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final step in data.steps) ...[
                        _buildStepCard(context, step),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    Color? iconColor,
    Key? key,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppStyle.surface(context),
        border: Border.all(color: AppStyle.border(context), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064F2D96),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: iconColor ?? AppStyle.ink(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, GuideStep step) {
    return WellnessCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppStyle.gradient,
            ),
            child: Center(
              child: Text(
                step.number.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppStyle.ink(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppStyle.muted(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
