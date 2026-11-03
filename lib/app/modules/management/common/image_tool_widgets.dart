
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../common/enum/enum.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../dialog/dialogs.dart';
import '../manage_content/manage_zhendu_console/enums/manage_zhendu_enums.dart';
import '../utils/utils.dart';
import 'commons.dart';


class ManageImageToolEditWidgets extends StatefulWidget {
  /// 是否显示定稿按钮
  final bool showLockButton;
  final bool locked;
  final String? imageUrl;
  final int? relationImageId;

  /// 是否显示编辑按钮
  final bool showEditButton;
  final int? uid;
  final String? type;
  final int? semanticId;
  final List<int?>? imageIds;
  final int? styleId;
  final int? promptId;
  /// 裁剪是否固定比例
  final bool isFixedAspectRatio;

  final ManageZhenduPersonaViewEnum? viewType;
  final SceneStoryboardTypeEnum? sceneType;
  final int? visualProjectId;

  /// 是否显示审核按钮
  final bool showReviewButton;
  final int? imageTaskId;

  /// 是否显示裁剪按钮
  final bool showCropButton;

  /// 刷新
  final Function()? onRefresh;

  const ManageImageToolEditWidgets({
    super.key, 
    this.showLockButton = true,
    this.locked = false,
    this.imageUrl,
    this.relationImageId,
    this.showEditButton = true,
    this.uid,
    this.type,
    this.semanticId,
    this.imageIds,
    this.styleId,
    this.promptId,
    this.isFixedAspectRatio = true,
    this.viewType,
    this.sceneType,
    this.visualProjectId,
    this.showReviewButton = true,
    this.imageTaskId,
    this.showCropButton = true,
    this.onRefresh,
  });

  @override
  State<ManageImageToolEditWidgets> createState() => _ManageImageToolEditWidgetsState();
}

class _ManageImageToolEditWidgetsState extends State<ManageImageToolEditWidgets> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Visibility(
          visible: widget.showLockButton,
          child: ManageAuthBoxWidget(
            authCodes: [ widget.locked ? ManageAuthCode.contentReviewImageUnlock : ManageAuthCode.contentReviewImageLock],
            margin: EdgeInsets.only(left: 4.wMin),
            child: TapScaleWidget(
              onTap: () async{
                bool res = await ManageLockBigImageDialog.show(
                  context: context, 
                  imageUrl: widget.imageUrl,
                  relationImageId: widget.relationImageId,
                  locked: widget.locked,
                );
                if(!res) return;
                widget.onRefresh?.call();
              },
              sclae: 1.1,
              child: Container(
                width: 36.wMin,
                height: 36.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: AppTheme.cInverseOverlay2.color,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                ),
                child: SvgPicture.asset(
                  widget.locked == true ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                  width: 22.wMin,
                ),
              ),
            ),
          ),
        ),

        Visibility(
          visible: widget.showReviewButton,
          child: Visibility(
            visible: UserStore.to.rolePermissions.value.userIsImageReviewer || UserStore.to.rolePermissions.value.userIsImageSuperReviewer,
            child: Container(
              margin: EdgeInsets.only(left: 4.wMin),
              child: ButtonWidget(
                text: (widget.imageTaskId??0) == 0 ? "无待审核" : "待审核 1",
                height: 36.wMin,
                padding: EdgeInsets.symmetric(horizontal: 6.wMin),
                color: AppTheme.cSurfacePrimary.color,
                borderRadius: 4.wMin,
                fontSize: 16.wMin,
                fontColor: (widget.imageTaskId??0) == 0 ? AppTheme.cTextPrimary.color : AppTheme.cSurfaceWarning.color,
                sclae: 1.03,
                onTap: () async{
                  if(widget.imageTaskId == null) return ToastUtils.showToast(text: "暂无待审核图片");
                  await ManagePageRegistry.jumpTo(
                    Routes.MANAGE_CHECK_IMAGE,
                    arguments: {
                      "taskIds": [widget.imageTaskId!],
                    },
                  );
                  widget.onRefresh?.call();
                },
              ),
            ),
          ),
        ),

        Visibility(
          visible: widget.showCropButton && widget.imageIds != null && widget.imageIds!.isNotEmpty,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.adminContentReviewImageCrop],
            margin: EdgeInsets.only(left: 4.wMin),
            child: TapScaleWidget(
              onTap: () async{
                dynamic res = await ManagePageRegistry.jumpTo(
                  Routes.MANAGE_UNIFIED_IMAGE_CROP,
                  arguments: {
                    "uid": widget.uid,
                    "type": widget.type,
                    "semanticId": widget.semanticId,
                    "imageIds": widget.imageIds,
                    "styleId": widget.styleId,
                    "viewType": widget.viewType,
                    "sceneType": widget.sceneType,
                    "visualProjectId": widget.visualProjectId,
                    "isFixedAspectRatio": widget.isFixedAspectRatio,
                  },
                );
                if(res != true) return;
                widget.onRefresh?.call();
              },
              sclae: 1.1,
              child: Container(
                width: 36.wMin,
                height: 36.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: AppTheme.cInverseOverlay2.color,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                ),
                child: Icon(
                  Icons.crop,
                  size: 22.wMin,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ),
          ),
        ),

        Visibility(
          visible: widget.showEditButton && widget.imageIds != null && widget.imageIds!.isNotEmpty,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.contentReviewImageCreateInfo],
            margin: EdgeInsets.only(left: 4.wMin),
            child: ButtonWidget(
              text: "编辑",
              height: 36.wMin,
              padding: EdgeInsets.symmetric(horizontal: 6.wMin),
              color: AppTheme.cSurfacePrimary.color,
              borderRadius: 4.wMin,
              fontSize: 16.wMin,
              fontColor: AppTheme.cTextBrand.color,
              sclae: 1.03,
              onTap: () async{
          
                await ManagePageRegistry.jumpTo(
                  Routes.MANAGE_UNIFIED_IMAGE_CREATE,
                  arguments: {
                    "uid": widget.uid,
                    "type": widget.type,
                    "semanticId": widget.semanticId,
                    "imageIds": widget.imageIds,
                    "styleId": widget.styleId,
                    "promptId": widget.promptId,
                    "viewType": widget.viewType,
                    "sceneType": widget.sceneType,
                    "visualProjectId": widget.visualProjectId,
                  },
                );
                widget.onRefresh?.call();
          
              },
            ),
          ),
        ),

      ],
    );
  }
}


