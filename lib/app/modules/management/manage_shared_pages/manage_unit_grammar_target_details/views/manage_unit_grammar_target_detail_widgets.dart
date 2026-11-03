import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageUnitGrammarPatternSkeletonWidget extends StatelessWidget {
  final PatternBlueprintEntity? data;
  final List<String> skeletonChips;

  const ManageUnitGrammarPatternSkeletonWidget({
    super.key,
    this.data,
    required this.skeletonChips,
  });

  static const List<Color> _slotColors = [
    Color(0xff0EA5E9),
    Color(0xffF59E0B),
    Color(0xffF43F5E),
    Color(0xff8B5CF6),
    Color(0xff00BC7D),
    Color(0xff14B8A6),
    Color(0xffF97316),
    Color(0xff84CC16),
    Color(0xffD946EF),
    Color(0xff6366F1),
  ];

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return SentenceSkeletonWidget(
        data: data!,
      );
    }

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
            '句型骨架',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
            SizedBox(height: 10.wMin),
            Text(
              '查看当前 Target 的槽位结构与模板。',
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
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    spacing: 2.wMin,
                    children: List.generate(skeletonChips.length, (index) {
                      final Color color = index < _slotColors.length
                          ? _slotColors[index]
                          : _slotColors[index % _slotColors.length];
                      return _buildSlotItem(
                        slotName: skeletonChips[index],
                        tagText: '骨架',
                        primaryColor: skeletonChips[index] == '.'
                            ? AppTheme.cTextPrimary.color
                            : color,
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        
        
        ],
      ),
    );
  }

  Widget _buildSlotItem({
    required String slotName,
    required String tagText,
    required Color primaryColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.wMin),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: primaryColor.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            slotName,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
