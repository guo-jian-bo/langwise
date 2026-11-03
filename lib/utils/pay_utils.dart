import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:langwise/config.dart';
import 'package:tobias/tobias.dart';

import '../app/modules/user_center/common/pay_qrcode_dialog.dart';
import '../common/entities/entities.dart';
import '../common/https/pay.dart';
import '../common/stores/stores.dart';
import 'toast_utils.dart';

class AppPayType {
  static const String aliApp = "aliApp";
  static const String aliWeb = "aliWeb";
  static const String aliQrcode = "aliQrcode";
  static const String applePay = "applePayV2";
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

  /// 支付 临时数据
  PayPreOrderEntity? _tempPendingPayOrder;

  /// 订单状态轮询总次数 20次 一共1分钟
  static const int maxQueryCount = 20;

  /// 订单轮询次数
  int queryCount = maxQueryCount;

  Timer? queryTimer;

  /// 支付结果监听
  Stream<bool> get payResultController => _payResultController.stream;

  /// 支付结果监听
  final StreamController<bool> _payResultController = StreamController<bool>.broadcast();

  /// 当前支付流程的 loading 是否处于显示状态，用于避免重复显示或误关闭。
  bool _isPaymentLoadingVisible = false;

  /// 当前是否处于支付结果轮询阶段，用于区分“发起支付”和“查单确认”两类 loading 生命周期。
  bool _isQueryingOrderStatus = false;

  /// 显示当前支付流程专用 loading。
  void _showPaymentLoading({String? text}) {
    if (_isPaymentLoadingVisible) {
      ToastUtils.hideLoading();
    }
    ToastUtils.showLoading(text: text);
    _isPaymentLoadingVisible = true;
  }

  /// 隐藏当前支付流程专用 loading。
  void _hidePaymentLoading() {
    if (!_isPaymentLoadingVisible) return;
    ToastUtils.hideLoading();
    _isPaymentLoadingVisible = false;
  }

