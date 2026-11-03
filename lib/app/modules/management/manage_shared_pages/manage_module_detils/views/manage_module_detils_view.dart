import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../../../../common/widgets/custom_button/LWCircularButton.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_module_detils_binding.dart';
import '../controllers/manage_module_detils_controller.dart';
import 'manage_module_units_dialog.dart';

enum _PipelineVisualState {
  done,
  current,
  pending,
}

class ManageModuleDetilsView extends GetView<ManageModuleDetilsController> {
  final String tagText;
  const ManageModuleDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_MODULE_DETILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageModuleDetilsView(tagText: tag),
      binding: ManageModuleDetilsBinding(tag: tag),
      routeName: Routes.MANAGE_MODULE_DETILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.onFetchData(),
      body: _ManageModuleDetilsContent(controller: controller),
    );
  }
}

class _ManageModuleDetilsContent extends StatelessWidget {
  final ManageModuleDetilsController controller;

  const _ManageModuleDetilsContent({
    required this.controller,
  });

  List<NewUnitResponseEntity<LessonResponseEntity>> get _units => controller.unitTabList.cast<NewUnitResponseEntity<LessonResponseEntity>>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          controller.rebuildUnitIndexMap();
          return Column(
            children: [
              Expanded(
                child: _units.isEmpty
                    ? Center(
                      
                      )
                    : Container(
                        alignment: Alignment.center,
                        color: AppTheme.cBgPrimary,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: ListView.builder(
                            controller: controller.scrollController,
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            padding: EdgeInsets.only(
                              top: 24.wMin,
                              bottom: 140.wMin + (MediaQuery.of(context).size.height * 0.5),
                            ),
                            itemCount: _units.length,
                            itemBuilder: (context, unitIndex) {
                              final unit = _units[unitIndex];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 40.wMin),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (unitIndex != 0)
                                      Container(
                                        width: double.infinity,
                                        height: 1,
                                        color: AppTheme.cBgQuaternary.withValues(alpha: 0.6),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 90.wMin,
                                        right: 90.wMin,
                                        top: unitIndex == 0 ? 0 : 22.wMin,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildUnitSectionHeader(context, unitIndex, unit),
                                          SizedBox(height: 18.wMin),
                                          _buildUnitMiddlePanel(unit),
                                          SizedBox(height: 18.wMin),
                                          _buildUnitLessonsRow(context, unit),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),
            ],
          );
        }),
        Obx(() {
          if (_units.isEmpty) {
            return const SizedBox.shrink();
          }
          return Positioned(
            bottom: 45.wMin,
            left: 90.wMin,
            right: 90.wMin,
            child: _buildBottomActionBar(context),
          );
        }),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: _buildEditCourseButton(),
              ),
            ),
            SizedBox(width: 16.wMin),
          ],
        ),
        Expanded(
          child: Center(
            child: _buildBottomUnitBar(context),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16.wMin),
            _buildEditCourseButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildEditCourseButton() {
    final color = AppTheme.cBgBrand;
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () {
        ManageModuleUnitsDialog.show(
          context: Get.context!,
          units: _units,
          onSave: controller.onSaveUnitSort,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: PlatformBackdropFilterWidget(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
          child: Container(
            height: 64.wMin,
            padding: EdgeInsets.symmetric(horizontal: 18.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '管理单元',
              style: TextStyle(
                color: color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomUnitBar(BuildContext context) {
    if (_units.isEmpty) return const SizedBox.shrink();
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999.wMin),
        child: PlatformBackdropFilterWidget(
          sigmaX: 4.wMin,
          sigmaY: 4.wMin,
          child: Container(
            height: 80.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSearchBackground.color,
              borderRadius: BorderRadius.circular(999.wMin),
              border: Border.all(
                color: AppTheme.cBorderDark.color,
                width: 1.wMin,
              ),
            ),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                key: controller.unitTabViewportKey,
                controller: controller.unitTabScrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_units.length, (i) {
                    final unit = _units[i];
                    final bool isActive = unit.uid == controller.activeUnitId.value;
                    return Padding(
                      padding: EdgeInsets.only(right: i == _units.length - 1 ? 0 : 12.wMin),
                      child: LWCircularButtonWidget(
                        key: controller.getUnitTabKey(i),
                        text: unit.name ?? 'Unit ${i + 1}',
                        isAction: isActive,
                        color: AppTheme.cBgBrand,
                        sclae: 1.02,
                        onTap: () {
                          controller.scrollToUnitIndex(i);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitSectionHeader(
    BuildContext context,
    int unitIndex,
    NewUnitResponseEntity<LessonResponseEntity> unit,
  ) {
    final LessonResponseEntity? objectiveLesson = _findObjectiveLesson(unit);
    final Color accent = AppTheme.cBgBrand;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 72.wMin),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [

            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      KeyedSubtree(
                        key: controller.getUnitSectionKey(unitIndex),
                        child: Text(
                          unit.name ?? '',
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.wMin),
                      CopyTagWidget(name: "单元ID", value: unit.uid.toString()),
                    ],
                  ),
                  SizedBox(height: 8.wMin),
                    _buildUnitKnowledgeCountWrap(unit),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TapScaleWidget(
                onTap: () {
                  controller.toUnitTarget(unit, objectiveLesson);
                },
                sclae: 1.03,
                child: Container(
                  height: 64.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999.wMin),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '单元目标',
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.wMin),
                      Icon(
                        Icons.chevron_right,
                        size: 24.wMin,
                        color: accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitMiddlePanel(NewUnitResponseEntity<LessonResponseEntity> unit) {
    final List<UnitLessonPlanStatisticEntity> lessonPlanList = unit.lessonPlanList ?? const <UnitLessonPlanStatisticEntity>[];
    final int lessonPlanTotal = unit.lessonPlanList?.length ?? 0;
    final int lessonPlanCount = unit.lessonPlanList?.where((e) => e.lessonPlan == true).length ?? 0;
    final int lessonExerciseCount = unit.lessonPlanList?.where((e) => e.exercise == true).length ?? 0;
    final UnitGrammarStatisticEntity? grammarStatistic = unit.grammarStatistic;
    final int totalStepCount = grammarStatistic?.totalStepCount ?? 7;
    final int finishedStepCount = (grammarStatistic?.finishedStepCount ?? 0).clamp(0, totalStepCount);
    final bool hasKnowledge = _getKnowledgeCount(unit, 'EN_WORD') > 0 ||
        _getKnowledgeCount(unit, 'EN_PHRASE') > 0 ||
        _getKnowledgeCount(unit, 'EN_SENTENCE') > 0;
    final bool grammarReady = finishedStepCount >= 6;
    final bool unitPlanEnabled = grammarReady && hasKnowledge;
    final bool hasUnitPlan = unit.unitPlan == true;
    final bool lessonPlanEnabled = hasUnitPlan;
    final bool lessonExerciseEnabled = lessonPlanCount > 0;
    final bool allLessonPlanDone = lessonPlanTotal > 0 && lessonPlanCount == lessonPlanTotal;
    final bool allLessonExerciseDone = lessonPlanTotal > 0 && lessonExerciseCount == lessonPlanTotal;
    final _PipelineVisualState grammarState = grammarReady ? _PipelineVisualState.done : _PipelineVisualState.current;
    final _PipelineVisualState unitPlanState = hasUnitPlan
        ? _PipelineVisualState.done
        : unitPlanEnabled
            ? _PipelineVisualState.current
            : _PipelineVisualState.pending;
    final _PipelineVisualState lessonState = allLessonPlanDone && allLessonExerciseDone
        ? _PipelineVisualState.done
        : lessonPlanEnabled
            ? _PipelineVisualState.current
            : _PipelineVisualState.pending;
    final _PipelineVisualState lessonPlanActionState = allLessonPlanDone
        ? _PipelineVisualState.done
        : lessonPlanEnabled
            ? _PipelineVisualState.current
            : _PipelineVisualState.pending;
    final _PipelineVisualState lessonExerciseActionState = allLessonExerciseDone
        ? _PipelineVisualState.done
        : lessonExerciseEnabled
            ? _PipelineVisualState.current
            : _PipelineVisualState.pending;
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(24.wMin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildPipelineColumn(
              index: 1,
              title: '语法管线',
              hint: _getGrammarStatusText(grammarStatistic),
              state: grammarState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPipelineActionButton(
                    label: '进入',
                    onTap: () {
                      controller.openUnitGrammarHub(unit);
                    },
                      state: grammarState,
                  ),
                  SizedBox(height: 8.wMin),
                  _buildGrammarProgressBar(
                    totalStepCount: totalStepCount,
                    finishedStepCount: finishedStepCount,
                    state: grammarState,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.wMin),
          Expanded(
            child: _buildPipelineColumn(
              index: 2,
              title: '单元计划',
              state: unitPlanState,
              child: ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.bookUnitPlan],
                child: _buildPipelineActionButton(
                  label: hasUnitPlan ? '重新生成' : '生成',
                  enabled: unitPlanEnabled,
                  state: unitPlanState,
                  onTap: unitPlanEnabled
                      ? () {
                          controller.generateUnitPlan(unit.uid);
                        }
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.wMin),
          Expanded(
            child: _buildPipelineColumn(
              index: 3,
              title: '课时',
              hint: '$lessonPlanCount/$lessonPlanTotal 课',
              state: lessonState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.bookUnitLessonPlan],
                    child: _buildPipelineActionButton(
                      label: '全部生成计划',
                      enabled: lessonPlanEnabled,
                        state: lessonPlanActionState,
                      onTap: lessonPlanEnabled
                          ? () {
                              controller.generateLessonPlan(unit.uid);
                            }
                          : null,
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  Wrap(
                    spacing: 4.wMin,
                    runSpacing: 4.wMin,
                    children: lessonPlanList
                        .map((lessonPlan) => ManageAuthBoxWidget(
                              authCodes: const [ManageAuthCode.bookUnitLessonPlan],
                              child: _buildPipelineLessonChip(
                                label: lessonPlan.lessonName ?? '',
                                  state: lessonPlan.lessonPlan == true
                                      ? _PipelineVisualState.done
                                      : lessonPlanEnabled
                                          ? _PipelineVisualState.current
                                          : _PipelineVisualState.pending,
                                onTap: lessonPlanEnabled && lessonPlan.lessonId != null
                                    ? () {
                                        controller.refreshOneLessonPlan(unit.uid, lessonPlan.lessonId!);
                                      }
                                    : null,
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 8.wMin),
                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.bookUnitLessonExercise],
                    child: _buildPipelineActionButton(
                      label: '全部生成题目',
                      enabled: lessonExerciseEnabled,
                        state: lessonExerciseActionState,
                      onTap: lessonExerciseEnabled
                          ? () {
                              controller.generateLessonTitle(unit.uid);
                            }
                          : null,
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  Wrap(
                    spacing: 4.wMin,
                    runSpacing: 4.wMin,
                    children: lessonPlanList
                        .map((lessonPlan) => ManageAuthBoxWidget(
                              authCodes: const [ManageAuthCode.bookUnitLessonExercise],
                              child: _buildPipelineLessonChip(
                                label: lessonPlan.lessonName ?? '',
                                  state: lessonPlan.exercise == true
                                      ? _PipelineVisualState.done
                                      : lessonPlan.lessonPlan == true
                                          ? _PipelineVisualState.current
                                          : _PipelineVisualState.pending,
                                onTap: lessonPlan.lessonPlan == true && lessonPlan.lessonId != null
                                    ? () {
                                        controller.generateOneLessonTitle(unit.uid, lessonPlan.lessonId!);
                                      }
                                    : null,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.wMin),
          Expanded(
            child: _buildPipelineColumn(
              index: 4,
              title: '写作课管线',
              state: _PipelineVisualState.pending,
              child: _buildPipelineActionButton(
                label: '待实现',
                enabled: false,
                state: _PipelineVisualState.pending,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitKnowledgeCountWrap(NewUnitResponseEntity<LessonResponseEntity> unit) {
    final List<Widget> tags = [
      _buildUnitKnowledgeCountTag(label: '单词', count: _getKnowledgeCount(unit, 'EN_WORD')),
      _buildUnitKnowledgeCountTag(label: '短语', count: _getKnowledgeCount(unit, 'EN_PHRASE')),
      _buildUnitKnowledgeCountTag(label: '句子', count: _getKnowledgeCount(unit, 'EN_SENTENCE')),
    ];
    return Wrap(
      spacing: 6.wMin,
      runSpacing: 6.wMin,
      children: tags,
    );
  }

  Widget _buildUnitKnowledgeCountTag({
    required String label,
    required int count,
  }) {
    final bool hasValue = count > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 5.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        color: hasValue ? const Color(0xff06B6D4).withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: hasValue ? const Color(0xff06B6D4).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
          width: 1.wMin,
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 16.wMin,
                color: hasValue ? const Color(0xffCFFAFE) : AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: ' $count',
              style: TextStyle(
                fontSize: 16.wMin,
                color: hasValue ? AppTheme.cTextPrimary : AppTheme.cTextDisabled,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineColumn({
    required int index,
    required String title,
    String? hint,
    required _PipelineVisualState state,
    required Widget child,
  }) {
    final bool isPending = state == _PipelineVisualState.pending;
    final Color titleColor = isPending ? AppTheme.cTextPrimary.withValues(alpha: 0.35) : AppTheme.cTextPrimary;
    final Color hintColor = isPending ? AppTheme.cTextPrimary.withValues(alpha: 0.3) : AppTheme.cTextSecondary.color;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              _buildPipelineDot(state),
              SizedBox(height: 8.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: state == _PipelineVisualState.pending ? titleColor : titleColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.wMin),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: titleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hint != null) ...[
                    SizedBox(width: 4.wMin),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: hintColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          child,
        ],
    );
  }

  Widget _buildGrammarProgressBar({
    required int totalStepCount,
    required int finishedStepCount,
    required _PipelineVisualState state,
  }) {
    final int stepCount = totalStepCount <= 0 ? 7 : totalStepCount;
    final Color doneColor = state == _PipelineVisualState.pending
        ? AppTheme.cBorderDark.color
        : _getPipelineAccentColor(state).withValues(alpha: 0.55);
    return Row(
      children: List.generate(stepCount, (index) {
        final bool isDone = index < finishedStepCount;
        return Expanded(
          child: Container(
            height: 6.wMin,
            margin: EdgeInsets.only(right: index == stepCount - 1 ? 0 : 4.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.wMin),
              color: isDone ? doneColor : AppTheme.cBorderDark.color,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPipelineActionButton({
    required String label,
    bool enabled = true,
    required _PipelineVisualState state,
    VoidCallback? onTap,
  }) {
    final Color backgroundColor = _getPipelineButtonBackgroundColor(state, enabled: enabled);
    final Color borderColor = _getPipelineButtonBorderColor(state, enabled: enabled);
    final Color textColor = _getPipelineButtonTextColor(state, enabled: enabled);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
      ),
      child: TapScaleWidget(
        sclae: 1.01,
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 11.wMin, vertical: 10.wMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: backgroundColor,
            borderRadius: BorderRadius.circular(6.wMin),
            border: Border.all(
                color: borderColor,
              width: 1.wMin,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.wMin,
                color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineLessonChip({
    required String label,
    required _PipelineVisualState state,
    required VoidCallback? onTap,
  }) {
    final bool enabled = state != _PipelineVisualState.pending;
    final Color backgroundColor = _getPipelineChipBackgroundColor(state);
    final Color borderColor = _getPipelineChipBorderColor(state);
    final Color textColor = _getPipelineChipTextColor(state);
    return TapScaleWidget(
      sclae: 1.01,
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 3.wMin),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6.wMin),
          border: Border.all(
            color: borderColor,
            width: 1.wMin,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.wMin,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  int _getKnowledgeCount(NewUnitResponseEntity<LessonResponseEntity> unit, String contentType) {
    for (final UnitKnowledgeTypeCountEntity item in unit.knowledgeTypeCountList ?? const <UnitKnowledgeTypeCountEntity>[]) {
      if (item.contentType == contentType) {
        return item.count ?? 0;
      }
    }
    return 0;
  }

  String _getGrammarStatusText(UnitGrammarStatisticEntity? grammarStatistic) {
    if (grammarStatistic?.grammarAnalyze != true) return '未生成';
    final int candidateTargetCount = grammarStatistic?.candidateTargetCount ?? 0;
    if (candidateTargetCount > 0) return '$candidateTargetCount 待审';
    final int totalStepCount = grammarStatistic?.totalStepCount ?? 7;
    final int finishedStepCount = (grammarStatistic?.finishedStepCount ?? 0).clamp(0, totalStepCount);
    return '$finishedStepCount/$totalStepCount';
  }

  Widget _buildPipelineDot(_PipelineVisualState state) {
    if (state == _PipelineVisualState.pending) {
      return SizedBox(
        width: 24.wMin,
        height: 24.wMin,
        child: DottedBorder(
          color: AppTheme.cBorderDark.color,
          strokeWidth: 1.wMin,
          dashPattern: [2.wMin, 2.wMin],
          borderType: BorderType.Circle,
          padding: EdgeInsets.zero,
          child: Container(
            width: 24.wMin,
            height: 24.wMin,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Container(
              width: 22.wMin,
              height: 22.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cSurfaceSoildBg.color,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      width: 24.wMin,
      height: 24.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.cTextDisabled,
          width: 1.wMin,
        ),
      ),
      child: Container(
        width: 22.wMin,
        height: 22.wMin,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getPipelineAccentColor(state),
        ),
      ),
    );
  }

  Color _getPipelineAccentColor(_PipelineVisualState state) {
    if (state == _PipelineVisualState.done) return const Color(0xff22C55E);
    return const Color(0xff0EA5E9);
  }

  Color _getPipelineButtonBackgroundColor(_PipelineVisualState state, {required bool enabled}) {
    if (!enabled || state == _PipelineVisualState.pending) {
      return AppTheme.cSurfaceTranslucentElevated.color;
    }
    return _getPipelineAccentColor(state).withValues(alpha: 0.12);
  }

  Color _getPipelineButtonBorderColor(_PipelineVisualState state, {required bool enabled}) {
    if (!enabled || state == _PipelineVisualState.pending) {
      return AppTheme.cBorderTranslucentSubtle.color;
    }
    return _getPipelineAccentColor(state).withValues(alpha: 0.2);
  }

  Color _getPipelineButtonTextColor(_PipelineVisualState state, {required bool enabled}) {
    if (!enabled || state == _PipelineVisualState.pending) {
      return AppTheme.cTextDisabled;
    }
    return AppTheme.cTextPrimary;
  }

  Color _getPipelineChipBackgroundColor(_PipelineVisualState state) {
    if (state == _PipelineVisualState.done || state == _PipelineVisualState.current) {
      return _getPipelineAccentColor(state).withValues(alpha: 0.12);
    }
    return Colors.white.withValues(alpha: 0.1);
  }

  Color _getPipelineChipBorderColor(_PipelineVisualState state) {
    if (state == _PipelineVisualState.done || state == _PipelineVisualState.current) {
      return _getPipelineAccentColor(state).withValues(alpha: 0.2);
    }
    return Colors.white.withValues(alpha: 0.15);
  }

  Color _getPipelineChipTextColor(_PipelineVisualState state) {
    if (state == _PipelineVisualState.pending) {
      return AppTheme.cTextSecondary;
    }
    return AppTheme.cTextPrimary;
  }


  LessonResponseEntity? _findObjectiveLesson(NewUnitResponseEntity<LessonResponseEntity> unit) {
    final List<LessonResponseEntity> lessons = unit.lessonDTOList?.cast<LessonResponseEntity>() ?? const <LessonResponseEntity>[];
    for (final LessonResponseEntity lesson in lessons) {
      if (lesson.isUnitTARGET) {
        return lesson;
      }
    }
    return null;
  }

  Widget _buildUnitLessonsRow(
    BuildContext context,
    NewUnitResponseEntity<LessonResponseEntity> unit,
  ) {
    final List<LessonResponseEntity> lessons = controller.buildDisplayLessons(unit);
    if (lessons.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6.wMin,
        mainAxisSpacing: 10.wMin,
        mainAxisExtent: 360.wMin,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _buildLessonCircleItem(
          context: context,
          unit: unit,
          lesson: lesson,
          borderColor: AppTheme.cBgBrand,
        );
      },
    );
  }

  Widget _buildLessonCircleItem({
    required BuildContext context,
    required NewUnitResponseEntity<LessonResponseEntity> unit,
    required LessonResponseEntity lesson,
    required Color borderColor,
  }) {
    final int normalCount = lesson.exerciseNormalCount ?? 0;
    final int totalCount = lesson.exerciseCount ?? 0;
    double progress = 0;
    if (totalCount > 0) {
      progress = (normalCount / totalCount).clamp(0, 1).toDouble();
    }
    final bool isComplete = totalCount > 0 && normalCount >= totalCount;
    final bool showProgress = !lesson.isUnitTEST;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        final double circleSize = (maxW * 0.98).clamp(120.wMin, 220.wMin).toDouble();
        return Column(
          children: [
            TapScaleWidget(
              sclae: 1,
              onTap: () {
                controller.toUnitTarget(unit, lesson);
              },
              child: SizedBox(
                width: circleSize,
                height: circleSize,
                child: LessonCircleWidget(
                  size: circleSize,
                  innerSize: circleSize * 0.92,
                  continuousProgress: false,
                  isComplete: isComplete,
                  progress: progress,
                  showNew: false,
                  selected: false,
                  borderColor: borderColor,
                  showProgess: showProgress,
                  child: _LessonCover(url: lesson.effectiveCoverUrl),
                ),
              ),
            ),
            SizedBox(height: 12.wMin),
            Text(
              lesson.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.wMin),
            TapScaleWidget(
              onTap: () {
                controller.toUnitTarget(unit, lesson);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999.wMin),
                  border: Border.all(
                    color: AppTheme.cSurfaceQuaternary.color.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '题目列表 $normalCount/$totalCount',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    Icon(
                      Icons.chevron_right,
                      size: 18.wMin,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LessonCover extends StatelessWidget {
  final String url;

  const _LessonCover({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        color: const Color(0xff1A2032),
        alignment: Alignment.center,
        child: buildEmptyWidget(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xff1A2032),
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            size: 40.wMin,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        );
      },
    );
  }
}
