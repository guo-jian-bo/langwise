


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/config.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';
import 'guide_engine/guide_engine.dart';
import 'widgets.dart';

/// 客服二维码弹窗
class CustomerServiceDialog{

  static Future<void> reportCustomer(BuildContext context) async{
    try {
      ToastUtils.showLoading();
      CustomerInfoEntity? customerInfoEntity = await UserRequest.getCustomerInfo();
      if(customerInfoEntity == null) return;
      if (!context.mounted) return;
      await show(
        context: context,
        customerInfo: customerInfoEntity,
      );
    } finally{
      ToastUtils.hideLoading();
    }
  }

  static Future<void> show({
    required BuildContext context,
    required CustomerInfoEntity customerInfo,
  }) async{
    await showCupertinoDialog(
      context: context, 
      builder: (context) {
        return QrCodeDialogWidget(
          customerInfo: customerInfo,
        );
      },
    );
  }

}


class QrCodeDialogWidget extends StatefulWidget {
  final CustomerInfoEntity customerInfo;
  const QrCodeDialogWidget({
    super.key,
    required this.customerInfo,
  });

  @override
  State<QrCodeDialogWidget> createState() => _QrCodeDialogWidgetState();
}

class _QrCodeDialogWidgetState extends State<QrCodeDialogWidget> {

