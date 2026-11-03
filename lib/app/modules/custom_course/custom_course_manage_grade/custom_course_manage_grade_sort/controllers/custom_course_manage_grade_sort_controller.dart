import 'package:api/entities/response.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/https/official_course_details.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../../utils/utils.dart';

class CustomCourseManageGradeSortController extends GetxController {
  final int? initialCourseId;
  final List<CourseLevelEntityLevelList?> initialLevelList;
  final bool shouldDisableAutoSortOnSave;
  CustomCourseManageGradeSortController({
    this.initialCourseId,
    this.initialLevelList = const <CourseLevelEntityLevelList?>[],
    this.shouldDisableAutoSortOnSave = false,
  });

  int? courseId;

  final RxList<CourseLevelEntityLevelList?> levelList =
      <CourseLevelEntityLevelList?>[].obs;
  final RxBool hasChanges = false.obs;
  final RxBool isSaving = false.obs;
  final List<_SortOperation> _pendingOperations = <_SortOperation>[];

  @override
  void onInit() {
    super.onInit();
    courseId = initialCourseId;
    levelList.value = initialLevelList
        .map(
          (item) => item == null
              ? null
              : CourseLevelEntityLevelList.fromJson(item.toJson()),
        )
        .toList();
    _pendingOperations.clear();
    hasChanges.value = false;
  }

  //交换位置
  void swap(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= levelList.length) return;
    if (newIndex < 0 || newIndex >= levelList.length) return;
    final item = levelList.removeAt(oldIndex);
    levelList.insert(newIndex, item);
    final int? levelId = item?.levelId;
    if (levelId != null) {
      _pendingOperations.add(
        _SortOperation(levelId: levelId, target: newIndex),
      );
    }
    hasChanges.value = true;
    levelList.refresh();
  }

  Future<bool> saveSort() async {
    if (courseId == null) return false;
    if (_pendingOperations.isEmpty) return false;
    try {
      isSaving.value = true;
      ToastUtils.showLoading();
      if (shouldDisableAutoSortOnSave) {
        if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomCourseAutoSort)) {
          ToastUtils.showToast(text: "无权限");
          return false;
        }
        final ResponseEntity? autoSortRes = await OfficialCourseDetailsRequest.autoSort(
          courseId!,
          parameters: {'autoSort': false},
        );
        if (autoSortRes == null) return false;
      }

      if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomV3CourseOrder)) {
        ToastUtils.showToast(text: "无权限");
        return false;
      }

      for (final _SortOperation operation in _pendingOperations) {
        final ResponseEntity? res = await OfficialCourseDetailsRequest.moveModule(
          parameters: {
            'courseId': courseId!,
          },
          data: {
            'levelId': operation.levelId,
            'target': operation.target,
            'courseId': courseId!,
          },
        );
        if (res == null) return false;
      }
      _pendingOperations.clear();
      hasChanges.value = false;
      ToastUtils.showToast(text: "排序保存成功", type: ToastType.success);
      return true;
    } finally {
      isSaving.value = false;
      ToastUtils.hideLoading();
    }
  }
}

class _SortOperation {
  final int levelId;
  final int target;

  _SortOperation({
    required this.levelId,
    required this.target,
  });
}
