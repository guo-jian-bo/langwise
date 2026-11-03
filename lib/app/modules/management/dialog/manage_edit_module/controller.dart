import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditModuleController extends BaseController {
  final ModuleResponseEntity moduleEntity;

  ManageEditModuleController(this.moduleEntity);

  // ------- 手动 -------
  /// 名称
  final TextEditingController createNameController = TextEditingController();

  /// 描述
  final TextEditingController createDesController = TextEditingController();

  /// local
  final RxString createLocale = ''.obs;

  /// 学习语言
  final RxInt createLearningLanguages = 0.obs;

  /// 按钮
  final RxBool createButtonFlag = false.obs;

  // 选择语言index
  final RxInt _createSelectLanguageIndex = (-1).obs;

  set createSelectLanguageIndex(value) => _createSelectLanguageIndex.value = value;

  int get createSelectLanguageIndex => _createSelectLanguageIndex.value;

  /// 封面
  String? _coverKey;

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  /// 获取手动表单内容是否填写完毕
  void getHandMovementButtonFlag() {
    createButtonFlag.value = createNameController.text.isNotEmpty &&
        createDesController.text.isNotEmpty &&
        (createSelectLanguageIndex != -1) &&
        (selectAccessIndex != -1);
  }

  final GlobalKey dialogKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    createNameController.text = moduleEntity.name?.trim() ?? '';
    createDesController.text = moduleEntity.description?.trim() ?? '';
    createLocale.value = moduleEntity.locale??"";
    if (moduleEntity.language != null) {
      for (int i = 0; i < CommonUtil.language.length; i++) {
        final Map<String, String> r = CommonUtil.language[i];
        if (r[moduleEntity.language] != null) {
          createSelectLanguageIndex = i;
        }
      }
    }
    _coverKey = moduleEntity.cover;
    // 上下架
    try {
      selectAccessIndex = StaticData.getOnOffShelfForCreateOrEditIndex(moduleEntity.access) ?? 0;
    } catch (e) {
      print(e);
    }
    getHandMovementButtonFlag();
    print('---$moduleEntity---');
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

      if (selectAccessIndex == -1) {
        ToastUtils.showManageToast(text: "请选择上架状态", containerKey: dialogKey);
        return;
      }

      final response = await ModuleUtil.edit(
          uid: moduleEntity.uid.toString(),
          config: RequestConfig(
              requireToken: true,
              data: {
                "name": moduleName,
                "cover": _coverKey,
                "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
                "description": des,
                "locale": createLocale.value,
              },
              cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "编辑模块成功");
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: "编辑模块失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "编辑模块失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  void _initData() {
    update(["manage_edit_module"]);
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

  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
    _initData();
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
