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
    required ZhenxieSentenceMemberSegmentEntity segment,
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
  final ZhenxieSentenceMemberSegmentEntity segment;
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
      width: 720.wMin,
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
        bottom: 12.wMin,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            _buildContentWidget(),
            SizedBox(height: 32.wMin),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    LanguageText? name = LearningLangUtils.getLocalLang(widget.segment.slot?.name);
    Color color = _resolvePrimaryColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 10.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: color.withValues(alpha: 0.2),
                border: Border.all(
                  color: color.withValues(alpha: 0.45),
                  width: 2.wMin,
                ),
              ),
              child: SuperpositionTextWidget(
                text: name?.text??'',
                foregroundColor: color.withValues(alpha: 0.3),
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ),
            CopyTagWidget(
              name: "槽",
              value: widget.segment.slot?.nid??"",
              isShow: widget.isManagement,
            ),
            SelectableText(
              widget.segment.text??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),

          ],
        ),
        SizedBox(height: 12.wMin),
        Visibility(
          visible: widget.isManagement,
          child: Row(
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
              CopyTagWidget(
                name: "槽UID",
                value: widget.segment.slotUid?.toString()??'',
                isShow: widget.isManagement,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildContentWidget(){
    
    List<LanguageText>? descriptions = LearningLangUtils.sortLearningLangFirst(widget.segment.slot?.description??[]);
    LanguageText? categoryDescription = LearningLangUtils.getLocalLang(widget.segment.slot?.categoryName);
    String categoryText = categoryDescription?.text??'';
    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "类别 · ${categoryDescription?.text ?? categoryText}",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 16.wMin),

          ListView.separated(
            itemCount: descriptions.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return Container(
                height: 1.wMin,
                color: AppTheme.cBorderSubtle.color,
                margin: EdgeInsets.symmetric(vertical: 16.wMin),
              );
            },
            itemBuilder: (context, index) {
              return Text(
                descriptions[index].text??'',
                style: TextStyle(
                  fontSize: index == 0 ? 28.wMin : 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: index == 0 ? AppTheme.cTextPrimary : AppTheme.cTextTertiary.color,
                ),
              );
            },
          ),
          
        ],
      ),
    );
  }


 

}
