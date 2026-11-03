

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/specialty/model/speciaity_default_phonics_model.dart';
import 'package:langwise/app/modules/specialty/model/speciaity_phonics_model.dart';
import 'package:langwise/app/modules/today_plan/controllers/today_plan_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/ai_assessment_result_detail_entity.dart';
import 'package:langwise/common/entities/lock_entity.dart';
import 'package:langwise/common/entities/pronunciations_entity.dart';
import 'package:langwise/common/entities/study_plan_entity.dart';
import 'package:langwise/common/enum/specialty_enum.dart';
import 'package:langwise/common/values/language_service_code.dart';
import 'package:langwise/common/widgets/animation_play_icon_widget.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/common/widgets/button_widgets.dart';
import 'package:langwise/common/widgets/cached_image_widget.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/common/widgets/pronunciations_color_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/lock_utils.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'tap_scale_widget.dart';

class PersonalizedLearningPlanIconData {
  final Object heroTag;
  final String title;
  final String? svgAsset;
  final Widget? icon;
  final bool selected;

  const PersonalizedLearningPlanIconData({
    required this.heroTag,
    required this.title,
    this.svgAsset,
    this.icon,
    this.selected = false,
  });
}

class PersonalizedLearningPlanCardData {
  final String id;
  final String title;
  final String? levelName;
  final String? type;
  final String? subTitle;
  final String? levelText;
  final String? statusText;
  final int minutesPerDay;
  final List<Color> gradient;
  final List<PersonalizedLearningPlanIconData> icons;
  final int startPoint;
  final int semester;
  final List<AiAssessmentPlanDirectionEntity> directionList;
  final List<SpeciaityDefaultPhonicsModelDataModuleInfoList> moduleInfoList;
  final String description;
  final bool isEnable;
  final String? status;
  final int? courseId;
  final int? moduleId;
  final int? levelId;
  final LockEntity? rights;
  final bool pause;
  final String resumeDate;
  final StudyPlanEntityPlanCourses? studyPlan;
  final bool isFromPlan;
  final AiAssessmentPlanTriggerEntity? trigger;

  const PersonalizedLearningPlanCardData(
      {required this.id,
      required this.title,
      this.levelName,
      this.type,
      this.subTitle,
      this.levelText,
      this.statusText,
      required this.minutesPerDay,
      required this.gradient,
      required this.icons,
      required this.startPoint,
      required this.semester,
      required this.directionList,
      required this.moduleInfoList,
      required this.description,
      required this.isEnable,
      required this.status,
      this.courseId,
      this.moduleId,
      this.levelId,
      this.rights,
      this.pause = false,
      this.resumeDate = '',
      this.studyPlan,
      this.trigger,
      this.isFromPlan = false});
}

class PersonalizedLearningPlanPageData {
  final String id;
  final int courseId;
  final bool isFollowSystem;
  final List<PersonalizedLearningPlanCardData> cards;

  const PersonalizedLearningPlanPageData({
    required this.id,
    this.courseId = 0,
    this.isFollowSystem = true,
    required this.cards,
  });
}

class PersonalizedLearningPlanController {
  _PersonalizedLearningPlanWidgetState? _state;

  bool get isAttached => _state != null;

  int? get currentPageIndex => _state?._currentPageIndex;

  void jumpToPage(int page) {
    _state?._jumpToPage(page);
  }

  Future<void> animateToPage(int page, {required Duration duration, required Curve curve}) async {
    await _state?._animateToPage(page, duration: duration, curve: curve);
  }

  void _attach(_PersonalizedLearningPlanWidgetState state) {
    _state = state;
  }

  void _detach(_PersonalizedLearningPlanWidgetState state) {
    if (!identical(_state, state)) return;
    _state = null;
  }
}

class PersonalizedLearningPlanWidget extends StatefulWidget {
  final String title;
  final List<Color> titleGradient;
  final String description;
  final List<PersonalizedLearningPlanPageData> pages;
  final bool showTitle;
  final double viewportFraction;
  final double horizontalGap;
  final bool isFromPlan;
  final bool isNoticeDialog;
  final bool hideClearButton;
  final PersonalizedLearningPlanController? controller;

  const PersonalizedLearningPlanWidget({
    super.key,
    this.title = '',
    this.titleGradient = const [],
    this.description = '',
    required this.pages,
    required this.showTitle,
    this.viewportFraction = 0.3,
    this.horizontalGap = 36,
    this.isFromPlan = false,
    this.isNoticeDialog = false,
    this.hideClearButton = false,
    this.controller,
  });

  @override
  State<PersonalizedLearningPlanWidget> createState() => _PersonalizedLearningPlanWidgetState();
}

class _PersonalizedLearningPlanWidgetState extends State<PersonalizedLearningPlanWidget> {
  late final PageController _pageController;
  double _page = 0;

  int get _currentPageIndex {
    if (!_pageController.hasClients) return 0;
    final p = _pageController.page;
    if (p == null) return _pageController.initialPage;
    return p.round();
  }

  void _jumpToPage(int page) {
    if (!_pageController.hasClients) return;
    _pageController.jumpToPage(page);
  }

  Future<void> _animateToPage(int page, {required Duration duration, required Curve curve}) async {
    if (!_pageController.hasClients) return;
    await _pageController.animateToPage(page, duration: duration, curve: curve);
  }

  final Map<int, int> _stackTopIndexByPage = {};
  final Object _guideActionToken = Object();
  bool _guideActionsRegistered = false;

