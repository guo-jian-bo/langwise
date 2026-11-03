
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../dialog/dialogs.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_sentence_binding.dart';
import '../controllers/manage_sentence_controller.dart';

class ManageSentenceView extends GetView<ManageSentenceController> {
  final String tagText;
  const ManageSentenceView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SENTENCE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentenceView(tagText: tag),
      binding: ManageSentenceBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Column(
        children: [
          _buildHeardWidget(context),
          Expanded(child: _buildListWidget(context)),
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
        width: 1500.wMin,
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
      
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enWordMatchDetail],
            child: ButtonWidget(
              text: "创建句子",
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
              borderRadius: 6.wMin,
              color: Colors.transparent,
              fontColor: AppTheme.cTextSecondary.color,
              tapColor: AppTheme.cTextSecondary.color.withValues(alpha: 0.1),
              sclae: 1.05,
              fontSize: 18.wMin,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 4.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_add.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextQuaternary.color, BlendMode.srcIn),
                ),
              ),
              onTap: (){
                controller.showCreateSentence(context);
              },
            ),
          ),

          SizedBox(width: 16.wMin),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enContentKnowledgeCreateHistory],
            child: ButtonWidget(
              text: "添加记录",
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
              borderRadius: 6.wMin,
              color: Colors.transparent,
              fontColor: AppTheme.cTextSecondary.color,
              tapColor: AppTheme.cTextSecondary.color.withValues(alpha: 0.1),
              sclae: 1.05,
              fontSize: 18.wMin,
              onTap: (){
                controller.jumpToCreateHistory(context);
              },
            ),
          ),

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
          left: 24.wMin,
          right: 24.wMin,
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
                        _buildSemanticTagWidget(context, data),
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

    String? imageUrl = data.data.relationImage?.imageUrl;
    bool locked = data.data.relationImage?.locked == true;
    if(data.assetType == 1){
      imageUrl = data.data.relationVideo?.firstImageUrl;
      locked = data.data.relationVideo?.locked == true;
    }

    return SizedBox(
      width: 160.wMin,
      height: 160.wMin,
      child: TapScaleWidget(
        onTap: () {
          if(imageUrl == null) return;
          ShowBigImageDialog.show(
            context: context, 
            imageUrls: [imageUrl],
          );
        },
        sclae: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.wMin),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                CachedImageWidget(
                  imageUrl ?? "",
                  errorWidget: buildEmptyWidget(),
                  placeholder: buildLoadingWidget(),
                  fadeInDuration: Duration.zero,
                ),
                Positioned(
                  left: 4.wMin,
                  top: 4.wMin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: locked,
                        child: ManageTagFS14Widget(
                          tag: "已定稿",
                          bgColor: AppTheme.cInversePrimary.color,
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

    /// 语义标签部分
  Widget _buildSemanticTagWidget(BuildContext context, ManageExpandModel<EnKnowledgeEntity> data){
    return Row(
      spacing: 6.wMin,
      children: [
        Visibility(
          visible: data.data.minDifficulty != null && data.data.maxDifficulty != null ,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4.wMin,
            children: [
              StatusTagDifficultyWidget(
                difficulty: data.data.minDifficulty,
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
                difficulty: data.data.maxDifficulty,
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
          tag: "课程: ${data.data.inCourseCnt??0}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        const Spacer(),

        _buildImageVideoSwitchWidget(data),

        SizedBox(width: 10.wMin),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.enSentenceEdit],
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
          authCodes: const [ManageAuthCode.enSentenceDelete],
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
    );
  }

  /// 图片视频的切换
  Widget _buildImageVideoSwitchWidget(ManageExpandModel<EnKnowledgeEntity> data){
    return Container(
      height: 40.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        children: [
          ButtonWidget(
            text: "图片",
            height: 40.wMin,
            width: 80.wMin,
            borderRadius: 8.wMin,
            fontSize: 16.wMin,
            color: data.assetType == 0 ? AppTheme.cSurfaceInfo.color : Colors.transparent,
            fontColor: data.assetType == 0 ? AppTheme.cInverseTextLight.color : AppTheme.cTextTertiary.color,
            sclae: 1,
            onTap: () {
              data.assetType = 0;
              controller.knowledgeList.refresh();
            },
          ),
          ButtonWidget(
            text: "视频",
            height: 40.wMin,
            width: 80.wMin,
            borderRadius: 8.wMin,
            fontSize: 16.wMin,
            color: data.assetType == 1 ? AppTheme.cSurfaceInfo.color : Colors.transparent,
            fontColor: data.assetType == 1 ? AppTheme.cInverseTextLight.color : AppTheme.cTextTertiary.color,
            sclae: 1,
            onTap: () {
              data.assetType = 1;
              controller.knowledgeList.refresh();
            },
          ),
        ],
      ),
    );
  }


  /// 内容
  Widget _buildCardContentWidget(BuildContext context, ManageExpandModel<EnKnowledgeEntity> data){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SelectableText(
          data.data.content??"",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),

        SizedBox(height: 6.wMin),

        SelectableText(
          data.data.definition??"",
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

    int knowledgeCnt = 0;
    data.data.contentKnowledgeStatistics?.contentKnowledge?.forEach((element) {
      knowledgeCnt += element?.total??0;
    });

    bool inCourse = data.data.inCourse == true;

    List<EnKnowledgeEntityAudioExpressionList?> audioExpressionList = data.data.audioExpressionList??[];
    // 音频数量
    int audioExpressionListAudio = audioExpressionList.where((e) => e?.published == true).length;

    bool locked = data.data.relationImage?.locked == true;
    if(data.assetType == 1){
      locked = data.data.relationVideo?.locked == true;
    }

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
            visible: data.assetType == 0,
            child: Row(
              children: [
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.enContentSemanticList, ManageAuthCode.adminContentReviewKnowledgeImages],
                  child: _buildActionItemWidget(
                    text: "图片",
                    onTap: () {
                      controller.onSemanticImage(data.data);
                    },
                  ),
                ),
            
                ManageAuthBoxWidget(
                  authCodes: [ locked ? ManageAuthCode.contentReviewImageUnlock : ManageAuthCode.contentReviewImageLock],
                  margin: EdgeInsets.only(left: 12.wMin),
                  child: _buildActionItemWidget(
                    text: locked ? "取消定稿" : "图片定稿",
                    onTap: () {
                      if(locked){
                        controller.cancelFinalDraftImage(context, data.data);
                      }else{
                        controller.finalDraftImage(data.data);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          Visibility(
            visible: data.assetType == 1,
            child: Row(
              children: [
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.enContentSemanticList, ManageAuthCode.videoReviewKnowledgeVideos],
                  child: _buildActionItemWidget(
                    text: "视频",
                    onTap: () {
                      controller.onSemanticVideo(data.data);
                    },
                  ),
                ),
            
                ManageAuthBoxWidget(
                  authCodes: [ locked ? ManageAuthCode.videoReviewVideoUnlock : ManageAuthCode.videoReviewVideoLock],
                  margin: EdgeInsets.only(left: 12.wMin),
                  child: _buildActionItemWidget(
                    text: locked ? "取消定稿" : "视频定稿",
                    onTap: () {
                      if(locked){
                        controller.cancelFinalDraftVideo(context, data.data.relationVideo);
                      }else{
                        controller.finalDraftVideo(data.data.relationVideo);
                      }
                    },
                  ),
                ),
              ],
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
                controller.onSemanticExercises(data.data);
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
                controller.onSemanticQuote(data.data);
              },
              bgColor: inCourse ? AppTheme.cFeedbackSuccessBackground.color : null,
              fontColor: inCourse ? AppTheme.cFeedbackSuccessText.color : null,
            ),
          ),
          SizedBox(width: 12.wMin),
          _buildActionItemWidget(
            text: "音频 $audioExpressionListAudio/${audioExpressionList.length}",
            onTap: () async{
              EnKnowledgeEntityAudioExpressionList? result = await ManageKnowledgeAudioListDialg.showAudioList(
                context: context,
                data: data.data,
                title: data.data.content??'',
              );
              if(result == null) return;
              controller.jumpToAudioManage(data.data, result);
            },
            bgColor: audioExpressionListAudio == 0 ? AppTheme.cSurfaceTertiary.color : AppTheme.cFeedbackSuccessBackground.color,
            fontColor: audioExpressionListAudio == 0 ?  AppTheme.cTextTertiary.color : AppTheme.cFeedbackSuccessText.color,
          ),

        ],
      ),
    );
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
