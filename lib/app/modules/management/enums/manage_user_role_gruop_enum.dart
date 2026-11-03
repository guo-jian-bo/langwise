// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

enum ManageUserRoleGruopEnum{
  OFFICIAL("OFFICIAL", "官方"),
  KOL("KOL", "KOL"),
  CHANNEL("CHANNEL", "渠道"),
  MODERATOR("MODERATOR", "协管"),
  SPECIALIST("SPECIALIST", "专家"),
  USER("USER", "用户")
  ;


  final String name;
  final String value;
  const ManageUserRoleGruopEnum(this.value, this.name);

  static ManageUserRoleGruopEnum? fromValue(String? value){
    return ManageUserRoleGruopEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}



