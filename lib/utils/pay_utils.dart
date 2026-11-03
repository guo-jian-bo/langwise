import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lib_common/common.dart';
import 'package:tobias/tobias.dart';

import '../app/modules/user_center/common/pay_qrcode_dialog.dart';
import '../common/entities/entities.dart';
import '../common/https/pay.dart';
import '../common/stores/stores.dart';
import '../common/values/values.dart';
import 'toast_utils.dart';

class AppPayType {
  static const String aliApp = "aliApp";
  static const String aliWeb = "aliWeb";
  static const String aliQrcode = "aliQrcode";
  static const String applePay = "applePay";
}

class AliPayResCode {
  static const String success = "9000";
  static const String loading = "8000";
  static const String fail = "4000";
  static const String repeat = "5000";
  static const String cancel = "6001";
  static const String userCancel = "6002";
  static const String networkError = "6003";
}

class PayUtils {
  factory PayUtils() => _getInstance();

  static PayUtils get instance => _getInstance();

  static PayUtils? _instance;

  static PayUtils _getInstance() {
    _instance ??= PayUtils._internal();
    return _instance!;
  }

  PayUtils._internal() {
    _initApplyPaySubscription();
  }

  final Tobias tobias = Tobias();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _applyPaySubscription;

  /// 苹果支付 临时数据
  PayPreOrderEntity? _tempPendingPayOrder;

  /// 支付结果监听
  Stream<bool> get payResultController => _payResultController.stream;
  /// 支付结果监听
  final StreamController<bool> _payResultController = StreamController<bool>.broadcast();

