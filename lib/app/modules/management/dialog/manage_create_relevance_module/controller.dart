import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_module_table/view.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageCreateRelevanceModuleController extends BaseController {
  final int levelUid;
  final String? language;

  ManageCreateRelevanceModuleController(this.levelUid, this.language);

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

  /// 选择的locale
  final RxString createLocale = "".obs;

  /// 按钮
  final RxBool createButtonFlag = false.obs;

  final RxInt _createSelectLanguageIndex = (-1).obs;

  set createSelectLanguageIndex(value) => _createSelectLanguageIndex.value = value;

  int get createSelectLanguageIndex => _createSelectLanguageIndex.value;

  /// 封面
  String? _coverKey;

  // 选中的ModuleResponseEntity
  final RxList<ModuleResponseEntity> _selectedRows = <ModuleResponseEntity>[].obs;

  set selectedRows(value) => _selectedRows.value = value;

  List<ModuleResponseEntity> get selectedRows => _selectedRows;

  /// 获取复制表单内容是否填写完毕
  void getCopyButtonFlag() {
    copyButtonFlag.value = copyOriginalIDController.text.isNotEmpty && copyNameController.text.isNotEmpty;
  }

  /// 获取手动表单内容是否填写完毕
  void getHandMovementButtonFlag() {
    createButtonFlag.value = createNameController.text.isNotEmpty && _coverKey != null && _coverKey!.isNotEmpty;
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

  // 创建/语言是否只读
  bool get createLanguageReadOnly => language != null;

  @override
  void onInit() {
    super.onInit();
    if (language != null) {
      for (int i = 0; i < CommonUtil.language.length; i++) {
        final Map<String, String> r = CommonUtil.language[i];
        if (r[language] != null) {
          setCreateLanguage(i);
        }
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  // 复制模块
  void onCopyCourse() async {
    try {
      final String moduleId = copyOriginalIDController.text.trim();
      if (ObjectUtil.isEmpty(moduleId)) {
        ToastUtils.showManageToast(text: "请输入原模块ID");
        return;
      }

      final String moduleName = copyNameController.text.trim();
      if (ObjectUtil.isEmpty(moduleName)) {
        ToastUtils.showManageToast(text: "请输入原模块名");
        return;
      }

      final response = await ModuleUtil.copy(
          uid: moduleId,
          config: RequestConfig(
              requireToken: true, data: {"name": moduleName, "levelId": levelUid}, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "复制模块成功");
        Get.back(result: [response.data]);
      } else {
        ToastUtils.showManageToast(text: "复制模块失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "复制模块失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  // 创建模块
  void onCreateModule() async {
    try {
      final String moduleName = createNameController.text.trim();
      if (ObjectUtil.isEmpty(moduleName)) {
        ToastUtils.showManageToast(text: "请输入模块名");
        return;
      }

      final String des = createDesController.text.trim();
      if (ObjectUtil.isEmpty(des)) {
        ToastUtils.showManageToast(text: "请输入模块描述");
        return;
      }

      if (ObjectUtil.isEmpty(createLocale.value)) {
        ToastUtils.showManageToast(text: "请输入locale");
        return;
      }

      if (_coverKey == null) {
        ToastUtils.showManageToast(text: "请上传封面");
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

      final response = await ModuleUtil.create(
          config: RequestConfig(
              requireToken: true,
              data: {
                "name": moduleName,
                "language": language,
                "cover": _coverKey,
                "description": des,
                "locale": createLocale.value,
                "levelId": levelUid
              },
              cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "创建模块成功");
        Get.back(result: [response.data]);
      } else {
        ToastUtils.showManageToast(text: "创建模块失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "创建模块失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  // 关联模块
  void onRelevanceModule() async {
    try {
      final List<int> ids = selectedRows.map((element) => element.uid).toList();
      final response = await LevelUtil.relation(
          uid: levelUid.toString(),
          config: RequestConfig(requireToken: true, data: {"moduleIds": ids}, cancelToken: cancelToken));
      if (response.data?.list != null) {
        ToastUtils.showManageToast(text: "关联模块成功");
        Get.back(result: response.data!.list);
      } else {
        ToastUtils.showManageToast(text: "关联模块失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "关联模块失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  void _initData() {
    update(["manage_create_relevance_module"]);
  }

  // 添加模块
  void addModule(BuildContext context, {final bool Function(ModuleResponseEntity)? dataDisableCallback}) {
    print("---selectedRows:${selectedRows.length}---");
    ManageSelectModuleTablePageManager.show(
            context: context,
            defaultDessert: selectedRows,
            dataDisableCallback: dataDisableCallback)
        .then((List<ModuleResponseEntity>? value) {
      if (value != null && value.isNotEmpty) {
        // ToDo 回显数据
        selectedRows = value;
        print("回显数据selectedRows:${selectedRows.length}");
      }
    });
  }

  // 移除模块
  void removeModule(int index) {
    selectedRows.removeAt(index);
    _selectedRows.refresh();
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
    createNameController.dispose();
    selectedRows.clear();
  }
}
