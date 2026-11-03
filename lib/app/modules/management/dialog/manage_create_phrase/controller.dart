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
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

class ManageCreatePhraseController extends BaseController {
  final String? content;
  final String? definition;
  final bool showSelectKnowledgeAddButton;

  ManageCreatePhraseController(this.content, this.definition, this.showSelectKnowledgeAddButton);

  /// 上传所有信息按钮
  bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty && (selectAccessIndex != -1) && definitionController.text.isNotEmpty);

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
    wordController.text = content?.trim() ?? '';
    definitionController.text = definition?.trim() ?? '';
    selectAccessIndex = 0;
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
    update(['manage_create_phrase']);
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

      // if (selectAccessIndex == -1) {
      //   ToastUtils.showManageToast(text: "请选择上架状态", containerKey: dialogKey);
      //   return;
      // }

      // // 验证数据是否一致
      // final effectiveContent = content.replaceAll(" ", "").trim();
      //
      // final effectiveKnowledgeContent = composeCells
      //     .where((element) => element.knowledge != null)
      //     .toList()
      //     .map((element) => element.knowledge!.content)
      //     .toList()
      //     .join()
      //     .replaceAll(" ", "")
      //     .trim();
      //
      // print("effectiveContent:$effectiveContent, effectiveKnowledgeContent:$effectiveKnowledgeContent");

      // if (effectiveContent.isNotEmpty && effectiveContent != effectiveKnowledgeContent) {
      //   ToastUtils.showManageToast(text: "短语和组成结构不匹配", containerKey: dialogKey);
      //   return;
      // }
      //
      if (posIndex == -1) {
        ToastUtils.showManageToast(text: "请选择词性");
        return;
      }

      // 词性/语法形式 , form
      String? pos;
      try {
        pos = poses[posIndex].pos;
      } catch (e) {
        print('---词性e:$e---');
      }
      
      // try {
      //   form = forms[formIndex].form;
      // } catch (e) {
      //   print('---语法形式e:$e---');
      // }

      ToastUtils.showLoading();
      var response = await PhraseUtil.match(
          config: RequestConfig(data: {
        "content": content,
        "contentType": KnowledgeType.EN_PHRASE.value,
        "definition": definition,
        "bookType": BookType.TEXTBOOK.value,
        "pos": pos,
      }, requireToken: true, cancelToken: cancelToken));

      if (response.data != null) {
        ToastUtils.showManageToast(text: response.data.toString());
        Get.back(result: null);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '创建短语失败', type: ManageToastType.error);
      }
    } on FormatException catch (error) {
      ToastUtils.showManageToast(text: error.source?.message ?? '', type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: '创建短语失败', type: ManageToastType.error);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 关联知识点
  Future<void> toRelevanceKnowledge(BuildContext context, List<BaseKnowledge> existList) async {
    print("[$runtimeType] 是否显示新增按钮 showSelectKnowledgeAddButton: $showSelectKnowledgeAddButton");
    var value = await ManageSelectKnowledgeTableManager.show(
        context: context,
        //unitId: 0,
        defaultDessert: existList,
        showSelectKnowledgeAddButton: showSelectKnowledgeAddButton,
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
        //unitId: 0,
        defaultDessert: existList,
        word: word.trim(),
        showSelectKnowledgeAddButton: showSelectKnowledgeAddButton,
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

    return title;
  }

// 语法形式
  void setForm(int index) {
    formIndex = index;
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

  // 新增检查编辑状态的方法
  bool get _anyLearnCoreEditing => learnCoreCells.any((unit) => unit.zhController.text.trim().isEmpty && unit.enController.text.trim().isEmpty);

  @override
  void onClose() {
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
    cancelToken.cancel("取消创建");
    super.onClose();
  }
}
