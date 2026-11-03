// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

enum ManageAudioProjectStatusEnum{
  audio_generating("audio_generating", "子音频生成中"),
  audio_checking("audio_checking", "部分子音频审核完成"),
  audio_checked("audio_checked", "所有需要参与合成的 relation 均已审核通过"),
  composite_generating("composite_generating", "开始执行项目成品合成"),
  finished("finished", "项目成品音频已生成完成，等待项目级审核"),
  checked("checked", "项目成品审核通过并发布关联"),
  failed("failed", "项目在子音频生成或成品合成阶段失败");

  final String value;
  final String label;

  const ManageAudioProjectStatusEnum(this.value, this.label);

  static ManageAudioProjectStatusEnum? fromValue(String value){
    return ManageAudioProjectStatusEnum.values.firstWhereOrNull((element) => element.value == value);
  }

}