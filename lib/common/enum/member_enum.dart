// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

enum MemberEnum {

  Free("Free"),
  Plus("Plus"),
  Pro("Pro"),
  Max("Max");

  final String value;

  const MemberEnum(this.value);

  factory MemberEnum.from(String? value) {
    return MemberEnum.values.firstWhereOrNull((e) => e.value.toLowerCase() == value?.toLowerCase()) ?? MemberEnum.Free;
  }

}