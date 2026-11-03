import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/https/https.dart';
import '../../../../../common/stores/user.dart';
import '../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

class EditUserProfileController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  EditUserProfileController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EDIT_USER_PROFILE;

  @override
  String get breadcrumbTitle => "编辑个人资料";

  final UserStore userStore = UserStore.to;
  
  final RxString headFilePath = "".obs;
  final RxString headImagePath = "".obs;

  final TextEditingController nickNameController = TextEditingController();

  final TextEditingController userIdController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    getUserInfo();
  }

  /// 获取用户信息
  Future<void> getUserInfo() async{
    await userStore.getUserInfo();
    nickNameController.text = userStore.userInfo.value.nickname??"";
    userIdController.text = userStore.userInfo.value.userId.toString();
    phoneController.text = userStore.userInfo.value.phone??"";
    headImagePath.value = userStore.userInfo.value.avatarUrl??"";
  }

  /// 选择头像
  Future<void> selectHeadImage(BuildContext context) async{
    // File? file = await ImagePickerUtils.pickImage(context);
    File? file = await ImagePickerUtils.selectPicture(
      context: context,
      withCircleUi: true,
    );

    if(file == null) return;
    headFilePath.value = file.path;
  }

  /// 保存
  Future<void> save() async{
    if(nickNameController.text.isEmpty){
      ToastUtils.showToast(text: "请输入用户名");
      return;
    }
    try {
      ToastUtils.showLoading();
      OssUpdateResponseEntity? uploadRes;
      if(headFilePath.value.isNotEmpty){
        uploadRes = await OssUploadFileUtils.uploadUserFile(
          filePath: headFilePath.value,
        );
        if(uploadRes == null){
          ToastUtils.showToast(text: "上传头像失败");
          return;
        }
      }
      
      Map<String, dynamic> data = {
        "nickname": nickNameController.text,
        "avatar": uploadRes?.key,
      };
      bool res = await UserRequest.editUserInfo(data);
      
      if(!res) return;
      await userStore.getUserInfo();
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
    nickNameController.dispose();
    userIdController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
