import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';
import 'package:sleep_buddy/core/constants/radius_constants.dart';

class StatCard extends StatelessWidget {
  final Image? icTitle;
  final String title;
  final String subtitle;
  final String? value;
  final Color? valueTextColor;
  final String? cardBgAsset;

  const StatCard({
    super.key,
    this.icTitle,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueTextColor,
    this.cardBgAsset,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ColorConstant.backgroundCard.withValues(alpha: 0.88),
      borderRadius: RadiusConstants.mediumCircular,
      border: Border.all(color: ColorConstant.border),
      image: cardBgAsset != null
          ?  DecorationImage(
              image: AssetImage(cardBgAsset!),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            )
          : null,
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
                  Expanded(child: _buildTitle()),
                ],
              )
            : _buildTitle(),

        const SizedBox(height: 6),

        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: ColorConstant.textTertiary,
          ),
        ),

        const Spacer(),

        if (value != null)
          Text(
            value!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: valueTextColor ?? ColorConstant.black,
            ),
          ),
        const Spacer(),
      ],
    ),
  );

  Widget _buildTitle() => Text(
    title,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 14,
      color: ColorConstant.black,
      fontWeight: FontWeight.bold,
    ),
  );
}
