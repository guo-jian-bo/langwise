import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/stores/stores.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../common/image_tool_widgets.dart';
import '../../../../utils/utils.dart';
import '../../enums/manage_visual_image_status_enum.dart';
import '../bindings/manage_visual_project_detils_binding.dart';
import '../controllers/manage_visual_project_detils_controller.dart';

class ManageVisualProjectDetilsView extends GetView<ManageVisualProjectDetilsController> {
  final String tagText;
  const ManageVisualProjectDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_VISUAL_PROJECT_DETILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageVisualProjectDetilsView(tagText: tag),
      binding: ManageVisualProjectDetilsBinding(tag: tag),
      routeName: Routes.MANAGE_VISUAL_PROJECT_DETILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.getDetilsData(),
      onMessagePageBack: (message) => controller.getDetilsData(showLoading: false),
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.only(
                left: 150.wMin,
                right: 150.wMin,
                top: 10.wMin,
                bottom: 200.wMin,
              ),
              children: [
                _buildNameWidget(),
                SizedBox(height: 16.wMin),
                _buildStatisticsWidget(context),
                SizedBox(height: 16.wMin),
                Obx((){
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.detilData.value.sceneRelations?.length??0,
                    separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
                    itemBuilder: (context, index) {
                      return _buildSceneItemWidget(context, controller.detilData.value.sceneRelations?[index], index);
                    },
                  );
                }),
              ],
            ),
          ),
          Positioned(
            right: 16.wMin,
            bottom: 40.wMin,
            child: _buildToolButtonsWidget(),
          ),
        ],
      ),
    );
  }

  /// 工具按钮
  Widget _buildToolButtonsWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVisualProjectFrameMappingDetail],
          child: ButtonWidget(
            text: "字幕映射",
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            height: 44.wMin,
            color: const Color(0xff8e51ff).withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: const Color(0xff8e51ff)),
            borderRadius: 8.wMin,
            fontSize: 18.wMin,
            fontColor: const Color(0xff8e51ff),
            sclae: 1.03,
            onTap: () {
              controller.subtitleMapping();
            },
          ),
        ),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVisualProjectVideoSegments],
          margin: EdgeInsets.only(top: 16.wMin),
          child: ButtonWidget(
            text: "生成视频",
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            height: 44.wMin,
            color: const Color(0xff00a6f4).withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: const Color(0xff00a6f4)),
            borderRadius: 8.wMin,
            fontSize: 18.wMin,
            fontColor: const Color(0xff00a6f4),
            sclae: 1.03,
            onTap: () {
              controller.generateVideo();
            },
          ),
        ),
      ],
    );
  }

  /// 名称
  Widget _buildNameWidget(){
    return Obx((){
      ManageVisualProjectEntity data = controller.detilData.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ManageTagFS16Widget(
                tag: "project_uid: ${data.uid??''}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              SizedBox(width: 6.wMin),
              ManageTagFS16Widget(
                tag: "locale: ${data.locale??''}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              SizedBox(width: 6.wMin),
              ManageTagFS16Widget(
                tag: "创建人: ${data.userName??''} (userId: ${data.userId??''})",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              SizedBox(width: 6.wMin),
              ManageTagFS16Widget(
                tag: "风格: ${data.styleTitle??''}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
            ],
          ),
          SizedBox(height: 6.wMin),
          SelectableText(
            data.title??"",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SelectableText(
            // 'script_uid: 600010 · audio_project_uid: 880001',
            '来源剧本: ${data.scriptTitle??''} · 音频底座 audio_project_uid: ${data.audioProjectId??''}',
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    });
  }


  Widget _buildStatisticsWidget(BuildContext context){
    return Obx((){
      ManageVisualProjectEntity data = controller.detilData.value;
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              spacing: 16.wMin,
              children: [
                _buildStatisticsItemWidget("场景总数", data.sceneRelations?.length.toString()??"0"),
                _buildStatisticsItemWidget("已出图", "${data.sceneImageGeneratedCount??0}/${data.sceneRelations?.length??0}"),
                _buildStatisticsItemWidget("已审核", "${data.sceneTaskCheckedCount??0}/${data.sceneRelations?.length??0}"),
                _buildStatisticsItemWidget("视频片段", "${data.videoSegmentCount??0}段"),
              ],
            ),
          ),
          SizedBox(height: 10.wMin),
          _buildStatisticsVideoWidget(context),
        ],
      );
    });
  }

  Widget _buildStatisticsVideoWidget(BuildContext context){
    return Obx((){
      String videoUrl = controller.detilData.value.videoInfo?.videoUrl??"";
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: videoUrl.isNotEmpty ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : AppTheme.cSurfaceSecondary.color,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(width: 1.wMin, color: videoUrl.isNotEmpty ? AppTheme.cSurfaceBrand.color : AppTheme.cTextSecondary.color),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10.wMin,
          children: [
            Row(
              children: [
                SelectableText(
                  "成品视频",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 16.wMin),
                ManageTagFS16Widget(
                  tag: "videoId: ${controller.detilData.value.videoInfo?.videoId??'-'}",
                  bgColor: AppTheme.cSurfaceTertiary.color,
                  fontColor: AppTheme.cTextSecondary.color,
                ),
                const Spacer(),
                Visibility(
                  visible: UserStore.to.rolePermissions.value.userIsAssReviewer || UserStore.to.rolePermissions.value.userIsAssSuperReviewer,
                  child: ButtonWidget(
                    text: "待审核字幕(${controller.detilData.value.videoInfo?.assTaskIds?.length??0})",
                    height: 42.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0),
                    border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
                    fontColor: AppTheme.cSurfaceBrand.color,
                    fontSize: 20.wMin,
                    borderRadius: 10.wMin,
                    sclae: 1.03,
                    onTap: (){
                      controller.toReviewAssPage();
                    },
                  ),
                ),

                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.dramaVisualProjectFrameAss],
                  margin: EdgeInsets.only(left: 24.wMin),
                  child: ButtonWidget(
                    text: "新建字幕",
                    height: 42.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: ResourceAlignEnum.align.color.withValues(alpha: 0.2),
                    border: Border.all(width: 1.wMin, color: ResourceAlignEnum.align.color),
                    fontColor: ResourceAlignEnum.align.color,
                    fontSize: 20.wMin,
                    borderRadius: 10.wMin,
                    sclae: 1.03,
                    onTap: () async{
                      await controller.generateKeyframeSubtitles(context);
                    },
                  ),
                ),

                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.adminAssReviewAssDetail],
                  margin: EdgeInsets.only(left: 6.wMin),
                  child: ButtonWidget(
                    text: "编辑字幕",
                    height: 42.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: ResourceAlignEnum.align.color.withValues(alpha: 0.2),
                    border: Border.all(width: 1.wMin, color: ResourceAlignEnum.align.color),
                    fontColor: ResourceAlignEnum.align.color,
                    fontSize: 20.wMin,
                    borderRadius: 10.wMin,
                    sclae: 1.03,
                    onTap: () async{
                      await controller.toEditAssPage();
                    },
                  ),
                ),

                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.dramaVisualProjectFramaAssTranslate],
                  margin: EdgeInsets.only(left: 24.wMin),
                  child: ButtonWidget(
                    text: "新建翻译",
                    height: 42.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: ResourceAlignEnum.translate.color.withValues(alpha: 0.2),
                    border: Border.all(width: 1.wMin, color: ResourceAlignEnum.translate.color),
                    fontColor: ResourceAlignEnum.translate.color,
                    fontSize: 20.wMin,
                    borderRadius: 10.wMin,
                    sclae: 1.03,
                    onTap: (){
                      controller.generateKeyframeTranslate();
                    },
                  ),
                ),

                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.adminAssReviewAssDetail],
                  margin: EdgeInsets.only(left: 6.wMin),
                  child: ButtonWidget(
                    text: "编辑翻译",
                    height: 42.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: ResourceAlignEnum.translate.color.withValues(alpha: 0.2),
                    border: Border.all(width: 1.wMin, color: ResourceAlignEnum.translate.color),
                    fontColor: ResourceAlignEnum.translate.color,
                    fontSize: 20.wMin,
                    borderRadius: 10.wMin,
                    sclae: 1.03,
                    onTap: () async{
                      await controller.toEditTranslatePage();
                    },
                  ),
                ),


                Visibility(
                  visible: videoUrl.isNotEmpty,
                  child: Container(
                    margin: EdgeInsets.only(left: 24.wMin),
                    child: ButtonWidget(
                      text: "播放视频",
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      height: 42.wMin,
                      color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                      border: Border.all(width: 1.wMin, color: AppTheme.cTextBrand.color),
                      fontColor: AppTheme.cTextBrand.color,
                      borderRadius: 8.wMin,
                      fontSize: 20.wMin,
                      sclae: 1.03,
                      onTap: () {
                        controller.playCompletedVideo(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatisticsItemWidget(String title, String value){
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceSecondary.color,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10.wMin,
          children: [
            SelectableText(
              title,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SelectableText(
              value,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSceneItemWidget(BuildContext context, ManageVisualProjectEntitySceneRelations? data, int index){
    if(data == null) return Container();
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSceneItemTagsWidget(context, data, index),
          SizedBox(height: 8.wMin),
          _buildSceneItemContentWidget(data),
          SizedBox(height: 8.wMin),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 8.wMin),
          _buildImageListWidget(context, data),
        ],
      ),
    );
  }

  Widget _buildSceneItemTagsWidget(BuildContext context, ManageVisualProjectEntitySceneRelations data, int index){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ManageTagFS16Widget(
              tag: "scene_uid: ${data.sceneId??''}",
              bgColor: AppTheme.cSurfaceQuaternary.color,
              fontColor: AppTheme.cTextSecondary.color,
            ),
            SizedBox(width: 6.wMin),
            ManageTagFS16Widget(
              tag: "promptId: ${data.promptId??''}",
              bgColor: AppTheme.cSurfaceQuaternary.color,
              fontColor: AppTheme.cTextSecondary.color,
            ),
            SizedBox(width: 6.wMin),
            ManageTagFS16Widget(
              tag: data.statusEnum?.name,
              bgColor: data.statusEnum?.bg,
              fontColor: data.statusEnum?.font??AppTheme.cTextSecondary.color,
            ),
            const Spacer(), 
        
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetPromptView],
              margin: EdgeInsets.only(left: 16.wMin),
              child: ButtonWidget(
                text: "分镜工作台",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 40.wMin,
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
                borderRadius: 8.wMin,
                fontSize: 18.wMin,
                fontColor: AppTheme.cSurfaceBrand.color,
                sclae: 1.03,
                rightIcon: Container(
                  margin: EdgeInsets.only(left: 8.wMin),
                  child: IgnorePointer(
                    ignoring: true,
                    child: ManageTagFS16Widget(
                      tag: data.statusEnum?.name,
                      bgColor: data.statusEnum?.bg,
                      fontColor: data.statusEnum?.font??AppTheme.cTextSecondary.color,
                    ),
                  ),
                ),
                onTap: () {
                  controller.toStoryboardWorkbench(data);
                },
              ),
            ),
          ],
        ),
        Visibility(
          visible: data.errorMessage != null && data.errorMessage != "",
          child: SelectableText(
            "失败原因: ${data.errorMessage??''}",
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cSurfaceError.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSceneItemContentWidget(ManageVisualProjectEntitySceneRelations data){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.wMin,
      children: [
        SelectableText(
          "Scene ${data.index??''} - ${data.sceneTitle??""}",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SelectableText(
          data.setting??"",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildImageListWidget(BuildContext context, ManageVisualProjectEntitySceneRelations data){
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.wMin,
        crossAxisSpacing: 16.wMin,
        childAspectRatio: 16 / 9,
      ),
      children: [
        _buildImageItemImageWidget(context, data, data.composition?.environment, SceneStoryboardTypeEnum.environment),
        _buildImageItemImageWidget(context, data, data.composition?.keyframes?.start, SceneStoryboardTypeEnum.start_frame),
        _buildImageItemImageWidget(context, data, data.composition?.keyframes?.highlight, SceneStoryboardTypeEnum.highlight_frame),
        _buildImageItemImageWidget(context, data, data.composition?.keyframes?.end, SceneStoryboardTypeEnum.end_frame),
      ],
    );
  }

  Widget _buildImageItemImageWidget(BuildContext context, ManageVisualProjectEntitySceneRelations data, ManageVisualProjectEntitySceneRelationsCompositionImage? item, SceneStoryboardTypeEnum type){
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: Stack(
        children: [

          Positioned.fill(
            child: TapScaleWidget(
              onTap: () {
                controller.showBigImage(context, item);
              },
              sclae: 1,
              child: CachedImageWidget(
                item?.imageUrl??"",
                fit: BoxFit.cover,
                placeholder: buildEmptyWidget(fit: BoxFit.cover),
                errorWidget: buildEmptyWidget(fit: BoxFit.cover),
              ),
            ),
          ),

          Positioned(
            top: 10.wMin,
            left: 10.wMin,
            child: Column(
              spacing: 8.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ManageTagFS16Widget(
                  tag: type.name,
                  bgColor: AppTheme.cSurfaceSecondary.color,
                  fontColor: AppTheme.cTextPrimary.color,
                ),
                ManageTagFS16Widget(
                  tag: "uid: ${item?.imageId??''}",
                  bgColor: AppTheme.cSurfaceSecondary.color,
                  fontColor: AppTheme.cTextPrimary.color,
                ),
                ManageTagFS16Widget(
                  tag: item?.status??"",
                  bgColor: item?.statusEnum?.bg ?? AppTheme.cSurfaceSecondary.color.withValues(alpha: 1),
                ),
              ],
            ),
          ),

          Positioned(
            right: 10.wMin,
            top: 10.wMin,
            child: Row(
              children: [

                Visibility(
                  visible: item?.isCover == true,
                  child: IgnorePointer(
                    ignoring: true,
                    child: ButtonWidget(
                      text: "已是封面",
                      height: 36.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin),
                      color: AppTheme.cSurfacePrimary.color,
                      borderRadius: 4.wMin,
                      fontSize: 16.wMin,
                      fontColor: AppTheme.cSurfaceSuccess.color,
                    ),
                  ),
                ),

                Visibility(
                  visible: item?.isCover != true,
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.dramaVisualProjectScriptCoverUpdate],
                    margin: EdgeInsets.only(left: 4.wMin),
                    child: ButtonWidget(
                      text: "设置为封面",
                      height: 36.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin),
                      color: AppTheme.cSurfacePrimary.color,
                      borderRadius: 4.wMin,
                      fontSize: 16.wMin,
                      fontColor: AppTheme.cSurfaceBrand.color,
                      sclae: 1.03,
                      onTap: () {
                        controller.setCover(context, item);
                      },
                    ),
                  ),
                ),

                ManageImageToolEditWidgets(
                  jumpCode: AppManageRoutesCode.visualProjectDetails,
                  params: {
                    "projectId": controller.detilData.value.uid,
                  },
                  showLockButton: false,
                  
                  imageTaskId: item?.statusEnum == ManageVisualImageStatusEnum.checked ? null : item?.imageTaskId,

                  uid: data.sceneId,
                  type: "SCRIPT_SCENE",
                  imageIds: item?.imageId == null ? null : [item!.imageId!],
                  styleId: controller.detilData.value.styleId,
                  visualProjectId: controller.detilData.value.uid,
                  sceneType: type,
                  onRefresh: () async{
                    controller.getDetilsData();
                  },
                ),

              ],
            ),
          ),

          Positioned(
            right: 10.wMin,
            bottom: 10.wMin,
            child: ManageImageToolBRWidgets(
              imageUrl: item?.imageUrl,
              onRefresh: () async{
                controller.getDetilsData();
              },
            ),
          ),

        ],
      ),
    );
  }


}