  Future<void> _initApplyPaySubscription() async {
    if (!Platform.isIOS) return;

    final bool available = await _inAppPurchase.isAvailable();
    if (!available) return;
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _applyPaySubscription = purchaseUpdated.listen((purchaseDetailsList) {
      print("创建支付监听");
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      print("取消支付监听");
      _applyPaySubscription?.cancel();
    }, onError: (err) {
      print("创建支付监听失败$err");
    });

    await _inAppPurchase.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    print("支付监听状态数据${purchaseDetailsList.length}");
    for (var purchaseDetails in purchaseDetailsList) {
      print("支付状态${purchaseDetails.status}");
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending: // 交易正在进行中
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored: // 验证收据并解锁功能
          _applyVerifyAndDeliverProduct(purchaseDetails);
          break;
        case PurchaseStatus.error: // 处理错误
          ToastUtils.hideLoading();
          ToastUtils.showToast(text: purchaseDetails.error?.message ?? "支付失败");
          break;
        case PurchaseStatus.canceled: // 用户取消购买
          ToastUtils.hideLoading();
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        // 完成交易
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// 调起支付宝支付
  Future<void> callAlipay(BuildContext context, ProductInfoEntityList data) async {
    // _payResultController.add(true);
    // return;
    try {
      ToastUtils.showLoading();
      String payType = AppPayType.aliQrcode;
      bool isInstalled = false;
      if (Platform.isIOS || Platform.isAndroid) {
        isInstalled = await tobias.isAliPayInstalled;
        if (isInstalled) {
          // 安装了支付宝
          payType = AppPayType.aliApp;
        }
      }

      PayPreOrderEntity? resOrder = await getPayPreOrder(payType, data);
      if (resOrder == null) {
        ToastUtils.showToast(text: "获取支付订单失败");
        return;
      }

      String? prepayId = resOrder.payParams?.prepayId;
      if (prepayId == null) {
        ToastUtils.showToast(text: "支付参数获取失败");
        return;
      }

      if (!isInstalled) {
        if (resOrder.totalFee == null) return;
        if (resOrder.payParams?.orderNo == null) return;
        bool qrCodePayRes = await PayQrcodeDialog.show(
          context: context,
          payType: payType,
          amount: resOrder.totalFee ?? 0,
          qrUrl: resOrder.payParams!.prepayId!,
          orderNo: resOrder.payParams!.orderNo!,
        );
        if (!qrCodePayRes) return;
        _payResultController.add(true);
        await UserStore.to.getUserInfo();
        return;
      }
      print("服务端：$prepayId");

      // 调起支付
      Map<dynamic, dynamic> result = await tobias.pay(
        prepayId,
        evn: AliPayEvn.online,
        universalLink: "https://timelywise.cn/alipay/",
      );

      print('\n📋 支付结果: $result');

      // 处理支付结果
      String resultStatus = result['resultStatus']?.toString() ?? '';
      String memo = result['memo']?.toString() ?? '';

      if (resultStatus == AliPayResCode.success) {
        _payResultController.add(true);
        ToastUtils.showToast(text: "支付成功", type: ToastType.success);
        await UserStore.to.getUserInfo();
      } else if (resultStatus == AliPayResCode.loading) {
        ToastUtils.showToast(text: "支付正在处理中");
      } else if (resultStatus == AliPayResCode.repeat) {
        ToastUtils.showToast(text: "重复请求");
      } else if (resultStatus == AliPayResCode.fail) {
        ToastUtils.showToast(text: "支付失败");
      } else if (resultStatus == AliPayResCode.cancel) {
        ToastUtils.showToast(text: "支付已取消");
      } else if (resultStatus == AliPayResCode.userCancel) {
        ToastUtils.showToast(text: "用户取消支付");
      } else if (resultStatus == AliPayResCode.networkError) {
        ToastUtils.showToast(text: "网络连接出错");
      } else {
        ToastUtils.showToast(text: "支付异常: $memo (状态码: $resultStatus)");
      }
    } catch (e) {
      ToastUtils.showToast(text: "支付异常: $e");
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 会员卡管理模块调起支付宝支付
  Future<bool> callAlipayWithQrcode(BuildContext context, ProductInfoEntityList data) async {
    try {
      ToastUtils.showLoading();
      String payType = AppPayType.aliQrcode;

      PayPreOrderEntity? resOrder = await getPayPreOrder(payType, data);
      if (resOrder == null) {
        ToastUtils.showToast(text: "获取支付订单失败");
        return false;
      }

      String? prepayId = resOrder.payParams?.prepayId;
      if (prepayId == null) {
        ToastUtils.showToast(text: "支付参数获取失败");
        return false;
      }

      if (resOrder.totalFee == null) return false;
      if (resOrder.payParams?.orderNo == null) return false;
      bool qrCodePayRes = await PayQrcodeDialog.show(
        context: context,
        payType: payType,
        amount: resOrder.totalFee ?? 0,
        qrUrl: resOrder.payParams!.prepayId!,
        orderNo: resOrder.payParams!.orderNo!,
      );
      if (!qrCodePayRes) return false;
      _payResultController.add(true);
      await UserStore.to.getUserInfo();
      return true;
    } catch (e) {
      ToastUtils.showToast(text: "支付异常: $e");
      return false;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 调起支付宝二维码支付
  Future<void> callAlipayQr(BuildContext context, PayPreOrderEntity resOrder) async {
    bool qrCodePayRes = await PayQrcodeDialog.show(
      context: context,
      payType: AppPayType.aliQrcode,
      amount: resOrder.totalFee ?? 0,
      qrUrl: resOrder.payParams!.prepayId!,
      orderNo: resOrder.payParams!.orderNo!,
    );
    if (!qrCodePayRes) return;
    _payResultController.add(true);
    await UserStore.to.getUserInfo();
  }

  /// 获取预支付订单
  Future<PayPreOrderEntity?> getPayPreOrder(String payType, ProductInfoEntityList data) async {
    Map<String, dynamic> reqData = {
      "servicePkgId": data.servicePackageId,
      "serviceVersion": data.version,
      "payChannel": payType,
    };

    PayPreOrderEntity? payPreOrderEntity = await PayRequest.getPayPreOrder(reqData);
    if (payPreOrderEntity == null) return null;
    return payPreOrderEntity;
  }

  void dispose() {
    _applyPaySubscription?.cancel();
    _tempPendingPayOrder = null;
    _instance = null;
  }

  /// 调起苹果支付
  Future<void> callApplyPay(BuildContext context, ProductInfoEntityList data) async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        ToastUtils.showToast(text: "当前设备不支持支付");
        return;
      }

      ToastUtils.showLoading(text: "正在支付，请不要进行其他操作！");
      await _inAppPurchase.restorePurchases();
      if (data.servicePackageId == null || data.price == null) {
        ToastUtils.hideLoading();
        ToastUtils.showToast(text: "参数错误");
        return;
      }

      // 获取服务端预支付订单
      _tempPendingPayOrder = await getPayPreOrder(AppPayType.applePay, data);

      String? productId = _tempPendingPayOrder?.payParams?.productId;
      if (_tempPendingPayOrder == null || productId == null || _tempPendingPayOrder?.sign == null || _tempPendingPayOrder?.orderNo == null) {
        ToastUtils.hideLoading();
        ToastUtils.showToast(text: "获取支付订单失败");
        return;
      }

      /// 获取苹果支付商品信息
      Set<String> _productIds = {productId};
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      if (response.productDetails.isEmpty) {
        ToastUtils.hideLoading();
        ToastUtils.showToast(text: "未找到商品信息");
        return;
      }

      final ProductDetails product = response.productDetails.first;

      // 发起购买
      await _inAppPurchase.buyConsumable(purchaseParam: PurchaseParam(productDetails: product));
    } catch (e) {
      print(e);
      ToastUtils.hideLoading();
      ToastUtils.showToast(text: "支付失败");
    }
  }

  /// 苹果支付恢复
  Future<void> callApplyPayRestore() async {
    if (!Platform.isIOS && !Platform.isMacOS) return;

    try {
      ToastUtils.showLoading();
      await _applyVerifyAndDeliverProductReq();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 验证并交付商品（使用增强的获取方法）
  Future<bool> _applyVerifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    try {
      // 1. 获取收据
      final String? receipt = await _getVerificationData(purchaseDetails);

      print(receipt);
      if (receipt == null) {
        throw Exception("无法获取收据");
      }
      // testAppleReceiptVerification(receipt);

      String? sign = _tempPendingPayOrder?.sign;
      String? orderNo = _tempPendingPayOrder?.orderNo;
      if (sign == null || orderNo == null) {
        throw Exception("参数错误");
      }

      Map<String, String> storage = {
        "sign": sign,
        "orderNo": orderNo,
        "receipt": receipt,
      };
      await StorageUtil().setString(STORAGE_IAP_PENDING_PURCHASES_KEY, jsonEncode(storage));

      bool isSuccess = await _applyVerifyAndDeliverProductReq();
      if (isSuccess) {
        _tempPendingPayOrder = null;
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
      return isSuccess;
    } catch (e) {
      ToastUtils.showToast(text: "验证失败");
      return false;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 验证并交付商品
  /// 获取验证数据
  Future<String?> _getVerificationData(PurchaseDetails purchaseDetails) async {
    var verificationData = purchaseDetails.verificationData;

    // iOS特殊处理：如果验证数据为空，尝试刷新
    if (Platform.isIOS && verificationData.serverVerificationData.isEmpty) {
      try {
        await _inAppPurchase.restorePurchases();
        verificationData = purchaseDetails.verificationData;
      } catch (e) {
        print('刷新验证数据失败: $e');
      }
    }

    // 检查数据有效性
    String receiptData = '';
    if (verificationData.serverVerificationData.isNotEmpty) {
      receiptData = verificationData.serverVerificationData;
    } else if (verificationData.localVerificationData.isNotEmpty) {
      receiptData = verificationData.localVerificationData;
    } else {
      print('警告：收据数据为空');
      return null;
    }

    // // 验证是否为有效的Base64格式
    // try {
    //   base64Decode(receiptData);
    //   print('收据数据格式验证通过');
    // } catch (e) {
    //   print('收据数据不是有效的Base64格式: $e');
    //   // 如果是JWT格式，需要特殊处理
    //   if (receiptData.contains('.')) {
    //     print('检测到JWT格式收据，可能需要使用StoreKit 2 API');
    //   }
    // }

    return receiptData;
  }

  /// 苹果支付验证接口
  Future<bool> _applyVerifyAndDeliverProductReq() async {
    // await StorageUtil().remove(STORAGE_IAP_PENDING_PURCHASES_KEY);

    String json = StorageUtil().getString(STORAGE_IAP_PENDING_PURCHASES_KEY);
    Map<String, dynamic> map = jsonDecode(json);
    String sign = map["sign"] ?? "";
    String orderNo = map["orderNo"] ?? "";
    String receipt = map["receipt"] ?? "";
    if (sign.isEmpty || orderNo.isEmpty || receipt.isEmpty) return false;

    Map<String, dynamic> reqData = {
      "receipt": receipt,
      "orderNo": orderNo,
      "sign": sign,
    };
    PayRespEntity? res = await PayRequest.verifyApplePay(reqData);
    if (res == null) return false;

    if (!res.isSuccess) {
      throw Exception("支付失败");
    }

    await StorageUtil().remove(STORAGE_IAP_PENDING_PURCHASES_KEY);
    // 3. 更新用户状态
    await UserStore.to.getUserInfo();
    // 4. 显示成功消息
    ToastUtils.showToast(text: "购买成功", type: ToastType.success);
    _payResultController.add(true);

    return true;
  }
}
