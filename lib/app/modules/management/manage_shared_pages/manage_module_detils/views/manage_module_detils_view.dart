import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../../../../common/widgets/custom_button/LWCircularButton.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_module_detils_binding.dart';
import '../controllers/manage_module_detils_controller.dart';
import 'manage_module_units_dialog.dart';
import 'writing_task_card_item_widget.dart';

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
  bool get _isWritingSpecialty => controller.isWritingSpecialty;

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
    final CourseUnitWritingPipelineEntity? writingPipeline = unit.writingPipeline;
    final int totalStepCount = grammarStatistic?.totalStepCount ?? 7;
    final int finishedStepCount = (grammarStatistic?.finishedStepCount ?? 0).clamp(0, totalStepCount);
    final int writingTaskCount = writingPipeline?.taskCount ?? 0;
    final int writingCompositionTaskCount = writingPipeline?.compositionTaskCount ?? 0;
    final bool hasKnowledge = _getKnowledgeCount(unit, 'EN_WORD') > 0 ||
        _getKnowledgeCount(unit, 'EN_PHRASE') > 0 ||
        _getKnowledgeCount(unit, 'EN_SENTENCE') > 0;
    final bool grammarReady = finishedStepCount >= 6;
    final bool unitPlanEnabled = grammarReady && hasKnowledge;
    final bool hasUnitPlan = unit.unitPlan == true;
    final bool allLessonPlanDone = lessonPlanTotal > 0 && lessonPlanCount == lessonPlanTotal;
    final bool allLessonExerciseDone = lessonPlanTotal > 0 && lessonExerciseCount == lessonPlanTotal;
    final _PipelineVisualState grammarState = grammarReady ? _PipelineVisualState.done : _PipelineVisualState.current;
    final _PipelineVisualState writingState = writingTaskCount <= 0
        ? _PipelineVisualState.pending
        : writingCompositionTaskCount >= writingTaskCount
            ? _PipelineVisualState.done
            : _PipelineVisualState.current;
    final _PipelineVisualState unitPlanState = hasUnitPlan
        ? _PipelineVisualState.done
        : unitPlanEnabled
            ? _PipelineVisualState.current
            : _PipelineVisualState.pending;
      final _PipelineVisualState lessonState =
          allLessonPlanDone && allLessonExerciseDone ? _PipelineVisualState.done : _PipelineVisualState.current;
      final _PipelineVisualState lessonPlanActionState =
          allLessonPlanDone ? _PipelineVisualState.done : _PipelineVisualState.current;
      final _PipelineVisualState lessonExerciseActionState =
          allLessonExerciseDone ? _PipelineVisualState.done : _PipelineVisualState.current;
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
          if (_isWritingSpecialty) ...[
            Expanded(
              child: _buildPipelineColumn(
                index: 2,
                title: '写作管线',
                hint: '$writingCompositionTaskCount/$writingTaskCount',
                state: writingState,
                child: _buildWritingPipelineContent(
                  unitId: unit.uid,
                  taskCount: writingTaskCount,
                  compositionTaskCount: writingCompositionTaskCount,
                  state: writingState,
                ),
              ),
            ),
            SizedBox(width: 16.wMin),
          ] else ...[
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
          ],
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
                        state: lessonPlanActionState,
                        onTap: () {
                          controller.generateLessonPlan(unit.uid);
                        },
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  _buildPipelineLessonChipRow(
                    lessonPlanList: lessonPlanList,
                    authCodes: const [ManageAuthCode.bookUnitLessonPlan],
                    stateBuilder: (lessonPlan) => lessonPlan.lessonPlan == true
                        ? _PipelineVisualState.done
                          : _PipelineVisualState.current,
                      onTapBuilder: (lessonPlan) => lessonPlan.lessonId != null
                        ? () {
                            controller.refreshOneLessonPlan(unit.uid, lessonPlan.lessonId!);
                          }
                        : null,
                  ),
                  SizedBox(height: 8.wMin),
                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.bookUnitLessonExercise],
                    child: _buildPipelineActionButton(
                      label: '全部生成题目',
                        state: lessonExerciseActionState,
                        onTap: () {
                          controller.generateLessonTitle(unit.uid);
                        },
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  _buildPipelineLessonChipRow(
                    lessonPlanList: lessonPlanList,
                    authCodes: const [ManageAuthCode.bookUnitLessonExercise],
                    stateBuilder: (lessonPlan) => lessonPlan.exercise == true
                        ? _PipelineVisualState.done
                        : lessonPlan.lessonPlan == true
                            ? _PipelineVisualState.current
                            : _PipelineVisualState.pending,
                    onTapBuilder: (lessonPlan) => lessonPlan.lessonPlan == true && lessonPlan.lessonId != null
                        ? () {
                            controller.generateOneLessonTitle(unit.uid, lessonPlan.lessonId!);
                          }
                        : null,
                  ),

                ],
              ),
            ),
          ),
      
          if (!_isWritingSpecialty) ...[
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
                color: hasValue ? AppTheme.cTextPrimary.color : AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: ' $count',
              style: TextStyle(
                fontSize: 16.wMin,
                color: hasValue ? AppTheme.cTextPrimary.color : AppTheme.cTextDisabled.color,
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
        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6.wMin),
          border: Border.all(
            color: borderColor,
            width: 1.wMin,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.wMin,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineLessonChipRow({
    required List<UnitLessonPlanStatisticEntity> lessonPlanList,
    required List<String> authCodes,
    required _PipelineVisualState Function(UnitLessonPlanStatisticEntity lessonPlan) stateBuilder,
    required VoidCallback? Function(UnitLessonPlanStatisticEntity lessonPlan) onTapBuilder,
  }) {
    if (lessonPlanList.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 4.wMin;
        final List<double> widths = _calculatePipelineLessonChipWidths(
          labels: lessonPlanList.map((lessonPlan) => lessonPlan.lessonName ?? '').toList(),
          maxWidth: constraints.maxWidth,
          spacing: spacing,
        );
        return Row(
          children: [
            for (int i = 0; i < lessonPlanList.length; i++) ...[
              if (i != 0) SizedBox(width: spacing),
              SizedBox(
                width: widths[i],
                child: ManageAuthBoxWidget(
                  authCodes: authCodes,
                  child: _buildPipelineLessonChip(
                    label: lessonPlanList[i].lessonName ?? '',
                    state: stateBuilder(lessonPlanList[i]),
                    onTap: onTapBuilder(lessonPlanList[i]),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  List<double> _calculatePipelineLessonChipWidths({
    required List<String> labels,
    required double maxWidth,
    required double spacing,
  }) {
    if (labels.isEmpty) return const <double>[];
    final double availableWidth = maxWidth - (spacing * (labels.length - 1));
    final List<double> minWidths = labels.map(_measurePipelineLessonChipMinWidth).toList();
    final double totalMinWidth = minWidths.fold(0, (sum, width) => sum + width);
    if (availableWidth <= 0) {
      return List<double>.filled(labels.length, 0);
    }
    if (totalMinWidth < availableWidth) {
      final double extraWidth = (availableWidth - totalMinWidth) / labels.length;
      return minWidths.map((width) => width + extraWidth).toList();
    }
    final double scale = availableWidth / totalMinWidth;
    return minWidths.map((width) => width * scale).toList();
  }

  double _measurePipelineLessonChipMinWidth(String label) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 14.wMin,
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width + (12.wMin) + (2.wMin);
  }

  Widget _buildWritingPipelineContent({
    required int? unitId,
    required int taskCount,
    required int compositionTaskCount,
    required _PipelineVisualState state,
  }) {
    final int progressTotal = taskCount <= 0 ? 1 : taskCount;
    final int progressCount = compositionTaskCount.clamp(0, progressTotal);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPipelineActionButton(
          label: '写作管线',
          enabled: unitId != null,
          state: state,
          onTap: unitId == null
              ? null
              : () {
                  TagRoutes.toNamed(
                    Routes.MANAGE_UNIT_WRITING_PIPELINE,
                    arguments: {
                      'unitId': unitId,
                      'isManagement': true,
                    },
                  );
                },
        ),
        SizedBox(height: 8.wMin),
        _buildGrammarProgressBar(
          totalStepCount: progressTotal,
          finishedStepCount: progressCount,
          state: state,
        ),
      ],
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
    final List<LessonResponseEntity> lessonDTOList = unit.lessonDTOList?.cast<LessonResponseEntity>() ?? const <LessonResponseEntity>[];
    final CourseUnitWritingTaskCardEntity? writingTaskCard =
        _isWritingSpecialty && unit.writingTaskCard?.type == 'WRITING_TASK' ? unit.writingTaskCard : null;
    LessonResponseEntity? writingLesson;
    if (writingTaskCard != null) {
      for (final LessonResponseEntity lesson in lessonDTOList) {
        if (lesson.uid == writingTaskCard.lessonId) {
          writingLesson = lesson;
          break;
        }
      }
    }
    if (lessons.isEmpty && writingTaskCard == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 6.wMin;
        final double runSpacing = 10.wMin;
        final double cellWidth =
            (constraints.maxWidth - (spacing * (ManageModuleDetilsController.lessonGridCrossAxisCount - 1))) /
                ManageModuleDetilsController.lessonGridCrossAxisCount;
        final double lessonCardTopHeight = (cellWidth * 0.9).clamp(120.wMin, 220.wMin).toDouble();
        final double writingCardWidth =
            (cellWidth * ManageModuleDetilsController.writingTaskCardGridSpan) +
                (spacing * (ManageModuleDetilsController.writingTaskCardGridSpan - 1));
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            ...lessons.map((lesson) => SizedBox(
                  width: cellWidth,
                  child: _buildLessonCircleItem(
                    context: context,
                    unit: unit,
                    lesson: lesson,
                    borderColor: AppTheme.cBgBrand,
                  ),
                )),
            if (writingTaskCard != null)
              SizedBox(
                width: writingCardWidth,
                child: WritingTaskCardItemWidget(
                  writingTaskCard: writingTaskCard,
                  lessonName: writingLesson?.name ?? '',
                  lessonIdText: (writingTaskCard.lessonId ?? writingLesson?.uid)?.toString() ?? '',
                  topCardHeight: lessonCardTopHeight,
                  onTap: () {
                    TagRoutes.toNamed(
                      Routes.MANAGE_UNIT_WRITING_TASK_LIST,
                      arguments: {
                        'unitId': unit.uid,
                        'isManagement': true,
                      },
                    );
                  },
                ),
              ),
          ],
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
            CopyTagWidget(name: '课时', value: lesson.uid.toString()),
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
