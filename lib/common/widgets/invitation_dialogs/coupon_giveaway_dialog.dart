import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../../https/https.dart';
import '../widgets.dart';
import 'invitation_method_enum.dart';


class CouponGiveawayDialog{

  /// 显示邀请方式弹窗
  static Future<bool> showMethodDialog({
    required BuildContext context,
    required CouponEntityDatas data,
  }) async{

    if(data.couponId == null) return false;
    CouponShareEntity? couponShareEntity;
    try {
      ToastUtils.showLoading();
      couponShareEntity = await AccountUtil.getCouponShareInfo(data.couponId!);
    } finally{
      ToastUtils.hideLoading();
    }
    if(couponShareEntity == null) return false;

    bool? result = await showCupertinoDialog<bool?>(
      context: Get.context ?? context,
      builder: (context) {
        return CouponGiveawayDialogWidget(
          couponData: data,
          couponShareData: couponShareEntity!,
        );
      },
    );

    return result??false;
  }

}

class CouponGiveawayDialogWidget extends StatefulWidget {
  /// 优惠券数据
  final CouponEntityDatas couponData;
  /// 分享数据
  final CouponShareEntity couponShareData;

  const CouponGiveawayDialogWidget({super.key, required this.couponData, required this.couponShareData});

  @override
  State<CouponGiveawayDialogWidget> createState() => _CouponGiveawayDialogWidgetState();
}

class _CouponGiveawayDialogWidgetState extends State<CouponGiveawayDialogWidget> {
  /// 选择的邀请方式
  InvitationMethodEnum? _selectedMethod;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground.color,
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: 720.wMin,
                padding: EdgeInsets.symmetric(vertical: 32.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.wMin),
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                  color: AppTheme.cSurfaceSecondary.color,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleWidget(),
                    
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.bottomCenter,
                      child: _buildBodyWidget(),
                    ),
              
                  ],
                ),
              ),
              Positioned(
                top: 20.wMin,
                right: 20.wMin,
                child: _buildColseWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.couponShareData.title??"",
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            widget.couponShareData.describe??"",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColseWidget(){
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () => Get.back(),
      child: Container(
        width: 48.wMin,
        height: 48.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceLayerElevated.color,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderDefault.color),
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 24.wMin,
          height: 24.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
        ),
      ),
    );
  }


  Widget _buildBodyWidget(){
    if(_selectedMethod == null){
      return CouponGiveawayDialogMethodWidget(
        couponShareData: widget.couponShareData,
        onTap: (method) {
          _selectedMethod = method;
          if(mounted) setState(() {});
        },
      );
    }

    if(_selectedMethod == InvitationMethodEnum.phone){
      return CouponGiveawayDialogPhoneWidget(
        couponData: widget.couponData,
        couponShareData: widget.couponShareData,
        onPrevious: () {
          _selectedMethod = null;
          if(mounted) setState(() {});
        },
      );
    }else if(_selectedMethod == InvitationMethodEnum.qrcode){
      return CouponGiveawayDialogQrcodeWidget(
        couponShareData: widget.couponShareData,
        onPrevious: () {
          _selectedMethod = null;
          if(mounted) setState(() {});
        },
      );
    } else if(_selectedMethod == InvitationMethodEnum.wechat){
      return CouponGiveawayDialogLinkWidget(
        couponShareData: widget.couponShareData,
        onPrevious: () {
          _selectedMethod = null;
          if(mounted) setState(() {});
        },
      );
    }

    return Container();

  }

}


