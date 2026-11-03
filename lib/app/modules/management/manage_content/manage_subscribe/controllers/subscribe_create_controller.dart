import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../common/manage_select_knowledge_table/view.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../../../routes/routes.dart';

class EnContentRequest {
  String? content;
  String? contentType;
  int? contentId;
  int? semanticId;
  EnContentRequest({required this.content, required this.contentType, required this.contentId, required this.semanticId});

  Map<String, dynamic> toJson() => {
        'content': content,
        'contentType': contentType,
        'contentId': contentId,
        'semanticId': semanticId,
      };
}

class SubscribeCreateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  SubscribeCreateController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SUBSCRIBE_CREATE;

  @override
  String get breadcrumbTitle => '创建内容';

  int? collectionId;
  String? themeZh;
  String? themeEn;
  List<ManageSubscribeReference?>? links;
  String? description;
  RxList<String> targetCefrLevels = <String>[].obs;
  bool isGenerating = false;
  String initContent = '';
  String initLink = '';
  String initGroup = '';
  final TextEditingController linkCtrl = TextEditingController();
  final TextEditingController contentCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    final args = Get.arguments as Map<String, dynamic>?;

    collectionId = args?['id'] as int?;
    themeZh = args?['themeZh'] as String?;
    themeEn = args?['themeEn'] as String?;
    links = args?['links'] as List<ManageSubscribeReference?>?;
    description = args?['description'] as String?;
    initContent = args?['originText'] ?? '';
    initLink = args?['originLink'] ?? '';
    initGroup = args?['group'] ?? '';
    linkCtrl.text = initLink;
    contentCtrl.text = initContent;
  }

  /// 生成文章
  Future<void> generalArticle() async {
    if (isGenerating) return;
    if (targetCefrLevels.isEmpty) {
      ToastUtils.showToast(text: '等级不能为空', type: ToastType.error);
      return;
    }
    if (contentCtrl.text.trim().isEmpty) {
      ToastUtils.showToast(text: '原文内容不能为空', type: ToastType.error);
      return;
    }
    if (linkCtrl.text.trim().isEmpty) {
      ToastUtils.showToast(text: '原文链接不能为空', type: ToastType.error);
      return;
    }
    isGenerating = true;

    List<EnContentRequest> knowledgePoints = [];
    if (relevanceKnowledgeList.isNotEmpty) {
      for (int i = 0; i < relevanceKnowledgeList.length; i++) {
        final entity = relevanceKnowledgeList[i];
        knowledgePoints.add(
            EnContentRequest(content: entity.content, contentType: entity.contentType, contentId: entity.contentId ?? entity.uid, semanticId: entity.semanticId ?? entity.uid));
      }
    }

    final data = {
      'collectionId': collectionId,
      'theme': themeEn,
      'cefrLevels': targetCefrLevels.toList(),
      'sourceContent': contentCtrl.text,
      'sourceUrl': linkCtrl.text,
      'contents': knowledgePoints.map((e) => e.toJson()).toList(),
      'group': initGroup
    };
    final res = await SubscribeRequest.generalArticle(data);
    if (res?.success == true) {
      Get.back(result: true);
    } else {
      isGenerating = false;
    }
  }

  /// 关联知识点列表
  final RxList<Knowledge> relevanceKnowledgeList = <Knowledge>[].obs;

  /// 选择关联知识点
  Future<void> toRelevanceKnowledge(BuildContext context) async {
    final List<BaseKnowledge> existList = List<BaseKnowledge>.from(relevanceKnowledgeList);

    final value = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: existList,
      showSelectKnowledgeAddButton: true,
      dataDisableCallback: (BaseKnowledge targetEntity) {
        bool isDisable = false;
        for (final BaseKnowledge exist in existList) {
          if (exist.contentId == targetEntity.uid) {
            isDisable = true;
            break;
          }
        }
        return isDisable;
      },
    );

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
            audioUrl: entity.audioUrl,
          ));
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
          ));
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
          ));
        } else if (entity is EnTextEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.title,
            contentId: entity.uid,
            definition: entity.content,
            semanticId: null,
            imageUrl: null,
            audioUrl: null,
          ));
        }
      }

      relevanceKnowledgeList.addAll(newLs);
    }
  }

  /// 删除关联知识点
  void removeRelevanceKnowledge(int index) {
    try {
      relevanceKnowledgeList.removeAt(index);
    } catch (e) {
      print('删除knowledgeList异常: $e');
    }
  }
}
