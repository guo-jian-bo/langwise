
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/stores/stores.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../controllers/manage_review_video_controller.dart';
import '../../../enums/video_task_status_enum.dart';


class ManageReviewItemWidget extends StatefulWidget {
  final VideoTaskEntityList data;
  final ManageReviewVideoController controller;
  const ManageReviewItemWidget({super.key, required this.data, required this.controller});

  @override
  State<ManageReviewItemWidget> createState() => _ManageReviewItemWidgetState();
}

class _ManageReviewItemWidgetState extends State<ManageReviewItemWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTagsWidget(),
          _buildContentWidget(),
          SizedBox(height: 8.wMin),
          _buildAudioInfoWidget(),
          SizedBox(height: 16.wMin),
          _buildImageListWidget(context),
          ManageReviewVideoListWidget(
            data: widget.data,
            controller: widget.controller,
          ),
          _buildFailedWidget(),
          _buildBottomButtonWidget(),



        ],
      ),
    );
  }

  Widget _buildTagsWidget(){
    ElementsCardColor? typeColor = StatusUtils.getElementsCardColor(widget.data.contentType);

    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);

    return SizedBox(
      height: 40.wMin,
      child: Row(
        spacing: 6.wMin,
        children: [
          ManageTagFS16Widget(
            tag: widget.data.typeTitle,
            bgColor: typeColor?.color1,
          ),
          Visibility(
            visible: widget.data.difficulty != null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 2.wMin,
              children: [
                StatusTagDifficultyWidget(
                  difficulty: widget.data.difficulty?.min,  
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
                  difficulty: widget.data.difficulty?.max,  
                  language: "en",
                ),
              ],
            ),
          ),
          Container(width: 1.wMin, height: 18.wMin, color: AppTheme.cBorderTertiary.color),
          ManageTagFS16Widget(
            tag: widget.data.styleTitle,
            bgColor: const Color(0xffF59E0B).withValues(alpha: 0.12),
            fontColor: const Color(0xffF59E0B),
          ),
          ManageTagFS16Widget(
            tag: widget.data.localeTitle,
            bgColor: const Color(0xffA855F7).withValues(alpha: 0.12),
            fontColor: const Color(0xffA855F7),
          ),
          Container(width: 1.wMin, height: 18.wMin, color: AppTheme.cBorderTertiary.color),
          ManageTagFS16Widget(
            tag: status.name,
            bgColor: status.bg.withValues(alpha: 0.12),
            fontColor: status.bg,
          ),
          ManageTagFS16Widget(
            tag: widget.data.mode,
            bgColor: AppTheme.cSurfaceTertiary.color,
            fontColor: AppTheme.cTextSecondary.color,
          ),
        ],
      ),
    );
  }


  Widget _buildContentWidget(){
    return SelectableText.rich(
      maxLines: 1,
      TextSpan(
        style: TextStyle(
          fontSize: 24.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: widget.data.content??""),
          TextSpan(
            text: "   ${widget.data.definition??""}",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioInfoWidget(){

    // 总帧数
    int totalFrames = widget.data.frames?.length??0;
    // 未完成的帧数
    int uncompletedFrames = widget.data.frames?.where((element) => element?.imageId == null).length??0;  
    // 已完成的帧数
    int completedFrames = widget.data.frames?.where((element) => element?.imageId != null).length??0;  

    // 首帧
    VideoTaskEntityListFrames? firstFrame;
    if((widget.data.frames??[]).isNotEmpty){
      firstFrame = widget.data.frames?.first;
    }

    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                Column(
                  children: [
                    Row(
                      children: [
                        _buildIconTextWidget(
                          svg: "assets/svg/manage/icon_duration.svg",
                          text: "${widget.data.duration??0}秒",
                        ),
                        SizedBox(width: 16.wMin),
                        _buildIconTextWidget(
                          svg: "assets/svg/manage/icon_frame.svg",
                          text: "$totalFrames帧",
                        ),
                        SizedBox(width: 16.wMin),
                
                        Visibility(
                          visible: completedFrames != totalFrames,
                          child: Row(
                            children: [
                              _buildIconTextWidget(
                                svg: "assets/svg/manage/icon_frame_radio.svg",
                                text: uncompletedFrames.toString(),
                              ),
                              Visibility(
                                visible: completedFrames > 0,
                                child: Container(
                                  margin: EdgeInsets.only(left: 4.wMin),
                                  child: _buildIconTextWidget(
                                    svg: "assets/svg/manage/icon_check_success.svg",
                                    text: completedFrames.toString(),
                                  ),
                                ),
                              ),
                              SelectableText(
                                "/ ${widget.data.frames?.length??0}帧",
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  color: AppTheme.cTextTertiary.color,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: completedFrames == totalFrames,
                          child: _buildIconTextWidget(
                            svg: "assets/svg/manage/icon_check_success.svg",
                            text: "全部$totalFrames帧已审核",
                            fontColor: AppTheme.cFeedbackSuccessText.color,
                          ),
                        ),
                
                      ],
                    ),
                    SizedBox(height: 12.wMin),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: AppTheme.cSurfaceSecondary.color,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10.wMin,
                        children: [
                          _buildRowTextWidget("场景焦点：", firstFrame?.semanticFocus??""),
                          _buildRowTextWidget("画面动态：", firstFrame?.suggestedMotion??""),
                          _buildRowTextWidget("音频描述：", firstFrame?.suggestedAudio??""),
                        ],
                      ),
                    ),
                  ],
                ),
                
                Visibility(
                  visible: widget.data.lines?.isNotEmpty??false,
                  child: Container(
                    margin: EdgeInsets.only(top: 12.wMin),
                    child: Row(
                      spacing: 8.wMin,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          "台词",
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: AppTheme.cTextSecondary.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: SelectableText(
                            widget.data.lines?.join(" / ")??"",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cTextBrand.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            
                SizedBox(height: 12.wMin),
            
                Row(
                  spacing: 8.wMin,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      "视频提示词",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        widget.data.videoPrompt??"",
                        maxLines: 1,
                        showCursor: true,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        
          _buildApprovedVideoWidget(),
        ],
      ),
    );
  }

  /// 已审核视频
  Widget _buildApprovedVideoWidget(){
    return Visibility(
      visible: widget.data.hasApprovedVideo == true,
      child: Container(
        margin: EdgeInsets.only(left: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "已审核视频",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SizedBox(height: 4.wMin),
            TapScaleWidget(
              onTap: () {
                widget.controller.taskReviewedVideo(context, widget.data);
              },
              sclae: 1.02,
              child: SizedBox(
                width: 160.wMin,
                height: 160.wMin,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.wMin),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                  
                      Positioned.fill(
                        child: CachedImageWidget(
                          widget.data.approvedVideo?.firstImageUrl??"",
                          errorWidget: buildEmptyWidget(),
                          placeholder: buildEmptyWidget(),
                        ),
                      ),
                          
                      Container(
                        width: 60.wMin,
                        height: 60.wMin,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32.wMin,
                              ),
                            ),
                            Positioned(
                              bottom: 2.wMin,
                              child: Text(
                                "${widget.data.approvedVideo?.duration}s",
                                style: TextStyle(
                                  fontSize: 14.wMin,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 视频 帧图片列表
  Widget _buildImageListWidget(BuildContext context){

    List<VideoTaskEntityListFrames?>? frames = widget.data.frames??[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "帧图片审核",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),

        SizedBox(height: 6.wMin),

        IntrinsicHeight(
          child: Row(
            children: [
              ...List.generate(frames.length, (index){
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 8.wMin),
                    child: ManageReviewImageListWidget(
                      data: widget.data,
                      frame: frames[index],
                      controller: widget.controller,
                    ),
                  ),
                );
              }),

              _buildUpdateFistLastButtonWidget(frames),

            ],
          ),
        ),

      ],
    );
  }

  Widget _buildUpdateFistLastButtonWidget(List<VideoTaskEntityListFrames?> frames){
    if(frames.length != 1) return Container();
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);
    if(status == VideoTaskStatusEnum.failed) return Container();
    
    return ManageAuthBoxWidget(
      authCodes: const [ManageAuthCode.adminVideoReviewTaskUpgradeToFirstLastFrameMode],
      child: Expanded(
        child: Container(
          margin: EdgeInsets.only(left: 8.wMin),
          child: TapScaleWidget(
            onTap: () {
              widget.controller.upgradeToFirstLastFrameMode(widget.data);
            },
            sclae: 1.005,
            child: DottedBorder(
              color: const Color(0xff8B5CF6),
              strokeWidth: 1.wMin,
              dashPattern: const [3, 3],
              borderType: BorderType.RRect,
              radius: Radius.circular(16.wMin),
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.wMin),
                  color: const Color(0xff8B5CF6).withValues(alpha: 0.2),
                ),
                child: Text(
                  "升级为首尾帧模式",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color(0xffA78BFA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// 失败模块
  Widget _buildFailedWidget(){
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);
    if(status != VideoTaskStatusEnum.failed) return Container();
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.wMin),
        color: AppTheme.cFeedbackErrorBackground.color,
        border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder.color),
      ),
      child: Row(
        children: [
          Text(
            "失败阶段：${widget.data.failedStage??''}",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cFeedbackErrorText.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 40.wMin),
          Text(
            "失败原因：${widget.data.failedReason??''}",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cFeedbackErrorText.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 底部审核按钮
  Widget _buildBottomButtonWidget(){
    
    // VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);


    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      padding: EdgeInsets.only(top: 10.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
      ),
      child: Row(
        children: [
          SelectableText(
            "任务UID：${widget.data.taskId??""}",
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

          Visibility(
            visible: UserStore.to.rolePermissions.value.isOfficial,
            child: Row(
              children: [
                SizedBox(width: 16.wMin),
                Container(width: 1.wMin, height: 20.wMin, color: AppTheme.cBorderPrimary.color),
                SizedBox(width: 16.wMin),
                SelectableText(
                  "生成者：${widget.data.userName??''}",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            
              ],
            ),
          ),

          SizedBox(width: 16.wMin),
          Container(width: 1.wMin, height: 20.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(width: 16.wMin),
          SelectableText(
            DateFormatUtil.formatStrtoStr(widget.data.started, newPattern: "yyyy-MM-dd HH:mm"),
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

          const Spacer(),

          _buildDeleteCreateButtonWidget(),
          _buildDeleteButtonWidget(),
          _buildGiveUpButtonWidget(),
          _buildDetailButtonWidget(),
          _buildCheckButtonWidget(),

        ],
      ),
    );
  }

  /// 删除并新建 按钮
  Widget _buildDeleteCreateButtonWidget(){
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);
    if(status == VideoTaskStatusEnum.checked || status == VideoTaskStatusEnum.failed){
      return Container(); // 已审核和失败状态 不显示删除任务按钮
    }
    return ManageAuthBoxWidget(
      authCodes: const [ManageAuthCode.videoReviewGenerateFrameStart, ManageAuthCode.videoReviewGenerateStartEndFrames],
      isAny: true,
      margin: EdgeInsets.only(right: 10.wMin),
      child: ButtonWidget(
        text: "删除并新建",
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        height: 40.wMin,
        borderRadius: 6.wMin,
        color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
        border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceError.color),
        fontColor: AppTheme.cSurfaceError.color,
        fontSize: 16.wMin,
        fontWeight: FontWeight.w500,
        sclae: 1.03,
        onTap: () {
          widget.controller.deleteCrtateTaskDialog(context, widget.data);
        },
      ),
    );
  }

  /// 删除任务按钮
  Widget _buildDeleteButtonWidget(){
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);
    if(status == VideoTaskStatusEnum.checked || status == VideoTaskStatusEnum.failed){
      return Container(); // 已审核和失败状态 不显示删除任务按钮
    }

    return ManageAuthBoxWidget(
      authCodes: const [ManageAuthCode.adminVideoReviewTaskDelete],
      child: ButtonWidget(
        text: "删除任务",
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        height: 40.wMin,
        borderRadius: 6.wMin,
        color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
        border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceError.color),
        fontColor: AppTheme.cSurfaceError.color,
        fontSize: 16.wMin,
        fontWeight: FontWeight.w500,
        sclae: 1.03,
        onTap: () {
          widget.controller.deleteTask(context, widget.data);
        },
      ),
    );
  }

  /// 放弃按钮
  Widget _buildGiveUpButtonWidget(){
    bool userIsVideoSuperReviewer = UserStore.to.rolePermissions.value.userIsVideoSuperReviewer;
    if(userIsVideoSuperReviewer) return Container(); // 高级审核人员不能放弃
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);
    if(status == VideoTaskStatusEnum.failed || status == VideoTaskStatusEnum.checked){
      return Container(); // 失败和已审核状态不显示放弃按钮
    }

    return Container(
      margin: EdgeInsets.only(left: 10.wMin),
      child: ButtonWidget(
        text: "放弃任务",
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        height: 40.wMin,
        borderRadius: 6.wMin,
        color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
        border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceError.color),
        fontColor: AppTheme.cSurfaceError.color,
        fontSize: 16.wMin,
        fontWeight: FontWeight.w500,
        sclae: 1.03,
        onTap: () {
          widget.controller.giveUpTask(context, widget.data);
        },
      ),
    );
  }

  /// 查看详情按钮
  Widget _buildDetailButtonWidget(){
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);
    if(status != VideoTaskStatusEnum.checked){
      return Container(); // 不是审核通过的状态 不显示查看详情按钮
    }

    if(widget.data.videos?.isEmpty??true) {
      return Container();
    }

    return ButtonWidget(
      text: "查看详情",
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      height: 40.wMin,
      borderRadius: 6.wMin,
      color: AppTheme.cSurfaceInfo.color.withValues(alpha: 0.2),
      border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceInfo.color),
      fontColor: AppTheme.cSurfaceInfo.color,
      fontSize: 16.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      onTap: () {
        VideoTaskEntityListVideos? video = widget.data.videos?.firstWhereOrNull((element) => element?.option == true);
        widget.controller.toVideoDetail(widget.data, video: video);
      },
    );
  }

  /// 审核视频按钮
  Widget _buildCheckButtonWidget(){
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);
    if(status != VideoTaskStatusEnum.finished && status != VideoTaskStatusEnum.abandoned){
      return Container(); // 不是待审核的状态 不显示审核视频按钮
    }

    if(widget.data.videos?.isEmpty??true) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.only(left: 10.wMin),
      child: ButtonWidget(
        text: "审核视频",
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        height: 40.wMin,
        borderRadius: 6.wMin,
        color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
        border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
        fontColor: AppTheme.cSurfaceSuccess.color,
        fontSize: 16.wMin,
        fontWeight: FontWeight.w500,
        sclae: 1.03,
        onTap: () {
          widget.controller.toVideoDetail(widget.data);
        },
      ),
    );
  }


  Widget _buildRowTextWidget(String name, String value){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          name,
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildIconTextWidget({
    required String svg,
    required String text,
    Color fontColor = AppTheme.cTextPrimary,
  }){
    return Row(
      children: [
        SvgPicture.asset(
          svg, 
          width: 20.wMin,
        ),
        SizedBox(width: 4.wMin),
        SelectableText(
          text, 
          style: TextStyle(
            fontSize: 16.wMin, 
            color: fontColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

}


class ManageReviewImageListWidget extends StatefulWidget {
  final VideoTaskEntityList data;
  final VideoTaskEntityListFrames? frame;
  final ManageReviewVideoController controller;
  const ManageReviewImageListWidget({super.key, required this.data, this.frame, required this.controller});

  @override
  State<ManageReviewImageListWidget> createState() => _ManageReviewImageListWidgetState();
}

class _ManageReviewImageListWidgetState extends State<ManageReviewImageListWidget> {

  /// 悬浮图片id
  int? hoverId;

  Future<void> showBigImages(String? imgUrl) async{
    List<VideoTaskEntityListFramesFrameImages?>? frameImages = widget.frame?.frameImages;
    List<String> images = frameImages?.map((e) => e?.imageUrl??"").toList()??[];
    if (images.isEmpty) return;
    final openIndex = images.indexOf(imgUrl??"");
    ShowBigResourceDialog.showImage(
      context: context,
      imageUrls: images,
      index: openIndex >= 0 ? openIndex : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        children: [
          _buildHeardWidget(),
          _buildPromptWidget(),
          _buildImageListWidget(),
          // const Spacer(),
          // _buildButtonsWidget(),
        ],
      ),
    );
  }

  /// 获取首帧是否已经审核
  bool getFistFrameIsReview(){
    List<VideoTaskEntityListFrames?> frames = widget.data.frames??[];
    // 检查首帧是否已经审核
    VideoTaskEntityListFrames? frame = frames.firstWhereOrNull((e) => e?.index == 0);
    if(frame == null) return false;
    return frame.imageId != null;
  }

  Widget _buildHeardWidget(){

    int? imageId = widget.frame?.imageId;
    Color imageReviewColor = AppTheme.cSurfaceWarning.color;
    String imageReviewStatus = "待审核";
    if(imageId != null){
      imageReviewColor = AppTheme.cSurfaceSuccess.color;
      imageReviewStatus = "已审核";
    }

    if((widget.frame?.frameImages??[]).isEmpty){
      imageReviewColor = AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.4);
      imageReviewStatus = "待生成";
    }

    int index = widget.frame?.index??0;

    String name = "";
    if(index == 0){
      name = "首帧";
    }else if(index == -1){
      name = "尾帧";
    }else {
      name = "中间帧";
    }

    return Row(
      children: [
        SelectableText(
          name,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(width: 8.wMin),
        SelectableText(
          "index=$index",
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(width: 10.wMin),
        ManageTagFS14Widget(
          tag: imageReviewStatus,
          bgColor: imageReviewColor,
        ),
        
        Visibility( // 如果是 尾帧 并且尾帧没有图片 并且首帧没有审核 显示提示
          visible: index == -1 && ((widget.frame?.frameImages??[]).isEmpty) && !getFistFrameIsReview(),
          child: Container(
            margin: EdgeInsets.only(left: 16.wMin),
            child: Text(
              "请先审核首帧",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cSurfaceWarning.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),

      ],
    );
  }
  

  /// 提示词
  Widget _buildPromptWidget(){

    if((widget.frame?.frameImages??[]).isEmpty) return Container();
    if(widget.frame?.imageTaskId == null) return Container();

    return Container(
      margin: EdgeInsets.only(top: 8.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              height: 34.wMin,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cSurfacePrimary.color,
              ),
              child: Text(
                widget.frame?.prompt??"",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          // ManageAuthBoxWidget(
          //   authCodes: const [ManageAuthCode.adminContentReviewPromptEdit],
          //   margin: EdgeInsets.only(left: 10.wMin),
          //   child: ButtonWidget(
          //     text: "编辑prompt",
          //     padding: EdgeInsets.symmetric(horizontal: 16.wMin),
          //     height: 34.wMin,
          //     borderRadius: 6.wMin,
          //     sclae: 1.03,
          //     color: AppTheme.cSurfaceWarning.color,
          //     fontSize: 16.wMin,
          //     onTap: () {
          //       widget.controller.editImagePrompt(context, widget.frame);
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }


  Widget _buildImageListWidget(){

    List<VideoTaskEntityListFramesFrameImages?> imageList = widget.frame?.frameImages??[];
    if(imageList.isEmpty) return Container();

    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);

    return Container(
      margin: EdgeInsets.only(top: 8.wMin),
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(imageList.length, (index){
                  return _buildImageItemWidget(image: imageList[index], index: index);
                }),
              ),
            ),
          ),
          SizedBox(width: 10.wMin),

          Visibility(
            visible: widget.frame?.imageTaskId != null && status != VideoTaskStatusEnum.failed,
            child: ButtonWidget(
              text: widget.frame?.imageId == null ? "去审核" : "重新审核",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              height: 34.wMin,
              borderRadius: 6.wMin,
              sclae: 1.03,
              color: (widget.frame?.imageId == null ? AppTheme.cSurfaceSuccess.color : AppTheme.cBgBrand.color).withValues(alpha: 0.2),
              border: Border.all(
                width: 1.wMin,
                color: (widget.frame?.imageId == null ? AppTheme.cSurfaceSuccess.color : AppTheme.cBgBrand.color),
              ),
              fontColor: (widget.frame?.imageId == null ? AppTheme.cSurfaceSuccess.color : AppTheme.cBgBrand.color),
              fontSize: 16.wMin,
              onTap: () {
                widget.controller.showReviewImage(context, widget.data, widget.frame, 0);
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildImageItemWidget({
    required VideoTaskEntityListFramesFrameImages? image,
    required int index,
  }){

    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);

    Color borderColor = Colors.transparent;
    if(image?.imageId == widget.frame?.imageId){
      borderColor = AppTheme.cSurfaceSuccess.color;
    }else if(hoverId == image?.imageId){
      borderColor = AppTheme.cBorderBrand.color;
    }

    return MouseRegion(
      onHover: (event){
        if(status == VideoTaskStatusEnum.failed) return;
        hoverId = image?.imageId;
        if(mounted) setState(() {});
      },
      onExit: (event){
        if(status == VideoTaskStatusEnum.failed) return;
        hoverId = null;
        if(mounted) setState(() {});
      },
      child: TapScaleWidget(
        sclae: 1.005,
        onTap: status == VideoTaskStatusEnum.failed || widget.frame?.imageTaskId == null ? null : () {
          widget.controller.showReviewImage(context, widget.data, widget.frame, index);
        },
        child: Container(
          width: 160.wMin,
          height: 160.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.wMin),
            border: Border.all(
              color: borderColor,
              width: 2.wMin,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.wMin),
            child: Stack(
              children: [
            
                Positioned.fill(
                  child: Image.network(
                    image?.imageUrl??"",
                    errorBuilder: (context, error, stackTrace) {
                      return buildEmptyWidget();
                    },
                  ),
                ),
            
                Visibility(
                  visible: image?.imageId == widget.frame?.imageId,
                  child: Positioned(
                    top: 4.wMin,
                    left: 4.wMin,
                    child: Container(
                      width: 42.wMin,
                      height: 42.wMin,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/public/check_box_green.svg",
                        width: 32.wMin,
                      ),
                    ),
                  ),
                ),
    
                // Visibility(
                //   visible: !isReviewed && !selected && status != VideoTaskStatusEnum.failed,
                //   child: Positioned(
                //     top: 4.wMin,
                //     left: 4.wMin,
                //     child: TapScaleWidget(
                //       onTap: () {
                //         // widget.frame?.selectedImageId = image?.imageId;
                //         // widget.controller.taskList.refresh();
                //       },
                //       sclae: 1,
                //       child: Container(
                //         width: 42.wMin,
                //         height: 42.wMin,
                //         alignment: Alignment.center,
                //         decoration: const BoxDecoration(
                //           shape: BoxShape.circle,
                //           color: Colors.black26,
                //         ),
                //         child: SvgPicture.asset(
                //           "assets/svg/manage/icon_unradio.svg",
                //           width: 32.wMin,
                //           colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
            
                Positioned(
                  right: 4.wMin,
                  bottom: 4.wMin,
                  child: IgnorePointer(
                    ignoring: !(status == VideoTaskStatusEnum.failed || widget.frame?.imageTaskId == null),
                    child: TapScaleWidget(
                      onTap: () {
                        showBigImages(image?.imageUrl);
                      },
                      child: Container(
                        width: 38.wMin,
                        height: 38.wMin,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8.wMin),
                        ),
                        child: Icon(
                          Icons.zoom_out_map,
                          color: Colors.white,
                          size: 24.wMin,
                        ),
                      ),
                    ),
                  ),
                ),
            
              ],
            ),
          ),
        ),
      ),
    );
  }


  // Widget _buildButtonsWidget(){

  //   VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);
  //   if(status == VideoTaskStatusEnum.checked || status == VideoTaskStatusEnum.failed) return Container();

  //   if((widget.frame?.frameImages??[]).isEmpty) return Container();
  //   if(widget.frame?.imageTaskId == null) return Container();

  //   if(widget.frame?.imageId != null){

  //     return Container(
  //       margin: EdgeInsets.only(top: 8.wMin),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: [
  //           ButtonWidget(
  //             text: "重新审核",
  //             padding: EdgeInsets.symmetric(horizontal: 12.wMin),
  //             height: 34.wMin,
  //             borderRadius: 6.wMin,
  //             sclae: 1.03,
  //             color: AppTheme.cBgBrand.color,
  //             fontSize: 16.wMin,
  //             onTap: () {
  //               widget.frame?.isReviewed = false;
  //               widget.controller.taskList.refresh();
  //             },
  //           ),
  //         ],
  //       ),
  //     );

  //   }

  //   bool isSelected = widget.frame?.selectedImageId != null;

  //   return Container(
  //     margin: EdgeInsets.only(top: 8.wMin),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         ManageAuthBoxWidget(
  //           authCodes: const [ManageAuthCode.adminVideoReviewTaskRetryImagePrompt],
  //           child: ButtonWidget(
  //             text: "重新生成提示词和图片",
  //             padding: EdgeInsets.symmetric(horizontal: 12.wMin),
  //             height: 34.wMin,
  //             borderRadius: 6.wMin,
  //             sclae: 1.03,
  //             color: const Color(0xff8B5CF6),
  //             fontSize: 16.wMin,
  //             onTap: () {
  //               widget.controller.reGenerateImagePrompt(widget.data, widget.frame);
  //             },
  //           ),
  //         ),
  //         ManageAuthBoxWidget(
  //           authCodes: const [ManageAuthCode.adminVideoReviewTaskRetryImageGenerate],
  //           margin: EdgeInsets.only(left: 10.wMin),
  //           child: ButtonWidget(
  //             text: "用提示词重新生成图片",
  //             padding: EdgeInsets.symmetric(horizontal: 12.wMin),
  //             height: 34.wMin,
  //             borderRadius: 6.wMin,
  //             sclae: 1.03,
  //             color: const Color(0xffF97316),
  //             fontSize: 16.wMin,
  //             onTap: () {
  //               widget.controller.reGenerateImageByPrompt(widget.data, widget.frame);
  //             },
  //           ),
  //         ),
  //         Container(
  //           margin: EdgeInsets.only(left: 10.wMin),
  //           child: ButtonWidget(
  //             text: "审核通过",
  //             padding: EdgeInsets.symmetric(horizontal: 12.wMin),
  //             height: 34.wMin,
  //             borderRadius: 6.wMin,
  //             sclae: 1.03,
  //             color: AppTheme.cSurfaceSuccess.color.withValues(alpha: isSelected ? 1 : 0.4),
  //             fontSize: 16.wMin,
  //             onTap: !isSelected ? null : () {
  //               widget.controller.imageReviewPass(widget.data, widget.frame);
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

}

class ManageReviewVideoListWidget extends StatefulWidget {
  final VideoTaskEntityList data;
  final ManageReviewVideoController controller;
  const ManageReviewVideoListWidget({super.key, required this.data, required this.controller});

  @override
  State<ManageReviewVideoListWidget> createState() => _ManageReviewVideoListWidgetState();
}

class _ManageReviewVideoListWidgetState extends State<ManageReviewVideoListWidget> {

  /// 悬浮的视频id
  int? hoverVideoId;

  @override
  Widget build(BuildContext context) {

    // VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);

    List<VideoTaskEntityListVideos?> videoList = widget.data.videos??[];
    

    if(videoList.isEmpty) return Container();

    return Column(
      children: [
        SizedBox(height: 10.wMin),
        Row(
          children: [
            Text(
              "生成的视频",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(height: 6.wMin),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(12.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTertiary.color,
            borderRadius: BorderRadius.circular(12.wMin),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8.wMin,
              children: List.generate(videoList.length, (index){
                return _buildVideoItemWidget(videoList[index]);
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItemWidget(VideoTaskEntityListVideos? video){

    List<VideoTaskEntityListFramesFrameImages?> images = widget.data.frames?.firstWhere((e) => e?.index == 0)?.frameImages??[];
    String? imageUrl = images.firstWhereOrNull((e) => e?.option == true)?.imageUrl;
    
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);

    Color borderColor = Colors.transparent;
    if(video?.option == true){
      borderColor = AppTheme.cFeedbackSuccessBorder.color;
    }else if(hoverVideoId == video?.videoId){
      borderColor = AppTheme.cBorderBrand.color;
    }

    return IgnorePointer(
      ignoring: status == VideoTaskStatusEnum.failed,
      child: MouseRegion(
        onHover: (event){
          if(status == VideoTaskStatusEnum.checked) return;
          hoverVideoId = video?.videoId;
          if(mounted) setState(() {});
        },
        onExit: (event){
          if(status == VideoTaskStatusEnum.checked) return;
          hoverVideoId = null;
          if(mounted) setState(() {});
        },
        child: TapScaleWidget(
          onTap: () {
            if(status == VideoTaskStatusEnum.checked && video?.option != true) return;
            widget.controller.toVideoDetail(widget.data, video: video);
          },
          sclae: 1.02,
          child: Container(
            width: 160.wMin,
            height: 160.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              border: Border.all(
                color: borderColor,
                width: 2.wMin,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.wMin),
              child: Stack(
                alignment: Alignment.center,
                children: [
              
                  Positioned.fill(
                    child: Image.network(
                      imageUrl??"",
                      errorBuilder: (context, error, stackTrace) {
                        return buildEmptyWidget();
                      },
                    ),
                  ),
      
                  Container(
                    width: 80.wMin,
                    height: 80.wMin,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 46.wMin,
                          ),
                        ),
                        Positioned(
                          bottom: 2.wMin,
                          child: Text(
                            "${video?.duration??0}s",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
