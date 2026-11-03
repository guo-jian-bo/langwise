import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/routes_breadcrumb_utils.dart';

class UpdateImageModel{
  String? key;
  String url;
  bool isNetword;
  UpdateImageModel({this.key, required this.url, this.isNetword = false});
}

class LimitDiscounDetailController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  LimitDiscounDetailController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.LIMIT_DISCOUN_DETAIL;

  @override
  String get breadcrumbTitle => "限时折扣详情";
  
  /// 状态数据
  final Rx<HotspotsActivitySubmitStatuEntity> statusData = HotspotsActivitySubmitStatuEntity().obs;

  final int maxSelectCount = 5;

  /// 从外部拖进来 是否触碰到
  final RxBool dropIsEnter = false.obs;
  
  /// 选择的照片
  final RxList<UpdateImageModel> selectFiles = <UpdateImageModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    getSubmissionStatus();
  }

  Future<void> getSubmissionStatus() async{
    try {
      ToastUtils.showLoading();
      HotspotsActivitySubmitStatuEntity? entity = await CouponsRequest.getHotspotsActivitySubmitStatus();
      if(entity == null) return;
      statusData.value = entity;

      List<String?> screenshotUrls = entity.screenshotUrls??[];
      List<String?> screenshots = entity.screenshots??[];
      for(int i = 0; i < screenshots.length; i++){
        if(screenshots[i] == null || screenshotUrls[i] == null) continue;
        selectFiles.add(UpdateImageModel(
          key: screenshots[i],
          url: screenshotUrls[i]!,
          isNetword: true,
        ));
      }
      
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 拖进来的文件
  Future<void> dropInFiles(List<DropItem> files) async{
    if(selectFiles.length >= maxSelectCount){
      return ToastUtils.showToast(text: "最多只能上传$maxSelectCount张图片");
    }
    for(int i = 0; i < files.length; i++){
      if(isImage(files[i].path)){
        if(selectFiles.length >= maxSelectCount) continue;
        if(selectFiles.contains(files[i].path)) continue;
        selectFiles.add(UpdateImageModel(
          url: files[i].path,
        ));
      }
    }
  }

  /// 点击选择图片
  Future<void> selectImage(BuildContext context) async{
    if(selectFiles.length >= maxSelectCount){
      return ToastUtils.showToast(text: "最多只能上传$maxSelectCount张图片");
    }

    List<File>? files = await ImagePickerUtils.pickImages(
      context: context,
      maxSelectCount: 5 - selectFiles.length,
      imageQuality: 50,
    );
    if(files == null) return;
    for(int i = 0; i < files.length; i++){
      if(selectFiles.length >= maxSelectCount) continue;
      if(selectFiles.contains(files[i].path)) continue;
      selectFiles.add(UpdateImageModel(
          url: files[i].path,
        ));
    }
  }
  
  bool isImage(String filePath) {
    final ext = filePath.toLowerCase();
    return ext.endsWith(".jpg") || ext.endsWith(".jpeg") || ext.endsWith(".png");
  }

  Future<void> save() async{
    if(selectFiles.isEmpty) return ToastUtils.showToast(text: "请上传截图");
    
    try {
      ToastUtils.showLoading();
      List<String> updateImageKeys = [];
      for(int i = 0; i < selectFiles.length; i++){
        if(selectFiles[i].key == null) continue;
        updateImageKeys.add(selectFiles[i].key!);
      }
      for(int i = 0; i < selectFiles.length; i++){
        if(selectFiles[i].isNetword) continue;

        final record = await OssUploadFileUtils.uploadUserFile(
          filePath: selectFiles[i].url,
        );
        if(record == null || record.key == null) continue;
        updateImageKeys.add(record.key!);
      }
      if(updateImageKeys.isEmpty) return ToastUtils.showToast(text: "上传失败");
      
      Map<String, dynamic> reqData = {
        "screenshots": updateImageKeys,
      };
      bool res = await CouponsRequest.uploadScreenshots(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "上传成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
    
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
}
