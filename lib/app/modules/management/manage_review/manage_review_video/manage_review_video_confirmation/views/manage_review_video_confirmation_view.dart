import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_review_video_confirmation_binding.dart';
import '../controllers/manage_review_video_confirmation_controller.dart';

class ManageReviewVideoConfirmationView extends GetView<ManageReviewVideoConfirmationController> {
  final String tagText;
  const ManageReviewVideoConfirmationView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_VIDEO_CONFIRMATION}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewVideoConfirmationView(tagText: tag),
      binding: ManageReviewVideoConfirmationBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_VIDEO_CONFIRMATION,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      showCollectButton: false,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            SizedBox(height: 10.wMin),
            
            Text(
              "是否覆盖已经审核通过的视频",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
        
            SizedBox(height: 10.wMin),
        
            Expanded(
              child: Row(
                spacing: 40.wMin,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOldWidget(),
                  _buildNewWidget(),
                ],
              ),
            ),
        
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10.wMin),
        
          ],
        ),
      ),
    );
  }

  Widget _buildOldWidget(){
    if(controller.approvedVideo?.videoUrl == null) return Container();
    return Column(
      children: [
    
        Container(
          padding: EdgeInsets.all(10.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfacePrimary.color,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "原审核通过视频",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.wMin),
            
              Center(
                child: SizedBox(
                  width: 700.wMin,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.wMin),
                    child: VideoEditWidget(
                      videoSize: Size(700.wMin, 700.wMin),
                      autoPlay: false,
                      videoUrl: controller.approvedVideo!.videoUrl!,
                      isMuted: controller.approvedVideo?.isMute??false,
                      trimStartTime: DateFormatUtil.secondsToDuration(controller.approvedVideo?.startSeconds??0),
                      trimEndTime: DateFormatUtil.secondsToDuration(controller.approvedVideo?.endSeconds??0),
                      disableEditing: true,
                      autoHideControls: !Platform.isAndroid && !Platform.isIOS,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.wMin),
        ButtonWidget(
          text: "沿用已有视频",
          height: 44.wMin,
          width: 700.wMin,
          borderRadius: 6.wMin,
          color: AppTheme.cFeedbackErrorBackground.color,
          fontColor: AppTheme.cFeedbackErrorText.color,
          fontSize: 18.wMin,
          fontWeight: FontWeight.w600,
          sclae: 1.005,
          onTap: () {
            controller.usingExistingVideos();
          },
        ),
    
      ],
    );
  }

  Widget _buildNewWidget(){
    if(controller.videoUrl == null) return Container();
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfacePrimary.color,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "本次审核视频",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.wMin),
              Center(
                child: SizedBox(
                  width: 700.wMin,
                  child: VideoEditWidget(
                    videoSize: Size(700.wMin, 700.wMin),
                    borderRadius: BorderRadius.circular(16.wMin),
                    autoPlay: false,
                    videoUrl: controller.videoUrl!,
                    isMuted: controller.isMute,
                    trimStartTime: Duration(milliseconds: controller.startSeconds??0),
                    trimEndTime: Duration(milliseconds: controller.endSeconds??0),
                    disableEditing: true,
                    autoHideControls: !Platform.isAndroid && !Platform.isIOS,
                  ),
                ),
              ),
            ],
          ),
        ),
    
        SizedBox(height: 20.wMin),
        ButtonWidget(
          text: "使用新视频，审核通过",
          height: 44.wMin,
          width: 700.wMin,
          borderRadius: 6.wMin,
          color: AppTheme.cFeedbackSuccessBackground.color,
          fontColor: AppTheme.cFeedbackSuccessText.color,
          fontSize: 18.wMin,
          fontWeight: FontWeight.w600,
          sclae: 1.005,
          onTap: () {
            controller.videoApprove();
          },
        ),
    
      ],
    );
  }

}
