
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../https/https.dart';
import '../widgets.dart';
import 'invitation_method_enum.dart';

class InvitationDialogsData{
  /// 弹窗标题
  String title;
  /// 弹窗描述
  String desc;

  /// 邀请奖励提示
  String? inviteRewardTip;
  /// 邀请奖励描述
  String? inviteRewardDesc;
  /// 微信分享提示
  String? wechatShareTip;
  /// 微信分享链接
  String? wechatShareLink;
  /// 分享缩略图
  String? appIconUrl;
  /// 二维码分享数据
  InvitationDialogsScanData? scanData;

  InvitationDialogsData({
    required this.title,
    required this.desc,
    this.inviteRewardTip,
    this.inviteRewardDesc,
    this.wechatShareTip,
    this.wechatShareLink,
    this.appIconUrl,
    this.scanData,
  });
}

class InvitationDialogsScanData{
  String? brandTitle;
  String? title;
  String? subTitle;
  List<String?>? benefitList;
  String? scanTip;
  String? actionText;

  InvitationDialogsScanData({
    this.brandTitle,
    this.title,
    this.subTitle,
    this.benefitList,
    this.scanTip,
    this.actionText,
  });
}

/// 邀请弹窗
class InvitationDialogs{
  
  /// 显示邀请方式弹窗
  static Future<bool> showMethodDialog({
    required BuildContext context,
    required InvitationDialogsData data,
  }) async{

    bool? result = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return InvitationDialogWidget(data: data);
      },
    );

    return result??false;
  }

}





class InvitationDialogWidget extends StatefulWidget {
  final InvitationDialogsData data;
  const InvitationDialogWidget({super.key, required this.data});

  @override
  State<InvitationDialogWidget> createState() => _InvitationDialogWidgetState();
}

class _InvitationDialogWidgetState extends State<InvitationDialogWidget> {
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
            widget.data.title,
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            widget.data.desc,
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
      return InvitationDialogMethodWidget(
        data: widget.data,
        onTap: (method) {
          _selectedMethod = method;
          if(mounted) setState(() {});
        },
      );
    }

    if(_selectedMethod == InvitationMethodEnum.phone){
      return InvitationDialogPhoneWidget(
        data: widget.data,
        onPrevious: () {
          _selectedMethod = null;
          if(mounted) setState(() {});
        },
      );
    }else if(_selectedMethod == InvitationMethodEnum.qrcode){
      return InvitationDialogQrcodeWidget(
        data: widget.data,
        onPrevious: () {
          _selectedMethod = null;
          if(mounted) setState(() {});
        },
      );
    } else if(_selectedMethod == InvitationMethodEnum.wechat){
      return InvitationDialogLinkWidget(
        data: widget.data,
        onPrevious: () {
          _selectedMethod = null;
          if(mounted) setState(() {});
        },
      );
    }

    return Container();

  }


}


