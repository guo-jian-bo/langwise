

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/stores/stores.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import '../../../../enums/video_task_status_enum.dart';
import '../controllers/manage_review_video_history_controller.dart';



class ManageVideoHistoryReviewItemWidget extends StatefulWidget {
  final VideoTaskEntityList data;
  final ManageReviewVideoHistoryController controller;
  const ManageVideoHistoryReviewItemWidget({super.key, required this.data, required this.controller});

  @override
  State<ManageVideoHistoryReviewItemWidget> createState() => _ManageVideoHistoryReviewItemWidgetState();
}

class _ManageVideoHistoryReviewItemWidgetState extends State<ManageVideoHistoryReviewItemWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
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
          ManageVideoHistoryReviewVideoListWidget(
            data: widget.data,
            controller: widget.controller,
          ),
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
          const Spacer(),

          // 审核信息
          SelectableText(
            "审核时间：${DateFormatUtil.formatStrtoStr(widget.data.checked, newPattern: "yyyy-MM-dd HH:mm")}  审核员：${widget.data.userName??''}",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cSurfaceWarning.color,
            ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  /// 视频 帧图片列表
  Widget _buildImageListWidget(BuildContext context){

    List<VideoTaskEntityListFrames?>? frames = widget.data.frames??[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "帧图片",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),

        SizedBox(height: 6.wMin),

        IntrinsicHeight(
          child: Row(
            spacing: 8.wMin,
            children: List.generate(frames.length, (index){
              return Expanded(
                child: ManageVideoHistoryReviewImageListWidget(
                  data: widget.data,
                  frame: frames[index],
                  controller: widget.controller,
                ),
              );
            }),
          ),
        ),

      ],
    );
  }

  /// 底部审核按钮
  Widget _buildBottomButtonWidget(){

    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
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

          _buildDetailButtonWidget(),

        ],
      ),
    );
  }

  /// 查看详情按钮
  Widget _buildDetailButtonWidget(){
    VideoTaskStatusEnum status = VideoTaskStatusEnum.fromValue(widget.data.status);
    if(status != VideoTaskStatusEnum.checked){
      return Container(); // 不是审核通过的状态 不显示查看详情按钮
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


class ManageVideoHistoryReviewImageListWidget extends StatefulWidget {
  final VideoTaskEntityList data;
  final VideoTaskEntityListFrames? frame;
  final ManageReviewVideoHistoryController controller;
  const ManageVideoHistoryReviewImageListWidget({super.key, required this.data, this.frame, required this.controller});

  @override
  State<ManageVideoHistoryReviewImageListWidget> createState() => _ManageVideoHistoryReviewImageListWidgetState();
}

class _ManageVideoHistoryReviewImageListWidgetState extends State<ManageVideoHistoryReviewImageListWidget> {

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
      width: double.infinity,
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
        ],
      ),
    );
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

      ],
    );
  }
  

  /// 提示词
  Widget _buildPromptWidget(){

    if((widget.frame?.frameImages??[]).isEmpty) return Container();

    return Container(
      margin: EdgeInsets.only(top: 8.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.wMin),
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
          //     height: 40.wMin,
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

    return Container(
      margin: EdgeInsets.only(top: 8.wMin),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(imageList.length, (index){
            return _buildImageItemWidget(image: imageList[index]);
          }),
        ),
      ),
    );
  }

  Widget _buildImageItemWidget({
    required VideoTaskEntityListFramesFrameImages? image,
  }){

    Color borderColor = Colors.transparent;
    if(image?.imageId == widget.frame?.imageId){
      borderColor = AppTheme.cSurfaceSuccess.color;
    }

    return Container(
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
              child: CachedImageWidget(
                image?.imageUrl??"",
                errorWidget: buildEmptyWidget(),
                placeholder: buildEmptyWidget(),
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

            Positioned(
              right: 6.wMin,
              bottom: 6.wMin,
              child: TapScaleWidget(
                onTap: () {
                  showBigImages(image?.imageUrl);
                },
                sclae: 1,
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
        
          ],
        ),
      ),
    );
  }


}

class ManageVideoHistoryReviewVideoListWidget extends StatefulWidget {
  final VideoTaskEntityList data;
  final ManageReviewVideoHistoryController controller;
  const ManageVideoHistoryReviewVideoListWidget({super.key, required this.data, required this.controller});

  @override
  State<ManageVideoHistoryReviewVideoListWidget> createState() => _ManageVideoHistoryReviewVideoListWidgetState();
}

class _ManageVideoHistoryReviewVideoListWidgetState extends State<ManageVideoHistoryReviewVideoListWidget> {

  @override
  Widget build(BuildContext context) {


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
    }

    return IgnorePointer(
      ignoring: status == VideoTaskStatusEnum.failed,
      child: TapScaleWidget(
        onTap: (status == VideoTaskStatusEnum.checked && video?.option != true) ? null : () {
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
                  child: CachedImageWidget(
                    imageUrl??"",
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildEmptyWidget(),
                  ),
                ),
      
              Visibility(
                visible: video?.option == true,
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
    );
  }

}
