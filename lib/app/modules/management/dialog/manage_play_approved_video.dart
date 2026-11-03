import 'dart:io';

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

    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 800.wMin,
              child: _buildVideoWidget(),
            ),
      
            _buildButtonWidget(),
      
          ],
        ),
      ),
    );
    
  }

  Widget _buildButtonWidget(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ButtonWidget(
          text: "取消",
          color: AppTheme.cSurfaceSecondary.color,
          borderRadius: 6.wMin,
          width: 300.wMin,
          height: 50.wMin,
          fontSize: 18.wMin,
          fontColor: AppTheme.cTextPrimary.color,
          sclae: 1.03,
          onTap: () => Get.back(),
        ),
        SizedBox(width: 12.wMin),
        ButtonWidget(
          text: "沿用已有视频",
          color: AppTheme.cFeedbackErrorBackground.color,
          fontColor: AppTheme.cFeedbackErrorText.color,
          borderRadius: 6.wMin,
          width: 300.wMin,
          height: 50.wMin,
          fontSize: 18.wMin,
          sclae: 1.03,
          onTap: () async{
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

    return GestureDetector(
      onTap: (){},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.wMin),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary.color,
          ),
          child: VideoEditWidget(
            videoSize: Size(800.wMin, 800.wMin),
            borderRadius: BorderRadius.circular(24.wMin),
            videoUrl: videoData!.videoUrl!,
            isMuted: videoData?.isMute??false,
            trimStartTime: startSeconds,
            trimEndTime: endSeconds,
            disableEditing: true,
            autoHideControls: !Platform.isAndroid && !Platform.isIOS,
          ),
        ),
      ),
    );

  }

}