class InvitationDialogMethodWidget extends StatelessWidget {
  final InvitationDialogsData data;
  final void Function(InvitationMethodEnum method)? onTap;
  const InvitationDialogMethodWidget({super.key, required this.data, required this.onTap});

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
    if(data.inviteRewardTip == null && data.inviteRewardDesc == null) return Container();
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
        spacing: data.inviteRewardTip != null && data.inviteRewardDesc != null ? 10.wMin : 0,
        children: [
          Visibility(
            visible: data.inviteRewardTip != null,
            child: Text(
              data.inviteRewardTip??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cSurfaceBrand.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Visibility(
            visible: data.inviteRewardDesc != null,
            child: Text(
              data.inviteRewardDesc??"",
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
    if(data.wechatShareLink != null){
      methods.add(InvitationMethodEnum.wechat);
    }
    if(data.wechatShareLink != null && data.scanData != null){
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
      title = "手机号邀请";
      description = "输入好友手机号，短信直达邀请";
    }else if(method == InvitationMethodEnum.qrcode){
      title = "二维码邀请";
      description = "生成专属海报，好友扫码即领";
    }else if(method == InvitationMethodEnum.wechat){
      if(Platform.isAndroid || Platform.isIOS){
        title = "微信转发";
        description = "唤起微信，把邀请链接发给好友";
      }else{
        title = "分享链接";
        description = "复制链接，把邀请链接发给好友";
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


class InvitationDialogPhoneWidget extends StatefulWidget {
  final InvitationDialogsData data;
  /// 上一步
  final void Function()? onPrevious;
  const InvitationDialogPhoneWidget({super.key, required this.data, required this.onPrevious});

  @override
  State<InvitationDialogPhoneWidget> createState() => _InvitationDialogPhoneWidgetState();
}

class _InvitationDialogPhoneWidgetState extends State<InvitationDialogPhoneWidget> {

  /// 邀请是否发送成功
  bool isInviteSuccess = false;

  String callingCode = "86";
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  Timer? codeDownTimer;
  int codeDownTime = 60;
  bool isGetCode = false;

  Future<void> getCode() async{
    if(isGetCode) return;
    FocusScope.of(context).requestFocus(FocusNode());

    if(phoneController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请输入手机号");
    }

    if(phoneController.text.trim().length < 6) {
      ToastUtils.showToast(text: "手机号格式不正确");
      return;
    }
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "callingCode": callingCode,
        "phoneNumber": phoneController.text.trim(),
      };
      bool res = await ActivitiesRequest.referralSmsSend(reqData: reqData);
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

  /// 提交
  Future<void> submit() async{

    if(phoneController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请输入手机号");
    }

    if(phoneController.text.trim().length < 6) {
      ToastUtils.showToast(text: "手机号格式不正确");
      return;
    }

    if(codeController.text.isEmpty){
      ToastUtils.showToast(text: "请输入验证码");
      return;
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "token": codeController.text,
        "callingCode": callingCode,
        "phoneNumber": phoneController.text.trim(),
      };
      bool res = await ActivitiesRequest.referralSmsTokenBind(reqData: reqData);
      if(!res) return;
      isInviteSuccess = true;
      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 继续邀请
  Future<void> continueInvite() async{
    isInviteSuccess = false;
    phoneController.clear();
    codeController.clear();
    isGetCode = false;
    codeDownTime = 60;
    codeDownTimer?.cancel();
    codeDownTimer = null;
    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(isInviteSuccess){
      return _buildSuccessWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 40.wMin),
        _buildPhoneWidget(),
        SizedBox(height: 24.wMin),
        _buildSendCodeWidget(),
        SizedBox(height: 24.wMin),
        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
        SizedBox(height: 40.wMin),
        _buildButtonWidget(),
      ],
    );
  }

  Widget _buildSuccessWidget(){
    String phone = phoneController.text.trim();
    phone = "${phone.substring(0, 4)}****${phone.substring(7)}";

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 32.wMin),
          child: Column(
            children: [
              SizedBox(height: 60.wMin),
              SvgPicture.asset(
                "assets/svg/public/check_box_green.svg",
                height: 120.wMin,
              ),
              SizedBox(height: 40.wMin),
              Text(
                "邀请发送成功！",
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.wMin),
              Text(
                "已向 $phone 发送邀请",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.wMin),
        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
        SizedBox(height: 40.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 32.wMin),
          child: Row(
            spacing: 12.wMin,
            children: [
              Expanded(
                child: ButtonWidget(
                  text: "继续邀请",
                  width: 128.wMin,
                  height: 60.wMin,
                  borderRadius: 8.wMin,
                  color: InvitationMethodEnum.phone.color.withValues(alpha: 0.1),
                  border: Border.all(width: 1.wMin, color: InvitationMethodEnum.phone.color.withValues(alpha: 0.2)),
                  fontColor: InvitationMethodEnum.phone.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  onTap: OptimizeUtils.noneThrottle(() {
                    continueInvite();
                  }, 300),
                ),
              ),
              Expanded(
                child: ButtonWidget(
                  text: "完成",
                  width: double.infinity,
                  height: 60.wMin,
                  borderRadius: 8.wMin,
                  color: AppTheme.cSurfaceLayerElevated.color,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                  fontColor: AppTheme.cTextSecondary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.01,
                  onTap: OptimizeUtils.noneThrottle(() {
                    Get.back(result: true);
                  }, 300),
                ),
              ),
              
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildPhoneWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: CardInputWidget(
        title: "输入好友手机号发送邀请",
        controller: phoneController,
        hintText: "请输入好友手机号",
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
              hintText: "请输入6位验证码",
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
            onTap: isGetCode ? null : OptimizeUtils.noneThrottle(() {
              getCode();
            }, 300),
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
              text: "确认邀请",
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
                submit();
              }, 300),
            ),
          ),
          
        ],
      ),
    );
  }

}


class InvitationDialogQrcodeWidget extends StatefulWidget {
  final InvitationDialogsData data;
  /// 上一步
  final void Function()? onPrevious;
  const InvitationDialogQrcodeWidget({super.key, required this.data, required this.onPrevious});

  @override
  State<InvitationDialogQrcodeWidget> createState() => _InvitationDialogQrcodeWidgetState();
}

class _InvitationDialogQrcodeWidgetState extends State<InvitationDialogQrcodeWidget> {
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

    String name = "langwise_share_invitation_${DateTime.now().millisecondsSinceEpoch}";
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

    bool hasPermission = await PermissionUtils.savePhoto(context);
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
    List<String?> benefitList = widget.data.scanData?.benefitList??[];

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
                    visible: widget.data.scanData?.brandTitle != null,
                    child: Text(
                      widget.data.scanData?.brandTitle??"",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.data.scanData?.title != null,
                    child: Container(
                      margin: EdgeInsets.only(top: 16.wMin),
                      child: Text(
                        widget.data.scanData?.title??"",
                        style: TextStyle(
                          fontSize: 40.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.data.scanData?.subTitle != null,
                    child: Container(
                      margin: EdgeInsets.only(top: 10.wMin),
                      child: Text(
                        widget.data.scanData?.subTitle??"",
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
                      data: widget.data.wechatShareLink??"",
                      size: 240.wMin,
                    ),
                  ),
                    
                  Visibility(
                    visible: widget.data.scanData?.scanTip != null,
                    child: Container(
                      margin: EdgeInsets.only(top: 24.wMin),
                      child: Text(
                        widget.data.scanData?.scanTip??"",
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
              color: AppTheme.cTextSecondary.color,
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
              text: widget.data.scanData?.actionText ?? "保存图片到相册",
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


class InvitationDialogLinkWidget extends StatefulWidget {
  final InvitationDialogsData data;
  /// 上一步
  final void Function()? onPrevious;
  const InvitationDialogLinkWidget({super.key, required this.data, required this.onPrevious});

  @override
  State<InvitationDialogLinkWidget> createState() => _InvitationDialogLinkWidgetState();
}

class _InvitationDialogLinkWidgetState extends State<InvitationDialogLinkWidget> {


  /// 微信分享网页
  Future<void> _onShareWebPage() async {
    if(widget.data.wechatShareLink == null) return;
    Uint8List? thumbData = await loadNetImageBytes();

    WxUtils.shareWebPage(
      url: widget.data.wechatShareLink??"", 
      title: widget.data.scanData?.title??"",
      description: widget.data.wechatShareTip,
      thumbData: thumbData,
    );
  }

  Future<Uint8List?> loadNetImageBytes() async {
    String? imageUrl = widget.data.appIconUrl;
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
            widget.data.wechatShareTip??"",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          Text(
            widget.data.wechatShareLink??"",
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

                  String copyText = "${widget.data.wechatShareTip} ${widget.data.wechatShareLink??""}";

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
