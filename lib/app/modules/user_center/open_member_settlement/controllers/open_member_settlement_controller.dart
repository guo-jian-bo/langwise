import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/stores/stores.dart';
import '../../../../../config.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../../routes/tag_routes.dart';
import '../../../application/controllers/application_controller.dart';
import '../../common/confirm_member_order_dialog.dart';
import '../../controllers/user_center_controller.dart';
import '../../member_center/controllers/member_center_controller.dart';

class OpenMemberSettlementController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  OpenMemberSettlementController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OPEN_MEMBER_SETTLEMENT;

  @override
  String get breadcrumbTitle => "会员结算";

  /// 传进来的参数
  int? servicePackageId;
  int? servicePackageVersion;

  /// 是否是购买席位
  bool isBuySeat = false;

  /// 席位id 如果不为null 就是续费席位
  int? traineeId;

  /// 是否是补齐会员
  bool isCompletionPrice = false;

  /// 结算明细
  final Rx<PackageShopDetailEntity> packageShopDetail = PackageShopDetailEntity().obs;

  /// 当前会员和购买的会员信息
  final Rx<PackageShopDetailEntityServicePackage> servicePackage = PackageShopDetailEntityServicePackage().obs;

  /// 优惠券列表
  final RxList<PackageShopDetailEntityCoupons> couponList = <PackageShopDetailEntityCoupons>[].obs;

  /// 使用卡券信息
  final RxList<PackageShopDetailEntityServicePackageCouponEffects> couponEffects = <PackageShopDetailEntityServicePackageCouponEffects>[].obs;

  /// 额外购买的信息(成员名额等)
  final RxList<ExtraPurchaseModel> extraPurchases = <ExtraPurchaseModel>[].obs;

  /// 购买席位的时长列表
  final RxList<BuySeatPackageEntityList> buySeatPackageList = <BuySeatPackageEntityList>[].obs;

  /// 选择的购买席位时长id
  final RxInt selectBuySeatPackageId = (-1).obs;

  /// 总金额
  final RxInt payTotalPrice = 0.obs;

  /// 选择的优惠券id
  final RxList<int> selectCouponIds = <int>[].obs;

  /// 续费-选择学员的席位index
  final RxList<int> selectTraineeIndexes = <int>[].obs;

  /// 是否同意会员服务协议
  final RxBool agreementProtocol = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      servicePackageId = Get.arguments["servicePackageId"];
      servicePackageVersion = Get.arguments["servicePackageVersion"];
      isBuySeat = Get.arguments["isBuySeat"] ?? false;
      traineeId = Get.arguments["traineeId"];
      isCompletionPrice = Get.arguments["isCompletionPrice"] ?? false;

      if (isBuySeat) {
        getBuySeatPackageList();
      } else {
        getPackageDetail();
      }
    }
  }

  /// 购买席位获取时长列表
  Future<void> getBuySeatPackageList() async {
    try {
      ToastUtils.showLoading();
      BuySeatPackageEntity? buySeatPackageEntity = await PayRequest.getBuySeatPackageList();
      if (buySeatPackageEntity == null) return;
      List<BuySeatPackageEntityList?>? list = buySeatPackageEntity.list;
      if (list == null || list.isEmpty) return;
      buySeatPackageList.clear();
      for (BuySeatPackageEntityList? item in list) {
        if (item == null) continue;
        buySeatPackageList.add(item);
      }
      if (buySeatPackageList.isEmpty) return;
      servicePackageId = buySeatPackageList.first.uid;
      servicePackageVersion = buySeatPackageList.first.version;
      selectBuySeatPackageId.value = buySeatPackageList.first.uid ?? (-1);
      await getPackageDetail(showLoading: false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getPackageDetail({bool defaultCoupon = true, bool showLoading = true}) async {
    if (servicePackageId == null || servicePackageVersion == null) return;
    Map<String, dynamic> reqData = {
      "servicePackageId": servicePackageId,
      "servicePackageVersion": servicePackageVersion,
      "couponIds": selectCouponIds.toList(),
      "defaultCoupon": defaultCoupon,
    };
    if (traineeId != null) {
      reqData['traineeId'] = traineeId;
    }
    if (showLoading) ToastUtils.showLoading();
    PackageShopDetailEntity? packageShopDetailEntity = await PayRequest.getPackageShopDetail(reqData);
    if (showLoading) ToastUtils.hideLoading();
    if (packageShopDetailEntity == null) return;
    packageShopDetail.value = packageShopDetailEntity;

    if (packageShopDetailEntity.servicePackage != null) {
      servicePackage.value = packageShopDetailEntity.servicePackage!;
    }

    List<PackageShopDetailEntityServicePackageCouponEffects?> couponEffectsList = packageShopDetailEntity.servicePackage?.couponEffects ?? [];
    couponEffects.clear();
    for (PackageShopDetailEntityServicePackageCouponEffects? item in couponEffectsList) {
      if (item == null) continue;
      couponEffects.add(item);
    }

    List<PackageShopDetailEntityCoupons?> coupons = packageShopDetailEntity.coupons ?? [];
    couponList.clear();
    for (PackageShopDetailEntityCoupons? item in coupons) {
      if (item == null) continue;
      if (item.couponId == null) continue;
      couponList.add(item);

      for (PackageShopDetailEntityServicePackageCouponEffects? couponEffectsItem in couponEffectsList) {
        if (couponEffectsItem == null) continue;
        if (couponEffectsItem.couponId == null) continue;
        if (couponEffectsItem.couponId == item.couponId && !selectCouponIds.contains(couponEffectsItem.couponId!)) {
          selectCouponIds.add(item.couponId!);
        }
      }
    }

    List<PackageShopDetailEntityServicePackageRights?> servicePackageRights = packageShopDetailEntity.servicePackageRights ?? [];

    for (PackageShopDetailEntityServicePackageRights? item in servicePackageRights) {
      if (item == null) continue;
      if (item.rightsId == null) continue;
      int quantity = item.quantity ?? 0;
      int price = isBuySeat ? packageShopDetailEntity.orderCredit ?? 0 : item.servicePackage?.price ?? 0;
      int priceOriginal = isBuySeat ? packageShopDetailEntity.orderCredit ?? 0 : item.servicePackage?.priceOriginal ?? 0;

      if (isBuySeat) {
        packageShopDetailEntity.orderCredit = 0;
        packageShopDetailEntity.orderOriginCredit = 0;
      }

      int freeQuantity = isBuySeat ? 0 : 1;

      int hIndex = -1;
      for (int i = 0; i < extraPurchases.length; i++) {
        if (extraPurchases[i].rightsId == item.rightsId) {
          hIndex = i;
          break;
        }
      }
      if (hIndex != -1) {
        //说明已经存在 只重新计算价格
        int buyQuantity = extraPurchases[hIndex].buyQuantity.value;
        int resultOriginal = priceOriginal * buyQuantity;
        extraPurchases[hIndex].priceOriginal = priceOriginal;
        // extraPurchases[hIndex].totalPrice.value = price;
        extraPurchases[hIndex].totalPriceOriginal.value = resultOriginal;
        if (isBuySeat) {
          extraPurchases[hIndex].price = price;
          extraPurchases[hIndex].totalPrice.value = priceOriginal * buyQuantity;
          extraPurchases[hIndex].data = item;
        }
        extraPurchases.refresh();
      } else {
        int result = priceOriginal * quantity;

        int totalPrice = (quantity - freeQuantity) * price;

        extraPurchases.add(ExtraPurchaseModel(
          rightsId: item.rightsId!,
          buyQuantity: quantity.obs,
          // freeQuantity: quantity,
          freeQuantity: freeQuantity,
          price: price,
          priceOriginal: priceOriginal,
          totalPrice: totalPrice.obs,
          totalPriceOriginal: result.obs,
          data: item,
        ));

        if(servicePackage.value.isVipRenewal){
          int quantity = item.quantity ?? 1;
          List<PackageShopDetailEntityServicePackageSubExtendTrainees?> trainees = item.subExtend?.trainees??[];
          if(quantity > trainees.length) quantity = trainees.length;
          for(int i = 0; i < quantity; i++){
            selectTraineeIndexes.add(i);
          }
        }

      }
    }

    calculateTotalPrice();
  }

  void addStudentCount(int index, {bool isIfMax = true}) {
    int have = UserStore.to.userInfo.value.studentCount ?? 0;
    if(!isIfMax) have = 0;
    int max = (UserStore.to.userInfo.value.maxTraineeSize ?? 0) - have;
    if (extraPurchases[index].buyQuantity.value >= max) {
      return;
    }
    extraPurchases[index].buyQuantity.value++;
    int buyQuantity = extraPurchases[index].buyQuantity.value - extraPurchases[index].freeQuantity;
    int price = extraPurchases[index].price;
    int priceOriginal = extraPurchases[index].priceOriginal;
    extraPurchases[index].totalPrice.value = price * buyQuantity;
    int result = priceOriginal * (buyQuantity + extraPurchases[index].freeQuantity);
    extraPurchases[index].totalPriceOriginal.value = result;
    calculateTotalPrice();
  }

  void reduceStudentCount(int index) {
    if (extraPurchases[index].buyQuantity.value > 1) {
      extraPurchases[index].buyQuantity.value--;
      int buyQuantity = extraPurchases[index].buyQuantity.value - extraPurchases[index].freeQuantity;
      int price = extraPurchases[index].price;
      int priceOriginal = extraPurchases[index].priceOriginal;
      extraPurchases[index].totalPrice.value = price * buyQuantity;

      int result = priceOriginal * (buyQuantity + extraPurchases[index].freeQuantity);
      extraPurchases[index].totalPriceOriginal.value = result;
    }

    calculateTotalPrice();
  }

  /// 计算总金额和节省金额
  void calculateTotalPrice() {
    // 计算额外购买
    int extraPrice = 0;
    for (ExtraPurchaseModel item in extraPurchases) {
      extraPrice += item.totalPrice.value;
    }

    int orderCredit = packageShopDetail.value.orderCredit ?? 0; //实际支付金额

    payTotalPrice.value = extraPrice + orderCredit;
  }

  /// 选择购买时长
  void selectBuySeatPackage(BuySeatPackageEntityList? data) {
    if (data == null) return;
    if (data.uid == null) return;
    servicePackageId = data.uid;
    servicePackageVersion = data.version;
    selectBuySeatPackageId.value = data.uid ?? (-1);
    getPackageDetail(defaultCoupon: selectCouponIds.isNotEmpty);
  }

  /// 选择优惠券
  Future<void> selectCoupon(int couponId) async {
    if (selectCouponIds.contains(couponId)) {
      selectCouponIds.remove(couponId);
    } else {
      selectCouponIds.clear();
      selectCouponIds.add(couponId);
    }
    getPackageDetail(defaultCoupon: selectCouponIds.isNotEmpty);
  }

  /// 续费 - 选择学员
  void selectTrainee(int traineeId, int packIndex, int index) {
    if (selectTraineeIndexes.contains(index)) {
      if(selectTraineeIndexes.length <= 1) return ToastUtils.showToast(text: "至少选择一个学员");
      selectTraineeIndexes.remove(index);
      reduceStudentCount(packIndex);
    } else {
      selectTraineeIndexes.add(index);
      addStudentCount(packIndex, isIfMax: false);
    }

  }

  /// 跳转至会员服务协议
  void toMemberProtocol() {
    WebViewUtils.openWebView(url: Config.memberProtocol);
  }

  /// 去充值乃币
  Future<void> toRecharge(BuildContext context, {bool isContinue = false}) async {
    dynamic result = await TagRoutes.toNamed(
      Routes.RECHARGE_NAIBI,
      arguments: {
        "pageType": 1,
      },
    );
    if (result == null) return;
    if (result != true) return;
    

    ToastUtils.showToast(text: "充值乃币成功", type: ToastType.success);
    if (!isContinue) return;

    // 再次判断余额是否充足
    int credit = UserStore.to.userInfo.value.credit??0;
    if (payTotalPrice.value > credit) {
      return ToastUtils.showToast(text: "余额不足，请充值");
    }

    settlement(context);
  }

  /// 结算
  Future<void> settlement(BuildContext context) async {
    if(servicePackage.value.isVipRenewal){
      if(selectTraineeIndexes.isEmpty){
        return ToastUtils.showToast(text: "请选择学员");
      }
    }

    if (!agreementProtocol.value) {
      return ToastUtils.showToast(text: "请先阅读并同意《会员服务协议》");
    }

    MemberLevelColor memberColors = StatusUtils.getMemberColorsByVipConfigs(UserStore.to.userInfo.value.vipConfigs, servicePackage.value.title);
    String? durationEnd = DateFormatUtil.formatStrtoStr(servicePackage.value.durationEnd);
    bool ask = await ConfirmMemberOrderDialog.show(
      context: context,
      valueTextColor: !isBuySeat ? memberColors.pale : AppTheme.cTextPrimary.color,
      kindReminder: isBuySeat ? null : "赠送学点将稍后到账，请留意查收。",
      datas: [
        ConfirmMemberOrderModel(name: "会员等级", value: servicePackage.value.title),
        ...List.generate(extraPurchases.length, (index) {
          return ConfirmMemberOrderModel(
            name: extraPurchases[index].data.title ?? "",
            value: extraPurchases[index].buyQuantity.string,
          );
        }),
        ...List.generate(couponEffects.length, (index) {
          return ConfirmMemberOrderModel(name: "已使用优惠券", value: couponEffects[index].title);
        }),
        ConfirmMemberOrderModel(name: couponEffects.isEmpty ? "有效期" : "用券之后有效期", value: durationEnd),
        ConfirmMemberOrderModel(name: "共计需要支付", value: "${NumberUtils.formatNumberWithCommas(payTotalPrice.value / 100)}乃币"),
      ],
    );
    if (!ask) return;

    List<Map<String, dynamic>> rights = [];
    for (int i = 0; i < extraPurchases.length; i++) {
      if(servicePackage.value.isVipRenewal){

        List<int> traineeIds = [];
        for (int index in selectTraineeIndexes) {
          traineeIds.add(extraPurchases[i].data.subExtend?.trainees?[index]?.traineeId??0);
        }

        rights.add({
          "quantity": extraPurchases[i].data.quantity??1,
          "rightsId": extraPurchases[i].data.rightsId,
          "resource": {
            "type": extraPurchases[i].data.subType,
            "uids": traineeIds,
          },
        });
      }else{
        rights.add({
          "quantity": extraPurchases[i].buyQuantity.value,
          "rightsId": extraPurchases[i].data.rightsId,
          "servicePackageId": servicePackageId,
        });
      }
      
    }

    Map<String, dynamic> reqData = {
      "servicePkgId": servicePackageId,
      "serviceVersion": servicePackageVersion,
      "payChannel": packageShopDetail.value.servicePackage?.payMethod?.toLowerCase(),
      "couponIds": selectCouponIds.toList(),
      "rights": rights,
    };
    if (traineeId != null) {
      reqData["traineeId"] = traineeId;
    }

    try {
      ToastUtils.showLoading();
      bool result = await PayRequest.buyMemberSettlement(reqData);
      if (!result) return;

      final memberCenterControllers = TagRoutes.finds<MemberCenterController>(Routes.MEMBER_CENTER);
      for (final c in memberCenterControllers) {
        await c.getMemberPackageList();
      }
      if (Get.isRegistered<ApplicationController>(tag: Routes.APPLICATION)) {
        await Get.find<ApplicationController>(tag: Routes.APPLICATION).refreshHomePages();
      }
      final userCenterControllers = TagRoutes.finds<UserCenterController>(Routes.USER_CENTER);
      for (final c in userCenterControllers) {
        await c.getUserTeam();
      }
      await UserStore.to.getUserInfo();
      ToastUtils.showToast(text: "购买成功", type: ToastType.success);
      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }
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

class ExtraPurchaseModel {
  // id 这里用作唯一标识
  int rightsId;

  /// 购买数量
  final RxInt buyQuantity;

  /// 免费数量
  int freeQuantity;

  /// 单价
  int price;

  /// 原价
  int priceOriginal;

  /// 总金额
  final RxInt totalPrice;
  final RxInt totalPriceOriginal;
  PackageShopDetailEntityServicePackageRights data;

  ExtraPurchaseModel({
    required this.rightsId,
    required this.buyQuantity,
    required this.freeQuantity,
    required this.price,
    required this.priceOriginal,
    required this.totalPrice,
    required this.totalPriceOriginal,
    required this.data,
  });
}
