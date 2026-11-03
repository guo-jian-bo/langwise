import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/public_controller/config_controller.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../theme/theme.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/values/values.dart';
import '../../../common/knowledge_video_tool_buttons_widget.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../models/manage_open_model.dart';
import '../../../utils/utils.dart';
import '../../../common/commons.dart';

class ManagePhraseCardWidget extends StatelessWidget {
  final ManageExpandModel<EnKnowledgeEntity> entity;
  final String? languageCode;
  final Function()? onToggleSemantic;
  final Function()? onDeleteKnowledge;
  final Function()? onEditKnowledge;
  final Function()? onKnowledgeCore;

  final Function(EnKnowledgeEntitySemantics semantic)? onDeleteSemantic;
  final Function(EnKnowledgeEntitySemantics semantic)? onEditSemantic;
  final Function(EnKnowledgeEntitySemantics semantic)? onSemanticImage;
  final Function(EnKnowledgeEntitySemantics semantic)? onSemanticVideo;
  final Function(EnKnowledgeEntitySemantics semantic)? onSemanticExercises;
  final Function(EnKnowledgeEntitySemantics semantic)? onSemanticQuote;
  final Function()? onAddSemantic;
  final Function()? onCorrelationSemantic;

  /// 刷新
  final Function()? onRefreshData;
  final Function()? onRefreshServiceData;