class CouponGiveawayDialogMethodWidget extends StatelessWidget {
  final CouponShareEntity couponShareData;
  final void Function(InvitationMethodEnum method)? onTap;
  const CouponGiveawayDialogMethodWidget({super.key, required this.couponShareData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTipWidget(),
          _buildMethodListWidget(),
        ],
      ),
    );
  }

  Widget _buildTipWidget(){
    if(couponShareData.activityTitle == null && couponShareData.activityDesc == null) return Container();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceBrand.color.withValues(alpha: .1),
        border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: couponShareData.activityTitle != null && couponShareData.activityDesc != null ? 10.wMin : 0,
        children: [
          Visibility(
            visible: couponShareData.activityTitle != null,
            child: Text(
              couponShareData.activityTitle??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cSurfaceBrand.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Visibility(
            visible: couponShareData.activityDesc != null,
            child: Text(
              couponShareData.activityDesc??"",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodListWidget(){
    List<InvitationMethodEnum> methods = [];
    if(couponShareData.wechatShareLink != null){
      methods.add(InvitationMethodEnum.wechat);
    }
    if(couponShareData.wechatShareLink != null && couponShareData.activityReward != null){
      methods.add(InvitationMethodEnum.qrcode);
    }
    methods.add(InvitationMethodEnum.phone);


    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      child: Column(
        spacing: 16.wMin,
        children: List.generate(methods.length, (index){
          return _buildMethodListItemWidget(methods[index]);
        }),
      ),
    );
  }

  Widget _buildMethodListItemWidget(InvitationMethodEnum method){
    String title = "";
    String description = "";

    if(method == InvitationMethodEnum.phone){
      title = "手机号赠送";
      description = "输入好友手机号，短信直达";
    }else if(method == InvitationMethodEnum.qrcode){
      title = "二维码赠送";
      description = "生成专属海报，好友扫码即领";
    }else if(method == InvitationMethodEnum.wechat){
      if(Platform.isAndroid || Platform.isIOS){
        title = "微信转发";
        description = "唤起微信，把链接发给好友";
      }else{
        title = "分享链接";
        description = "复制链接，把链接发给好友";
      }
    }

    return TapScaleWidget(
      onTap: () {
        onTap?.call(method);
      },
      sclae: 1.01,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
        ),
        child: Row(
          children: [
            Container(
              width: 56.wMin,
              height: 56.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: method.color,
              ),
              child: SvgPicture.asset(
                method.iconPath,
                height: 24.wMin,
              ),
            ),
            SizedBox(width: 12.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.wMin),
            SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 40.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
            ),

          ],
        ),
      ),
    );
  }

}


class CouponGiveawayDialogPhoneWidget extends StatefulWidget {
  final CouponEntityDatas couponData;
  final CouponShareEntity couponShareData;

  /// 上一步
  final void Function()? onPrevious;
  const CouponGiveawayDialogPhoneWidget({super.key, required this.couponData, required this.couponShareData, required this.onPrevious});

  @override
  State<CouponGiveawayDialogPhoneWidget> createState() => _CouponGiveawayDialogPhoneWidgetState();
}

class _CouponGiveawayDialogPhoneWidgetState extends State<CouponGiveawayDialogPhoneWidget> {

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  /// 国家区号码
  String callingCode = "86";

  Timer? codeDownTimer;
  int codeDownTime = 60;
  bool isGetCode = false;

  /// 选择国家区号码
  Future<void> onSelectCallingCode(BuildContext context) async{
    String? res = await InternationalAreaCodeDialog.show(
      context: context,
      initialSelectedCode: callingCode,
    );
    if(res == null) return;
    callingCode = res;
    if(mounted) setState(() {});
  }

