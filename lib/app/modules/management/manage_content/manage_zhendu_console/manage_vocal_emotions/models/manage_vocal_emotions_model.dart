import 'package:flutter/material.dart';

import '../../../../../../../common/entities/entities.dart';

class ManageVocalEmotionsModel{

  ManageVocalEmotionsEntity? data;
  
  /// nid
  TextEditingController nidInput;

  /// suggested_speed
  TextEditingController suggestedSpeedInput;

  /// 中文名称
  TextEditingController zhNameInput;

  /// 英文名称
  TextEditingController enNameInput;

  /// 中文描述
  TextEditingController zhDescInput;
  
  /// 英文描述
  TextEditingController enDescInput;

  /// happy 滑块
  double happySlider;
  /// sad 滑块
  double sadSlider;
  /// disgusted 滑块
  double disgustedSlider;
  /// surprised 滑块
  double surprisedSlider;
  /// angry 滑块
  double angrySlider;
  /// afraid 滑块
  double afraidSlider;
  /// melancholic 滑块
  double melancholicSlider;
  /// calm 滑块
  double calmSlider;

  ManageVocalEmotionsModel({
    this.data,
    required this.nidInput,
    required this.suggestedSpeedInput,
    required this.zhNameInput,
    required this.enNameInput,
    required this.zhDescInput,
    required this.enDescInput,
    this.happySlider = 0,
    this.sadSlider = 0,
    this.disgustedSlider = 0,
    this.surprisedSlider = 0,
    this.angrySlider = 0,
    this.afraidSlider = 0,
    this.melancholicSlider = 0,
    this.calmSlider = 0,
  });

}