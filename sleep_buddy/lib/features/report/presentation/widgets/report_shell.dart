import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/choice_strip.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/style.dart';

class ReportShell extends StatelessWidget {
  const ReportShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.section = AnalyticsSection.report,

    this.maxContentWidth = 600,
    this.onSectionChanged,
  });
  final String title, subtitle;
  final List<Widget> children;
  final AnalyticsSection? section;
  final double maxContentWidth;
  final ValueChanged<AnalyticsSection>? onSectionChanged;

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: AppStyle.dark(c)
        ? const Color(0xFF1C1729)
        : const Color(0xFFEFEDFF),
    body: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppStyle.dark(c)
              ? [const Color(0xFF1C1729), const Color(0xFF221B30)]
              : [const Color(0xFFEFEDFF), const Color(0xFFFCFBFF)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          key: PageStorageKey('wellness-content-${section?.name}'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 21,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: AppStyle.ink(c),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.35,
                                color: AppStyle.muted(c),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (section != null) ...[
                    ChoiceStrip(
                      values: AnalyticsSection.values,
                      selected: section!,
                      keyPrefix: 'section',
                      label: (v) => switch (v) {
                        AnalyticsSection.report => 'Báo cáo',
                        AnalyticsSection.library => 'Cẩm nang',
                        AnalyticsSection.settings => 'Cài đặt',
                      },
                      onChanged: onSectionChanged,
                    ),
                    const SizedBox(height: 14),
                  ],
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