  Future<void> getCode() async{
    if(isGetCode) return;
    if(phoneController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请输入手机号");
    }
    if(phoneController.text.trim().length < 6){
      return ToastUtils.showToast(text: "手机号格式不正确");
    }
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "callingCode": callingCode,
        "phoneNumber": phoneController.text,
      };
      bool res = await CouponsRequest.transferCouponsSendCode(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "验证码发送成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
    
    isGetCode = true;
    if(mounted) setState(() {});
    codeDownTimer?.cancel();
    codeDownTimer = null;
    codeDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      codeDownTime--;
      if(mounted) setState(() {});
      if(codeDownTime == 0){
        timer.cancel();
        codeDownTimer = null;
        codeDownTime = 60;
        isGetCode = false;
        if(mounted) setState(() {});
      }
    });
  }

  /// 立即使用
  Future<void> transferCoupons() async{
    if(phoneController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请输入手机号");
    }
    if(phoneController.text.trim().length < 6){
      return ToastUtils.showToast(text: "手机号格式不正确");
    }
    if(codeController.text.isEmpty){
      return ToastUtils.showToast(text: "请输入验证码");
    }
    
    try {
      Map<String, dynamic> reqData = {
        "callingCode": callingCode,
        "phoneNumber": phoneController.text,
        "token": codeController.text,
        "couponId": widget.couponData.couponId,
      };
      ToastUtils.showLoading();
      bool res = await CouponsRequest.transferCouponsSubmit(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "赠送成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  void dispose() {
    codeDownTimer?.cancel();
    codeDownTimer = null;
    phoneController.dispose();
    codeController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 40.wMin),
        _buildTitleWidget(),
        SizedBox(height: 24.wMin),
        _buildPhoneWidget(),
        SizedBox(height: 24.wMin),
        _buildSendCodeWidget(),
        // _buildDescWidget(),
        SizedBox(height: 24.wMin),
        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
        SizedBox(height: 40.wMin),
        _buildButtonWidget(),
      ],
    );
  }

  Widget _buildTitleWidget(){
    Color couponColor = StatusUtils.getCouponColor(widget.couponData.type);

    String? expired = widget.couponData.expired;
    String expiredText = "";
    if(expired != null){
      expiredText = DateFormatUtil.formatStrtoStr(expired);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "您正在转送 ",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary,
                ),
              ),
              Text(
                widget.couponData.title??"",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: couponColor,
                ),
              ),
            ],
          ),
          Visibility(
            visible: expiredText.isNotEmpty,
            child: Row(
              children: [
                Text(
                  "有效期至: ",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary,
                  ),
                ),
                Text(
                  expiredText,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cFeedbackErrorText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPhoneWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: CardInputWidget(
        title: "朋友手机号",
        hintText: "请输入朋友的手机号",
        controller: phoneController,
        keyboardType: TextInputType.phone,
        maxLength: 11,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onClean: () {
          phoneController.clear();
        },
        prefixIcon: Container(
          margin: EdgeInsets.only(right: 16.wMin),
          child: TapScaleWidget(
            onTap: () {
              onSelectCallingCode(context);
            },
            sclae: 1,
            child: Container(
              height: 70.wMin,
              padding: EdgeInsets.only(left: 16.wMin),
              color: Colors.transparent,
              child: Row(
                spacing: 16.wMin,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "+$callingCode",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/svg/public/icon_arrow_down.svg",
                    width: 24.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                  Container(
                    width: 1.5.wMin,
                    height: 24.wMin,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ],
              ),
            ),
          ),
        ),
        
      ),
    );
  }

  Widget _buildSendCodeWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        spacing: 12.wMin,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CardInputWidget(
              title: "短信验证码",
              hintText: "请输入验证码",
              maxLength: 6,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              controller: codeController,
              onClean: () {
                codeController.clear();
              },
            ),
          ),
          ButtonWidget(
            text: !isGetCode ? "获取验证码" : "$codeDownTime s",
            height: 72.wMin,
            width: 177.wMin,
            borderRadius: 12.wMin,
            color: isGetCode ? AppTheme.cSurfaceTertiary.color : AppTheme.cFeedbackDefaultBackground,
            fontColor: AppTheme.cFeedbackDefaultText,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            sclae: 1.02,
            onTap: isGetCode ? null : () {
              getCode();
            },
          ),
        ],
      ),
    );
  }

  /// 说明
  // Widget _buildDescWidget(){
  //   return Container(
  //     margin: EdgeInsets.only(top: 24.wMin),
  //     padding: EdgeInsets.symmetric(horizontal: 32.wMin),
  //     child: Container(
  //       width: double.infinity,
  //       padding: EdgeInsets.all(24.wMin),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12.wMin),
  //         color: AppTheme.cSurfaceTertiary.color,
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             "转送说明",
  //             style: TextStyle(
  //               fontSize: 24.wMin,
  //               fontWeight: FontWeight.w600,
  //               color: AppTheme.cTextPrimary,
  //             ),
  //           ),
  //           SizedBox(height: 8.wMin),
  //           _buildDirectionsWidget("转送后不支持退回"),
  //           _buildDirectionsWidget("转送后的券不支持再次转送"),
  //           _buildDirectionsWidget("当朋友用券购买会员后会返还给你 10% 的实际支付乃币"),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildDirectionsWidget(String value){
  //   return Row(
  //     spacing: 8.wMin,
  //     children: [
  //       Text(
  //         "·",
  //         style: TextStyle(
  //           fontSize: 28.wMin,
  //           fontWeight: FontWeight.w600,
  //           color: AppTheme.cFeedbackErrorIcon,
  //         ),
  //       ),
  //       Expanded(
  //         child: Text(
  //           value,
  //           style: TextStyle(
  //             fontSize: 20.wMin,
  //             fontWeight: FontWeight.w400,
  //             color: AppTheme.cTextSecondary,
  //             height: 1.6,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildButtonWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        spacing: 12.wMin,
        children: [
          ButtonWidget(
            text: "返回",
            width: 128.wMin,
            height: 60.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            fontColor: AppTheme.cTextSecondary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            leftIcon: Container(
              margin: EdgeInsets.only(right: 4.wMin),
              child: SvgPicture.asset(
                "assets/svg/public/icon_w_arrow_left.svg",
                width: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
            ),
            onTap: () {
              widget.onPrevious?.call();
            },
          ),
          Expanded(
            child: ButtonWidget(
              text: "确认赠送",
              width: double.infinity,
              height: 60.wMin,
              borderRadius: 8.wMin,
              color: InvitationMethodEnum.phone.color.withValues(alpha: 0.1),
              border: Border.all(width: 1.wMin, color: InvitationMethodEnum.phone.color.withValues(alpha: 0.2)),
              fontColor: InvitationMethodEnum.phone.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.01,
              onTap: OptimizeUtils.noneThrottle(() {
                transferCoupons();
              }, 300),
            ),
          ),
          
        ],
      ),
    );
  }

}



