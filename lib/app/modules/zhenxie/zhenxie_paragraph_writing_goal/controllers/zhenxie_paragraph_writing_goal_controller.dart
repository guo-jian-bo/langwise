import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/tag_routes.dart';

class ZhenxieParagraphWritingGoalController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieParagraphWritingGoalController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PARAGRAPH_WRITING_GOAL;

  @override
  String get breadcrumbTitle => "写作目标";

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;
  int? instanceUid;

  /// 段落/文章的步骤
  final RxList<ParagraphRhetoricalEntityList> paragraphRhetoricalList = <ParagraphRhetoricalEntityList>[].obs;

  /// 详情
  final Rx<ParagraphWritingGoalEntity> detailData = ParagraphWritingGoalEntity().obs;

  /// 当前选择的beatNid
  final RxString selectBeatNid = "".obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      isManagement = Get.arguments["isManagement"] ?? false;
      instanceUid = Get.arguments["instanceUid"];
      initData();
    }
  }

  Future<void> initData() async {
    if (instanceUid == null) return;
    try {
      ToastUtils.showLoading();
      await getParagraphRhetoricalList();
      await getDetail();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 段落/文章的步骤
  Future<void> getParagraphRhetoricalList() async {
    try {
      ParagraphRhetoricalEntity? entity = await LanguageUtil.getParagraphRhetoricalList();
      if (entity == null) return;
      List<ParagraphRhetoricalEntityList?> list = entity.list ?? [];
      paragraphRhetoricalList.clear();
      for (ParagraphRhetoricalEntityList? item in list) {
        if (item == null) continue;
        paragraphRhetoricalList.add(item);
      }
    } catch (_) {}
  }

  /// 获取详情
  Future<void> getDetail() async {
    if (instanceUid == null) return;
    try {
      ParagraphWritingGoalEntity? entity = await LanguageConsoleRequest.getParagraphWritingGoalDetail(instanceUid!);
      if (entity == null) return;
      detailData.value = entity;
      final beatSpanList = entity.beatSpanList??[];
      if(beatSpanList.isEmpty) return;
      selectBeatNid.value = beatSpanList.first?.beatNid ?? "";
    } catch (_) {}
  }

  /// 跳转至段落蓝图详情
  Future<void> jumpToParagraphDetail() async {
    String? nid = detailData.value.blueprint?.nid;
    if (nid == null) return;
    TagRoutes.toNamed(
      Routes.ZHENXIE_PARAGRAPH_BLUEPRINT_DETAILS,
      arguments: {
        "blueprintNid": nid,
        "isManagement": isManagement,
      },
    );
  }


  /// 切换步骤
  void switchBeat(ParagraphWritingGoalEntityBeatSpan? beatSpan) {
    if(beatSpan == null) return;
    selectBeatNid.value = beatSpan.beatNid ?? "";
  }

  /// 跳转至写作任务详情
  Future<void> jumpToTaskDetail(ParagraphWritingGoalEntityUsedInCompositions? usedInCompositions) async {
    TagRoutes.toNamed(
      Routes.ZHENXIE_TASK_DETAILS,
      arguments: {
        "isManagement": isManagement,
        "compositionUid": usedInCompositions?.uid,
        "contentSource": WritingBoardContentSourceMacro.exemplar.value,
        "editPolicy": WritingBoardEditPolicyMacro.readOnly.value,
        // "contentSource": WritingBoardContentSourceMacro.task.value,
        // "editPolicy": WritingBoardEditPolicyMacro.stageRule.value,
      },
    );
  }



}