class ManageImageToolBRWidgets extends StatefulWidget {
  final bool locked;
  final String? imageUrl;
  final int? relationImageId;
  /// 刷新
  final Function()? onRefresh;
  const ManageImageToolBRWidgets({
    super.key, 
    this.locked = false, 
    this.imageUrl, 
    this.relationImageId,
    this.onRefresh,
  });

  @override
  State<ManageImageToolBRWidgets> createState() => _ManageImageToolBRWidgetsState();
}

class _ManageImageToolBRWidgetsState extends State<ManageImageToolBRWidgets> {


  Future<void> download() async {
    if (widget.imageUrl == null) return;

    String? selectDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectDirectory == null) return;

    try {
      ToastUtils.showLoading();
      // 先检查本地有没有音频资源 如果有就直接复制到下载目录
      String? localFilePath = await CacheManagerUtils.instance.getFile(widget.imageUrl!, ResourceType.image);
      String imageName = getFileName(url: widget.imageUrl!) ?? "${DateTime.now().millisecond}.jpg";
      String saveFilePath = "$selectDirectory${Platform.pathSeparator}$imageName";
      if (await File(saveFilePath).exists()) {
        return;
      }
      if (localFilePath != null) {
        await File(localFilePath).copy(saveFilePath);
        ToastUtils.showToast(text: "下载成功", type: ToastType.success);
        return;
      }
      // 本地没有资源 就从网络下载
      Response res = await WiseHttp().download(
        widget.imageUrl!,
        saveFilePath,
      );
      if (res.statusCode == 200) {
        ToastUtils.showToast(text: "下载成功", type: ToastType.success);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  ///获取资源名称
  String? getFileName({
    required String? url,
  }) {
    if (url == null) return null;
    Uri uri = Uri.parse(url);
    return uri.pathSegments.last.split("/").last;
  }



  @override
  Widget build(BuildContext context) {
    if(widget.imageUrl == null) return Container();

    return Row(
      children: [

        TapScaleWidget(
          onTap: () async{
            download();
          },
          sclae: 1.1,
          child: Container(
            width: 36.wMin,
            height: 36.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.wMin),
              color: AppTheme.cInverseOverlay2.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
            ),
            child: SvgPicture.asset(
              "assets/svg/public/icon_download_simple.svg",
              width: 22.wMin,
              height: 22.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
            ),
          ),
        ),


        Container(
          margin: EdgeInsets.only(left: 4.wMin),
          child: TapScaleWidget(
            onTap: () async{
              if(widget.imageUrl == null) return;
              if(widget.relationImageId != null){
                bool res = await ManageLockBigImageDialog.show(
                  context: context, 
                  imageUrl: widget.imageUrl,
                  relationImageId: widget.relationImageId,
                  locked: widget.locked,
                );
                if(!res) return;
                widget.onRefresh?.call();
              }else{
                ShowBigResourceDialog.showImage(
                  context: context, 
                  imageUrls: [widget.imageUrl!],
                );
              }
              
            },
            sclae: 1.1,
            child: Container(
              width: 36.wMin,
              height: 36.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: AppTheme.cInverseOverlay2.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              ),
              child: Icon(
                Icons.fullscreen,
                size: 22.wMin,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ),

        

      ],
    );
  }
}