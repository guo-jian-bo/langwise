import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';

class PayQrcodeDialog{

  static Future<bool> show({
    required BuildContext context,
    required String payType,
    required int amount,
    required String qrUrl,
    required String orderNo,
  }) async {
    bool? res = await showCupertinoDialog(
      context: context, 
      builder: (BuildContext context){
        return PayQrcodeDialogWidget(payType: payType, amount: amount, qrUrl: qrUrl, orderNo: orderNo);
      },
    );
    return res ?? false;
  }

}

class PayQrcodeDialogWidget extends StatefulWidget {
  final String payType;
  final int amount;
  final String qrUrl;
  final String orderNo;

  const PayQrcodeDialogWidget({super.key, required this.payType, required this.amount, required this.qrUrl, required this.orderNo});

  @override
  State<PayQrcodeDialogWidget> createState() => _PayQrcodeDialogWidgetState();
}

class _PayQrcodeDialogWidgetState extends State<PayQrcodeDialogWidget> {

  int queryCount = 60 * 15;

  Timer? queryTimer;


  @override
  void initState() {
    super.initState();
    _startQueryTimer();
  }

  void _startQueryTimer() {
    queryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      queryCount--;
      if(queryCount <= 0){
        timer.cancel();
        ToastUtils.showToast(text: "支付超时");
        Get.back();
      }
      _queryOrderStatus();
    });
  }

  /// 轮询查询订单状态
  Future<void> _queryOrderStatus() async{
    Map<String, dynamic> parameters = {
      "orderNo": widget.orderNo,
    };
    PayRespEntity? res = await PayRequest.getPayOrderStatus(parameters, showToast: false);
    if(res == null) return;
    if(res.isSuccess){
      ToastUtils.showToast(text: "支付成功", type: ToastType.success);
      Get.back(result: true);
    }
  }

  @override
  void dispose() {
    queryTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    String typeStr = "微信";
    Color color = const Color(0xff22AC38);
    String titleSvg = "assets/svg/user_center/icon_wx_pay.svg";
    if(widget.payType == AppPayType.aliQrcode){
      titleSvg = "assets/svg/user_center/icon_ali_pay.svg";
      color = const Color(0xff3379F6);
      typeStr = "支付宝";
    }

    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.wMin),
              child: Container(
                width: 640.wMin,
                color: AppTheme.cStaticWhite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40.wMin),
                    SvgPicture.asset(
                      titleSvg,
                      height: 80.wMin,
                    ),
                    SizedBox(height: 24.wMin),
                    Text(
                      "支付金额",
                      style: TextStyle(
                        color: AppTheme.cStaticBlack,
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    Text(
                      NumberUtils.formatNumberWithCommas(widget.amount / 100),
                      style: TextStyle(
                        color: const Color(0xffF97316),
                        fontSize: 64.wMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 24.wMin),
                    Container(
                      height: 320.wMin,
                      width: 320.wMin,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24.wMin),
                        border: Border.all(
                          width: 1.wMin, 
                          color: const Color(0xffBDC2C8),
                        ),
                      ),
                      child: QrImageView(
                        data: widget.qrUrl,
                        padding: EdgeInsets.all(10.wMin),
                      ),
                    ),
                    SizedBox(height: 24.wMin),
                    Container(
                      width: double.infinity,
                      height: 126.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                      ),
                      child: Text(
                        "请使用$typeStr扫一扫\n扫描二维码支付",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.cStaticWhite,
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.wMin),
            TapScaleWidget(
              onTap: () => Get.back(),
              sclae: 1.05,
              child: SizedBox(
                width: 80.wMin,
                height: 80.wMin,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_close_circle.svg",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}