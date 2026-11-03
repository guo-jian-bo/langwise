import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageCreateCourseController extends BaseController {
  // ------- 复制 ---------
  /// 原始ID
  final TextEditingController copyOriginalIDController = TextEditingController();

  /// 名称
  final TextEditingController copyNameController = TextEditingController();

  /// 按钮
  final RxBool copyButtonFlag = false.obs;

  // ------- 导入 -----
  /// 名称
  final TextEditingController importName = TextEditingController();

  /// 学习语言
  final RxInt importLearningLanguages = 0.obs;

  /// 选择文件的路径
  final RxString importFilePath = "".obs;

  /// 按钮
  final RxBool importButtonFlag = false.obs;

  // ------- 手动 -------
  ///名称
  final TextEditingController handMovementName = TextEditingController();

  /// 学习语言
  final RxInt handMovementLearningLanguages = 0.obs;

  /// 按钮
  final RxBool handMovementButtonFlag = false.obs;

  final RxInt _importSelectLanguageIndex = (-1).obs;

  set importSelectLanguageIndex(value) => _importSelectLanguageIndex.value = value;

  int get importSelectLanguageIndex => _importSelectLanguageIndex.value;

  final RxInt _createSelectLanguageIndex = (-1).obs;

  set createSelectLanguageIndex(value) => _createSelectLanguageIndex.value = value;

  int get createSelectLanguageIndex => _createSelectLanguageIndex.value;

  /// 封面
  String? _coverKey;

  /// 获取复制表单内容是否填写完毕
  void getCopyButtonFlag() {
    copyButtonFlag.value = copyOriginalIDController.text.isNotEmpty && copyNameController.text.isNotEmpty;
  }

  /// 获取导入表单内容是否填写完毕
  void getImportButtonFlag() {
    importButtonFlag.value = importName.text.isNotEmpty && importFilePath.isNotEmpty;
  }

  /// 获取手动表单内容是否填写完毕
  void getHandMovementButtonFlag() {
    handMovementButtonFlag.value = handMovementName.text.isNotEmpty && _coverKey != null && _coverKey!.isNotEmpty;
  }

  // 导入模板/语言title
  String get importLanguageTitle {
    String title = '';
    try {
      title = CommonUtil.languageValues[importSelectLanguageIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

  // 导入模板/设置语言
  void setImportLanguage(int index) {
    importSelectLanguageIndex = index;
    getImportButtonFlag();
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
    getHandMovementButtonFlag();
  }

  // 复制课程
  void onCopyCourse() async {
    try {
      final String courseId = copyOriginalIDController.text.trim();
      if (ObjectUtil.isEmpty(courseId)) {
        ToastUtils.showManageToast(text: "请输入原课程ID");
        return;
      }

      final String courseName = copyNameController.text.trim();
      if (ObjectUtil.isEmpty(courseName)) {
        ToastUtils.showManageToast(text: "请输入原课程名");
        return;
      }

      final response = await CourseUtil.copy(
          uid: courseId,
          config: RequestConfig(requireToken: true, data: {"name": courseName}, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "复制课程成功");
        Get.back(result: true);
      } else {
        ToastUtils.showManageToast(text: "复制课程失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "复制课程失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  // 创建课程
  void onCreateCourse() async {
    try {
      final String courseName = handMovementName.text.trim();
      if (ObjectUtil.isEmpty(courseName)) {
        ToastUtils.showManageToast(text: "请输入课程名");
        return;
      }

      // 语言
      String? language;
      try {
        language = CommonUtil.languageKeys[createSelectLanguageIndex];
      } catch (e) {
        print('---语言e:$e---');
      }

      final response = await CourseUtil.create(
          config: RequestConfig(
              requireToken: true,
              data: {
                "name": courseName,
                "language": language,
                "cover": _coverKey,
                "description": null,
              },
              cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "创建课程成功");
        Get.back(result: true);
      } else {
        ToastUtils.showManageToast(text: "创建课程失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "创建课程失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  void _initData() {
    update(["manage_create_course"]);
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
    copyOriginalIDController.dispose();
    copyNameController.dispose();
    handMovementName.dispose();
  }
}