  int _pageIndexForGuideId(String guideId) {
    for (int i = 0; i < widget.pages.length; i++) {
      final id = widget.pages[i].id;
      if (guideId == 'add_official_plan' && id.contains('official')) return i;
      if (guideId == 'add_textbook_plan' && id.contains('textbook')) return i;
      if (guideId == 'add_phonics_plan' && id.contains('phonics')) return i;
    }
    return 0;
  }

  void _unregisterGuideFlipActions() {
    GuideManager.instance.unregisterAction('add_official_plan', token: _guideActionToken);
    GuideManager.instance.unregisterAction('add_textbook_plan', token: _guideActionToken);
    GuideManager.instance.unregisterAction('add_phonics_plan', token: _guideActionToken);
    _guideActionsRegistered = false;
  }

  void _flipToGuideId(String guideId, {int retry = 0}) {
    if (!mounted) return;
    if (!_pageController.hasClients) {
      if (retry >= 60) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _flipToGuideId(guideId, retry: retry + 1);
      });
      return;
    }
    final idx = _pageIndexForGuideId(guideId);
    _pageController.jumpToPage(idx);
  }

  void _ensureGuideFlipActionsRegistered() {
    if (!widget.isFromPlan) {
      if (_guideActionsRegistered) {
        _unregisterGuideFlipActions();
      }
      return;
    }
    if (_guideActionsRegistered) return;
    for (final guideId in const ['add_official_plan', 'add_textbook_plan', 'add_phonics_plan']) {
      GuideManager.instance.registerAction(
        guideId,
        () {
          _flipToGuideId(guideId);
        },
        token: _guideActionToken,
      );
    }
    _guideActionsRegistered = true;
  }

  String _anchorIdForPage(String pageId) {
    if (pageId.contains('official')) return 'add_official_plan';
    if (pageId.contains('textbook')) return 'add_textbook_plan';
    return 'add_phonics_plan';
  }

  String _titleNameForPage(String pageId) {
    if (pageId.contains('official')) return '官方课程';
    if (pageId.contains('textbook')) return '教材';
    return '发音课';
  }

  String _specialtyForPage(String pageId) {
    if (pageId.contains('official')) return SpecialtyEnum.EN_OFFICIAL;
    if (pageId.contains('textbook')) return SpecialtyEnum.EN_TEXTBOOK;
    return SpecialtyEnum.EN_PHONICS;
  }

  Widget _buildAddPlanBlankPage(PersonalizedLearningPlanPageData pageData) {
    final pageId = pageData.id;
    final courseId = pageData.courseId;
    final titleName = _titleNameForPage(pageId);
    final specialty = _specialtyForPage(pageId);

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          border: Border.all(color: AppTheme.cBorderSecondary),
          color: AppTheme.cSurfaceSecondary,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 84.wMin,
              alignment: Alignment.center,
              color: const Color(0x0DFFFFFF),
              child: Text(
                '添加$titleName计划',
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  TagRoutes.toNamed(
                    Routes.NEW_CREATE_STUDY_PLAN,
                    arguments: {'titleName': titleName, 'courseId': courseId, 'specialty': specialty, 'initPlan': false},
                  );
                },
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/svg/public/icon_add.svg',
                    colorFilter: const ColorFilter.mode(AppTheme.cBorderTertiary, BlendMode.srcIn),
                    width: 120.wMin,
                    height: 120.wMin,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
    _pageController.addListener(_onPage);
    widget.controller?._attach(this);
    _ensureGuideFlipActionsRegistered();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureGuideFlipActionsRegistered();
    });
  }

  @override
  void didUpdateWidget(covariant PersonalizedLearningPlanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFromPlan != widget.isFromPlan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureGuideFlipActionsRegistered();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureGuideFlipActionsRegistered();
    });
  }

  void _onPage() {
    if (!_pageController.hasClients) return;
    final p = _pageController.page;
    if (p == null) return;
    setState(() {
      _page = p;
    });
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _unregisterGuideFlipActions();
    _pageController.removeListener(_onPage);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) return const SizedBox.shrink();

    final currentIndex = _page.round().clamp(0, widget.pages.length - 1);
    final currentPage = widget.pages[currentIndex];
    final currentTopIndex = (_stackTopIndexByPage[currentIndex] ?? 0).clamp(0, currentPage.cards.isEmpty ? 0 : (currentPage.cards.length - 1));
    final current = currentPage.cards.isEmpty ? null : currentPage.cards[currentTopIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showTitle)
            Column(children: [
              _buildTitle(),
              SizedBox(height: 8.wMin),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 24.wMin),
            ]),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 80.wMin),
            child: SizedBox(
              height: 726.wMin,
              child: PageView.builder(
                controller: _pageController,
                clipBehavior: Clip.none,
                itemCount: widget.pages.length,
                itemBuilder: (context, index) {
                  final pageData = widget.pages[index];
                  final delta = (index - _page);
                  final tilt = delta.clamp(-1.0, 1.0);

                  final rotateY = tilt * 0.4;
                  final translateX = tilt * widget.horizontalGap.wMin;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..translate(translateX)
                          ..rotateY(rotateY),
                        child: widget.isFromPlan && !pageData.isFollowSystem && pageData.cards.isEmpty
                            ? _buildAddPlanBlankPage(pageData)
                            : _StackedCards(
                                key: ValueKey(pageData.id),
                                items: pageData.cards,
                                isFromPlan: widget.isFromPlan,
                                isYinbiao: pageData.id.contains('phonics'),
                                initialTopIndex: _stackTopIndexByPage[index] ?? 0,
                                onTopIndexChanged: (v) {
                                  _stackTopIndexByPage[index] = v;
                                  setState(() {});
                                },
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            current?.description ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 200.wMin + 24.wMin),
              _bottomBtn(current, currentPage, currentTopIndex),

              Container(
                margin: EdgeInsets.only(left: 24.wMin),
                width: 200.wMin,
                child: Visibility(
                  visible: current?.status == 'EXECUTED' ? false : current?.status == 'PENDING' ? true : false,
                  child: ButtonWidget(
                    text: "提前学习",
                    width: 200.wMin,
                    height: 72.wMin,
                    color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.15),
                    fontColor: AppTheme.cSurfaceWarning.color,
                    fontSize: 28.wMin,
                    borderRadius: 14.wMin,
                    fontWeight: FontWeight.w500,
                    sclae: 1.03,
                    onTap: () async{
                      String? specialty;
                      String? titleName;
                      if(current?.type == 'official'){
                        specialty = SpecialtyEnum.EN_OFFICIAL;
                        titleName = '官方课程';
                      }else if(current?.type == 'textbook'){
                        specialty = SpecialtyEnum.EN_TEXTBOOK;
                        titleName = '教材课程';
                      } else {
                        specialty = SpecialtyEnum.EN_PHONICS;
                        titleName = '自然拼读课';
                      }
                      await TagRoutes.toNamed(Routes.NEW_CREATE_STUDY_PLAN, arguments: {
                        "directionList": current?.directionList,
                        "dailyStudyDuration": current?.minutesPerDay,
                        "courseId": current?.courseId,
                        "tier": current?.startPoint,
                        'initPlan': current?.status != 'RUNNING' && specialty != SpecialtyEnum.EN_PHONICS,
                        "specialty": specialty,
                        "titleName": titleName
                      });
                    },
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBtn(PersonalizedLearningPlanCardData? current, PersonalizedLearningPlanPageData currentPage, int currentTopIndex) {
    if (current != null) {
      if (widget.isFromPlan && current.status == 'RUNNING' && current.studyPlan != null) {
        return btn(context, current);
      }
      Widget child = Container();
      if (current.type == 'official') {
        child = Container(
          child: GuideAnchor(
                  id: 'add_official_plan',
                  route: Routes.TODAY_PLAN,
                  child: TapScaleWidget(
                    sclae: 1,
                    onTap: () async {
                      if (current.status == 'EXECUTED') {
                        ToastUtils.showToast(text: '当前计划已完成');
                        return;
                      }
                      if (current.isEnable) {
                        bool student = await LockUtils.checkStudent(context);
                        if (!student) return;
                        if (await LockUtils.checkLock(current.rights, context)) return;
                        if (widget.isNoticeDialog && current.status != 'RUNNING') {
                          final res = await showNoticeDialog();
                          if (!res) {
                            return;
                          }
                        }
                        await TagRoutes.toNamed(Routes.NEW_CREATE_STUDY_PLAN, arguments: {
                          "directionList": current.directionList,
                          "dailyStudyDuration": current.minutesPerDay,
                          "courseId": current.courseId,
                          "tier": current.startPoint,
                          'initPlan': current.status != 'RUNNING',
                          "specialty": SpecialtyEnum.EN_OFFICIAL,
                          "titleName": '官方课程'
                        });
                      } else {
                        ToastUtils.showToast(text: '当前计划不可执行,请先完成前置课程');
                      }
                    },
                    child: Container(
                      width: 560.wMin,
                      height: 88.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: current.status == 'RUNNING'
                            ? Color(0x1A00BC7D)
                            : current.isEnable
                                ? current.gradient[0]
                                : Color(0xFF4E4E4E),
                        borderRadius: BorderRadius.circular(16.wMin),
                      ),
                      child: current.status == 'RUNNING'
                          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                "查看执行详情",
                                style: TextStyle(
                                  fontSize: 28.wMin,
                                  color: AppTheme.cFeedbackSuccessText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/svg/user_center/icon_chevron_right1.svg',
                                width: 40.wMin,
                                height: 40.wMin,
                                colorFilter: const ColorFilter.mode(AppTheme.cFeedbackSuccessIcon, BlendMode.srcIn),
                              ),
                            ])
                          : Text(
                              current.status == 'EXECUTED'
                                  ? '已完成'
                                  : current.status == 'PENDING'
                                      ? '官方课程计划学到L${currentPage.cards[currentTopIndex].startPoint}后开启'
                                      : '执行 「官方主课程」 计划',
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: current.status == 'EXECUTED' ? AppTheme.cTextQuaternary : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )),
        );
      } else if (current.type == 'textbook') {
        child = GuideAnchor(
                    id: 'add_textbook_plan',
                    route: Routes.TODAY_PLAN,
                    child: TapScaleWidget(
                      sclae: 1,
                      onTap: () async {
                        if (current.status == 'EXECUTED') {
                          ToastUtils.showToast(text: '当前计划已完成');
                          return;
                        }
                        if (current.isEnable) {
                          bool student = await LockUtils.checkStudent(context);
                          if (!student) return;
                          if (await LockUtils.checkLock(current.rights, context)) return;
                          if (widget.isNoticeDialog && current.status != 'RUNNING') {
                            final res = await showNoticeDialog();
                            if (!res) {
                              return;
                            }
                          }
                          if ((current.moduleId == null || current.moduleId == 0) && current.status != 'RUNNING') {
                            await TagRoutes.toNamed(
                              Routes.CUSTOM_COURSE,
                              arguments: {
                                'courseId': current.courseId,
                                'levelId': current.levelId,
                                'cefr': current.title,
                                'moduleId': current.moduleId,
                                'isFromManage': false,
                                'fromType': 4,
                                'gradeIndex': current.startPoint,
                                'levelName': current.levelName
                              },
                            );
                          } else {
                            await TagRoutes.toNamed(Routes.NEW_CREATE_STUDY_PLAN, arguments: {
                              "directionList": current.directionList,
                              "dailyStudyDuration": current.minutesPerDay,
                              "courseId": current.courseId,
                              "tier": current.startPoint,
                              "semester": current.semester,
                              'moduleId': current.moduleId,
                              'initPlan': current.status != 'RUNNING',
                              "specialty": SpecialtyEnum.EN_TEXTBOOK,
                              "titleName": '教材拓展课'
                            });
                          }
                        } else {
                          ToastUtils.showToast(text: '当前计划不可执行,请先完成前置课程');
                        }
                      },
                      child: Container(
                        width: 560.wMin,
                        height: 88.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: current.status == 'RUNNING'
                              ? Color(0x1A00BC7D)
                              : current.isEnable
                                  ? current.gradient[0]
                                  : Colors.grey,
                          borderRadius: BorderRadius.circular(16.wMin),
                        ),
                        child: current.status == 'RUNNING'
                            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(
                                  "查看执行详情",
                                  style: TextStyle(
                                    fontSize: 28.wMin,
                                    color: AppTheme.cFeedbackSuccessText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/svg/user_center/icon_chevron_right1.svg',
                                  width: 40.wMin,
                                  height: 40.wMin,
                                  colorFilter: const ColorFilter.mode(AppTheme.cFeedbackSuccessIcon, BlendMode.srcIn),
                                ),
                              ])
                            : Text(
                                current.status == 'EXECUTED'
                                    ? '已完成'
                                    : current.status == 'PENDING'
                                        ? current.trigger == null && currentTopIndex > 0
                                            ? '教材拓展课学到${currentPage.cards[currentTopIndex].title}后开启'
                                            : '官方课程计划学到L${current.trigger?.tier}后开启'
                                        : "执行 「教材拓展课」 计划",
                                style: TextStyle(
                                  fontSize: 28.wMin,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
        );
      } else {
        child = GuideAnchor(
                id: 'add_phonics_plan',
                route: Routes.TODAY_PLAN,
                child: TapScaleWidget(
                  sclae: 1,
                  onTap: () async {
                    if (current.status == 'EXECUTED') {
                      ToastUtils.showToast(text: '当前计划已完成');
                      return;
                    }
                    if (current.isEnable) {
                      bool student = await LockUtils.checkStudent(context);
                      if (!student) return;
                      if (await LockUtils.checkLock(current.rights, context)) return;
                      if (widget.isNoticeDialog && current.status != 'RUNNING') {
                        final res = await showNoticeDialog();
                        if (!res) {
                          return;
                        }
                      }
                      await TagRoutes.toNamed(Routes.NEW_CREATE_STUDY_PLAN, arguments: {
                        "directionList": current.directionList,
                        "dailyStudyDuration": current.minutesPerDay,
                        "courseId": current.courseId,
                        "tier": current.startPoint,
                        'initPlan': current.status != 'RUNNING',
                        "specialty": SpecialtyEnum.EN_PHONICS,
                        "titleName": '自然拼读课'
                      });
                    } else {
                      ToastUtils.showToast(text: '当前计划不可执行,请先完成前置课程');
                    }
                  },
                  child: Container(
                    width: 560.wMin,
                    height: 88.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: current.status == 'RUNNING'
                          ? const Color(0x1A00BC7D)
                          : current.isEnable
                              ? current.gradient[0]
                              : Colors.grey,
                      borderRadius: BorderRadius.circular(16.wMin),
                    ),
                    child: current.status == 'RUNNING'
                        ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              "查看执行详情",
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: AppTheme.cFeedbackSuccessText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/svg/user_center/icon_chevron_right1.svg',
                              width: 40.wMin,
                              height: 40.wMin,
                              colorFilter: const ColorFilter.mode(AppTheme.cFeedbackSuccessIcon, BlendMode.srcIn),
                            ),
                          ])
                        : Text(
                            current.status == 'EXECUTED'
                                ? '已完成'
                                : current.status == 'PENDING'
                                    ? current.trigger == null
                                        ? '官方课程计划学到L${currentPage.cards[currentTopIndex].startPoint}后开启'
                                        : '官方课程计划学到L${current.trigger?.tier}后开启'
                                    : "执行 「自然拼读课」 计划",
                            style: TextStyle(
                              fontSize: 28.wMin,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ));
      }
      return cancelWidget(child: child);
    } else {
      final pageId = currentPage.id;
      final titleName = _titleNameForPage(pageId);
      final anchorId = _anchorIdForPage(pageId);
      final courseId = currentPage.courseId;
      final specialty = _specialtyForPage(pageId);
      return GuideAnchor(
        id: anchorId,
        route: Routes.TODAY_PLAN,
        child: TapScaleWidget(
          sclae: 1,
          onTap: () {
            TagRoutes.toNamed(
              Routes.NEW_CREATE_STUDY_PLAN,
              arguments: {'titleName': titleName, 'courseId': courseId, 'specialty': specialty, 'initPlan': false},
            );
          },
          child: Container(
            width: 560.wMin,
            height: 88.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceBrand.color,
              borderRadius: BorderRadius.circular(16.wMin),
            ),
            child: Text(
              "添加$titleName计划",
              style: TextStyle(
                fontSize: 28.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<bool> showNoticeDialog() async {
    return await AskDialog.showUserAsk(
        context: context,
        title: '提示',
        content: '替换计划会清除你的其他计划，学习记录会被保留，不影响复习，只影响新学的内容',
        showLastCountdown: true,
        onDefine: () {
          Get.back();
        },
        onCancel: () {
          Get.back();
        });
  }

  Widget cancelWidget({required Widget child}) {
    return Row(
    mainAxisSize: MainAxisSize.min,
     children: [
      GuideAnchor(
        id: '',
        route: Routes.TODAY_PLAN,
        child: Visibility(
          visible: widget.isNoticeDialog && !widget.hideClearButton,
          child: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
                width: 560.wMin,
                height: 88.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cTextQuaternary,
                  borderRadius: BorderRadius.circular(16.wMin),
                ),
                child: Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cInverseTextLight,
                    fontWeight: FontWeight.w600,
                  ),
                )),
          ),
        ),
      ),
      Visibility(
          visible: widget.isNoticeDialog,
          child: SizedBox(width: 20.wMin,),
      ),
      child,
    ]);
  }

  Widget _buildTitleLineWidget([bool isLeft = true]) {
    return Container(
      height: 2.wMin,
      width: 56.wMin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
            AppTheme.cBgBrand.color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget btn(BuildContext context, PersonalizedLearningPlanCardData data) {
    return SizedBox(
      height: 88.wMin,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        data.pause
            ? GuideAnchor(
                id: 'resume_plan',
                route: Routes.TODAY_PLAN,
                child: ButtonWidget(
                  text: "立即恢复计划",
                  color: AppTheme.cSurfaceSuccess.color,
                  width: 312.wMin,
                  borderRadius: 16.wMin,
                  height: 88.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                  fontColor: AppTheme.cTextPrimary,
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.01,
                  onTap: () {
                    TagRoutes.findLast<TodayPlanController>(Routes.TODAY_PLAN)?.pauseRecoverPlan(context, StudyPlanEntityPlanCourses(courseId: data.courseId, dailyStudyDuration: data.minutesPerDay * 60, pause: data.pause));
                  },
                ),
              )
            : GuideAnchor(
                id: 'pause_plan',
                route: Routes.TODAY_PLAN,
                child: ButtonWidget(
                  text: "暂停新学",
                  color: AppTheme.cSurfaceWarning.color,
                  borderRadius: 16.wMin,
                  width: 312.wMin,
                  height: 88.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                  fontColor: AppTheme.cTextPrimary,
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.01,
                  onTap: () {
                    TagRoutes.findLast<TodayPlanController>(Routes.TODAY_PLAN)?.pauseRecoverPlan(context, StudyPlanEntityPlanCourses(courseId: data.courseId, dailyStudyDuration: data.minutesPerDay * 60, pause: data.pause));
                  },
                ),
              ),
        SizedBox(width: 24.wMin),
        GuideAnchor(
          id: 'edit_plan',
          route: Routes.TODAY_PLAN,
          child: ButtonWidget(
            text: "编辑计划",
            color: AppTheme.cSurfaceInfo.color,
            borderRadius: 16.wMin,
            width: 312.wMin,
            height: 88.wMin,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
            fontColor: AppTheme.cTextPrimary,
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.01,
            onTap: () {
              TagRoutes.findLast<TodayPlanController>(Routes.TODAY_PLAN)?.toEditPlan(
                  StudyPlanEntityPlanCourses(courseId: data.courseId, dailyStudyDuration: data.minutesPerDay * 60, pause: data.pause),
                  context,
                  data.type == "official"
                      ? 0
                      : data.type == "textbook"
                          ? 1
                          : 2);
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12.wMin,
      children: [
        Column(
          spacing: 10.wMin,
          children: [
            _buildTitleLineWidget(),
            _buildTitleLineWidget(),
          ],
        ),
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.titleGradient,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36.wMin,
              fontWeight: FontWeight.w700,
              color: AppTheme.cTextPrimary,
            ),
          ),
        ),
        Column(
          spacing: 10.wMin,
          children: [
            _buildTitleLineWidget(false),
            _buildTitleLineWidget(false),
          ],
        ),
      ],
    );
  }
}

class _StackedCards extends StatefulWidget {
  final List<PersonalizedLearningPlanCardData> items;
  final int initialTopIndex;
  final bool isYinbiao;
  final bool isFromPlan;
  final ValueChanged<int> onTopIndexChanged;

  const _StackedCards({super.key, required this.items, required this.initialTopIndex, required this.onTopIndexChanged, required this.isYinbiao, required this.isFromPlan});

  @override
  State<_StackedCards> createState() => _StackedCardsState();
}

class _StackedCardsState extends State<_StackedCards> with SingleTickerProviderStateMixin {
  late int _topIndex;

  late final AnimationController _animController;
  late Animation<double> _progressAnim;
  double _dragDy = 0;
  _DeckSwipeDirection _direction = _DeckSwipeDirection.none;

  @override
  void initState() {
    super.initState();
    _topIndex = widget.initialTopIndex;

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _progressAnim = const AlwaysStoppedAnimation<double>(0);
  }

  @override
  void didUpdateWidget(covariant _StackedCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTopIndex != widget.initialTopIndex) {
      _topIndex = widget.initialTopIndex;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _setTopIndex(int v) {
    if (v == _topIndex) return;
    setState(() {
      _topIndex = v;
    });
    widget.onTopIndexChanged(v);
  }

  double _applyResistance({required double dy, required bool canMove}) {
    if (canMove) return dy;
    final sign = dy.sign;
    final v = dy.abs();
    return sign * (v * 0.28);
  }

  Future<void> _animateProgressTo(double target, {required Curve curve}) async {
    final begin = _currentProgress;
    _progressAnim = Tween<double>(begin: begin, end: target).animate(CurvedAnimation(parent: _animController, curve: curve));
    _animController.value = 0;
    await _animController.forward();
  }

  double get _currentProgress {
    if (_animController.isAnimating) return _progressAnim.value;
    final threshold = 140.wMin;
    return (_dragDy.abs() / threshold).clamp(0.0, 1.0);
  }

  bool get _canRotate {
    return widget.items.length > 1;
  }

  bool get _canMoveUp {
    if (!_canRotate) return false;
    return true;
  }

  bool get _canMoveDown {
    if (!_canRotate) return false;
    return true;
  }

  Future<void> _animateSwipeEnd({required double velocity}) async {
    if (!_canRotate || _direction == _DeckSwipeDirection.none) {
      await _animateProgressTo(0, curve: Curves.easeOutBack);
      _dragDy = 0;
      _direction = _DeckSwipeDirection.none;
      return;
    }

    const minVelocity = 700.0;
    final commitThreshold = 0.35;
    final p = _currentProgress;

    final commit = p >= commitThreshold || velocity.abs() >= minVelocity;
    if (!commit) {
      await _animateProgressTo(0, curve: Curves.easeOutBack);
      _dragDy = 0;
      _direction = _DeckSwipeDirection.none;
      return;
    }

    await _animateProgressTo(1, curve: Curves.easeOutCubic);
    final n = widget.items.length;

    if (_direction == _DeckSwipeDirection.up && _canMoveUp) {
      _setTopIndex((_topIndex + 1) % n);
    } else if (_direction == _DeckSwipeDirection.down && _canMoveDown) {
      _setTopIndex((_topIndex - 1 + n) % n);
    }

    _dragDy = 0;
    _direction = _DeckSwipeDirection.none;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final topIndex = _topIndex.clamp(0, widget.items.length - 1);
    if (topIndex != _topIndex) {
      _topIndex = topIndex;
      widget.onTopIndexChanged(_topIndex);
    }

    return GestureDetector(
      onVerticalDragStart: (_) {
        if (_animController.isAnimating) {
          _animController.stop();
        }
      },
      onVerticalDragUpdate: (details) {
        if (!_canRotate) return;
        final next = _dragDy + details.delta.dy;
        final isUp = next < 0;
        final canMove = (isUp && _canMoveUp) || (!isUp && _canMoveDown) || next == 0;
        final withResistance = _applyResistance(dy: next, canMove: canMove);
        setState(() {
          _dragDy = withResistance;
          _direction = _dragDy == 0 ? _DeckSwipeDirection.none : (_dragDy < 0 ? _DeckSwipeDirection.up : _DeckSwipeDirection.down);
        });
      },
      onVerticalDragEnd: (details) {
        _animateSwipeEnd(velocity: details.primaryVelocity ?? 0);
      },
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          final layers = <Widget>[];
          const maxLayers = 3;
          //卡牌高度
          double cardHeight = 510.wMin;
          //下层露出高度
          final peek = 125.wMin;
          //上层抬起高度
          final lift = 36.wMin;
          final cardWidth = 546.wMin;

          final p = _currentProgress;
          final n = widget.items.length;
          final stackSize = n < maxLayers ? n : maxLayers;

          int idx0 = _topIndex % n;
          int idx1 = (idx0 + 1) % n;
          int idx2 = (idx0 + 2) % n;

          if (stackSize == 1) {
            if (widget.isFromPlan) {
              // cardHeight = cardHeight + peek * 2;
            }
            layers.add(
              _buildLayerInterpolated(
                data: widget.items[idx0],
                position: 0,
                scale: 1,
                cardHeight: cardHeight,
                cardWidth: cardWidth,
              ),
            );
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: layers,
            );
          }

          final s0 = 1.0;
          final s1 = 0.96;
          final s2 = 0.92;
          final y0 = 0.0;
          final y1 = peek;
          final y2 = 2 * peek;

          double lerp(double a, double b) => a + (b - a) * p;
          double lerp2(double a, double b, double c) {
            if (p <= 0.5) {
              final t = p / 0.5;
              return a + (b - a) * t;
            }
            final t = (p - 0.5) / 0.5;
            return b + (c - b) * t;
          }

          if (_direction == _DeckSwipeDirection.up) {
            final aY = lerp2(y0, -lift, y2);
            final aS = lerp2(s0, 0.92, s2);
            final bY = lerp(y1, y0);
            final bS = lerp(s1, s0);
            final cY = lerp(y2, y1);
            final cS = lerp(s2, s1);

            if (stackSize >= 3) {
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx0],
                  position: aY,
                  scale: aS,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx2],
                  position: cY,
                  scale: cS,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx1],
                  position: bY,
                  scale: bS,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
            } else {
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx0],
                  position: aY,
                  scale: aS,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx1],
                  position: bY,
                  scale: bS,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
            }
          } else if (_direction == _DeckSwipeDirection.down) {
            final aY = lerp(y0, y1);
            final aS = lerp(s0, s1);
            final bY = lerp(y1, y2);
            final bS = lerp(s1, s2);
            final cY = lerp2(y2, -lift, y0);
            final cS = lerp2(s2, 0.92, s0);

            if (stackSize >= 3) {
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx1],
                  position: bY,
                  scale: bS,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx0],
                  position: aY,
                  scale: aS,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx2],
                  position: cY,
                  scale: cS,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
            } else {
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx0],
                  position: aY,
                  scale: aS,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx1],
                  position: y0,
                  scale: s0,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
            }
          } else {
            if (stackSize >= 3) {
              layers.add(
                _buildLayerInterpolated(
                  data: widget.items[idx2],
                  position: y2,
                  scale: s2,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                ),
              );
            }
            layers.add(
              _buildLayerInterpolated(
                data: widget.items[idx1],
                position: y1,
                scale: s1,
                cardHeight: cardHeight,
                cardWidth: cardWidth,
              ),
            );
            layers.add(
              _buildLayerInterpolated(
                data: widget.items[idx0],
                position: y0,
                scale: s0,
                cardHeight: cardHeight,
                cardWidth: cardWidth,
              ),
            );
          }

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: layers,
          );
        },
      ),
    );
  }

  Widget _buildLayerInterpolated({
    required PersonalizedLearningPlanCardData data,
    required double position,
    required double scale,
    required double cardHeight,
    required double cardWidth,
  }) {
    final child = PlanCard(
      data: data,
      isTop: true,
      height: cardHeight,
      clipToBottom: false,
      clipHeight: cardHeight,
    );

    return Positioned(
      top: position,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: cardWidth,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
      ),
    );
  }
}

