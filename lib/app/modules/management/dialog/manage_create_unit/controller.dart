import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageCreateUnitController extends BaseController {
  // ------- 复制 ---------
  /// 原始ID
  final TextEditingController copyOriginalIDController = TextEditingController();

  /// 名称
  final TextEditingController copyNameController = TextEditingController();

  /// 按钮
  final RxBool copyButtonFlag = false.obs;

  // ------- 导入 -----
  /// 名称
  final TextEditingController importNameController = TextEditingController();

  /// 学习语言
  final RxInt importLearningLanguages = 0.obs;

  /// 选择文件的路径
  final RxString importFilePath = "".obs;

  /// 按钮
  final RxBool importButtonFlag = false.obs;

  // ------- 手动 -------
  /// 名称
  final TextEditingController createNameController = TextEditingController();

  /// 描述
  final TextEditingController createDesController = TextEditingController();

  /// 学习语言
  final RxInt createLearningLanguages = 0.obs;

  /// 按钮
  final RxBool createButtonFlag = false.obs;

  final RxInt _importSelectLanguageIndex = (-1).obs;

  set importSelectLanguageIndex(value) => _importSelectLanguageIndex.value = value;

  int get importSelectLanguageIndex => _importSelectLanguageIndex.value;

  final RxInt _createSelectLanguageIndex = (-1).obs;

  set createSelectLanguageIndex(value) => _createSelectLanguageIndex.value = value;

  int get createSelectLanguageIndex => _createSelectLanguageIndex.value;

  // cefr
  final RxInt _selectDifficultyIndex = (-1).obs;

  set selectDifficultyIndex(value) => _selectDifficultyIndex.value = value;

  int get selectDifficultyIndex => _selectDifficultyIndex.value;

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  /// 获取复制表单内容是否填写完毕
  void getCopyButtonFlag() {
    copyButtonFlag.value = copyOriginalIDController.text.isNotEmpty && copyNameController.text.isNotEmpty;
  }

  /// 获取导入表单内容是否填写完毕
  void getImportButtonFlag() {
    importButtonFlag.value = importNameController.text.isNotEmpty && importFilePath.isNotEmpty;
  }

  /// 获取手动表单内容是否填写完毕
  void getHandMovementButtonFlag() {
    createButtonFlag.value = createNameController.text.isNotEmpty &&
        createDesController.text.isNotEmpty &&
        (createSelectLanguageIndex != -1) &&
        (selectDifficultyIndex != -1);
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

  // 导入模板/设置语言
  void setImportLanguage(int index) {
    importSelectLanguageIndex = index;
  }

  // 手动创建模板/设置语言
  void setCreateLanguage(int index) {
    createSelectLanguageIndex = index;
    print("接收index:$index");
    // 切换语言时, 重置难度水平为-1
    setCreateDifficulty(-1);
    getHandMovementButtonFlag();
    // 重新获取难度等级数据
    getConfig();
  }

  // 难度水平
  void setCreateDifficulty(int index) {
    selectDifficultyIndex = index;
    getHandMovementButtonFlag();
  }

  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
    getHandMovementButtonFlag();
  }

  final GlobalKey dialogKey = GlobalKey();

  /// 难度等级数据
  final List<DifficultieEntity> difficultieList = [];

  @override
  void onInit() {
    super.onInit();
    createSelectLanguageIndex = 0;
    selectAccessIndex = 1;
    getConfig();
  }

  // 难度等级
  Future<void> getConfig() async {
    final ConfigEntity configData = Get.find<ConfigController>().appConfig.value;
    final String languageCode = StaticData.languageList[createSelectLanguageIndex].value;
    final List<DifficultieEntity>? diffList = DifficultieUtils.getDifficultieList(configData, languageCode);
    if (diffList != null && diffList.isNotEmpty) {
      difficultieList.clear();
      difficultieList.addAll(diffList);
    }
    _initData();
  }

  // 复制
  void onCopyUnit() async {
    try {
      final String moduleId = copyOriginalIDController.text.trim();
      if (ObjectUtil.isEmpty(moduleId)) {
        ToastUtils.showManageToast(text: "请输入原单元ID");
        return;
      }

      final String moduleName = copyNameController.text.trim();
      if (ObjectUtil.isEmpty(moduleName)) {
        ToastUtils.showManageToast(text: "请输入原单元名");
        return;
      }

      final response = await UnitUtil.copy(
          uid: moduleId,
          config: RequestConfig(requireToken: true, data: {"name": moduleName}, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "复制单元成功");
        Get.back(result: true);
      } else {
        ToastUtils.showManageToast(text: "复制单元失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "复制单元失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  // 创建
  void onCreateUnit() async {
    try {
      final String moduleName = createNameController.text.trim();
      if (ObjectUtil.isEmpty(moduleName)) {
        ToastUtils.showManageToast(text: "请输入单元名");
        return;
      }

      final String des = createDesController.text.trim();
      if (ObjectUtil.isEmpty(des)) {
        ToastUtils.showManageToast(text: "请输入单元描述");
        return;
      }

      // 语言
      String? language;
      try {
        language = CommonUtil.languageKeys[createSelectLanguageIndex];
      } catch (e) {
        print('---语言e:$e---');
      }
      print('---语言language:$language---');

      if (language == null) {
        ToastUtils.showManageToast(text: "请选择语言");
        return;
      }

      if (selectDifficultyIndex == -1) {
        ToastUtils.showManageToast(text: "请选择难度等级", containerKey: dialogKey);
        return;
      }

      final response = await UnitUtil.create(
          config: RequestConfig(
              requireToken: true,
              data: {
                "name": moduleName,
                "language": language,
                "description": des,
                "difficultyLevel": difficultieList[selectDifficultyIndex].level,
                "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value
              },
              cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "创建单元成功");
        Get.back(result: true);
      } else {
        ToastUtils.showManageToast(text: "创建单元失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "创建单元失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  void _initData() {
    update(["manage_create_level", "buildHandMovement"]);
  }

  // 上下架title
  String get newAccessName {
    return StaticData.getOnOffShelfForCreateOrEdit(selectAccessIndex);
  }

  @override
  void onClose() {
    super.onClose();
    copyOriginalIDController.dispose();
    copyNameController.dispose();
    createNameController.dispose();
    createDesController.dispose();
    importNameController.dispose();
  }
}
