
import 'package:flutter/material.dart';

import '../../../../../../../common/entities/entities.dart';

class ManageScriptGenreModel{

  ManageScriptGenreEntity? data;

  // nid
  TextEditingController nidInput;

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

  /// description_for_prompt
  TextEditingController descriptionForPromptInput;

  /// audio_characteristics
  TextEditingController audioCharacteristicsInput;

  ManageScriptGenreModel({
    this.data,
    required this.nidInput,
    required this.zhNameInput,
    required this.enNameInput,
    required this.zhDescInput,
    required this.enDescInput,
    required this.difficultyMinInput,
    required this.difficultyMaxInput,
    required this.descriptionForPromptInput,
    required this.audioCharacteristicsInput,
  });

}