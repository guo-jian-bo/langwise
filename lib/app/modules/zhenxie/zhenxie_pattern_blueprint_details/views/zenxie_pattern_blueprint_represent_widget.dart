

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../../../management/common/commons.dart';
import '../../../management/utils/utils.dart';
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
        controller: controller.scrollController,
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
     List<PatternBlueprintSentenceBriefEntity?> memberList = example.memberList??[];
    return Container(
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
          _buildGroupItemTitleWidget(context, index, example),
          SizedBox(height: 16.wMin),
          Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
          SizedBox(height: 24.wMin),
          Column(
            spacing: 24.wMin,
            children: List.generate(memberList.length, (index){
              return _buildGroupListItemWidget(context, example, index, memberList[index]);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItemTitleWidget(BuildContext context, int index, PatternBlueprintExampleEntity example){
    String title = "代表句${controller.exampleList.length > 1 ? index + 1 : ''}";
    if(controller.supportsPyramid){
      title = "金字塔${controller.exampleList.length > 1 ? index + 1 : ''}";
    }
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
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
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceTertiary.color,
              borderRadius: BorderRadius.circular(6.wMin),
            ),
            child: Row(
              children: [
                ListingAndDelistingWidget(
                  value: example.isNormal,
                  onChange: () {
                    controller.exampleSentenceGroupShelf(example);
                  },
                ),
                // Container(
                //   margin: EdgeInsets.only(left: 8.wMin),
                //   child: TapScaleWidget(
                //     onTap: () {
                      
                //     },
                //     sclae: 1.1,
                //     borderRadius: 8.wMin,
                //     backColor: AppTheme.cSurfaceTertiary.color,
                //     child: Container(
                //       width: 50.wMin,
                //       height: 40.wMin,
                //       alignment: Alignment.center,
                //       child: SvgPicture.asset(
                //         "assets/svg/manage/icon_edit.svg",
                //         width: 24.wMin,
                //         colorFilter: ColorFilter.mode(
                //           AppTheme.cTextTertiary.color,
                //           BlendMode.srcIn,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.only(left: 8.wMin),
                  child: TapScaleWidget(
                    onTap: () async {
                      await controller.exampleSentenceGroupDelete(context, index, example);
                    },
                    sclae: 1.1,
                    borderRadius: 8.wMin,
                    backColor: AppTheme.cSurfaceTertiary.color,
                    child: Container(
                      width: 50.wMin,
                      height: 40.wMin,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_delete.svg",
                        width: 24.wMin,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupListItemWidget(BuildContext context, PatternBlueprintExampleEntity example, int index, PatternBlueprintSentenceBriefEntity? sentence){
    if(sentence == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTagWidget(
              tagText: controller.supportsPyramid ? "第${index + 1}层" : "代表句${index + 1}",
            ),
            SizedBox(width: 4.wMin),
            CopyTagWidget(
              name: "句子",
              value: sentence.sentenceId?.toString()??'',
              isShow: controller.isManagement,
            ),
            SizedBox(width: 12.wMin),
            Visibility(
              visible: controller.isManagement,
              child: _buildTagWidget(
                tagText: sentence.isNormal ? "已上架" : "未上架",
                textColor: sentence.isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                bgColor: sentence.isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                borderColor: sentence.isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
              ),
            ),
            Spacer(),
            ListingAndDelistingWidget(
              value: sentence.isNormal,
              showBorder: false,
              onChange: () {
                controller.exampleSentenceShelf(sentence);
              },
            ),
          ],
        ),
        SizedBox(height: 12.wMin),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.wMin),
            border: Border.all(
              color: AppTheme.cSurfaceLayerBase2.color,
              width: 1.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.wMin),
              SentenceSlotExampleWidget(
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                isManagement: controller.isManagement,
                segmentList: sentence.segmentList,
                onSlotTap: (PatternBlueprintSentenceBriefSegmentEntity segment) {
                  controller.slotSentenceExample(context, segment, sentence);
                },
              ),
              SizedBox(height: 12.wMin),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                child: Text(
                  sentence.definition ?? '',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ),
              SizedBox(height: 12.wMin),
              Visibility(
                visible: controller.isManagement,
                child: Container(
                  padding: EdgeInsets.all(12.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceLayerBase.color,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(6.wMin)),
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.cBorderThin.color,
                        width: 1.wMin,
                      ),
                    ),
                  ),
                  child: Row(
                    spacing: 12.wMin,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildButtonWidget(
                        text: "视觉",
                        onTap: () async{
                          await ManagePageRegistry.jumpTo(
                            Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
                            arguments: {
                              'type': KnowledgeTypeEnum.EN_SENTENCE.value,
                              'uid': sentence.sentenceId,
                              "quizOrImage": 1,
                            },
                          );
                          onRefresh?.call(example);
                        },
                      ),
                      // _buildButtonWidget(
                      //   text: "声音",
                      // ),
                      _buildButtonWidget(
                        text: "题目",
                        onTap: () async{
                          await ManagePageRegistry.jumpTo(
                            Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
                            arguments: {
                              'type': KnowledgeTypeEnum.EN_SENTENCE.value,
                              'uid': sentence.sentenceId,
                              "quizOrImage": 0,
                            },
                          );
                          onRefresh?.call(example);
                        },
                      ),
                      _buildButtonWidget(
                        text: "拓展",
                        onTap: () {
                          controller.expandLearning(sentence);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
      ],
    );
  }


  Widget _buildButtonWidget({
    required String text,
    void Function()? onTap,
  }){
    return ButtonWidget(
      text: text,
      sclae: 1.03,
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      borderRadius: 6.wMin,
      color: AppTheme.cSurfaceLayerElevated.color,
      border: Border.all(
        color: AppTheme.cBorderThin.color,
        width: 1.wMin,
      ),
      fontSize: 16.wMin,
      fontColor: AppTheme.cTextSecondary.color,
      fontWeight: FontWeight.w500,
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