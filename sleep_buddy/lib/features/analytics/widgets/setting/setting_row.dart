import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';

import '../../../../core/config/app_style.dart';

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.value,
    this.onTap,
    this.switchValue,
    this.onSwitchChanged,
    this.actionKey,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  final String title;
  final String? subtitle;
  final String? value;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool? switchValue;
  final void Function()? onSwitchChanged;
  final Key? actionKey;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow =
            constraints.maxWidth < 280 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;

        final content = Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                _buildIcon(context),
                const SizedBox(width: 11),
              ],
              Expanded(
                child: isNarrow
                    ? _buildNarrowLayout(context)
                    : _buildWideLayout(context),
              ),
            ],
          ),
        );

        if (switchValue != null) {
          return content;
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            key: actionKey,
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCopy(context),
        const SizedBox(height: 6),
        _buildTrailing(context),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCopy(context)),
        const SizedBox(width: 10),
        _buildTrailing(context),
      ],
    );
  }

  Widget _buildCopy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.3,
            color: AppStyle.ink(context),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.3,
              color: AppStyle.muted(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        color: AppStyle.tinted(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Icon(icon, size: 17, color: ColorConstant.primary)),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (switchValue != null) {
      return Semantics(
        label: title,
        child: Switch(
          key: actionKey,
          value: switchValue!,
          onChanged: onSwitchChanged == null
              ? null
              : (value) => onSwitchChanged!(),
          activeThumbColor: AppStyle.switchThumb(context, active: true),
          activeTrackColor: AppStyle.switchTrack(context, active: true),
          inactiveThumbColor: AppStyle.switchThumb(context, active: false),
          inactiveTrackColor: AppStyle.switchTrack(context, active: false),
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: value ?? ''),
          if (onTap != null)
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppStyle.purple,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 13, color: AppStyle.purple),
    );
  }
}
