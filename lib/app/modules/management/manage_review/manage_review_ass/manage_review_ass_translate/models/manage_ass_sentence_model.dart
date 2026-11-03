

import 'package:flutter/material.dart';
import 'package:langwise/utils/karaoke_subtitles_utils.dart';

class ManageAssSentenceModel{

  SubtitlesSentenceModel sentence;

  AssSubtitle? translation;

  TextEditingController translationInput;

  FocusNode focusNode;

  /// 输入框是否发生了改变
  bool inputChange;

  /// 是否显示删除按钮
  bool isSuperfluous;


  ManageAssSentenceModel({
    required this.sentence,
    required this.translation,
    required this.translationInput,
    required this.focusNode,
    this.inputChange = false,
    this.isSuperfluous = false,
  });
}