  const ManagePhraseCardWidget({
    super.key,
    required this.entity, 
    this.languageCode, 
    this.onToggleSemantic,
    this.onDeleteKnowledge,
    this.onEditKnowledge,
    this.onKnowledgeCore,
    this.onDeleteSemantic,
    this.onEditSemantic,
    this.onSemanticImage,
    this.onSemanticVideo,
    this.onSemanticExercises,
    this.onSemanticQuote,
    this.onAddSemantic,
    this.onCorrelationSemantic,
    this.onRefreshData,
    this.onRefreshServiceData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardTagsWidget(context),
                SizedBox(height: 4.wMin),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKnowledgeContentWidget(),
                          SizedBox(height: 4.wMin),
                          _buildDefinitionWidget(),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.wMin),
                    ManageEnKnowledgeAudioListWidget(
                      audioList: entity.data.audioList,
                      contentType: entity.data.contentType,
                      contentId: entity.data.uid,
                      onRefreshServiceData: onRefreshServiceData,
                      isShowUploadBtn: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildSemanticWidget(context),
        ],
      ),
    );
  }

  /// 卡片标签栏
  Widget _buildCardTagsWidget(BuildContext context){

  final ConfigController config = Get.find<ConfigController>();
    
    LanguageConfigColorModel? colorInfo = StatusUtils.getConfigColor(
      config.colorConfigs.value.pos, 
      entity.data.pos,
    );

    return Row(
      spacing: 8.wMin,
      children: [
        ManageTagFS14Widget(
          tag: "UID: ${entity.data.uid??''}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        ManageTagFS14Widget(
          tag: entity.data.posTitle??'',
          fontColor: colorInfo?.color?.textColor??Colors.white,
          bgColor: colorInfo?.color?.bgColor??AppTheme.cSurfaceQuaternary.color,
        ),
        Visibility(
          visible: entity.data.difficulty != null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4.wMin,
            children: [
              StatusTagDifficultyWidget(
                difficulty: entity.data.difficulty?.min,
                language: languageCode,
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
                difficulty: entity.data.difficulty?.max,
                language: languageCode,
              ),
            ],
          ),
        ),
        ManageTagFS14Widget(
          tag: "课程 ${entity.data.inCourseCnt??0}",
          fontColor: AppTheme.cTextPrimary.color,
        ),

        const Spacer(),

        Container(
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTertiary.color,
            borderRadius: BorderRadius.circular(6.wMin),
          ),
          child: Row(
            children: [
              ListingAndDelistingWidget(
                value: entity.data.isNormal,
                // onChange: onListingAndDelisting,
                showSwitch: false,
              ),
              
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.enPhraseEdit],
                margin: EdgeInsets.only(left: 8.wMin),
                child: TapScaleWidget(
                  onTap: () {
                    onEditKnowledge?.call();
                  },
                  sclae: 1.1,
                  borderRadius: 8.wMin,
                  backColor: AppTheme.cSurfaceTertiary.color,
                  child: Container(
                    width: 50.wMin,
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
                authCodes: const [ManageAuthCode.enPhraseDelete],
                margin: EdgeInsets.only(left: 8.wMin),
                child: TapScaleWidget(
                  onTap: () {
                    onDeleteKnowledge?.call();
                  },
                  sclae: 1.1,
                  borderRadius: 8.wMin,
                  backColor: AppTheme.cSurfaceTertiary.color,
                  child: Container(
                    width: 50.wMin,
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

      ],
    );
  }

  /// 知识点栏
  Widget _buildKnowledgeContentWidget() {

    List<EnKnowledgeEntityIpaList?> ipaList = entity.data.ipaList??[];
    ipaList.sort((a, b) => b?.accent == LanguageServiceCodeEnum.US.value ? 1 : -1);

    return Row(
      spacing: 8.wMin,
      children: [
        SelectableText(
          entity.data.content??"",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),

        Row(
          spacing: 8.wMin,
          children: List.generate(ipaList.length, (index){
            return AnimationPlayIconTextWidget(
              iconSize: 24.wMin,
              audioUrl: ipaList[index]?.audioUrl,
              phonetic: ipaList[index]?.text,
              nationalTitle: ipaList[index]?.nationalTitle,
              childPadding: 0,
            );
          }),
        ),

      ],
    );
  }

  /// 释义栏
  Widget _buildDefinitionWidget() {
    List<LanguageText?> gloss = entity.data.gloss??[];

    if(gloss.isEmpty){
      return SelectableText(
        entity.data.definition??"",
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextSecondary.color,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(gloss.length, (index){
        return SelectableText(
          gloss[index]?.text ?? "",
          style: TextStyle(
            fontSize: index == 0 ? 24.wMin : 18.wMin,
            fontWeight: FontWeight.w400,
            color: index == 0 ? AppTheme.cTextSecondary.color : AppTheme.cTextTertiary.color,
          ),
        );
      }),
    );

  }


  /// 包含语义
  Widget _buildSemanticWidget(BuildContext context) {

    /// 核心知识点
    int coreKnowledge = entity.data.contentKnowledgeStatistics?.total??0;

    bool addAuth = ManageAuthUtils.isAuth(ManageAuthCode.enWordEdit);
    bool correlationAuth = ManageAuthUtils.isAuth(ManageAuthCode.enWordEditSemanticAdd);

    return ManageCrossFadeWidget(
      title: "包含语义 (${entity.data.semantics?.length??0})",
      firstChild: _buildSemanticListWidget(context),
      onToggleExpand: onToggleSemantic,
      isExpanded: entity.isExpanded,
      buttonText: "添加语义",
      onButton: !addAuth ? null : (){
        onAddSemantic?.call();
      },
      buttonText1: "关联语义",
      onButton1: !correlationAuth ? null : () {
        onCorrelationSemantic?.call();
      },
      centerWidget: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enContentKnowledgeList],
            child: ButtonWidget(
              text: "核心知识点 $coreKnowledge",
              height: 40.wMin,
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              borderRadius: 8.wMin,
              color: coreKnowledge == 0 ? AppTheme.cSurfaceTertiary.color : AppTheme.cFeedbackSuccessBackground.color,
              fontColor: coreKnowledge == 0 ?  AppTheme.cTextTertiary.color : AppTheme.cFeedbackSuccessText.color,
              fontSize: 18.wMin,
              sclae: 1.05,
              onTap: () async{
                onKnowledgeCore?.call();
              },
            ),
          ),

          SizedBox(width: 16.wMin),
        ],
      ),
    );
  }

  

  /// 语义列表
  Widget _buildSemanticListWidget(BuildContext context){
    final semantics = entity.data.semantics ?? [];
    return GridView.builder(
      itemCount: semantics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: 18.wMin, right: 18.wMin, bottom: 18.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.wMin,
        mainAxisSpacing: 20.wMin,
        mainAxisExtent: 220.wMin,
      ), 
      itemBuilder: (context, index) {
        final semantic = semantics[index];
        return MangeWordSemanticCardWidget(
          entity: entity,
          semantic: semantic,
          languageCode: languageCode,
          showImage: entity.isExpanded,
          onDeleteSemantic: onDeleteSemantic,
          onEditSemantic: onEditSemantic,
          onSemanticImage: onSemanticImage,
          onSemanticVideo: onSemanticVideo,
          onSemanticExercises: onSemanticExercises,
          onSemanticQuote: onSemanticQuote,
          onRefreshServiceData: onRefreshServiceData,
        );
      },
    );
  }
  


}






