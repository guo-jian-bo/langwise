import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/https/https.dart';

import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../utils/utils.dart';

class FeedbackOpinionController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  FeedbackOpinionController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.FEEDBACK_OPINION;

  @override
  String get breadcrumbTitle => "反馈意见";
  
  final TextEditingController feedbackController = TextEditingController();
  final RxInt feedbackLength = 0.obs;

  final RxList<File> imageFileList = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
  }


  Future<void> selectImage(BuildContext context) async{
    if(imageFileList.length >= 4) {
      ToastUtils.showToast(text: "最多只能上传4张图片");
      return;
    }
    File? file = await ImagePickerUtils.selectPicture(
      context: context, 
      showCrop: false,
    );
    if(file == null) return;
    imageFileList.add(file);
  }


  void deleteImage(int index){
    imageFileList.removeAt(index);
  }


  Future<void> submitFeedback() async{

    if(feedbackController.text.trim().isEmpty) {
      ToastUtils.showToast(text: "请输入问题描述");
      return;
    }
    if(feedbackController.text.trim().length < 10){
      ToastUtils.showToast(text: "问题描述不能少于10个字符");
      return;
    }

    try {
      ToastUtils.showLoading();
      List<String> imageKey = [];
      for(int i = 0; i < imageFileList.length; i++){

        final record = await OssUploadFileUtils.uploadUserFile(
          filePath: imageFileList[i].path,
        );
        if (record == null || record.key == null) return;
        imageKey.add(record.key!);
      }
      Map<String, dynamic> reqData = {
        "text": feedbackController.text,
        "images": imageKey,
      };
      bool res = await UserRequest.feedbackOpinion(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功");
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
    feedbackController.dispose();
    super.onClose();
  }
  
}
