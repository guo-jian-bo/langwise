import 'package:api/entities/response.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/common/https/manage_english_content_management_song_request.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/manage_breadcrumb_utils.dart';

class ManageCoreKnowledgeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCoreKnowledgeController({required this.tag});

  int? uid; //id
  String? type; //类型

  Rx<ManageEnglishContentManagementSongKnowledgeStatisticsModel> knowledgeData = ManageEnglishContentManagementSongKnowledgeStatisticsModel().obs;
  List<ManageEnglishContentManagementSongKnowledgeModel> allList = [];
  List<ManageEnglishContentManagementSongKnowledgeModel> wordList = [];
  List<ManageEnglishContentManagementSongKnowledgeModel> phraseList = [];
  List<ManageEnglishContentManagementSongKnowledgeModel> sentenceList = [];

  RxString currentSelectOption = '全部'.obs;

  /// 是否显示未匹配
  bool hasUnmatched = true;

  int? selectedIndex;

  @override
  String get breadcrumbRoute => Routes.MANAGE_CORE_KNOWLEDGE;

  @override
  String get breadcrumbTitle => '核心知识点';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    uid = Get.arguments?["uid"];
    type = Get.arguments?["type"];

    getContentData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// 获取内容数据
  Future<void> getContentData() async {
    currentSelectOption.value = '全部';
    wordList.clear();
    phraseList.clear();
    sentenceList.clear();
    allList.clear();

    try {
      ToastUtils.showLoading();

      ManageEnglishContentManagementSongKnowledgeStatisticsModel? res = await ManageEnglishContentManagementSongRequest.getContentKnowledge(
        parameters: {
          "uid": uid,
          "type": type,
        },
      );
      if(res == null) return;
      knowledgeData.value = res;

      for (var element in res.contentKnowledge ?? []) {
        if (element.contentType == "EN_WORD") {
          wordList = element.contentSimpleList ?? [];
        } else if (element.contentType == "EN_PHRASE") {
          phraseList = element.contentSimpleList ?? [];
        } else if (element.contentType == "EN_SENTENCE") {
          sentenceList = element.contentSimpleList ?? [];
        }
      }

      allList = wordList + phraseList + sentenceList;

      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 添加知识点
  Future<void> addKnowledge(context) async {
    // 选择知识点
    var value = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: [],
      language: 'en',
      showSelectKnowledgeAddButton: true,
      singleSelectionMode: true,
      hideText: true,
    );

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
        }
      }
    }
    if (newLs.isEmpty) {
      return;
    }

    //添加请求
    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await ManageEnglishContentManagementSongRequest.deleteKnowledge(
        'add',
        parameters: {
          "uid": uid,
          "type": type,
        },
        data: {
          "uid": newLs.first.uid,
          "type": newLs.first.contentType,
          "semanticId": newLs.first.semanticId,
        },
      );
      if (res == null) {
        return;
      }
      ToastUtils.showManageToast(text: '添加成功');
      getContentData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除知识点
  Future<void> deleteKnowledge(ManageEnglishContentManagementSongKnowledgeModel knowledge) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要删除这个知识点吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await ManageEnglishContentManagementSongRequest.deleteKnowledge(
        'remove',
        parameters: {
          "uid": uid,
          "type": type,
        },
        data: {
          "uid": knowledge.contentId,
          "type": knowledge.contentType,
          "semanticId": knowledge.semanticId,
        },
      );
      if (res == null) {
        return;
      }
      ToastUtils.showManageToast(text: '删除成功');
      getContentData();
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
