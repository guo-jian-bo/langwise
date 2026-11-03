import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

class ZhenxieParagraphWritingGoalStopWidget extends StatefulWidget {
  final String? selectNid;
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final List<ParagraphWritingGoalEntityBeatSpan?>? beatSpanList;
  final void Function(ParagraphWritingGoalEntityBeatSpan? beatSpan)? onTap;
  const ZhenxieParagraphWritingGoalStopWidget({
    super.key,
    this.selectNid,
    required this.paragraphRhetoricalList,
    required this.beatSpanList,
    this.onTap,
  });

  @override
  State<ZhenxieParagraphWritingGoalStopWidget> createState() => _ZhenxieParagraphWritingGoalStopWidgetState();
}

class _ZhenxieParagraphWritingGoalStopWidgetState extends State<ZhenxieParagraphWritingGoalStopWidget> {
  @override
  Widget build(BuildContext context) {

    return Column(
      spacing: 16.wMin,
      children: List.generate(widget.beatSpanList?.length??0, (index) {
        return _buildItemWidget(widget.beatSpanList?[index]);
      }),
    );
  }

  Widget _buildItemWidget(ParagraphWritingGoalEntityBeatSpan? beatSpan) {
    final jobDescription = LearningLangUtils.getLocalLang(beatSpan?.jobDescription);

    bool selected = widget.selectNid == beatSpan?.beatNid;

    return TapScaleWidget(
      onTap: widget.onTap == null ? null : () {
        widget.onTap?.call(beatSpan);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: selected ? AppTheme.cWritePrimary.color : AppTheme.cBorderSubtle.color,
            width: 0.8.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemTitleWidget(beatSpan),
            SizedBox(height: 10.wMin),
            _buildItemRowWidget("教学", jobDescription?.text??''),
            // SizedBox(height: 10.wMin),
            // _buildItemRowWidget(hideText: true),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTitleWidget(ParagraphWritingGoalEntityBeatSpan? beatSpan) {
    final rhetorical = widget.paragraphRhetoricalList.firstWhereOrNull((element) => element.nid == beatSpan?.beatNid);
    Color colorValue = rhetorical?.currentThemeColor?.colorValue ?? AppTheme.cTextPrimary.color;
    final rhetoricalName = LearningLangUtils.getLocalLang(rhetorical?.name);
    final jobName = LearningLangUtils.getLocalLang(beatSpan?.jobName);

    return Row(
      children: [
        SizedBox(
          width: 44.wMin,
          child: Text(
            rhetoricalName?.text??'',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: colorValue,
            ),
          ),
        ),
        SizedBox(width: 4.wMin),
        Expanded(
          child: Text(
            jobName?.text??'',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRowWidget(String name, String text, {bool hideText = false}) {
    return Row(
      children: [
        SizedBox(
          width: 44.wMin,
          child: Text(
            name,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ),
        Expanded(
          child: IgnorePointer(
            ignoring: !hideText,
            child: TapScaleWidget(
              onTap: () {},
              sclae: 1,
              child: Container(
                padding: EdgeInsets.all(4.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.wMin),
                  color: hideText ? AppTheme.cSurfaceLayerElevated.color : Colors.transparent,
                ),
                child: Opacity(
                  opacity: hideText ? 0 : 1,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
