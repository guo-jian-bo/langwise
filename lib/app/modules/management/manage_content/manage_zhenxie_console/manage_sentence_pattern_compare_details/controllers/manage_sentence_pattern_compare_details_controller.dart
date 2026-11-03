import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../utils/utils.dart';
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

  // 传进来的参数
  /// 句型对照详情
  final Rx<SentencePatternCompareEntity> detailData = SentencePatternCompareEntity().obs;
  /// nid
  String? nid;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      nid = Get.arguments["nid"];
      getDetailData();
    }
  }

  /// 获取详情数据
  Future<void> getDetailData() async{
    if(nid == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "nid": nid!,
      };
      ListResponseEntity<SentencePatternCompareEntity>? list = await LanguageConsoleRequest.querySentencePatternCompareList(
        data: reqData,
      );
      if(list == null) return;
      if(list.datas == null) return;
      List<SentencePatternCompareEntity> datas = list.datas??[];

      for (var j = 0; j < datas.length; j++) {
        if(nid == datas[j].nid){
          detailData.value = datas[j];
          detailData.refresh();
          break;
        }
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑名称说明
  Future<void> editNameDesc(BuildContext context) async{
    if(detailData.value.nid == null) return;

    ManageEditNameDescDialogResult? res = await ManageEditNameDescDialog.show(
      context: context,
      name: detailData.value.name,
      description: detailData.value.description,
    );
    if(res == null) return;
    try {
      ToastUtils.showLoading();
      List<Map<String, dynamic>> nameList = [];
      List<Map<String, dynamic>> descriptionList = [];
      res.name?.forEach((e) {
        nameList.add(e?.toJson()??{});
      });
      res.description?.forEach((e) {
        descriptionList.add(e?.toJson()??{});
      });

      Map<String, dynamic> reqData = {
        "name": nameList,
        "description": descriptionList,
      };

      SentencePatternCompareEntity? resp = await LanguageConsoleRequest.editSentencePatternCompare(
        nid: detailData.value.nid!,
        data: reqData,
      );
      if(resp == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      detailData.value = resp;
      detailData.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 编辑对照组
  Future<void> editCompareGroup(BuildContext context) async{
    await ManageEditCompareGroupDialog.show(
      context: context,
      detailData: detailData.value,
    );
    await getDetailData();
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
