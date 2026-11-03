
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/elements_card_type.dart';

class ElementsDetilsTabModel{
  final String name;
  final ScrollController scrollController;
  final ElementsCardType? type;
  List<ElementsDetilsDataModel>? data;
  LockEntity? rights;

  bool isInit = false;

  final RxBool isNotData = false.obs;
  int offset = 0;
  int limit = 40;
  int count = 0;
  bool isLoading = true;
  
  ElementsDetilsTabModel({required this.name, required this.scrollController, this.type, this.data, this.rights});
}


class ElementsDetilsDataModel{
  GlobalKey? key;
  ElementsCardType type;
  ElementsCardEntityDatas? data;
  bool hideStar;

  /// 高亮文本(暂时用于句子)
  List<ElementsDetilsDataHighlightModel>? sentenceHighlights;
  
  ElementsDetilsDataModel({
    this.key, 
    required this.type, 
    this.data,
    this.hideStar = false,
    this.sentenceHighlights,
  });
}

class ElementsDetilsDataHighlightModel{
  String? text;
  int? start;
  int? end;
  Color? highlightColor;

  ElementsDetilsDataHighlightModel({
    this.text,
    this.start,
    this.end,
    this.highlightColor,
  });
}