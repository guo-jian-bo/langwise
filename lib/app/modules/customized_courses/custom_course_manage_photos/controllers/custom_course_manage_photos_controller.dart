import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/official_course_details/controllers/official_course_details_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/https/customized_courses.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/camera_macos_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/camera_windows_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/delete_dialog.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../models/custom_course_manage_photos_model.dart';
import '../models/custom_course_manage_photos_response_entity.dart';

class CustomCourseManagePhotosController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;
  CustomCourseManagePhotosController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.CUSTOM_COURSE_MANAGE_PHOTOS;

  @override
  String get breadcrumbTitle => '管理书页';

  // 传进来的参数
  int? courseId;
  int? levelId;
  int? moduleId;
  bool fromCourseDetailPage = true;
  bool isFromShoot = false; //是否是从拍摄页面过来的

  // 是否显示过提示框
  RxBool isShowTip = false.obs;

  // 拍摄的单词表图片缓存路径
  RxList<CustomCourseManagePhotosModel> imagesList = <CustomCourseManagePhotosModel>[].obs;

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);

    scrollController = ScrollController();

    // 初始化数据
    if (Get.arguments != null) {
      courseId = Get.arguments['courseId'];
      levelId = Get.arguments['levelId'];
      moduleId = Get.arguments['moduleId'];
      fromCourseDetailPage = Get.arguments['fromCourseDetailPage'] ?? true;
      isFromShoot = Get.arguments['isFromShoot'] ?? false;
      imagesList.value = Get.arguments['imagesList'] ?? [];
    }

    //如果保存过图片，需要从服务器获取已保存的图片
    if (!isFromShoot) {
      initServiceData();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  //滚动到最后位置
  void scrollToLast() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  //返回
  void back() async {
    if (fromCourseDetailPage) {
      final officialCourseDetailsController =
          TagRoutes.findLast<OfficialCourseDetailsController>(Routes.OFFICIAL_COURSE_DETAILS);
      if (officialCourseDetailsController != null) {
        await officialCourseDetailsController.getModuleList(isPlan: true, isLoading: true);
      }
      Get.until((route) => route.settings.name == Routes.OFFICIAL_COURSE_DETAILS);
    } else {
      TagRoutes.offNamedUntil(
        Routes.OFFICIAL_COURSE_DETAILS,
        ModalRoute.withName(Routes.APPLICATION),
        arguments: {
          "courseId": courseId,
          "levelId": levelId,
          "moduleId": moduleId,
          "goCustomCourseProgress": false,
        },
      );
    }
  }

  //新增单词表
  void addImageItem() async {
    bool isCameraPermission = await PermissionUtils.camera(Get.context!);
    if (!isCameraPermission) {
      return;
    }

    Map<String, dynamic> params = {
      "moduleId": moduleId,
      "courseId": courseId,
      "levelId": levelId,
      "imagesList": imagesList,
      "fromCourseDetailPage": fromCourseDetailPage,
    };
    if (Platform.isMacOS) {
      String? deviceId = await CameraMacOSCustomCurseDialog.show(
        context: Get.context!,
      );
      params["deviceId"] = deviceId;
    } else if (Platform.isWindows) {
      CameraDescription? cameraDescription = await CameraWindowsCustomCurseDialog.show(
        context: Get.context!,
      );
      params["cameraDescription"] = cameraDescription;
    }
    TagRoutes.offNamed(
      Routes.CUSTOM_COURSE_SHOOT_WORDS,
      arguments: params,
    );
  }

  //交换图片位置
  void changeCardPosition(int oldIndex, int newIndex) {
    if (oldIndex >= imagesList.length || newIndex > imagesList.length) return;

    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    List<CustomCourseManagePhotosModel> tempList = [];
    tempList.addAll(imagesList);

    final item = tempList.removeAt(oldIndex);
    tempList.insert(newIndex, item);
    imagesList.value = tempList;
  }

  //删除图片
  void deleteItem(int index) {
    imagesList.removeAt(index);
  }

  //重拍本书---跳转拍摄界面
  void reshoot() async {
    //重拍确认框
    bool res = await DeleteDialog.show(
      context: Get.context!,
      title: "重新拍这本书",
      subTitle: "确定要清空当前已添加的所有页面，并重新拍摄吗？",
      content: "提示：此操作不可逆！",
      subContent: "点击“确认”后，当前所有已拍摄但未保存的页面将被永久删除。",
      confirmText: "清空并重拍",
    );
    if (!res) return;

    //请求重拍本书接口
    final result = await CustomizedCoursesRequest.reshootWordList(moduleId!);
    if (result == false) {
      AskDialog.showUserAsk(
        context: Get.context!,
        content: "网络错误，请重试。",
        define: "确认",
        showCancel: false,
      );
      return;
    }

    //跳转到拍摄界面
    bool isCameraPermission = await PermissionUtils.camera(Get.context!);
    if (!isCameraPermission) {
      return;
    }

    Map<String, dynamic> params = {
      "moduleId": moduleId,
      "fromCourseDetailPage": fromCourseDetailPage,
    };
    if (Platform.isMacOS) {
      String? deviceId = await CameraMacOSCustomCurseDialog.show(
        context: Get.context!,
      );
      params["deviceId"] = deviceId;
    } else if (Platform.isWindows) {
      CameraDescription? cameraDescription = await CameraWindowsCustomCurseDialog.show(
        context: Get.context!,
      );
      params["cameraDescription"] = cameraDescription;
    }
    TagRoutes.offNamed(
      Routes.CUSTOM_COURSE_SHOOT_WORDS,
      arguments: params,
    );
  }

  //保存退出事件
  void saveExit() async {
    try {
      ToastUtils.showLoading();
      final uploadTasks = _createUploadTasks();
      final results = await Future.wait(uploadTasks);
      bool isUploadSuccess = await _validateUploadResults(results);
      if (!isUploadSuccess) {
        final askRes = await AskDialog.showUserAsk(
          context: Get.context!,
          content: "图片上传失败，请重试。",
          define: "确认",
        );
        if (!askRes) {
          back();
        }
        return;
      }

      bool isSaveSuccess = await _saveCustomCursesImage();
      if (!isSaveSuccess) return;

      final askRes = await AskDialog.showUserAsk(
        title: '进度已保存',
        context: Get.context!,
        content: "您当前添加的所有书本页面均已保存。\n下次返回时，您可以从当前状态继续添加或调整页面。",
        define: "确认退出",
        cancel: "继续调整",
      );
      if (askRes) {
        back();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //开始识别事件
  void startRecognize() async {
    final askRes = await AskDialog.showUserAsk(
      title: '开始识别前，请确认',
      context: Get.context!,
      content: "为保证识别准确，请确保当前只保留了【按单元/Module顺序】的词汇表页面。\n请再次检查，并移除其他所有无关页面\n例如：\n\u2022 A-Z 字母顺序的总索引\n\u2022 语法总结、不规则动词表\n\u2022 封面、目录、空白页",
      define: "我已检查,开始识别",
      cancel: "返回修改",
    );
    if (!askRes) {
      return;
    }

    try {
      ToastUtils.showLoading();
      final uploadTasks = _createUploadTasks();
      final results = await Future.wait(uploadTasks);
      bool isUploadSuccess = await _validateUploadResults(results);
      if (!isUploadSuccess) {
        final askRes = await AskDialog.showUserAsk(
          context: Get.context!,
          content: "图片上传失败，请重试。",
          define: "确认",
        );
        if (!askRes) {
          back();
        }
        return;
      }

      await _saveCustomCursesImage();

      final result = await CustomizedCoursesRequest.recognizeCourseImagesList(moduleId!);
      if (result == false) {
        final askRes = await AskDialog.showUserAsk(
          context: Get.context!,
          content: "识别失败，请重试。",
          define: "确认",
        );
        if (!askRes) {
          back();
        }
        return;
      }

      back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 创建上传任务列表
  List<Future<bool>> _createUploadTasks() {
    List<Future<bool>> uploadTasks = [];

    for (int i = 0; i < imagesList.length; i++) {
      if (imagesList[i].key == null) {
        final imagePath = imagesList[i].imageUrl!;
        final index = i;
        uploadTasks.add(_uploadSingleImage(imagePath, index));
      }
    }
    return uploadTasks;
  }

  // 上传单个图片
  Future<bool> _uploadSingleImage(String imagePath, int index) async {
    final record = await OssUploadFileUtils.uploadUserFile(filePath: imagePath);
    if (record == null || record.key == null || record.url == null) {
      return false; // 上传失败
    } else {
      imagesList[index].key = record.key;
      imagesList[index].imageUrl = record.url;
      return true;
    }
  }

  // 验证上传结果
  Future<bool> _validateUploadResults(List<bool> results) async {
    for (int i = 0; i < results.length; i++) {
      if (!results[i]) {
        return false;
      }
    }
    return true;
  }

  //保存自定义课程已编辑的图片
  Future<bool> _saveCustomCursesImage() async {
    Map<String, dynamic> reqData = {'bookPageList': imagesList.map((model) => model.toJson()).toList()};
    final result = await CustomizedCoursesRequest.saveCourseImagesList(reqData, moduleId!);
    if (result == false) {
      final askRes = await AskDialog.showUserAsk(
        context: Get.context!,
        content: "保存失败，请重试。",
        define: "确认",
      );
      if (askRes) {
        return false;
      } else {
        back();
        return false;
      }
    }
    return true;
  }

  //获取已保存的图片
  initServiceData() async {
    try {
      ToastUtils.showLoading();
      CustomCourseManagePhotosResponseEntity? imageEntity = await CustomizedCoursesRequest.getCourseImagesList({}, moduleId!);
      if (imageEntity == null) return;
      imagesList.value = imageEntity.bookPageList ?? [];
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
