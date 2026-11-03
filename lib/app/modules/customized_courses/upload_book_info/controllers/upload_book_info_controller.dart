import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/https/https.dart';
import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';

class UploadBookInfoController extends GetxController {
  String? isbn;

  final RxString initDistrictCode = "".obs;

  final RxString frontCover = "".obs;
  final RxString backCover = "".obs;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      isbn = Get.arguments["isbn"];
    }
  }

  

  Future<void> selectFrontCover(BuildContext context) async {
    File? file = await ImagePickerUtils.selectPicture(
      context: context, 
      title: "上传教材封面",
      cropAspectRatio: 3 / 4,
    );
    if(file == null) return;
    frontCover.value = file.path;
  }

  Future<void> selectBackCover(BuildContext context) async {
    File? file = await ImagePickerUtils.selectPicture(
      context: context, 
      title: "上传教材封底",
      cropAspectRatio: 3 / 4,
    );
    if(file == null) return;
    backCover.value = file.path;
  }

  void reset(){
    frontCover.value = "";
    backCover.value = "";
  }

  Future<void> uploadBookInfo(BuildContext context) async {
    if(isbn == null) return;

    if(frontCover.isEmpty){
      ToastUtils.showToast(text: "请上传教材封面");
      return;
    }
    if(backCover.isEmpty){
      ToastUtils.showToast(text: "请上传教材封底");
      return;
    }

    try {
      ToastUtils.showLoading();
      
      final record = await OssUploadFileUtils.uploadUserFile(filePath: frontCover.value);
      if (record == null) return;

      final record2 = await OssUploadFileUtils.uploadUserFile(filePath: backCover.value);
      if (record2 == null) return;

      Map<String, dynamic> reqData = {
        "isbn": isbn,
        "cover": record.key,
        "backCover": record2.key,
        "locale": initDistrictCode.value,
      };
      bool res = await CustomizedCoursesRequest.uploadUnIsbnInfo(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
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
