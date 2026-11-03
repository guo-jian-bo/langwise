

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/set_expansion_buttons_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../management/common/commons.dart';
import '../controllers/zhenxie_pattern_blueprint_details_controller.dart';

class ZenxiePatternBlueprintRepresentWidget extends StatelessWidget {
  final ZhenxiePatternBlueprintDetailsController controller;
  /// 刷新单独的数据
  final void Function(PatternBlueprintExampleEntity data)? onRefresh;

  const ZenxiePatternBlueprintRepresentWidget({super.key, required this.controller, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Obx((){
      if(controller.exampleList.isEmpty){
        if(!controller.isManagement) return Container();
        return Text(
          "待教研挑选代表句",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        );
      }

      return ListView.separated(
        itemCount: controller.exampleList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
        itemBuilder: (context, index) {
          return _buildGroupItemWidget(context, index, controller.exampleList[index]);
        },
      );
    });
  }

  Widget _buildGroupItemWidget(BuildContext context, int index, PatternBlueprintExampleEntity example){
    List<ZhenxieSentenceMemberEntity?> memberList = example.members??[];
    return Container(
      padding: EdgeInsets.all(24.wMin),
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
          _buildGroupItemTitleWidget(context, index, example),
          Container(
            height: 1.wMin,
            color: AppTheme.cZhenxieBorderPrimary.color,
            margin: EdgeInsets.symmetric(vertical: 16.wMin),
          ),

          Visibility(
            visible: memberList.isEmpty,
            child: Text(
              "暂无例句",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: memberList.length,
            separatorBuilder: (context, index) {
              return SizedBox(height: 24.wMin);
            },
            itemBuilder: (context, index) {
              return _buildGroupListItemWidget(context, example, index, memberList[index]);
            },
          ),

        ],
      ),
    );
  }

  Widget _buildGroupItemTitleWidget(BuildContext context, int index, PatternBlueprintExampleEntity example){
    String title = "蓝图 ${controller.exampleList.length > 1 ? index + 1 : ''}";
    if(controller.supportsPyramid){
      title = "金字塔 ${controller.exampleList.length > 1 ? index + 1 : ''}";
    }
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
        SizedBox(width: 12.wMin),
        CopyTagWidget(
          name: "uid",
          value: example.uid?.toString()??'',
          isShow: controller.isManagement,
        ),
        SizedBox(width: 12.wMin),
        Visibility(
          visible: controller.isManagement,
          child: _buildTagWidget(
            tagText: example.isNormal ? "已上架" : "未上架",
            textColor: example.isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
            bgColor: example.isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
            borderColor: example.isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
          ),
        ),
        Spacer(),
    
        Visibility(
          visible: controller.isManagement,
          child: ManageIpDownEditDelWidget(
            isNormal: example.isNormal,
            onShelf: () {
              controller.exampleSentenceGroupShelf(example);
            },
            onDelete: () {
              controller.exampleSentenceGroupDelete(context, index, example);
            },
          ),
        ),
    
      ],
    );
  }

  Widget _buildGroupListItemWidget(BuildContext context, PatternBlueprintExampleEntity example, int index, ZhenxieSentenceMemberEntity? member){
    final ZhenxieSentenceMemberSentenceEntity? sentence = member?.sentence;
    if(member == null || sentence == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.wMin),
            Row(
              children: [
                Expanded(
                  child: SentenceSlotExampleWidget(
                    isManagement: controller.isManagement,
                    content: sentence.content,
                    segmentList: sentence.segmentList,
                    lableFontSzie: 14.wMin,
                    valueFontSize: 20.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 2.wMin, vertical: 2.wMin),
                    onSlotTap: (ZhenxieSentenceMemberSegmentEntity segment) {
                      controller.slotSentenceExample(context, segment, sentence);
                    },
                  ),
                ),
                SizedBox(width: 12.wMin),
                SetExpansionButtonsWidget(
                  isManagement: controller.isManagement,
                  sentenceId: member.sentenceId,
                  content: sentence.content,
                  isNormal: sentence.isNormal,
                  onShelf: () {
                    controller.exampleSentenceShelf(sentence);
                  },
                  onRefresh: () {
                    onRefresh?.call(example);
                  },
                ),
              ],
            ),
            SizedBox(height: 6.wMin),

            Text.rich(TextSpan(
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
              children: [
                TextSpan(text: sentence.definition ?? ""),
                if(controller.isManagement) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 4.wMin),
                      child: CopyTagWidget(
                        name: "句子",
                        value: sentence.sentenceId?.toString()??'',
                      ),
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 4.wMin),
                      child: _buildTagWidget(
                        tagText: sentence.isNormal ? "已上架" : "未上架",
                        textColor: sentence.isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                        bgColor: sentence.isNormal ? AppTheme.cSurfaceSuccess.withValues(alpha: 0.12) : AppTheme.cSurfaceWarning.withValues(alpha: 0.12),
                        borderColor: sentence.isNormal ? AppTheme.cSurfaceSuccess.withValues(alpha: 0.2) : AppTheme.cSurfaceWarning.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ],
              ],
            )),

          ],
        ),
        
      ],
    );
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
