import 'package:flutter/material.dart';

import '../../../../../../../common/entities/entities.dart';

class ManageScriptThemeModel{

  /// 服务器返回的原始数据
  ManageScriptThemeEntity? data;

  /// nid
  TextEditingController nidInput;

  /// category
  TextEditingController categoryInput;

  /// 中文名称
  TextEditingController zhNameInput;

  /// 英文名称
  TextEditingController enNameInput;

  /// 中文描述
  TextEditingController zhDescInput;
  
  /// 英文描述
  TextEditingController enDescInput;

  /// difficulty.min
  TextEditingController difficultyMinInput;

  /// difficulty.max
  TextEditingController difficultyMaxInput;

  /// suggested_personas
  TextEditingController suggestedPersonasInput;

  ManageScriptThemeModel({
    this.data,
    required this.nidInput,
    required this.categoryInput,
    required this.zhNameInput,
    required this.enNameInput,
    required this.zhDescInput,
    required this.enDescInput,
    required this.difficultyMinInput,
    required this.difficultyMaxInput,
    required this.suggestedPersonasInput,
  });

}