class MangeWordSemanticCardWidget extends StatelessWidget {
  final ManageExpandModel<EnKnowledgeEntity> entity;
  final EnKnowledgeEntitySemantics? semantic;
  final String? languageCode;
  final bool showImage;
  final Function(EnKnowledgeEntitySemantics semantic)? onDeleteSemantic;
  final Function(EnKnowledgeEntitySemantics semantic)? onEditSemantic;
  final Function(EnKnowledgeEntitySemantics semantic)? onSemanticImage;
  final Function(EnKnowledgeEntitySemantics semantic)? onSemanticVideo;
  final Function(EnKnowledgeEntitySemantics semantic)? onSemanticExercises;
  final Function(EnKnowledgeEntitySemantics semantic)? onSemanticQuote;

  final Function()? onRefreshServiceData;

  const MangeWordSemanticCardWidget({
    super.key, 
    required this.entity,
    this.semantic,
    this.languageCode,
    this.showImage = true,

    this.onDeleteSemantic,
    this.onEditSemantic,
    this.onSemanticImage,
    this.onSemanticVideo,
    this.onSemanticExercises,
    this.onSemanticQuote,
    this.onRefreshServiceData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
      ),
      child: Row(
        children: [
          _buildSemanticCardImageWidget(context, semantic),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSemanticTagWidget(semantic),
                  _buildSemanticGlossWidget(semantic),
                  const Spacer(),
                  _buildSemanticActionWidget(semantic),
                ],
              ),
            ),
          ),


        ],
      ),
    );
  }


  /// 语义卡片图片部分
  Widget _buildSemanticCardImageWidget(BuildContext context, EnKnowledgeEntitySemantics? semantic){
    return Obx((){
      final ManageSettingController settingController = Get.find<ManageSettingController>();

      String? imagesUrl = semantic?.relationImage?.imageUrl;
      if(settingController.defaultResources.value == ResourceTypeEnum.video){
        imagesUrl = semantic?.relationVideo?.firstImageUrl;
      }

      return TapScaleWidget(
        onTap: () {
          if(settingController.defaultResources.value == ResourceTypeEnum.video){
            ShowBigResourceDialog.showVideo(
              context: context, 
              relationVideo: semantic?.relationVideo,
            );
          }else{
            if(imagesUrl == null) return;
            ShowBigResourceDialog.showImage(
              context: context, 
              imageUrls: [imagesUrl],
            );
          }
        },
        sclae: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(12.wMin)),
          child: AspectRatio(
            aspectRatio: 1,
            child: SizedBox(
              width: 220.wMin,
              height: 220.wMin,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Visibility(
                    visible: showImage,
                    child: CachedImageWidget(
                      imagesUrl ?? "",
                      errorWidget: buildEmptyWidget(),
                      placeholder: buildLoadingWidget(),
                      fadeInDuration: Duration.zero,
                    ),
                  ),

                  Visibility(
                    visible: settingController.defaultResources.value == ResourceTypeEnum.video && imagesUrl != null,
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
                                "${semantic?.relationVideo?.duration??0}s",
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
                    top: 4.wMin,
                    child: KnowledgeVideoToolVuttonsWidget(
                      uid: entity.data.uid,
                      type: entity.data.contentType,
                      semanticId: semantic?.uid,
                      relationImage: semantic?.relationImage,
                      relationVideo: semantic?.relationVideo,
                      onRefresh: () {
                        onRefreshServiceData?.call();
                      },
                      
                    ),
                  ),

                  Positioned(
                    left: 4.wMin,
                    bottom: 4.wMin,
                    child: Visibility(
                      visible: settingController.defaultResources.value == ResourceTypeEnum.video && imagesUrl != null,
                      child: ManageAssStatusWidget(
                        assState: semantic?.relationVideo?.assState,
                        assTranslateState: semantic?.relationVideo?.assTranslateState,
                        videoId: semantic?.relationVideo?.videoId,
                        assId: semantic?.relationVideo?.assId,
                        onRefresh: () {
                          onRefreshServiceData?.call();
                        },
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
  Widget _buildSemanticTagWidget(EnKnowledgeEntitySemantics? semantic){
    return Row(
      spacing: 6.wMin,
      children: [
        StatusTagDifficultyWidget(
          difficulty: semantic?.difficulty,
          language: languageCode,
        ),
        ManageTagFS14Widget(
          tag: "sid: ${semantic?.uid??''}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        ManageTagFS14Widget(
          tag: "教育等级：${semantic?.eduTierEnum?.name??''}",
          fontColor: semantic?.eduTierEnum?.color??AppTheme.cTextPrimary.color,
          bgColor: (semantic?.eduTierEnum?.color??AppTheme.cSurfaceQuaternary.color).withValues(alpha: 0.2),
        ),

        const Spacer(),

        Visibility(
          visible: onEditSemantic != null,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enWordSemanticEdit],
            child: TapScaleWidget(
              onTap: () {
                if(semantic == null) return;
                onEditSemantic?.call(semantic);
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
        ),

        Visibility(
          visible: onDeleteSemantic != null,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enPhraseSemanticDelete],
            margin: EdgeInsets.only(left: 8.wMin),
            child: TapScaleWidget(
              onTap: () {
                if(semantic == null) return;
                onDeleteSemantic?.call(semantic);
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
        ),

      ],
    );
  }

  /// 语义释义部分
  Widget _buildSemanticGlossWidget(EnKnowledgeEntitySemantics? semantic){
    List<LanguageText?> gloss = semantic?.gloss??[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(gloss.length, (index){
        return SelectableText(
          gloss[index]?.text??"",
          maxLines: 2,
          minLines: 1,
          style: TextStyle(
            fontSize: 22.wMin,
            color: index == 0 ? AppTheme.cTextPrimary.color : AppTheme.cTextSecondary.color,
            fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }),
    );
  }

  


  /// 语义操作按钮部分
  Widget _buildSemanticActionWidget(EnKnowledgeEntitySemantics? semantic){
    final ManageSettingController settingController = Get.find<ManageSettingController>();
    
    return Obx((){

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: settingController.defaultResources.value == ResourceTypeEnum.image,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.enContentSemanticList, ManageAuthCode.adminContentReviewKnowledgeImages],
              child: _buildSemanticActionItemWidget(
                text: "图片",
                onTap: () {
                  onSemanticImage?.call(semantic!);
                },
              ),
            ),
          ),

          Visibility(
            visible: settingController.defaultResources.value == ResourceTypeEnum.video,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.enContentSemanticList, ManageAuthCode.videoReviewKnowledgeVideos],
              child: _buildSemanticActionItemWidget(
                text: "视频",
                onTap: () {
                  onSemanticVideo?.call(semantic!);
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
            margin: EdgeInsets.only(left: 10.wMin),
            child: _buildSemanticActionItemWidget(
              text: "题目",
              onTap: () {
                onSemanticExercises?.call(semantic!);
              },
            ),
          ),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.unitKnowledgeCourseInfos],
            margin: EdgeInsets.only(left: 10.wMin),
            child: _buildSemanticActionItemWidget(
              text: "引用(${semantic?.inCourseCnt??'0'})",
              bgColor: semantic?.inCourse == true ? AppTheme.cFeedbackSuccessBackground.color : null,
              fontColor: semantic?.inCourse == true ? AppTheme.cFeedbackSuccessText.color : null,
              onTap: () {
                onSemanticQuote?.call(semantic!);
              },
            ),
          ),
      
        ],
      );
    });
  }

    
  Widget _buildSemanticActionItemWidget({
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
            color: bgColor??AppTheme.cSurfaceTertiary.color,
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