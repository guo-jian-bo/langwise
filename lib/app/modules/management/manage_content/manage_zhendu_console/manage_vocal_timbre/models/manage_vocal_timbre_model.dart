import 'package:flutter/material.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../enums/manage_zhendu_enums.dart';

class ManageVocalTimbreModel{
  ManageVocalTimbreEntity? data;

  /// nid
  TextEditingController nidInput;

  /// 中文名称
  TextEditingController zhNameInput;

  /// 英文名称
  TextEditingController enNameInput;

  /// category
  ManageZhenduVocalTimbreCategoryEnum? category;

  /// gender
  ManageZhenduGenderEnum? gender;

  /// age_group
  ManageZhenduAgeGroupEnum? ageGroup;

  /// manner
  ManageZhenduVocalTimbreMannerEnum? manner;

  /// morality
  ManageZhenduVocalTimbreMoralityEnum? morality;

  /// background
  ManageZhenduVocalTimbreBackgroundEnum? background;

  /// label
  TextEditingController labelInput;

  /// 方言音色code列表
  List<ManageVocalDialectTimbreCodeModel> dialectTimbreCodes;

  /// 方言音色
  List<ManageVocalDialectTimbreModel> dialectTimbres;

  ManageVocalTimbreModel({
    this.data,
    required this.nidInput,
    required this.zhNameInput,
    required this.enNameInput,
    required this.category,
    required this.gender,
    required this.ageGroup,
    required this.manner,
    required this.morality,
    required this.background,
    required this.labelInput,
    required this.dialectTimbreCodes,
    required this.dialectTimbres,
  });

}

class ManageVocalDialectTimbreCodeModel{
  /// code
  String code;
  /// 是否占用
  bool isOccupy;

  ManageVocalDialectTimbreCodeModel({
    required this.code,
    this.isOccupy = false,
  });
}

class ManageVocalDialectTimbreModel{

  /// dialect
  String dialect;

  /// description
  TextEditingController descriptionInput;

  /// 设计台词 audio_text
  TextEditingController audioTextInput;

  /// 参考演员
  TextEditingController actorInput;

  /// 参考链接
  TextEditingController urlInput;

  /// 数据
  ManageVocalTimbreEntityAudioRefs? data;

  /// 音频数据
  ManageVocalTimbreEntityAudioRefsAudio? audio;

  ManageVocalDialectTimbreModel({
    required this.dialect,
    required this.descriptionInput,
    required this.audioTextInput,
    required this.actorInput,
    required this.urlInput,
    this.data, 
    this.audio,
  });

}
