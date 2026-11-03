import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/enum/enum.dart';
import '../../../../../../../../common/public_controller/config_controller.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../theme/theme.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../common/commons.dart';
import '../../../../../utils/utils.dart';
import '../controllers/manage_create_audio_project_controller.dart';

class ManageCreateAudioProjectScriptItemWidget extends StatelessWidget {
  final ManageCreateAudioProjectController controller;
  final ManageScriptEntity data;
  const ManageCreateAudioProjectScriptItemWidget({super.key, required this.controller, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        children: [
          TapScaleWidget(
            onTap: () {
              controller.selectScript(data);
            },
            sclae: 1,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(12.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildListitemTagsWidget(),
                      SizedBox(height: 16.wMin),
                      _buildListitemContentWidget(),
                    ],
                  ),
                ),
                Positioned(
                  top: 16.wMin,
                  right: 16.wMin,
                  child: Obx((){
                    bool selected = controller.selectScriptData.value?.uid == data.uid;
                    return SvgPicture.asset(
                      selected ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                      width: 28.wMin,
                      height: 28.wMin,
                      colorFilter: selected ? null : ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                    );
                  }),
                ),
              ],
            ),
          ),
          _buildListitemButtonsWidget(context),
        ],
      ),
    );
  }

  Widget _buildListitemTagsWidget(){
    ConfigController configController = Get.find<ConfigController>();
    DifficultieEntity? min = DifficultieUtils.getLanguageDifficultieLevel(configController.appConfig.value, "en", data.difficulty?.min);
    DifficultieEntity? max = DifficultieUtils.getLanguageDifficultieLevel(configController.appConfig.value, "en", data.difficulty?.max);

    return Row(
      children: [
        ManageTagFS16Widget(
          tag: "uid: ${data.uid??''}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "地区: ${data.lang??''}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "主题: ${data.themeNid??''}",
          bgColor: const Color(0xff8E51FF).withValues(alpha: 0.2),
          fontColor: const Color(0xff8E51FF),
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "题材: ${data.genreNid??''}",
          bgColor: const Color(0xff00A6F4).withValues(alpha: 0.2),
          fontColor: const Color(0xff00A6F4),
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "难度: ${min?.name?.text??''} - ${max?.name?.text??''}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "场景: ${data.sceneIds?.length??0}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "创建日期: ${DateFormatUtil.formatStrtoStr(data.created)}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
      ],
    );
  }

  Widget _buildListitemContentWidget(){

    List<LanguageText?> title = LearningLangUtils.sortLearningLangFirst(data.title);

    ManageScriptEntityCourseInfo? courseInfo = data.courseInfo;

    String courseStr = "";
    if(data.scriptTypeEnum == ScriptTypeEnum.unit){
      courseStr = "${courseInfo?.courseName??''} > ${courseInfo?.courseLevelName??""} > ${courseInfo?.courseModuleName??''} > ${courseInfo?.courseUnitName??''}";
    }else{
      courseStr = "${data.contentList?.length??0} 个词汇来源";
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(title.length, (index){
            return SelectableText(
              title[index]?.text??"",
              style: TextStyle(
                fontSize: index == 0 ? 24.wMin : 20.wMin,
                color: AppTheme.cTextPrimary.color.withValues(alpha: index == 0 ? 1 : 0.8),
                fontWeight: FontWeight.w600,
              ),
            );
          }),
        ),
        SizedBox(height: 4.wMin),
        SelectableText(
          courseStr,
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4.wMin),
        SelectableText(
          data.text??"",
          maxLines: 3,
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),

      ],
    );
  }

  Widget _buildListitemButtonsWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfacePrimary.color,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.wMin)),
        border: Border(top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color)),
      ),
      child: Row(
        children: [

          const Spacer(),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enContentKnowledgeList],
            child: ButtonWidget(
              text: "核心知识点 (${data.usedKnowledgePoints?.length??0})",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              onTap: () {
                controller.coreKnowledge(data);
              },
            ),
          ),
          Visibility(
            visible: data.scriptTypeEnum == ScriptTypeEnum.unit,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.unitKnowledgeList],
              margin: EdgeInsets.only(left: 12.wMin),
              child: ButtonWidget(
                text: "关联课程",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 40.wMin,
                color: AppTheme.cSurfaceSecondary.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                borderRadius: 8.wMin,
                fontSize: 18.wMin,
                fontColor: AppTheme.cTextSecondary.color,
                sclae: 1.03,
                onTap: () {
                  controller.relatedCourses(data);
                },
              ),
            ),
          ),

        ],
      ),
    );
  }


}