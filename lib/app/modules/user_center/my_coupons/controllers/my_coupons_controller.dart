import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/personal_data/controllers/personal_data_controller.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/stores/user.dart';
import '../../../../../utils/utils.dart';
import '../../common/exchange_coupons_dialog.dart';
import '../../common/transfer_coupons_dialog.dart';


class MyCouponsController extends GetxController {
  final UserStore userStore = UserStore.to;
  final ScrollController scrollController = ScrollController();


  /// 热点活动列表
  final RxList<HotspotsActivityEntity> hotspotsActivityList = <HotspotsActivityEntity>[].obs;

  /// 卡券tab列表
  final RxList<CouponTabEntity> tabbarList = <CouponTabEntity>[].obs;

  final RxInt tabbarIndex = 0.obs;

  final RxInt couponTotal = 0.obs;
  int offset = 0;
  int limit = 30;
  bool isLoading = true;
  /// 卡券列表
  RxList<CouponEntityDatas> couponList = <CouponEntityDatas>[].obs;

  @override
  void onInit() {
    super.onInit();
    userStore.getUserInfo();
    initData();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 && !scrollController.position.outOfRange) {
        if(couponList.length < couponTotal.value && !isLoading) {
          isLoading = true;
          offset += limit;
          getCouponList();
        }
      }
    });
  }

  Future<void> initData() async{
    try {
      ToastUtils.showLoading();
      await getHotspotsActivityList();
      await getCouponTabList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取热点活动列表
  Future<void> getHotspotsActivityList() async{
    List<HotspotsActivityEntity>? res = await CouponsRequest.getHotspotsActivityList();
    if(res == null) return;
    hotspotsActivityList.value = res;
  }

  /// 获取tab列表
  Future<void> getCouponTabList() async{
    List<CouponTabEntity>? res = await CouponsRequest.getCouponTabList();
    if(res == null) return;
    tabbarList.value = res;
    if(res.isEmpty) return;
    await getCouponList(showLoading: false);
  }

  Future<void> getCouponList({bool showLoading = true}) async{
    Map<String, dynamic> parameters = {
      "type": tabbarList[tabbarIndex.value].type,
      "offset": offset,
      "limit": limit,
    };
    try {
      if(showLoading) ToastUtils.showLoading();
      CouponEntity? res = await CouponsRequest.getCouponList(parameters);
      if(res == null) return;
      couponTotal.value = res.count??0;
      if(res.datas == null) return;
      for(CouponEntityDatas? data in res.datas??[]){
        if(data == null) continue;
        couponList.add(data);
      }
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  void changeTabbarIndex(int index){
    tabbarIndex.value = index;
    offset = 0;
    isLoading = true;
    couponList.clear();
    getCouponList();
  }

  /// 跳转至限时优惠详情
  void toLimitDiscountDetail(HotspotsActivityEntity data){
    Get.toNamed(Routes.LIMIT_DISCOUN_DETAIL);
  }

  /// 使用券
  Future<void> activationCoupon(BuildContext context, CouponEntityDatas data) async{
    if(data.jump != null){
      String routeCode = data.jump!.code??"";
      Map<String, dynamic> params = data.jump!.params??{};
      JumpPageUtils.jumpUserPages(routeCode, params);
      return;
    }

    if(data.code == null){
      Get.toNamed(Routes.MEMBER_CENTER);
      return;
    }
    
    bool res = await ExchangeCouponsDialog.couponActivateStart(context, data.code!);
    if(!res) return;

    changeTabbarIndex(tabbarIndex.value);

  }

  /// 兑换卡券
  Future<void> exchangeCoupons(BuildContext context) async{
    bool resCode = await ExchangeCouponsDialog.show(context: context);
    if(!resCode) return;
    changeTabbarIndex(tabbarIndex.value);
    if(Get.isRegistered<PersonalDataController>()){
      Get.find<PersonalDataController>().getCouponTabList();
    }
  }

  /// 转送朋友
  Future<void> transferCoupons(BuildContext context, CouponEntityDatas data) async{
    bool res = await TransferCouponsDialog.show(context: context, data: data);
    if(!res) return;
    changeTabbarIndex(tabbarIndex.value);
    if(Get.isRegistered<PersonalDataController>()){
      Get.find<PersonalDataController>().getCouponTabList();
    }
    UserStore.to.getUserInfo();
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
