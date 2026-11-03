
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
  videoReviewer("videoReviewer");
  

  final String value;
  const UserRoleEnum(this.value);

  factory UserRoleEnum.fromString(String value) {
    return UserRoleEnum.values.firstWhere((e) => e.value == value, orElse: () => none);
  }
}

enum UserAdminGroupEnum{

  /// 官方管理员
  OFFICIAL("OFFICIAL");

  final String value;
  const UserAdminGroupEnum(this.value);

}