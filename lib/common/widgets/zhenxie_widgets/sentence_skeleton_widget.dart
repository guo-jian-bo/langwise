import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import '../widgets.dart';

class SentenceSkeletonWidget extends StatelessWidget {
  final PatternBlueprintEntity data;
  final void Function(SentenceSlotMapItemEntity item)? onTap;
  const SentenceSkeletonWidget({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final SentenceSlotMapEntity slotMap = SentenceSlotMapUtils.buildFromPatternBlueprint(data);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "句型骨架",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            "顶栏：受控/必填/可选；虚线为可选开放槽（代表句可省略）",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: AppTheme.cBorderThin.color,
                width: 0.8.wMin,
              ),
            ),
            child: SentenceSlotMapWidget(
              data: slotMap,
              onSlotTap: (item) {
                onTap?.call(item);
              },
            ),
          ),
          _buildDependEdgesWidget(context, slotMap),
        ],
      ),
    );
  }

  /// 渲染底部 dependsOn 关系区域。
  Widget _buildDependEdgesWidget(
    BuildContext context,
    SentenceSlotMapEntity data,
  ) {
    if (data.dependEdges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 16.wMin),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 16.wMin,
            children: data.dependEdges.map(_buildDependEdgeWidget).toList(),
          ),
        ),
      ),
    );
  }

  /// 渲染 dependsOn 关系标签。
  Widget _buildDependEdgeWidget(SentenceSlotMapDependEdgeEntity edge) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDependTagWidget(
          text: edge.fromLabel,
          textColor: AppTheme.cTextSecondary.color,
          bgColor: AppTheme.cSurfaceLayerBase.color,
          borderColor: AppTheme.cBorderThin.color,
        ),
        SizedBox(width: 8.wMin),
        Text(
          "→dependsOn→",
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SizedBox(width: 8.wMin),
        _buildDependTagWidget(
          text: edge.toLabel,
          textColor: const Color(0xffE0E7FF),
          bgColor: const Color(0xff6366F1).withValues(alpha: 0.12),
          borderColor: const Color(0xff6366F1).withValues(alpha: 0.24),
        ),
      ],
    );
  }

  Widget _buildDependTagWidget({
    required String text,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.75),
          width: 0.8.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.wMin,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }
}
