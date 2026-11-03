import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_semantic_table/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_sentence_pattern_table/view.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditSentenceController extends BaseController {
  final EnKnowledgeEntity entity;

  ManageEditSentenceController(this.entity);

  /// 上传所有信息按钮
  bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty && (selectAccessIndex != -1));

  /// word
  final TextEditingController wordController = TextEditingController(text: '');

  /// 释义
  final TextEditingController definitionController = TextEditingController(text: '');

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  // 语义list
  final List<EnEntitySemantics> semantics = <EnEntitySemantics>[];

  final GlobalKey dialogKey = GlobalKey();

  // 组成结构
  final List<ComposeCell> composeCells = <ComposeCell>[];

  // 组成结构的知识点
  List<Knowledge> knowledgeList = <Knowledge>[];

  // 学习核心
  final List<LearnCoreCell> learnCoreCells = <LearnCoreCell>[];

  // 关联知识点
  final List<Knowledge> relevanceKnowledgeList = <Knowledge>[];

  List<SentencePatternEntity> sentencePatternList = <SentencePatternEntity>[];

  @override
  void onInit() {
    super.onInit();
    wordController.text = entity.content ?? '';
    definitionController.text = entity.definition ?? '';

    // if (entity.components != null && entity.components!.isNotEmpty) {
    //   for (final ComponentEntity structure in entity.components!) {
    //     composeCells.add(ComposeCellPattern(
    //         isEditing: false,
    //         isKnowledge: structure.core ?? false,
    //         selectedKnowledge: structure.content ?? '',
    //         grammar: ConfigEntityGrammar(
    //             grammar: structure.component,
    //             title: structure.grammaticalTitle,
    //             englishName: structure.grammaticalEnglishName),
    //         knowledge: Knowledge(
    //           uid: structure.contentId ?? 0,
    //           content: structure.content,
    //           contentId: structure.contentId,
    //           semanticId: structure.semanticId,
    //         )));
    //   }
    // }

    // 上下架
    try {
      selectAccessIndex = StaticData.getOnOffShelfForCreateOrEditIndex(entity.access) ?? 0;
    } catch (e) {
      print(e);
    }
    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_edit_sentence']);
  }

  void _onListener() {
    wordController.addListener(() {
      _initData();
    });
    definitionController.addListener(() {
      _initData();
    });
  }

  // 编辑句型
  void onEditSentence() async {
    try {
      final String content = wordController.text.trim();
      if (ObjectUtil.isEmpty(content)) {
        ToastUtils.showManageToast(text: "请填写句型名称", containerKey: dialogKey);
        return;
      }

      final String definition = definitionController.text.trim();
      if (ObjectUtil.isEmpty(definition)) {
        ToastUtils.showManageToast(text: "请填写释义");
        return;
      }

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

      var response = await SentenceUtil.editSentence(
          uid: entity.uid.toString(),
          config: RequestConfig(data: {
            "content": content,
            "definition": definition,
            "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
            "components": composeCells.toList().map((element) => element.toJson()).toList(),
          }, requireToken: true, cancelToken: cancelToken));

      if (response.data != null) {
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '编辑句子失败');
      }
    } on FormatException catch (e) {
      print("---编辑句子e: $e---");
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: "编辑句子失败");
    }
  }

  // 关联知识点
  Future<void> toRelevanceKnowledge(BuildContext context, List<BaseKnowledge> existList) async {
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

      relevanceKnowledgeList.addAll(newLs);
    }

    _initData();
  }

  // 删除关联知识点
  void removeRelevanceKnowledge(int index) {
    try {
      relevanceKnowledgeList.removeAt(index);
    } catch (e) {
      print("删除knowledgeList异常:$e");
    }
    _initData();
  }

  // 知识点
  Future<void> toAddKnowledge(BuildContext context, int index, List<BaseKnowledge> existList) async {
    final String word = getWordByIndex(index);
    var value = await ManageSelectKnowledgeTableManager.show(
        context: context,
        // unitId: 0,
        defaultDessert: existList,
        word: word.trim(),
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
        }
      }

      knowledgeList = newLs;

      try {
        final Knowledge knowledge = newLs.first;
        final ComposeCell cell = composeCells[index];
        composeCells[index] = cell.copyWith(
          position: [index],
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

  // 添加语义
  Future<void> toAddSemantic(BuildContext context, List<EnEntitySemantics> existList) async {
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

    if (value != null) {
      semantics.clear();
      semantics.addAll(value);
      _initData();
    }
  }

  // 添加组成结构
  void addCompose(BuildContext context) {
    if (wordController.text.trim().isEmpty) {
      ToastUtils.showManageToast(text: "请填写句子", containerKey: dialogKey);
      return;
    }

    if (composeCells.isEmpty) {
      composeCells.add(ComposeCell());
    } else {
      // 没有正在编辑状态
      if (!_anyComposeEditing && composeCells.length < wordSplit.length) {
        composeCells.add(ComposeCell());
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

  // 添加学习核心
  void addLearnCore(BuildContext context) {
    if (wordController.text.trim().isEmpty) {
      ToastUtils.showManageToast(text: "请填写短语", containerKey: dialogKey);
      return;
    }

    if (learnCoreCells.isEmpty) {
      learnCoreCells.add(LearnCoreCell());
    } else {
      // 没有正在编辑状态
      if (!_anyLearnCoreEditing) {
        learnCoreCells.add(LearnCoreCell());
      }
    }

    _initData();
  }

  // 删除学习核心
  void removeLearnCore(int index) {
    try {
      learnCoreCells.removeAt(index);
    } catch (e) {
      print("删除learnCoreCells异常:$e");
    }
    _initData();
  }

  // 移除语义
  void onRemoveSemantic(EnEntitySemantics entity) {
    if (semantics.isNotEmpty) {
      semantics.remove(entity);
      _initData();
    }
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

  // 新增检查编辑状态的方法
  bool get _anyLearnCoreEditing => learnCoreCells.any((unit) => unit.zhController.text.trim().isEmpty && unit.enController.text.trim().isEmpty);

  // 移除句型
  void onRemoveAddSentencePattern(SentencePatternEntity sentencePatternEntity) {
    try {
      sentencePatternList.remove(sentencePatternEntity);
    } catch (e) {
      print("删除sentencePatternList异常:$e");
    }
    _initData();
  }

  // 添加句型
  void toAddSentencePattern(BuildContext context, List<SentencePatternEntity> existList) async {
    final List<SentencePatternEntity>? value = (await ManageSelectSentencePatternTableManager.show(
        context: context,
        defaultDessert: existList,
        dataDisableCallback: (SentencePatternEntity targetEntity) {
          bool isDisable = false;
          for (final SentencePatternEntity exist in existList) {
            if (exist == targetEntity) {
              isDisable = true;
              break;
            }
          }
          return isDisable;
        }));
    if (value != null && value.isNotEmpty) {
      sentencePatternList = value;
    }
    _initData();
  }

  @override
  void onClose() {
    super.onClose();
    cancelToken.cancel("取消创建");
    wordController.dispose();
    for (var compose in composeCells) {
      compose.knowledgeController.dispose();
      compose.positionController.dispose();
    }
    for (var compose in learnCoreCells) {
      compose.zhController.dispose();
      compose.enController.dispose();
    }
    composeCells.clear();
  }
}
