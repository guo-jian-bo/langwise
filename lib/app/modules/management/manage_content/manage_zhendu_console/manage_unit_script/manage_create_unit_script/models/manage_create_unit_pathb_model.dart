import 'package:flutter/material.dart';

import '../../../../../../../../common/entities/entities.dart';

class ManageCreateUnitPathBModel{

  /// 题材
  ManageScriptGenreEntity genre;

  /// 是否选中
  bool isSelected;

  /// 场景数量 输入框
  TextEditingController sceneCountController;

  /// 故事创意 输入框
  TextEditingController storyCreativityController;

  ManageCreateUnitPathBModel({
    required this.genre,
    this.isSelected = false,
    required this.sceneCountController,
    required this.storyCreativityController,
  });

}