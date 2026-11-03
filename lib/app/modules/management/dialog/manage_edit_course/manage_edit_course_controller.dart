import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditCourseController extends BaseController {
  final CourseResponseEntity courseEntity;

  ManageEditCourseController(this.courseEntity);

  // ------- 手动 -------
  ///名称
  final TextEditingController handMovementName = TextEditingController();

  /// 学习语言
  final RxInt handMovementLearningLanguages = 0.obs;

  /// 按钮
  final RxBool handMovementButtonFlag = false.obs;

  final RxInt _createSelectLanguageIndex = (-1).obs;

  set createSelectLanguageIndex(value) => _createSelectLanguageIndex.value = value;

  int get createSelectLanguageIndex => _createSelectLanguageIndex.value;

  /// 封面
  String? _coverKey;

  @override
  void onInit() {
    super.onInit();
    handMovementName.text = courseEntity.name?.trim() ?? '';
    if (courseEntity.language != null) {
      for (int i = 0; i < CommonUtil.language.length; i++) {
        final Map<String, String> r = CommonUtil.language[i];
        if (r[courseEntity.language] != null) {
          createSelectLanguageIndex = i;
        }
      }
    }
    _coverKey = courseEntity.cover;
    getHandMovementButtonFlag();
    print('---$courseEntity---');
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  /// 获取手动表单内容是否填写完毕
  void getHandMovementButtonFlag() {
    handMovementButtonFlag.value = handMovementName.text.isNotEmpty && _coverKey != null && _coverKey!.isNotEmpty;
  }

  // 手动创建/语言title
  String get createLanguageTitle {
    String title = '';
    try {
      title = CommonUtil.languageValues[createSelectLanguageIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

  // 手动创建模板/设置语言
  void setCreateLanguage(int index) {
    createSelectLanguageIndex = index;
    handMovementLearningLanguages();
  }

  // 确定
  void onConfirm() {
    final String courseName = handMovementName.text.trim();
    if (ObjectUtil.isEmpty(courseName)) {
      ToastUtils.showManageToast(text: "请输入课程名");
      return;
    }

    if (ObjectUtil.isEmpty(_coverKey)) {
      ToastUtils.showManageToast(text: "请选择封面");
      return;
    }

    Get.back(result: {
      "name": courseName,
      "cover": _coverKey,
    });
  }

  void _initData() {
    update(["manage_edit_course"]);
  }

// 添加封面
  Future<String?> onAddCover(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (_) => Container(),
    );

    final String? path = await onPickFile(context: context);

    if (path == null) {
      Get.back();
      return null;
    }

    Get.back();

    onGetToken(path, callback: (String? key, int? size) {
      _coverKey = key;
      debugPrint('--key: $key--');
      getHandMovementButtonFlag();
      // 更新UI
      _initData();
    });
    return path;
  }

  @override
  void onClose() {
    super.onClose();
    handMovementName.dispose();
  }
}
