import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/focus_rest/presentation/screens/focus_style.dart';


class FocusProgressCard extends StatelessWidget {
  const FocusProgressCard(
      {super.key,
      required this.title,
      required this.countLabel,
      required this.timeDetail,
      required this.progress,
      this.icon = const AssetImage('assets/focus_rest/bolt.png'),
      this.onTapDetail});
  final String title, countLabel, timeDetail;
  final double progress;
  final ImageProvider icon;
  final VoidCallback? onTapDetail;
  @override
  Widget build(BuildContext context) => FocusSurface(
      padding: const EdgeInsets.all(13),
      child: LayoutBuilder(builder: (context, c) {
        final narrow =
            c.maxWidth < 280 || MediaQuery.textScalerOf(context).scale(14) > 20;
        final heading = Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: FocusStyle.ink));
        final detail = InkWell(
            key: const ValueKey('progress-detail'),
            onTap: onTapDetail,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: countLabel),
                      const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.chevron_right_rounded,
                              size: 18, color: FocusStyle.secondary))
                    ]),
                    style: const TextStyle(
                        fontSize: 13, color: FocusStyle.secondary))));
        final body =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (narrow) ...[heading, detail] else
            Row(children: [
              Expanded(child: heading),
              const SizedBox(width: 8),
              Flexible(
                  child: Align(alignment: Alignment.centerRight, child: detail))
            ]),
          const SizedBox(height: 3),
          Semantics(
              label: title,
              value: '${((progress.isFinite ? progress.clamp(0, 1) : 0) * 100)
                      .round()}%',
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                      height: 8,
                      child: Stack(fit: StackFit.expand, children: [
                        const ColoredBox(color: Color(0xFFE8E1FC)),
                        FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.isFinite
                                ? progress.clamp(0.0, 1.0)
                                : 0,
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: FocusStyle.primaryGradient)))
                      ])))),
          const SizedBox(height: 8),
          Text.rich(
              TextSpan(children: [
                const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.access_time_rounded,
                        size: 12, color: FocusStyle.secondary)),
                TextSpan(text: '  $timeDetail')
              ]),
              style: const TextStyle(fontSize: 11, color: FocusStyle.secondary))
        ]);
        final badge = Image(
            image: icon,
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            excludeFromSemantics: true);
        if (c.maxWidth < 200) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [badge, const SizedBox(height: 8), body]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          badge,
          const SizedBox(width: 10),
          Expanded(child: body)
        ]);
      }));
}
