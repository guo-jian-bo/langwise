enum VideoRameModeEnum{
  /// 全部
  all("全部"),
  /// 首帧模式
  firstFrame("首帧"),
  /// 首尾帧模式
  firstAndLastFrame("首尾桢"),
  /// 多帧模式
  multiFrame("多帧");

  final String name;
  const VideoRameModeEnum(this.name);

}