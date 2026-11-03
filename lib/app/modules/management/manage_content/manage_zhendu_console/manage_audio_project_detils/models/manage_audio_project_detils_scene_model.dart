import 'package:flutter/material.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../enums/manage_zhendu_enums.dart';

class ManageAudioProjectDetilsSceneModel {
  ManageScriptDetilEntityScenes data;
  TextEditingController settingInput;
  TextEditingController summaryInput;
  List<ManageAudioProjectDetilsLineModel> dialogues;

  ManageAudioProjectDetilsSceneModel({
    required this.data,
    required this.settingInput,
    required this.summaryInput,
    required this.dialogues,
  });

}

class ManageAudioProjectDetilsLineModel {
  ManageScriptDetilEntityScenesDialogues? data;
  TextEditingController delayAfterInput;
  TextEditingController textInput;
  ManageZhenduAudioFilterEnum filter;
  double dryWet;

  ManageAudioProjectDetilsLineModel({
    this.data,
    required this.delayAfterInput,
    required this.textInput,
    this.filter = ManageZhenduAudioFilterEnum.none,
    this.dryWet = 0,
  });

}