class CouponGiveawayDialogQrcodeWidget extends StatefulWidget {
  final CouponShareEntity couponShareData;
  /// 上一步
  final void Function()? onPrevious;
  const CouponGiveawayDialogQrcodeWidget({super.key, required this.couponShareData, required this.onPrevious});

  @override
  State<CouponGiveawayDialogQrcodeWidget> createState() => _CouponGiveawayDialogQrcodeWidgetState();
}

class _CouponGiveawayDialogQrcodeWidgetState extends State<CouponGiveawayDialogQrcodeWidget> {
  final GlobalKey sharePageKey = GlobalKey();

  Uint8List? pngBytes;

  Future<void> generateShareImage() async{
    if(pngBytes != null) return;
    try {
      ToastUtils.showLoading();
      RenderRepaintBoundary? boundary = sharePageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if(boundary== null) return;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // 像素比率，值越大图片越清晰
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if(byteData == null) return;
      pngBytes = byteData.buffer.asUint8List();
    } finally{
      ToastUtils.hideLoading();
    }
    
  }

  /// 保存图片
  Future<void> _onSaveTap() async{
    await generateShareImage();
    if(pngBytes == null) return ToastUtils.showToast(text: "生成图片失败，请稍后重试");

    String name = "langwise_share_coupon_${DateTime.now().millisecondsSinceEpoch}";
    if(Platform.isMacOS || Platform.isWindows || Platform.isLinux){
      String? res = await FileSaver.instance.saveAs(
        name: name,
        bytes: pngBytes!,
        mimeType: MimeType.png,
        fileExtension: 'png',
      );
      print(res);
      if(res == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      return;
    }

    bool hasPermission = await PermissionUtils.savePhoto(Get.context ?? context);
    if(!hasPermission) return;
    dynamic res = await ImageGallerySaverPlus.saveImage(pngBytes!, quality: 100, name: name);
    print(res);
    if(res == null) return;
    ToastUtils.showToast(text: "保存成功", type: ToastType.success);

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.wMin),
        _buildBodyWidget(),
        SizedBox(height: 24.wMin),
        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
        SizedBox(height: 40.wMin),
        _buildButtonWidget(),
      ],
    );
  }

  Widget _buildBodyWidget(){
    List<String?> benefitList = widget.couponShareData.activityReward?.benefitList??[];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.wMin),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
      ),
      constraints: BoxConstraints(
        maxHeight: 720.wMin,
      ),
      child: SingleChildScrollView(
        child: RepaintBoundary(
          key: sharePageKey,
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 32.wMin),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cSurfaceBrand.color.withValues(alpha: 0.3),
                    AppTheme.cSurfaceBrand.color.withValues(alpha: 0),
                    AppTheme.cSurfaceLayerElevated2.color.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    
                  Visibility(
                    visible: widget.couponShareData.activityReward?.brandTitle != null,
                    child: Text(
                      widget.couponShareData.activityReward?.brandTitle??"",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.couponShareData.activityReward?.title != null,
                    child: Container(
                      margin: EdgeInsets.only(top: 16.wMin),
                      child: Text(
                        widget.couponShareData.title??"",
                        style: TextStyle(
                          fontSize: 40.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.couponShareData.activityReward?.subTitle != null,
                    child: Container(
                      margin: EdgeInsets.only(top: 10.wMin),
                      child: Text(
                        widget.couponShareData.activityReward?.subTitle??"",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                  ),
                    
                  Visibility(
                    visible: benefitList.isNotEmpty,
                    child: Container(
                      margin: EdgeInsets.only(top: 6.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(benefitList.length, (index){
                          return _buildDescItemWidget(benefitList[index]);
                        }),
                      ),
                    ),
                  ),
                    
                  SizedBox(height: 24.wMin),
                    
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      color: Colors.white,
                    ),
                    child: QrImageView(
                      data: widget.couponShareData.wechatShareLink??"",
                      backgroundColor: Colors.white,
                      size: 240.wMin,
                    ),
                  ),
                    
                  Visibility(
                    visible: widget.couponShareData.activityReward?.scanTip != null,
                    child: Container(
                      margin: EdgeInsets.only(top: 24.wMin),
                      child: Text(
                        widget.couponShareData.activityReward?.scanTip??"",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                  ),
                    
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescItemWidget(String? text){
    if(text == null) return Container();
    
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: Row(
        spacing: 8.wMin,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 24.wMin,
            color: AppTheme.cSurfaceBrand.color,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildButtonWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        spacing: 12.wMin,
        children: [
          ButtonWidget(
            text: "返回",
            width: 128.wMin,
            height: 60.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            fontColor: AppTheme.cTextSecondary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            leftIcon: Container(
              margin: EdgeInsets.only(right: 4.wMin),
              child: SvgPicture.asset(
                "assets/svg/public/icon_w_arrow_left.svg",
                width: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
            ),
            onTap: () {
              widget.onPrevious?.call();
            },
          ),
          Expanded(
            child: ButtonWidget(
              text: widget.couponShareData.activityReward?.actionText ?? "保存图片到相册",
              width: double.infinity,
              height: 60.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2)),
              fontColor: AppTheme.cSurfaceBrand.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.01,
              onTap: () async {
                await _onSaveTap();
              },
            ),
          ),
          
        ],
      ),
    );
  }

}




class CouponGiveawayDialogLinkWidget extends StatefulWidget {
   final CouponShareEntity couponShareData;
  /// 上一步
  final void Function()? onPrevious;
  const CouponGiveawayDialogLinkWidget({super.key, required this.couponShareData, required this.onPrevious});

  @override
  State<CouponGiveawayDialogLinkWidget> createState() => _CouponGiveawayDialogLinkWidgetState();
}

class _CouponGiveawayDialogLinkWidgetState extends State<CouponGiveawayDialogLinkWidget> {


  /// 微信分享网页
  Future<void> _onShareWebPage() async {
    if(widget.couponShareData.wechatShareLink == null) return;
    Uint8List? thumbData = await loadNetImageBytes();

    WxUtils.shareWebPage(
      url: widget.couponShareData.wechatShareLink??"", 
      title: widget.couponShareData.activityReward?.title??"",
      description: widget.couponShareData.wechatShareTip,
      thumbData: thumbData,
    );
  }

  Future<Uint8List?> loadNetImageBytes() async {
    String? imageUrl = widget.couponShareData.appIconUrl;
    if(imageUrl == null || imageUrl.isEmpty) return null;

    try {
      ToastUtils.showLoading();
      String? localFilePath = await CacheManagerUtils.instance.getFile(imageUrl, ResourceType.image);
      if(localFilePath != null){
        File localFile = File(localFilePath);
        if(await localFile.exists()){
          return await localFile.readAsBytes();
        }
      }

      HttpClient httpClient = HttpClient();
      try{
        HttpClientRequest request = await httpClient.getUrl(Uri.parse(imageUrl));
        HttpClientResponse response = await request.close();
        if(response.statusCode != HttpStatus.ok){
          return null;
        }

        List<int> imageBytes = await response.fold<List<int>>([], (previous, element){
          previous.addAll(element);
          return previous;
        });
        return Uint8List.fromList(imageBytes);
      } finally{
        httpClient.close(force: true);
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.wMin),
        _buildBodyWidget(),
        SizedBox(height: 16.wMin),
        _buildDescWidget(),
        SizedBox(height: 24.wMin),
        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
        SizedBox(height: 40.wMin),
        _buildButtonWidget(),
      ],
    );
  }

  Widget _buildBodyWidget(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.wMin),
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderNone.color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.couponShareData.wechatShareTip??"",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          Text(
            widget.couponShareData.wechatShareLink??"",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cSurfaceBrand.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescWidget(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.wMin),
      alignment: Alignment.center,
      child: Text(
        "好友打开链接后输入手机号即可领取福利",
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }


  Widget _buildButtonWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        children: [
          ButtonWidget(
            text: "返回",
            width: 128.wMin,
            height: 60.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            fontColor: AppTheme.cTextSecondary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            leftIcon: Container(
              margin: EdgeInsets.only(right: 4.wMin),
              child: SvgPicture.asset(
                "assets/svg/public/icon_w_arrow_left.svg",
                width: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
            ),
            onTap: () {
              widget.onPrevious?.call();
            },
          ),

          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 12.wMin),
              child: ButtonWidget(
                text: "复制文本和链接",
                width: double.infinity,
                height: 60.wMin,
                borderRadius: 8.wMin,
                color: AppTheme.cSurfaceLayerElevated.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                fontColor: InvitationMethodEnum.wechat.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.01,
                onTap: () async {

                  String copyText = "${widget.couponShareData.wechatShareTip} ${widget.couponShareData.wechatShareLink??""}";

                  await Clipboard.setData(ClipboardData(text: copyText));
                  ToastUtils.showToast(text: "复制成功", type: ToastType.success);
                },
              ),
            ),
          ),

          Visibility(
            visible: (Platform.isAndroid || Platform.isIOS),
            child: Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 12.wMin),
                child: ButtonWidget(
                  text: "打开微信转发给好友",
                  width: double.infinity,
                  height: 60.wMin,
                  borderRadius: 8.wMin,
                  color: InvitationMethodEnum.wechat.color,
                  border: Border.all(width: 1.wMin, color: InvitationMethodEnum.wechat.color),
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.01,
                  onTap: () async {
                    await _onShareWebPage();
                  },
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }

}