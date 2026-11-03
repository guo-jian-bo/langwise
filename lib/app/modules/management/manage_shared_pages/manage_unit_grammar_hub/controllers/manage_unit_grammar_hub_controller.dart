import 'dart:async';

import 'package:api/api.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/mqtt_utils/mqtt_message_services_code.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../routes/routes.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageUnitGrammarHubController extends GetxController
    with ManageBreadcrumbMixin {
  final String tag;
  ManageUnitGrammarHubController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT_GRAMMAR_HUB;

  @override
  String get breadcrumbTitle =>
      (unitName?.isNotEmpty ?? false) ? '$unitName · 单元语法' : '单元语法';

  int? unitId;
  String? unitName;
  String? moduleNameCn;

  final RxBool isLoading = true.obs;
  final RxString actionLoadingCode = ''.obs;
  final RxInt sentenceAnalyseLoadingUid = 0.obs;

  final Rx<ManageUnitGrammarHubEntity?> hubData =
      Rx<ManageUnitGrammarHubEntity?>(null);
  final Rx<ManageUnitGrammarSentenceListEntity?> sentenceData =
      Rx<ManageUnitGrammarSentenceListEntity?>(null);
  final Rxn<ManageUnitGrammarHeaderEntity> header = Rxn<ManageUnitGrammarHeaderEntity>();
  final RxList<ManageUnitGrammarPointEntity> points =
      <ManageUnitGrammarPointEntity>[].obs;
  final RxList<ManageUnitGrammarTargetTabEntity> targetTabs =
      <ManageUnitGrammarTargetTabEntity>[].obs;
  final RxList<ManageUnitGrammarSentenceTabEntity> sentenceTabs =
      <ManageUnitGrammarSentenceTabEntity>[].obs;
  final RxList<ManageUnitGrammarSentenceEntity> sentences =
      <ManageUnitGrammarSentenceEntity>[].obs;
  final RxList<ManageUnitGrammarPipelineStepEntity> steps =
      <ManageUnitGrammarPipelineStepEntity>[].obs;

  final RxString pane = 'targets'.obs;
  final RxString kindFilter = 'all'.obs;
  final RxInt pointFilter = 0.obs;
  final RxString sentenceQueue = 'bound'.obs;
  StreamSubscription<PushMessageServiceEnitiy>? _messageSub;
  Timer? _mqttRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    final arguments = Get.arguments;
    final Map args = arguments is Map ? arguments : const {};
    unitId = _parseInt(args['unitId']);
    unitName = args['unitName']?.toString();
    moduleNameCn = args['moduleNameCn']?.toString();

    fetchData(showLoading: true);

    _messageSub = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.MESSAGE_UNIT_GRAMMAR],
      whereBackPage: true,
      onData: (value) {
        if (!_shouldRefreshByMqtt(value.message)) return;
        _scheduleRefreshByMqtt();
      },
    );
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool _shouldRefreshByMqtt(PushMessageEntity message) {
    if (message.code != MqttMessageServicesCode.MESSAGE_UNIT_GRAMMAR) {
      return false;
    }
    final int? messageUnitId = _parseInt(message.jump?.params?['unitId']) ??
        _parseInt(message.jump?.params?['unitUid']);
    if (messageUnitId != null && messageUnitId != unitId) {
      return false;
    }
    return true;
  }

  void _scheduleRefreshByMqtt() {
    _mqttRefreshTimer?.cancel();
    _mqttRefreshTimer = Timer(const Duration(milliseconds: 500), () {
      if (isClosed) return;
      fetchData(showLoading: false);
    });
  }

  Future<void> fetchData({bool showLoading = false}) async {
    if (unitId == null) {
      ToastUtils.showManageToast(text: 'unitId为空');
      return;
    }

    if (showLoading) {
      ToastUtils.showLoading();
    }

    try {
      isLoading.value = true;
      final response = await Future.wait<dynamic>([
        UnitUtil.unitGrammarHub(
            unitId: unitId.toString(),
          config: RequestConfig(requireToken: true),
        ),
        UnitUtil.unitGrammarSentences(
            unitId: unitId.toString(),
          config: RequestConfig(requireToken: true),
        ),
      ]);

      final hubResponse = response[0] as ResponseEntity<ManageUnitGrammarHubEntity?>;
      final sentenceResponse =
          response[1] as ResponseEntity<ManageUnitGrammarSentenceListEntity?>;

      if (hubResponse.data == null) {
        ToastUtils.showManageToast(text: hubResponse.message ?? '单元语法数据加载失败');
        return;
      }

      hubData.value = hubResponse.data;
      sentenceData.value = sentenceResponse.data;
        unitName ??= hubResponse.data?.unitName;
        moduleNameCn ??= hubResponse.data?.moduleNameCn;
        header.value = hubResponse.data?.header;
        points.assignAll(hubResponse.data?.outline?.points ?? const []);
        targetTabs.assignAll(hubResponse.data?.targetTabs ?? const []);
        sentenceTabs.assignAll(sentenceResponse.data?.sentenceTabs ?? const []);
        sentences.assignAll(
          sentenceResponse.data?.sentenceView?.sentences ?? const [],
        );
        steps.assignAll(hubResponse.data?.pipeline?.steps ?? const []);
        _syncSentenceQueue();
    } catch (e) {
      ToastUtils.showManageToast(text: '单元语法数据加载失败');
    } finally {
      isLoading.value = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  void onChangePane(String value) {
    pane.value = value;
  }

  void onChangeKindFilter(String value) {
    kindFilter.value = value;
  }

  void onChangePointFilter(int? value) {
    pointFilter.value = value ?? 0;
  }

  void onChangeSentenceQueue(String value) {
    sentenceQueue.value = value;
  }

  void _syncSentenceQueue() {
    if (sentenceTabs.isEmpty) {
      sentenceQueue.value = 'bound';
      return;
    }
    final bool hasCurrentQueue =
        sentenceTabs.any((tab) => tab.code == sentenceQueue.value);
    if (hasCurrentQueue) return;
    final ManageUnitGrammarSentenceTabEntity? defaultTab =
        sentenceTabs.firstWhereOrNull((tab) => tab.code?.isNotEmpty == true);
    sentenceQueue.value = defaultTab?.code ?? 'bound';
  }

  Future<void> onRemoveSentenceFromUnit(int? sentenceUid) async {
    if (unitId == null || sentenceUid == null) return;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<String?>? response =
          await UnitUtil.removeUnitGrammarSentenceFromUnit(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          parameters: {
            'uid': sentenceUid,
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

  Future<void> onAnalyseSentence(ManageUnitGrammarSentenceEntity sentence) async {
    if (unitId == null || sentence.uid == null || sentenceAnalyseLoadingUid.value == sentence.uid) {
      return;
    }

    final List<int> targetUids = (sentence.targetBadges ?? const [])
        .map((badge) => badge.targetUid)
        .whereType<int>()
        .toList();
    if (targetUids.isEmpty) {
      ToastUtils.showManageToast(text: '当前句子还没有绑定 Target，暂不能分析');
      return;
    }

    sentenceAnalyseLoadingUid.value = sentence.uid!;
    ToastUtils.showLoading();
    try {
      final ResponseEntity<String>? response = await UnitUtil.analyseBoundUnitGrammarSentences(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetIds': targetUids,
          },
        ),
      );
      if (response == null || response.code != 200) return;
      ToastUtils.showManageToast(text: response.message ?? '已发起分析');
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '分析句子失败');
    } finally {
      sentenceAnalyseLoadingUid.value = 0;
      ToastUtils.hideLoading();
    }
  }

  Future<void> onOpenTargetDetails(
    ManageUnitGrammarTargetEntity target, {
    bool reviewQueue = false,
    List<int> reviewQueueUids = const [],
  }) async {
    if (unitId == null || target.uid == null) {
      ToastUtils.showManageToast(text: 'Target详情参数为空');
      return;
    }

    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIT_GRAMMAR_TARGET_DETAILS,
      arguments: {
        'unitId': unitId,
        'targetUid': target.uid,
        'reviewQueue': reviewQueue,
        'reviewQueueUids': reviewQueue ? reviewQueueUids : const [],
      },
    );
    await fetchData(showLoading: true);
  }

  List<ManageUnitGrammarTargetEntity> filteredTargets() {
    final allTargets = points.expand((e) => e.targets).toList();
    return allTargets.where((target) {
      final String currentKind = kindFilter.value;
      final int currentPoint = pointFilter.value;
      if (currentKind != 'all' && target.assetKind != currentKind) {
        return false;
      }
      if (currentPoint > 0 && target.pointOrder != currentPoint) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final int pointA = a.pointOrder ?? 0;
        final int pointB = b.pointOrder ?? 0;
        if (pointA != pointB) return pointA.compareTo(pointB);
        final int orderA = a.order ?? 0;
        final int orderB = b.order ?? 0;
        return orderA.compareTo(orderB);
      });
  }

  List<ManageUnitGrammarGroupedTargetsEntity> groupedTargets() {
    if (points.isEmpty) {
      return [
        ManageUnitGrammarGroupedTargetsEntity(
          point: null,
          targets: filteredTargets(),
        ),
      ];
    }

    return points
        .map((point) {
          final pointTargets = filteredTargets()
              .where((target) => target.pointOrder == point.pointOrder)
              .toList();
          return ManageUnitGrammarGroupedTargetsEntity(
            point: point,
            targets: pointTargets,
          );
        })
        .where((group) => group.targets.isNotEmpty)
        .toList();
  }

  List<ManageUnitGrammarSentenceEntity> boundSentences() {
    final int currentPoint = pointFilter.value;
    final list =
        sentences.where((e) => e.grammarBindStatus == 'bound').toList();
    if (currentPoint <= 0) return list;
    final allTargets = points.expand((e) => e.targets).toList();
    return list.where((sentence) {
      return (sentence.targetBadges ?? const []).any((badge) {
        final target = allTargets.firstWhereOrNull(
          (item) => item.uid == badge.targetUid,
        );
        return target?.pointOrder == currentPoint;
      });
    }).toList();
  }

  List<ManageUnitGrammarSentenceEntity> uncheckedSentences() =>
      sentences.where((e) => e.grammarBindStatus == 'unchecked').toList();

  List<ManageUnitGrammarSentenceEntity> notTargetSentences() =>
      sentences.where((e) => e.grammarBindStatus == 'not_target').toList();

  List<ManageUnitGrammarSentenceEntity> sentenceRows() {
    if (sentenceQueue.value == 'all') return sentences;
    if (sentenceQueue.value == 'unchecked') return uncheckedSentences();
    if (sentenceQueue.value == 'not_target') return notTargetSentences();
    return boundSentences();
  }

  int newCreatedSentenceCount() =>
      sentences.where((e) => e.access == 'INTERNAL').length;

  String getSentenceQueueLabel(String code) {
    final ManageUnitGrammarSentenceTabEntity? sentenceTab =
        sentenceTabs.firstWhereOrNull((tab) => tab.code == code);
    if (sentenceTab?.label?.isNotEmpty == true) {
      return sentenceTab!.label!;
    }
    if (code == 'all') return '全部';
    if (code == 'bound') return '已绑定';
    if (code == 'unchecked') return '未绑定';
    if (code == 'not_target') return '不符合单元语法';
    return code;
  }

  String getStepActionLabel(ManageUnitGrammarPipelineStepEntity step) {
    return step.actionText ?? '';
  }

  bool canRunStep(ManageUnitGrammarPipelineStepEntity step) {
    final String? code = step.code;
    final String? status = step.status;
    final String actionText = step.actionText ?? '';
    if (status == 'locked' || status == 'running' || status == 'skipped') {
      return false;
    }
    if (actionText.isEmpty) return false;
    if (actionLoadingCode.value.isNotEmpty &&
        actionLoadingCode.value == step.code) {
      return false;
    }
    final bool hasOtherLoading = actionLoadingCode.value.isNotEmpty &&
        actionLoadingCode.value != step.code;
    final bool hasOtherRunning =
        steps.any((e) => e.code != step.code && e.status == 'running');
    if (hasOtherLoading || hasOtherRunning) {
      return false;
    }
    if (status == 'done') {
      return code == 'analyze';
    }
    return status == 'todo' || status == 'failed';
  }

  Future<void> runStep(ManageUnitGrammarPipelineStepEntity step) async {
    final String? code = step.code;
    if (code == null || !canRunStep(step) || unitId == null) return;

    if (code == 'review') {
        await openReviewQueue();
      return;
    }

    actionLoadingCode.value = code;
    try {
      if (code == 'analyze') {
        await _runAnalyze();
      } else if (code == 'bind_targets') {
        await _runBindTargets();
      } else if (code == 'match_deficit') {
        await _runMatchDeficit();
      } else if (code == 'create_auto') {
        await _runCreateAuto();
      } else if (code == 'analyse_bound') {
        await _runAnalyseBound();
      } else if (code == 'generate_grammar_course') {
        await _runGenerateGrammarCourse();
      } else if (code == 'generate_writing_course') {
        await _runGenerateWritingCourse();
      } else {
        ToastUtils.showManageToast(text: step.summary ?? '暂未实现');
      }
    } finally {
      actionLoadingCode.value = '';
    }
  }

  Future<void> openReviewQueue() async {
    final List<ManageUnitGrammarTargetEntity> candidateTargets =
        filteredTargets()
            .where((target) => target.status == 'candidate')
            .toList()
          ..sort((a, b) {
            final int pointCompare =
                (a.pointOrder ?? 0).compareTo(b.pointOrder ?? 0);
            if (pointCompare != 0) return pointCompare;
            final int orderCompare = (a.order ?? 0).compareTo(b.order ?? 0);
            if (orderCompare != 0) return orderCompare;
            return (a.uid ?? 0).compareTo(b.uid ?? 0);
          });
    if (hubData.value?.reviewEntry?.hasCandidate != true ||
        candidateTargets.isEmpty) {
      ToastUtils.showManageToast(text: '当前没有待审核 Target');
      return;
    }

    pane.value = 'targets';
    kindFilter.value = 'all';
    final ManageUnitGrammarTargetEntity candidate = candidateTargets.first;
    if (candidate.pointOrder != null) {
      pointFilter.value = candidate.pointOrder!;
    }
    await onOpenTargetDetails(
      candidate,
      reviewQueue: true,
      reviewQueueUids: candidateTargets.map((e) => e.uid).whereType<int>().toList(),
    );
  }

  Future<void> _runAnalyze() async {
    final ManageUnitGrammarPipelineStepEntity? analyzeStep = steps
        .firstWhereOrNull((step) => step.code == 'analyze');
    final bool isRegenerate = analyzeStep?.status == 'done';
    if (isRegenerate) {
      final bool askRes = await AskDialog.showUserAsk(
        context: Get.context!,
        content: '重新生成会覆盖当前大纲与 Target，并清空后续产线进度，确认继续吗？',
        cancel: '取消',
        define: '确认',
      );
      if (!askRes) return;
    }
    if (unitId == null) return;

    ToastUtils.showLoading();
    try {
      final response = await UnitUtil.generateUnitGrammar(
          unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
            data: isRegenerate ? {'updateExists': true} : const {},
        ),
      );
      if (response?.code != 200) return;
      ToastUtils.showManageToast(text: response?.message ?? '操作成功');
      await fetchData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> _runBindTargets() async {
    if (unitId == null) return;

    ToastUtils.showLoading();
    try {
      final response = await UnitUtil.bindUnitGrammarTargets(
          unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.code != 200) return;
      ToastUtils.showManageToast(text: response?.message ?? '操作成功');
      await fetchData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> _runMatchDeficit() async {
    if (unitId == null) return;

    ToastUtils.showLoading();
    try {
      final response = await UnitUtil.matchUnitGrammarDeficit(
          unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.code != 200) return;
      ToastUtils.showManageToast(text: response?.message ?? '操作成功');
      await fetchData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> _runCreateAuto() async {
    if (unitId == null) return;

    ToastUtils.showLoading();
    try {
      final response = await UnitUtil.createUnitGrammarAuto(
          unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: const {'onlyDeficit': true},
        ),
      );
      if (response?.code != 200) return;
      ToastUtils.showManageToast(text: response?.message ?? '操作成功');
      await fetchData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> _runAnalyseBound() async {
    if (unitId == null) return;

    ToastUtils.showLoading();
    try {
      final response = await UnitUtil.analyseBoundUnitGrammarSentences(
          unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.code != 200) return;
      ToastUtils.showManageToast(text: response?.message ?? '操作成功');
      await fetchData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> _runGenerateGrammarCourse() async {
    if (unitId == null) return;

    ToastUtils.showLoading();
    try {
      final response = await UnitUtil.generateUnitGrammarCourse(
        unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.code != 200) return;
      ToastUtils.showManageToast(text: response?.message ?? '操作成功');
      await fetchData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> _runGenerateWritingCourse() async {
    ToastUtils.showManageToast(text: '暂未实现');
  }

  @override
  void onClose() {
    _messageSub?.cancel();
    _mqttRefreshTimer?.cancel();
    super.onClose();
  }
}

class ManageUnitGrammarGroupedTargetsEntity {
  final ManageUnitGrammarPointEntity? point;
  final List<ManageUnitGrammarTargetEntity> targets;

  const ManageUnitGrammarGroupedTargetsEntity({
    required this.point,
    required this.targets,
  });
}
