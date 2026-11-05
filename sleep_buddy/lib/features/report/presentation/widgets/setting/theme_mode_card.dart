import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/choice_strip.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/style.dart';

class ThemeModeCard extends StatelessWidget {
  const ThemeModeCard({super.key, required this.selected, this.onChanged});
  final ThemeMode selected;
  final ValueChanged<ThemeMode>? onChanged;
  @override
  Widget build(BuildContext c) => WellnessCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Chế độ hiển thị',
          style: TextStyle(fontSize: 14, color: AppStyle.ink(c)),
        ),
        const SizedBox(height: 12),
        ChoiceStrip(
          values: const [ThemeMode.light, ThemeMode.dark, ThemeMode.system],
          selected: selected,
          onChanged: onChanged,
          keyPrefix: 'theme',
          label: (v) => switch (v) {
            ThemeMode.light => 'Sáng',
            ThemeMode.dark => 'Tối',
            ThemeMode.system => 'Hệ thống',
          },
        ),
      ],
    ),
  );
}
