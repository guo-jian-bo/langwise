import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditTopicController extends GetxController {
  final EnEntityTopic topic;

  ManageEditTopicController(this.topic);

  /// 上传所有信息按钮
  bool get uploadButtonFlag =>
      (wordController.text.trim().isNotEmpty && (selectDifficultyIndex != -1) && (selectAccessIndex != -1));

  /// 标题
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
    // 初始化标题
    wordController.text = topic.title ?? '';

    print(topic);
    // 初始化难度级别
    if (topic.difficulty != null) {
      try {
        final int difficultyIndex = CommonUtil.cefr[topic.difficulty!];
        selectDifficultyIndex = difficultyIndex;
      } catch (e) {
        selectDifficultyIndex = -1;
      }
    } else {
      selectDifficultyIndex = -1;
    }

    // 初始化上下架状态
    if (topic.access != null) {
      final int? accessIndex = StaticData.getOnOffShelfForCreateOrEditIndex(topic.access);
      if (accessIndex != null) {
        selectAccessIndex = accessIndex;
      } else {
        // 默认选择下架状态
        selectAccessIndex = 1;
      }
    } else {
      // 默认选择下架状态
      selectAccessIndex = 1;
    }

    // 初始化描述
    if (topic.descriptions != null && topic.descriptions!.isNotEmpty) {
      for (var desc in topic.descriptions!) {
        final DescriptionCell cell = DescriptionCell(
            descriptionController: TextEditingController(text: desc.text ?? ''), language: desc.lang);
        descriptionCells.add(cell);
      }
    }

    // 如果没有描述，添加一个空的描述单元格
    if (descriptionCells.isEmpty) {
      descriptionCells.add(DescriptionCell());
    }

    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_edit_topic']);
  }

  void _onListener() {
    wordController.addListener(() {
      _initData();
    });
  }

  // 添加描述单元格
  void addDescriptionCell(BuildContext context) {
    descriptionCells.add(DescriptionCell());
    _initData();
  }

  // 删除描述单元格
  void removeDescription(int index) {
    if (index < 0 || index >= descriptionCells.length) return;
    descriptionCells.removeAt(index);
    _initData();
  }

  // 语言选择处理
  void onDescriptionSelectLanguage(String value, int languageIndex, int cellIndex) {
    if (cellIndex < 0 || cellIndex >= descriptionCells.length) return;
    if (languageIndex >= 0) {
      // 从 languageKeys 获取对应的语言对象
      final language = CommonUtil.languageKeys[languageIndex];
      final DescriptionCell old = descriptionCells[cellIndex];

      // 更新组件数据
      descriptionCells[cellIndex] = old.copyWith(language: language);
      _initData();
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

  // 编辑主题
  void onEditTopic() async {
    try {
      final String title = wordController.text.trim();
      if (ObjectUtil.isEmpty(title)) {
        ToastUtils.showManageToast(text: "请填写标题", containerKey: dialogKey);
        return;
      }

      if (selectDifficultyIndex == -1) {
        ToastUtils.showManageToast(text: "请选择难度等级", containerKey: dialogKey);
        return;
      }

      if (selectAccessIndex == -1) {
        ToastUtils.showManageToast(text: "请选择上架状态", containerKey: dialogKey);
        return;
      }

      // 构建描述数据
      List<Map<String, dynamic>> descriptions = [];
      for (var cell in descriptionCells) {
        if (cell.descriptionController.text.trim().isNotEmpty && cell.language != null) {
          descriptions.add({"lang": cell.language!.toLowerCase(), "text": cell.descriptionController.text.trim()});
        }
      }

      // 构建请求数据
      final Map<String, dynamic> data = {
        "title": title,
        "difficulty": selectDifficultyIndex,
        "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
        "descriptions": descriptions
      };

      // 调用编辑API
      final response = await TopicUtil.edit(
        uid: topic.uid.toString(),
        config: RequestConfig(requireToken: true, data: data),
      );

      if (response.code == 0) {
        ToastUtils.showManageToast(text: response.message ?? "编辑成功");
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? "编辑失败", type: ManageToastType.error);
      }
    } catch (error) {
      ToastUtils.showManageToast(text: "编辑失败", type: ManageToastType.error);
    }
  }
}
