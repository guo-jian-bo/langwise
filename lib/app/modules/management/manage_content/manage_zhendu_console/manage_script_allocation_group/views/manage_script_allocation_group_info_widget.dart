
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/public_controller/config_controller.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import '../controllers/manage_script_allocation_group_controller.dart';

class ManageScriptAllocationGroupInfoWidget extends StatelessWidget {
  final ManageScriptAllocationGroupController controller;
  const ManageScriptAllocationGroupInfoWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(context),
          SizedBox(height: 12.wMin),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 12.wMin),
              child: _buildInfoWidget(),
            ),
          ),

          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
            margin: EdgeInsets.symmetric(vertical: 12.wMin),
          ),

          _buildCurrentGroupWidget(),

          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
            margin: EdgeInsets.symmetric(vertical: 12.wMin),
          ),



          _buildButtonsWidget(context),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "当前剧本",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoWidget(){
    ManageScriptEntity? data = controller.assignedData;
    if(data == null) return Container();
    List<LanguageText?> title = LearningLangUtils.sortLearningLangFirst(data.title);

    ManageScriptEntityCourseInfo? courseInfo = data.courseInfo;

    String courseStr = "";
    if(data.scriptTypeEnum == ScriptTypeEnum.unit){
      courseStr = "${courseInfo?.courseName??''} > ${courseInfo?.courseLevelName??""} > ${courseInfo?.courseModuleName??''} > ${courseInfo?.courseUnitName??''}";
    }else{
      courseStr = "${data.contentList?.length??0} 个词汇来源";
    }

    ConfigController configController = Get.find<ConfigController>();
    DifficultieEntity? min = DifficultieUtils.getLanguageDifficultieLevel(configController.appConfig.value, "en", data.difficulty?.min);
    DifficultieEntity? max = DifficultieUtils.getLanguageDifficultieLevel(configController.appConfig.value, "en", data.difficulty?.max);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6.wMin,
            runSpacing: 6.wMin,
            children: [
              ManageTagFS16Widget(
                tag: "uid: ${data.uid??''}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              ManageTagFS16Widget(
                tag: "${data.scriptTypeEnum?.name??''}剧本",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              ManageTagFS16Widget(
                tag: "地区: ${data.lang??''}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              ManageTagFS16Widget(
                tag: "主题: ${data.themeNid??''}",
                bgColor: const Color(0xff8E51FF).withValues(alpha: 0.2),
                fontColor: const Color(0xff8E51FF),
              ),
              ManageTagFS16Widget(
                tag: "题材: ${data.genreNid??''}",
                bgColor: const Color(0xff00A6F4).withValues(alpha: 0.2),
                fontColor: const Color(0xff00A6F4),
              ),
              ManageTagFS16Widget(
                tag: "难度: ${min?.name?.text??''} - ${max?.name?.text??''}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              ManageTagFS16Widget(
                tag: "场景: ${data.sceneIds?.length??0}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              ManageTagFS16Widget(
                tag: "创建日期: ${DateFormatUtil.formatStrtoStr(data.created)}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
            ],
          ),

          SizedBox(height: 10.wMin),

          Column(
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
              Visibility(
                visible: (data.themeSelectionReason??"").isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(top: 6.wMin),
                  child: SelectableText(
                    data.themeSelectionReason??"",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: courseStr.isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(top: 6.wMin),
                  child: SelectableText(
                    courseStr,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.wMin),
              SelectableText(
                data.text??"",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }


  Widget _buildCurrentGroupWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "已选分组",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        Container(
          alignment: Alignment.centerLeft,
          constraints: BoxConstraints(
            minHeight: 48.wMin,
          ),
          child: Obx((){
            if(controller.selectList.isEmpty){
              return Text(
                "还没有分配分组，可以从左侧列表直接点选。",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cSurfaceWarning.color,
                  fontWeight: FontWeight.w400,
                ),
              );
            }
            return Wrap(
              spacing: 16.wMin,
              runSpacing: 10.wMin,
              alignment: WrapAlignment.start,
              children: List.generate(controller.selectList.length, (index){
                return _buildCurrentGroupItemWidget(controller.selectList[index]);
              }),
            );
          }),
        ),
      ],
    );
  }


  Widget _buildCurrentGroupItemWidget(ManageScriptGroupingEntity data){
    String nameStr = data.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"";
    return Container(
      padding: EdgeInsets.only(left: 16.wMin),
      height: 48.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nameStr.isEmpty ? "未命名分组" : nameStr,
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),

          TapScaleWidget(
            onTap: () {
              controller.selectGroup(data);
            },
            sclae: 1.1,
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 32.wMin,
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildButtonsWidget(BuildContext context){
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        ButtonWidget(
          text: "返回",
          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
          height: 38.wMin,
          color: Colors.transparent,
          borderRadius: 8.wMin,
          border: Border.all(
            width: 1.wMin, 
            color:  AppTheme.cBorderSecondary.color,
          ),
          fontColor: AppTheme.cTextSecondary.color,
          fontSize: 18.wMin,
          sclae: 1.03,
          onTap: () {
            Get.back();
          },
        ),

        SizedBox(width: 16.wMin),

        ButtonWidget(
          text: "分配分组",
          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
          height: 38.wMin,
          color: const Color(0xff00b8db).withValues(alpha: 0.2),
          borderRadius: 8.wMin,
          border: Border.all(
            width: 1.wMin, 
            color:  const Color(0xff00b8db),
          ),
          fontColor: const Color(0xff00b8db),
          fontSize: 18.wMin,
          sclae: 1.03,
          onTap: OptimizeUtils.noneThrottle(() {
            controller.confirmAllocation(context);
          }, 300),
        ),

      ],
    );
  }

}