import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/stores/user.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/invitation_dialogs/coupon_giveaway_dialog.dart';
import '../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../common/exchange_coupons_dialog.dart';


class MyCouponsController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  MyCouponsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MY_COUPONS;

  @override
  String get breadcrumbTitle => "我的优惠券";

  final UserStore userStore = UserStore.to;
  final ScrollController scrollController = ScrollController();


  /// 热点活动列表
  final RxList<PushMessageEntity> hotspotsActivityList = <PushMessageEntity>[].obs;

  /// 卡券tab列表
  final RxList<CouponTabEntity> tabbarList = <CouponTabEntity>[].obs;

  final RxInt tabbarIndex = 0.obs;

  final RxInt couponTotal = 0.obs;
  int offset = 0;
  int limit = 200;
  bool isLoading = true;
  /// 卡券列表
  RxList<CouponEntityDatas> couponList = <CouponEntityDatas>[].obs;

  StreamSubscription<PushMessageServiceEnitiy>? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    userStore.getUserInfo();
    initData(isGuide: true);
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 && !scrollController.position.outOfRange) {
        if(couponList.length < couponTotal.value && !isLoading) {
          isLoading = true;
          offset += limit;
          getCouponList();
        }
      }
    });

    _messageSubscription = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.refreshHomePageAd], 
      onData: (value){
        getHotspotsActivityList();
      },
    );
    

  }

  Future<void> initData({bool isGuide = false}) async{
    try {
      ToastUtils.showLoading();
      if(isGuide){
        await GuideTaskController.to.loadTasks(pageCode: AppRoutesCode.myCoupons);
      }
      await getHotspotsActivityList();
      await getCouponTabList();
      if(isGuide){
        await Future.delayed(const Duration(milliseconds: 100));
        GuideTaskController.to.start(AppRoutesCode.myCoupons);
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取热点活动列表
  Future<void> getHotspotsActivityList() async{

    List<PushMessageEntity>? adList = await ActivitiesRequest.getHomeAdList("redeem");
    if(adList == null) return;
    hotspotsActivityList.value = adList;
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

  /// 使用券
  Future<void> activationCoupon(BuildContext context, CouponEntityDatas data) async{
    if(data.jump != null){
      JumpPageUtils.jumpUserPages(data.jump);
      return;
    }

    if(data.isDiscount){
      bool res = await ExchangeCouponsDialog.showDiscountexchangeCoupons(context: context, data: data);
      if(!res) return;
      changeTabbarIndex(tabbarIndex.value);
      return;
    }
    
    bool res = await ExchangeCouponsDialog.couponActivateStart(context, data.code!);
    if(!res) return;

    changeTabbarIndex(tabbarIndex.value);

  }

  /// 兑换卡券
  Future<void> exchangeCoupons(BuildContext context) async{
    bool resCode = await ExchangeCouponsDialog.show(context: context);
    if(!resCode) {
      GuideTaskController.to.stop();
      return;
    }
    changeTabbarIndex(tabbarIndex.value);
    GuideTaskController.to.continueGuide(AppRoutesCode.myCoupons, GuideWidgetIds.myCouponsCouponExchangeButton);
  }

  /// 转送朋友
  Future<void> transferCoupons(BuildContext context, CouponEntityDatas data) async{
    
    bool res = await CouponGiveawayDialog.showMethodDialog(context: context, data: data);

    if(!res) return;
    changeTabbarIndex(tabbarIndex.value);
    UserStore.to.getUserInfo();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _messageSubscription?.cancel();
    super.onClose();
  }
}
