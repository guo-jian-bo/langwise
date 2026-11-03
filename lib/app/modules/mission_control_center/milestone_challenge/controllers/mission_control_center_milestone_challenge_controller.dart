import 'dart:async';

import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../utils/utils.dart';

class MissionControlCenterMilestoneChallengeController extends GetxController {
  final RxBool loading = false.obs;
  final RxBool metaLoading = false.obs;
  final RxBool actionLoading = false.obs;
  Timer? _nextDayTimer;
  int _analyseRequestId = 0;

  final Rx<MilestoneChallengeOverviewEntity> overview = MilestoneChallengeOverviewEntity().obs;
  final Rx<MilestoneChallengeHistoryEntity> history = MilestoneChallengeHistoryEntity().obs;
  final Rx<MilestoneChallengeMetaEntity> meta = MilestoneChallengeMetaEntity().obs;
  final Rxn<MilestoneChallengeAnalyseEntity> analyseResult = Rxn<MilestoneChallengeAnalyseEntity>();
  final Rxn<MilestoneChallengeItemEntity> detail = Rxn<MilestoneChallengeItemEntity>();

  List<MilestoneChallengeItemEntity> get activeGoals =>
      overview.value.activeGoals ?? const <MilestoneChallengeItemEntity>[];

  List<MilestoneChallengeItemEntity> get historyList =>
      history.value.list ?? const <MilestoneChallengeItemEntity>[];

  bool get canCreate => overview.value.canCreate ?? true;

  int get activeLimit => overview.value.activeLimit ?? meta.value.activeLimit ?? 3;
  int get activeCount => overview.value.activeCount ?? 0;
  int get claimableCount => activeGoals.where((item) => item.isClaimable).length;
  int get claimedCount => history.value.claimedCount ?? 0;
  int get voidedCount => history.value.voidedCount ?? 0;
  int get expiredCount => history.value.expiredCount ?? 0;

  @override
  void onInit() {
    super.onInit();
    nextDayRefresh();
  }

  Future<void> refreshData() async {
    loading.value = true;
    try {
      await Future.wait([
        ensureMeta(),
        loadOverview(),
        loadHistory(),
      ]);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadOverview() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseMilestoneChallengeOverview)) return;
    final result = await MilestoneChallengeRequest.getOverview();
    if (result != null) {
      overview.value = result;
    }
  }

  Future<void> loadHistory() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseMilestoneChallengeHistory)) return;
    final result = await MilestoneChallengeRequest.getHistory();
    if (result != null) {
      history.value = result;
    }
  }

  Future<void> ensureMeta() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseMilestoneChallengeMeta)) return;
    if ((meta.value.metrics ?? const []).isNotEmpty || metaLoading.value) return;
    metaLoading.value = true;
    try {
      final result = await MilestoneChallengeRequest.getMeta();
      if (result != null) {
        meta.value = result;
      }
    } finally {
      metaLoading.value = false;
    }
  }

  Future<MilestoneChallengeAnalyseEntity?> analyseDraft({
    required String startDate,
    required String endDate,
    required List<MilestoneChallengeDraftSubtaskRequest> subtasks,
  }) async {
    if (subtasks.isEmpty) {
      ToastUtils.showToast(text: '请至少添加一个子任务');
      return null;
    }
    final requestId = ++_analyseRequestId;
    actionLoading.value = true;
    try {
      final result = await MilestoneChallengeRequest.analyse(
        startDate: startDate,
        endDate: endDate,
        subtasks: subtasks,
      );
      if (requestId == _analyseRequestId) {
        analyseResult.value = result;
      }
      return result;
    } finally {
      if (requestId == _analyseRequestId) {
        actionLoading.value = false;
      }
    }
  }

  void resetAnalyseResult() {
    _analyseRequestId++;
    analyseResult.value = null;
    actionLoading.value = false;
  }

  Future<MilestoneChallengeItemEntity?> createChallenge(
    MilestoneChallengeCreateRequest request,
  ) async {
    actionLoading.value = true;
    try {
      final result = await MilestoneChallengeRequest.create(request);
      if (result != null) {
        ToastUtils.showToast(type: ToastType.success, text: '挑战创建成功');
        await refreshData();
      }
      return result;
    } finally {
      actionLoading.value = false;
    }
  }

  Future<MilestoneChallengeItemEntity?> loadDetail(
    int uid, {
    bool showLoading = true,
  }) async {
    if (showLoading) actionLoading.value = true;
    try {
      final result = await MilestoneChallengeRequest.getDetail(uid);
      if (result != null) {
        detail.value = result;
      }
      return result;
    } finally {
      if (showLoading) actionLoading.value = false;
    }
  }

  Future<bool> claimChallenge(int uid) async {
    actionLoading.value = true;
    try {
      final result = await MilestoneChallengeRequest.claim(uid);
      if (result == null) return false;
      detail.value = result;
      ToastUtils.showToast(type: ToastType.success, text: '奖励已兑现');
      await refreshData();
      return true;
    } finally {
      actionLoading.value = false;
    }
  }

  Future<bool> voidChallenge(int uid) async {
    actionLoading.value = true;
    try {
      final result = await MilestoneChallengeRequest.voidChallenge(uid);
      if (result == null) return false;
      detail.value = result;
      ToastUtils.showToast(text: '挑战已作废');
      await refreshData();
      return true;
    } finally {
      actionLoading.value = false;
    }
  }

  /// 0点刷新
  void nextDayRefresh() {
    _nextDayTimer?.cancel();
    final now = DateTime.now().toLocal();
    final nextDay = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    final refreshDuration = nextDay.difference(now);

    _nextDayTimer = Timer(refreshDuration, () async {
      await refreshData();
      nextDayRefresh();
    });
  }

  String metricTitle(String? metric) {
    switch (metric) {
      case 'MINUTES':
        return '学习时长';
      case 'STARS':
        return '星星数量';
      case 'GEMS':
        return '钻石数量';
      case 'STUDY_DAYS':
        return '学习天数';
      case 'PLAN_DAYS':
        return '完美计划';
      default:
        return '目标';
    }
  }

  String kindTitle(String? kind) {
    switch (kind) {
      case 'ACCUMULATE':
        return '累计';
      case 'QUALIFIED_DAYS':
        return '达标天数';
      case 'STREAK':
        return '连续';
      default:
        return '统计';
    }
  }

  String subtaskSummary(MilestoneChallengeSubtaskEntity item) {
    final current = item.currentValue ?? 0;
    final target = item.targetValue ?? 0;
    final unit = item.unit ?? '';
    return '$current / $target $unit';
  }

  String subtaskDescription(MilestoneChallengeSubtaskEntity item) {
    final title = metricTitle(item.metric);
    final kind = kindTitle(item.kind);
    if (item.metric == 'MINUTES' && item.kind == 'STREAK') {
      final threshold = item.dailyThresholdMinutes ?? 0;
      final targetDays = item.targetDays ?? item.targetValue ?? 0;
      return '需连续 $targetDays 天，每天至少 $threshold 分钟';
    }
    return '$kind$title目标';
  }

  @override
  void onClose() {
    _nextDayTimer?.cancel();
    super.onClose();
  }
}
