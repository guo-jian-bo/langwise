import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import '../widgets.dart';

/// 槽位数例句说明
class SlotSentenceExampleDialog{
  static Future<void> show({
    required PatternBlueprintSentenceBriefSegmentEntity segment,
    required String nid,
    required int? sentenceId,
    required BuildContext context,
    bool isManagement = false,
  }) async{
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return SlotSentenceExampleDialogWidget(segment: segment, nid: nid, sentenceId: sentenceId, isManagement: isManagement);
      },
    );
  }
}

class SlotSentenceExampleDialogWidget extends StatefulWidget {
  final PatternBlueprintSentenceBriefSegmentEntity segment;
  final String nid;
  final int? sentenceId;
  final bool isManagement;

  const SlotSentenceExampleDialogWidget({super.key, required this.segment, required this.nid, this.sentenceId, this.isManagement = false});

  @override
  State<SlotSentenceExampleDialogWidget> createState() => _SlotSentenceExampleDialogWidgetState();
}

class _SlotSentenceExampleDialogWidgetState extends State<SlotSentenceExampleDialogWidget> {
  Color _resolvePrimaryColor() {
    return ColorUtils.parseColor(widget.segment.slot?.color) ?? AppTheme.cSurfaceBrand.color;
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "例句实例",
      width: 1680.wMin,
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
        bottom: 12.wMin,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        height: 650.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            SizedBox(height: 16.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            _buildContentTagsWidget(),
            Expanded(
              child: _buildContentWidget(),
            ),
            SizedBox(height: 32.wMin),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    LanguageText? name = LearningLangUtils.getLocalLang(widget.segment.slot?.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 4.wMin,
          children: [
            Text(
              name?.text??'',
              style: TextStyle(
                fontSize: 40.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            CopyTagWidget(
              name: "槽",
              value: widget.segment.slot?.nid??"",
              isShow: widget.isManagement,
            ),
          ],
        ),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 12.wMin,
          children: [
            CopyTagWidget(
              name: "句型",
              value: widget.nid,
              isShow: widget.isManagement,
            ),
            CopyTagWidget(
              name: "句子",
              value: widget.sentenceId?.toString()??"",
              isShow: widget.isManagement,
            ),
          ],
        ),
        SizedBox(height: 6.wMin),
        SelectableText(
          "类别 · ${widget.segment.slot?.categoryNid??''}",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(height: 6.wMin),
        SelectableText(
          widget.segment.text??'',
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),

      ],
    );
  }

  Widget _buildContentTagsWidget(){
    Color color = _resolvePrimaryColor();
    LanguageText? name = LearningLangUtils.getLocalLang(widget.segment.slot?.name);

    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: color.withValues(alpha: 0.55),
              border: Border.all(
                width: 0.8.wMin,
                color: color.withValues(alpha: 0.2),  
              ),
            ),
            child: Text(
              name?.text??'',
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget(){
    Color color = _resolvePrimaryColor();
    List<LanguageText>? descriptions = LearningLangUtils.sortLocalLangFirst(widget.segment.slot?.description??[]);
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      width: double.infinity,
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: color.withValues(alpha: 0.12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "实例说明",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(height: 12.wMin),
          Column(
            spacing: 10.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(descriptions.length, (index){
              return Text(
                descriptions[index].text??'',
                style: TextStyle(
                  fontSize: index == 0 ? 28.wMin : 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: index == 0 ? AppTheme.cTextPrimary : AppTheme.cTextSecondary.color,
                ),
              );
            }),
          ),
          
        ],
      ),
    );
  }


 

}
