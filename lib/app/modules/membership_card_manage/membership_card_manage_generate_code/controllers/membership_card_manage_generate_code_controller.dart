import 'package:api/entities/response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../controllers/membership_card_manage_controller.dart';
import '../../membership_card_manage_code_manage/controllers/membership_card_manage_code_manage_controller.dart';
import '../models/membership_card_manage_generate_code_model.dart';
import '../views/membership_card_manage_generate_code_dialog.dart';

class MembershipCardManageGenerateCodeController extends GetxController {
  final String tagText;
  MembershipCardManageGenerateCodeController({required this.tagText});

  RxInt selectLevelIndex = 0.obs;
  RxInt additionalCardNum = 1.obs;
  RxInt selectTimeIndex = (-1).obs;

  RxInt usageMonths = 0.obs;

  RxList<MembershipCardManageGenerateCodeVIPListModel> vipList = <MembershipCardManageGenerateCodeVIPListModel>[].obs;
  RxList<MembershipCardManageGenerateCodeCouponSupplyListModel> couponSupplyList = <MembershipCardManageGenerateCodeCouponSupplyListModel>[].obs;
  Rx<MembershipCardManageGenerateCodeSettlementEntity> settlementModel = MembershipCardManageGenerateCodeSettlementEntity().obs;

  RxBool isShowCardNum = false.obs;

  @override
  void onInit() {
    super.onInit();
    initVIPListData();
    initCouponSupplyListData();
  }

  /// 初始化vip列表
  initVIPListData() async {
    try {
      ToastUtils.showLoading();

      final ResponseEntity<MembershipCardManageGenerateCodeVIPListEntity>? res = await MembershipCardManageApi.vipList();
      if (res?.data == null) {
        return;
      }
      vipList.value = res?.data?.list ?? [];
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 初始化月卡、季卡、年卡...列表
  initCouponSupplyListData() async {
    try {
      ToastUtils.showLoading();

      final ResponseEntity<MembershipCardManageGenerateCodeCouponSupplyListEntity>? res = await MembershipCardManageApi.couponSupplyList();
      if (res?.data == null) {
        return;
      }
      couponSupplyList.value = res?.data?.list ?? [];
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 获取结算信息
  getSettlement() async {
    if (selectTimeIndex.value == -1) {
      return;
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity<MembershipCardManageGenerateCodeSettlementEntity>? res = await MembershipCardManageApi.getSettlement(
        parameters: {
          'couponSupplyId': couponSupplyList[selectTimeIndex.value].couponSupplyId,
          'couponSupplyConfigId': couponSupplyList[selectTimeIndex.value].couponSupplyConfigId,
          'quantity': additionalCardNum.value,
          'vipType': vipList[selectLevelIndex.value].vipType,
          'servicePackageId': vipList[selectLevelIndex.value].servicePackageId,
          'version': vipList[selectLevelIndex.value].version,
        },
        data: {},
      );
      if (res?.data == null) {
        return;
      }
      settlementModel.value = res!.data!;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 生成卡密
  Future<void> generateCode() async {
    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await MembershipCardManageApi.generateCode(
        parameters: {},
        data: {
          'couponSupplyId': couponSupplyList[selectTimeIndex.value].couponSupplyId,
          'couponSupplyConfigId': couponSupplyList[selectTimeIndex.value].couponSupplyConfigId,
          'quantity': additionalCardNum.value,
          'vipType': vipList[selectLevelIndex.value].vipType,
          'servicePackageId': vipList[selectLevelIndex.value].servicePackageId,
          'version': vipList[selectLevelIndex.value].version,
          'price': settlementModel.value.price,
        },
      );
      if (res?.data == null) {
        return;
      }

      //卡密管理界面刷新数据
      if (Get.isRegistered<MembershipCardManageCodeManageController>(tag: tagText)) {
        MembershipCardManageCodeManageController membershipCardManageCodeManageController =
            Get.find<MembershipCardManageCodeManageController>(tag: tagText);
        await membershipCardManageCodeManageController.onRefresh();
      }

      // 账户界面概览刷新数据
      if (Get.isRegistered<MembershipCardManageController>(tag: tagText)) {
        MembershipCardManageController membershipCardManageController =
            Get.find<MembershipCardManageController>(tag: tagText);
        await membershipCardManageController.initData();
      }

      // 生成成功
      ToastUtils.showManageToast(text: '生成成功');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //弹出确认支付界面
  void confirmPaymentInformation(BuildContext context) {
    MembershipCardManageGenerateCodeDialog.show(
      context: Get.context!,
      item: {},
      tagText: tagText,
    );
  }
}
