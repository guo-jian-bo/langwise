import 'package:api/entities/response.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/customized_courses_l_m_entity.dart';
import 'package:langwise/common/https/official_course_details.dart';
import 'package:langwise/utils/toast_utils.dart';

class CustomCourseManageGradeSortController extends GetxController {
  int? courseId;

  final RxList<CustomizedCoursesLMEntityListLevelList?> levelList =
      <CustomizedCoursesLMEntityListLevelList?>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      courseId = Get.arguments['courseId'];
    }

    initServiceData();
  }

  //交换位置
  void swap(int oldIndex, int newIndex) async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        'levelId': levelList[oldIndex]?.uid,
        'target': newIndex,
        'courseId': courseId!,
      };
      ResponseEntity? res = await OfficialCourseDetailsRequest.moveModule(
        parameters: {
          'courseId': courseId!,
        },
        data: reqData,
      );
      if (res == null) return;
      final item = levelList.removeAt(oldIndex);
      levelList.insert(newIndex, item);
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //获取数据
  initServiceData() async {
    if (courseId == null) return;
    try {
      ToastUtils.showLoading();

      CustomizedCoursesLMEntity? entity =
          await OfficialCourseDetailsRequest.editCourseInfo(courseId!);
      if (entity == null) return;

      levelList.value = entity.list!.first!.levelList ?? [];
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
