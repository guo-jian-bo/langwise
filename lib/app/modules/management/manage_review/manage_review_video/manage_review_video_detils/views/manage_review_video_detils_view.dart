

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../model/video_task_status_enum.dart';
import '../bindings/manage_review_video_detils_binding.dart';
import '../controllers/manage_review_video_detils_controller.dart';
import 'manage_review_video_detils_info_widget.dart';
import '../../../../common/video_edit_widget.dart';

class ManageReviewVideoDetilsView extends GetView<ManageReviewVideoDetilsController> {
  final String tagText;
  const ManageReviewVideoDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_VIDEO_DETILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewVideoDetilsView(tagText: tag),
      binding: ManageReviewVideoDetilsBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_VIDEO_DETILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40.wMin),
              child: Row(
                spacing: 16.wMin,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 400.wMin),
                      child: _buildVideoInfoWidget(),
                    ),
                  ),
                  SizedBox(
                    child: _buildVideoModuleWidget(),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomWidget(context),
      
        ],
      ),
    );
  }

  Widget _buildBottomWidget(BuildContext context){
    return Container(
      height: 76.wMin,
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
      ),
      child: Row(
        children: [
          Visibility(
            visible: controller.videoData.value.taskId != null,
            child: Row(
              children: [
                SelectableText(
                  "任务UID：${controller.videoData.value.taskId??''}",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
                SizedBox(width: 24.wMin),
                Container(width: 1.wMin, height: 20.wMin, color: AppTheme.cBorderPrimary.color),
                SizedBox(width: 24.wMin),
              ],
            ),
          ),
          
          Visibility(
            visible: controller.videoData.value.started != null,
            child: SelectableText(
              "生成时间：${DateFormatUtil.formatStrtoStr(controller.videoData.value.started, newPattern: "yyyy-MM-dd HH:mm")}",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ),
          const Spacer(),

          ButtonWidget(
            text: "取消",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            height: 40.wMin,
            color: AppTheme.cSurfaceQuaternary.color,
            fontColor: AppTheme.cTextTertiary.color,
            fontSize: 16.wMin,
            borderRadius: 6..wMin,
            sclae: 1.05,
            onTap: () {
              Get.back();
            },
          ),
          SizedBox(width: 12.wMin),

          _buildBottomButtonsWidget(context),

        ],
      ),
    );
  }


  Widget _buildBottomButtonsWidget(BuildContext context){
    return Obx((){
      if(controller.videoData.value.status == null) return Container();
      VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(controller.videoData.value.status);

      if(status == VideoTaskStatusEnum.checked){

        return Row(
          children: [
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.videoReviewVideoEdit],
              child: ButtonWidget(
                text: "保存裁剪&静音状态",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 40.wMin,
                color: AppTheme.cSurfaceInfo.color,
                fontColor: AppTheme.cInverseTextLight.color,
                fontSize: 16.wMin,
                borderRadius: 6..wMin,
                sclae: 1.03,
                onTap: () {
                  controller.saveCropMute();
                },
              ),
            ),
            SizedBox(width: 12.wMin),

            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.videoReviewVideoAudioEnhance],
              child: ButtonWidget(
                text: "音频增强",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 40.wMin,
                color: const Color(0xffFB923C),
                fontColor: AppTheme.cInverseTextLight.color,
                fontSize: 16.wMin,
                borderRadius: 6..wMin,
                sclae: 1.03,
                onTap: () {
                  controller.audioEnhancement(context);
                },
              ),
            ),

          ],
        );

      }

      return Row(
        children: [

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.videoReviewTaskRetryVideoPrompt],
            child: ButtonWidget(
              text: "重新生成提示词和视频",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color: const Color(0xff8B5CF6),
              fontColor: AppTheme.cInverseTextLight.color,
              fontSize: 16.wMin,
              borderRadius: 6..wMin,
              sclae: 1.03,
              onTap: () async{
                controller.regeneratePromptAndVideos();
              },
            ),
          ),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.videoReviewTaskRetryVideoGenerate],
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "用提示词重新生成视频",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color: AppTheme.cSurfaceWarning.color,
              fontColor: AppTheme.cInverseTextLight.color,
              fontSize: 16.wMin,
              borderRadius: 6..wMin,
              sclae: 1.03,
              onTap: () {
                controller.usePromptRegenerateTheVideo();
              },
            ),
          ),
          

          Container(
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "审核通过",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color: AppTheme.cSurfaceSuccess.color,
              fontColor: AppTheme.cInverseTextLight.color,
              fontSize: 16.wMin,
              borderRadius: 6..wMin,
              sclae: 1.03,
              onTap: () {
                controller.videoApprove();
              },
            ),
          ),
        ],
      );
    });
  }
  

  Widget _buildVideoModuleWidget() {
    
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.wMin),
      child: Column(
        children: [
          Obx((){
            VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(controller.videoData.value.status);

            List<VideoTaskEntityListVideos?> videos = controller.videoData.value.videos??[];
            int current = controller.currentVideoIndex.value;

            return Visibility(
              visible: status != VideoTaskStatusEnum.checked,
              child: Container(
                margin: EdgeInsets.only(bottom: 10.wMin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TapScaleWidget(
                      onTap: () {
                        controller.toggleReviewVideo(isNext: false);
                      },
                      sclae: 1.03,
                      child: Container(
                        width: 48.wMin,
                        height: 48.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.cSurfaceTertiary.color,
                          borderRadius: BorderRadius.circular(4.wMin),
                        ),
                        child: SvgPicture.asset(
                          'assets/svg/public/icon_w_arrow_left.svg',
                          width: 24.wMin,
                          height: 24.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    SizedBox(width: 24.wMin),
                    Container(
                      width: 150.wMin,
                      alignment: Alignment.center,
                      child: Visibility(
                        visible: videos.isNotEmpty && current >= 0,
                        child: SelectableText(
                          "视频 ${current + 1} / ${videos.length}",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 24.wMin),
                    TapScaleWidget(
                      onTap: () {
                        controller.toggleReviewVideo(isNext: true);
                      },
                      sclae: 1.03,
                      child: Container(
                        width: 48.wMin,
                        height: 48.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.cSurfaceTertiary.color,
                          borderRadius: BorderRadius.circular(4.wMin),
                        ),
                        child: SvgPicture.asset(
                          'assets/svg/public/icon_w_arrow_right.svg',
                          width: 24.wMin,
                          height: 24.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.wMin),
                  child: Container(
                    color: AppTheme.cSurfacePrimary.color,
                    child: Obx((){
                      List<VideoTaskEntityListVideos> videos = controller.videoList.toList();
                      int current = controller.currentVideoIndex.value;
                      if(videos.isEmpty) return Container();
                      if(current > videos.length) return Container();
                      VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(controller.videoData.value.status);
                      bool checked = status == VideoTaskStatusEnum.checked;
                      return VideoEditWidget(
                        controller: controller.videoEditController,
                        videoUrl: videos[current].videoUrl??"",
                        trimStartTime: checked ? controller.videoCropStartDuration.value : null,
                        trimEndTime: checked ? controller.videoCropEndDuration.value : null,
                        isMuted: controller.videoIsMute.value,
                        onTrim: (startTime, endTime, isMuted) {
                          controller.videoCropStartDuration.value = startTime;
                          controller.videoCropEndDuration.value = endTime;
                          controller.videoIsMute.value = isMuted;
                        },
                        onVideoDuration: (actualDuration) {
                          controller.actualDuration.value = actualDuration;
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
      
        ],
      ),
    );
  }


  Widget _buildVideoInfoWidget(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.wMin),
      child: ManageReviewVideoDetilsInfoWidget(controller: controller),
    );
  }


}
