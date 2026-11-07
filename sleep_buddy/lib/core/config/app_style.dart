import 'package:flutter/material.dart';

abstract final class AppStyle {
  static const purple = Color(0xFF7A52F4);
  static const gradient = LinearGradient(
    colors: [Color(0xFFA186FF), Color(0xFF8056F3)],
  );
  static bool dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
  static Color ink(BuildContext c) =>
      dark(c) ? const Color(0xFFF5F0FF) : const Color(0xFF160D3E);
  static Color muted(BuildContext c) =>
      dark(c) ? const Color(0xFFC0B6D8) : const Color(0xFF6B6091);
  static Color surface(BuildContext c) =>
      dark(c) ? const Color(0xFF29233C) : const Color(0xFFFFFEFF);
  static Color track(BuildContext c) =>
      dark(c) ? const Color(0xFF49405E) : const Color(0xFFEDE9F5);
  static Color switchThumb(BuildContext c, {required bool active}) {
    if (active) return Colors.white;
    return dark(c) ? const Color(0xFFAEB4CD) : Colors.white;
  }

  static Color switchTrack(BuildContext c, {required bool active}) {
    if (active) return purple;
    return dark(c) ? const Color(0xFF49405E) : const Color(0xFFDDD6EA);
  }

  static Color border(BuildContext c) =>
      dark(c) ? const Color(0xFF463B61) : const Color(0xFFECE7FA);
  static Color tinted(BuildContext c) =>
      dark(c) ? const Color(0xFF3C3057) : const Color(0xFFF1EDFF);
  static Color navBackground(BuildContext c) =>
      dark(c) ? const Color(0xFF171A32) : const Color(0xFFFFFFFF);
  static Color navBorder(BuildContext c) =>
      dark(c) ? const Color(0xFF343957) : const Color(0xFFF0EDF5);
  static Color navUnselected(BuildContext c) =>
      dark(c) ? const Color(0xFFAEB4CD) : const Color(0xFF160D3E);
  static Shadow navShadow(BuildContext c) => Shadow(
        color: dark(c) ? const Color(0x66000000) : const Color(0x22000000),
        blurRadius: 12,
      );
}

class WellnessCard extends StatelessWidget {
  const WellnessCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  @override
  Widget build(BuildContext c) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: AppStyle.surface(c),
      gradient: AppStyle.dark(c) ? null : gradient,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppStyle.border(c), width: .7),
      boxShadow: const [
        BoxShadow(
          color: Color(0x05613E99),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class AssetIcon extends StatelessWidget {
  const AssetIcon(this.name, {super.key, this.size = 26});
  final String name;
  final double size;
  @override
  Widget build(BuildContext c) => Image.asset(
    'assets/wellness/$name.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}

class LabelBadge extends StatelessWidget {
  const LabelBadge(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: AppStyle.tinted(c),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10.5,
        color: AppStyle.dark(c)
            ? const Color(0xFFCFB7FF)
            : const Color(0xFF4B2DBB),
      ),
    ),
  );
}

class GradientProgress extends StatelessWidget {
  const GradientProgress({
    super.key,
    required this.value,
    this.label = 'Tiến độ',
    this.color,
  });
  final double value;
  final String label;
  final Color? color;
  @override
  Widget build(BuildContext c) {
    final fraction = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
    return Semantics(
      label: label,
      value: '${(fraction * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: AppStyle.track(c)),
              FractionallySizedBox(
                widthFactor: fraction,
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    gradient: color == null ? AppStyle.gradient : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(
    this.title, {
    super.key,
    this.onMore,
    this.moreLabel = 'Xem thêm',
  });
  final String title, moreLabel;
  final VoidCallback? onMore;
  @override
  Widget build(BuildContext c) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    spacing: 12,
    runSpacing: 4,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppStyle.ink(c),
        ),
      ),
      if (onMore != null)
        TextButton(
          onPressed: onMore,
          child: Text(
            '$moreLabel  ›',
            style: const TextStyle(fontSize: 12, color: AppStyle.purple),
          ),
        ),
    ],
  );
}

class AdviceCard extends StatelessWidget {
  const AdviceCard({super.key, required this.title, required this.message});
  final String title, message;
  @override
  Widget build(BuildContext c) => WellnessCard(
    gradient: const LinearGradient(
      colors: [Color(0xFFFFF3E2), Color(0xFFFCECF1)],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssetIcon('sparkle-gold', size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppStyle.ink(c),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppStyle.muted(c),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
