import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/customized_courses/custom_course_manage_photos/models/custom_course_manage_photos_model.dart';
import 'package:langwise/app/modules/official_course_details/controllers/official_course_details_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/utils.dart';

class CustomCourseShootWordsController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;
  CustomCourseShootWordsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.CUSTOM_COURSE_SHOOT_WORDS;

  @override
  String get breadcrumbTitle => '拍摄词汇表';

  ///界面路由栈里面是否有课程详情页
  bool fromCourseDetailPage = true;
  int? moduleId;
  int? courseId;
  int? levelId;
  String? deviceId;
  CameraDescription? cameraDescription;

  // 是否显示过提示框
  RxBool isShownTip = false.obs;

  // 图片列表
  List<CustomCourseManagePhotosModel> imagesList = [];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    moduleId = Get.arguments['moduleId'];
    courseId = Get.arguments['courseId'];
    levelId = Get.arguments['levelId'];
    deviceId = Get.arguments['deviceId'];
    imagesList = Get.arguments['imagesList'] ?? [];
    cameraDescription = Get.arguments['cameraDescription'];
    fromCourseDetailPage = Get.arguments['fromCourseDetailPage'] ?? true;
  }

  ///返回按钮事件
  void back() async {
    //返回确认框
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      title: '书页尚未保存',
      content: "现在退出，您拍摄的照片将会丢失。是否继续退出？",
      cancel: '直接退出',
      define: "返回修改",
    );
    if (askRes) {
      return;
    }

    final officialCourseDetailsController =
        TagRoutes.findLast<OfficialCourseDetailsController>(Routes.OFFICIAL_COURSE_DETAILS);
    if (officialCourseDetailsController != null) {
      await officialCourseDetailsController.getModuleList(isPlan: true, isLoading: false);
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

  //添加拍摄图片
  void addImage(String imagePath) {
    CustomCourseManagePhotosModel model = CustomCourseManagePhotosModel(imageUrl: imagePath);
    imagesList.add(model);
  }

  /// 将拍摄的图片传递给管理页面进行处理
  void navigateToManagePhotos() {
    TagRoutes.offNamed(
      Routes.CUSTOM_COURSE_MANAGE_PHOTOS,
      arguments: {
        "moduleId": moduleId,
        "courseId": courseId,
        "levelId": levelId,
        "imagesList": imagesList,
        'isFromShoot': true,
        'fromCourseDetailPage': fromCourseDetailPage,
      },
    );
  }
}
