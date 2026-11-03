import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import '../../values/values.dart';
import '../widgets.dart';

class SentenceSkeletonWidget extends StatelessWidget {
  final PatternBlueprintEntity data;
  final String? desc;
  final void Function(SentenceSlotMapItemEntity item)? onTap;
  const SentenceSkeletonWidget({super.key, required this.data, this.desc, this.onTap});

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
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            desc ?? "顶栏：受控/必填/可选；虚线为可选开放槽（代表句可省略）",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
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
              showDepend: true,
              onSlotTap: (item) {
                onTap?.call(item);
              },
            ),
          ),
        ],
      ),
    );
  }
}
