import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../../../create_study_plan/controllers/create_study_plan_controller.dart';
import '../../../today_plan/controllers/today_plan_controller.dart';
import '../common/user_evaluation_level_share_dialog.dart';

class UserEvaluationLevelController extends GetxController {
  /// 传进来的参数 评测id
  int? assessmentId;

  final Rx<AssessmentResultDetailEntity> resultDetail = AssessmentResultDetailEntity().obs;
  final Rx<List<AssessmentHistoryItemEntity>> assessmentHistory = Rx<List<AssessmentHistoryItemEntity>>([]);
  final Rx<CurrentMemberInfoEntity?> currentMemberInfo = Rx<CurrentMemberInfoEntity?>(null);
  final Rx<AiAssessmentResultDetailEntity?> aiResultDetail = Rx<AiAssessmentResultDetailEntity?>(null);

  /// 生成图片页面key
  final GlobalKey sharePageKey = GlobalKey();

  Uint8List? shareImage;

  final PersonalizedLearningPlanController learningPlanController = PersonalizedLearningPlanController();

  final RxInt reportDurationSec = 0.obs;
  Timer? _reportTimer;
  bool _reportCountdownTriggeredRefresh = false;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      assessmentId = Get.arguments["assessmentId"];
    }
    initData();
  }

  Future<void> initData() async {
    getAssessmentHistory();
    getAssessmentResultDetail();
    getCurrentMemberInfo();
  }

  Future<void> getCurrentMemberInfo() async {
    final info = await UserRequest.getCurrentMemberInfo();
    if (info == null) return;
    currentMemberInfo.value = info;
  }

  Future<void> getAssessmentResultDetail() async {
    try {
      shareImage = null;
      ToastUtils.showLoading();
      AiAssessmentResultDetailEntity? resp;
      if (assessmentId != null) {
        resp = await PracticeQuestionsReqest.getAiAssessmentResultDetail(assessmentId!);
      } else {
        resp = await PracticeQuestionsReqest.getUserAiAssessmentResultDetail();
      }
      if (resp == null) return;
      aiResultDetail.value = resp;
      resultDetail.value = resp.base;
      _syncReportCountdown();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void _syncReportCountdown() {
    final seconds = resultDetail.value.reportDuration ?? 0;
    _startReportCountdown(seconds);
  }

  void _startReportCountdown(int seconds) {
    _reportTimer?.cancel();
    _reportTimer = null;

    final s = seconds < 0 ? 0 : seconds;
    reportDurationSec.value = s;
    if (s <= 0) return;

    _reportCountdownTriggeredRefresh = false;
    _reportTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = reportDurationSec.value - 1;
      if (next <= 0) {
        reportDurationSec.value = 0;
        timer.cancel();
        _reportTimer = null;

        if (!_reportCountdownTriggeredRefresh) {
          _reportCountdownTriggeredRefresh = true;
          getAssessmentResultDetail();
        }
      } else {
        reportDurationSec.value = next;
      }
    });
  }

  Future<void> assessmentPay(BuildContext context) async {
    if (reportDurationSec.value > 0) {
      ToastUtils.showToast(text: '上一次评测结果正在生成中，无法开始新一次的评测');
      return;
    }
    await PracticeQuestionsReqest.startToAssessment(context, closeCurrentPage: true);
  }

  Future<void> getAssessmentHistory() async {
    final resp = await PracticeQuestionsReqest.getAssessmentHistory(0, 3);
    if (resp == null) return;
    assessmentHistory.value = resp.datas;
  }

  List<PersonalizedLearningPlanPageData> get learningPlanPages {
    final detail = aiResultDetail.value;
    final rights = detail?.base.planRights;
    final plan = detail?.plan;
    if (plan == null) return const [];

    PersonalizedLearningPlanPageData buildPage(String id, List<AiAssessmentPlanCardEntity> cards, List<Color> colors) {
      final cardDatas = <PersonalizedLearningPlanCardData>[];
      for (var i = 0; i < cards.length; i++) {
        final c = cards[i];
        final minutes = ((c.dailyStudyDuration ?? 0) / 60).round();
        final range = c.tierRange;
        final String? levelText;
        if (range == null) {
          levelText = null;
        } else if (range.max == null && range.min != null) {
          levelText = 'L${range.min}';
        } else if (range.min == null && range.max != null) {
          levelText = 'L0 → L${range.max}';
        } else if (range.min != null && range.max != null) {
          if (range.min == range.max) {
            levelText = 'L${range.min}';
          } else {
            levelText = 'L${range.min} → L${range.max}';
          }
        } else {
          levelText = null;
        }

        final statusText = c.status == 'EXECUTED'
            ? '已完成'
            : c.status == "RUNNING"
                ? '进行中'
                : c.status == "READY"
                    ? "可执行"
                    : "待执行";

        final icons = <PersonalizedLearningPlanIconData>[];
        for (int i = 0; i < c.directionList.length; i++) {
          AiAssessmentPlanDirectionEntity d = c.directionList[i];
          final title = LearningLangUtils.getLocalLang(d.title)?.text ?? '';
          if (title.isEmpty) continue;
          icons.add(
            PersonalizedLearningPlanIconData(
              heroTag: '${id}_${i}_${d.direction ?? title}',
              title: title,
              svgAsset: d.iconUrl,
              selected: !(d.exclude ?? false),
            ),
          );
        }

        cardDatas.add(
          PersonalizedLearningPlanCardData(
              id: '${id}_card_$i',
              title: c.name ?? '',
              levelName: c.levelName,
              rights: rights,
              type: id,
              subTitle: c.description,
              levelText: levelText,
              statusText: statusText,
              minutesPerDay: minutes,
              startPoint: range?.min ?? 0,
              semester: c.semester ?? 0,
              gradient: colors,
              icons: icons,
              moduleId: c.moduleId,
              levelId: c.levelId,
              moduleInfoList: c.moduleInfoList,
              directionList: c.directionList,
              description: c.description ?? '',
              isEnable: c.status == "READY" || c.status == "RUNNING",
              courseId: c.courseId,
              status: c.status,
              trigger: c.trigger),
        );
      }

      return PersonalizedLearningPlanPageData(id: id, cards: cardDatas);
    }

    final pages = <PersonalizedLearningPlanPageData>[];
    if (plan.official.isNotEmpty) {
      pages.add(
        buildPage(
          'official',
          plan.official,
          const [
            Color(0xFF22D3EE),
            Color(0xFF0891B2),
          ],
        ),
      );
    }
    if (plan.textbook.isNotEmpty) {
      pages.add(
        buildPage(
          'textbook',
          plan.textbook,
          const [
            Color(0xFF00D492),
            Color(0xFF009966),
          ],
        ),
      );
    }
    if (plan.phonics.isNotEmpty) {
      pages.add(
        buildPage(
          'phonics',
          plan.phonics,
          const [
            Color(0xFFC084FC),
            Color(0xFF9333EA),
          ],
        ),
      );
    }

    return pages;
  }

  Future<void> selectLevel(BuildContext context) async {
    SelectUserLanguageLevelDialog.show(
      context: context,
    );
  }

  /// 获得学习计划
  Future<void> getLearningPlan(BuildContext context) async {
    if (await LockUtils.checkLock(resultDetail.value.planRights, context)) return;

    if (resultDetail.value.isPlan ?? false) {
      // 有官方课程的计划 去计划列表

      // 判断路由堆栈中是否有计划列表页面
      if (Get.isRegistered<TodayPlanController>()) {
        // 回退到计划列表页面
        Get.until((route) => route.settings.name == Routes.TODAY_PLAN);
      } else {
        await Get.toNamed(Routes.TODAY_PLAN);
        getAssessmentResultDetail();
      }
    } else {
      dynamic resp = await Get.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
        arguments: {
          "courseId": resultDetail.value.recommendCourseId,
          "showUnit": true,
          "showRecommend": true,
          "scrollToStudyZoneEnum": StudyZoneEnum.study,
        },
      );
      if (resp == null) return;

      if (Get.isRegistered<CreateStudyPlanController>()) {
        //页面堆栈中有创建计划页面 给此页面设置起点 并初始化所有
        CreateStudyPlanController createStudyPlanController = Get.find<CreateStudyPlanController>();
        try {
          ToastUtils.showLoading();
          createStudyPlanController.initStartUnit = resp;
          await createStudyPlanController.setInitCourseAndStartPosition(isPush: false);
        } finally {
          ToastUtils.hideLoading();
        }

        Get.until((route) => route.settings.name == Routes.CREATE_STUDY_PLAN);
      } else {
        Get.toNamed(Routes.CREATE_STUDY_PLAN, arguments: {
          "initStartUnit": resp,
        });
      }
    }
  }

  /// 重新评测
  Future<void> reEvaluation(BuildContext context) async {
    if (reportDurationSec.value > 0) {
      ToastUtils.showToast(text: '上一次评测结果正在生成中，无法开始新一次的评测');
      return;
    }
    Get.toNamed(Routes.USER_EVALUATION, arguments: {"isFromEvaResult": true});
  }

  /// 弹出分享弹窗
  Future<void> showShareDialog(BuildContext context) async {
    final int? prevPageIndex = learningPlanController.currentPageIndex;
    try {
      if (learningPlanController.isAttached && (learningPlanController.currentPageIndex ?? 0) != 1) {
        learningPlanController.jumpToPage(1);
        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(const Duration(milliseconds: 16));
        shareImage = null;
      }

      if (shareImage == null) {
        ToastUtils.showLoading();
        RenderRepaintBoundary? boundary = sharePageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;
        ui.Image image = await boundary.toImage(pixelRatio: 1.0); // 像素比率，值越大图片越清晰
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        shareImage = byteData?.buffer.asUint8List();
        if (shareImage == null) return;
      }

      await UserEvaluationLevelShareDialog.show(
        context: context,
        imageBytes: shareImage!,
      );
    } catch (e) {
      print('Error capturing widget: $e');
    } finally {
      if (learningPlanController.isAttached && prevPageIndex != null && prevPageIndex != 1) {
        learningPlanController.jumpToPage(prevPageIndex);
      }
      ToastUtils.hideLoading();
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _reportTimer?.cancel();
    _reportTimer = null;
    super.onClose();
  }
}
