import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/level.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditLevelController extends BaseController {
  final LevelResponseEntity levelEntity;

  ManageEditLevelController(this.levelEntity);

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

  // 上下架
  final RxInt _selectAccessIndex = (0).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  int? createTierTitle;

  /// 获取手动表单内容是否填写完毕
  void getHandMovementButtonFlag() {
    createButtonFlag.value = createNameController.text.isNotEmpty && createDesController.text.isNotEmpty && (createSelectLanguageIndex != -1);
  }

  final GlobalKey dialogKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    createNameController.text = levelEntity.name?.trim() ?? '';
    createTierTitle = levelEntity.tier;
    createDesController.text = levelEntity.description?.trim() ?? '';
    if (levelEntity.language != null) {
      for (int i = 0; i < CommonUtil.language.length; i++) {
        final Map<String, String> r = CommonUtil.language[i];
        if (r[levelEntity.language] != null) {
          createSelectLanguageIndex = i;
        }
      }
    }

    try {
      selectAccessIndex = StaticData.getOnOffShelfForCreateOrEditIndex(levelEntity.access) ?? 0;
    } catch (e) {
      print(e);
    }

    getHandMovementButtonFlag();
    print('---$levelEntity---');
  }

  // 确定
  void onConfirm() async {
    try {
      final String moduleName = createNameController.text.trim();
      if (ObjectUtil.isEmpty(moduleName)) {
        ToastUtils.showManageToast(text: "请输入级别名");
        return;
      }

      final String des = createDesController.text.trim();
      if (ObjectUtil.isEmpty(des)) {
        ToastUtils.showManageToast(text: "请输入级别描述");
        return;
      }

      if (selectAccessIndex == -1) {
        ToastUtils.showManageToast(text: "请选择上下架状态", containerKey: dialogKey);
        return;
      }

      if (createTierTitle == null) {
        ToastUtils.showManageToast(text: "请选择级别等级");
        return;
      }

      final response = await LevelUtil.edit(
          uid: levelEntity.uid.toString(),
          config: RequestConfig(
              requireToken: true,
              data: {"name": moduleName, "description": des, "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value, "tier": createTierTitle},
              cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "编辑级别成功");

        // 通知上层页面需要刷新数据
        CourseUpdateStore.to.notifyCourseUpdated();
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: "编辑级别失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "编辑级别失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  void _initData() {
    update(["manage_edit_level"]);
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

  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
    getHandMovementButtonFlag();
  }

  // 上下架title
  String get newAccessName {
    return StaticData.getOnOffShelfForCreateOrEdit(selectAccessIndex);
  }

  @override
  void onClose() {
    super.onClose();
    createNameController.dispose();
    createDesController.dispose();
  }
}
