import 'package:flutter/material.dart';
import 'style.dart';

class SettingRow extends StatelessWidget {
  const SettingRow(
      {super.key,
      required this.title,
      this.subtitle,
      this.iconName,
      this.value,
      this.onTap,
      this.switchValue,
      this.onSwitchChanged,
      this.actionKey});
  final String title;
  final String? subtitle, iconName, value;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final Key? actionKey;
  @override
  Widget build(BuildContext c) => LayoutBuilder(builder: (c, box) {
        final narrow =
            box.maxWidth < 280 || MediaQuery.textScalerOf(c).scale(14) > 20;
        final copy =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontSize: 13.5, height: 1.3, color: WellnessStyle.ink(c))),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: TextStyle(
                    fontSize: 11.5, height: 1.3, color: WellnessStyle.muted(c)))
          ],
        ]);
        final trailing = switchValue != null
            ? Semantics(
                label: title,
                child: Switch(
                    key: actionKey,
                    value: switchValue!,
                    onChanged: onSwitchChanged,
                    activeColor: Colors.white,
                    activeTrackColor: WellnessStyle.purple))
            : Text.rich(
                TextSpan(children: [
                  TextSpan(text: value ?? ''),
                  if (onTap != null)
                    const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.chevron_right_rounded,
                            size: 16, color: WellnessStyle.purple))
                ]),
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontSize: 13, color: WellnessStyle.purple));
        final content = Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (iconName != null) ...[
                Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                        color: WellnessStyle.tinted(c),
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(child: AssetIcon(iconName!, size: 17))),
                const SizedBox(width: 11)
              ],
              Expanded(
                  child: narrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [copy, const SizedBox(height: 6), trailing])
                      : Row(children: [
                          Expanded(child: copy),
                          const SizedBox(width: 10),
                          Flexible(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: trailing)),
                        ])),
            ]));
        if (switchValue != null) return content;
        return Material(
            color: Colors.transparent,
            child: InkWell(
                key: actionKey,
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: content));
      });
}
