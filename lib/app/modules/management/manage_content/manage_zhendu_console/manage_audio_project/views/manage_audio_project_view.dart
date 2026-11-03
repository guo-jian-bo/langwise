import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/stores/stores.dart';
import '../../../../../../../common/widgets/audio_play_ui_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../enums/manage_audio_project_status_enum.dart';
import '../bindings/manage_audio_project_binding.dart';
import '../controllers/manage_audio_project_controller.dart';

class ManageAudioProjectView extends GetView<ManageAudioProjectController> {
  final String tagText;
  const ManageAudioProjectView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_AUDIO_PROJECT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageAudioProjectView(tagText: tag),
      binding: ManageAudioProjectBinding(tag: tag),
      routeName: Routes.MANAGE_AUDIO_PROJECT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.getDataList(),
      onMessagePageBack: (message) => controller.getDataList(showLoading: false),
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
        onReset: (_, conditions) {
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
          authCodes: const [ManageAuthCode.dramaAudioProjectCreate],
          margin: EdgeInsets.only(top: 10.wMin),
          child: ButtonWidget(
            text: "新建音频项目",
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            height: 44.wMin,
            color: const Color(0xff4ADE80).withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: const Color(0xff4ADE80)),
            borderRadius: 8.wMin,
            fontSize: 18.wMin,
            fontColor: const Color(0xff4ADE80),
            sclae: 1.03,
            onTap: () {
              controller.addAudioProject();
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
          ManageAudioProjectEntity data = controller.dataList[index];
          return _buildListitemWidget(context, data);
        },
      );
    });
  }


  Widget _buildListitemWidget(BuildContext context, ManageAudioProjectEntity data){
    return TapScaleWidget(
      onTap: () {
        if(!ManageAuthUtils.isAuth(ManageAuthCode.dramaAudioProjectDetail)) return;
        controller.audioProjectDetail(data);
      },
      sclae: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          color: AppTheme.cSurfaceSecondary.color,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListitemTagsWidget(context, data),
                  SizedBox(height: 8.wMin),
                  _buildListitemContentWidget(data),
                  SizedBox(height: 8.wMin),
                  _buildListItemInfoWidget(data),
                ],
              ),
            ),
            _buildListitemButtonsWidget(data),
          ],
        ),
      ),
    );
  }

  Widget _buildListitemTagsWidget(BuildContext context, ManageAudioProjectEntity data){

    String userName = data.userName?.trim() ?? "";
    String creator = userName.isNotEmpty ? userName : (data.userId?.toString() ?? "-");

    return Row(
      children: [
        ManageTagFS16Widget(
          tag: "project_uid: ${data.uid ?? "-"}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "创建人: $creator",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "${data.statusEnum?.value??''}: ${data.statusEnum?.label??'-'}",
          bgColor: _statusBgColor(data),
          fontColor: _statusFontColor(data),
        ),

        const Spacer(),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaAudioProjectDelete],
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

  Widget _buildListitemContentWidget(ManageAudioProjectEntity data){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SelectableText(
          data.title??"",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.wMin),
        SelectableText(
          "来源剧本: ${data.scriptTitle??''}",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildListItemInfoWidget(ManageAudioProjectEntity data){
    String userName = data.userName?.trim() ?? "";
    String creator = userName.isNotEmpty ? userName : (data.userId?.toString() ?? "-");
    return Row(
      spacing: 24.wMin,
      children: [
        _buildListItemInfoItemWidget("创建用户: ", creator),
        _buildListItemInfoItemWidget("对话数: ", "${data.dialogueRelations?.length ?? 0}"),
        Visibility(
          visible: data.failedStage != null,
          child: _buildListItemInfoItemWidget("失败阶段: ", data.failedStage??""),
        ),
        Visibility(
          visible: data.statusEnum == ManageAudioProjectStatusEnum.failed,
          child: _buildListItemInfoItemWidget("失败原因: ", data.failedReason??""),
        ),
        const Spacer(),

      ],
    );
  }

  Widget _buildListItemInfoItemWidget(String name, String value){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.wMin),
        color: AppTheme.cSurfaceTertiary.color,
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
      ),
      child: Row(
        children: [
          SelectableText(
            name,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 4.wMin),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListitemButtonsWidget(ManageAudioProjectEntity data){
    ManageAudioProjectEntityVisualProjects? visualProject;
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

          const Spacer(),

          Visibility(
            visible: data.audioInfo?.audioUrl != null,
            child: Container(
              width: 800.wMin,
              height: 44.wMin,
              padding: EdgeInsets.symmetric(horizontal: 8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                color: AppTheme.cSurfaceTertiary.color,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AudioPlayUiWidget(
                      audioUrl: data.audioInfo?.audioUrl,
                    ),
                  ),

                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.adminAssReviewTaskAlignAudioCreate],
                    margin: EdgeInsets.only(left: 10.wMin),
                    child: ButtonWidget(
                      text: "生成已有音频字幕",
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                      height: 38.wMin,
                      color:  AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                      border: Border.all(
                        width: 1.wMin, 
                        color: AppTheme.cSurfaceWarning.color,
                      ),
                      fontSize: 18.wMin,
                      fontColor: AppTheme.cSurfaceWarning.color,
                      borderRadius: 6.wMin,
                      sclae: 1.03,
                      onTap: () {
                        controller.assReviewCreateAss(data.audioInfo);
                      },
                    ),
                  ),

                  Visibility(
                    visible: data.audioInfo?.assId != null,
                    child: ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.adminAssReviewAssDetail],
                      margin: EdgeInsets.only(left: 10.wMin),
                      child: ButtonWidget(
                        text: "编辑字幕",
                        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                        height: 38.wMin,
                        color:  ResourceAlignEnum.align.color.withValues(alpha: 0.2),
                        border: Border.all(
                          width: 1.wMin, 
                          color: ResourceAlignEnum.align.color,
                        ),
                        fontSize: 18.wMin,
                        fontColor: ResourceAlignEnum.align.color,
                        borderRadius: 6.wMin,
                        sclae: 1.03,
                        onTap: () {
                          controller.toEditAssPage(data.audioInfo);
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: data.audioInfo?.assId != null,
                    child: ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.adminAssReviewAssDetail],
                      margin: EdgeInsets.only(left: 10.wMin),
                      child: ButtonWidget(
                        text: "编辑翻译",
                        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                        height: 38.wMin,
                        color:  ResourceAlignEnum.translate.color.withValues(alpha: 0.2),
                        border: Border.all(
                          width: 1.wMin, 
                          color: ResourceAlignEnum.translate.color,
                        ),
                        fontSize: 18.wMin,
                        fontColor: ResourceAlignEnum.translate.color,
                        borderRadius: 6.wMin,
                        sclae: 1.03,
                        onTap: () {
                          controller.toEditTranslatePage(data.audioInfo);
                        },
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),

          Visibility(
            visible: UserStore.to.rolePermissions.value.userIsAudioReviewer || UserStore.to.rolePermissions.value.userIsAudioSuperReviewer,
            child: Container(
              margin: EdgeInsets.only(left: 10.wMin),
              child: Opacity(
                opacity: data.audioTaskIds?.isNotEmpty ?? false ? 1 : 0.5,
                child: ButtonWidget(
                  text: "待审核音频 ${data.audioTaskIds?.length ?? 0} 个",
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  height: 38.wMin,
                  color:  AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                  border: Border.all(
                    width: 1.wMin, 
                    color: AppTheme.cSurfaceBrand.color,
                  ),
                  fontSize: 18.wMin,
                  fontColor: AppTheme.cSurfaceBrand.color,
                  borderRadius: 6.wMin,
                  sclae: 1.03,
                  onTap: () {
                    controller.reviewAudio(data);
                  },
                ),
              ),
            ),
          ),

          Visibility(
            visible: UserStore.to.rolePermissions.value.userIsAssReviewer || UserStore.to.rolePermissions.value.userIsAssSuperReviewer,
            child: Container(
              margin: EdgeInsets.only(left: 10.wMin),
              child: Opacity(
                opacity: data.assTaskIds?.isNotEmpty ?? false ? 1 : 0.5,
                child: ButtonWidget(
                  text: "待审核字幕 ${data.assTaskIds?.length ?? 0} 个",
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  height: 38.wMin,
                  color:  AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                  border: Border.all(
                    width: 1.wMin, 
                    color: AppTheme.cSurfaceWarning.color,
                  ),
                  fontSize: 18.wMin,
                  fontColor: AppTheme.cSurfaceWarning.color,
                  borderRadius: 6.wMin,
                  sclae: 1.03,
                  onTap: () {
                    controller.reviewAss(data);
                  },
                ),
              ),
            ),
          ),

          Visibility(
            visible: visualProject == null && data.statusEnum == ManageAudioProjectStatusEnum.checked,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaVisualProjectCreate],
              margin: EdgeInsets.only(left: 10.wMin),
              child: ButtonWidget(
                text: "创建视觉项目",
                padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                height: 44.wMin,
                color: const Color(0xffe12afb).withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: const Color(0xffe12afb)),
                borderRadius: 8.wMin,
                fontSize: 18.wMin,
                fontColor: const Color(0xffe12afb),
                sclae: 1.03,
                onTap: () {
                  controller.addVisualProject(data);
                },
              ),
            ),
          ),

          Visibility(
            visible: visualProject != null,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaVisualProjectDetail],
              margin: EdgeInsets.only(left: 10.wMin),
              child: ButtonWidget(
                text: "视觉项目(${visualProject?.status ?? ""})",
                padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                height: 44.wMin,
                color: AppTheme.cSurfaceSecondary.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                borderRadius: 8.wMin,
                fontSize: 18.wMin,
                fontColor: AppTheme.cTextSecondary.color,
                sclae: 1.03,
                onTap: () {
                  controller.visualProjectDetail(visualProject);
                },
              ),
            ),
          ),


        ],
      ),
    );
  }

  Color _statusBgColor(ManageAudioProjectEntity data){
    ManageAudioProjectStatusEnum? status = data.statusEnum;
    if(status == ManageAudioProjectStatusEnum.failed){
      return AppTheme.cFeedbackErrorBackground.color;
    }
    if(status == ManageAudioProjectStatusEnum.checked){
      return AppTheme.cFeedbackSuccessBackground.color;
    }
    return AppTheme.cFeedbackWarningBackground.color;
  }

  Color _statusFontColor(ManageAudioProjectEntity data){
    ManageAudioProjectStatusEnum? status = data.statusEnum;
    if(status == ManageAudioProjectStatusEnum.failed){
      return AppTheme.cFeedbackErrorText.color;
    }
    if(status == ManageAudioProjectStatusEnum.checked){
      return AppTheme.cFeedbackSuccessText.color;
    }
    return AppTheme.cFeedbackWarningText.color;
  }



  
}
