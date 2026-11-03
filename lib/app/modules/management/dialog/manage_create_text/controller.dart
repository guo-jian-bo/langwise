import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart' as common;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

class ManageCreateTextController extends BaseController {
  final bool showSelectKnowledgeAddButton;

  ManageCreateTextController(this.showSelectKnowledgeAddButton);

  /// 上传按钮状态标志
  bool get uploadButtonFlag => (titleController.text.trim().isNotEmpty && contentController.text.trim().isNotEmpty && (selectAccessIndex != -1));

  /// 标题
  final TextEditingController titleController = TextEditingController(text: '');

  /// 内容
  final TextEditingController contentController = TextEditingController(text: '');

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  // 学习核心
  final List<LearnCoreCell> learnCoreCells = <LearnCoreCell>[];

  // 关联知识点
  final List<Knowledge> relevanceKnowledgeList = <Knowledge>[];

  final GlobalKey dialogKey = GlobalKey();

  // 获取上下架状态显示名称
  String get newAccessName {
    if (selectAccessIndex == -1) return "";
    return StaticData.getOnOffShelfForCreateOrEditNames[selectAccessIndex];
  }

  @override
  void onInit() {
    super.onInit();
    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_create_text']);
  }

  void _onListener() {
    titleController.addListener(() {
      _initData();
    });
    contentController.addListener(() {
      _initData();
    });
  }

  // 创建文章
  void onCreateText() async {
    try {
      final String title = titleController.text.trim();
      if (common.ObjectUtil.isEmpty(title)) {
        ToastUtils.showManageToast(text: "请填写标题", containerKey: dialogKey);
        return;
      }

      final String content = contentController.text.trim();
      if (common.ObjectUtil.isEmpty(content)) {
        ToastUtils.showManageToast(text: "请填写内容", containerKey: dialogKey);
        return;
      }

      if (selectAccessIndex == -1) {
        ToastUtils.showManageToast(text: "请选择上架状态", containerKey: dialogKey);
        return;
      }

      var response = await TextUtil.create(
          config: RequestConfig(data: {
        "title": title,
        "content": content,
        "knowledgeList": relevanceKnowledgeList.map((element) => element.toTextJson()).toList(),
        "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
        "learnTips": learnCoreCells.map((element) => element.toJson()).toList(),
      }, requireToken: true, cancelToken: cancelToken));

      if (response.data != null) {
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '创建文章失败');
      }
    } on FormatException catch (e) {
      print("---创建文章e: $e---");
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: "创建文章失败", type: ManageToastType.error);
    }
  }

  // 关联知识点
  Future<void> toRelevanceKnowledge(BuildContext context, List<BaseKnowledge> existList) async {
    var value = await ManageSelectKnowledgeTableManager.show(
        context: context,
        // unitId: 0,
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

  // 添加学习核心
  void addLearnCore(BuildContext context) {
    if (contentController.text.trim().isEmpty) {
      ToastUtils.showManageToast(text: "请填写文章", containerKey: dialogKey);
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

  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
    _initData();
  }

  // 新增检查编辑状态的方法
  bool get _anyLearnCoreEditing => learnCoreCells.any((unit) => unit.zhController.text.trim().isEmpty && unit.enController.text.trim().isEmpty);

  @override
  void onClose() {
    titleController.dispose();
    for (var compose in learnCoreCells) {
      compose.zhController.dispose();
      compose.enController.dispose();
    }
    contentController.dispose();
    cancelToken.cancel("取消创建");
    super.onClose();
  }
}
