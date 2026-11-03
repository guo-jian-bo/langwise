import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../dialog/dialogs.dart';
import '../../../../utils/utils.dart';

class ManageGrammarPanoramaDetailsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageGrammarPanoramaDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_GRAMMAR_PANORAMA_DETAILS;

  @override
  String get breadcrumbTitle => '语法全景详情';

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

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
