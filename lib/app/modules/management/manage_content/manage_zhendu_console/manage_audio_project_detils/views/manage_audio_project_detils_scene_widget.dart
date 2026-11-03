import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/audio_play_ui_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../../enums/manage_audio_project_status_enum.dart';
import '../controllers/manage_audio_project_detils_controller.dart';
import '../models/manage_audio_project_detils_scene_model.dart';

class ManageAudioProjectDetilsSceneWidget extends StatelessWidget {
  final ManageAudioProjectDetilsController controller;
  final ManageAudioProjectDetilsSceneModel data;
  const ManageAudioProjectDetilsSceneWidget({super.key, required this.controller, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTitleWidget(),
          SizedBox(height: 12.wMin),
          _buildSettingSummaryWidget(),
          SizedBox(height: 16.wMin),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 16.wMin),
          Column(
            spacing: 12.wMin,
            children: List.generate(data.dialogues.length, (index){
              return _buildLinesItemWidget(context, data.dialogues[index]);
            }),
          ),


        ],
      ),
    );
  }

  Widget _buildInfoTitleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          "scene ${data.data.index??''}",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SelectableText(
          data.data.title??"",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  
  /// setting summary
  Widget _buildSettingSummaryWidget(){
    return Row(
      spacing: 32.wMin,
      children: [
        Expanded(
          child: ManageZhenduInputHeightWidget(
            title: "setting",
            hintText: "setting",
            height: 120.wMin,
            maxLines: 5,
            readOnly: true,
            fillColor: Colors.transparent,
            controller: data.settingInput,
          ),
        ),
        Expanded(
          child: ManageZhenduInputHeightWidget(
            title: "summary",
            hintText: "summary",
            height: 120.wMin,
            maxLines: 5,
            readOnly: true,
            fillColor: Colors.transparent,
            controller: data.summaryInput,
          ),
        ),
      ],
    );
  }


  Widget _buildLinesItemWidget(BuildContext context, ManageAudioProjectDetilsLineModel dialogue){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildLinesImageWidget(dialogue),
        SizedBox(width: 12.wMin),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cBlackAlpha20.color,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleWidget(context, dialogue),
                SizedBox(height: 12.wMin),
                _buildLineInfoWidget(context, dialogue),
                SizedBox(height: 12.wMin),
                _buildLineInputWidget(dialogue),
                SizedBox(height: 12.wMin),
                _buildTagsWidget(dialogue),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildLinesImageWidget(ManageAudioProjectDetilsLineModel dialogue){
    return SizedBox(
      width: 100.wMin,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2.wMin),
            child: SizedBox(
              width: 100.wMin,
              height: 100.wMin,
              child: CachedImageWidget(
                dialogue.data?.imageUrl??"",
                alignment: Alignment.topCenter,
                errorWidget: buildEmptyWidget(),
                placeholder: buildEmptyWidget(),
              ),
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            dialogue.data?.speaker??"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context, ManageAudioProjectDetilsLineModel dialogue){
    Color statusColor = AppTheme.cSurfaceWarning.color;
    if(dialogue.data?.statusEnum == ManageAudioProjectStatusEnum.failed){
      statusColor = AppTheme.cSurfaceError.color;
    }else if(dialogue.data?.statusEnum == ManageAudioProjectStatusEnum.checked){
      statusColor = AppTheme.cSurfaceSuccess.color;
    }

    // 待审核音频数量
    int unCheckedCount = dialogue.data?.audioTaskIds?.length??0;

    return Row(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(right: 12.wMin),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false, // 隐藏滚动条
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ManageTagFS16Widget(
                      tag: dialogue.data?.audioStatus??"",
                      bgColor: statusColor.withValues(alpha: 0.2),
                      fontColor: statusColor,
                    ),
                    Visibility(
                      visible: dialogue.data?.error != null,
                      child: Container(
                        margin: EdgeInsets.only(left: 12.wMin),
                        child: ManageTagFS16Widget(
                          tag: dialogue.data?.error??"",
                          bgColor: statusColor.withValues(alpha: 0.2),
                          fontColor: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Visibility(
          visible: dialogue.data?.audioInfo?.audioUrl != null,
          child: Container(
            width: 550.wMin,
            height: 44.wMin,
            padding: EdgeInsets.symmetric(horizontal: 8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: AudioPlayUiWidget(
              audioUrl: dialogue.data?.audioInfo?.audioUrl,
            ),
          ),
        ),
    
        SizedBox(width: 16.wMin),
        
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaAudioProjectDialogueAudioGenerate],
          child: ButtonWidget(
            text: "新建",
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            height: 38.wMin,
            color: AppTheme.cInverseBg.color,
            borderRadius: 6.wMin,
            fontColor: Colors.black,
            fontSize: 16.wMin,
            sclae: 1.03,
            onTap: () {
              controller.addDialogueAudio(dialogue);
            },
          ),
        ),
    
        SizedBox(width: 12.wMin),
        ButtonWidget(
          text: "审核音频($unCheckedCount)",
          height: 38.wMin,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          borderRadius: 6.wMin,
          color:  AppTheme.cSurfaceSuccess.color.withValues(alpha: unCheckedCount > 0 ? 0.2 : 0.1),
          border: Border.all(
            width: 1.wMin, 
            color: unCheckedCount > 0 ? AppTheme.cSurfaceSuccess.color : AppTheme.cBorderTertiary.color,
          ),
          fontColor: unCheckedCount > 0 ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color,
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            controller.toReviewAudioPage(context, dialogue);
          },
        ),
    
      ],
    );
  }

  Widget _buildLineInfoWidget(BuildContext context, ManageAudioProjectDetilsLineModel dialogue){
    return Row(
      children: [
        SizedBox(
          width: 300.wMin,
          child: ManageZhenduSelectWidget(
            title: "演员",
            hintText: "请选择演员",
            height: 48.wMin,
            readOnly: true,
            value: dialogue.data?.speaker??"",
          ),
        ),
        SizedBox(width: 12.wMin),
        Expanded(
          child: ManageZhenduSelectWidget(
            title: "情绪",
            hintText: "请选择情绪",
            height: 48.wMin,
            value: "${dialogue.data?.emotionName??""} (nid: ${dialogue.data?.emotionNid??""})",
            onTap: () {
              controller.dialogueSelectEmotions(context, dialogue);
            },
          ),
        ),
        SizedBox(width: 12.wMin),
        SizedBox(
          width: 200.wMin,
          child: ManageZhenduNumberInputWidget(
            title: "停顿时间(秒)",
            jumpValue: 0.1,
            minValue: 0.1,
            height: 48.wMin,
            controller: dialogue.delayAfterInput,
            onStepChanged: (value) {
              controller.autoSaveDialogueDelayAfter(dialogue);
            },
            onTapOutside: (event) {
              controller.autoSaveDialogueDelayAfter(dialogue);
            },
            onSubmitted: (value) {
              controller.autoSaveDialogueDelayAfter(dialogue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLineInputWidget(ManageAudioProjectDetilsLineModel dialogue){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ManageZhenduInputHeightWidget(
          height: 100.wMin,
          maxLines: 5,
          controller: dialogue.textInput,
          onFocusLost: () {
            controller.autoSaveDialogueText(dialogue);
          },
        ),
      ],
    );
  }

  Widget _buildTagsWidget(ManageAudioProjectDetilsLineModel dialogue){
    return Row(
      children: [
        // ManageTagFS16Widget(
        //   tag: "tense-suspenseful",
        //   bgColor: AppTheme.cSurfaceTertiary.color,
        //   fontColor: AppTheme.cTextSecondary.color,
        // ),
        ManageTagFS16Widget(
          tag: "uid: ${dialogue.data?.uid??''}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 4.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: AppTheme.cSurfaceTertiary.color,
          ),
          child: Row(
            spacing: 4.wMin,
            children: [
              SvgPicture.asset(
                "assets/svg/manage/icon_duration.svg",
                width: 18.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
              SelectableText(
                '${dialogue.data?.audioInfo?.duration??0}s',
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 4.wMin),
        ManageTagFS16Widget(
          tag: "index ${dialogue.data?.index??''}",
          bgColor: const Color(0xffA855F7).withValues(alpha: 0.1),
          fontColor: const Color(0xffA855F7),
        ),

      ],
    );
  }


}