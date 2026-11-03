import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/widgets/custom_button/LWCircularButton.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_module_detils_binding.dart';
import '../controllers/manage_module_detils_controller.dart';
import 'manage_module_units_dialog.dart';

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
              child: SizedBox(
                width: 320.wMin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                    SizedBox(height: 8.wMin),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Opacity(
                opacity: objectiveLesson != null ? 1 : 0,
                child: TapScaleWidget(
                  onTap: () {
                    if (objectiveLesson == null) return;
                    controller.toUnitTarget(unit, objectiveLesson);
                  },
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitMiddlePanel(NewUnitResponseEntity<LessonResponseEntity> unit) {
    final int lessonPlanTotal = unit.lessonPlanList?.length ?? 0;
    final int lessonPlanCount = unit.lessonPlanList?.where((e) => e.lessonPlan == true).length ?? 0;
    final int lessonExerciseCount = unit.lessonPlanList?.where((e) => e.exercise == true).length ?? 0;
    final int articleTotalCount = unit.articleStatistic?.totalCount ?? 0;
    final int articleNormalCount = unit.articleStatistic?.normalCount ?? 0;
    final int songTotalCount = unit.songStatistic?.totalCount ?? 0;
    final int songNormalCount = unit.songStatistic?.normalCount ?? 0;
    final UnitGrammarStatisticEntity? grammarStatistic = unit.grammarStatistic;
    final bool hasGrammarReview = grammarStatistic?.grammarAnalyze == true;
    final int candidateTargetCount = grammarStatistic?.candidateTargetCount ?? 0;
    final int targetTotalCount = grammarStatistic?.targetTotalCount ?? 0;
    final int sentenceTotalCount = grammarStatistic?.sentenceTotalCount ?? 0;
    final int boundSentenceCount = grammarStatistic?.boundSentenceCount ?? 0;
    return SizedBox(
      height: 100.wMin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildUnitMiddlePanelCard(
              title: '单元计划',
              accentColor: const Color(0xff00C2FF),
              titleTag: unit.unitPlan == true
                  ? _buildMiddlePanelTag(
                      text: '已有计划',
                      textColor: const Color(0xff17C964),
                      backgroundColor: const Color(0xff17C964).withValues(alpha: 0.12),
                    )
                  : null,
              trailing: null,
              actions: [
                _buildMiddlePanelButtonWrap(
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.bookUnitPlan],
                    child: _buildPanelActionButton(
                      label: '生成单元计划',
                      onTap: () {
                        controller.generateUnitPlan(unit.uid);
                      },
                      fillColor: const Color(0xff0A4F68),
                      foregroundColor: const Color(0xff8EE7FF),
                      borderColor: const Color(0xff1E7899).withValues(alpha: 0.48),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: _buildUnitMiddlePanelCard(
              title: '课时计划',
              accentColor: const Color(0xff7C5CFF),
              titleTag: null,
              trailing: _buildMiddlePanelInfoText('$lessonPlanCount/$lessonPlanTotal 有计划  $lessonExerciseCount/$lessonPlanTotal 有题目'),
              actions: [
                _buildMiddlePanelButtonWrap(
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.bookUnitLessonPlan],
                    child: _buildPanelActionButton(
                      label: '生成全部课时计划',
                      onTap: () {
                        controller.generateLessonPlan(unit.uid);
                      },
                      fillColor: const Color(0xff0F503F),
                      foregroundColor: const Color(0xffA7F3D0),
                      borderColor: const Color(0xff1C7A62).withValues(alpha: 0.45),
                    ),
                  ),
                ),
                _buildMiddlePanelButtonWrap(
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.bookUnitLessonExercise],
                    child: _buildPanelActionButton(
                      label: '生成全部课时题目',
                      onTap: () {
                        controller.generateLessonTitle(unit.uid);
                      },
                      fillColor: const Color(0xff3E245D),
                      foregroundColor: const Color(0xffD8B4FE),
                      borderColor: const Color(0xff7C3AED).withValues(alpha: 0.42),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: _buildUnitMiddlePanelCard(
              title: '单元语法',
              accentColor: const Color(0xffF59E0B),
              titleTag: _buildMiddlePanelTag(
                text: hasGrammarReview ? '待审核$candidateTargetCount' : '未生成',
                textColor: const Color(0xffF59E0B),
                backgroundColor: const Color(0xffF59E0B).withValues(alpha: 0.12),
              ),
              trailing: _buildMiddlePanelInfoText('$targetTotalCount'
                  'Target  $boundSentenceCount/$sentenceTotalCount句'),
              actions: [
                _buildMiddlePanelButtonWrap(
                  child: _buildPanelActionButton(
                    label: '进入审核',
                    onTap: () {
                      controller.openUnitGrammarHub(unit);
                    },
                    fillColor: const Color(0xff4C1D95),
                    foregroundColor: const Color(0xffE9D5FF),
                    borderColor: const Color(0xff7C3AED).withValues(alpha: 0.44),
                  ),
                ),
                _buildMiddlePanelButtonWrap(
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.bookUnitSentence],
                    child: _buildPanelActionButton(
                      label: _getGrammarGenerateButtonLabel(unit.grammarAnalyzed),
                      onTap: () {
                        controller.runUnitGrammarAnalyze(unit);
                      },
                      fillColor: const Color(0xff5B3E11),
                      foregroundColor: const Color(0xffFCD34D),
                      borderColor: const Color(0xffF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: _buildUnitMiddlePanelCard(
              title: '文章',
              accentColor: const Color(0xffF59E0B),
              titleTag: null,
              trailing: _buildMiddlePanelInfoText('总计$articleTotalCount篇  上架$articleNormalCount篇'),
              actions: [
                _buildMiddlePanelButtonWrap(
                  child: _buildPanelActionButton(
                    label: '查看',
                    onTap: () {
                      controller.toUnitTargetKnowledgeType(unit, ElementsCardType.text);
                    },
                  ),
                ),
                _buildMiddlePanelButtonWrap(
                  child: _buildPanelActionButton(
                    label: '关联',
                    onTap: () {
                      controller.onRelateArticle(unit);
                    },
                  ),
                ),
                _buildMiddlePanelButtonWrap(
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.courseUnitTextRemix],
                    child: _buildPanelActionButton(
                      label: _getCommonGenerateButtonLabel(unit.remixTextGenerateType),
                      onTap: () {
                        controller.generateLessonArticle(unit.uid);
                      },
                      fillColor: const Color(0xff5B3E11),
                      foregroundColor: const Color(0xffFCD34D),
                      borderColor: const Color(0xffF59E0B).withValues(alpha: 0.38),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: _buildUnitMiddlePanelCard(
              title: '歌曲',
              accentColor: const Color(0xffD89B17),
              titleTag: null,
              trailing: _buildMiddlePanelInfoText('总计$songTotalCount首  上架$songNormalCount首'),
              actions: [
                _buildMiddlePanelButtonWrap(
                  child: _buildPanelActionButton(
                    label: '查看',
                    onTap: () {
                      controller.toUnitTargetKnowledgeType(unit, ElementsCardType.song);
                    },
                  ),
                ),
                _buildMiddlePanelButtonWrap(
                  child: _buildPanelActionButton(
                    label: '关联',
                    onTap: () {
                      controller.onRelateSong(unit);
                    },
                  ),
                ),
                _buildMiddlePanelButtonWrap(
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.courseUnitSongGenerate],
                    child: _buildPanelActionButton(
                      label: _getCommonGenerateButtonLabel(unit.songGenerateType),
                      onTap: () {
                        controller.generateLessonSong(unit.uid);
                      },
                      fillColor: const Color(0xff3E245D),
                      foregroundColor: const Color(0xffD8B4FE),
                      borderColor: const Color(0xff7C3AED).withValues(alpha: 0.38),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitMiddlePanelCard({
    required String title,
    required Color accentColor,
    Widget? titleTag,
    required Widget? trailing,
    required List<Widget> actions,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 12.wMin),
      decoration: _buildMiddleCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3.wMin,
                height: 18.wMin,
                margin: EdgeInsets.only(right: 8.wMin),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (titleTag != null) ...[
                SizedBox(width: 8.wMin),
                titleTag,
              ],
              if (trailing != null) ...[
                const Spacer(),
                trailing,
              ],
            ],
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                actions[i],
                if (i != actions.length - 1) SizedBox(width: 8.wMin),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiddlePanelTag({
    required String text,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Container(
      height: 24.wMin,
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.wMin,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMiddlePanelInfoText(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16.wMin,
        color: Colors.white.withValues(alpha: 0.72),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildMiddlePanelButtonWrap({
    required Widget child,
  }) {
    return child;
  }

  BoxDecoration _buildMiddleCardDecoration() {
    return BoxDecoration(
      color: const Color(0xff091126).withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(16.wMin),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.06),
        width: 1.wMin,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12.wMin,
          offset: Offset(0, 4.wMin),
        ),
      ],
    );
  }

  Widget _buildPanelActionButton({
    required String label,
    required VoidCallback onTap,
    Color? fillColor,
    Color? foregroundColor,
    Color? borderColor,
  }) {
    final Color effectiveFillColor = fillColor ?? Colors.white.withValues(alpha: 0.06);
    final Color effectiveForegroundColor = foregroundColor ?? Colors.white.withValues(alpha: 0.82);
    final Color effectiveBorderColor = borderColor ?? Colors.white.withValues(alpha: 0.08);
    return TapScaleWidget(
      sclae: 1.01,
      onTap: onTap,
      child: Container(
        height: 34.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: effectiveFillColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: effectiveBorderColor,
            width: 1.wMin,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.wMin),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.wMin,
            color: effectiveForegroundColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getGrammarGenerateButtonLabel(int? grammarAnalyzed) {
    if (grammarAnalyzed == null) return '生成语法单元';
    if (grammarAnalyzed == 1) return '生成中';
    if (grammarAnalyzed == 2) return '重新生成';
    if (grammarAnalyzed == -1) return '失败';
    return '生成语法单元';
  }

  String _getCommonGenerateButtonLabel(int? generateType) {
    if (generateType == null) return '生成';
    if (generateType == 1) return '生成中';
    if (generateType == 2) return '重新生成';
    if (generateType == -1) return '失败';
    return '生成';
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
