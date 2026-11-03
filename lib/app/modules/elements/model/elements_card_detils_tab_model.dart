import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../common/entities/entities.dart';

class ElementsCardDetilsTabModel{
  List<LanguageText?> potTitle;
  String pos;
  int? contentId;
  String? contentType;
  ScrollController scrollController;
  ListObserverController observerController;
  RxInt tagTabbarIndex;
  Color? indicatorColor;

  ElementsCardDetilsTabModel({
    required this.potTitle,
    required this.pos,
    this.contentId,
    this.contentType,
    required this.scrollController,
    required this.observerController,
    required this.tagTabbarIndex,
    this.indicatorColor,
  });
}