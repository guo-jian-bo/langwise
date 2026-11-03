import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/audio_play_ui_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../../common/manage_zhendu_widgets.dart';
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
                _buildLineInputWidget(dialogue),
                SizedBox(height: 12.wMin),
                _buildAudioConfigWidget(dialogue),
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
    bool checked = dialogue.data?.audioInfo?.audioUrl != null;
    return Row(
      children: [

        ManageTagFS16Widget(
          tag: "dialogueId: ${dialogue.data?.uid??''}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 12.wMin),
        ManageTagFS16Widget(
          tag: checked ? "checked" : "unchecked",
          bgColor: checked ? AppTheme.cFeedbackSuccessBackground.color : AppTheme.cFeedbackWarningBackground.color,
          fontColor: checked ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackWarningText.color,
        ),
        SizedBox(width: 12.wMin),
        ManageTagFS16Widget(
          tag: "delay_after: ${dialogue.delayAfterInput.text}s",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        
        const Spacer(),
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
          text: "审核音频(${dialogue.data?.audioTaskIds?.length??0})",
          height: 38.wMin,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
          border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
          fontColor: AppTheme.cSurfaceSuccess.color,
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            controller.showReviewDialog(context, dialogue);
          },
        ),

      ],
    );
  }

  Widget _buildLineInputWidget(ManageAudioProjectDetilsLineModel dialogue){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ManageZhenduInputHeightWidget(
          height: 60.wMin,
          maxLines: 5,
          readOnly: true,
          controller: dialogue.textInput,
        ),
        SizedBox(height: 12.wMin),
        Row(
          spacing: 12.wMin,
          children: [

            _buildIconTagWidget(
              tag: dialogue.data?.speaker??"",
              svg: "assets/svg/public/icon_orange_horn.svg",
            ),
            _buildIconTagWidget(
              tag: dialogue.data?.emotionName??"",
              svg: "assets/svg/public/icon_stack.svg",
            ),
            _buildIconTagWidget(
              tag: "音频时长 ${dialogue.data?.audioInfo?.duration??0}s",
              svg: "assets/svg/public/icon_duration1.svg",
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildIconTagWidget({
    required String tag,
    required String svg,
  }){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        spacing: 2.wMin,
        children: [
          SvgPicture.asset(svg, width: 16.wMin),
          Text(
            tag,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAudioConfigWidget(ManageAudioProjectDetilsLineModel dialogue){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        SizedBox(
          width: 200.wMin,
          child: ManageZhenduNumberInputWidget(
            title: "delay_after",
            jumpValue: 0.1,
            minValue: 0.1,
            height: 48.wMin,
            controller: dialogue.delayAfterInput,
            onChanged: (p0) {
              controller.sceneList.refresh();
            },
          ),
        ),

        SizedBox(width: 12.wMin),

        // SizedBox(
        //   width: 200.wMin,
        //   child: ManageZhenduDropdownWidget(
        //     title: "filter",
        //     hintText: "请选择",
        //     height: 48.wMin,
        //     selectValue: dialogue.filter,
        //     items: ManageZhenduDropdownEnums.audioFilters,
        //     onChanged: (choiceData, index) {
        //       controller.selectFilter(dialogue, choiceData.value);
        //     },
        //   ),
        // ),

        // SizedBox(width: 12.wMin),

        // Expanded(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Container(
        //         margin: EdgeInsets.only(bottom: 4.wMin),
        //         padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        //         child: Row(
        //           children: [
        //             Text(
        //               "dry / wet",
        //               style: TextStyle(
        //                 fontSize: 18.wMin,
        //                 fontWeight: FontWeight.w500,
        //                 color: AppTheme.cTextSecondary.color,
        //               ),
        //             ),
        //             const Spacer(),
        //             Text(
        //               dialogue.dryWet.toString(),
        //               style: TextStyle(
        //                 fontSize: 18.wMin,
        //                 fontWeight: FontWeight.w400,
        //                 color: AppTheme.cTextSecondary.color,
        //               ),
        //             ),
        //           ],

        //         ),
        //       ),
        //       Container(
        //         height: 48.wMin,
        //         alignment: Alignment.centerLeft,
        //         child: Opacity(
        //           opacity: dialogue.filter == ManageZhenduAudioFilterEnum.none ? 0.6 : 1,
        //           child: SliderTheme(
        //             data: SliderThemeData(
        //               trackHeight: 8.wMin,
        //               thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.wMin),
        //               overlayShape: SliderComponentShape.noOverlay,
        //             ),
        //             child: Slider(
        //               value: dialogue.dryWet,
        //               divisions: 20,
        //               activeColor: const Color(0xff00D492),
        //               inactiveColor: AppTheme.cSurfaceQuinary.color,
        //               onChanged: (value) {
        //                 // filter = 不加滤镜 设置为0 不允许修改
        //                 controller.changeDryWet(dialogue, value);
        //               },
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),



      ],
    );
  }



}