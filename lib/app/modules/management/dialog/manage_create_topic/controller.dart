import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

class ManageCreateTopicController extends GetxController {
  ManageCreateTopicController();

  /// 上传所有信息按钮
  bool get uploadButtonFlag =>
      (wordController.text.trim().isNotEmpty && (selectDifficultyIndex != -1) && (selectAccessIndex != -1));

  /// word
  final TextEditingController wordController = TextEditingController(text: '');

  // 难度等级
  final RxInt _selectDifficultyIndex = (-1).obs;

  set selectDifficultyIndex(value) => _selectDifficultyIndex.value = value;

  int get selectDifficultyIndex => _selectDifficultyIndex.value;

  // 上下架状态
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  // 获取上下架状态名称
  String get newAccessName {
    return StaticData.getOnOffShelfForCreateOrEdit(selectAccessIndex);
  }

  final GlobalKey dialogKey = GlobalKey();

  // 语义描述
  final List<DescriptionCell> descriptionCells = <DescriptionCell>[];

  @override
  void onInit() {
    super.onInit();
    descriptionCells.add(DescriptionCell());
    // 默认选择第一个上下架状态（通常是"下架"）
    selectAccessIndex = 1;
    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_create_topic']);
  }

  void _onListener() {
    wordController.addListener(() {
      _initData();
    });
  }

  // 创建主题
  void onCreateTopic() async {
    try {
      final String content = wordController.text.trim();
      if (ObjectUtil.isEmpty(content)) {
        ToastUtils.showManageToast(text: "请填写主题", containerKey: dialogKey);
        return;
      }

      if (_anyDescriptionEditing) {
        ToastUtils.showManageToast(text: "请填充主题描述", containerKey: dialogKey);
        return;
      }

      if (selectDifficultyIndex == -1) {
        ToastUtils.showManageToast(text: "请选择难度等级", containerKey: dialogKey);
        return;
      }

      // 描述数据
      List<Map<String, dynamic>> descriptionsList = [];
      for (var element in descriptionCells) {
        descriptionsList.add(element.toJson());
      }

      // 创建请求数据
      final data = <String, dynamic>{};
      data["title"] = wordController.text.trim();
      data["difficulty"] = selectDifficultyIndex;
      data["descriptions"] = descriptionsList;

      // 调用创建API
      final response = await TopicUtil.create(
        config: RequestConfig(requireToken: true, data: data),
      );

      if (response.data != null) {
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(
          text: response.message ?? "创建失败",
          containerKey: dialogKey,
          type: ManageToastType.error,
        );
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "创建失败", containerKey: dialogKey, type: ManageToastType.error);
    }
  }

  // 设置难度
  void setCreateDifficulty(int index) {
    selectDifficultyIndex = index;
    _initData();
  }

  // 设置上下架状态
  void setAccess(int index) {
    selectAccessIndex = index;
    _initData();
  }

// 语言选择处理
  void onDescriptionSelectLanguage(String value, int languageIndex, int cellIndex) {
    if (languageIndex >= 0) {
      // 从 languageKeys 获取对应的语言对象
      final language = CommonUtil.languageKeys[languageIndex];
      // 打印日志，方便调试
      print("选择了语言: $language, languageIndex:$languageIndex, 在单元格: $cellIndex");
      final DescriptionCell old = descriptionCells[cellIndex];

      // 更新组件数据
      descriptionCells[cellIndex] = old.copyWith(
          // 可以根据需要存储选中的语言信息
          language: language);
    } else {
      print("选择了语言, 未命中语言: 在单元格cellIndex:$cellIndex");
      // 重置组件数据
      final DescriptionCell old = descriptionCells[cellIndex];
      descriptionCells[cellIndex] = old.copyWith(
          // 可以根据需要存储选中的语言信息
          language: null);
    }
  }

  // 添加语言语义
  void addDescriptionCell(BuildContext context) {
    // 没有正在编辑状态
    if (!_anyDescriptionEditing) {
      descriptionCells.add(DescriptionCell());
      _initData();
    } else {
      ToastUtils.showManageToast(text: '请完善语义描述');
    }
  }

  // 删除语言语义
  void removeDescription(int index) {
    try {
      descriptionCells.removeAt(index);
    } catch (e) {
      print("删除descriptionCells异常:$e");
    }
    _initData();
  }

  // 检查是否有正在编辑的描述
  bool get _anyDescriptionEditing {
    return descriptionCells.any((cell) => cell.isEditing);
  }
}
