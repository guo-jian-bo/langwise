
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../common/commons.dart';
import '../utils/utils.dart';

/// 显示大图片 并且显示定稿按钮
class ManageLockBigImageDialog{

  /// * [relationImageId] 为null 不显示定稿按钮
  static Future<bool> show({
    required BuildContext context,
    required String? imageUrl,
    int? relationImageId,
    bool? locked,
  }) async{
    if(imageUrl == null) return false;
    bool? res = await showDialog<bool?>(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return ManageLockBigImageDialogWidget(
          imageUrl: imageUrl,
          relationImageId: relationImageId,
          locked: locked,
        );
      },
    );

    return res??false;
  }

}

class ManageLockBigImageDialogWidget extends StatefulWidget {
  final String imageUrl;
  final int? relationImageId;
  final bool? locked;
  const ManageLockBigImageDialogWidget({
    super.key, 
    required this.imageUrl, 
    this.relationImageId, 
    this.locked,
  });

  @override
  State<ManageLockBigImageDialogWidget> createState() => _ManageLockBigImageDialogWidgetState();
}

class _ManageLockBigImageDialogWidgetState extends State<ManageLockBigImageDialogWidget> {

  final _viewController = PhotoViewController();
  bool locked = false;

  @override
  void initState() {
    super.initState();
    locked = widget.locked == true;
  }


   /// 图片定稿
  Future<void> finalDraftImage(BuildContext context) async{
    if(widget.relationImageId == null) return;
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要将此图片定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": widget.relationImageId,
      };
      bool res = await LanguageConsoleRequest.finalDraftImage(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "定稿成功", type: ToastType.success);
      locked = true;
      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 图片取消定稿
  Future<void> cancelFinalDraftImage(BuildContext context) async{
    if(widget.relationImageId == null) return;

    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要取消图片定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": widget.relationImageId,
      };
      bool res = await LanguageConsoleRequest.unlockDraftImage(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "取消定稿成功", type: ToastType.success);
      locked = false;
      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back(result: widget.locked != locked);
      },
      child: Material(
        color: AppTheme.cBgPrimary.color,
        child: Stack(
          alignment: Alignment.center,
          children: [
            
            Center(
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final delta = event.scrollDelta.dy;
                    final scale = _viewController.scale ?? 1.0;
                    final newScale = scale - delta / 1000;
                    _viewController.scale = newScale.clamp(0.2, 10.0);
                  }
                },
                child: PhotoView(
                  controller: _viewController,
                  imageProvider: NetworkImage(widget.imageUrl),
                  loadingBuilder: (context, event) {
                    return Center(
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: AppTheme.cBgBrand.color,
                          size: 100.wMin,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      
            Positioned(
              right: 24.wMin + MediaQuery.of(context).padding.right,
              top: 24.wMin + MediaQuery.of(context).padding.top,
              child: TapScaleWidget(
                sclae: 1.05,
                onTap: () => Get.back(result: widget.locked != locked),
                child: Container(
                  width: 56.wMin,
                  height: 56.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceTertiary.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/x.svg",
                    width: 32.wMin,
                    height: 32.wMin,
                  ),
                ),
              ),
            ),
      
      
            Positioned(
              right: 24.wMin + MediaQuery.of(context).padding.right,
              bottom: 24.wMin + MediaQuery.of(context).padding.bottom,
              child: ManageAuthBoxWidget(
                authCodes: [ locked ? ManageAuthCode.contentReviewImageUnlock : ManageAuthCode.contentReviewImageLock],
                child: TapScaleWidget(
                  onTap: () {
                    if(locked){
                      cancelFinalDraftImage(context);
                    }else{
                      finalDraftImage(context);
                    }
                  },
                  sclae: 1.03,
                  child: Container(
                    width: 68.wMin,
                    height: 68.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.wMin),
                      color: AppTheme.cInverseOverlay2.color,
                      border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                    ),
                    child: SvgPicture.asset(
                      locked ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                      width: 38.wMin,
                    ),
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