  /// 结束订单轮询，并重置轮询相关状态。
  void _stopQueryTimer({bool hideLoading = true}) {
    queryTimer?.cancel();
    queryTimer = null;
    queryCount = maxQueryCount;
    _isQueryingOrderStatus = false;
    if (hideLoading) {
      _hidePaymentLoading();
    }
  }

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
          // 轮询查询服务端订单状态
          _startQueryTimer(purchaseDetails: purchaseDetails);
          break;
        case PurchaseStatus.error: // 处理错误
          _stopQueryTimer();
          ToastUtils.showToast(text: purchaseDetails.error?.message ?? "支付失败");
          break;
        case PurchaseStatus.canceled: // 用户取消购买
          _stopQueryTimer();
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        // 完成交易
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// 调起支付宝支付
  Future<void> callAlipay(
      BuildContext context, ProductInfoEntityList data) async {
    // _payResultController.add(true);
    // return;
    bool shouldHideLoading = true;
    try {
      _showPaymentLoading();
      String payType = AppPayType.aliQrcode;
      bool isInstalled = false;
      if (Platform.isIOS || Platform.isAndroid) {
        isInstalled = await tobias.isAliPayInstalled;
        if (isInstalled) {
          // 安装了支付宝
          payType = AppPayType.aliApp;
        }
      }

      _tempPendingPayOrder = await getPayPreOrder(payType, data);
      if (_tempPendingPayOrder == null) {
        ToastUtils.showToast(text: "获取支付订单失败");
        return;
      }

      String? prepayId = _tempPendingPayOrder?.payParams?.prepayId;
      if (prepayId == null) {
        ToastUtils.showToast(text: "支付参数获取失败");
        return;
      }

      if (!isInstalled) {
        if (_tempPendingPayOrder?.totalFee == null) return;
        if (_tempPendingPayOrder?.payParams?.orderNo == null) return;
        _hidePaymentLoading();
        bool qrCodePayRes = await PayQrcodeDialog.show(
          context: Get.context ?? context,
          payType: payType,
          amount: _tempPendingPayOrder?.totalFee ?? 0,
          qrUrl: _tempPendingPayOrder!.payParams!.prepayId!,
          orderNo: _tempPendingPayOrder!.payParams!.orderNo!,
        );
        if (!qrCodePayRes) return;
        _payResultController.add(true);
        await UserStore.to.getUserInfo();
        return;
      }
      print("服务端：$prepayId");

      // iOS 先关闭 universal link 做最小验证，观察取消支付时是否仍会落到浏览器桥接页。
      final String? aliPayUniversalLink = Platform.isIOS ? null : "${Config.wechatUniversalLink}alipay/";

      // 即将切到外部支付 App，此时不保留本应用内 loading。
      _hidePaymentLoading();

      // 调起支付
      Map<dynamic, dynamic> result = await tobias.pay(
        prepayId,
        evn: AliPayEvn.online,
        universalLink: aliPayUniversalLink,
      );

      print('\n📋 支付结果: $result');

      // 处理支付结果
      String resultStatus = result['resultStatus']?.toString() ?? '';
      String memo = result['memo']?.toString() ?? '';

      if (resultStatus == AliPayResCode.success) {
        // _payResultController.add(true);
        // ToastUtils.showToast(text: "支付成功", type: ToastType.success);
        // await UserStore.to.getUserInfo();
        shouldHideLoading = false;
        _startQueryTimer();
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
      if (shouldHideLoading) {
        _hidePaymentLoading();
      }
    }
  }

  /// 会员卡管理模块调起支付宝支付
  Future<bool> callAlipayWithQrcode(
      BuildContext context, ProductInfoEntityList data) async {
    try {
      _showPaymentLoading();
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
      _hidePaymentLoading();
      bool qrCodePayRes = await PayQrcodeDialog.show(
        context: Get.context ?? context,
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
      _hidePaymentLoading();
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
    _stopQueryTimer();
    _applyPaySubscription?.cancel();
    _tempPendingPayOrder = null;
    _instance = null;
  }

  /// 恢复苹果支付
  Future<void> callApplyPayRestore() async {
    if (!Platform.isIOS) return;
    await _inAppPurchase.restorePurchases();
  }

  /// 调起苹果支付
  Future<void> callApplyPay(BuildContext context, ProductInfoEntityList data) async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        ToastUtils.showToast(text: "当前设备不支持支付");
        return;
      }

      _showPaymentLoading(text: "正在支付，请不要进行其他操作！");
      // await _inAppPurchase.restorePurchases();
      if (data.servicePackageId == null || data.price == null) {
        _hidePaymentLoading();
        ToastUtils.showToast(text: "参数错误");
        return;
      }

      // 获取服务端预支付订单
      _tempPendingPayOrder = await getPayPreOrder(AppPayType.applePay, data);

      String? productId = _tempPendingPayOrder?.payParams?.productId;
      if (_tempPendingPayOrder == null || productId == null || _tempPendingPayOrder?.sign == null || _tempPendingPayOrder?.orderNo == null) {
        _hidePaymentLoading();
        ToastUtils.showToast(text: "获取支付订单失败");
        return;
      }

      /// 获取苹果支付商品信息
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        _hidePaymentLoading();
        ToastUtils.showToast(text: "未找到商品信息");
        return;
      }

      final ProductDetails product = response.productDetails.first;

      // 发起购买
      await _inAppPurchase.buyConsumable(purchaseParam: PurchaseParam(
        productDetails: product,
        applicationUserName: _tempPendingPayOrder?.payParams?.appAccountToken,
      ));
    } catch (e) {
      print(e);
      _hidePaymentLoading();
      ToastUtils.showToast(text: "支付失败");
    }
  }

  void _startQueryTimer({PurchaseDetails? purchaseDetails}) {
    if (_tempPendingPayOrder == null) return;
    _stopQueryTimer(hideLoading: false);
    _isQueryingOrderStatus = true;
    _showPaymentLoading(text: "支付结果确认中...");
    queryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      queryCount--;
      if (queryCount <= 0) {
        timer.cancel();
        ToastUtils.showToast(text: "支付超时");
        _stopQueryTimer();
        return;
      }
      _queryOrderStatus(purchaseDetails: purchaseDetails);
    });
  }

  /// 轮询查询订单状态
  Future<void> _queryOrderStatus({PurchaseDetails? purchaseDetails}) async {
    try {
      if (_tempPendingPayOrder == null) {
        _stopQueryTimer();
        return;
      }
      Map<String, dynamic> parameters = {
        "orderNo": _tempPendingPayOrder?.orderNo!,
      };
      PayRespEntity? res = await PayRequest.getPayOrderStatus(parameters, showToast: false);
      if (res == null || !res.isSuccess) return;
      if (_tempPendingPayOrder?.payChannel == AppPayType.applePay && purchaseDetails != null) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }

      _stopQueryTimer();
      ToastUtils.showToast(text: "支付成功", type: ToastType.success);
      _payResultController.add(true);
      _tempPendingPayOrder = null;
      await UserStore.to.getUserInfo();
    } catch (_) {
      if (!_isQueryingOrderStatus) {
        _hidePaymentLoading();
      }
    }
  }
}
