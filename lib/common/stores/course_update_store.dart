import 'package:get/get.dart';

/// 课程更新状态管理服务
/// 用于协调课程、模块、单元之间的数据更新通知
class CourseUpdateStore extends GetxService {
  static CourseUpdateStore get to => Get.find<CourseUpdateStore>();

  /// 模块列表是否需要刷新
  final RxBool needRefreshModuleList = false.obs;
  
  /// 课程列表是否需要刷新
  final RxBool needRefreshCourseList = false.obs;

  /// 通知单元更新，需要刷新上层模块列表和课程列表
  void notifyUnitUpdated() {
    needRefreshModuleList.value = true;
    needRefreshCourseList.value = true;
  }
  
  /// 通知模块更新，只需要刷新课程列表
  void notifyCourseUpdated() {
    needRefreshCourseList.value = true;
  }

  /// 模块列表已刷新，重置标记
  void moduleListRefreshed() {
    needRefreshModuleList.value = false;
  }
  
  /// 课程列表已刷新，重置标记
  void courseListRefreshed() {
    needRefreshCourseList.value = false;
  }
}
