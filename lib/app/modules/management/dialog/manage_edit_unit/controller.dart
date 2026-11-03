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

class ManageEditUnitController extends BaseController {
  final NewUnitResponseEntity unitEntity;

  ManageEditUnitController(this.unitEntity);

  // ------- 手动 -------
  /// id
  final TextEditingController idController = TextEditingController();

  /// 名称
  final TextEditingController createNameController = TextEditingController();

  /// 描述
  final TextEditingController createDesController = TextEditingController();

  /// 按钮
  final RxBool createButtonFlag = false.obs;

  // 选择语言
  final RxInt _createSelectLanguageIndex = (-1).obs;

  set createSelectLanguageIndex(value) =>
      _createSelectLanguageIndex.value = value;

  int get createSelectLanguageIndex => _createSelectLanguageIndex.value;

  // 难度等级(最小)
  final RxInt selectMinDifficulty = (-1).obs;

  // 难度等级(最大)
  final RxInt selectMaxDifficulty = (-1).obs;

  // 上下架
  final RxInt _selectAccessIndex = (0).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  /// 获取手动表单内容是否填写完毕
  void getHandMovementButtonFlag() {
    createButtonFlag.value = createNameController.text.isNotEmpty &&
        (createSelectLanguageIndex != -1);
  }

  /// 难度等级数据
  final List<DifficultieEntity> difficultieList = [];

  String? difficultyMinValue, difficultyMaxValue;

  final GlobalKey dialogKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    idController.text = unitEntity.uid.toString();
    createNameController.text = unitEntity.name?.trim() ?? '';
    createDesController.text = unitEntity.description?.trim() ?? '';

    

    if (unitEntity.language != null) {
      for (int i = 0; i < CommonUtil.language.length; i++) {
        final Map<String, String> r = CommonUtil.language[i];
        if (r[unitEntity.language] != null) {
          createSelectLanguageIndex = i;
        }
      }
    }

    // (如果语言未命中)默认选中英语
    if (createSelectLanguageIndex == -1) {
      setCreateLanguage(0);
    }


    try {
      selectAccessIndex =
          StaticData.getOnOffShelfForCreateOrEditIndex(unitEntity.access) ?? 0;
    } catch (e) {
      print(e);
    }

    getHandMovementButtonFlag();
    getConfig();
    print('---$unitEntity---');
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
    print("接收index:$index");
    // 切换语言时, 重置难度水平为-1
    setCreateMinDifficulty(-1);
    setCreateMaxDifficulty(-1);
    getHandMovementButtonFlag();
    // 重新获取难度等级数据
    getConfig();
  }

  // 最小难度水平
  void setCreateMinDifficulty(int diff) {
    selectMinDifficulty.value = difficultieList.firstWhereOrNull((element) => element.level == diff)?.level ?? -1;
    getHandMovementButtonFlag();
  }

  // 最大难度水平
  void setCreateMaxDifficulty(int diff) {
    selectMaxDifficulty.value = difficultieList.firstWhereOrNull((element) => element.level == diff)?.level ?? -1;
    getHandMovementButtonFlag();
  }

  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
    getHandMovementButtonFlag();
  }

  // 难度等级
  Future<void> getConfig() async {
    final ConfigEntity configData =
        Get.find<ConfigController>().appConfig.value;
    final String languageCode =
        StaticData.languageList[createSelectLanguageIndex].value;
    final List<DifficultieEntity>? diffList = DifficultieUtils.getDifficultieList(configData, languageCode);
    if (diffList != null && diffList.isNotEmpty) {
      difficultieList.clear();
      difficultieList.addAll(diffList);
    }


    // 最小等级
    if (unitEntity.difficulty?.min != null) {
      setCreateMinDifficulty(unitEntity.difficulty!.min!);
    }

    // 最大等级
    if (unitEntity.difficulty?.max != null) {
      setCreateMaxDifficulty(unitEntity.difficulty!.max!);
    }

    try {
      // 最小难度
      difficultyMinValue = difficultieList.firstWhereOrNull((element) => element.level == selectMinDifficulty.value)?.name?.text;
    } catch (e) {
      print(e);
    }

    try {
      // 最大难度
      difficultyMaxValue = difficultieList.firstWhereOrNull((element) => element.level == selectMaxDifficulty.value)?.name?.text;
    } catch (e) {
      print(e);
    }

    _initData();
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

      // if (selectMinDifficultyIndex == -1) {
      //   ToastUtils.showManageToast(text: "请选择最小难度等级", containerKey: dialogKey);
      //   return;
      // }
      //
      // if (selectMaxDifficultyIndex == -1) {
      //   ToastUtils.showManageToast(text: "请选择最大难度等级", containerKey: dialogKey);
      //   return;
      // }
      //
      // if (selectMinDifficultyIndex > selectMaxDifficultyIndex) {
      //   ToastUtils.showManageToast(text: "最小难度等级不能大于最大难度等级", containerKey: dialogKey);
      //   return;
      // }

      final response = await UnitUtil.edit(
          uid: unitEntity.uid.toString(),
          config: RequestConfig(
              requireToken: true,
              data: {
                "name": moduleName,
                "description": des,
                if (selectMinDifficulty.value != -1 ||
                    selectMaxDifficulty.value != -1)
                  "difficulty": {
                    "min": difficultieList.firstWhereOrNull((element) => element.level == selectMinDifficulty.value)?.level,
                    "max": difficultieList.firstWhereOrNull((element) => element.level == selectMaxDifficulty.value)?.level,
                  },
                "access": StaticData
                    .onOffShelfForCreateOrEdit[selectAccessIndex].value
              },
              cancelToken: cancelToken));
      if (response?.data != null) {
        ToastUtils.showManageToast(text: "编辑单元成功");
        Get.back(result: response?.data);
      } else {
        ToastUtils.showManageToast(text: "编辑单元失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "编辑单元失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  void _initData() {
    update(["manage_edit_unit"]);
  }

  // 上下架title
  String get newAccessName {
    return StaticData.getOnOffShelfForCreateOrEdit(selectAccessIndex);
  }

  @override
  void onClose() {
    idController.dispose();
    createNameController.dispose();
    createDesController.dispose();
    super.onClose();
  }
}
