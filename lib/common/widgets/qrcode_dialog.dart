
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/theme/theme.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';
import 'widgets.dart';

/// 客服二维码弹窗
class QrCodeDialog{

  static Future<void> reportCustomer(BuildContext context) async{
    try {
      ToastUtils.showLoading();
      CustomerInfoEntity? customerInfoEntity = await UserRequest.getCustomerInfo();
      if(customerInfoEntity == null) return;
      await show(
        context: context,
        qrCodeContent: customerInfoEntity.customerUrl ?? "",
        title: customerInfoEntity.title,
        name: customerInfoEntity.message,
      );
    } finally{
      ToastUtils.hideLoading();
    }
  }

  static Future<void> show({
    required BuildContext context,
    required String qrCodeContent,
    String? title,
    String? name,
  }) async{
    await showCupertinoDialog(
      context: context, 
      builder: (context) {
        return QrCodeDialogWidget(
          qrCodeContent: qrCodeContent,
          title: title,
          name: name,
        );
      },
    );
  }

}


class QrCodeDialogWidget extends StatefulWidget {
  final String qrCodeContent;
  final String? title;
  final String? name;
  const QrCodeDialogWidget({
    super.key,
    required this.qrCodeContent,
    this.title,
    this.name,
  });

  @override
  State<QrCodeDialogWidget> createState() => _QrCodeDialogWidgetState();
}

class _QrCodeDialogWidgetState extends State<QrCodeDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 464.wMin,
              padding: EdgeInsets.all(32.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cSurfaceSecondary.color,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: widget.title != null,
                    child: Text(
                      widget.title ?? "",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      color: AppTheme.cStaticWhite,
                    ),
                    child: QrImageView(
                      data: widget.qrCodeContent,
                      size: 213.wMin,
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                  Visibility(
                    visible: widget.name != null,
                    child: Text(
                      widget.name ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ),
            
                ],
              ),
            ),
            Positioned(
              right: 8.wMin,
              top: 8.wMin,
              child: TapScaleWidget(
                sclae: 1.05,
                onTap: () => Get.back(),
                child: Container(
                  width: 42.wMin,
                  height: 42.wMin,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceTertiary,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/x.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}