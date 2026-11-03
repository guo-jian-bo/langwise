
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:langwise/utils/umeng_utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/stores/stores.dart';

class PersonalDataController extends GetxController {
  final UserStore userStore = UserStore.to;

  /// 卡券tab列表
  final RxList<CouponTabEntity> cardCouponsList = <CouponTabEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    userStore.getUserInfo();
    getCouponTabList();
  }
  

  /// 获取卡券tab列表
  Future<void> getCouponTabList() async{
    try {
      ToastUtils.showLoading();
      List<CouponTabEntity>? res = await CouponsRequest.getCouponTabList();
      if(res == null) return;
      cardCouponsList.value = res;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  Future<void> signOut(BuildContext context) async{
    bool askRes = await AskDialog.showUserAsk(context: context, title: "温馨提示", content: "您确定要退出此账号吗？");
    if(!askRes) return;
    try {
      ToastUtils.showLoading();
      await userStore.onLogout("");
      UmengUtils.signOut();
      GuideManager.instance.clearTask();
    } finally{
      ToastUtils.hideLoading();
    }
    Get.offAllNamed(Routes.SIGN_IN_UP);
    
  }

  /// 设置家长密码
  Future<void> setParentPassword(BuildContext context) async{
    SetTeamPasswordDialog.show(context: context, isEdit: userStore.userInfo.value.hasPassword == 1);
  }

  /// 跳转至关于我们
  Future<void> toAboutUs() async{
    await Get.toNamed(Routes.ABOUT_US);
  }  

  /// 跳转至编辑个人信息
  Future<void> toEditUserProfile() async{
    await Get.toNamed(Routes.EDIT_USER_PROFILE);
  }

  /// 跳转至会员中心
  Future<void> toMemberCenter() async{
    await Get.toNamed(Routes.MEMBER_CENTER);
  }

  /// 跳转至我的优惠券
  Future<void> toMyCoupons() async{
    await Get.toNamed(Routes.MY_COUPONS);
  }

  /// 跳转至学点明细
  Future<void> toLearningPointDetails() async{
    await Get.toNamed(Routes.LEARNING_POINT_DETAILS);
  }

  /// 跳转至兑换学点页面
  Future<void> toLearningPointPayment(BuildContext context) async{
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if(!isPwdRight) return;

    // await Get.toNamed(Routes.LEARNING_POINT_PAYMENT);
    await Get.toNamed(Routes.RECHARGE_POINT);
  }

  /// 跳转至充值乃币页面
  Future<void> toRechargeNaibi(BuildContext context) async{
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if(!isPwdRight) return;

    await Get.toNamed(
      Routes.RECHARGE_NAIBI,
      arguments: {
        "pageType": 2,
      },
    );
  }



  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
