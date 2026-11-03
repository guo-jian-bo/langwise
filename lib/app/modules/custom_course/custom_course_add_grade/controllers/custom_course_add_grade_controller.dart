import 'package:api/entities/response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/https/official_course_details.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../utils/utils.dart';
import '../../custom_course_manage_grade/views/custom_course_manage_grade_add_grade_dialog.dart';

class CustomCourseAddGradeController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  CustomCourseAddGradeController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.CUSTOM_COURSE_ADD_GRADE;

  @override
  String get breadcrumbTitle => '英语教材';

  //课程id
  int? courseId;

  //推荐年级的索引
  int? studyGradeIndex;

  String? studyTips;

  int tipNum = 0;

  final ScrollController scrollController = ScrollController();

  final RxList<CourseLevelEntityLevelList?> levelList = <CourseLevelEntityLevelList?>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);

    initServiceData();
  }

  //获取数据
  initServiceData() async {
    try {
      ToastUtils.showLoading();
      CourseLevelEntity? entity = await OfficialCourseDetailsRequest.initCourseInfo();
      courseId = entity!.courseId;
      levelList.value = entity.levelList ?? [];

      bool isHaveLevel = false;
      if (entity.studyTier != null) {
        if (tipNum > 0) return;
        tipNum += 1;
        studyTips = entity.studyTips;

        for (var i = 0; i < (levelList.length); i++) {
          if (levelList[i]?.tier == entity.studyTier) {
            studyGradeIndex = i;
            isHaveLevel = true;
            break;
          }
        }

        if (isHaveLevel) {
          scrollToStudyGrade();
        } else {
          // 没有推荐年级
          final askRes = await AskDialog.showUserAsk(
            context: Get.context!,
            title: '没有检测到相应年级',
            content: "如果想要添加「$studyTips」的教材，请先创建一个新等级",
            cancel: '暂不添加',
            define: "去添加",
          );
          if (askRes) {
            addGrade();
          }
        }
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //滚动到评测的年级位置
  void scrollToStudyGrade() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (studyGradeIndex == null) return;

    double offset = (scrollController.position.maxScrollExtent + scrollController.position.viewportDimension) * (studyGradeIndex! / levelList.length);
    scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  //新增年级
  void addGrade() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomV2CourseLevelCreate)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    Map<String, dynamic>? newGrap = await CustomCourseManageGradeAddGradeDialog.show(
      context: Get.context!,
      courseId: courseId!,
    );
    if (newGrap == null) return;
    String name = newGrap['name'];
    int tier = newGrap['tier'];

    for (var i = 0; i < (levelList.length); i++) {
      if (levelList[i]?.name == name) {
        // 年级已存在, 询问用户是否继续
        bool askRes = await AskDialog.showUserAsk(
          context: Get.context!,
          title: '温馨提示',
          content: '您已经有名称为 $name 的年级，是否继续？',
        );
        if (!askRes) {
          return;
        }
      }
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "courseId": courseId,
        "name": name,
        "tier": tier,
      };
      ResponseEntity? res = await OfficialCourseDetailsRequest.addGrade(data: reqData);
      if (res?.data == null) return;
      ToastUtils.showToast(text: "新增成功", type: ToastType.success);

      //刷新数据
      initServiceData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //添加新教材
  addModule(CourseLevelEntityLevelList? model) {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomCreateCourseModule)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    TagRoutes.toNamed(
      Routes.CUSTOM_COURSE,
      arguments: {
        'courseId': courseId,
        'levelId': model?.levelId,
        'isFromManage': false,
        'fromType': 0,
        'gradeIndex': model?.tier ?? 0,
        'cefr': model?.name,
        'levelName': model?.name,
      },
    );
  }
}
