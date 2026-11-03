


import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/values/values.dart';
import '../../../../../config.dart';
import '../../common/exchange_coupons_dialog.dart';

class RechargeNaibiController extends GetxController {

  /// 页面type 支付完成之后 0=不做操作 1=返回上层页面 2=替换当前页面跳转至会员列表页面
  int pageType = 0;

  final RxList<ProductInfoEntityList> productList = <ProductInfoEntityList>[].obs;
  final Rx<ProductInfoEntity> productInfo = ProductInfoEntity().obs;
  final RxList<ProductInfoEntityDescribes> describeList = <ProductInfoEntityDescribes>[].obs;

  /// 选中的商品索引
  final RxInt selectedProductIndex = (-1).obs;

  /// 是否同意协议
  final RxBool isChecked = false.obs;

  final PayUtils payUtils = PayUtils.instance;

  /// 支付结果监听
  StreamSubscription<bool>? _payResultSubscription;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      pageType = Get.arguments['pageType'] ?? 0;
    }
    getProductList();
    listenPayResult();
  }

  /// 监听支付结果
  void listenPayResult(){
    _payResultSubscription = payUtils.payResultController.listen((event) {
      if(event){
        if(pageType == 1){
          Get.back(result: true);
        } else if(pageType == 2){
          Get.offAndToNamed(Routes.MEMBER_CENTER);
        }
      }
    });
  }
  

  /// 获取商品列表
  Future<void> getProductList() async {
    try {
      ToastUtils.showLoading();
      ProductInfoEntity? res = await PayRequest.getProductList();
      if(res == null) return;
      productInfo.value = res;
      List<ProductInfoEntityList?> list = res.list??[];
      productList.clear();
      describeList.clear();
      for(var item in list){
        if(item == null) continue;
        productList.add(item);
      }
      List<ProductInfoEntityDescribes?> descList = res.describes??[];
      for(var item in descList){
        if(item == null) continue;
        describeList.add(item);
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 兑换乃币卡
  Future<void> getExchangeCard(BuildContext context) async {
    bool resCode = await ExchangeCouponsDialog.show(context: context);
    if(!resCode) return;
    if(pageType == 1){
      Get.back(result: true);
    } else if(pageType == 2){
      Get.offAndToNamed(Routes.MEMBER_CENTER);
    }

  }

  /// 唤起支付
  /// type 1: 支付宝 2: 微信支付 3: 苹果支付
  Future<void> callPay(BuildContext context, int type) async{
    if(selectedProductIndex.value == -1) {
      ToastUtils.showToast(text: "请先选择充值金额");
      return;
    }
    // if(!isChecked.value){
    //   ToastUtils.showToast(text: "请先阅读并同意协议");
    //   return;
    // }

    ProductInfoEntityList data = productList[selectedProductIndex.value];

    if(type == 1){
      payUtils.callAlipay(context, data);
    } else if(type == 2){
      // callWxPay(context);
    } else if(type == 3){
      bool res = await checkIAPPendingPurchases();
      if(!res) return;
      payUtils.callApplyPay(context, data);
    }
  }


  /// 跳转至会员协议
  Future<void> jumpToMemberProtocol() async {
    await WebViewUtils.openWebView(url: Config.memberProtocol);
  }

  Future<bool> checkIAPPendingPurchases() async {
    String json = StorageUtil().getString(STORAGE_IAP_PENDING_PURCHASES_KEY);
    if(json.isEmpty) return true;
    Map<String, dynamic> map = jsonDecode(json);
    String sign = map["sign"]??"";
    String orderNo = map["orderNo"]??"";
    String receipt = map["receipt"]??"";
    if(sign.isEmpty || orderNo.isEmpty || receipt.isEmpty) return true;

    bool res = await AskDialog.showUserAsk(
      context: Get.context!,
      title: "温馨提示",
      content: "您有一个未验证的订单, $orderNo",
      define: "继续支付",
    );
    if(!res) return false;
    // payUtils.callApplyPayRestore();
    return true;
  }



  @override
  void onReady() {
    super.onReady();
  }


  @override
  void onClose() {
    payUtils.dispose();
    _payResultSubscription?.cancel();
    super.onClose();
  }
}



