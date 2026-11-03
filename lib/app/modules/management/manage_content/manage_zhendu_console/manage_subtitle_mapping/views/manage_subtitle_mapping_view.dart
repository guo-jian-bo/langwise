import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_subtitle_mapping_binding.dart';
import '../controllers/manage_subtitle_mapping_controller.dart';
import 'manage_subtitle_mapping_ass_list_widget.dart';
import 'manage_subtitle_mapping_scene_info_widget.dart';
import 'manage_subtitle_mapping_scene_list_widget.dart';

class ManageSubtitleMappingView extends GetView<ManageSubtitleMappingController> {
  final String tagText;
  const ManageSubtitleMappingView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SUBTITLE_MAPPING}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSubtitleMappingView(tagText: tag),
      binding: ManageSubtitleMappingBinding(tag: tag),
      routeName: Routes.MANAGE_SUBTITLE_MAPPING,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.getMappingData(),
      body: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.space): () {
            controller.player.playOrPause();
          },
        },
        child: Focus(
          autofocus: true,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 20.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleWIdget(),
                SizedBox(height: 10.wMin),
                Expanded(
                  child: Row(
                    spacing: 16.wMin,
                    children: [
                      ManageSubtitleMappingSceneListWidget(controller: controller),
                      Expanded(
                        child: ManageSubtitleMappingSceneInfoWidget(controller: controller),
                      ),
                      ManageSubtitleMappingAssListWidget(controller: controller),
                    ],
                  ),
                ),
                SizedBox(height: 10.wMin),
                _buildPlayWidget(context),
                SizedBox(height: 10.wMin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWIdget(){
    return Row(
      children: [
        SelectableText(
          controller.projectName??'',
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(width: 16.wMin),

        ManageTagFS16Widget(
          tag: "projecc_id: ${controller.projectId??''}",
          bgColor: AppTheme.cSurfaceSecondary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 8.wMin),
        ManageTagFS16Widget(
          tag: "Scene 级映射",
          bgColor: AppTheme.cSurfaceSecondary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 8.wMin),
        Obx((){
          int totalSceneCount = controller.scenesList.length;
          int savedSceneCount = controller.scenesList.where((scene) {
            bool start = scene.composition?.keyframes?.start?.mappings != null;
            bool highlight = scene.composition?.keyframes?.highlight?.mappings != null;
            bool end = scene.composition?.keyframes?.end?.mappings != null;
            return start || highlight || end;
          }).length;

          return ManageTagFS16Widget(
            tag: "已保存 $savedSceneCount/$totalSceneCount Scene",
            bgColor: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
            fontColor: AppTheme.cSurfaceSuccess.color,
          );
        }),
      ],
    );
  }





  Widget _buildPlayWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      height: 100.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
          
              Container(
                height: 42.wMin,
                constraints: BoxConstraints(
                  minWidth: 250.wMin,
                ),
                padding: EdgeInsets.only(left: 10.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/manage/icon_duration.svg",
                      width: 24.wMin,
                    ),
                    SizedBox(width: 10.wMin),
                    Obx((){
                      String audioDurationText = DateFormatUtil.formatMillisecondsToMinSec(controller.audioDuration.value);
                      String currentPositionText = DateFormatUtil.formatMillisecondsToMinSec(controller.currentPosition.value);
                      return Text(
                        "$audioDurationText / $currentPositionText",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                  ],
                ),
              ),
          
              SizedBox(width: 24.wMin),
          
              Obx((){
                String label = controller.getCurrentPlaybackSceneFrameLabel();
                return Container(
                  height: 42.wMin,
                  padding: EdgeInsets.only(left: 10.wMin),
                  constraints: BoxConstraints(
                    minWidth: 220.wMin,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: AppTheme.cSurfaceBrand.color.withValues(alpha: label.isEmpty ? 0 : 0.2),
                    border: Border.all(
                      width: 1.wMin, 
                      color: AppTheme.cBorderBrand.color.withValues(alpha: label.isEmpty ? 0.2 : 1.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/svg/manage/icon_frame.svg",
                        width: 22.wMin,
                      ),
                      SizedBox(width: 10.wMin),
                      Text(
                        label.isEmpty ? "未命中映射" : label,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: label.isEmpty ? AppTheme.cTextTertiary.color : AppTheme.cTextBrand.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          
              SizedBox(width: 24.wMin),
          
              Container(
                height: 42.wMin,
                padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
                ),
                child: Row(
                  children: [
                    Text(
                      "下一步：所有 scene 保存完成后创建关键帧字幕",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
          
              const Spacer(),
          
              Obx((){
                bool canCreate = controller.canCreateKeyframeSubtitles();
                return Opacity(
                  opacity: canCreate ? 1 : 0.6,
                  child: ButtonWidget(
                    text: "创建关键帧字幕",
                    height: 42.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0),
                    border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
                    fontColor: AppTheme.cSurfaceSuccess.color,
                    fontSize: 20.wMin,
                    borderRadius: 10.wMin,
                    sclae: 1.03,
                    onTap: () async{
                      await controller.generateKeyframeSubtitles(context);
                    },
                  ),
                );
              }),
          
              SizedBox(width: 24.wMin),
          
              TapScaleWidget(
                onTap: () {
                  controller.player.playOrPause();
                },
                sclae: 1.03,
                child: Container(
                  width: 52.wMin,
                  height: 52.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceBrand.color,
                  ),
                  child: Obx((){
                    return Icon(
                      controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 38.wMin,
                      color: Colors.white,
                    );
                  }),
                ),
              ),

            ],
          ),
          

          Obx((){
            double maxMs = controller.audioDuration.value.inMilliseconds.toDouble();
            if(maxMs <= 0){
              maxMs = 1;
            }
            double valueMs = controller.currentPosition.value.inMilliseconds.toDouble().clamp(0, maxMs);

            return SliderTheme(
              data: SliderThemeData(
                trackHeight: 8.wMin,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.wMin),
                overlayShape: SliderComponentShape.noOverlay,
                tickMarkShape: SliderTickMarkShape.noTickMark,
              ),
              child: Slider(
                min: 0,
                max: maxMs,
                value: valueMs, 
                activeColor: AppTheme.cSurfaceBrand.color,
                inactiveColor: AppTheme.cSurfaceQuinary.color,
                onChanged: (value) async{
                  await controller.seekAudioTo(Duration(milliseconds: value.toInt()));
                },
              ),
            );
          }),

        ],
      ),
    );
  }


}
