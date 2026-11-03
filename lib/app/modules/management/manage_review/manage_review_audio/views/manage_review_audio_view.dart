import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/stores/stores.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_review_audio_binding.dart';
import '../controllers/manage_review_audio_controller.dart';
import '../models/manage_review_audio_model.dart';

class ManageReviewAudioView extends GetView<ManageReviewAudioController> {
  final String tagText;
  const ManageReviewAudioView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_AUDIO}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewAudioView(tagText: tag),
      binding: ManageReviewAudioBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_AUDIO,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Column(
        children: [
          _buildHeardWidget(),
          Expanded(child: _buildListWidget(context)),
        ],
      ),
    );
  }

  /// 头部
  Widget _buildHeardWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 6.wMin),
      color: AppTheme.cSurfaceSecondary.color,
      child: Row(
        children: [
          const Spacer(),
          Obx((){
            return SelectableText(
              "${controller.taskList.length}个待审核",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cSurfaceWarning.color,
              ),
            );
          }),

          SizedBox(width: 16.wMin),

          ManageButton(
            text: "审核历史",
            height: 50.wMin,
            padding: EdgeInsets.symmetric(horizontal: 20.wMin),
            color: const Color(0xff353E5C),
            borderColor: Colors.transparent,
            sclae: 1.03,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            onTap: () {
              controller.toReviewHistory(false);
            },
          ),
      
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.adminAudioReviewAuditHistory],
            margin: EdgeInsets.only(left: 16.wMin),
            child: ManageButton(
              text: "管理员",
              height: 50.wMin,
              padding: EdgeInsets.symmetric(horizontal: 20.wMin),
              color: const Color(0xff353E5C),
              borderColor: Colors.transparent,
              sclae: 1.03,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              onTap: () {
                controller.toReviewHistory(true);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildListWidget(BuildContext context){

    return Obx((){
      if(controller.loadStatus.value == -1){
        return Container();
      }
      if(controller.taskList.isEmpty){
        return _buildEmptyWidget(context);
      }
      return ListView.separated(
        itemCount: controller.taskList.length,
        padding: EdgeInsets.all(40.wMin),
        separatorBuilder: (context, index) {
          return SizedBox(height: 16.wMin);
        },
        itemBuilder: (context, index) {
          return _buildListItemWidget(context, controller.taskList[index], index);
        },
      );
    });

  }

  Widget _buildEmptyWidget(BuildContext context){
    if(controller.isSubConditionQuery.value){
      return const NotDataWidget(
        message: "暂无任务",
      );
    }
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/svg/public/not_data.svg",
            width: 200.wMin,
          ),
          Text(
            "没有待审核的音频",
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "所有一拼都已审核完成",
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 50.wMin),
          ButtonWidget(
            text: "再审核一批",
            height: 58.wMin,
            width: 180.wMin,
            borderRadius: 6.wMin,
            color: AppTheme.cSurfaceBrand.color,
            sclae: 1.03,
            fontSize: 24.wMin,
            fontColor: Colors.white,
            onTap: () {
              controller.getAssTaskAnotherBatch();
            },
            
          ),
        ],
      ),
    );

  }


  Widget _buildListItemWidget(BuildContext context, ManageReviewAudioModel data, int index){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTagWidget(context, data),
                    SizedBox(height: 8.wMin),
                    _buildContentWidget(context, data),
                  ],
                ),
              ),
              _buildAudioListWidget(context, data),
            ],
          ),
          
          SizedBox(height: 8.wMin),
          _buildBottomWidget(context, data),
        ],
      ),
    );
  }

  Widget _buildTagWidget(BuildContext context, ManageReviewAudioModel data){
    ElementsCardColor? typeColor = StatusUtils.getElementsCardColor(data.data.contentType);

    ElementsCardType contentType = ElementsCardType.fromRawValue(data.data.contentType??"");
    
    return Row(
      children: [
        ManageTagFS16Widget(
          tag: data.data.contentType,
          bgColor: typeColor?.color1??AppTheme.cSurfaceQuaternary.color,
        ),
        Visibility(
          visible: data.data.difficulty != null,
          child: Container(
            margin: EdgeInsets.only(left: 8.wMin),
            child: StatusTagDifficultyWidget(
              difficulty: data.data.difficulty,  
              fontSize: 16.wMin,
              language: "en",
            ),
          ),
        ),
        SizedBox(width: 8.wMin),
        Container(width: 1.wMin, height: 18.wMin, color: AppTheme.cBorderTertiary.color),
        SizedBox(width: 8.wMin),
        ManageTagFS16Widget(
          tag: data.data.dialect,
          fontColor: AppTheme.cTextSecondary.color,
        ),

        const Spacer(),

        Visibility(
          visible: contentType == ElementsCardType.song || contentType == ElementsCardType.reveal,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.adminAudioReviewTaskRetryPromptGenerate],
            child: ButtonWidget(
              text: "查看提示词",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceTertiary.color,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              onTap: () {
                controller.viewPrompt(data, context);
              },
            ),
          ),
        ),

        Visibility(
          visible: data.data.hasPublishedAudio == true,
          child: Container(
            margin: EdgeInsets.only(left: 16.wMin),
            child: ButtonWidget(
              text: "播放已有音频",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceTertiary.color,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 8.wMin),
                width: 32.wMin,
                height: 32.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cSurfaceQuaternary.color,
                ),
                child: Obx((){
                  return Icon(
                    controller.audioPlaying.value && data.publishedAudioPlay ? Icons.pause : Icons.play_arrow,
                    size: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                  );
                }),
              ),
              onTap: () {
                controller.playPublishedAudio(data);
              },
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildBottomWidget(BuildContext context, ManageReviewAudioModel data){
    bool selectAudio = data.selectAudioId != null;

    ElementsCardType contentType = ElementsCardType.fromRawValue(data.data.contentType??"");
    
    return Container(
      padding: EdgeInsets.only(top: 16.wMin),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color)),
      ),
      child: Row(
        children: [

          SelectableText(
            "任务UID：${data.data.taskId??''}",
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 8.wMin),
          Container(width: 1.wMin, height: 20.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(width: 8.wMin),
          SelectableText(
            DateFormatUtil.formatStrtoStr(data.data.started, newPattern: "yyyy-MM-dd HH:mm"),
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

          const Spacer(),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.adminAudioReviewTaskDelete],
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
              sclae: 1.05,
              onTap: () {
                controller.deleteTask(context, data);
              },
            ),
          ),
          Visibility(
            visible: !UserStore.to.rolePermissions.value.userIsAudioSuperReviewer, // 高级审核员不允许放弃
            child: Container(
              margin: EdgeInsets.only(left: 12.wMin),
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
                sclae: 1.05,
                onTap: () {
                  controller.abandonTask(data);
                },
              ),
            ),
          ),

          Visibility(
            visible: contentType == ElementsCardType.song || contentType == ElementsCardType.reveal,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.adminAudioReviewTaskRetryPromptRegenerate],
              margin: EdgeInsets.only(left: 12.wMin),
              child: ButtonWidget(
                text: "重新生成提示词和音频",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: const Color(0xff8B5CF6).withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: const Color(0xff8B5CF6)),
                fontColor: const Color(0xff8B5CF6),
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.05,
                onTap: () {
                  controller.audioPromptRegenerate(data);
                },
              ),
            ),
          ),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.adminAudioReviewTaskRetryPromptGenerate],
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: contentType == ElementsCardType.song || contentType == ElementsCardType.reveal ? "用提示词重新生成音频" : "重新生成音频",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color),
              fontColor: AppTheme.cSurfaceWarning.color,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.05,
              onTap: () {
                controller.audioPromptGenerate(data);
              },
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "审核通过",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: (selectAudio ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color).withValues(alpha: 0.2),
              border: Border.all(
                width: 1.wMin, 
                color: selectAudio ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color,
              ),
              fontColor: selectAudio ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.05,
              onTap: () {
                controller.approveTask(data);
              },
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildContentWidget(BuildContext context, ManageReviewAudioModel data){
    ElementsCardType contentType = ElementsCardType.fromRawValue(data.data.contentType??"");

    if(contentType == ElementsCardType.word || contentType == ElementsCardType.phrase || contentType == ElementsCardType.sentence){
      return SelectableText(
        data.data.content ?? "",
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
          letterSpacing: 0.6.wMin,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: data.data.title != null,
          child: Text(
            data.data.title ??"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),

        Visibility(
          visible: data.data.content != null,
          child: Text(
            data.data.content ??"",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
              letterSpacing: 0.6.wMin,
            ),
          ),
        ),

      ],
    );
  }


  /// 音频列表
  Widget _buildAudioListWidget(BuildContext context, ManageReviewAudioModel data){

    List<AudioReviewEntityListAudios?> audios = data.data.audios??[];

    return Container(
      width: 500.wMin,
      margin: EdgeInsets.only(left: 12.wMin),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
      ),
      child: Column(
        spacing: 8.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(audios.length, (index){
          return _buildAudioListItemWidget(context, data, audios[index], index);
        }),
      ),
    );
  }

  Widget _buildAudioListItemWidget(BuildContext context, ManageReviewAudioModel data, AudioReviewEntityListAudios? audio, int index){

    bool selectAudio = data.selectAudioId == audio?.audioId;
    bool playAudio = data.playAudioId == audio?.audioId;
    Duration duration = DateFormatUtil.secondsToDuration(audio?.duration??0);

    return Obx((){

      String positionStr = "0.00";
      Duration audioPosition = controller.audioPosition.value;
      bool currentPlaying = false;
      double progress = 0;
      if(playAudio){
        positionStr = DateFormatUtil.millisecondsToSecondsWithDecimal(audioPosition.inMilliseconds);
        currentPlaying = controller.audioPlaying.value;
        if(duration.inMilliseconds != 0){
          progress = audioPosition.inMilliseconds / duration.inMilliseconds;
        }
      }

      return TapScaleWidget(
        onTap: () {
          controller.selectAudio(data, audio);
        },
        sclae: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.wMin),
          child: Container(
            height: 48.wMin,
            color: AppTheme.cSurfaceTertiary.color,
            child: Container(
              color: selectAudio ? AppTheme.cFeedbackInfoBackground.color : Colors.transparent,
              child: Column(
                children: [
                  
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(4.wMin),
                      child: Row(
                        children: [
                    
                          SizedBox(
                            width: 100.wMin,
                            child: Text(
                              "音频${index + 1}",
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: AppTheme.cTextPrimary.color,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                    
                          const Spacer(),
                    
                          Container(
                            height: 38.wMin,
                            constraints: BoxConstraints(
                              minWidth: 110.wMin,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.wMin),
                              color: AppTheme.cSurfaceQuaternary.color,
                            ),
                            child: Text(
                              "$positionStr / ${audio?.duration??0}",
                              style: TextStyle(
                                fontSize: 14.wMin,
                                color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                    
                          SizedBox(width: 34.wMin),
                    
                          TapScaleWidget(
                            onTap: () {
                              controller.playAudio(data, audio);
                            },
                            sclae: 1.03,
                            child: Container(
                              width: 38.wMin,
                              height: 38.wMin,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectAudio ? AppTheme.cSurfaceInfo.color : AppTheme.cSurfaceQuaternary.color,
                              ),
                              child: Icon(
                                currentPlaying ? Icons.pause : Icons.play_arrow,
                                size: 24.wMin,
                                color: selectAudio ? Colors.white : AppTheme.cTextPrimary.color,
                              ),
                            ),
                          ),
                    
                        ],
                      ),
                    ),
                  ),
                    
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth;

                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 1.wMin,
                          width: maxWidth * progress.clamp(0, 1.0),
                          color: playAudio ? AppTheme.cFeedbackInfoBorder.color : AppTheme.cBorderTertiary.color,
                        ),
                      );
                    },
                  ),
                    
                ],
              ),
            ),
          ),
        ),
      );
    });
  }


}
