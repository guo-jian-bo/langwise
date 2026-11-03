import 'package:api/entities/entities.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_semantic_table/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_topic_table/view.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import 'views/associate_semantic_widget.dart';

class ManageCreateSemanticController extends GetxController {
  ManageCreateSemanticController();

  /// 上传所有信息按钮
  bool get uploadButtonFlag => ((selectDifficultyIndex != -1));

  // 选中的主题列表
  final RxList<EnEntityTopic> _topicList = <EnEntityTopic>[].obs;

  List<EnEntityTopic> get topicList => _topicList;

  // 难度等级
  final RxInt _selectDifficultyIndex = (-1).obs;

  set selectDifficultyIndex(value) => _selectDifficultyIndex.value = value;

  int get selectDifficultyIndex => _selectDifficultyIndex.value;

  final GlobalKey dialogKey = GlobalKey();

  // 语义描述
  final List<DescriptionCell> descriptionCells = <DescriptionCell>[];

  // 关联语义
  final List<AssociateSemanticCell> associateSemanticCells = <AssociateSemanticCell>[];

  @override
  void onInit() {
    super.onInit();
    descriptionCells.add(DescriptionCell());
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_create_semantic']);
  }

  // 创建语义
  void onCreateSemantic() async {
    try {
      if (_anyDescriptionEditing) {
        ToastUtils.showManageToast(text: "请填写语义描述", containerKey: dialogKey);
        return;
      }

      if (selectDifficultyIndex == -1) {
        ToastUtils.showManageToast(text: "请选择难度等级", containerKey: dialogKey);
        return;
      }

      // 检查关联语义编辑状态
      if (associateSemanticCells.isEmpty || _anyAssociatedSemanticEditing) {
        ToastUtils.showManageToast(text: "请完成关联语义的填写", containerKey: dialogKey);
        return;
      }

      var response = await SemanticUtil.create(
          config: RequestConfig(data: {
        "descriptions": descriptionCells
            .where((element) => !element.isEditing)
            .toList()
            .map((element) => element.toJson())
            .toList(),
        "difficulty": CommonUtil.cefr[selectDifficultyIndex],
        "topics": _topicList.map((topic) => topic.uid).toList(),
        "references": associateSemanticCells
            .where((element) => !element.isEditing)
            .toList()
            .map((element) => element.toJson())
            .toList(),
      }, requireToken: true));
      if (response.data != null) {
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '创建语义失败');
      }
    } on FormatException catch (e) {
      print("---创建语义e: $e---");
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: "创建语义失败");
    }
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

  // 难度水平
  void setCreateDifficulty(int index) {
    selectDifficultyIndex = index;
    _initData();
  }

  // 添加主题
  void toAddTopic(BuildContext context, List<EnEntityTopic> existList) async {
    final topics = await ManageSelectTopicTableManager.show(
        context: context,
        defaultDessert: [],
        dataDisableCallback: (EnEntityTopic targetEntity) {
          bool isDisable = false;
          for (final EnEntityTopic exist in existList) {
            if (exist == targetEntity) {
              isDisable = true;
              break;
            }
          }
          return isDisable;
        });

    if (topics != null && topics.isNotEmpty) {
      for (final EnEntityTopic entityTopic in topics) {
        if (!_topicList.contains(entityTopic)) {
          _topicList.add(entityTopic);
        }
      }
      _initData();
    }
  }

  // 移除主题
  void onRemoveTopic(EnEntityTopic entity) {
    _topicList.remove(entity);
    _initData();
  }

  // 关联语义
  void associatedSemantics(BuildContext context, List<EnEntitySemantics> existList) async {
    // 没有正在编辑状态时才能添加新的关联语义
    if (_anyAssociatedSemanticEditing) {
      ToastUtils.showManageToast(text: '请完善语义信息');
      return;
    }

    var value = await ManageSelectSemanticTableManager.show(
        context: context,
        defaultDessert: [],
        dataDisableCallback: (EnEntitySemantics targetEntity) {
          bool isDisable = false;
          for (final EnEntitySemantics exist in existList) {
            if (exist == targetEntity) {
              isDisable = true;
              break;
            }
          }
          return isDisable;
        });
    if (value != null && value.isNotEmpty) {
      for (final EnEntitySemantics entitySemantics in value) {
        // 添加单元格，传入预设好ID的控制器
        associateSemanticCells.add(AssociateSemanticCell(
            entitySemantics: entitySemantics,
            semanticIdController: TextEditingController(text: entitySemantics.uid.toString())));
      }
      _initData();
    }
  }

  // 删除关联语义
  void removeAssociatedSemantic(int index) {
    try {
      associateSemanticCells.removeAt(index);
    } catch (e) {
      print("删除关联语义异常:$e");
    }
    _initData();
  }

  // 处理关联语义口音选择
  void onSelectAssociateNationals(List<int> indexes, int cellIndex) {
    print("业务接收选中的下标indexes: $indexes, 单元格cellIndex: $cellIndex");
    if (cellIndex >= 0 && cellIndex < associateSemanticCells.length) {
      final AssociateSemanticCell old = associateSemanticCells[cellIndex];
      associateSemanticCells[cellIndex] = old.copyWith(nationals: indexes);
      _initData();
    }
  }

  // 处理选择关联类型
  void onSelectAssociateType(String value, int typeIndex, int cellIndex) {
    if (cellIndex >= 0 && cellIndex < associateSemanticCells.length) {
      // 从 semanticTypeKeys 获取对应的类型值
      final type = typeIndex >= 0 ? CommonUtil.semanticTypeKeys[typeIndex] : null;
      print("关联语义选择了类型: $type, typeIndex:$typeIndex, 在单元格: $cellIndex");
      final AssociateSemanticCell old = associateSemanticCells[cellIndex];
      associateSemanticCells[cellIndex] = old.copyWith(relationShip: type);
      _initData();
    }
  }

  // 处理关联语义语言选择
  void onSelectAssociateLanguage(String value, int languageIndex, int cellIndex) {
    if (cellIndex >= 0 && cellIndex < associateSemanticCells.length) {
      // 从 languageKeys 获取对应的语言对象
      final language = languageIndex >= 0 ? CommonUtil.languageKeys[languageIndex] : null;
      print("关联语义选择了语言: $language, languageIndex:$languageIndex, 在单元格: $cellIndex");

      final AssociateSemanticCell old = associateSemanticCells[cellIndex];
      associateSemanticCells[cellIndex] = old.copyWith(language: language);
      _initData();
    }
  }

  // 处理备注变更
  void onAssociateRemarkChanged(String value, int cellIndex) {
    if (cellIndex >= 0 && cellIndex < associateSemanticCells.length) {
      _initData();
    }
  }

  // 新增检查编辑状态的方法
  bool get _anyDescriptionEditing => descriptionCells.any((unit) => unit.isEditing);

  // 检查关联语义编辑状态
  bool get _anyAssociatedSemanticEditing => associateSemanticCells.any((unit) => unit.isEditing);

  /// 获取所有关联语义列表
  /// 返回一个包含所有有效关联语义的列表
  List<EnEntitySemantics> getAllAssociatedSemantics() {
    final List<EnEntitySemantics> semanticsList = [];

    for (final cell in associateSemanticCells) {
      // 只添加非编辑状态且有实体语义的单元格
      if (!cell.isEditing && cell.entitySemantics != null) {
        semanticsList.add(cell.entitySemantics!);
      }
    }

    return semanticsList;
  }
}
