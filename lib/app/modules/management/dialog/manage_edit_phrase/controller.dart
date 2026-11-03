import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_semantic_table/view.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditPhraseController extends BaseController {
  final EnPhraseEntity entity;

  ManageEditPhraseController(this.entity);

  /// 上传所有信息按钮
  bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty && posIndex != -1 && (selectAccessIndex != -1));

  /// word
  final TextEditingController wordController = TextEditingController(text: '');

  /// 释义
  final TextEditingController definitionController = TextEditingController(text: '');

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  // 词性
  final RxInt _posIndex = (-1).obs;

  set posIndex(value) => _posIndex.value = value;

  int get posIndex => _posIndex.value;

  // 语法形式
  final RxInt _formIndex = (-1).obs;

  set formIndex(value) => _formIndex.value = value;

  int get formIndex => _formIndex.value;

  // 词性
  List<PosResponseEntity> poses = <PosResponseEntity>[];

  // 语法形式
  List<FormResponseEntity> forms = <FormResponseEntity>[];

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

  @override
  void onInit() {
    super.onInit();
    wordController.text = entity.content ?? '';
    definitionController.text = entity.definition ?? '';

    // 关联知识点
    if (entity.knowledgeList != null && entity.knowledgeList!.isNotEmpty) {
      relevanceKnowledgeList.addAll(entity.knowledgeList!);
    }

    if (entity.structures != null && entity.structures!.isNotEmpty) {
      for (final EnEntityStructure structure in entity.structures!) {
        composeCells.add(ComposeCell(
            position: structure.positions ?? [],
            isEditing: false,
            selectedKnowledge: "${structure.content ?? ''} (${structure.semantic ?? ''})",
            knowledge: Knowledge(
                uid: structure.contentId ?? 0, content: structure.content, contentId: structure.contentId, semanticId: structure.semanticId, definition: structure.semantic)));
      }
    }

    // 学习核心
    if (entity.learnTips != null) {
      for (final EnEntityLearn map in entity.learnTips!) {
        learnCoreCells.add(LearnCoreCell(zhController: TextEditingController(text: map.zh), enController: TextEditingController(text: map.en)));
      }
    }

    // 语义
    if (entity.semantics != null && entity.semantics!.isNotEmpty) {
      semantics.addAll(entity.semantics! as Iterable<EnEntitySemantics>);
    }

    // 上下架
    try {
      selectAccessIndex = StaticData.getOnOffShelfForCreateOrEditIndex(entity.access) ?? 0;
    } catch (e) {
      print(e);
    }
    onGetPos();
    onGetForm();
    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_edit_phrase']);
  }

  void _onListener() {
    wordController.addListener(() {
      _initData();
    });
    definitionController.addListener(() {
      _initData();
    });
  }

  // 获取词性列表
  void onGetPos() async {
    try {
      final response = await LanguageUtil.pos(config: RequestConfig(requireToken: true, cancelToken: cancelToken));
      if (response.data != null) {
        poses = response.data?.list ?? [];
        // 词性
        if (entity.pos != null) {
          for (int i = 0; i < poses.length; i++) {
            final PosResponseEntity r = poses[i];
            if (r.pos == entity.pos) {
              posIndex = i;
            }
          }
        }
      } else {
        ToastUtils.showManageToast(text: response.message ?? '获取词性列表失败');
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "获取词性列表失败");
    } finally {
      _initData();
    }
  }

// 获取语法形式列表
  void onGetForm() async {
    try {
      final response = await LanguageUtil.form(config: RequestConfig(requireToken: true, cancelToken: cancelToken));
      if (response.data != null) {
        forms = response.data?.list ?? [];
        // 词性
        if (entity.pos != null) {
          for (int i = 0; i < forms.length; i++) {
            final FormResponseEntity r = forms[i];
            if (r.form == entity.form) {
              formIndex = i;
            }
          }
        }
      } else {
        ToastUtils.showManageToast(text: response.message ?? '获取语法形式列表失败');
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "获取语法形式列表失败");
    } finally {
      _initData();
    }
  }

  // 创建短语
  void onCreatePhrase() async {
    try {
      final String content = wordController.text.trim();
      if (ObjectUtil.isEmpty(content)) {
        ToastUtils.showManageToast(text: "请填写短语", containerKey: dialogKey);
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
      final effectiveContent = content.replaceAll(" ", "").trim();

      final effectiveKnowledgeContent =
          composeCells.where((element) => element.knowledge != null).toList().map((element) => element.knowledge!.content).toList().join().replaceAll(" ", "").trim();

      print("effectiveContent:$effectiveContent, effectiveKnowledgeContent:$effectiveKnowledgeContent");

      if (effectiveContent != effectiveKnowledgeContent) {
        ToastUtils.showManageToast(text: "短语和组成结构不匹配", containerKey: dialogKey);
        return;
      }

      if (posIndex == -1) {
        ToastUtils.showManageToast(text: "请选择词性");
        return;
      }

      // 词性/语法形式
      String? pos, form;
      try {
        pos = poses[posIndex].pos;
      } catch (e) {
        print('---词性e:$e---');
      }

      try {
        form = forms[formIndex].form;
      } catch (e) {
        print('---语法形式e:$e---');
      }

      var response = await PhraseUtil.edit(
          uid: entity.uid.toString(),
          config: RequestConfig(data: {
            "content": content,
            "definition": definition,
            "semanticIds": semantics.map((element) => element.uid).toList(),
            "knowledgeList": relevanceKnowledgeList.map((element) => element.toPhraseJson()).toList(),
            "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
            "structures": composeCells.where((element) => element.knowledge != null).toList().map((element) => element.toJson()).toList(),
            "learnTips": learnCoreCells.map((element) => element.toJson()).toList(),
            "pos": pos,
            "form": form,
          }, requireToken: true, cancelToken: cancelToken));

      if (response.data != null) {
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '编辑短语失败', containerKey: dialogKey, type: ManageToastType.error);
      }
    } catch (e) {
      print("---编辑短语e: $e---");
      ToastUtils.showManageToast(text: '编辑短语失败', containerKey: dialogKey, type: ManageToastType.error);
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

  // 选择知识点
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
      semantics.addAll(value);
      _initData();
    }
  }

  // 添加组成结构
  void addCompose(BuildContext context) {
    if (wordController.text.trim().isEmpty) {
      ToastUtils.showManageToast(text: "请填写短语", containerKey: dialogKey);
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
      print("删除knowledgeList异常:$e");
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

  // 词性
  String get posTitle {
    String title = '';
    try {
      title = poses.map((element) => element.title ?? '').toList()[posIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

// 设置词性
  void setPos(int index) {
    posIndex = index;
    _initData();
  }

// 语法形式
  String get formTitle {
    String title = '';
    try {
      title = forms.map((element) => element.title ?? '').toList()[formIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

// 语法形式
  void setForm(int index) {
    formIndex = index;
    _initData();
  }

  // 新增检查编辑状态的方法
  bool get _anyComposeEditing => composeCells.any((unit) => unit.isEditing);

  // 新增检查编辑状态的方法
  bool get _anyLearnCoreEditing => learnCoreCells.any((unit) => unit.zhController.text.trim().isEmpty && unit.enController.text.trim().isEmpty);

  @override
  void onClose() {
    super.onClose();
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
