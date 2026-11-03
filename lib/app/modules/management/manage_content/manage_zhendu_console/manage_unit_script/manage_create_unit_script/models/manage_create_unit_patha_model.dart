import 'package:flutter/material.dart';

import '../../../../../../../../common/entities/entities.dart';

class ManageCreateUnitPathAModel{

  ManageUnitCreativityEntity? data;

  /// 是否选中
  bool isSelected;

  /// 题材nid
  String? genreNid;

  /// 场景数量输入框
  TextEditingController sceneCountController;

  /// 故事创意输入框
  TextEditingController storyCreativityController;

  ManageCreateUnitPathAModel({
    this.data,
    this.isSelected = false,
    this.genreNid,
    required this.sceneCountController,
    required this.storyCreativityController,
  });

}