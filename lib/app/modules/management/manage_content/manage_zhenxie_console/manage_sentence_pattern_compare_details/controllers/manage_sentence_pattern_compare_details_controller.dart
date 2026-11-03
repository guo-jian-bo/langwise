import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../dialog/dialogs.dart';
import '../../../../utils/utils.dart';
import '../views/manage_edit_compare_group_dialog.dart';

class ManageSentencePatternCompareDetailsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSentencePatternCompareDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_PATTERN_COMPARE_DETAILS;

  @override
  String get breadcrumbTitle => '句型对照详情';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
  }

  /// 编辑名称说明
  Future<void> editNameDesc(BuildContext context) async{
    await ManageEditNameDescDialog.show(context: context);
  }

  /// 编辑对照组
  Future<void> editCompareGroup(BuildContext context) async{
    await ManageEditCompareGroupDialog.show(context: context);
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
