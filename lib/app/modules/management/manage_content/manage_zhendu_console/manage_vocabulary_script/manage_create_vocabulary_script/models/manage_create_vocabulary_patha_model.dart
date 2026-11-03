import 'package:flutter/material.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../enums/manage_script_mode_enum.dart';

class ManageCreateVocabularyPathAModel{

  ManageVocabularyCreativityEntity? data;

  /// 是否选中
  bool isSelected;

  /// 题材nid
  String? genreNid;

  /// 场景数量输入框
  TextEditingController sceneCountController;

  /// 难度等级
  String? cefr;
  
  /// 剧本模式
  ManageScriptModeEnum? scriptMode;

  /// 故事创意输入框
  TextEditingController storyCreativityController;

  /// 必须包含的语义列表
  List<ManageCreateVocabularyPathASemanticModel> mustIncludeSemantics;

  ManageCreateVocabularyPathAModel({
    this.data,
    this.isSelected = false,
    this.genreNid,
    required this.sceneCountController,
    required this.storyCreativityController,
    this.cefr,
    this.scriptMode,
    required this.mustIncludeSemantics,
  });

}

/// 语义列表
class ManageCreateVocabularyPathASemanticModel{
  ManageVocabularyCreativityEntityMustIncludeSemantics data;
  bool isSelected;

  ManageCreateVocabularyPathASemanticModel({
    required this.data,
    this.isSelected = false,
  });

  
}