import 'package:flutter/material.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/app/modules/zhenxie/zhenxie_composition_writing/models/zhenxie_composition_writing_models.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/zhenxie_widgets/set_expansion_buttons_widget.dart';
import '../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';

/// 课程目标页里的写作任务卡片。
class CourseUnitTargetWritingCardWidget extends StatelessWidget {
  static const double _cardHeight = 480;

  final bool isManagement;
  final int? unitId;
  final KnowledgeCommonEntityList data;
  final LockEntity? rights;
  final Future<void> Function()? onReturned;
  /// 管理端点击上下架按钮后的回调。
  final Future<void> Function()? onShelf;

  const CourseUnitTargetWritingCardWidget({
    super.key,
    required this.isManagement,
    required this.unitId,
    required this.data,
    this.rights,
    this.onReturned,
    this.onShelf,
  });

  @override
  Widget build(BuildContext context) {
    final ContentCardData? contentData = _buildContentCardData();
    if (contentData == null) return const SizedBox.shrink();
    return ZhenxieWriteCatalogCardWidget(
      contentData: contentData,
      height: _cardHeight,
      copyLabel: '范文',
      isManagement: isManagement,
      issueTimeText: _buildIssueTimeText(),
      showCopyTag: isManagement,
      cardOverlay: _buildRightsCardOverlay(),
      actions: isManagement ? _buildManageWidget() : null,
      onTap: () => _handleTap(context),
    );
  }

  Widget _buildManageWidget() {
    return Row(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: SetExpansionButtonsWidget(
              isManagement: isManagement,
              contentId: data.contentId,
              contentType: data.contentType,
              showExpand: false,
              unitId: unitId,
              isNormal: data.isNormal,
            ),
          ),
        ),
        ListingAndDelistingWidget(
          value: data.isNormal,
          onChange: onShelf,
          showBorder: false,
        ),
      ],
    );
  }

  /// 处理卡片点击后的权限校验与详情跳转。
  Future<void> _handleTap(BuildContext context) async {
    if (!isManagement) {
      final bool lock = await LockUtils.checkLock(
        data.rights,
        context,
        contentType: data.content?.type ?? '',
      );
      if (lock) return;
    }

    if (data.jump == null) {
      //   TagRoutes.toNamed(
      //     Routes.ZHENXIE_TASK_DETAILS,
      //     arguments: <String, dynamic>{
      //       'isManagement': controller.isManagement,
      //       'taskUid': task.uid,
      //       "mode": WritingBoardModeEnum.task.value,
      //     },
      //   );
      return;
    }

    data.jump?.params?['isManagement'] = isManagement;
    await JumpPageUtils.jumpUserPages(data.jump);
    await onReturned?.call();
  }

  /// 将课程目标里的 compositionStage 数据直接解析成卡片阶梯模型。
  StageCardData? _buildStageCardData() {
    final KnowledgeCommonEntityListParamsData? paramsData = data.params?.data;
    if (paramsData == null) return null;
    if ((paramsData.nid ?? '').isEmpty && (paramsData.slots ?? const <KnowledgeCommonEntityListParamsDataSlot?>[]).isEmpty) {
      return null;
    }
    return StageCardData(
      nid: paramsData.nid,
      coverUrl: paramsData.coverUrl,
      genreNid: paramsData.genreNid,
      difficulty: _buildCardDifficulty(paramsData.difficulty),
      answerKind: paramsData.answerKind,
      answerMinCount: paramsData.answerMinCount,
      answerMaxCount: paramsData.answerMaxCount,
      slots: _buildStageSlots(paramsData),
      headFill: paramsData.headFill == 'write' ? 'write' : 'hidden',
      tailFill: paramsData.tailFill == 'write' ? 'write' : 'hidden',
      hasHead: paramsData.hasHead == true && paramsData.headFill == 'write',
      hasTail: paramsData.hasTail == true && paramsData.tailFill == 'write',
      headName: paramsData.headName?.whereType<LanguageText>().toList() ?? const <LanguageText>[],
      tailName: paramsData.tailName?.whereType<LanguageText>().toList() ?? const <LanguageText>[],
      compositionBlueprint: _buildCompositionBlueprint(paramsData),
    );
  }

  /// 将课程目标里的写作知识点直接解析成任务卡片模型。
  ContentCardData? _buildContentCardData() {
    final StageCardData? stageData = _buildStageCardData();
    if (stageData == null && (data.content?.uid ?? data.contentId) == null) return null;
    return ContentCardData(
      uid: data.content?.uid ?? data.contentId,
      coverUrl: _getTaskCoverUrl(),
      name: _buildTaskName(),
      // stem: _buildTaskStem(),
      stageNid: stageData?.nid,
      stage: stageData,
      genreNid: data.params?.data?.genreNid,
      difficulty: stageData?.difficulty,
      blueprint: stageData?.compositionBlueprint,
      memberWritingStatus: data.params?.data?.memberWritingStatus == null
          ? null
          : CompositionTaskMemberWritingStatusModel.fromJson(data.params!.data!.memberWritingStatus!),
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


  /// 构建写作任务蓝图数据。
  Map<String, dynamic> _buildCompositionBlueprint(KnowledgeCommonEntityListParamsData data) {
    return <String, dynamic>{
      'nid': data.compositionBlueprintNid,
      'coverUrl': data.coverUrl,
      'name': (data.name?.whereType<LanguageText>().toList() ?? const <LanguageText>[]).map((text) => text.toJson()).toList(),
    };
  }

  /// 构建阶段槽位列表，只保留真实可展示的 beat。
  List<StageCardSlotData> _buildStageSlots(KnowledgeCommonEntityListParamsData data) {
    final slots = <StageCardSlotData>[];
    for (final slot in data.slots ?? const <KnowledgeCommonEntityListParamsDataSlot?>[]) {
      if (slot?.fill == 'hidden' || slot?.beatNid?.isEmpty != false) continue;
      slots.add(
        StageCardSlotData(
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

  /// 获取写作任务封面。
  String _getTaskCoverUrl() {
    if ((data.coverImage?.url ?? '').isNotEmpty) return data.coverImage!.url!;
    if ((data.params?.data?.coverUrl ?? '').isNotEmpty) return data.params!.data!.coverUrl!;
    return '';
  }

  String? _buildIssueTimeText() {
    if ((data.created ?? '').isEmpty) return null;
    final text = DateFormatUtil.formatStrtoStr(data.created, newPattern: 'MM/dd');
    return text.isEmpty ? null : text;
  }

  Widget? _buildRightsCardOverlay() {
    final LockEntity? currentRights = rights ?? data.rights;
    if (isManagement || currentRights?.access != 'NORMAL' || currentRights?.isNoRights != true) {
      return null;
    }
    return Container(
      color: AppTheme.cBlackAlpha50.color,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 13.wMin, vertical: 5.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceTranslucentElevated.color,
              borderRadius: BorderRadius.circular(9999.wMin),
              border: Border.all(
                color: AppTheme.cBorderTranslucentSubtle.color,
                width: 1.wMin,
              ),
            ),
            child: Text(
              'LOCKED',
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.wMin,
                color: AppTheme.cTextSecondary.color,
                height: 1.0,
              ),
            ),
          ),
          SizedBox(height: 16.wMin),
          Text(
            currentRights?.message ?? '',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
