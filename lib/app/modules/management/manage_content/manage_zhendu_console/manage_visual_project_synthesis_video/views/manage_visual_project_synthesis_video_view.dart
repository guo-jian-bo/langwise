import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_visual_project_synthesis_video_binding.dart';
import '../controllers/manage_visual_project_synthesis_video_controller.dart';
import 'manage_visual_project_synthesis_scene_widget.dart';
import 'manage_visual_project_synthesis_timeline_widget.dart';

class ManageVisualProjectSynthesisVideoView extends GetView<ManageVisualProjectSynthesisVideoController> {
  final String tagText;
  const ManageVisualProjectSynthesisVideoView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_VISUAL_PROJECT_SYNTHESIS_VIDEO}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageVisualProjectSynthesisVideoView(tagText: tag),
      binding: ManageVisualProjectSynthesisVideoBinding(tag: tag),
      routeName: Routes.MANAGE_VISUAL_PROJECT_SYNTHESIS_VIDEO,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.initData(),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 150.wMin,
                right: 150.wMin,
                top: 10.wMin,
                bottom: 20.wMin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameWidget(),
                  SizedBox(height: 10.wMin),
                  _buildSceneImageWidget(),
                  SizedBox(height: 10.wMin),
                  _buildVideoTimelineWidget(),
                  
                ],
              ),
            ),
          ),
          Positioned(
            right: 10.wMin,
            bottom: 40.wMin,
            child: _buildToolButtonsWidget(context),
          ),
        ],
      ),
    );
  }

    /// 工具按钮
  Widget _buildToolButtonsWidget(BuildContext context){
    return Obx((){
      int selectedSceneCount = controller.selectedSceneIds.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          IgnorePointer(
            ignoring: selectedSceneCount != 1,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaVisualProjectGenerateVideoScene],
              child: ButtonWidget(
                text: "生成场景视频",
                padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                height: 44.wMin,
                color: const Color(0xffc800de).withValues(alpha: 0.2),
                border: Border.all(
                  width: 1.wMin, 
                  color: selectedSceneCount != 1 ? AppTheme.cBorderPrimary.color : const Color(0xffc800de),
                ),
                borderRadius: 8.wMin,
                fontSize: 18.wMin,
                fontColor: selectedSceneCount != 1 ? AppTheme.cTextQuaternary.color : const Color(0xffc800de),
                sclae: 1.03,
                onTap: () {
                  controller.generateSceneVideo();
                },
              ),
            ),
          ),
          IgnorePointer(
            ignoring: selectedSceneCount != 2,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaVisualProjectGenerateVideoBetweenScenes],
              margin: EdgeInsets.only(top: 16.wMin),
              child: ButtonWidget(
                text: "生成过渡视频",
                padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                height: 44.wMin,
                color: const Color(0xff0092b8).withValues(alpha: 0.2),
                border: Border.all(
                  width: 1.wMin, 
                  color: selectedSceneCount != 2 ? AppTheme.cBorderPrimary.color :  const Color(0xff0092b8),
                ),
                borderRadius: 8.wMin,
                fontSize: 18.wMin,
                fontColor: selectedSceneCount != 2 ? AppTheme.cTextQuaternary.color : const Color(0xff0092b8),
                sclae: 1.03,
                onTap: () {
                  controller.generateTransitionVideo();
                },
              ),
            ),
          ),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVisualProjectVideoImport],
            margin: EdgeInsets.only(top: 16.wMin),
            child: ButtonWidget(
              text: "导入完整视频",
              padding: EdgeInsets.symmetric(horizontal: 10.wMin),
              height: 44.wMin,
              color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cSurfaceSuccess.color,
              sclae: 1.03,
              onTap: () {
                controller.importCompleteVideo(context);
              },
            ),
          ),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVisualProjectVideoCompose],
            margin: EdgeInsets.only(top: 16.wMin),
            child: ButtonWidget(
              text: "合成完整视频",
              padding: EdgeInsets.symmetric(horizontal: 10.wMin),
              height: 44.wMin,
              color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cSurfaceWarning.color,
              sclae: 1.03,
              onTap: () {
                controller.generateFullVideo();
              },
            ),
          ),
        ],
      );
    });
  }

  /// 名称
  Widget _buildNameWidget(){
    return Obx((){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '视频合成 · ${controller.detilData.value.title??""}',
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${controller.detilData.value.statusEnum?.name??""} · ${controller.detilData.value.styleTitle??""}',
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

  /// 场景图片预览
  Widget _buildSceneImageWidget(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
            child: Row(
              spacing: 6.wMin,
              children: [
                SelectableText(
                  "场景图片预览",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SelectableText(
                  "勾选 1 个场景→生成场景视频，勾选 2 个相邻场景→生成过渡视频",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                Obx((){
                  int selectedSceneIdsCount = controller.selectedSceneIds.length;
                  String selectText = "";
                  if(selectedSceneIdsCount == 1){
                    selectText = "已选 1 个场景，可生成场景视频";
                  }else if(selectedSceneIdsCount == 2){
                    selectText = "已选 2 个场景，可生成过渡视频";
                  }

                  return SelectableText(
                    selectText,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cSurfaceSuccess.color,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),

                


              ],
            ),
          ),

          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
            child: Obx((){
              List<ManageVisualProjectEntitySceneRelations?> sceneRelations = controller.detilData.value.sceneRelations??[];
              return Row(
                spacing: 16.wMin,
                children: List.generate(sceneRelations.length, (index){
                  return ManageVisualProjectSynthesisSceneWidget(
                    controller: controller,
                    scene: sceneRelations[index],
                  );
                }),
              );
            }),
          ),

        ],
      ),
    );
  }




  /// 视频片段时间线
  Widget _buildVideoTimelineWidget(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
            child: Row(
              children: [
                SelectableText(
                  "视频片段时间线",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 6.wMin),
                SelectableText(
                "拖拽排序 · 删除无用片段 · 状态实时更新",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w500,
                ),
                ),
                const Spacer(),
                Obx((){
                  return ButtonWidget(
                    text: "打包下载 · ${controller.getDownloadZipName()}",
                    height: 38.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: Colors.transparent,
                    borderRadius: 6.wMin,
                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderBrand.color),
                    fontColor: AppTheme.cTextBrand.color,
                    fontSize: 18.wMin,
                    sclae: 1.01,
                    onTap: (){
                      controller.downloadVideoZip();
                    },
                  );
                }),
                SizedBox(width: 16.wMin),
                Icon(Icons.sort_rounded, color: AppTheme.cTextTertiary.color, size: 24.wMin),
                SizedBox(width: 10.wMin),
                SelectableText(
                  "拖拽可排序",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),

          IntrinsicHeight(
            child: Obx((){
              return ReorderableRow(
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
                onReorder: (index, newIndex){
                  controller.sortVideo(index, newIndex);
                },
                buildDraggableFeedback: (context, constraints, child) {
                  return Transform.scale(
                    scale: 0.98,
                    child: Container(
                      constraints: constraints,
                      child: child,
                    ),
                  );
                },
                children: List.generate(controller.sceneVideoList.length, (index){
                  return Container(
                    key: Key(index.toString()),
                    margin: EdgeInsets.only(right: 16.wMin),
                    child: ManageVisualProjectSynthesisTimelineWidget(
                      controller: controller,
                      data: controller.sceneVideoList[index],
                    ),
                  );
                }),
              );
            }),
          ),

        ],
      ),
    );
  }

}
