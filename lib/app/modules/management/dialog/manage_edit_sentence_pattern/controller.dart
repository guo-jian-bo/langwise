import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_create_sentence_pattern/views/compose_widget_pattern.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditSentencePatternController extends BaseController {
  final SentencePatternEntity entity;

  ManageEditSentencePatternController(this.entity);

  /// 上传所有信息按钮
  bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty && (selectAccessIndex != -1) && (definitionController.text.trim().isNotEmpty));

  /// word
  final TextEditingController wordController = TextEditingController(text: '');

  /// 释义
  final TextEditingController definitionController = TextEditingController(text: '');

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  final GlobalKey dialogKey = GlobalKey();

  // 组成结构
  final List<ComposeCellPattern> composeCells = <ComposeCellPattern>[];

  // 组成结构的知识点
  List<Knowledge> knowledgeList = <Knowledge>[];

  /// 难度等级数据
  final List<ConfigEntityGrammar> grammarList = [];

  @override
  void onInit() {
    super.onInit();
    wordController.text = entity.name ?? '';
    definitionController.text = entity.pattern ?? '';

    if (entity.components != null && entity.components!.isNotEmpty) {
      for (final ComponentEntity structure in entity.components!) {
        composeCells.add(ComposeCellPattern(
            isEditing: false,
            isKnowledge: structure.core ?? false,
            selectedKnowledge: structure.content ?? '',
            grammar: ConfigEntityGrammar(grammar: structure.component, title: structure.grammaticalTitle, englishName: structure.grammaticalEnglishName),
            knowledge: Knowledge(
              uid: structure.contentId ?? 0,
              content: structure.content,
              contentId: structure.contentId,
              semanticId: structure.semanticId,
            )));
      }
    }

    // 上下架
    try {
      selectAccessIndex = StaticData.getOnOffShelfForCreateOrEditIndex(entity.access) ?? 0;
    } catch (e) {
      print(e);
    }
    getConfig();
    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_edit_sentence_pattern']);
  }

  void _onListener() {
    wordController.addListener(() {
      _initData();
    });
    definitionController.addListener(() {
      _initData();
    });
  }

  // 语法
  void getConfig() {
    final ConfigEntity configData = Get.find<ConfigController>().appConfig.value;
    final List<ConfigEntityGrammar> grammar = configData.grammar ?? [];
    if (grammar.isNotEmpty) {
      grammarList.clear();
      grammarList.addAll(grammar);
    }

    _initData();
  }

  // 编辑句型
  void onEditSentencePattern() async {
    try {
      final String content = wordController.text.trim();
      if (ObjectUtil.isEmpty(content)) {
        ToastUtils.showManageToast(text: "请填写句型名称", containerKey: dialogKey);
        return;
      }

      final String definition = definitionController.text.trim();

      if (selectAccessIndex == -1) {
        ToastUtils.showManageToast(text: "请选择上架状态", containerKey: dialogKey);
        return;
      }

      // 验证数据是否一致
      final effectiveContent = content.trim();
      print("effectiveContent:$effectiveContent");

      for (final String v in composeCells
          .where((element) => element.knowledge != null)
          .toList()
          .map((element) => (element.knowledge!.content ?? '').replaceAll(" ", "").trim())
          .where((element) => (element.isNotEmpty))
          .toList()) {
        if (!effectiveContent.contains(v)) {
          ToastUtils.showManageToast(text: '$v不在句型名称里');
          return;
        }
      }

      var response = await SentenceUtil.editPattern(
          uid: entity.uid.toString(),
          config: RequestConfig(data: {
            "name": content,
            "pattern": definition,
            "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
            "components": composeCells.toList().map((element) => element.toJson()).toList(),
          }, requireToken: true, cancelToken: cancelToken));

      if (response.data != null) {
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '编辑句型失败');
      }
    } on FormatException catch (e) {
      print("---编辑句型e: $e---");
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: "编辑句型失败");
    }
  }

  // 知识点
  Future<void> toAddKnowledge(BuildContext context, int index, List<BaseKnowledge> existList) async {
    var value = await ManageSelectKnowledgeTableManager.show(
        context: context,
        // unitId: 0,
        defaultDessert: existList,
        dataDisableCallback: (BaseKnowledge targetEntity) {
          bool isDisable = false;
          for (final BaseKnowledge exist in existList) {
            if (exist.contentId == targetEntity.uid) {
              isDisable = true;
              break;
            }
          }
          return isDisable;
        });

    if (value != null && value.isNotEmpty) {
      final List<Knowledge> newLs = <Knowledge>[];
      for (int i = 0; i < value.length; i++) {
        final entity = value[i];
        if (entity is EnWordEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.definition,
              semanticId: entity.selectedSemantics?.uid,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl));
        } else if (entity is EnPhraseEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.definition,
              semanticId: entity.selectedSemantics?.uid,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl));
        } else if (entity is EnSentenceEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.definition,
              semanticId: entity.selectedSemantics?.uid,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl));
        }
      }

      knowledgeList = newLs;

      try {
        final Knowledge knowledge = newLs.first;
        final ComposeCellPattern cell = composeCells[index];
        composeCells[index] = cell.copyWith(
          isEditing: false,
          selectedKnowledge: "${knowledge.content ?? ''} (${knowledge.definition ?? ''})",
          knowledge: knowledge,
        );
        print(composeCells[index].toJson());
      } catch (e) {
        print("---e:$e---");
      }

      print("---返回value: $value, newLs:$newLs---");
    }

    _initData();
  }

  // 添加组成结构
  void addCompose(BuildContext context) {
    if (wordController.text.trim().isEmpty) {
      ToastUtils.showManageToast(text: "请填写句型名称", containerKey: dialogKey);
      return;
    }

    if (composeCells.isEmpty) {
      composeCells.add(ComposeCellPattern());
    } else {
      // 没有正在编辑状态
      if (!_anyComposeEditing) {
        composeCells.add(ComposeCellPattern());
      }
    }

    _initData();
  }

  // 分割单词
  List<String> get wordSplit => wordController.text.trim().split(' ');

  // 获取单词所在位置
  String getWordByIndex(int index) {
    final List<String> words = wordSplit;
    if (index >= 0 && index < words.length) {
      return words[index];
    }
    return '';
  }

  // 删除组成结构
  void removeCompose(int index) {
    try {
      composeCells.removeAt(index);
      knowledgeList.removeAt(index);
    } catch (e) {
      print("删除knowledgeList异常:$e");
    }
    _initData();
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

  // 新增检查编辑状态的方法
  bool get _anyComposeEditing => composeCells.any((unit) => unit.isEditing);

  // 切换是否知识点
  void onSetKnowledgeStatus(int index, int cellIndex) {
    final ComposeCellPattern old = composeCells[cellIndex];
    composeCells[cellIndex] = old.copyWith(
      isKnowledge: CommonUtil.knowledgeOptions[index].isKnowledge,
    );
    _initData();
  }

  // 语法结构选择处理
  void onSelectGrammar(String value, int grammarIndex, int cellIndex) {
    if (grammarIndex >= 0 && grammarIndex < grammarList.length) {
      // 从 grammarList 获取对应的语法结构对象
      final grammar = grammarList[grammarIndex];
      final ComposeCellPattern old = composeCells[cellIndex];

      // 更新组件数据
      composeCells[cellIndex] = old.copyWith(
          // 可以根据需要存储选中的语法结构信息
          grammar: grammar,
          isEditing: false);

      // 打印日志，方便调试
      print("选择了语法结构: ${grammar.title}, ID: ${grammar.grammar}, grammarIndex:$grammarIndex,在单元格: $cellIndex");

      _initData();
    } else {
      print("选择了语法结构, 未命中语法结构: 在单元格cellIndex:$cellIndex");
      // 重置组件数据
      final ComposeCellPattern old = composeCells[cellIndex];
      composeCells[cellIndex] = old.copyWith(
          // 可以根据需要存储选中的语法结构信息
          grammar: null,
          isEditing: true);
    }
  }

  @override
  void onClose() {
    super.onClose();
    wordController.dispose();
    for (var compose in composeCells) {
      compose.knowledgeController.dispose();
    }
    composeCells.clear();
  }
}
