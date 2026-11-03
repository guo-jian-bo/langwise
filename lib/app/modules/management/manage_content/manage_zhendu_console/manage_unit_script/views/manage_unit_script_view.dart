import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/utils.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_unit_script_binding.dart';
import '../controllers/manage_unit_script_controller.dart';

class ManageUnitScriptView extends GetView<ManageUnitScriptController> {
  final String tagText;
  const ManageUnitScriptView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_UNIT_SCRIPT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageUnitScriptView(tagText: tag),
      binding: ManageUnitScriptBinding(tag: tag),
      routeName: Routes.MANAGE_UNIT_SCRIPT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.refreshListData(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTitleWidget(),
              Expanded(child: _buildListWidget(context)),
            ],
          ),
          Positioned(
            right: 8.wMin,
            bottom: 200.wMin,
            child: _buildToolButtonsWidget(),
          ),
        ],
      ),
      floatingActionButton: _buildFilterWidget(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Obx((){
      return FilterStripWidget(
        sorts: {...controller.filterSorts},
        conditions: {...controller.filterConditions},
        searchs: controller.filterSearchs,
        onSorts: (sorts) {
          controller.filterSorts.value = sorts;
          controller.pagerController.jumpToPage(1);
        },
        onConditions: (conditions) {
          controller.filterConditions.value = conditions;
          controller.pagerController.jumpToPage(1);
        },
        onReset: (sorts, conditions) {
          controller.filterSorts.value = sorts;
          controller.filterConditions.value = conditions;
          controller.pagerController.jumpToPage(1);
        },
        onSearch: () {
          controller.pagerController.jumpToPage(1);
        },
      );
    });
  }

  /// 工具按钮
  Widget _buildToolButtonsWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.zhenduGenerateTaskPages],
          child: ButtonWidget(
            text: "创建记录",
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            height: 44.wMin,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
            borderRadius: 8.wMin,
            fontSize: 18.wMin,
            fontColor: AppTheme.cSurfaceBrand.color,
            sclae: 1.03,
            onTap: () {
              controller.createRecord();
            },
          ),
        ),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaScriptGenerateUnit],
          margin: EdgeInsets.only(top: 10.wMin),
          child: ButtonWidget(
            text: "新建单元剧本",
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            height: 44.wMin,
            color: const Color(0xff4ADE80).withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: const Color(0xff4ADE80)),
            borderRadius: 8.wMin,
            fontSize: 18.wMin,
            fontColor: const Color(0xff4ADE80),
            sclae: 1.03,
            onTap: () {
              controller.createUnitScript();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 150.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx((){
            return PagerWidget(
              dataCount: controller.totalCount.value,
              controller: controller.pagerController,
              pageSize: controller.limit,
              visiblePageCount: 3,
              activeColor: AppTheme.cTextPrimary.color,
              onPage: (page, pageSize) {
                controller.pagerCallback(page, pageSize);
              },
            );
          }),
        ],
      ),
    );
  }


  Widget _buildListWidget(BuildContext context){
    return Obx((){
      return ListView.separated(
        itemCount: controller.dataList.length,
        padding: EdgeInsets.only(
          left: 150.wMin,
          right: 150.wMin,
          top: 10.wMin,
          bottom: 200.wMin,
        ),
        separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
        itemBuilder: (context, index) {
          return _buildListitemWidget(context, controller.dataList[index]);
        },
      );
    });
  }

  Widget _buildListitemWidget(BuildContext context, ManageScriptEntity data){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        children: [
          TapScaleWidget(
            onTap: () {
              if(ManageAuthUtils.isAuth(ManageAuthCode.dramaScriptDetail)){
                controller.scriptDetils(data);
              }
            },
            sclae: 1,
            child: Container(
              padding: EdgeInsets.all(12.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListitemTagsWidget(context, data),
                  SizedBox(height: 16.wMin),
                  _buildListitemContentWidget(data),
                ],
              ),
            ),
          ),
          _buildListitemButtonsWidget(context, data),
        ],
      ),
    );
  }

  Widget _buildListitemTagsWidget(BuildContext context, ManageScriptEntity data){
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
          tag: "地区: ${data.locale??''}",
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

        const Spacer(),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaScriptDelete],
          margin: EdgeInsets.only(left: 16.wMin),
          child: TapScaleWidget(
            onTap: () {
              controller.deleteData(context, data);
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
    );
  }

  Widget _buildListitemContentWidget(ManageScriptEntity data){
    List<LanguageText?> title = LearningLangUtils.sortLearningLangFirst(data.title);

    ManageScriptEntityCourseInfo? courseInfo = data.courseInfo;

    String courseStr = "${courseInfo?.courseName??''} > ${courseInfo?.courseLevelName??""} > ${courseInfo?.courseModuleName??''} > ${courseInfo?.courseUnitName??''}";

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

  Widget _buildListitemButtonsWidget(BuildContext context, ManageScriptEntity data){

    ManageScriptEntityAudioProjects? audioProject;
    ManageScriptEntityVisualProjects? visualProject;
    if((data.audioProjects??[]).isNotEmpty){
      audioProject = data.audioProjects?[0];
    }
    if((data.visualProjects??[]).isNotEmpty){
      visualProject = data.visualProjects?[0];
    }

    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfacePrimary.color,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.wMin)),
        border: Border(top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color)),
      ),
      child: Row(
        children: [

          Visibility(
            visible: data.groupName != null && data.groupName?.isNotEmpty == true,
            child: Text(
              "分组: ",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 6.wMin,
                children: List.generate(data.groupName?.length??0, (index){
                  return ManageTagFS16Widget(
                    tag: data.groupName?[index]??"未命名分组",
                    bgColor: AppTheme.cSurfaceTertiary.color,
                    fontColor: AppTheme.cTextSecondary.color,
                  );
                }),
              ),
            ),
          ),

          SizedBox(width: 16.wMin),

          Visibility(
            visible: audioProject != null,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaAudioProjectDetail],
              child: ButtonWidget(
                text: "音频项目(${audioProject?.status??""})",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 40.wMin,
                color: AppTheme.cSurfaceSecondary.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                borderRadius: 8.wMin,
                fontSize: 18.wMin,
                fontColor: AppTheme.cTextSecondary.color,
                sclae: 1.03,
                onTap: () {
                  controller.toAudioProjectDetail(audioProject);
                },
              ),
            ),
          ),

          Visibility(
            visible: visualProject != null,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaVisualProjectDetail],
              margin: EdgeInsets.only(left: 12.wMin),
              child: ButtonWidget(
                text: "视觉项目(${visualProject?.status??""})",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 40.wMin,
                color: AppTheme.cSurfaceSecondary.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                borderRadius: 8.wMin,
                fontSize: 18.wMin,
                fontColor: AppTheme.cTextSecondary.color,
                sclae: 1.03,
                onTap: () {
                  controller.toVisualProjectDetail(visualProject);
                },
              ),
            ),
          ),

          ManageAuthBoxWidget(
            authCodes: const [
              ManageAuthCode.enContentSemanticList, 
              ManageAuthCode.exerciseTypeList,
              ManageAuthCode.exercisePage,
            ],
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "题目",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              onTap: () {
                controller.toQuiz(data);
              },
            ),
          ),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enContentKnowledgeList],
            margin: EdgeInsets.only(left: 12.wMin),
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
          ManageAuthBoxWidget(
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
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaScriptEdit],
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "分配分组",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              onTap: () {
                controller.assignGroups(data);
              },
            ),
          ),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaScriptDetail],
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "打开详情",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              onTap: () {
                controller.scriptDetils(data);
              },
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "预览",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color:  AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
              border: Border.all(
                width: 1.wMin, 
                color: AppTheme.cSurfaceWarning.color,
              ),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cSurfaceWarning.color,
              sclae: 1.03,
              onTap: () {
                controller.previewPreview(context, data);
              },
            ),
          ),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaScriptEdit],
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: data.isNormal ? "已发布" : "发布",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color:  AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
              border: Border.all(
                width: 1.wMin, 
                color: AppTheme.cSurfaceSuccess.color,
              ),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cSurfaceSuccess.color,
              sclae: 1.03,
              onTap: () {
                controller.onListingAndDelisting(context, data);
              },
            ),
          ),



        ],
      ),
    );
  }


}
