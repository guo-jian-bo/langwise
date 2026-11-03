import 'package:flutter/material.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/zhenxie_widgets/zhenxie_composition_task_card_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../zhenxie/zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';
import '../../../zhenxie/zhenxie_composition_writing/models/zhenxie_composition_writing_models.dart';
import '../controllers/course_unit_target_controller.dart';

/// 课程目标页里的写作任务卡片。
class CourseUnitTargetWritingCardWidget extends StatelessWidget {
  final CourseUnitTargetController controller;
  final KnowledgeCommonEntityList data;

  const CourseUnitTargetWritingCardWidget({
    super.key,
    required this.controller,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final CompositionTaskModel task = _buildCompositionTask();
    return ZhenxieCompositionTaskCardWidget(
      task: task,
      genre: _buildCompositionGenre(),
      beatMap: _buildBeatMap(),
      beatOrderList: _buildBeatOrderList(),
      difficultyLabel: _getDifficultyLabel(task),
      coverUrl: _getTaskCoverUrl(),
      genreColor: _getGenreColor(),
      langTextGetter: _getLangText,
      beatNameGetter: _getBeatName,
      headLabelGetter: _getHeadLabel,
      tailLabelGetter: _getTailLabel,
      hasHeadGetter: _hasHead,
      hasTailGetter: _hasTail,
      onTap: () => _handleTap(context, task),
    );
  }

  /// 处理卡片点击后的权限校验与详情跳转。
  Future<void> _handleTap(BuildContext context, CompositionTaskModel task) async {
    if (data.jump == null) return;
    if (!controller.isManagement) {
      final bool lock = await LockUtils.checkLock(
        data.rights,
        context,
        contentType: data.content?.type ?? '',
      );
      if (lock) return;
    }

    data.jump?.params?['isManagement'] = controller.isManagement;
    await JumpPageUtils.jumpUserPages(data.jump);

    // TagRoutes.toNamed(
    //   Routes.ZHENXIE_TASK_DETAILS,
    //   arguments: <String, dynamic>{
    //     'isManagement': controller.isManagement,
    //     'taskUid': task.uid,
    //     'contentSource': WritingBoardContentSourceMacro.exemplar.value,
    //     'editPolicy': WritingBoardEditPolicyMacro.readOnly.value,
    //   },
    // );
  }

  /// 将课程目标里的写作知识点映射为任务卡片数据。
  CompositionTaskModel _buildCompositionTask() {
    final CompositionStageModel stage = _buildCompositionStage();
    return CompositionTaskModel(
      uid: data.content?.uid ?? data.contentId,
      coverUrl: _getTaskCoverUrl(),
      stageNid: stage.nid,
      name: _buildTaskName(),
      stem: _buildTaskStem(),
      blueprint: stage.compositionBlueprint,
      stage: stage,
      difficulty: stage.difficulty,
    );
  }

  /// 构建写作任务标题多语言数据。
  List<LanguageText> _buildTaskName() {
    final list = <LanguageText>[];
    if ((data.title ?? '').isNotEmpty) {
      list.add(LanguageText(lang: 'zh', text: data.title));
    }
    if ((data.subTitle ?? '').isNotEmpty) {
      list.add(LanguageText(lang: 'en', text: data.subTitle));
    }
    return list;
  }

  /// 构建写作任务说明，优先使用接口 description。
  List<LanguageText> _buildTaskStem() {
    final list = data.description?.whereType<LanguageText>().toList() ?? <LanguageText>[];
    if (list.isNotEmpty) return list;
    if ((data.subTitle ?? '').isEmpty) return const <LanguageText>[];
    return [LanguageText(lang: 'zh', text: data.subTitle)];
  }

  /// 将课程目标里的 compositionStage 数据转成写作任务 stage。
  CompositionStageModel _buildCompositionStage() {
    final paramsData = data.params?.data;
    return CompositionStageModel(
      nid: paramsData?.nid,
      coverUrl: _getTaskCoverUrl(),
      difficulty: _buildCardDifficulty(paramsData?.difficulty),
      slots: _buildStageSlots(paramsData),
      headFill: paramsData?.headFill == true ? 'write' : 'hidden',
      tailFill: paramsData?.tailFill == true ? 'write' : 'hidden',
      compositionBlueprint: _buildCompositionBlueprint(paramsData),
    );
  }

  /// 构建写作任务蓝图数据。
  CompositionBlueprintModel _buildCompositionBlueprint(KnowledgeCommonEntityListParamsData? paramsData) {
    return CompositionBlueprintModel(
      nid: paramsData?.compositionBlueprintNid,
      coverUrl: paramsData?.coverUrl,
      name: paramsData?.name?.whereType<LanguageText>().toList() ?? const <LanguageText>[],
      frame: _buildBlueprintFrame(paramsData),
    );
  }

  /// 构建文首文尾蓝图信息。
  CompositionBlueprintFrameModel _buildBlueprintFrame(KnowledgeCommonEntityListParamsData? paramsData) {
    return CompositionBlueprintFrameModel(
      hasHead: paramsData?.hasHead == true && paramsData?.headFill == true,
      hasTail: paramsData?.hasTail == true && paramsData?.tailFill == true,
      headName: paramsData?.headName?.whereType<LanguageText>().toList() ?? const <LanguageText>[],
      tailName: paramsData?.tailName?.whereType<LanguageText>().toList() ?? const <LanguageText>[],
    );
  }

  /// 构建阶段槽位列表，只保留真实可展示的 beat。
  List<CompositionStageSlotModel> _buildStageSlots(KnowledgeCommonEntityListParamsData? paramsData) {
    final slots = <CompositionStageSlotModel>[];
    for (final slot in paramsData?.slots ?? const <KnowledgeCommonEntityListParamsDataSlot?>[]) {
      if (slot?.fill == 'hidden' || slot?.beatNid?.isEmpty != false) continue;
      slots.add(
        CompositionStageSlotModel(
          order: slot?.order,
          beatNid: slot?.beatNid,
          paragraphTypeNid: slot?.paragraphTypeNid,
          paragraphTypeName: slot?.paragraphType?.name?.whereType<LanguageText>().toList() ?? const <LanguageText>[],
          fill: slot?.fill,
        ),
      );
    }
    return slots;
  }

  /// 将蓝图难度转换成任务卡片组件识别的难度结构。
  CardContentDifficulty? _buildCardDifficulty(ArticleBlueprintEntityDifficulty? difficulty) {
    if (difficulty == null) return null;
    return CardContentDifficulty(
      min: difficulty.min,
      max: difficulty.max,
    );
  }

  /// 构建题材标签，当前课程目标里缺少独立 genre 时降级为分类标签。
  CompositionGenreModel? _buildCompositionGenre() {
    final genreName = data.category?.text ?? data.subCategory?.text ?? '';
    if (genreName.isEmpty) return null;
    return CompositionGenreModel(
      name: [LanguageText(lang: 'zh', text: genreName)],
    );
  }

  /// 构建段落修辞映射。
  Map<String, ParagraphRhetoricalEntityList> _buildBeatMap() {
    return <String, ParagraphRhetoricalEntityList>{
      for (final item in controller.paragraphRhetoricalList)
        if ((item.nid ?? '').isNotEmpty) item.nid!: item,
    };
  }

  /// 构建段落顺序列表。
  List<String> _buildBeatOrderList() {
    return controller.paragraphRhetoricalList.where((item) => (item.nid ?? '').isNotEmpty).map((item) => item.nid!).toList();
  }

  /// 使用当前语言偏好返回展示文案。
  String _getLangText(List<LanguageText>? values, String lang) {
    return LearningLangUtils.getShowLList(values)?.text ?? '';
  }

  /// 获取段落名称。
  String _getBeatName(String? beatNid) {
    if (beatNid == 'head') return '文首';
    if (beatNid == 'tail') return '文末';
    final ParagraphRhetoricalEntityList? beat = _buildBeatMap()[beatNid];
    return LearningLangUtils.getShowLList(beat?.name)?.text ?? '';
  }

  /// 判断是否有文首。
  bool _hasHead(CompositionStageModel stage) {
    return stage.compositionBlueprint?.frame?.hasHead == true;
  }

  /// 判断是否有文尾。
  bool _hasTail(CompositionStageModel stage) {
    return stage.compositionBlueprint?.frame?.hasTail == true;
  }

  /// 获取文首名称。
  String _getHeadLabel(CompositionStageModel stage) {
    return LearningLangUtils.getShowLList(stage.compositionBlueprint?.frame?.headName)?.text ?? '';
  }

  /// 获取文尾名称。
  String _getTailLabel(CompositionStageModel stage) {
    return LearningLangUtils.getShowLList(stage.compositionBlueprint?.frame?.tailName)?.text ?? '';
  }

  /// 获取写作任务封面。
  String _getTaskCoverUrl() {
    if ((data.coverImage?.url ?? '').isNotEmpty) return data.coverImage!.url!;
    if ((data.params?.data?.coverUrl ?? '').isNotEmpty) return data.params!.data!.coverUrl!;
    return '';
  }

  /// 获取难度文案。
  String _getDifficultyLabel(CompositionTaskModel task) {
    final CardContentDifficulty? difficulty = task.stage?.difficulty;
    final String minDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.min)?.name?.text ?? '';
    final String maxDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.max)?.name?.text ?? '';
    if (minDifficultyLabel.isEmpty || maxDifficultyLabel.isEmpty) return '';
    return minDifficultyLabel == maxDifficultyLabel ? minDifficultyLabel : '$minDifficultyLabel-$maxDifficultyLabel';
  }

  /// 获取题材颜色。
  Color _getGenreColor() {
    return AppTheme.cSurfaceBrand.color;
  }
}
