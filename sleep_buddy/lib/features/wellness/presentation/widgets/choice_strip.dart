import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'style.dart';

/// Measures labels including system text scaling, then scrolls if needed.
class ChoiceStrip<T> extends StatelessWidget {
  const ChoiceStrip({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.gradientSelection = true,
    this.keyPrefix = 'choice',
  });
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T>? onChanged;
  final bool gradientSelection;
  final String keyPrefix;
  @override
  Widget build(BuildContext c) => LayoutBuilder(
    builder: (c, box) {
      final style = TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: DefaultTextStyle.of(c).style.fontFamily,
      );
      final widths = values.map((v) {
        final p = TextPainter(
          text: TextSpan(text: label(v), style: style),
          textDirection: Directionality.of(c),
          textScaler: MediaQuery.textScalerOf(c),
        )..layout();
        final w = math.max(48.0, p.width + 28);
        p.dispose();
        return w;
      }).toList();
      final natural =
          widths.fold<double>(0, (a, b) => a + b) +
          math.max(0, values.length - 1) * 6 +
          8;
      final extra = values.isEmpty
          ? 0.0
          : math.max(0.0, box.maxWidth - natural) / values.length;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppStyle.tinted(c).withValues(alpha: .6),
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                for (var i = 0; i < values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  SizedBox(
                    width: widths[i] + extra,
                    child: Semantics(
                      selected: values[i] == selected,
                      button: true,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: values[i] == selected && gradientSelection
                              ? AppStyle.gradient
                              : null,
                          color: values[i] == selected && !gradientSelection
                              ? AppStyle.surface(c)
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: ValueKey('$keyPrefix-$i'),
                            borderRadius: BorderRadius.circular(24),
                            onTap: onChanged == null
                                ? null
                                : () => onChanged!(values[i]),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 40),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                child: Center(
                                  child: Text(
                                    label(values[i]),
                                    textAlign: TextAlign.center,
                                    style: style.copyWith(
                                      color: values[i] == selected
                                          ? (gradientSelection
                                                ? Colors.white
                                                : AppStyle.purple)
                                          : AppStyle.muted(c),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
