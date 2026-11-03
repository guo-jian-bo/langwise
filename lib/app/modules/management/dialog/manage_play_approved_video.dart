import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../common/commons.dart';

class ManagePlayApprovedVideo{

  static Future<bool> show({
    required BuildContext context,
    required int videoTaskId,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManagePlayApprovedVideoWidget(videoTaskId: videoTaskId);
      },
    );

    return res??false;
  }

}


class ManagePlayApprovedVideoWidget extends StatefulWidget {
  final int videoTaskId;
  const ManagePlayApprovedVideoWidget({super.key, required this.videoTaskId});

  @override
  State<ManagePlayApprovedVideoWidget> createState() => _ManagePlayApprovedVideoWidgetState();
}

class _ManagePlayApprovedVideoWidgetState extends State<ManagePlayApprovedVideoWidget> {

  List<VideoTaskEntityListVideos> videoList = [];
  VideoTaskEntityListVideos? videoData;

  @override
  void initState() {
    super.initState();
    getApprovedVideo();
  }

  Future<void> getApprovedVideo() async{
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "videoTaskId": widget.videoTaskId,
      };
      List<VideoTaskEntityListVideos>? list = await LanguageUtil.sameTaskReviewedVideo(data: reqData);
      if(list == null) return;
      videoList = list;
      if(list.isEmpty) return;
      videoData = list.first;
      if(mounted) setState(() {});

    } finally{
      ToastUtils.hideLoading();
    }
  }
  

  @override
  Widget build(BuildContext context) {

    // return ManageDialogBoxWidget(
    //   title: "查看已审核视频",
    //   width: 1000.wMin,
    //   onConfirm: () => Get.back(),
    //   child: Container(
    //     margin: EdgeInsets.only(bottom: 10.wMin),
    //     width: 900.wMin,
    //     height: 900.wMin,
    //     child: AspectRatio(
    //       aspectRatio: 1,
    //       child: _buildVideoWidget(),
    //     ),
    //   ),
    // );

    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 980.wMin,
            height: 980.wMin,
            child: AspectRatio(
              aspectRatio: 1,
              child: _buildVideoWidget(),
            ),
          ),
          

          _buildButtonWidget(),

        ],
      ),
    );
    
  }

  Widget _buildButtonWidget(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ButtonWidget(
          text: "继续审核新视频",
          color: AppTheme.cSurfaceSecondary.color,
          borderRadius: 6.wMin,
          width: 288.wMin,
          height: 50.wMin,
          fontSize: 18.wMin,
          fontColor: AppTheme.cTextPrimary.color,
          sclae: 1.03,
          onTap: () => Get.back(),
        ),
        SizedBox(width: 12.wMin),
        ButtonWidget(
          text: "沿用已有视频",
          color: AppTheme.cSurfaceInfo.color,
          borderRadius: 6.wMin,
          width: 288.wMin,
          height: 50.wMin,
          fontSize: 18.wMin,
          sclae: 1.03,
          onTap: () async{

            bool askRes = await DeleteDialog.show(
              context: context, 
              title: "沿用已有视频",
              content: "沿用已有视频代表放弃此任务，您确定要放弃此任务吗？",
              confirmText: "确认放弃",
            );
            if(!askRes) return;

            Get.back(result: true);
          },
        ),
      ],
    );
  }


  Widget _buildVideoWidget(){
    if(videoData == null) return Container();
    if(videoData?.videoUrl == null) return Container();

    Duration? startSeconds;
    Duration? endSeconds;

    if(videoData?.startSeconds != null){
      startSeconds = DateFormatUtil.secondsToDuration(videoData?.startSeconds??0);
    }

    if(videoData?.endSeconds != null){
      endSeconds = DateFormatUtil.secondsToDuration(videoData?.endSeconds??0);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.wMin),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: VideoEditWidget(
          videoUrl: videoData!.videoUrl!,
          isMuted: videoData?.isMute??false,
          trimStartTime: startSeconds,
          trimEndTime: endSeconds,
          disableEditing: true,
        ),
      ),
    );

  }

}