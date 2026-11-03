
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/public_controller/config_controller.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../controllers/manage_script_details_controller.dart';

class ManageScriptContentWidget extends StatelessWidget {
  final ManageScriptDetailsController controller;
  const ManageScriptContentWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTagsWidget(),
              SizedBox(height: 6.wMin),
              _buildContentWidget(),
            ],
          ),
        ),
        SizedBox(width: 32.wMin),
        _buildButtonsWidget(context),
      ],
    );
  }

  Widget _buildTagsWidget(){
    return Obx((){
      ManageScriptDetilEntity data = controller.detilData.value;
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
            tag: "场景: ${data.scenes?.length??0}",
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
    });
  }

  Widget _buildContentWidget(){
    return Obx((){
      ManageScriptDetilEntity data = controller.detilData.value;

      List<LanguageText?> title = LearningLangUtils.sortLearningLangFirst(data.title);

      ManageScriptDetilEntityCourseInfo? courseInfo = data.courseInfo;

      String courseStr = "";
      if(controller.scriptType == ScriptTypeEnum.unit){
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
    });
  }


  Widget _buildButtonsWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.enContentKnowledgeList],
          child: Obx((){
            ManageScriptDetilEntity data = controller.detilData.value;
            return ButtonWidget(
              text: "核心知识点 (${data.usedKnowledgePoints?.length??0})",
              width: 180.wMin,
              height: 40.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              onTap: () {
                controller.coreKnowledge();
              },
            );
          }),
        ),
        Visibility(
          visible: controller.scriptType == ScriptTypeEnum.unit,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.unitKnowledgeList],
            margin: EdgeInsets.only(top: 12.wMin),
            child: ButtonWidget(
              text: "关联课程",
              width: 180.wMin,
              height: 40.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              onTap: () {
                controller.relatedCourses();
              },
            ),
          ),
        ),
        // ManageAuthBoxWidget(
        //   authCodes: const [ManageAuthCode.dramaScriptSceneEdit, ManageAuthCode.dramaScriptDialogueEdit],
        //   margin: EdgeInsets.only(top: 12.wMin),
        //   child: ButtonWidget(
        //     text: "保存全部",
        //     width: 180.wMin,
        //     height: 40.wMin,
        //     color: AppTheme.cSurfaceBrand.color,
        //     borderRadius: 8.wMin,
        //     fontSize: 18.wMin,
        //     fontWeight: FontWeight.w600,
        //     sclae: 1.03,
        //     onTap: () {
        //       controller.saveAllEdit();
        //     },
        //   ),
        // ),
      ],
    );
  }
  
}