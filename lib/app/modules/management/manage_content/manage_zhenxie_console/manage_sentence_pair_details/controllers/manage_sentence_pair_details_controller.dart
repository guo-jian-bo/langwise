import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../dialog/dialogs.dart';
import '../../../../utils/utils.dart';
import '../views/manage_edit_pair_sentence_dialog.dart';

class ManageSentencePairDetailsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSentencePairDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_PAIR_DETAILS;

  @override
  String get breadcrumbTitle => '句间配链详情';

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

  /// 编辑对句
  Future<void> editPairSentence(BuildContext context) async{
    await ManageEditPairSentenceDialog.show(context: context);
  }

  /// 打开棋盘
  Future<void> toForkDetails() async{
    ManagePageRegistry.jumpTo(Routes.MANAGE_SENTENCE_PAIR_FORK_DETAILS);
  } 

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
