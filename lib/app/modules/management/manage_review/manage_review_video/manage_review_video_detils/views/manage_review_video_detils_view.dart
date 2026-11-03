



import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../enums/video_task_status_enum.dart';
import '../bindings/manage_review_video_detils_binding.dart';
import '../controllers/manage_review_video_detils_controller.dart';
import 'manage_review_video_detils_info_widget.dart';

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
      showCollectButton: false,
      onRefresh: controller.isAdminPage ? () => controller.refreshData() : null,
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 30.wMin, right: 10.wMin),
              child: Row(
                spacing: 16.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 400.wMin),
                      child: _buildVideoInfoWidget(),
                    ),
                  ),
                  _buildVideoModuleWidget(),
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
          Obx((){
            return Visibility(
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
            );
          }),
          
          Obx((){
            return Visibility(
              visible: controller.videoData.value.started != null,
              child: SelectableText(
                "生成时间：${DateFormatUtil.formatStrtoStr(controller.videoData.value.started, newPattern: "yyyy-MM-dd HH:mm")}",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            );
          }),

          Visibility(
            visible: controller.isAdminPage,
            child: Row(
              children: [

                

                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.videoReviewGenerateFrameStart, ManageAuthCode.videoReviewGenerateStartEndFrames],
                  child: ButtonWidget(
                    text: "新建视频",
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    height: 40.wMin,
                    color: ResourceTypeEnum.video.color.withValues(alpha: 0.2),
                    fontColor: ResourceTypeEnum.video.color,
                    border: Border.all(width: 1.wMin, color: ResourceTypeEnum.video.color),
                    fontSize: 16.wMin,
                    borderRadius: 6.wMin,
                    sclae: 1.03,
                    onTap: () {
                      controller.createVideo(context);
                    },
                  ),
                ),

                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.adminVideoReviewGenerateByPrompy],
                  margin: EdgeInsets.only(left: 16.wMin),
                  child: ButtonWidget(
                    text: "用提示词新建视频",
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    height: 40.wMin,
                    color: ResourceTypeEnum.video.color.withValues(alpha: 0.2),
                    fontColor: ResourceTypeEnum.video.color,
                    border: Border.all(width: 1.wMin, color: ResourceTypeEnum.video.color),
                    fontSize: 16.wMin,
                    borderRadius: 6..wMin,
                    sclae: 1.03,
                    onTap: () {
                      controller.createVideoByPrompt(context);
                    },
                  ),
                ),

                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.adminAssReviewTaskAlignVideoCreate],
                  margin: EdgeInsets.only(left: 48.wMin),
                  child: ButtonWidget(
                    text: "新建字幕",
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    height: 40.wMin,
                    color: ResourceAlignEnum.align.color.withValues(alpha: 0.2),
                    fontColor: ResourceAlignEnum.align.color,
                    border: Border.all(width: 1.wMin, color: ResourceAlignEnum.align.color),
                    fontSize: 16.wMin,
                    borderRadius: 6.wMin,
                    sclae: 1.03,
                    onTap: () {
                      controller.assReviewCreateAlign();
                    },
                  ),
                ),

                Visibility(
                  visible: UserStore.to.rolePermissions.value.userIsAssReviewer || UserStore.to.rolePermissions.value.userIsAssSuperReviewer,
                  child: Container(
                    margin: EdgeInsets.only(left: 16.wMin),
                    child: Obx((){
                      return ButtonWidget(
                        text: "待审核字幕${controller.videoData.value.assTaskIds?.length??0}个",
                        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                        height: 40.wMin,
                        color: ResourceAlignEnum.align.color.withValues(alpha: 0.2),
                        border: Border.all(width: 1.wMin, color: ResourceAlignEnum.align.color),
                        fontColor: ResourceAlignEnum.align.color,
                        fontSize: 16.wMin,
                        borderRadius: 6.wMin,
                        sclae: 1.03,
                        onTap: () {
                          controller.toAssReview();
                        },
                      );
                    }),
                  ),
                ),

                Obx((){
                  int? assRelationId = controller.videoData.value.assRelationId;
                  if(assRelationId == null) return Container();
                  bool assLocked = controller.videoData.value.assLocked == true;
                  return ManageAuthBoxWidget(
                    authCodes: [assLocked ? ManageAuthCode.adminAssReviewAssUnlock : ManageAuthCode.adminAssReviewAssLock],
                    margin: EdgeInsets.only(left: 16.wMin),
                    child: ButtonWidget(
                      text: "字幕定稿",
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                        border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackSuccessBorder.color),
                        fontColor: assLocked ? AppTheme.cFeedbackErrorText.color : AppTheme.cFeedbackSuccessText.color,
                        color: assLocked ? AppTheme.cFeedbackErrorBackground.color : AppTheme.cFeedbackSuccessBackground.color,
                        sclae: 1.03,
                        borderRadius: 6.wMin,
                        fontSize: 16.wMin,
                        height: 40.wMin,
                        leftIcon: Container(
                          margin: EdgeInsets.only(right: 6.wMin),
                          child: SvgPicture.asset(
                            assLocked ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                            width: 16.wMin,
                          ),
                        ),
                      onTap: () {
                        if(assLocked){
                          controller.cancelFinalDraftAss(context);
                        }else{
                          controller.finalDraftAss(context);
                        }
                      },
                    ),
                  );
                }),
                

              ],
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
            borderRadius: 6.wMin,
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

      bool videoLoadingCompleted = false;
      if(controller.videoCropEndDuration.value != Duration.zero && controller.actualDuration.value != Duration.zero){
        videoLoadingCompleted = true;
      }

      if(status == VideoTaskStatusEnum.checked){

        return Row(
          children: [
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.videoReviewVideoEdit],
              child: ButtonWidget(
                text: "保存裁剪&静音状态&台词",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 40.wMin,
                color: AppTheme.cFeedbackInfoBackground.color,
                fontColor: AppTheme.cFeedbackInfoText.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackInfoBorder.color),
                fontSize: 16.wMin,
                borderRadius: 6.wMin,
                sclae: 1.03,
                onTap: !videoLoadingCompleted ? null : () {
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
                color: const Color(0xffFB923C).withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: const Color(0xffFB923C)),
                fontColor: const Color(0xffFB923C),
                fontSize: 16.wMin,
                borderRadius: 6.wMin,
                sclae: 1.03,
                onTap: () {
                  controller.audioEnhancement(context);
                },
              ),
            ),

            Visibility(
              visible: controller.isAdminPage,
              child: Obx((){
                List<VideoTaskEntityListVideos> videos = controller.videoList.toList();
                int current = controller.currentVideoIndex.value;
                if(videos.isEmpty) return Container();
                if(current > videos.length) return Container();

                return ManageAuthBoxWidget(
                  authCodes: [videos[current].locked == true ? ManageAuthCode.videoReviewVideoUnlock : ManageAuthCode.videoReviewVideoLock],
                  margin: EdgeInsets.only(left: 16.wMin),
                  child: ButtonWidget(
                    text: videos[current].locked == true ? "解锁定稿" : "视频定稿",
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackSuccessBorder.color),
                    fontColor: videos[current].locked == true ? AppTheme.cFeedbackErrorText.color : AppTheme.cFeedbackSuccessText.color,
                    color: videos[current].locked == true ? AppTheme.cFeedbackErrorBackground.color : AppTheme.cFeedbackSuccessBackground.color,
                    sclae: 1.03,
                    borderRadius: 6.wMin,
                    fontSize: 16.wMin,
                    height: 40.wMin,
                    leftIcon: Container(
                      margin: EdgeInsets.only(right: 6.wMin),
                      child: SvgPicture.asset(
                        videos[current].locked == true ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                        width: 16.wMin,
                      ),
                    ),
                    onTap: () {
                      if(videos[current].locked == true){
                        controller.cancelFinalDraftVideo(context);
                      }else{
                        controller.finalDraftVideo(context);
                      }
                    },
                  ),
                  
                );

              }),
            ),

          ],
        );

      }

      return Row(
        children: [

          Visibility(
            visible: !controller.isHideRegenerateBtn,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.videoReviewTaskRetryVideoPrompt],
              child: ButtonWidget(
                text: "重新生成提示词和视频",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 40.wMin,
                color: const Color(0xff8B5CF6).withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: const Color(0xff8B5CF6)),
                fontColor: const Color(0xff8B5CF6),
                fontSize: 16.wMin,
                borderRadius: 6.wMin,
                sclae: 1.03,
                onTap: () async{
                  controller.regeneratePromptAndVideos();
                },
              ),
            ),
          ),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.videoReviewTaskRetryVideoGenerate],
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "用提示词重新生成视频",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color),
              fontColor: AppTheme.cSurfaceWarning.color,
              fontSize: 16.wMin,
              borderRadius: 6.wMin,
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
              color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
              fontColor: AppTheme.cSurfaceSuccess.color,
              fontSize: 16.wMin,
              borderRadius: 6.wMin,
              sclae: 1.03,
              onTap: !videoLoadingCompleted ? null : () {
                controller.videoApprove();
              },
            ),
          ),
        ],
      );
    });
  }
  

  Widget _buildVideoModuleWidget() {
    
    return SizedBox(
      width: 700.wMin + 20.wMin,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 10.wMin,
          bottom: 10.wMin,
          right: 20.wMin,
        ),
        child: Column(
          children: [
            SizedBox(
              width: 700.wMin,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cSurfacePrimary.color,
                  borderRadius: BorderRadius.circular(16.wMin),
                ),
                child: Stack(
                  children: [
                    Obx((){
                      List<VideoTaskEntityListVideos> videos = controller.videoList.toList();
                      int current = controller.currentVideoIndex.value;
                      if(videos.isEmpty) return Container();
                      if(current > videos.length) return Container();
                      bool isTrimEnd = controller.videoCropEndDuration.value != Duration.zero;
                      return VideoEditWidget(
                        videoSize: Size(700.wMin, 700.wMin),
                        borderRadius: BorderRadius.circular(16.wMin),
                        controller: controller.videoEditController,
                        videoUrl: videos[current].videoUrl??"",
                        trimStartTime: controller.videoCropStartDuration.value,
                        trimEndTime: isTrimEnd ? controller.videoCropEndDuration.value : null,
                        isMuted: controller.videoIsMute.value,
                        autoHideControls: false,
                        ass: controller.videoData.value.ass,
                        translate: controller.videoData.value.translate,
                        onTrim: (startTime, endTime, isMuted) {
                          controller.videoCropStartDuration.value = startTime;
                          controller.videoCropEndDuration.value = endTime;
                          controller.videoIsMute.value = isMuted;
                        },
                        onVideoDuration: (actualDuration) {
                          controller.actualDuration.value = actualDuration;
                        },
                        onVideoPosition: (duration) {
                          controller.onVideoPosition.value = duration;
                        },
                      );
                    }),
                    Positioned(
                      right: 10.wMin,
                      top: 700.wMin - 42.wMin - 10.wMin,
                      child: _buildArrowWidget(),
                    ),
                  ],
                ),
              ),
            ),
              
            _buildLinesWidget(),
        
          ],
        ),
      ),
    );
  }

  Widget _buildArrowWidget(){
    return Obx((){
      VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(controller.videoData.value.status);

      List<VideoTaskEntityListVideos?> videos = controller.videoData.value.videos??[];
      int current = controller.currentVideoIndex.value;

      return Visibility(
        visible: status != VideoTaskStatusEnum.checked,
        child: Container(
          margin: EdgeInsets.only(top: 6.wMin, bottom: 6.wMin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TapScaleWidget(
                onTap: () {
                  controller.toggleReviewVideo(isNext: false);
                },
                sclae: 1.03,
                child: Container(
                  width: 38.wMin,
                  height: 38.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    border: Border.all(width: 0.6.wMin, color: AppTheme.cInverseOverlay3.color),
                    borderRadius: BorderRadius.circular(4.wMin),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16.wMin,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 24.wMin),
              Container(
                width: 80.wMin,
                alignment: Alignment.center,
                child: Visibility(
                  visible: videos.isNotEmpty && current >= 0,
                  child: SelectableText(
                    "视频 ${current + 1}/${videos.length}",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextPrimary.color,
                      shadows: const [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black38,
                        ),
                      ],
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
                  width: 38.wMin,
                  height: 38.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    border: Border.all(width: 0.6.wMin, color: AppTheme.cInverseOverlay3.color),
                    borderRadius: BorderRadius.circular(4.wMin),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.wMin,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLinesWidget(){
    return Obx((){
      return Container(
        margin: EdgeInsets.only(top: 10.wMin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 46.wMin,
              alignment: Alignment.centerLeft,
              child: Text(
                "台词",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 10.wMin),
            Expanded(
              child: Column(
                children: [
                  Column(
                    spacing: 6.wMin,
                    children: List.generate(controller.linesInputs.length, (index){
                  
                      return Row(
                        children: [
                          Expanded(
                            child: CardInputWidget(
                              controller: controller.linesInputs[index],
                              height: 46.wMin,
                              borderRadius: BorderRadius.circular(8.wMin),
                              borderColor: Colors.transparent,
                              valueStyle: TextStyle(
                                fontSize: 18.wMin,
                                color: AppTheme.cTextBrand.color,
                                fontWeight: FontWeight.w500,
                              ),
                              onClean: () {
                                controller.linesInputs[index].clear();
                              },
                            ),
                          ),

                          TapScaleWidget(
                            onTap: () {
                              controller.deleteLines(index);
                            },
                            sclae: 1.03,
                            child: Container(
                              width: 46.wMin,
                              height: 46.wMin,
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: SvgPicture.asset(
                                "assets/svg/public/icon_delete.svg",
                                width: 28.wMin,
                              ),
                            ),
                          ),

                        ],
                      );
                  
                    }),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 6.wMin, right: 46.wMin),
                    child: ButtonWidget(
                      text: "添加台词",
                      height: 46.wMin,
                      color: AppTheme.cSurfaceTertiary.color,
                      borderRadius: 8.wMin,
                      fontColor: AppTheme.cSurfaceInfo.color,
                      fontSize: 18.wMin,
                      sclae: 1,
                      onTap: () {
                        controller.addLines();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }


  Widget _buildVideoInfoWidget(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.wMin),
      child: ManageReviewVideoDetilsInfoWidget(controller: controller),
    );
  }


}
