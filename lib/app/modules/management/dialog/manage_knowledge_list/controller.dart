import 'package:api/entities/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/views/select_semantic_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../routes/routes.dart';
import '../../utils/manage_page_registry.dart';

class ManageCreateKnowledgeController extends BaseController {
  final int unitId;
  final int? moduleId;
  final String? language;
  final String? specialty;

  ManageCreateKnowledgeController(this.unitId, this.moduleId, this.language, this.specialty);

  static ManageCreateKnowledgeController get to => Get.find<ManageCreateKnowledgeController>();

  // 词汇表
  final RxList<Knowledge> _units = <Knowledge>[].obs;

  set units(value) => _units.value = value;

  List<Knowledge> get units => _units;

  // 总数据量
  int totalCount = 0;

  // 是否还有更多数据
  bool get hasMoreData => units.length < totalCount + 1;

  // 滚动控制器
  final ScrollController scrollController = ScrollController();

  bool isRequesting = false;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    onRefresh();
  }

  /// 设置滚动监听器
  ///
  /// 监听列表滑动，当滑动到距离底部一定距离时自动加载更多数据
  void _setupScrollListener() {
    scrollController.addListener(() {
      // 当滚动位置接近底部且还有更多数据时触发加载更多
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.8 && hasMoreData && !isRequesting) {
        onLoadMore();
      }
    });
  }

  // 下拉刷新
  @override
  Future<void> onRefresh() async {
    try {
      isRequesting = true;
      offset = 0;
      final response = await KnowledgeUtil.pages(
          unitId: unitId,
          config: RequestConfig(
              requireToken: true,
              data: {"unitId": unitId},
              parameters: {
                "offset": offset,
                "limit": limit,
                "order": "-order",
                "display": specialty == SpecialtyEnum.EN_PHONICS ? 1 : 0,
              },
              cancelToken: cancelToken));
      units.clear();
      // 获取原始数据
      units.add(getAddKnowledgeButton());
      units.addAll((response.data?.datas ?? []).map((element) => element.copyWith(language: language)).toList());
      totalCount = response.data?.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      units.clear();
      // 无论是否成功，都添加添加按钮
      units.add(getAddKnowledgeButton());
    } finally {
      _units.refresh();
      _initData();
      isRequesting = false;
    }
  }

  // 上拉加载更多
  Future<void> onLoadMore() async {
    try {
      isRequesting = true;
      offset = offset + limit;
      final response = await KnowledgeUtil.pages(
          unitId: unitId,
          config: RequestConfig(requireToken: true, data: {"unitId": unitId}, parameters: {"offset": offset, "limit": limit, "order": "-order"}, cancelToken: cancelToken));
      final List<Knowledge> knowledgeList = (response.data?.datas ?? []).map((element) => element.copyWith(language: language)).toList();
      units.addAll(knowledgeList);
      totalCount = response.data?.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _units.refresh();
      _initData();
      isRequesting = false;
    }
  }

  /// 从知识库彻底删除知识点
  void onDeleteFromKnowledgeBase(int index, Knowledge e) async {
    final bool ask = await AskDialog.showGetDialog(
      title: "温馨提示",
      content: "确定要删除${e.content}吗？",
      askLevel: AskLevelType.warning,
      showLastCountdown: true,
    );
    if (!ask) return;
    _deleteFromKnowledgeBase(index, e);
  }

  // 从知识库彻底删除知识点
  void _deleteFromKnowledgeBase(int index, Knowledge e) async {
    try {
      final response = await UnitUtil.deleteKnowledge(
          unitId: unitId,
          config: RequestConfig(
              requireToken: true,
              parameters: {
                "uid": [e.uid],
                "flag": '0',
              },
              cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: '删除成功');
        units.removeAt(index);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '删除失败');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      _units.refresh();
      _initData();
    }
  }

  /// 从当前知识点列表删除，不影响知识库
  void onDeleteFromCurrentList(int index, Knowledge e) async {
    // return;
    try {
      final response = await UnitUtil.deleteKnowledge(
          unitId: unitId,
          config: RequestConfig(
              requireToken: true,
              parameters: {
                "uid": [e.uid],
                "flag": '1',
              },
              cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: '删除成功');
        units.removeAt(index);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '删除失败');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      _units.refresh();
      _initData();
    }
  }

  // 知识点
  Future<void> toAddKnowledge(
    BuildContext context,
    List<BaseKnowledge> existList, {
    bool hidePhrase = false,
    bool hideSentence = false,
    bool hideText = false,
    String? topic, //专项课 自然拼读课音标
    required int? moduleId,
  }) async {
    var value = await ManageSelectKnowledgeTableManager.show(
        context: context,
        //unitId: unitId,
        defaultDessert: existList,
        language: language,
        showSelectKnowledgeAddButton: true,
        hidePhrase: hidePhrase,
        hideSentence: hideSentence,
        hideText: hideText,
        topic: topic,
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
    final List<Knowledge> newLs = <Knowledge>[];
    if (value != null && value.isNotEmpty) {
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
              audioUrl: entity.audioUrl,
              language: entity.language));
        } else if (entity is EnPhraseEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.definition,
              semanticId: entity.selectedSemantics?.uid,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl,
              language: entity.language));
        } else if (entity is EnSentenceEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.definition,
              semanticId: entity.selectedSemantics?.uid,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl,
              language: entity.language));
        } else if (entity is EnTextEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.title,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl,
              language: entity.language));
        }
      }
      _onAdd(list: newLs);
    }
  }

  // 添加知识点
  void _onAdd({required List<Knowledge> list}) async {
    if (list.isEmpty) {
      return;
    }

    try {
      final response = await KnowledgeUtil.add(
        unitId: unitId,
        config: RequestConfig(
          requireToken: true,
          parameters: {
            "moduleId": moduleId,
          },
          data: list.map((element) => element.toJson()).toList(),
          cancelToken: cancelToken,
        ),
      );
      if (response.data != null) {
        ToastUtils.showManageToast(text: '添加知识点成功');
        onRefresh();
      } else {
        ToastUtils.showManageToast(text: response.message ?? '添加知识点失败');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      _initData();
    }
  }

  /// 处理课时排序
  Future<void> onReorderKnowledge(int oldIndex, int newIndex) async {
    try {
      // 确保索引在有效范围内
      if (oldIndex < 0 || oldIndex >= units.length || newIndex < 0 || newIndex > units.length) {
        return;
      }

      // 获取被移动的知识点
      final movedLesson = units[oldIndex];

      if (movedLesson.isAddKnowledge) {
        ToastUtils.showManageToast(text: "不能调整顺序");
        return;
      }

      // 排序
      final row = units.removeAt(oldIndex);
      units.insert(newIndex, row);

      // 调用API更新课时顺序
      final response = await KnowledgeUtil.order(
          unitId: unitId.toString(), knowledgeId: movedLesson.uid, config: RequestConfig(requireToken: true, parameters: {"index": newIndex}, cancelToken: cancelToken));

      if (response.data != null) {
        _units.refresh();
        ToastUtils.showManageToast(text: "排序成功");
      } else {
        ToastUtils.showManageToast(text: response.message ?? "排序失败");
      }
    } catch (e) {
      if (kDebugMode) {
        print("课时排序错误: $e");
      }
      ToastUtils.showManageToast(text: "排序失败");
    } finally {
      _initData();
    }
  }

  void _initData() {
    update(["manage_knowledge_list"]);
  }

  /// 添加知识点按钮
  Knowledge getAddKnowledgeButton() => Knowledge(uid: -1);

  // 知识点审核
  void toKnowledgeModeration(Knowledge k) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': k.contentType, 
        'uid': k.contentId, 
        'semanticId': k.semanticId,
        "quizOrImage": 1,
      },
    ).then((v){
      onRefresh();
    });
    // Get.to(
    //   const ManageKnowledgeModerationView(),
    //   arguments: {
    //     "knowledge": k,
    //   },
    //   // 设置透明背景，使页面看起来像是浮动的
    //   opaque: false,
    //   transition: Transition.downToUp,
    //   duration: const Duration(milliseconds: 300),
    //   curve: Curves.easeInOut,
    // )?.then((value) {
    //   onRefresh();
    // });
  }

  /// 更新释义
  void onUpdateDefinition(int index, Knowledge knowledge) {
    // TODO: 实现更新释义的逻辑
    if (kDebugMode) {
      print('更新释义: index=$index, knowledge=${knowledge.content}');
    }

    if (knowledge.knowledgeType.isWord) {
      fetchEnWordList(knowledge);
    } else if (knowledge.knowledgeType.isPhrase) {
      fetchEnPhraseList(knowledge);
    } else {
      ToastUtils.showManageToast(text: "暂无释义", type: ManageToastType.error);
    }
  }

  void fetchEnWordList(Knowledge knowledge) async {
    try {
      final ListResponseEntity<EnWordEntity>? response = await ManageSelectQuziKnowledge.getEnWordKnowledgeList(parameters: {
        'offset': 0,
        'limit': 30,
        "order": "-wordFreq"
      }, data: {
        "uid": [knowledge.contentId]
      });

      if ((response?.datas ?? []).isEmpty) {
        throw "暂无数据";
      }

      final EnWordEntity enWord = response!.datas!.first;

      if (enWord.semantics == null || enWord.semantics!.isEmpty) {
        throw "暂无数据";
      }

      final List<EnEntitySemantics> semantics = enWord.semantics!.map((s) => s.copyWith(language: language)).toList();

      for (final EnEntitySemantics s in semantics) {
        if (s.uid == knowledge.semanticId) {
          s.isSelected = true;
        }
      }

      SelectSemanticManager.show(
          context: Get.context!,
          semantics: semantics,
          onOkTap: (List<EnEntitySemantics> semantics) {
            print("选中的语义: ${semantics.length},$semantics");
            if (semantics.isEmpty) {
              return;
            }

            final EnEntitySemantics? selectedSemantics = semantics.firstWhereOrNull((element) => element.isSelected);
            if (selectedSemantics == null) {
              return;
            }

            onEditKnowledgeSemantic(knowledge, selectedSemantics);
          });
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString(), type: ManageToastType.error);
    }
  }

  void fetchEnPhraseList(Knowledge knowledge) async {
    try {
      final ListResponseEntity<EnPhraseEntity>? response = await ManageSelectQuziKnowledge.getEnPhraseKnowledgeList(parameters: {
        'offset': 0,
        'limit': 30,
        "order": "-wordFreq"
      }, data: {
        "uid": [knowledge.contentId]
      });

      if ((response?.datas ?? []).isEmpty) {
        throw "暂无数据";
      }

      final EnPhraseEntity enWord = response!.datas!.first;

      if (enWord.semantics == null || enWord.semantics!.isEmpty) {
        throw "暂无数据";
      }

      final List<EnEntitySemantics> semantics = enWord.semantics!.map((s) => s.copyWith(language: language)).toList();

      for (final EnEntitySemantics s in semantics) {
        if (s.uid == knowledge.semanticId) {
          s.isSelected = true;
        }
      }

      SelectSemanticManager.show(
          context: Get.context!,
          semantics: semantics,
          onOkTap: (List<EnEntitySemantics> semantics) {
            print("选中的语义: $semantics");
            if (semantics.isEmpty) {
              return;
            }

            final EnEntitySemantics? selectedSemantics = semantics.firstWhereOrNull((element) => element.isSelected);
            if (selectedSemantics == null) {
              return;
            }

            onEditKnowledgeSemantic(knowledge, selectedSemantics);
          });
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString(), type: ManageToastType.error);
    }
  }

  void onEditKnowledgeSemantic(Knowledge knowledge, EnEntitySemantics semantic) async {
    try {
      final response =
          await UnitUtil.editKnowledgeSemantic(unitId: knowledge.unitId, knowledgeId: knowledge.uid, semanticId: semantic.uid, config: RequestConfig(requireToken: true));

      if (response.data == null) {
        throw response.message ?? "未知错误";
      }

      onRefresh();
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString(), type: ManageToastType.error);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    cancelToken.cancel("管理知识点列表取消");
    super.onClose();
  }
}
