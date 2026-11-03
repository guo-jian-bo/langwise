import 'package:flutter/material.dart';

class LearningChipModel {
  final String id;
  final String title;
  final IconData? icon;
  final bool enabled;

  const LearningChipModel({
    required this.id,
    required this.title,
    this.icon,
    this.enabled = true,
  });
}

class LearningCardPageModel {
  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final String minutesUnit;
  final List<LearningChipModel> chips;
  final List<WidgetBuilder> detailBuilders;

  const LearningCardPageModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    this.minutesUnit = '分钟/天',
    this.chips = const <LearningChipModel>[],
    this.detailBuilders = const <WidgetBuilder>[],
  });
}

class LearningCardStackModel {
  final String id;
  final Color primaryColor;
  final Color secondaryColor;
  final List<LearningCardPageModel> pages;

  const LearningCardStackModel({
    required this.id,
    required this.primaryColor,
    required this.secondaryColor,
    required this.pages,
  });
}

class LearningDeckModel {
  final String id;
  final List<LearningCardStackModel> stacks;

  const LearningDeckModel({
    required this.id,
    required this.stacks,
  });
}
