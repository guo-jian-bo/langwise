
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/commons.dart';
import 'package:langwise/app/modules/management/common/manage_tag_widget.dart';
import 'package:langwise/app/modules/management/utils/utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../controllers/manage_subtitle_mapping_controller.dart';
import '../models/manage_subtitle_mapping_ass_model.dart';

class ManageSubtitleMappingAssListWidget extends StatelessWidget {
  final ManageSubtitleMappingController controller;
  const ManageSubtitleMappingAssListWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(10.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.wMin),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            child: Row(
              children: [
                Text(
                  "原始 ASS 字幕",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.dramaVisualProjectFrameAssClearMapping],
                  child: ButtonWidget(
                    text: "清除全部映射",
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    height: 40.wMin,
                    color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                    border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
                    borderRadius: 8.wMin,
                    fontSize: 18.wMin,
                    fontColor: AppTheme.cSurfaceBrand.color,
                    sclae: 1.03,
                    onTap: () {
                      controller.clearAllMapping(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.wMin),
          Expanded(
            child: Obx((){
              return ListView.separated(
                itemCount: controller.dialogueList.length,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
                separatorBuilder: (context, index) => SizedBox(height: 10.wMin),
                itemBuilder: (context, index) {
                  return _buildAssItemWidget(controller.dialogueList[index], index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAssItemWidget(ManageSubtitleMappingAssModel data, int index){
    return Obx((){
      bool selectedByCurrentFrame = controller.assSelectedByCurrentFrame(data.data.index);
      bool selectedByOtherFrame = controller.assLockedByOtherFrame(data.data.index);
      String lockLabel = controller.getAssOwnerLabel(data.data.index);

      Duration sentenceStartTime = Duration(milliseconds: data.sentence.sentenceStartTime??0);
      Duration sentenceEndTime = Duration(milliseconds: data.sentence.sentenceEndTime??0);

      return GestureDetector(
        onTap: () {
          controller.toggleAssDialogue(data);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.all(10.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.wMin),
            color: selectedByCurrentFrame ? AppTheme.cBorderBrand.color.withValues(alpha: 0.05) : AppTheme.cSurfacePrimary.color,
            border: Border.all(
              width: 1.wMin,
              color: selectedByCurrentFrame ? AppTheme.cBorderBrand.color : AppTheme.cBorderSecondary.color,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                children: [
          
                  ManageTagFS16Widget(
                    tag: "#${(data.data.index??index) + 1}",
                    bgColor: AppTheme.cSurfaceTertiary.color,
                    fontColor: AppTheme.cTextTertiary.color,
                  ),
          
                  SizedBox(width: 16.wMin),
          
                  Text(
                    "${DateFormatUtil.formatMillisecondsToMinSec(sentenceStartTime)} - ${DateFormatUtil.formatMillisecondsToMinSec(sentenceEndTime)}",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          
                  const Spacer(),
          
                  Visibility(
                    visible: !selectedByOtherFrame,
                    child: SvgPicture.asset(
                      selectedByCurrentFrame ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
                      width: 24.wMin,
                      colorFilter: selectedByCurrentFrame ? null :ColorFilter.mode(
                        AppTheme.cTextTertiary.color,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
          
                  Visibility(
                    visible: selectedByOtherFrame,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.wMin),
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_kockkey.svg",
                        width: 24.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                      ),
                    ),
                  ),
          
                ],
              ),
          
              SizedBox(height: 12.wMin),
          
              Text(
                data.data.content??"",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
          
              SizedBox(height: 12.wMin),
          
              Text(
                lockLabel,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }


}
