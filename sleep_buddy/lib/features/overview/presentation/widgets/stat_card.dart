import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final Color valueColor;

  const StatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 140,
      ),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ColorConstant.backgroundCard.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: ColorConstant.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: ColorConstant.textCard,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstant.textTertiary,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}