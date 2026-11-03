
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_svg/svg.dart';
import 'package:langwise/config.dart';
import 'package:langwise/theme/theme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluwx/fluwx.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/utils.dart';
import 'widgets.dart';


class ShareBoxWidget extends StatefulWidget {
  final String? shareTitle;
  final String? shareText;
  final Color childBgColor;
  /// 分享的内容组件 通常是图片widget
  final Widget child;
  final double childWidth;
  final Decoration? childDecoration;

  /// 分享统一外框
  const ShareBoxWidget({
    super.key, 
    this.childBgColor = AppTheme.cBgPrimary,
    required this.child, 
    required this.childWidth,
    this.childDecoration,
    this.shareText, 
    this.shareTitle,
  });

  @override
  State<ShareBoxWidget> createState() => _ShareBoxWidgetState();
}

class _ShareBoxWidgetState extends State<ShareBoxWidget> {
  final GlobalKey sharePageKey = GlobalKey();

  final GlobalKey moreKey = GlobalKey();

  Uint8List? pngBytes;


  Future<void> generateShareImage() async{
    if(pngBytes != null) return;
    try {
      ToastUtils.showLoading();
      RenderRepaintBoundary? boundary = sharePageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if(boundary== null) return;
      ui.Image image = await boundary.toImage(pixelRatio: 5.0); // 像素比率，值越大图片越清晰
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
    if(pngBytes == null) return;

    String name = "langwise_share_${DateTime.now().millisecondsSinceEpoch}";
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

  /// 更多
  Future<void> _onMoreTap() async{
    await generateShareImage();
    if(pngBytes == null) return;
    final box = moreKey.currentContext?.findRenderObject() as RenderBox?;
    if(box == null) return;
    
    // 使用固定路径的临时文件，避免每次分享都生成新文件
    final tempDirPath = await CacheManagerUtils.instance.getShareDirPath();
    final shearPngName = CacheManagerUtils.instance.evalLevelFileName;
    final tempFile = File('$tempDirPath${Platform.pathSeparator}$shearPngName');
    await tempFile.writeAsBytes(pngBytes!);
    
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(tempFile.path),
        ],
        subject: widget.shareTitle,
        text: widget.shareText,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  /// 微信好友
  Future<void> _onWechatFriendTap() async{
    await generateShareImage();
    if(pngBytes == null) return;
    try{
      await WxUtils.shareImage(
        imageBytes: pngBytes!,
        title: widget.shareTitle??"",
      );
    } catch (e) {
      print(e);
    }
  }

  ///  微信朋友圈
  Future<void> _onWechatTimelineTap() async{
    await generateShareImage();
    if(pngBytes == null) return;
    await WxUtils.shareImage(
      imageBytes: pngBytes!,
      scene: WeChatScene.timeline,
      title: widget.shareTitle??"",
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxDialogHeight = (media.size.height - media.padding.vertical - 48.wMin).clamp(0.0, double.infinity);
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pop();
      },
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: GestureDetector(
            onTap: (){},
            child: SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxDialogHeight,
                ),
                child: Container(
                  padding: EdgeInsets.only(top: 16.wMin, left: 16.wMin, bottom: 16.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.wMin),
                    color: AppTheme.cBgTertiary.color,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: widget.childWidth,
                        child: SingleChildScrollView(
                          child: RepaintBoundary(
                            key: sharePageKey,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.wMin),
                              child: Container(
                                width: double.infinity,
                                color: widget.childBgColor,
                                child: Container(
                                  decoration: widget.childDecoration,
                                  child: Column(
                                    children: [
                                      widget.child,
                                      _appQrCodeWidget(),
                                      SizedBox(height: 10.wMin),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildButtonsWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appQrCodeWidget(){
    return Container(
      margin: EdgeInsets.only(top: 12.wMin),
      padding: EdgeInsets.symmetric(horizontal: 6.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(4.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cBgBrand.color,
              borderRadius: BorderRadius.circular(6.wMin),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.wMin),
                  child: Image.asset(
                    "assets/images/logo/app_logo.png",
                    width: 18.wMin,
                    height: 18.wMin,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 4.wMin),
                Text(
                  Config.appName,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: AppTheme.cStaticWhite.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.wMin),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.wMin),
                    color: AppTheme.cStaticWhite.color,
                  ),
                  child: Text(
                    Config.appIntroduction,
                    style: TextStyle(
                      fontSize: 12.wMin,
                      color: AppTheme.cStaticBlack.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(6.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cStaticWhite.color,
              borderRadius: BorderRadius.circular(4.wMin),
            ),
            child: QrImageView(
              data: Config.appDownloadUrl,
              backgroundColor: AppTheme.cStaticWhite.color,
              padding: EdgeInsets.zero,
              size: 75.wMin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsWidget(){
    return Container(
      // color: Colors.yellow,
      width: 320.wMin,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: Platform.isAndroid || Platform.isIOS,
            child: Container(
              margin: EdgeInsets.only(bottom: 40.wMin),
              child: Row(
                children: [
                  _buildWechatFriendButtonWidget(),
                  _buildWechatTimelineButtonWidget(),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _buildSaveButtonWidget(),
              _buildMoreButtonWidget(),
            ],
          ),
        ],
      ),
    );
  }





  /// 保存到本地按钮
  Widget _buildSaveButtonWidget(){
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16.wMin,
        children: [
          TapScaleWidget(
            onTap: () {
              _onSaveTap();
            },
            sclae: 1.05,
            child: Container(
              width: 64.wMin,
              height: 64.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cBgBrand.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_download_simple.svg",
                width: 32.wMin,
                height: 32.wMin,
              ),
            ),
          ),
          Text(
            "保存到本地",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
      
        ],
      ),
    );
  }

  /// 更多按钮
  Widget _buildMoreButtonWidget(){
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16.wMin,
        children: [
          TapScaleWidget(
            onTap: () {
              _onMoreTap();
            },
            sclae: 1.05,
            child: Container(
              key: moreKey,
              width: 64.wMin,
              height: 64.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cBgSecondary.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_more.svg",
                width: 32.wMin,
                height: 32.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
          ),
          Text(
            "更多",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
      
        ],
      ),
    );
  }

  /// 微信好友按钮
  Widget _buildWechatFriendButtonWidget(){
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16.wMin,
        children: [
          TapScaleWidget(
            onTap: () {
              _onWechatFriendTap();
            },
            sclae: 1.05,
            child: Image.asset(
              "assets/images/public/icon_wx.png",
              fit: BoxFit.cover,
              width: 64.wMin,
              height: 64.wMin,
            ),
          ),
          Text(
            "微信好友",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
      
        ],
      ),
    );
  }


  /// 微信朋友圈按钮
  Widget _buildWechatTimelineButtonWidget(){
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16.wMin,
        children: [
          TapScaleWidget(
            onTap: () {
              _onWechatTimelineTap();
            },
            sclae: 1.05,
            child: Container(
              width: 64.wMin,
              height: 64.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cStaticWhite.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_wx_f.svg",
                fit: BoxFit.cover,
                width: 58.wMin,
                height: 58.wMin,
              ),
            ),
          ),
          Text(
            "微信朋友圈",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
      
  

}
