// ignore_for_file: constant_identifier_names

enum SceneStoryboardTypeEnum {
  /// 起始帧
  start_frame("start_frame", "起始帧"),

  /// 结束帧
  end_frame("end_frame", "结束帧"),

  /// 高亮帧
  highlight_frame("highlight_frame", "高光帧"),

  /// 环境帧
  environment("environment", "环境图"),

  /// 场景分镜图
  storyboard_sheet("storyboard_sheet", "分镜图");

  const SceneStoryboardTypeEnum(this.value, this.name);

  final String value, name;

  static SceneStoryboardTypeEnum? fromValue(String? value){
    for(SceneStoryboardTypeEnum item in SceneStoryboardTypeEnum.values){
      if(item.value == value) return item;
    }
    return null;
  }
}