import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/constants/radius_constants.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class StatCard extends StatelessWidget {
  final Image? icTitle;
  final String title;
  final String subtitle;
  final String? value;
  final Color? valueTextColor;
  final String cardBgAsset;

  const StatCard({
    super.key,
    this.icTitle,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueTextColor,
    required this.cardBgAsset,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: RadiusConstants.mediumCircular,
      border: Border.all(color: AppStyle.border(context)),
      image: DecorationImage(
              image: AssetImage(cardBgAsset),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icTitle != null
            ? Row(
                children: [
                  icTitle!,
                  const SizedBox(width: 8),
                  Expanded(child: _buildTitle(context)),
                ],
              )
            : _buildTitle(context),

        const SizedBox(height: 6),

        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: AppStyle.muted(context)),
        ),
        const SizedBox(height: 10),
        if (value != null)
          Text(
            value!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppStyle.dark(context)
                  ? AppStyle.ink(context)
                  : valueTextColor ?? AppStyle.ink(context),
            ),
          ),
      ],
    ),
  );

  Widget _buildTitle(BuildContext context) => Text(
    title,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: 14,
      color: AppStyle.ink(context),
      fontWeight: FontWeight.bold,
    ),
  );
}
