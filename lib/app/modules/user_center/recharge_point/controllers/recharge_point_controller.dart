import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/stores/stores.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../../routes/tag_routes.dart';

class RechargePointController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  RechargePointController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.RECHARGE_POINT;

  @override
  String get breadcrumbTitle => "充值学点";

  final Rx<ProductPointsEntity> productInfo = ProductPointsEntity().obs;
  final RxList<ProductPointsEntityList> productInfoList = <ProductPointsEntityList>[].obs;
  final RxList<ProductPointsEntityDescribes> describeList = <ProductPointsEntityDescribes>[].obs;
  
  final RxInt selectedProductIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    getProductPoints();
  }


  Future<void> getProductPoints() async{
    try {
      ToastUtils.showLoading();
      ProductPointsEntity? productPointsEntity = await PayRequest.getPackageShopList();
      if(productPointsEntity == null) return;
      productInfo.value = productPointsEntity;
      List<ProductPointsEntityList?> productList = productPointsEntity.list??[];
      for(ProductPointsEntityList? item in productList){
        if(item == null) continue;
        productInfoList.add(item);
      }

      List<ProductPointsEntityDescribes?> describes = productPointsEntity.describes??[];
      for(ProductPointsEntityDescribes? item in describes){
        if(item == null) continue;
        describeList.add(item);
      }
    } finally{
      ToastUtils.hideLoading();
    }

  }


  /// 跳转至充值乃币页面
  Future<void> toRechargeNaibi() async{
    await TagRoutes.toNamed(
      Routes.RECHARGE_NAIBI,
      arguments: {
        "pageType": 1,
      },
    );
  }

  Future<void> pay(BuildContext context) async{
    if(selectedProductIndex.value == -1){
      return ToastUtils.showToast(text: "请选择充值数量");
    }
    ProductPointsEntityList product = productInfoList[selectedProductIndex.value];
    
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "您确定要花费${NumberUtils.formatNumberWithCommas((product.price??0) / 100)}乃币兑换此商品吗？",
    );
    if(!askRes) return;

    Map<String, dynamic> reqData = {
      "servicePkgId": product.servicePackageId,
      "serviceVersion": product.version,
      "payChannel": product.payMethod?.toLowerCase(),
    };
     try {
      ToastUtils.showLoading();
      bool result = await PayRequest.buyMemberSettlement(reqData);
      if(!result) return;
    
      await UserStore.to.getUserInfo();
      await Future.delayed(const Duration(seconds: 2));
      ToastUtils.showToast(text: "购买成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
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

class PayHttp {
}
