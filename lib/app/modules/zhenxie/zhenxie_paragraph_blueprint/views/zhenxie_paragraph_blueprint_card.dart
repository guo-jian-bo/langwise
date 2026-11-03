import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/zhenxie_paragraph_blueprint_table_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';

class ZhenxieParagraphBlueprintCard extends StatefulWidget {
  final bool isManagement;
  final ParagraphBlueprintEntity data;
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final void Function(ParagraphBlueprintEntity data)? onTap;
  final void Function(ParagraphBlueprintEntity data, ParagraphBlueprintEntityBlueprints blueprint)? onTapBlueprint;
  const ZhenxieParagraphBlueprintCard({
    super.key,
    this.isManagement = false,
    required this.data,
    required this.paragraphRhetoricalList,
    this.onTap,
    this.onTapBlueprint,
  });

  @override
  State<ZhenxieParagraphBlueprintCard> createState() => _ZhenxieParagraphBlueprintCardState();
}

class _ZhenxieParagraphBlueprintCardState extends State<ZhenxieParagraphBlueprintCard> {
  @override
  Widget build(BuildContext context) {
    final ParagraphBlueprintEntityBlueprints? previewBlueprint = _getPreviewBlueprint();
    return TapScaleWidget(
      onTap: widget.onTap == null
          ? null
          : () {
              widget.onTap?.call(widget.data);
            },
      sclae: 1,
      backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.06),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(previewBlueprint),
            if (previewBlueprint != null) ...[
              SizedBox(height: 20.wMin),
              _buildPreviewWidget(previewBlueprint),
            ],
          ],
        ),
      ),
    );
  }

  /// 取第一个可展示的蓝图，和 Web 段型卡保持同样的摘要逻辑。
  ParagraphBlueprintEntityBlueprints? _getPreviewBlueprint() {
    final List<ParagraphBlueprintEntityBlueprints?> blueprints = widget.data.blueprints ?? [];
    for (final blueprint in blueprints) {
      if (blueprint != null) return blueprint;
    }
    return null;
  }

  /// 构建卡片头部信息区。
  Widget _buildTitleWidget(ParagraphBlueprintEntityBlueprints? previewBlueprint) {
    final localTask = LearningLangUtils.getLocalLang(widget.data.localTask);
    final name = LearningLangUtils.getLocalLang(widget.data.name);
    final description = LearningLangUtils.getLocalLang(widget.data.description);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      localTask?.text ?? '',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontTertiary.color,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: previewBlueprint != null,
                    child: _buildTagWidget(
                      tagText: _buildSentenceCount(previewBlueprint),
                      textColor: AppTheme.cZhenxieFontTertiary.color,
                      bgColor: AppTheme.cSurfaceLayerBase.color,
                      borderColor: AppTheme.cBorderSubtle.color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.wMin),
              Text(
                name?.text ?? '',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              SizedBox(height: 6.wMin),
              Text(
                description?.text ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontTertiary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              Visibility(
                visible: widget.isManagement,
                child: Container(
                  margin: EdgeInsets.only(top: 8.wMin),
                  child: CopyTagWidget(
                    name: "段型",
                    value: widget.data.nid ?? '',
                    isShow: widget.isManagement,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建 Web 风格的蓝图摘要预览区。
  Widget _buildPreviewWidget(ParagraphBlueprintEntityBlueprints blueprint) {
    return ZhenxieParagraphBlueprintOverviewTableWidget(
      paragraphRhetoricalList: widget.paragraphRhetoricalList,
      slotList: blueprint.slots,
    );
  }

  /// 统一生成句数文案。
  String _buildSentenceCount(ParagraphBlueprintEntityBlueprints? blueprint) {
    if(blueprint == null) return "0句";
    int minSentenceCount = blueprint.minSentenceCount ?? 0;
    int maxSentenceCount = blueprint.maxSentenceCount ?? 0;
    if (minSentenceCount == maxSentenceCount) return "$minSentenceCount句";
    return "$minSentenceCount-$maxSentenceCount句";
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
