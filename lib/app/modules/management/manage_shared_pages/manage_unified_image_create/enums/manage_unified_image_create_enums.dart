import 'package:get/get.dart';

enum GenerationModeEnum{
  /// 文生图
  textToImage("文生图", "generate"),
  /// 图片编辑
  imageEdit("图片编辑", "edit"),
  /// 复用提示词
  reusePrompt("复用提示词", "reuse_prompt"),
  /// 转换风格
  convertStyle("转换风格", "restyle_prompt");

  final String name, value;

  const GenerationModeEnum(this.name, this.value);

  static GenerationModeEnum? fromValue(String? value){
    return GenerationModeEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}

enum ModeModuleEnum{

  /// 自动模式
  auto("自动", "auto"),
  /// Pro模式
  pro("Pro", "pro");

  final String name, value;

  const ModeModuleEnum(this.name, this.value);

  static ModeModuleEnum? fromValue(String? value){
    return ModeModuleEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}