
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../controllers/manage_script_details_controller.dart';
import '../models/manage_script_details_model.dart';

class ManageScriptSceneWidget extends StatelessWidget {
  final ManageScriptDetailsController controller;
  final ManageScriptDetailsModel scene;
  const ManageScriptSceneWidget({super.key, required this.controller, required this.scene});

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
          _buildSceneNameWidget(context),
          SizedBox(height: 12.wMin),
          _buildSettingSummaryWidget(),
          SizedBox(height: 16.wMin),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 16.wMin),
          _buildCastMembersWidget(context),
          SizedBox(height: 16.wMin),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 16.wMin),
          _buildLineListWidget(context),


        ],
      ),
    );
  }

  Widget _buildSceneNameWidget(BuildContext context){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2.wMin,
      children: [
        Text(
          "scene ${scene.data.index??''}",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Visibility(
              visible: !scene.showNameInput,
              child: Text(
                scene.nameInput.text,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Visibility(
              visible: scene.showNameInput,
              child: SizedBox(
                width: 500.wMin,
                child: ManageZhenduInputWidget(
                  hintText: "title",
                  controller: scene.nameInput,
                  onChanged: (value) {
                    controller.sceneList.refresh();
                  },
                ),
              ),
            ),
            SizedBox(width: 10.wMin),
            Visibility(
              visible: !scene.showNameInput,
              child: TapScaleWidget(
                onTap: () {
                  controller.editSceneName(scene);
                },
                sclae: 1.05,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_edit.svg",
                  width: 24.wMin,
                ),
              ),
            ),
            Visibility(
              visible: scene.showNameInput,
              child: ButtonWidget(
                text: "确定",
                width: 100.wMin,
                height: 54.wMin,
                color:  AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                border: Border.all(
                  width: 1.wMin, 
                  color: AppTheme.cSurfaceBrand.color,
                ),
                fontSize: 20.wMin,
                fontColor: AppTheme.cSurfaceBrand.color,
                borderRadius: 6.wMin,
                sclae: 1.03,
                onTap: () {
                  controller.editSceneName(scene);
                },
              ),
            ),
          ],
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
            controller: scene.settingInput,
            onFocusLost: () {
              controller.autoSaveSceneSetting(scene);
            },  
          ),
        ),
        Expanded(
          child: ManageZhenduInputHeightWidget(
            title: "summary",
            hintText: "summary",
            height: 120.wMin,
            maxLines: 5,
            controller: scene.summaryInput,
            onFocusLost: () {
              controller.autoSaveSceneSummary(scene);
            },  
          ),
        ),
      ],
    );
  }

  /// 参演人员
  Widget _buildCastMembersWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "参演人员",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.wMin),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false, // 隐藏滚动条
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 24.wMin,
              children: [
                ...List.generate(scene.personas.length, (index){
                  return _buildCastMembersItemWidget(context, scene.personas[index]);
                }),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.dramaScriptSceneEdit],
                  child: _buildCastMembersAddWidget(context),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildCastMembersItemWidget(BuildContext context, ManageScriptDetilEntityScenesPersonas persona){
    return SizedBox(
      width: 220.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TapScaleWidget(
            onTap: () {
              controller.showPersonaImage(context, scene, persona);
            },
            sclae: 1,
            child: Container(
              width: 220.wMin,
              height: 220.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedImageWidget(
                    persona.imageUrl??"",
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(6.wMin),
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildEmptyWidget(),
                  ),
                  Positioned(
                    right: 4.wMin,
                    bottom: 4.wMin,
                    child: Container(
                      width: 34.wMin,
                      height: 34.wMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.wMin),
                        color: Colors.black45,
                      ),
                      child: Icon(
                        Icons.zoom_out_map,
                        color: Colors.white,
                        size: 18.wMin,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            persona.speaker??"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            persona.variantNid??"",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          Row(
            children: [
              TapScaleWidget(
                onTap: () {
                  controller.removePersona(context, scene, persona);
                },
                sclae: 1.1,
                child: Container(
                  padding: EdgeInsets.all(4.wMin),
                  child: Text(
                    "移除",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: AppTheme.cSurfaceError.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              TapScaleWidget(
                onTap: () {
                  controller.replacePersona(context, scene, persona);
                },
                sclae: 1.1,
                child: Container(
                  padding: EdgeInsets.all(4.wMin),
                  child: Text(
                    "替换",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: AppTheme.cSurfaceBrand.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCastMembersAddWidget(BuildContext context){
    return TapScaleWidget(
      onTap: () {
        controller.addParticipants(context, scene);
      },
      sclae: 1.01,
      child: DottedBorder(
        radius: Radius.circular(4.wMin),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: AppTheme.cBorderSecondary.color,
        dashPattern: const [3, 3],
        child: Container(
          width: 220.wMin,
          height: 300.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: AppTheme.cSurfaceSecondary.color,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10.wMin,
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_add.svg",
                width: 40.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
              Text(
                "新增参演人员",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// 台词列表
  Widget _buildLineListWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            Text(
              "台词列表",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaScriptDialogueCreate],
              child: ButtonWidget(
                text: "新增台词",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                borderRadius: 8.wMin,
                fontSize: 18.wMin,
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
                fontColor: AppTheme.cSurfaceBrand.color,
                sclae: 1.03,
                onTap: () {
                  controller.addLines(context, scene);
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 12.wMin),

        Column(
          spacing: 12.wMin,
          children: List.generate(scene.dialogues.length, (index){
            return ManageScriptSceneLineItemWidget(
              controller: controller,
              scene: scene,
              dialogue: scene.dialogues[index],
            );
          }),
        ),

      ],
    );
  }


}



class ManageScriptSceneLineItemWidget extends StatelessWidget {
  final ManageScriptDetailsController controller;
  final ManageScriptDetailsModel scene;
  final ManageScriptDetailsLinesModel dialogue;
  const ManageScriptSceneLineItemWidget({
    super.key, 
    required this.controller, 
    required this.dialogue, 
    required this.scene,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageWidget(),
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
                _buildTitleWidget(context),
                SizedBox(height: 12.wMin),
                _buildLinesWidget(),
                SizedBox(height: 12.wMin),
                _buildTagsWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(){
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
                dialogue.persona.imageUrl??"",
                alignment: Alignment.topCenter,
                fit: BoxFit.cover,
                errorWidget: buildEmptyWidget(),
                placeholder: buildEmptyWidget(),
              ),
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            dialogue.persona.speaker??"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.wMin),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaScripSceneDialogueSort],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ButtonWidget(
                  text: "上移",
                  fontSize: 14.wMin,
                  width: 80.wMin,
                  color: AppTheme.cSurfaceTertiary.color,
                  height: 34.wMin,
                  fontColor: AppTheme.cTextPrimary.color,
                  borderRadius: 4.wMin,
                  sclae: 1.03,
                  leftIcon: SvgPicture.asset(
                    "assets/svg/manage/icon_chevron_up.svg",
                    width: 20.wMin,
                  ),
                  onTap: () {
                    controller.dialogueMovesUp(scene, dialogue);
                  },
                ),
                SizedBox(height: 4.wMin),
                ButtonWidget(
                  text: "下移",
                  fontSize: 14.wMin,
                  width: 80.wMin,
                  color: AppTheme.cSurfaceTertiary.color,
                  height: 34.wMin,
                  fontColor: AppTheme.cTextPrimary.color,
                  borderRadius: 4.wMin,
                  sclae: 1.03,
                  leftIcon: SvgPicture.asset(
                    "assets/svg/manage/icon_chevron_down.svg",
                    width: 20.wMin,
                  ),
                  onTap: () {
                    controller.dialogueMovesDown(scene, dialogue);
                  },
                ),
              ],
            ),
          ),
          
      
        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        SizedBox(
          width: 300.wMin,
          child: ManageZhenduDropdownWidget(
            title: "演员",
            hintText: "请选择演员",
            height: 48.wMin,
            selectValue: dialogue.persona.variantNid,
            items: List.generate(scene.personas.length, (index){
              return IconDropdownCheckData<String>(
                title: scene.personas[index].speaker??"",
                value: scene.personas[index].variantNid??"",
              );
            }),
            onChanged: (choiceData, index) {
              controller.dialogueChangePersona(scene, dialogue, choiceData.value);
            },
          ),
        ),
        SizedBox(width: 12.wMin),
        Expanded(
          child: ManageZhenduSelectWidget(
            title: "情绪",
            hintText: "请选择情绪",
            height: 48.wMin,
            value: "${dialogue.emotion.emotionName} (nid: ${dialogue.emotion.emotionNid})",
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
            
          ),
        ),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaScriptDialogueEdit],
          margin: EdgeInsets.only(left: 12.wMin),
          child: ButtonWidget(
            text: dialogue.enabled ? "已启用" : "已停用",
            padding: EdgeInsets.only(left: 8.wMin, right: 12.wMin),
            height: 48.wMin,
            color: dialogue.enabled ? AppTheme.cFeedbackSuccessBackground.color : AppTheme.cFeedbackErrorBackground.color,
            borderRadius: 8.wMin,
            fontColor: dialogue.enabled ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackErrorText.color,
            fontSize: 18.wMin,
            leftIcon: Container(
              margin: EdgeInsets.only(right: 4.wMin),
              child: SvgPicture.asset(
                dialogue.enabled ? "assets/svg/public/icon_enable.svg" : "assets/svg/public/icon_prohibit.svg",
                height: 24.wMin,
                colorFilter: ColorFilter.mode(
                  dialogue.enabled ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackErrorText.color, 
                  BlendMode.srcIn,
                ),
              ),
            ),
            sclae: 1.03,
            onTap: () {
              controller.dialogueChangeEnabled(dialogue);
            },
          ),
        ),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaScriptDialogueDelete],
          margin: EdgeInsets.only(left: 12.wMin),
          child: ButtonWidget(
            text: "删除",
            height: 48.wMin,
            width: 110.wMin,
            borderRadius: 6.wMin,
            color: AppTheme.cFeedbackErrorBackground.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder.color),
            fontColor: AppTheme.cFeedbackErrorText.color,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              controller.dialogueDelete(context, scene, dialogue);
            },
          ),
        ),

      ],
    );
  }

  Widget _buildLinesWidget(){
    return ManageZhenduInputHeightWidget(
      height: 94.wMin,
      maxLines: 5,
      controller: dialogue.textInput,
      onFocusLost: () {
        controller.autoSaveDialogueText(dialogue);
      },
    );
  }

  Widget _buildTagsWidget(){
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
