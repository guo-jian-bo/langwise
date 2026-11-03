import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_level_table/view.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageCreateRelevanceLevelController extends BaseController {
  final int courseId;
  final String? language;
  final int initCreateWay;

  int? createTierTitle;

  ManageCreateRelevanceLevelController(this.courseId, this.language, this.initCreateWay);

  // ------- 复制 ---------
  /// 原始ID
  final TextEditingController copyOriginalIDController = TextEditingController();

  /// 名称
  final TextEditingController copyNameController = TextEditingController();

  /// 按钮
  final RxBool copyButtonFlag = false.obs;

  final RxInt _copySelectLanguageIndex = (-1).obs;

  set copySelectLanguageIndex(value) => _copySelectLanguageIndex.value = value;

  int get copySelectLanguageIndex => _copySelectLanguageIndex.value;

  // ------- 导入 -----
  /// 学习语言
  final RxInt importLearningLanguages = 0.obs;

  /// 选择文件的路径
  final RxString importFilePath = "".obs;

  /// 按钮
  final RxBool importButtonFlag = false.obs;

  // ------- 手动 -------
  ///名称
  final TextEditingController createNameController = TextEditingController();

  final TextEditingController createDesController = TextEditingController();

  /// 语言
  final TextEditingController createLanguageController = TextEditingController();

  /// 学习语言
  final RxInt createLearningLanguages = 0.obs;

  /// 按钮
  final RxBool createButtonFlag = false.obs;

  final RxInt _createSelectLanguageIndex = (-1).obs;

  set createSelectLanguageIndex(value) => _createSelectLanguageIndex.value = value;

  int get createSelectLanguageIndex => _createSelectLanguageIndex.value;

  // 选中的ModuleResponseEntity
  final RxList<LevelResponseEntity> _selectedRows = <LevelResponseEntity>[].obs;

  set selectedRows(value) => _selectedRows.value = value;

  List<LevelResponseEntity> get selectedRows => _selectedRows;

  // 创建/语言是否只读
  bool get createLanguageReadOnly => language != null;

  @override
  void onInit() {
    super.onInit();
    createWay.value = initCreateWay;
    if (language != null) {
      for (int i = 0; i < CommonUtil.language.length; i++) {
        final Map<String, String> r = CommonUtil.language[i];
        if (r[language] != null) {
          setCreateLanguage(i);
        }
      }
    }
  }

  /// 获取复制表单内容是否填写完毕
  void getCopyButtonFlag() {
    copyButtonFlag.value = copyOriginalIDController.text.isNotEmpty && copyNameController.text.isNotEmpty;
  }

  /// 获取手动表单内容是否填写完毕
  void getHandMovementButtonFlag() {
    createButtonFlag.value = createNameController.text.isNotEmpty;
  }

  // 导入模板/语言title
  String get copyLanguageTitle {
    String title = '';
    try {
      title = CommonUtil.languageValues[copySelectLanguageIndex];
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
    copySelectLanguageIndex = index;
    getCopyButtonFlag();
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

  // 复制级别
  void onCopyLevel() async {
    try {
      final String levelId = copyOriginalIDController.text.trim();
      if (ObjectUtil.isEmpty(levelId)) {
        ToastUtils.showManageToast(text: "请输入原级别ID");
        return;
      }

      final String levelName = copyNameController.text.trim();
      if (ObjectUtil.isEmpty(levelName)) {
        ToastUtils.showManageToast(text: "请输入原级别名");
        return;
      }

      final response = await LevelUtil.copy(uid: levelId, config: RequestConfig(requireToken: true, data: {"name": levelName, "courseId": courseId}, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "复制级别成功");
        Get.back(result: [response.data]);
      } else {
        ToastUtils.showManageToast(text: "复制级别失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "复制级别失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  // 创建级别
  void onCreateLevel() async {
    try {
      final String levelName = createNameController.text.trim();
      if (ObjectUtil.isEmpty(levelName)) {
        ToastUtils.showManageToast(text: "请输入级别名");
        return;
      }

      final String des = createDesController.text.trim();
      if (ObjectUtil.isEmpty(des)) {
        ToastUtils.showManageToast(text: "请输入级别描述");
        return;
      }

      // 语言
      String? language;
      try {
        language = CommonUtil.languageKeys[createSelectLanguageIndex];
      } catch (e) {
        print('---语言e:$e---');
      }

      if (language == null) {
        ToastUtils.showManageToast(text: "请选择语言");
        return;
      }

      if (createTierTitle == null) {
        ToastUtils.showManageToast(text: "请选择级别等级");
        return;
      }

      final response = await LevelUtil.create(
          config: RequestConfig(
              requireToken: true, data: {"name": levelName, "language": language, "description": des, "courseId": courseId, "tier": createTierTitle}, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "创建级别成功");
        Get.back(result: [response.data]);
      } else {
        ToastUtils.showManageToast(text: "创建级别失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "创建级别失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  // 关联级别
  void onRelevanceLevel() async {
    try {
      final List<int> ids = selectedRows.map((element) => element.uid).toList();
      final response = await CourseUtil.relation(uid: courseId.toString(), config: RequestConfig(requireToken: true, data: {"levelIds": ids}, cancelToken: cancelToken));
      if (response.data?.list != null) {
        ToastUtils.showManageToast(text: "关联级别成功");
        Get.back(result: response.data!.list);
      } else {
        ToastUtils.showManageToast(text: "关联级别失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "关联级别失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  void _initData() {
    update(["manage_create_relevance_level"]);
  }

  // 添加级别
  void addModule(BuildContext context, {final bool Function(LevelResponseEntity)? dataDisableCallback}) {
    print("---selectedRows:${selectedRows.length}---");
    ManageSelectLevelTablePageManager.show(context: context, defaultDessert: selectedRows, dataDisableCallback: dataDisableCallback)
        .then((List<LevelResponseEntity>? value) {
      if (value != null && value.isNotEmpty) {
        // ToDo 回显数据
        selectedRows = value;
        print("回显数据selectedRows:${selectedRows.length}");
      }
    });
  }

  // 移除级别
  void removeModule(int index) {
    selectedRows.removeAt(index);
    _selectedRows.refresh();
  }

  @override
  void onClose() {
    super.onClose();
    copyOriginalIDController.dispose();
    copyNameController.dispose();
    createNameController.dispose();
    selectedRows.clear();
  }
}
