
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
  
  ElementsDetilsDataModel({
    this.key, 
    required this.type, 
    this.data,
    this.hideStar = false,
  });
}
