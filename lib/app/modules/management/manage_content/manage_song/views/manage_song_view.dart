import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../dialog/dialogs.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_song_binding.dart';
import '../controllers/manage_song_controller.dart';

class ManageSongView extends GetView<ManageSongController> {
  final String tagText;
  const ManageSongView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SONG}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSongView(tagText: tag),
      binding: ManageSongBinding(tag: tag),
      routeName: Routes.MANAGE_SONG,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeardWidget(context),
              Expanded(child: _buildListWidget(context)),
            ],
          ),
          Positioned(
            right: 10.wMin,
            bottom: 200.wMin,
            child: ManageListToolButtonWidget(
              onSubmit: controller.getKnowledgeList,
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFilterWidget(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    
    return Obx((){
      Map<String, FilterConditionData> filterConditionDatas = {...controller.filterConditionDatas};
      Map<String, FilterInputData> filterInputDatas = {...controller.filterInputDatas};
      return FilterFloatWidget(
        width: 1400.wMin,
        conditions: filterConditionDatas,
        inputs: filterInputDatas,
        onChange: (datas) {
          controller.changeFilterConditionData(datas);
        },
        onSubmitted: () {
          controller.searchSubmitted();
        },

      );
    });
  }

  Widget _buildHeardWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        children: [
    
          const Spacer(),

          Obx((){
            return PagerWidget(
              dataCount: controller.totalCount.value,
              controller: controller.pagerController,
              visiblePageCount: 3,
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


  /// 列表
  Widget _buildListWidget(BuildContext context){
    return Obx((){
      return ListView.separated(
        padding: EdgeInsets.only(
          top: 24.wMin,
          left: 140.wMin,
          right: 140.wMin,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120.wMin,
        ),
        itemCount: controller.knowledgeList.length,
        separatorBuilder: (context, index) {
          return SizedBox(height: 16.wMin);
        },
        itemBuilder: (context, index) {
          return _buildCardWidget(context, controller.knowledgeList[index]);
        },
      );
    });
  }

  Widget _buildCardWidget(BuildContext context, ManageExpandModel<EnKnowledgeEntity> data){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.wMin),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _buildCardImageWidget(context, data),
                  SizedBox(width: 8.wMin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTagWidget(context, data),
                        SizedBox(height: 4.wMin),
                        _buildCardContentWidget(context, data),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildCardButtonsWidget(context, data),
        ],
      ),
    );
  }


  Widget _buildCardImageWidget(BuildContext context, ManageExpandModel<EnKnowledgeEntity> data){
    final ManageSettingController settingController = Get.find<ManageSettingController>();
    
    return Obx((){
      String? imageUrl = data.data.relationImage?.imageUrl;
      bool locked = data.data.relationImage?.locked == true;
      List<String> authCodes = [locked ? ManageAuthCode.contentReviewImageUnlock : ManageAuthCode.contentReviewImageLock];
      bool isNullId = data.data.relationImage?.uid == null;
      if(settingController.defaultResources.value == ResourceTypeEnum.video){
        imageUrl = data.data.relationVideo?.firstImageUrl;
        locked = data.data.relationVideo?.locked == true;
        authCodes = [locked ? ManageAuthCode.videoReviewVideoUnlock : ManageAuthCode.videoReviewVideoLock];
        isNullId = data.data.relationVideo?.uid == null;
      }

      return SizedBox(
        width: 160.wMin,
        height: 160.wMin,
        child: TapScaleWidget(
          onTap: () {
            if(settingController.defaultResources.value == ResourceTypeEnum.video){
              ShowBigResourceDialog.showVideo(
                context: context, 
                relationVideo: data.data.relationVideo,
              );
            }else{
              if(imageUrl == null) return;
              ShowBigResourceDialog.showImage(
                context: context, 
                imageUrls: [imageUrl],
              );
            }
            
          },
          sclae: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.wMin),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedImageWidget(
                    imageUrl ?? "",
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildLoadingWidget(),
                    fadeInDuration: Duration.zero,
                  ),

                  Visibility(
                    visible: settingController.defaultResources.value == ResourceTypeEnum.video,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
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
                                size: 42.wMin,
                              ),
                            ),
                            Positioned(
                              bottom: 2.wMin,
                              child: Text(
                                "${data.data.relationVideo?.duration??0}s",
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  Positioned(
                    right: 4.wMin,
                    bottom: 4.wMin,
                    child: Visibility(
                      visible: !isNullId,
                      child: ManageAuthBoxWidget(
                        authCodes: authCodes,
                        child: TapScaleWidget(
                          onTap: () {
                            if(locked){
                              if(settingController.defaultResources.value == ResourceTypeEnum.image){
                                controller.cancelFinalDraftImage(context, data.data);
                              }else{
                                controller.cancelFinalDraftVideo(context, data.data.relationVideo);
                              }
                            }else{
                              if(settingController.defaultResources.value == ResourceTypeEnum.image){
                                controller.finalDraftImage(data.data);
                              }else{
                                controller.finalDraftVideo(data.data.relationVideo);
                              }
                            }
                          },
                          sclae: 1.1,
                          child: Container(
                            width: 36.wMin,
                            height: 36.wMin,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.wMin),
                              color: AppTheme.cInverseOverlay2.color,
                              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                            ),
                            child: SvgPicture.asset(
                              locked ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                              width: 24.wMin,
                            ),
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
    });
  }

    /// 语义标签部分
  Widget _buildTagWidget(BuildContext context, ManageExpandModel<EnKnowledgeEntity> data){
    return Row(
      spacing: 6.wMin,
      children: [
        Visibility(
          visible: data.data.difficulty != null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4.wMin,
            children: [
              StatusTagDifficultyWidget(
                difficulty: data.data.difficulty?.min,
                language: controller.languageCode,
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
                difficulty: data.data.difficulty?.max,
                language: controller.languageCode,
              ),
            ],
          ),
        ),

        ManageTagFS14Widget(
          tag: "uid: ${data.data.uid??''}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        ManageTagFS14Widget(
          tag: "主题: ${data.data.theme??''}",
          bgColor: const Color(0xff2388FF).withValues(alpha: 0.2),
          fontColor: const Color(0xff2388FF),
        ),
        ManageTagFS14Widget(
          tag: "风格: ${data.data.genre??''}",
          bgColor: const Color(0xff17C964).withValues(alpha: 0.2),
          fontColor: const Color(0xff17C964),
        ),
        ManageTagFS14Widget(
          tag: "字数: ${data.data.wordCount??0}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        ManageTagFS14Widget(
          tag: "课程: ${data.data.inCourseCnt??''}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        ManageTagFS14Widget(
          tag: "创建日期: ${DateFormatUtil.formatStrtoStr(data.data.created)}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        ManageTagFS14Widget(
          tag: "修改日期: ${DateFormatUtil.formatStrtoStr(data.data.updated)}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        const Spacer(),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.enSongEdit, ManageAuthCode.enSongDelete],
          isAny: true,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceTertiary.color,
              borderRadius: BorderRadius.circular(6.wMin),
            ),
            child: Row(
              children: [
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.enTextEdit],
                  child: ListingAndDelistingWidget(
                    value: data.data.isNormal,
                    onChange: (){
                      controller.onListingAndDelisting(context, data);
                    },
                  ),
                ),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.enSongEdit],
                  child: TapScaleWidget(
                    onTap: () {
                      controller.editKnowledge(context, data);
                    },
                    sclae: 1.1,
                    borderRadius: 8.wMin,
                    backColor: AppTheme.cSurfaceTertiary.color,
                    child: Container(
                      width: 40.wMin,
                      height: 40.wMin,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "assets/svg/manage/icon_edit.svg",
                        width: 24.wMin,
                        colorFilter: ColorFilter.mode(
                          AppTheme.cTextTertiary.color,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
            
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.enSongDelete],
                  margin: EdgeInsets.only(left: 8.wMin),
                  child: TapScaleWidget(
                    onTap: () {
                      controller.deleteKnowledge(context, data);
                    },
                    sclae: 1.1,
                    borderRadius: 8.wMin,
                    backColor: AppTheme.cSurfaceTertiary.color,
                    child: Container(
                      width: 40.wMin,
                      height: 40.wMin,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_delete.svg",
                        width: 24.wMin,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }


  /// 内容
  Widget _buildCardContentWidget(BuildContext context, ManageExpandModel<EnKnowledgeEntity> data){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SelectableText(
          data.data.title??"",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),

        SizedBox(height: 4.wMin),

        SelectableText(
          data.data.content??"",
          maxLines: 3,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        
      ],
    );
  }

  Widget _buildCardButtonsWidget(BuildContext context, ManageExpandModel<EnKnowledgeEntity> data){
    final ManageSettingController settingController = Get.find<ManageSettingController>();

    int knowledgeCnt = 0;
    data.data.contentKnowledgeStatistics?.contentKnowledge?.forEach((element) {
      knowledgeCnt += element?.total??0;
    });

    bool inCourse = (data.data.inCourseCnt??0) > 0;

    List<EnKnowledgeEntityAudioExpressionList?> audioExpressionList = data.data.audioExpressionList??[];
    // 音频数量
    int audioExpressionListAudio = audioExpressionList.where((e) => e?.published == true).length;
    /// 字幕数量
    int audioExpressionListSubtitle = audioExpressionList.where((e) => e?.assPublished == 1).length;


    return Obx((){
      return Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfacePrimary.color,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.wMin)),
          border: Border(top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color)),
        ),
        child: Row(
          children: [
            Visibility(
              visible: settingController.defaultResources.value == ResourceTypeEnum.image,
              child: ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.enContentSemanticList, ManageAuthCode.adminContentReviewKnowledgeImages],
                child: _buildActionItemWidget(
                  text: "图片",
                  onTap: () {
                    controller.onKnowledgeImage(data.data);
                  },
                ),
              ),
            ),

            Visibility(
              visible: settingController.defaultResources.value == ResourceTypeEnum.video,
              child: ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.enContentSemanticList, ManageAuthCode.videoReviewKnowledgeVideos],
                child: _buildActionItemWidget(
                  text: "视频",
                  onTap: () {
                    controller.onKnowledgeVideo(data.data);
                  },
                ),
              ),
            ),

            ManageAuthBoxWidget(
              authCodes: const [
                ManageAuthCode.enContentSemanticList, 
                ManageAuthCode.exerciseTypeList,
                ManageAuthCode.exercisePage,
              ],
              margin: EdgeInsets.only(left: 12.wMin),
              child: _buildActionItemWidget(
                text: "题目",
                onTap: () {
                  controller.onKnowledgeExercises(data.data);
                },
              ),
            ),
            
            const Spacer(),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.enContentKnowledgeList],
              child: _buildActionItemWidget(
                text: "核心知识点($knowledgeCnt)",
                onTap: () {
                  controller.onKnowledgeCore(context, data);
                },
                bgColor: knowledgeCnt > 0 ? AppTheme.cFeedbackSuccessBackground.color : null,
                fontColor: knowledgeCnt > 0 ? AppTheme.cFeedbackSuccessText.color : null,
              ),
            ),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.unitKnowledgeCourseInfos],
              margin: EdgeInsets.only(left: 12.wMin),
              child: _buildActionItemWidget(
                text: "引用(${data.data.inCourseCnt??'0'})",
                onTap: () {
                  controller.onKnowledgeQuote(data.data);
                },
                bgColor: inCourse ? AppTheme.cFeedbackSuccessBackground.color : null,
                fontColor: inCourse ? AppTheme.cFeedbackSuccessText.color : null,
              ),
            ),
            SizedBox(width: 12.wMin),
            _buildActionItemWidget(
              text: "音频 $audioExpressionListAudio/${audioExpressionList.length}",
              onTap: () async{
                EnKnowledgeEntityAudioExpressionList? result = await ManageKnowledgeAudioListDialg.showAudioSubtitleList(
                  context: context,
                  data: data.data,
                );
                if(result == null) return;
                controller.jumpToAudioManage(data.data, result);
              },
              bgColor: audioExpressionListAudio == 0 ? AppTheme.cSurfaceTertiary.color : AppTheme.cFeedbackSuccessBackground.color,
              fontColor: audioExpressionListAudio == 0 ?  AppTheme.cTextTertiary.color : AppTheme.cFeedbackSuccessText.color,
            ),
            SizedBox(width: 12.wMin),
            _buildActionItemWidget(
              text: "字幕 $audioExpressionListSubtitle/${audioExpressionList.length}",
              onTap: () async{
                EnKnowledgeEntityAudioExpressionList? result = await ManageKnowledgeAudioListDialg.showAudioSubtitleList(
                  context: context,
                  data: data.data,
                );
                if(result == null) return;
                controller.jumpToAudioManage(data.data, result);
              },
              bgColor: audioExpressionListSubtitle == 0 ? AppTheme.cSurfaceTertiary.color : AppTheme.cFeedbackSuccessBackground.color,
              fontColor: audioExpressionListSubtitle == 0 ?  AppTheme.cTextTertiary.color : AppTheme.cFeedbackSuccessText.color,
            ),

          ],
        ),
      );
    });
  }

  Widget _buildActionItemWidget({
    required String text,
    void Function()? onTap,
    Color? bgColor,
    Color? fontColor,
  }){
    return SizedBox(
      width: 150.wMin,
      child: TapScaleWidget(
        onTap: onTap,
        sclae: 1.03,
        child: Container(
          height: 40.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: bgColor??AppTheme.cSurfaceSecondary.color,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.wMin,
              color: fontColor??AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

}