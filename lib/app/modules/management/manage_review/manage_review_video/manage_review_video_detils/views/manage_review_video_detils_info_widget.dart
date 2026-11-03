


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import '../../../../enums/video_aspect_ratio_enum.dart';
import '../../../../enums/video_task_status_enum.dart';
import '../controllers/manage_review_video_detils_controller.dart';

class ManageReviewVideoDetilsInfoWidget extends StatelessWidget {
  final ManageReviewVideoDetilsController controller;
  const ManageReviewVideoDetilsInfoWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: AppTheme.cSurfacePrimary.color,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTagsWidget(),
            _buildContentWidget(),
            SizedBox(height: 16.wMin),
            Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color),
            _buildFrameImageWidget(context),
            Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color),
            _buildVideoInfoWidget(),
            Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color),
            _buildSceneGuideWidget(),
            Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color),
            _buildVideoPromptWidget(context),
          ],
        ),
      ),
    );
  }


  Widget _buildTagsWidget(){
    return Obx((){
      ElementsCardColor? typeColor = StatusUtils.getElementsCardColor(controller.videoData.value.contentType);

      VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(controller.videoData.value.status);
      

      return SizedBox(
        height: 40.wMin,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ManageTagFS16Widget(
                tag: controller.videoData.value.typeTitle,
                bgColor: typeColor?.color1,
              ),
              SizedBox(width: 6.wMin),
              Visibility(
                visible: controller.videoData.value.difficulty != null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2.wMin,
                  children: [
                    StatusTagDifficultyWidget(
                      difficulty: controller.videoData.value.difficulty?.min,  
                      language: "en",
                    ),
                    Text(
                      "-",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextQuaternary.color,
                      ),
                    ),
                    StatusTagDifficultyWidget(
                      difficulty: controller.videoData.value.difficulty?.max,  
                      language: "en",
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.wMin),
              Container(width: 1.wMin, height: 18.wMin, color: AppTheme.cBorderTertiary.color),
              SizedBox(width: 6.wMin),
              ManageTagFS16Widget(
                tag: controller.videoData.value.styleTitle,
                bgColor: const Color(0xffF59E0B).withValues(alpha: 0.12),
                fontColor: const Color(0xffF59E0B),
              ),
              SizedBox(width: 6.wMin),
              ManageTagFS16Widget(
                tag: controller.videoData.value.localeTitle,
                bgColor: const Color(0xffA855F7).withValues(alpha: 0.12),
                fontColor: const Color(0xffA855F7),
              ),
              SizedBox(width: 6.wMin),
              Container(width: 1.wMin, height: 18.wMin, color: AppTheme.cBorderTertiary.color),
              SizedBox(width: 6.wMin),
              ManageTagFS16Widget(
                tag: status.name,
                bgColor: status.bg.withValues(alpha: 0.12),
                fontColor: status.bg,
              ),
              Visibility(
                visible: controller.videoData.value.mode != null,
                child: Container(
                  margin: EdgeInsets.only(left: 6.wMin),
                  child: ManageTagFS16Widget(
                    tag: controller.videoData.value.mode,
                    bgColor: AppTheme.cSurfaceTertiary.color,
                    fontColor: AppTheme.cTextSecondary.color,
                  ),
                ),
              ),
              Visibility(
                visible: status == VideoTaskStatusEnum.checked && controller.videoList.isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(left: 6.wMin),
                  child: Row(
                    children: [
                      Container(width: 1.wMin, height: 18.wMin, color: AppTheme.cBorderTertiary.color),
                      SizedBox(width: 6.wMin,),
                      ManageTagFS16Widget(
                        tag: controller.videoList.isEmpty ? null : "ID: ${controller.videoList[controller.currentVideoIndex.value].videoId?.toString()}",
                        fontColor: AppTheme.cTextTertiary.color,
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

  Widget _buildContentWidget(){
    return Obx((){
      if(controller.videoData.value.content == null) return Container();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.wMin),
          SelectableText(
            controller.videoData.value.content??"",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),

          SizedBox(height: 6.wMin),

          SelectableText(
            controller.videoData.value.definition??"",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),

        ],
      );
    });
  }

  /// 帧图片列表
  Widget _buildFrameImageWidget(BuildContext context){
    return Obx((){
      bool isExpanded = controller.isFrameImageExpanded.value;
      List<VideoTaskEntityListFrames?> frames = controller.videoData.value.frames??[];
      return ManageCrossFadeTitleWidget(
        isExpanded: isExpanded,
        title: "帧信息 （${controller.videoData.value.frames?.length??0}帧）",
        onToggleExpand: controller.toggleFrameImageExpanded,
        firstChild: Container(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(bottom: 24.wMin),
            child: Row(
              spacing: 16.wMin,
              children: List.generate(frames.length, (index){
                return _buildFrameImageItemWidget(context, frames[index]);
              }),
            ),
          ),
        ), 
      );
    });
  }

  /// 帧信息图片item
  Widget _buildFrameImageItemWidget(BuildContext context, VideoTaskEntityListFrames? frame){

    int index = frame?.index??0;
    String name = "";
    if(index == 0){
      name = "首帧";
    }else if(index == -1){
      name = "尾帧";
    }else {
      name = "中间帧";
    }

    int? imageId = frame?.imageId;
    Color imageReviewColor = AppTheme.cSurfaceWarning.color;
    String imageReviewStatus = "待审核";
    if(imageId != null){
      imageReviewColor = AppTheme.cSurfaceSuccess.color;
      imageReviewStatus = "已审核";
    }
    if((frame?.frameImages??[]).isEmpty){
      imageReviewColor = AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.4);
      imageReviewStatus = "待生成";
    }

    String? imageUrl = frame?.frameImages?.firstWhereOrNull((e) => e?.option == true)?.imageUrl;

    return SizedBox(
      width: 500.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      
          Row(
            children: [
              SelectableText(
                "$name  index=$index",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(width: 10.wMin),
              ManageTagFS14Widget(
                tag: imageReviewStatus,
                bgColor: imageReviewColor,
              ),
            ],
          ),
      
          SizedBox(height: 6.wMin),
      
          SizedBox(
            height: 150.wMin,
            child: Row(
              children: [
                Container(
                  width: 150.wMin,
                  height: 150.wMin,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2.wMin, color: AppTheme.cSurfaceSuccess.color),
                    borderRadius: BorderRadius.circular(8.wMin),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedImageWidget(
                            imageUrl??"",
                            errorWidget: buildEmptyWidget(),
                            placeholder: buildEmptyWidget(),
                            borderRadius: BorderRadius.circular(8.wMin),
                          ),
                        ),
                        Visibility(
                          visible: imageUrl != null,
                          child: Positioned(
                            right: 8.wMin,
                            bottom: 8.wMin,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if(imageUrl == null) return;
                                ShowBigResourceDialog.showImage(
                                  context: context,
                                  imageUrls: [imageUrl],
                                );
                              },
                              child: Container(
                                width: 42.wMin,
                                height: 42.wMin,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8.wMin),
                                ),
                                child: Icon(
                                  Icons.zoom_out_map,
                                  color: Colors.white,
                                  size: 28.wMin,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.wMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        "图片提示词",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                      SizedBox(height: 4.wMin),
                      Expanded(
                        child: SelectableText(
                          frame?.prompt??"",
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      
        ],
      ),
    );
  }


  /// 视频信息区域
  Widget _buildVideoInfoWidget(){
    return Obx((){
      int videoEditStatus = controller.videoEditStatus.value;

      String startDuration = DateFormatUtil.millisecondsToSecondsWithDecimal(controller.videoCropStartDuration.value.inMilliseconds);
      String endDuration = DateFormatUtil.millisecondsToSecondsWithDecimal(controller.videoCropEndDuration.value.inMilliseconds);
      String diffDuration = DateFormatUtil.millisecondsToSecondsWithDecimal((controller.videoCropEndDuration.value.inMilliseconds - controller.videoCropStartDuration.value.inMilliseconds));


      return ManageCrossFadeTitleWidget(
        isExpanded: controller.isVideoInfoExpanded.value,
        title: "视频信息",
        onToggleExpand: controller.toggleVideoInfoExpanded,
        firstChild: Container(
          padding: EdgeInsets.only(bottom: 24.wMin),
          child: Column(
            children: [

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: videoEditStatus != 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond, 
                secondChild: _buildVideoInfoDurResWidget(), 
                firstChild: videoEditStatus == 1 ? _buildVideoInfoEditDurationWidget() : _buildVideoInfoEditResolutionWidget(), 
              ),

              Container(
                margin: EdgeInsets.only(top: 6.wMin),
                child: Row(
                  children: [
                    Text(
                      "裁剪区域：",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                    Text(
                      "${startDuration}s - ${endDuration}s",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextBrand.color,
                      ),
                    ),
                    Text(
                      " (有效 ${diffDuration}s)",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ), 
      );
    });
  }

  /// 视频信息 - 编辑时长区域
  Widget _buildVideoInfoEditDurationWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "编辑时长 (3-10秒)",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),

          SizedBox(height: 6.wMin),

          Wrap(
            spacing: 10.wMin,
            runSpacing: 10.wMin,
            children: List.generate(controller.editVideoDurationList.length, (index){
              return TapScaleWidget(
                onTap: () {
                  controller.selectEditVideoDuration(controller.editVideoDurationList[index]);
                },
                sclae: 1.03,
                child: Obx((){
                  bool isSelect = controller.editSelectVideoDuration.value == controller.editVideoDurationList[index];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color: AppTheme.cSurfaceTertiary.color,
                      border: Border.all(
                        width: 1.wMin,
                        color: isSelect ? AppTheme.cBorderBrand.color : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      "${controller.editVideoDurationList[index]}",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),
                  );
                })
              );
            }),
          ),

          SizedBox(height: 6.wMin),

          _buildVideoInfoCancelSaveWidget(
            onClean: () {
              controller.toggleVideoEditStatus(0);
            },
            onConfirm: () {
              controller.saveEditVideoDuration();
            },
          ),

        ],
      ),
    );
  }

  /// 视频信息 - 编辑分辨率区域
  Widget _buildVideoInfoEditResolutionWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "编辑分辨率",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),

          Text(
            "比例",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),

          Wrap(
            spacing: 10.wMin,
            runSpacing: 10.wMin,
            children: List.generate(controller.editVideoAspectRatioList.length, (index){
              VideoAspectRatioEnum aspectRatio = controller.editVideoAspectRatioList[index];
              return TapScaleWidget(
                onTap: () {
                  controller.selectEditVideoAspectRatio(aspectRatio);
                },
                sclae: 1.03,
                child: Obx((){
                  bool isSelect = controller.editSelectVideoAspectRatio.value == aspectRatio;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color: AppTheme.cSurfaceTertiary.color,
                      border: Border.all(
                        width: 1.wMin,
                        color: isSelect ? AppTheme.cBorderBrand.color : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      "${aspectRatio.width}:${aspectRatio.height} (${aspectRatio.name})",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color:  AppTheme.cTextTertiary.color,
                      ),
                    ),
                  );
                })
              );
            }),
          ),

          SizedBox(height: 6.wMin),

          Text(
            "清晰度",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),

          Wrap(
            spacing: 10.wMin,
            runSpacing: 10.wMin,
            children: List.generate(controller.editVideoQualityList.length, (index){
              VideoQualityEnum quality = controller.editVideoQualityList[index];
              return TapScaleWidget(
                onTap: () {
                  controller.selectEditVideoQuality(quality);
                },
                sclae: 1.03,
                child: Obx((){
                  bool isSelect = controller.editSelectVideoQualityValue.value == quality;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color:  AppTheme.cSurfaceTertiary.color,
                      border: Border.all(
                        width: 1.wMin,
                        color: isSelect ? AppTheme.cBorderBrand.color : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      "${quality.name} (${quality.value}p)",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color:  AppTheme.cTextTertiary.color,
                      ),
                    ),
                  );
                })
              );
            }),
          ),

          SizedBox(height: 6.wMin),

          Row(
            children: [

              Obx((){
                
                Size size = controller.calculateVideoAspectRatio();

                return _buildTextEditWidget(title: "计算分辨率：", value: "${size.width.toInt()} x ${size.height.toInt()}");  
              }),

              const Spacer(),
              _buildVideoInfoCancelSaveWidget(
                onClean: () {
                  controller.toggleVideoEditStatus(0);
                },
                onConfirm: () {
                  controller.saveEditVideoAspectRatio();
                },
              ),
            ],
          ),

        ],
      ),
    );
  }

  

  /// 视频信息 - 时长和分辨率区域
  Widget _buildVideoInfoDurResWidget(){

    /// 是否有编辑时长的权限
    bool durAuth = ManageAuthUtils.isAuth(ManageAuthCode.videoReviewPromptEdit);

    /// 是否有编辑分辨率的权限
    bool resAuth = ManageAuthUtils.isAnyAuth([ManageAuthCode.videoReviewTaskRetryVideoPrompt, ManageAuthCode.videoReviewTaskRetryVideoGenerate]);

    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(controller.videoData.value.status);
    bool editable = status == VideoTaskStatusEnum.finished || status == VideoTaskStatusEnum.abandoned; // 只有待审核或被放弃可以编辑

    return Row(
      children: [
        Expanded(
          child: _buildTextEditWidget(
            title: "时长：",
            value: "${controller.videoDuration.value}秒",
            onEdit: !durAuth || !editable ? null : () {
              controller.toggleVideoEditStatus(1);
            },
          ),
        ),
        Expanded(
          child: _buildTextEditWidget(
            title: "分辨率：",
            value: "${controller.videoWidth.value}x${controller.videoHeight.value}",
            onEdit: !resAuth || !editable ? null : () {
              controller.toggleVideoEditStatus(2);
            },
          ),
        ),
      ],
    );
  }


  /// 场景引导区域
  Widget _buildSceneGuideWidget(){
    return Obx((){
      bool isExpanded = controller.isSceneGuideExpanded.value;
      
      VideoTaskEntityListFrames? firstFrame = controller.videoData.value.frames?.first;
      if(firstFrame == null) return Container();

      bool isEdit = controller.isSceneGuideEditing.value;
      
      VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(controller.videoData.value.status);
      bool editable = status == VideoTaskStatusEnum.finished || status == VideoTaskStatusEnum.abandoned; // 只有待审核或被放弃可以编辑


      return ManageCrossFadeTitleWidget(
        isExpanded: isExpanded,
        title: "场景引导",
        onToggleExpand: controller.toggleSceneGuideExpanded,
        titleIcon: ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.videoReviewPromptEdit],
          child: Visibility(
            visible: !isEdit && editable,
            child: TapScaleWidget(
              onTap: (){
                controller.toggleSceneGuideEditing(true);
              },
              sclae: 1.1,
              child: Container(
                padding: EdgeInsets.all(4.wMin),
                color: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_edit.svg",
                  width: 20.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextBrand.color, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
        firstChild: Container(
          width: double.infinity,
          padding: EdgeInsets.only(bottom: 24.wMin),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isEdit ? CrossFadeState.showSecond : CrossFadeState.showFirst, 
            secondChild: _buildSceneGuideEditWidget(), 
            firstChild: _buildSceneGuideDefaultWidget(firstFrame), 
          ),
        ), 
      );
    });
  }

  /// 场景引导默认区域
  Widget _buildSceneGuideDefaultWidget(VideoTaskEntityListFrames? firstFrame){
    return Obx((){
      return Column(
        spacing: 4.wMin,
        children: [
          _buildTextRowWidget(
            title: "场景焦点：",
            value: controller.sceneFocusText.value,
          ),
          _buildTextRowWidget(
            title: "画面动态：",
            value: controller.suggestedMotionText.value,
          ),
          _buildTextRowWidget(
            title: "音频描述：",
            value: controller.suggestedAudioText.value,
          ),
        ],
      );
    });
  }


  /// 场景引导编辑区域
  Widget _buildSceneGuideEditWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        spacing: 6.wMin,
        children: [
          _buildTitleInputWidget(
            title: "场景焦点：",
            valueController: controller.sceneFocusController,
          ),
          _buildTitleInputWidget(
            title: "画面动态：",
            valueController: controller.suggestedMotionController,
          ),
          _buildTitleInputWidget(
            title: "音频描述：",
            valueController: controller.suggestedAudioController,
          ),
          _buildVideoInfoCancelSaveWidget(
            onClean: () {
              controller.toggleSceneGuideEditing(false);
            },
            onConfirm: () {
              controller.saveSceneGuideEdit();
            },
          ),
        ],
      ),
    );
  }


  /// 视频提示词模块
  Widget _buildVideoPromptWidget(BuildContext context){
    return Obx((){
      bool isExpanded = controller.isPromptExpanded.value;
      bool isEdit = controller.isPromptEditing.value;

      VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(controller.videoData.value.status);
      bool editable = status == VideoTaskStatusEnum.finished || status == VideoTaskStatusEnum.abandoned; // 只有待审核或被放弃可以编辑

      return ManageCrossFadeTitleWidget(
        isExpanded: isExpanded,
        title: "视频提示词",
        onToggleExpand: controller.togglePromptExpanded,
        titleIcon: ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.videoReviewPromptEdit],
          child: Visibility(
            visible: !isEdit && editable,
            child: TapScaleWidget(
              onTap: (){
                controller.togglePromptEditing(true);
              },
              sclae: 1.1,
              child: Container(
                padding: EdgeInsets.all(4.wMin),
                color: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_edit.svg",
                  width: 20.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextBrand.color, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
        firstChild: Container(
          width: double.infinity,
          padding: EdgeInsets.only(bottom: 24.wMin),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isEdit ? CrossFadeState.showSecond : CrossFadeState.showFirst, 
            secondChild: _buildVideoPromptEditWidget(context), 
            firstChild: SelectableText(
              controller.videoPromptText.value,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ), 

      );
    });
  }

  /// 视频提示词编辑模块
  Widget _buildVideoPromptEditWidget(BuildContext context){
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.wMin),
      borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
    );

    return SizedBox(
      width: double.infinity,
      child: Column(
        spacing: 6.wMin,
        children: [
          SizedBox(
            height: 300.wMin,
            child: TextField(
              controller: controller.videoPromptController,
              maxLines: 15,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                isDense: true,
                counterText: "",
                fillColor: AppTheme.cSurfaceSecondary.color,
                filled: true,
                border: border,
                focusedBorder: border,
                enabledBorder: border,
                disabledBorder: border,
                contentPadding: EdgeInsets.all(16.wMin),
              ),
              onTapOutside: (p0) {
                controller.savePromptOtherEdit(showLoading: false);
                FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
          ),
          _buildVideoInfoCancelSaveWidget(
            onClean: () {
              controller.togglePromptEditing(false);
            },
            onConfirm: () {
              controller.savePromptEdit();
            },
          ),
        ],
      ),
    );
  }



  /// 取消保存按钮
  Widget _buildVideoInfoCancelSaveWidget({
    void Function()? onClean,
    void Function()? onConfirm,
  }){

    return Row(
      spacing: 12.wMin,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ButtonWidget(
          text: "取消",
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceQuaternary.color,
          sclae: 1.03,
          fontSize: 16.wMin,
          fontColor: AppTheme.cTextTertiary.color,
          onTap: onClean,
        ),
        ButtonWidget(
          text: "保存",
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceInfo.color,
          fontSize: 16.wMin,
          sclae: 1.03,
          onTap: onConfirm,
        ),
      ],
    );
  }

  Widget _buildTitleInputWidget({
    required String title,
    required TextEditingController valueController,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          title,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(height: 2.wMin),
        CardInputWidget(
          controller: valueController,
          height: 46.wMin,
          valueStyle: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
          onClean: () {
            valueController.clear();
          },
          onTapOutside: (p0) {
            controller.savePromptOtherEdit(showLoading: false);
          },
        ),
      ],
    );
  }

  Widget _buildTextRowWidget({
    required String title,
    required String? value,
  }){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          title,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        Expanded(
          child: SelectableText(
            value??"",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextEditWidget({
    required String title,
    required String value,
    void Function()? onEdit,
  }){
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(controller.videoData.value.status);
    return Row(
      children: [
        SelectableText(
          title,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Visibility(
          visible: onEdit != null && status != VideoTaskStatusEnum.checked,// 已审核不能编辑
          child: TapScaleWidget(
            onTap: onEdit,
            sclae: 1.1,
            child: Container(
              padding: EdgeInsets.all(4.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset(
                "assets/svg/public/icon_edit.svg",
                width: 20.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextBrand.color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }


}