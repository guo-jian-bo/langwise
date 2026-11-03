import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
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
                tag: "创建人: ${data.userId??''}",
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
      return IntrinsicHeight(
        child: Row(
          spacing: 16.wMin,
          children: [
            _buildStatisticsItemWidget("场景总数", data.sceneRelations?.length.toString()??"0"),
            _buildStatisticsItemWidget("已出图", "${data.sceneImageGeneratedCount??0}/${data.sceneRelations?.length??0}"),
            _buildStatisticsItemWidget("已审核", "${data.sceneTaskCheckedCount??0}/${data.sceneRelations?.length??0}"),
            _buildStatisticsItemWidget("视频片段", "${data.videoSegmentCount??0}段"),
            _buildStatisticsVideoWidget(context),
          ],
        ),
      );
    });
  }

  Widget _buildStatisticsVideoWidget(BuildContext context){
    return Expanded(
      child: Obx((){
        String videoUrl = controller.detilData.value.videoInfo?.videoUrl??"";
        return TapScaleWidget(
          onTap: () {
            controller.playCompletedVideo(context);
          },
          sclae: 1.01,
          child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SelectableText(
                      "成品视频",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Visibility(
                      visible: videoUrl.isNotEmpty,
                      child: Text(
                        "播放",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextBrand.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SelectableText(
                  "videoId: ${controller.detilData.value.videoInfo?.videoId??'-'}",
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
      }),
    );
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

    return Row(
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

        Visibility(
          visible: controller.canShowPromptButton(index),
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetPromptView],
            child: ButtonWidget(
              text: "分镜提示词",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cSurfaceBrand.color,
              sclae: 1.03,
              onTap: () {
                controller.viewPrompt(context, data);
              },
            ),
          ),
        ),

        SizedBox(width: 16.wMin),
        ButtonWidget(
          text: "分镜图",
          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
          height: 40.wMin,
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
          border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color),
          borderRadius: 8.wMin,
          fontSize: 18.wMin,
          fontColor: AppTheme.cSurfaceWarning.color,
          sclae: 1.03,
          onTap: () {
            controller.viewOriginalSceneImage(context, data);
          },
          rightIcon: Container(
            margin: EdgeInsets.only(left: 8.wMin),
            child: ManageTagFS16Widget(
              tag: data.statusEnum?.name,
              bgColor: data.statusEnum?.bg,
              fontColor: data.statusEnum?.font??AppTheme.cTextSecondary.color,
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
        _buildImageItemImageWidget(context, data.composition?.environment, "环境图"),
        _buildImageItemImageWidget(context, data.composition?.keyframes?.start, "起始帧"),
        _buildImageItemImageWidget(context, data.composition?.keyframes?.highlight, "高光帧"),
        _buildImageItemImageWidget(context, data.composition?.keyframes?.end, "结束帧"),
      ],
    );
  }

  Widget _buildImageItemImageWidget(BuildContext context, ManageVisualProjectEntitySceneRelationsCompositionImage? item, String name){
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
            child: Row(
              spacing: 8.wMin,
              children: [
                ManageTagFS16Widget(
                  tag: name,
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
            bottom: 10.wMin,
            child: Row(
              spacing: 8.wMin,
              children: [
                Visibility(
                  visible: item?.imageId != null,
                  child: ManageTagFS16Widget(
                    tag: "image_uid: ${item?.imageId??''}",
                    bgColor: AppTheme.cSurfaceSecondary.color,
                    fontColor: AppTheme.cTextPrimary.color,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }


}
