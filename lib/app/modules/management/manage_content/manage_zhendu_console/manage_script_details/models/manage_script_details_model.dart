import 'package:flutter/material.dart';

import '../../../../../../../common/entities/entities.dart';

class ManageScriptDetailsModel{

  ManageScriptDetilEntityScenes data;

  /// 是否显示编辑名称输入框
  bool showNameInput;

  /// name
  TextEditingController nameInput;

  /// setting
  TextEditingController settingInput;

  /// summary
  TextEditingController summaryInput;

  /// 参演人员
  List<ManageScriptDetilEntityScenesPersonas> personas;

  /// 台词列表
  List<ManageScriptDetailsLinesModel> dialogues;

  ManageScriptDetailsModel({
    required this.data,
    required this.showNameInput,
    required this.nameInput,
    required this.settingInput,
    required this.summaryInput,
    required this.personas,
    required this.dialogues,
  });

}

class ManageScriptDetailsLinesModel{

  ManageScriptDetilEntityScenesDialogues? data;

  /// 当前演员
  ManageScriptDetilEntityScenesPersonas persona;

  /// 当前情绪
  ManageScriptDetailsEmotionModel emotion;

  /// 当前 delay_after
  TextEditingController delayAfterInput;

  /// 当前是否启用
  bool enabled;

  /// 当前台词
  TextEditingController textInput;

  ManageScriptDetailsLinesModel({
    this.data,
    required this.persona,
    required this.emotion,
    required this.delayAfterInput,
    required this.enabled,
    required this.textInput,
  });
}

class ManageScriptDetailsEmotionModel{
  String emotionNid;
  String emotionName;

  ManageScriptDetailsEmotionModel({
    required this.emotionNid,
    required this.emotionName,
  });
}