import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../models/manage_review_audio_model.dart';
import '../bindings/manage_review_audio_history_binding.dart';
import '../controllers/manage_review_audio_history_controller.dart';

class ManageReviewAudioHistoryView extends GetView<ManageReviewAudioHistoryController> {
  final String tagText;
  const ManageReviewAudioHistoryView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_AUDIO_HISTORY}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewAudioHistoryView(tagText: tag),
      binding: ManageReviewAudioHistoryBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_AUDIO_HISTORY,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Column(
        children: [
          SizedBox(height: 10.wMin),
          _buildHeardWidget(),
          _buildAdministratorFilteringWidget(context),
          SizedBox(height: 10.wMin),
          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
          ),
          Expanded(child: _buildHistoryListWidget(context)),
          
        ],
      ),
    );
  }

  Widget _buildHeardWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        children: [

          Builder(
            builder: (context) {
              return TapScaleWidget(
                onTap: () {
                  controller.filterTime(context);
                },
                sclae: 1.02,
                child: Container(
                  height: 50.wMin,
                  padding: EdgeInsets.only(left: 16.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: AppTheme.cSurfaceSecondary.color,
                    border: Border.all(
                      color: AppTheme.cBorderPrimary.color,
                      width: 1.wMin,
                    ),
                  ),
                  child: Obx((){

                    String startDate = "";
                    String endDate = "";
                    
                    if(controller.startDate.value == null || controller.endDate.value == null){
                      startDate = "开始日期";
                      endDate = "结束日期";
                    }else{
                      startDate = DateFormatUtil.formatStr(controller.startDate.value!);
                      endDate = DateFormatUtil.formatStr(controller.endDate.value!);
                    }


                    return Row(
                    children: [
                      Text(
                        "$startDate ～ $endDate",
                          style: TextStyle(
                            color: AppTheme.cTextPrimary.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TapScaleWidget(
                          onTap: () {
                            controller.clearFilterTime();
                          },
                          sclae: 1.1,
                          child: Container(
                            width: 50.wMin,
                            height: 50.wMin,
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "assets/svg/public/x.svg",
                              width: 28.wMin,
                            ),
                          ),
                          
                        ),

                      ],
                    );
                  }),
                ),
              );
            },
          ),

          const Spacer(),
      
         Obx((){
          return PagerWidget(
            pageSize: controller.limit,
            dataCount: controller.totalCount.value,
            controller: controller.pagerController,
            activeColor: AppTheme.cTextPrimary.color,
            onPage: (page, pageSize) {
              controller.pagerCallback(page, pageSize);
            },
          );
         }),
      
        ],
      ),
    );
  }

  Widget _buildAdministratorFilteringWidget(BuildContext context){
    if(!controller.fromAdmin) return Container();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [


          Text(
            "审核员：",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

          Obx((){

            String? selectedAuditor = controller.auditorList.firstWhereOrNull((element) => element.userId == controller.selectedUserId.value)?.userName;

            return IconDropdownMenuWidget(
              sclae: 1.03,
              width: 200.wMin,
              textStyle: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
              ),
              items: List.generate(controller.auditorList.length, (index){
                return IconDropdownIconData<int?>(
                  title: controller.auditorList[index].userName,
                  value: controller.auditorList[index].userId,
                );
              }),
              onTap: (data, index) {
                controller.filterAuditor(data.value);
              },
              child: Container(
                height: 54.wMin,
                width: 200.wMin,
                padding: EdgeInsets.only(right: 10.wMin),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cSurfaceSecondary.color,
                  borderRadius: BorderRadius.circular(10.wMin),
                  border: Border.all(color: AppTheme.cBorderPrimary.color, width: 1.wMin),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          selectedAuditor??"",
                          style: TextStyle(
                            color: AppTheme.cTextPrimary.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/svg/manage/icon_arrow_down.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            );
          }),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.adminAudioReviewAuditStatistics],
            margin: EdgeInsets.only(left: 20.wMin),
            child: ButtonWidget(
              text: "查看统计",
              height: 50.wMin,
              width: 120.wMin,
              borderRadius: 10.wMin,
              color: const Color(0xff353E5C),
              fontColor: Colors.white,
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              sclae: 1.05,
              onTap: () {
                controller.toStatistics();
              },
            ),
          ),
      
          
      
        ],
      ),
    );
  }


  Widget _buildHistoryListWidget(BuildContext context){
    return Obx((){
      return ListView.separated(
        itemCount: controller.reviewList.length,
        padding: EdgeInsets.only(
          top: 16.wMin,
          bottom: 120.wMin + MediaQuery.of(context).padding.bottom,
          left: 40.wMin,
          right: 40.wMin,
        ),
        separatorBuilder: (context, index) {
          return SizedBox(height: 24.wMin);
        },
        itemBuilder: (context, index) {
          return _buildListItemWidget(context, controller.reviewList[index], index);
        },
      );
    });
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
          _buildTagWidget(data),
          SizedBox(height: 8.wMin),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildContentWidget(context, data)),
              _buildAudioListWidget(context, data),
            ],
          ),
          SizedBox(height: 8.wMin),
          _buildBottomWidget(context, data),
        ],
      ),
    );
  }

  Widget _buildTagWidget(ManageReviewAudioModel data){
    ElementsCardColor? typeColor = StatusUtils.getElementsCardColor(data.data.contentType);
    
    return Row(
      spacing: 8.wMin,
      children: [
        ManageTagFS16Widget(
          tag: data.data.contentType,
          bgColor: typeColor?.color1,
        ),
        StatusTagDifficultyWidget(
          difficulty: data.data.difficulty,  
          fontSize: 16.wMin,
          language: "en",
        ),
        Container(width: 1.wMin, height: 18.wMin, color: AppTheme.cBorderTertiary.color),

        ManageTagFS16Widget(
          tag: data.data.dialect,
          fontColor: AppTheme.cTextSecondary.color,
        ),

        const Spacer(),
        
        SelectableText(
          "审核时间：${DateFormatUtil.formatStrtoStr(data.data.checked, newPattern: "yyyy-MM-dd HH:mm")}  审核员：${data.data.userName??''}",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cSurfaceWarning.color,
          ),
        ),
      ],
    );
  }



  Widget _buildBottomWidget(BuildContext context, ManageReviewAudioModel data){
    
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

          // Container(
          //   margin: EdgeInsets.only(left: 12.wMin),
          //   child: ButtonWidget(
          //     text: "审核通过",
          //     padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          //     height: 40.wMin,
          //     borderRadius: 6.wMin,
          //     color: selectAudio ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceTertiary.color,
          //     fontSize: 16.wMin,
          //     fontWeight: FontWeight.w500,
          //     fontColor: selectAudio ? Colors.white : AppTheme.cTextPrimary.color,
          //     sclae: 1.05,
          //     onTap: () {
          //       controller.approveTask(data);
          //     },
          //   ),
          // ),

        ],
      ),
    );
  }


  Widget _buildContentWidget(BuildContext context, ManageReviewAudioModel data){
    ElementsCardType contentType = ElementsCardType.fromRawValue(data.data.contentType??"");

    if(contentType == ElementsCardType.word || contentType == ElementsCardType.phrase || contentType == ElementsCardType.sentence){
      return Text(
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

      return ClipRRect(
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
      );
    });
  }
  
}