enum _DeckSwipeDirection {
  none,
  up,
  down,
}

class PlanCard extends StatelessWidget {
  final PersonalizedLearningPlanCardData data;
  final bool isTop;
  final double height;
  final bool clipToBottom;
  final double clipHeight;

  const PlanCard({
    required this.data,
    required this.isTop,
    required this.height,
    required this.clipToBottom,
    required this.clipHeight,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.wMin),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.isEnable ? data.gradient : [Color(0xFF1D2021), Color(0xFF1D2021)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24.wMin,
            offset: Offset(0, 16.wMin),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (data.status == 'READY')
            Positioned.fill(
                child: Container(
              decoration: BoxDecoration(
                color: Color(0xF21D2021),
                borderRadius: BorderRadius.circular(18.wMin),
              ),
              margin: EdgeInsets.all(2.wMin),
            )),
          isTop ? _buildTopContent() : _buildBottomPeek(),
        ],
      ),
    );

    if (!clipToBottom) return card;

    return SizedBox(
      height: clipHeight,
      child: ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: clipHeight / height,
          child: card,
        ),
      ),
    );
  }

  Widget _buildTopContent() {
    Color textColor = Colors.white;
    Color bgColor = Colors.white;
    Color bottomTxtColor = Colors.white;
    if (data.status == 'RUNNING') {
      textColor = const Color(0xB2000000);
      bgColor = const Color(0x9DFFFFFF);
      bottomTxtColor = Colors.white;
    } else if (data.status == 'READY') {
      textColor = AppTheme.cInverseTextLight;
      if (data.type == "official") {
        bgColor = AppTheme.cSurfaceInfo;
        bottomTxtColor = AppTheme.cSurfaceInfo;
      } else if (data.type == 'textbook') {
        bgColor = const Color(0xFF00D492);
        bottomTxtColor = const Color(0xFF00D492);
      } else {
        bgColor = const Color(0xFFA855F7);
        bottomTxtColor = const Color(0xFFA855F7);
      }
    } else if (data.status == 'PENDING') {
      bottomTxtColor = Colors.white;
      if (data.type == "official") {
        textColor = AppTheme.cTextBrand;
        bgColor = const Color(0x3338BDF8);
      } else if (data.type == 'textbook') {
        textColor = const Color(0xFF00D492);
        bgColor = const Color(0x1F00D492);
      } else {
        textColor = const Color(0xFFA855F7);
        bgColor = const Color(0x33A855F7);
      }
    } else {
      bottomTxtColor = Colors.white;
      textColor = AppTheme.cTextPrimary;
      bgColor = AppTheme.cBgTertiary;
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                    child: data.id.contains('phonics')
                        ? data.isFromPlan && data.studyPlan != null
                            ? _phonicsBody(data.studyPlan?.moduleContentInfo)
                            : Padding(
                                padding: EdgeInsets.all(18.wMin),
                                child: _phonicsWidget(modelList: data.moduleInfoList),
                              )
                        : chipsWidget()),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(12.wMin, 6.wMin, 12.wMin, 6.wMin),
                decoration: BoxDecoration(
                    border: const Border(
                      top: BorderSide(
                        color: Color(0x0DFFFFFF),
                      ),
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(18.wMin),
                    ),
                    color: Color(0x0DFFFFFF)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (data.statusText != null)
                                Container(
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(5.wMin),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
                                  child: Text(
                                    data.statusText ?? '',
                                    style: TextStyle(
                                      fontSize: 16.wMin,
                                      color: textColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              AutoSizeText(
                                data.isFromPlan && data.status == 'RUNNING' && data.studyPlan != null ? data.studyPlan?.courseName ?? '' : data.title,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: bottomTxtColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${data.minutesPerDay}',
                              style: TextStyle(
                                fontSize: 66.wMin,
                                color: bottomTxtColor,
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(width: 9.wMin),
                            Text(
                              '分钟\n/每日',
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: bottomTxtColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      data.isFromPlan && data.isEnable && data.studyPlan != null
                          ? "${data.studyPlan?.currentUnitInfo?.levelName ?? ''}/${data.studyPlan?.currentUnitInfo?.moduleName ?? ''}/${data.studyPlan?.currentUnitInfo?.unitName ?? ''}"
                          : data.levelText ?? '',
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: bottomTxtColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Visibility(
                      visible: data.isFromPlan && data.isEnable && data.studyPlan?.nextUnitDay != null,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "预计还有 ${data.studyPlan?.nextUnitDay ?? 0} 天学习到下一个单元",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: bottomTxtColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (data.pause) Positioned.fill(child: _buildPauseOverlayWidget()),
        if (data.status == 'EXECUTED')
          Positioned(
            right: 10.wMin,
            bottom: 80.wMin,
            child: SvgPicture.asset(
              "assets/svg/exam_plan/plan_finish.svg",
              fit: BoxFit.cover,
              height: 187.wMin,
              width: 187.wMin,
            ),
          ),
        if (data.status == 'EXECUTED')
          Positioned.fill(
              child: Container(
            color: const Color(0x60000000),
          )),
      ],
    );
  }

  Widget chipsWidget() {
    List<PersonalizedLearningPlanIconData> list = data.icons;
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(8.wMin),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.wMin,
        crossAxisSpacing: 8.wMin,
        mainAxisExtent: 70.wMin,
      ),
      itemBuilder: (context, index) {
        return _PlanIconChip(data: list[index]);
      },
    );
  }

  Widget _phonicsBody(SpeciaityPhonicsModelDataModuleContentInfo? model) {
    if (model == null) return SizedBox.shrink();
    List<PronunciationsEntity?> pronunciations = model.pronunciations ?? [];

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 320.wMin,
            height: 320.wMin,
            color: Colors.transparent,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.wMin),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CachedImageWidget(
                      model.imageUrl ?? "",
                      placeholder: buildEmptyWidget(),
                      errorWidget: buildEmptyWidget(),
                    ),
                    Container(
                      width: double.infinity,
                      color: AppTheme.cBlackAlpha50.color,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PronunciationsPlayIpaTextWidget(
                            ipa: data.studyPlan?.startUnitInfo?.moduleTopic,
                            pronunciations: pronunciations,
                            national: LanguageServiceCode.US,
                            style: TextStyle(
                              fontSize: 110.wMin,
                              color: AppTheme.cInverseTextLight.color,
                              fontWeight: FontWeight.w700,
                              fontFamily: "AndikaRegular",
                            ),
                          ),
                          PronunciationsColorWidget(
                            content: model.content,
                            ipa: data.studyPlan?.startUnitInfo?.moduleTopic,
                            pronunciations: pronunciations,
                            national: LanguageServiceCode.US,
                            style: TextStyle(
                              fontSize: 70.wMin,
                              color: AppTheme.cInverseTextLight.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 60.wMin),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(pronunciations.length, (index) {
                        return PlayLottieIconWidget(
                          size: 68.wMin,
                          audioUrl: pronunciations[index]?.audioUrl,
                          backgroundImageUrl: pronunciations[index]?.nationalIconUrl,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 暂停蒙层
  Widget _buildPauseOverlayWidget() {
    return Container(
      width: double.infinity,
      height: 536.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cBlackAlpha70.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.wMin)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "该计划已暂停",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cFeedbackWarningText.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          Visibility(
            visible: data.resumeDate.isNotEmpty,
            child: Text(
              "计划将于${data.resumeDate}恢复",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPeek() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.wMin),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${data.minutesPerDay}',
              style: TextStyle(
                fontSize: 80.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
            SizedBox(width: 9.wMin),
            Text(
              '分钟\n/天',
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _phonicsWidget extends StatefulWidget {
  final List<SpeciaityDefaultPhonicsModelDataModuleInfoList> modelList;
  _phonicsWidget({required this.modelList});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _phonicsWidgetState();
  }
}

class _phonicsWidgetState extends State<_phonicsWidget> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.modelList.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16.wMin,
        mainAxisSpacing: 16.wMin,
      ),
      itemBuilder: (BuildContext context, int index) {
        final SpeciaityDefaultPhonicsModelDataModuleInfoList? item = index < widget.modelList.length ? widget.modelList[index] : null;
        return _buildViewWidget(item);
      },
    );
  }

  Widget _buildViewWidget(SpeciaityDefaultPhonicsModelDataModuleInfoList? data) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CachedImageWidget(
            data?.moduleCoverUrl ?? "",
            placeholder: buildEmptyWidget(),
            errorWidget: buildEmptyWidget(),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 6.wMin, horizontal: 6.wMin),
            color: AppTheme.cBlackAlpha50.color,
            child: Center(
              child: Text(
                "/${data?.topic}/",
                style: TextStyle(fontSize: 24.wMin, color: AppTheme.cInverseTextLight.color, fontWeight: FontWeight.w600, fontFamily: "AndikaRegular"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanIconChip extends StatelessWidget {
  final PersonalizedLearningPlanIconData data;

  const _PlanIconChip({required this.data});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withValues(alpha: 0.12);
    final border = Colors.white.withValues(alpha: data.selected ? 0.65 : 0.18);

    final iconWidget = data.icon ?? (data.svgAsset == null ? const SizedBox.shrink() : Image.network(data.svgAsset!, width: 20.wMin, height: 20.wMin));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9.wMin),
        border: Border.all(color: border, width: 1.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          iconWidget,
          Row(
            children: [
              Text(
                data.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (data.selected) ...[
                Spacer(),
                Icon(Icons.check, size: 18.wMin, color: Colors.white),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
