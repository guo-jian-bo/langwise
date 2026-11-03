import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditLessonController extends BaseController {
  final LessonResponseEntity lessonEntity;

  ManageEditLessonController(this.lessonEntity);

  // ------- 手动 -------
  /// 名称
  final TextEditingController createNameController = TextEditingController();

  /// 描述
  final TextEditingController createDesController = TextEditingController();

  /// 学习语言
  final RxInt createLearningLanguages = 0.obs;

  /// 按钮
  final RxBool createButtonFlag = false.obs;

  final RxInt _createSelectLanguageIndex = (-1).obs;

  set createSelectLanguageIndex(value) => _createSelectLanguageIndex.value = value;

  int get createSelectLanguageIndex => _createSelectLanguageIndex.value;

  /// 获取手动表单内容是否填写完毕
  void getHandMovementButtonFlag() {
    createButtonFlag.value = createNameController.text.isNotEmpty && createDesController.text.isNotEmpty;
  }

  @override
  void onInit() {
    super.onInit();
    createNameController.text = lessonEntity.name?.trim() ?? '';
    createDesController.text = lessonEntity.description?.trim() ?? '';
    if (lessonEntity.language != null) {
      for (int i = 0; i < CommonUtil.language.length; i++) {
        final Map<String, String> r = CommonUtil.language[i];
        if (r[lessonEntity.language] != null) {
          createSelectLanguageIndex = i;
        }
      }
    }
    getHandMovementButtonFlag();
    print('---$lessonEntity---');
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
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

  // 确定
  void onConfirm() async {
    try {
      final String lessonName = createNameController.text.trim();
      if (ObjectUtil.isEmpty(lessonName)) {
        ToastUtils.showManageToast(text: "请输入课时名称");
        return;
      }

      final String des = createDesController.text.trim();
      if (ObjectUtil.isEmpty(des)) {
        ToastUtils.showManageToast(text: "请输入课时描述");
        return;
      }

      final response = await LessonUtil.edit(
          uid: lessonEntity.uid.toString(),
          config: RequestConfig(
              requireToken: true, data: {"name": lessonName, "description": des}, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "编辑课时成功");
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: "编辑课时失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "编辑课时失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void _initData() {
    update(["manage_edit_lesson"]);
  }

  @override
  void onClose() {
    super.onClose();
    createNameController.dispose();
    createDesController.dispose();
  }
}
