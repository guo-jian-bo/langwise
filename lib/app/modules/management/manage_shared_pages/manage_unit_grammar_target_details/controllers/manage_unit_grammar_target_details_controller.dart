import 'package:api/api.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../elements/utils/elements_page_utils.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../views/manage_unit_grammar_target_details_dialogs.dart';

class ManageUnitGrammarTargetDetailsController extends GetxController
    with ManageBreadcrumbMixin {
  final String tag;
  ManageUnitGrammarTargetDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT_GRAMMAR_TARGET_DETAILS;

  @override
  String get breadcrumbTitle =>
      (target.value?.title?.isNotEmpty ?? false)
          ? '${target.value?.title} · Target详情'
          : 'Target详情';

  int? unitId;
  int? targetUid;
  bool reviewQueue = false;
  final RxList<int> reviewQueueUids = <int>[].obs;
  final RxMap<int, String> reviewQueueStatuses = <int, String>{}.obs;

  final RxBool isLoading = true.obs;
  final RxBool isSentenceAnalyseRunning = false.obs;

  /// 详情原始返回，便于后续扩展直接追源。
  final Rxn<ManageUnitGrammarTargetDetailEntity> detailData =
      Rxn<ManageUnitGrammarTargetDetailEntity>();
  final Rxn<ManageUnitGrammarTargetDetailTargetEntity> target =
      Rxn<ManageUnitGrammarTargetDetailTargetEntity>();
  final Rxn<ManageUnitGrammarTargetDetailAssetViewEntity> assetView =
      Rxn<ManageUnitGrammarTargetDetailAssetViewEntity>();
  final Rxn<PatternBlueprintEntity> patternBlueprint =
      Rxn<PatternBlueprintEntity>();
  final Rxn<SentencePatternCompareEntity> paradigmCompareData =
      Rxn<SentencePatternCompareEntity>();
  final RxMap<String, dynamic> grammarStructPayload = <String, dynamic>{}.obs;
  final Rxn<ManageUnitGrammarTargetDetailQuotaEntity> quota =
      Rxn<ManageUnitGrammarTargetDetailQuotaEntity>();
  final RxList<ManageUnitGrammarTargetDetailLexicalAnchorEntity> lexicalAnchors =
      <ManageUnitGrammarTargetDetailLexicalAnchorEntity>[].obs;
  final RxList<ManageUnitGrammarTargetDetailSentenceEntity> sentences =
      <ManageUnitGrammarTargetDetailSentenceEntity>[].obs;
  final Rxn<ManageUnitGrammarTargetDetailReviewEntity> review =
      Rxn<ManageUnitGrammarTargetDetailReviewEntity>();

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    final arguments = Get.arguments;
    final Map args = arguments is Map ? arguments : const {};
    unitId = _parseInt(args['unitId']);
    targetUid = _parseInt(args['targetUid']);
    reviewQueue = args['reviewQueue'] == true;
    reviewQueueUids.assignAll(_parseIntList(args['reviewQueueUids']));
    if (reviewQueueUids.isEmpty) {
      reviewQueue = false;
    }

    fetchData(showLoading: true);
  }

  /// 统一解析页面入参里的数字字段。
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  List<int> _parseIntList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(_parseInt)
        .whereType<int>()
        .toList();
  }

  /// 拉取当前 Target 详情，并把页面直用字段显式落到本地状态。
  Future<void> fetchData({bool showLoading = false}) async {
    if (unitId == null || targetUid == null) {
      ToastUtils.showManageToast(text: 'Target详情参数为空');
      return;
    }

    if (showLoading) {
      ToastUtils.showLoading();
    }

    try {
      isLoading.value = true;
      final ResponseEntity<ManageUnitGrammarTargetDetailEntity?>? response =
          await UnitUtil.unitGrammarTargetDetail(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          parameters: {
            'targetUid': targetUid,
          },
        ),
      );

      if (response?.data == null) {
        ToastUtils.showManageToast(
          text: response?.message ?? 'Target详情加载失败',
        );
        return;
      }

      detailData.value = response!.data;
      target.value = response.data?.target;
      assetView.value = response.data?.assetView;
      patternBlueprint.value = response.data?.grammarStructInfo?.payload;
      grammarStructPayload.assignAll(
        response.data?.grammarStructInfo?.payloadRaw ?? const {},
      );
      paradigmCompareData.value = grammarStructPayload.isEmpty
          ? null
          : SentencePatternCompareEntity.fromJson(grammarStructPayload);
      quota.value = response.data?.quota;
      lexicalAnchors.assignAll(response.data?.lexicalAnchors ?? const []);
      sentences.assignAll(response.data?.sentences ?? const []);
      review.value = response.data?.review;
      if (!sentences.any((item) => item.hasStructure != true)) {
        isSentenceAnalyseRunning.value = false;
      }
      if (reviewQueue && targetUid != null && target.value?.status != null) {
        reviewQueueStatuses[targetUid!] = target.value!.status!;
      }
    } catch (e) {
      ToastUtils.showManageToast(text: 'Target详情加载失败');
    } finally {
      isLoading.value = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  /// 当前页面先只对 pattern 做完整渲染，其余资产先占位。
  bool isPatternTarget() {
    final String? kind = assetView.value?.kind ?? target.value?.assetKind;
    return kind == 'pattern';
  }

  bool isPatternOrPyramidTarget() {
    final String? kind = assetView.value?.kind ?? target.value?.assetKind;
    return kind == 'pattern' || kind == 'pyramid';
  }

  bool isPairTarget() {
    final String? kind = assetView.value?.kind ?? target.value?.assetKind;
    return kind == 'pair';
  }

  bool isParadigmTarget() {
    final String? kind = assetView.value?.kind ?? target.value?.assetKind;
    return kind == 'paradigm';
  }

  /// 右上角“搜索库里已有句子 / 生成句子”按钮的可用条件。
  bool canOperatePatternActions() {
    return isPatternTarget() && target.value?.status == 'approved';
  }

  bool isAdvancedPracticeTarget() {
    final String? kind = assetView.value?.kind ?? target.value?.assetKind;
    return kind == 'pair' ||
        kind == 'pair_fork' ||
        kind == 'paradigm' ||
        kind == 'pyramid' ||
        kind == 'grid';
  }

  bool canOperateAdvancedPractice() {
    return isAdvancedPracticeTarget() && target.value?.status == 'approved';
  }

  bool hasReviewQueue() {
    return reviewQueue && reviewQueueUids.isNotEmpty;
  }

  int currentReviewQueueIndex() {
    if (!hasReviewQueue() || targetUid == null) return -1;
    return reviewQueueUids.indexOf(targetUid!);
  }

  int currentReviewQueueOrder() {
    final int index = currentReviewQueueIndex();
    if (index < 0) return 0;
    return index + 1;
  }

  int reviewQueueTotalCount() {
    return reviewQueueUids.length;
  }

  int remainingReviewQueueCandidateCount() {
    if (!hasReviewQueue()) return 0;
    return reviewQueueUids.where((uid) {
      final String? status = reviewQueueStatuses[uid];
      return status == null || status == 'candidate';
    }).length;
  }

  int? getPreviousReviewTargetUid() {
    final int index = currentReviewQueueIndex();
    if (index <= 0) return null;
    return reviewQueueUids[index - 1];
  }

  int? getNextReviewTargetUid() {
    final int index = currentReviewQueueIndex();
    if (index < 0 || index >= reviewQueueUids.length - 1) return null;
    return reviewQueueUids[index + 1];
  }

  int? findNextCandidateTargetUid() {
    if (!hasReviewQueue()) return null;
    final int currentIndex = currentReviewQueueIndex();
    final int takeCount = (currentIndex + 1).clamp(0, reviewQueueUids.length).toInt();
    final List<int> orderedUids = <int>[
      ...reviewQueueUids.skip(currentIndex + 1),
      ...reviewQueueUids.take(takeCount),
    ];
    for (final uid in orderedUids) {
      final String? status = reviewQueueStatuses[uid];
      if (status == null || status == 'candidate') {
        return uid;
      }
    }
    return null;
  }

  Future<void> onTapSearchLibrary() async {
    if (!canOperatePatternActions()) {
      ToastUtils.showManageToast(text: '先把本 Target 标成通过，才能匹配或生成');
      return;
    }

    ToastUtils.showLoading();
    try {
      final ResponseEntity<ManageUnitGrammarMatchPreviewEntity?>? response =
          await UnitUtil.previewUnitGrammarTargetMatch(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
          },
        ),
      );

      ToastUtils.hideLoading();
      if (response == null) {
        ToastUtils.showManageToast(text: '搜索库句失败');
        return;
      }

      final List<ManageUnitGrammarMatchCandidateEntity> matches =
          response.data?.matches ?? const [];
      final List<int>? selectedIds =
          await ManageUnitGrammarTargetDetailsDialogs.showMatchPreviewDialog(
        matches: matches,
      );

      if (selectedIds == null || selectedIds.isEmpty) return;

      ToastUtils.showLoading();
      final ResponseEntity<ManageUnitGrammarAppendSelectedEntity?>? saveResponse =
          await UnitUtil.appendUnitGrammarTargetSelectedSentences(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
            'contentIds': selectedIds,
          },
        ),
      );

      ToastUtils.showManageToast(
        text: saveResponse?.message ?? '保存选中成功',
      );
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '搜索库句失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onTapGenerateSentence() async {
    if (!canOperatePatternActions()) {
      ToastUtils.showManageToast(text: '先把本 Target 标成通过，才能匹配或生成');
      return;
    }

    final int? count = await ManageUnitGrammarTargetDetailsDialogs.showCreateCountDialog(
      title: '生成几句？',
      description: '只给当前这条 Target 加句，范围 1-6。',
      min: 1,
      max: 6,
      confirmText: '生成',
    );
    if (count == null) return;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<String>? response =
          await UnitUtil.createUnitGrammarSentenceByPattern(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
            'count': count,
          },
        ),
      );

      ToastUtils.showManageToast(text: response?.message ?? '已发起生成');
      await ManageUnitGrammarTargetDetailsDialogs.showGeneratingHintDialog();
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '生成句子失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onTapAdvancedPractice() async {
    if (!canOperateAdvancedPractice()) {
      ToastUtils.showManageToast(text: '先把本 Target 标成通过，才能高阶加练');
      return;
    }

    final int? count = await ManageUnitGrammarTargetDetailsDialogs.showCreateCountDialog(
      title: '生成几组？',
      description: '只给当前这条高阶 Target 加练，范围 1-3 组。',
      min: 1,
      max: 3,
      confirmText: '生成',
    );
    if (count == null) return;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<String>? response =
          await UnitUtil.createUnitGrammarSentenceByRelation(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
            'count': count,
          },
        ),
      );
      if (response == null || response.code != 200) return;

      ToastUtils.showManageToast(text: response.message ?? '已发起高阶加练');
      await ManageUnitGrammarTargetDetailsDialogs.showGeneratingHintDialog();
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '高阶加练失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void onTapSlotDetails() {
    ToastUtils.showManageToast(text: '槽位详情待接入');
  }

  Future<void> onTapExpandStudy(
    ManageUnitGrammarTargetDetailSentenceEntity sentence,
  ) async {
    if (sentence.contentId == null) {
      ToastUtils.showManageToast(text: '当前句子缺少 contentId');
      return;
    }

    await ElementsPageUtils.jumpElementsPage(
      contentId: sentence.contentId,
      contentType: KnowledgeTypeEnum.EN_SENTENCE.value,
      semanticId: sentence.semanticId,
      content: sentence.content,
      styleId: null,
      dialect: null,
    );
  }

  Future<void> onAnalyseSentence() async {
    if (unitId == null || targetUid == null || isSentenceAnalyseRunning.value) {
      return;
    }

    ToastUtils.showLoading();
    isSentenceAnalyseRunning.value = true;
    try {
      final ResponseEntity<String>? response = await UnitUtil.analyseUnitGrammarSentence(
        config: RequestConfig(
          requireToken: true,
          data: {
            'unit_id': unitId,
            'target_ids': [targetUid],
          },
        ),
      );
      if (response == null || response.code != 200) {
        isSentenceAnalyseRunning.value = false;
        return;
      }
      ToastUtils.showManageToast(text: response.message ?? '已发起分析');
      await fetchData();
    } catch (e) {
      isSentenceAnalyseRunning.value = false;
      ToastUtils.showManageToast(text: '分析语法失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  PatternBlueprintSentenceBriefEntity? findSentenceRealizationByContentId(
    int? contentId,
  ) {
    if (contentId == null) return null;
    final List<PatternBlueprintSentenceBriefEntity?> sentenceRealizationList =
        patternBlueprint.value?.sentenceRealizationList ?? const [];
    for (final item in sentenceRealizationList) {
      if (item?.sentenceId == contentId) {
        return item;
      }
    }
    return null;
  }

  Future<void> onRemoveFromGrammar(int? knowledgeUid) async {
    if (unitId == null || targetUid == null || knowledgeUid == null) return;
    // final bool askRes = await AskDialog.showUserAsk(
    //   context: Get.context!,
    //   content: '确认将这句从当前语法 Target 移除吗？',
    //   cancel: '取消',
    //   define: '确认',
    // );
    // if (!askRes) return;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<String>? response =
          await UnitUtil.removeUnitGrammarTargetSentence(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
            'knowledgeUid': knowledgeUid,
          },
        ),
      );
      if (response == null || response.code != 200) return;
      ToastUtils.showManageToast(text: response.message ?? '已从语法移除');
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '从语法移除失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onRemoveFromUnit(int? knowledgeUid) async {
    if (unitId == null || knowledgeUid == null) return;
    // final bool askRes = await AskDialog.showUserAsk(
    //   context: Get.context!,
    //   content: '确认将这句从当前单元移除吗？',
    //   cancel: '取消',
    //   define: '确认',
    // );
    // if (!askRes) return;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<String?>? response =
          await UnitUtil.removeUnitGrammarSentenceFromUnit(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          parameters: {
            'uid': knowledgeUid,
            'flag': 1,
          },
        ),
      );
      if (response == null || response.code != 200) return;
      ToastUtils.showManageToast(text: response.message ?? '已从单元移除');
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '从单元移除失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onReviewStatus(String status) async {
    if (unitId == null || targetUid == null) return;
    final int currentUid = targetUid!;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<ManageUnitGrammarTargetStatusUpdateEntity?>? response =
          await UnitUtil.updateUnitGrammarTargetStatus(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
            'status': status,
          },
        ),
      );

      if (response == null || response.code != 200) return;

      reviewQueueStatuses[currentUid] = status;
      ToastUtils.showManageToast(text: response.message ?? '审核状态更新成功');

      if (hasReviewQueue()) {
        if (status == 'candidate') {
          await fetchData();
          return;
        }
        if (response.data?.reviewCompleted == true ||
            remainingReviewQueueCandidateCount() <= 0) {
          Get.back();
          return;
        }
        final int? nextTargetUid = findNextCandidateTargetUid();
        if (nextTargetUid != null) {
          targetUid = nextTargetUid;
          await fetchData();
          return;
        }
        Get.back();
        return;
      }

      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '审核状态更新失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onOpenReviewQueueTarget(int? nextTargetUid) async {
    if (!hasReviewQueue() || nextTargetUid == null) return;
    targetUid = nextTargetUid;
    await fetchData(showLoading: true);
  }
}
