import 'package:flutter/material.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../enums/manage_script_mode_enum.dart';

class ManageCreateVocabularyPathBModel{

  /// 题材
  ManageScriptGenreEntity genre;

  /// 是否选中
  bool isSelected;

  /// 场景数量 输入框
  TextEditingController sceneCountController;

    /// 难度等级
  String? cefr;
  
  /// 剧本模式
  ManageScriptModeEnum? scriptMode;

  /// 故事创意输入框
  TextEditingController storyCreativityController;

  /// 必须包含的语义列表
  List<ManageVocabularyCreativityEntityMustIncludeSemantics> mustIncludeSemantics;


  ManageCreateVocabularyPathBModel({
    required this.genre,
    this.isSelected = false,
    required this.sceneCountController,
    required this.storyCreativityController,
    this.cefr,
    this.scriptMode,
    required this.mustIncludeSemantics,
  });

}