  /// 拉起微信
  Future<void> _launchWechat() async{
    if(widget.customerInfo.customerUrl == null) return;
    bool isInstalled = await WxUtils.isWechatInstalled();
    if(!isInstalled) {
      ToastUtils.showToast(text: "请先安装微信");
      return;
    }

    // await WxUtils.openCustomerServiceUrl(widget.qrCodeContent);

    // checkBindWechat();

    // await WxUtils.openCustomerServiceUrl(widget.qrCodeContent);
    // await WxUtils.openCustomerServiceUrl("https://work.weixin.qq.com/kfid/kfce3f8a3ed4664b63b");

      // final schemeUrl = 'weixin://biz/ww/profile/${Uri.encodeComponent("https://work.weixin.qq.com/ca/cawcdee9be6a9dcec5")}';
      final schemeUrl = 'weixin://biz/ww/profile/${Uri.encodeComponent(widget.customerInfo.customerUrl ?? "")}'; 
      final uri = Uri.parse(schemeUrl); 
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// 点击按钮之前先绑定客服微信
  Future<void> checkBindWechat() async{
    if(widget.customerInfo.staffId == null) return;
    try {
      Map<String, dynamic> reqData = {
        "staffId": widget.customerInfo.staffId,
      };
      bool isRequest = await AccountUtil.bindCustomerWechat(data: reqData);
      if(isRequest) return;
    } catch (_) {}
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 1300.wMin,
              height: 820.wMin,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cSurfaceSecondary.color,
                border: Border.all(
                  color: AppTheme.cBorderSecondary.color,
                  width: 1.wMin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 700.wMin,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(32.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfoTitleWidget(),
                          SizedBox(height: 20.wMin),
                          _buildInfoListWidget(),
                          _buildInfoLeftDescWidget(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 1.wMin,
                    color: AppTheme.cBorderSecondary.color,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(32.wMin),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.4],
                          colors: [
                            AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1),
                            AppTheme.cSurfaceBrand.color.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
                        decoration: BoxDecoration(
                          color: AppTheme.cSurfacePrimary.color,
                          borderRadius: BorderRadius.circular(24.wMin),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildQrTitleWidget(),
                                      SizedBox(height: 16.wMin),
                                      _buildQrCodeWidget(),
                                      _buildQrSupportWidget(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.wMin),
                            _buildQrButtonWidget(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16.wMin,
              top: 16.wMin,
              child: TapScaleWidget(
                sclae: 1.05,
                onTap: () => Get.back(),
                child: Container(
                  width: 48.wMin,
                  height: 48.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceQuaternary.color,
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

  Widget _buildInfoTitleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_headset.svg",
              width: 48.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
            ),
            SizedBox(width: 10.wMin),
            Text(
              widget.customerInfo.title ?? "真人助教老师",
              style: TextStyle(
                fontSize: 32.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Text(
          widget.customerInfo.description ?? "有任何问题都可以免费联系助教老师。",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ],
    );
  }


  Widget _buildInfoListWidget(){
    List<CustomerInfoEntityItems?> items = widget.customerInfo.items??[];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16.wMin,
        crossAxisSpacing: 16.wMin,
        mainAxisExtent: 240.wMin,
      ),
      itemBuilder: (context, index) {
        return _buildInfoListItemWidget(items[index], index); 
      },
    );
  }

  Widget _buildInfoListItemWidget(CustomerInfoEntityItems? model, int index){
    if(model == null) return Container();
    return Container(
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTertiary.color,
        border: Border.all(
          color: AppTheme.cBorderSecondary.color,
          width: 1.wMin,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.wMin,
              height: 42.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.cBorderQuaternary.color,
                  width: 1.wMin,
                ),
              ),
              child: Text(
                (index + 1).padLeft(2, "0"),
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ),
            SizedBox(height: 10.wMin),
            Text(
              model.title??"",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            Text(
              model.description??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            
          ],
        ),
      ),
    );
  }


  Widget _buildInfoLeftDescWidget(){
    if(widget.customerInfo.tipTitle == null || widget.customerInfo.tipDescription == null) return Container();
    return Container(
      margin: EdgeInsets.only(top: 20.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTertiary.color,
        border: Border.all(
          color: AppTheme.cBorderSecondary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_qrcode.svg",
                width: 20.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
              SizedBox(width: 8.wMin),
              Expanded(
                child: Text(
                  widget.customerInfo.tipTitle ?? "",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          Text(
            widget.customerInfo.tipDescription ?? "",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildQrTitleWidget(){
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.cSurfaceTertiary.color,
            border: Border.all(
              color: AppTheme.cBorderSecondary.color,
              width: 1.wMin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wechat,
                size: 24.wMin,
                color: AppTheme.cTextPrimary.color,
              ),
              SizedBox(width: 6.wMin),
              Text(
                widget.customerInfo.customerLabel ?? "",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.wMin),
        Text(
          widget.customerInfo.customerTitle ?? "",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Text(
          widget.customerInfo.customerDescription ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeWidget(){
    return Container(
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cStaticWhite,
      ),
      child: QrImageView(
        data: widget.customerInfo.customerUrl ?? "",
        size: 240.wMin,
      ),
    );
  }

  Widget _buildQrSupportWidget(){
    List<CustomerInfoEntitySupportItems?> descriptionList = widget.customerInfo.supportItems??[];
    if(descriptionList.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      width: double.infinity,
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTertiary.color,
        border: Border.all(
          color: AppTheme.cBorderSecondary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.customerInfo.supportTitle ?? "支持范围",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(height: 4.wMin),
          GridView.builder(
            itemCount: descriptionList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6.wMin,
              crossAxisSpacing: 6.wMin,
              mainAxisExtent: 38.wMin,
            ),
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppTheme.cBorderSecondary.color,
                  border: Border.all(
                    color: AppTheme.cBorderPrimary.color,
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  descriptionList[index]?.title ?? "",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQrButtonWidget(){
    if (Config.wechatAppId.isEmpty) return Container();
    if (Config.wechatCorpId.isEmpty) return Container();
    if (widget.customerInfo.customerUrl == null) return Container();
    
    return Column(
      children: [

        TapScaleWidget(
          onTap: (){
            _launchWechat();
          },
          sclae: 1.01,
          child: Container(
            width: double.infinity,
            height: 70.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.cSurfaceBrand.color.withValues(alpha: 0.8),
                  AppTheme.cSurfaceBrand.color,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wechat,
                  size: 32.wMin,
                  color: Colors.white,
                ),
                SizedBox(width: 8.wMin),
                Text(
                  widget.customerInfo.contactButtonText ?? "联系助教",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        Visibility(
          visible: widget.customerInfo.contactButtonDescription != null,
          child: Container(
            margin: EdgeInsets.only(top: 10.wMin),
            child: Text(
              widget.customerInfo.contactButtonDescription ?? "",
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ),

      ],
    );
  }

}

class CustomerServiceButtonWidget extends StatefulWidget {
  final String pageCode;
  final String widgetId;
  /// 客服按钮
  const CustomerServiceButtonWidget({super.key, required this.widgetId, required this.pageCode});

  @override
  State<CustomerServiceButtonWidget> createState() => _CustomerServiceButtonWidgetState();
}

class _CustomerServiceButtonWidgetState extends State<CustomerServiceButtonWidget> {

  bool flag = false;

  /// 显示客服弹窗
  Future<void> showCustomerServiceDialog(BuildContext context) async{
    if (flag) return;
    flag = true;
    await CustomerServiceDialog.reportCustomer(context);
    flag = false;
    GuideTaskController.to.continueGuide(widget.pageCode, widget.widgetId);
  }

  @override
  Widget build(BuildContext context) {
    return GuideStepWidget(
      id: widget.widgetId,
      onTap: () async{
        showCustomerServiceDialog(context);
      },
      sclae: 1.02,
      child: Container(
        width: 108.wMin,
        height: 108.wMin,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.wMin),
          color: AppTheme.cBgSolid.color,
        ),
        child: PlatformBackdropFilterWidget(
          sigmaX: 8,
          sigmaY: 8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.wMin),
              color: AppTheme.cStaticBlack.color.withValues(alpha: 0.05),
              border: Border.all(
                width: 1.wMin,
                color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SvgPicture.asset(
                  "assets/svg/public/icon_headset.svg",
                  width: 40.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
                Text(
                  "助教老师",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
