import 'package:flutter/material.dart';

@immutable
class GuideStep {
  const GuideStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final int number;
  final String title;
  final String description;
}

@immutable
class GuideDetailData {
  const GuideDetailData({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.readTimeLabel,
    required this.appliedCountLabel,
    required this.heroImage,
    required this.goldenRuleTitle,
    required this.goldenRuleDescription,
    required this.steps,
  });

  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final String readTimeLabel;
  final String appliedCountLabel;
  final ImageProvider heroImage;
  final String goldenRuleTitle;
  final String goldenRuleDescription;
  final List<GuideStep> steps;

  GuideDetailData copyWith({
    String? id,
    String? tag,
    String? title,
    String? subtitle,
    String? readTimeLabel,
    String? appliedCountLabel,
    ImageProvider? heroImage,
    String? goldenRuleTitle,
    String? goldenRuleDescription,
    List<GuideStep>? steps,
    String? actionButtonLabel,
    bool? isBookmarked,
  }) => GuideDetailData(
    id: id ?? this.id,
    tag: tag ?? this.tag,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    readTimeLabel: readTimeLabel ?? this.readTimeLabel,
    appliedCountLabel: appliedCountLabel ?? this.appliedCountLabel,
    heroImage: heroImage ?? this.heroImage,
    goldenRuleTitle: goldenRuleTitle ?? this.goldenRuleTitle,
    goldenRuleDescription: goldenRuleDescription ?? this.goldenRuleDescription,
    steps: steps ?? this.steps,
  );
}
