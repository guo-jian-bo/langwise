
// ignore_for_file: constant_identifier_names

enum UserRoleEnum{
  /// 没有任何权限
  none("none"),

  /// 审图员
  imageReviewer("imageReviewer"),

  /// 超记审图员
  imageSuperReviewer("imageSuperReviewer"),

  /// 审核题目
  exerciseReviewer("exerciseReviewer"),
  
  /// 视频审核员
  videoReviewer("videoReviewer"),
  videoSuperReviewer("videoSuperReviewer"),

  /// 字幕审核员
  assReviewer("assReviewer"),
  assSuperReviewer("assSuperReviewer"), 
  
  /// 音频审核员
  audioReviewer("audioReviewer"),
  audioSuperReviewer("audioSuperReviewer");
  

  final String value;
  const UserRoleEnum(this.value);

  factory UserRoleEnum.fromString(String value) {
    return UserRoleEnum.values.firstWhere((e) => e.value == value, orElse: () => none);
  }
}

enum UserAdminGroupEnum{

  /// 官方管理员
  OFFICIAL("OFFICIAL"),

  CHANNEL("CHANNEL");

  final String value;
  const UserAdminGroupEnum(this.value);

}
