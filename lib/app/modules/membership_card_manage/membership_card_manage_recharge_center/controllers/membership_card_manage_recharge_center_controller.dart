import 'package:api/entities/response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_recharge_center/models/membership_card_manage_recharge_center_model.dart';
import 'package:langwise/common/entities/product_info_entity.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/utils/pay_utils.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../controllers/membership_card_manage_controller.dart';

class MembershipCardManageRechargeCenterController extends GetxController {
  final ScrollController scrollController = ScrollController();
  Rx<MembershipCardManageRechargeCenterEntity> rechargeCenterEntity =
      MembershipCardManageRechargeCenterEntity().obs;
  final PayUtils payUtils = PayUtils.instance;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  initData() async {
    try {
      ToastUtils.showLoading();
      ResponseEntity<MembershipCardManageRechargeCenterEntity>? responseEntity =
          await MembershipCardManageApi.rechargeCenterList();
      if (responseEntity?.data == null) return;
      rechargeCenterEntity.value = responseEntity!.data!;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  recharge(MembershipCardManageRechargeCenterModel? model) async {
    if (model == null) return;

    ProductInfoEntityList productInfoEntityList = ProductInfoEntityList(
      servicePackageId: model.serviceId,
      version: model.version,
    );
    bool res = await payUtils.callAlipayWithQrcode(
        Get.context!, productInfoEntityList);
    //支付成功
    if (res) {
      // 账户界面概览刷新数据
      if (Get.isRegistered<MembershipCardManageController>()) {
        MembershipCardManageController membershipCardManageController =
            Get.find<MembershipCardManageController>();
        await membershipCardManageController.initData();
      }
    }
  }
}
