import 'package:flutter/material.dart';

import '../../../../enums/enums.dart';

class ManageTicketFormModel{
  /// 表单类型
  final TicketFormTypeEnum formType;

  /// 是否必填
  bool isRequired;

  /// 表单项标题 输入框控制器
  final TextEditingController titleController;

  /// 提示文案 输入框控制器
  final TextEditingController hintController;

  /// 输入框类型的控制器
  List<TextEditingController>? optionInputs;

  /// 是否允许修改选项
  bool updateOptions;

  /// 是否允许删除选项
  bool deleteOptions;

  /// 是否允许添加选项
  bool addOptions;

  /// key
  GlobalKey key;

  ManageTicketFormModel({
    required this.formType,
    this.isRequired = false,
    required this.titleController,
    required this.hintController,
    this.optionInputs,
    this.updateOptions = true,
    this.deleteOptions = true,
    this.addOptions = true,
    required this.key,
  });
}