
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:uuid/uuid.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/favourite_button.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import '../../elements/utils/elements_page_utils.dart';
import '../../management/common/commons.dart';
import '../../management/common/knowledge_video_tool_buttons_widget.dart';
import '../../management/controllers/manage_setting_controller.dart';
import '../../management/dialog/dialogs.dart';
import '../../management/utils/utils.dart';

enum CourseDetailsTargetEditToastType{
  /// 图片
  image('图片'),

  video('视频'),
  /// 题目
  exercise('题目'),
  /// 内容
  content('内容'),
  /// 替换
  replace('替换'), 
  /// 替换义
  replaceSemantics('替换义'), 
  /// 替换词
  replaceWord('替换词');

  final String title;
  const CourseDetailsTargetEditToastType(this.title);
}

class KnowledgeCardItemWidget extends StatefulWidget {
  final List<UnitKnowledgePointsEntityKnowledgeList> allKnowledge;
  final UnitKnowledgePointsEntityKnowledgeList knowledge;
  final String? moduleTopic;
  final bool isAdminPage;
  final void Function(CourseDetailsTargetEditToastType type, UnitKnowledgePointsEntityKnowledgeList knowledge)? onEditTap;
  /// 从当前知识点列表删除，不影响知识库
  final void Function(UnitKnowledgePointsEntityKnowledgeList knowledge)? onDeleteKnowledgeTap;
  /// 从知识库里彻底删除
  final void Function(UnitKnowledgePointsEntityKnowledgeList knowledge)? onDeleteKnowledgeFromLibraryTap;
  /// 刷新
  final void Function(UnitKnowledgePointsEntityKnowledgeList knowledge)? onRefresh;
  /// 单元id
  final int? unitId;
  const KnowledgeCardItemWidget({
    super.key, 
    required this.allKnowledge,
    required this.knowledge,
    this.moduleTopic,
    this.isAdminPage = false,
    this.onEditTap,
    this.onDeleteKnowledgeTap,
    this.onDeleteKnowledgeFromLibraryTap,
    this.onRefresh,
    this.unitId,
  });

  @override
  State<KnowledgeCardItemWidget> createState() => _KnowledgeCardItemWidgetState();
}

class _KnowledgeCardItemWidgetState extends State<KnowledgeCardItemWidget> {

  final GlobalKey deleteButtonKey = GlobalKey();

  Future<void> adminDeleteKnowledgeFunction(BuildContext context) async {

    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "从知识点列表删除",
      subTitle: "确定删除知识点吗？",
      content: "从当前知识点列表删除，不影响知识库",
    );
    if(!askRes) return;

    // 从当前知识点列表删除，不影响知识库
    widget.onDeleteKnowledgeTap?.call(widget.knowledge);
    

    // OptionMenuManager.showAtKey(
    //   context: context,
    //   key: deleteButtonKey,
    //   items: [
    //     OptionMenuItem(
    //       title: "从知识点列表删除",
    //       onTap: () {
    //         // 从当前知识点列表删除，不影响知识库
    //         widget.onDeleteKnowledgeTap?.call(widget.knowledge);
    //       },
    //     ),
    //     // OptionMenuItem(
    //     //   title: "从知识库里删除",
    //     //   onTap: () {
    //     //     // 从知识库彻底删除
    //     //     widget.onDeleteKnowledgeFromLibraryTap?.call(widget.knowledge);
    //     //   },
    //     // ),
    //   ],
    // );
  }


  /// 播放按钮
  Future<void> toPlayPage() async{
    bool experience = await LockUtils.checkExperienceApp(context);
    if(experience) return;

    bool student = await LockUtils.checkStudent(context);
    if(!student) return;

    /// 是否是管理端的标识 随机UUID
    String? traceAdminHeader;
    if(widget.isAdminPage){
      traceAdminHeader = const Uuid().v4();
    }

    List<Map<String, dynamic>> contents = [];
    for(var item in widget.allKnowledge){
      if(item.contentType == widget.knowledge.contentType){
        contents.add({
          "contentId": item.contentId,
          "contentType": item.contentType,
          "styleId": item.styleId,
          "dialect": item.dialect,
        });
      }
    }

    ElementsPageUtils.jumpElementsPage(
      contentId: widget.knowledge.contentId,
      contentType: widget.knowledge.contentType,
      semanticId: widget.knowledge.semanticId,
      styleId: widget.knowledge.styleId,
      dialect: widget.knowledge.dialect,
      semanticIds: [widget.knowledge.semanticId],
      content: widget.knowledge.content,
      contents: contents,
      type: PlayRecordPageType.unit,
      typeId: widget.unitId,
      traceAdminHeader: traceAdminHeader,
    );
  }

  /// 替换
  Future<void> showReplace(BuildContext ctx) async{
    int? res = await IconDropdownDialog.showCheck(
      context: ctx, 
      width: 200.wMin,
      selectIndex: -1,
      items: [
        IconDropdownCheckData(
          title: "替换义",
        ),
        IconDropdownCheckData(
          title: "替换词",
        ),
      ],
    );
    if(res == null) return;
    if(res == 0){
      widget.onEditTap?.call(CourseDetailsTargetEditToastType.replaceSemantics, widget.knowledge);
    }else{
      widget.onEditTap?.call(CourseDetailsTargetEditToastType.replaceWord, widget.knowledge);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.wMin),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary.color,
            borderRadius: BorderRadius.circular(12.wMin),
          ),
          child: Row(
            children: [
              Visibility(
                visible: !widget.isAdminPage,
                child: _buildImageWidget(),
              ),
              Visibility(
                visible: widget.isAdminPage,
                child: _buildAdminImageWidget(),
              ),
              SizedBox(width: 4.wMin),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8.wMin),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTagGroupWidget(context)),
                          Visibility(
                            visible: widget.isAdminPage,
                            child: ManageAuthBoxWidget(
                              authCodes: const [ManageAuthCode.unitKnowledgeRemove],
                              child: Container(
                                margin: EdgeInsets.only(left: 8.wMin),
                                child: TapScaleWidget(
                                  onTap: () => adminDeleteKnowledgeFunction(context),
                                  sclae: 1.05,
                                  key: deleteButtonKey,
                                  child: SvgPicture.asset(
                                    "assets/svg/public/icon_delete.svg",
                                    width: 32.wMin,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 4.wMin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildKnowledgeTextWidget(),
                              const Spacer(),
                              Row(
                                spacing: 4.wMin,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildEditButtonWidget(),
                                  const Spacer(),
                                  Visibility(
                                    visible: (widget.knowledge.isSong || widget.knowledge.isText) && widget.knowledge.contentId != null,
                                    child: FavouriteButton(
                                      styleId: widget.knowledge.styleId,
                                      dialect: widget.knowledge.dialect,
                                      contentId: widget.knowledge.contentId??0,
                                      contentType: widget.knowledge.contentType??"",
                                      isFavourited: widget.knowledge.favorited??false,
                                      onRefresh: (p0) {
                                        widget.onRefresh?.call(widget.knowledge);
                                      },
                                    ),
                                  ),
                                  _buildButtonWidget(),
                                ],
                              ),
                                                
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(){
    
    ConfigController controller = Get.find<ConfigController>();

    return Obx((){
      String? imagesUrl = widget.knowledge.imageUrl;

      return AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [

            TapScaleWidget(
              onTap: () async{

                if(widget.knowledge.cardType == ElementsCardType.song || widget.knowledge.cardType == ElementsCardType.text){
                  toPlayPage();
                  return;
                }

                if(controller.currentShowResource.value == ResourceTypeEnum.video && widget.knowledge.video?.videoUrl != null){
                  ShowBigResourceDialog.showVideo(
                    context: context, 
                    relationVideo: EnKnowledgeEntityRelationVideo(
                      uid: widget.knowledge.video?.videoRelationId,
                      videoUrl: widget.knowledge.video?.videoUrl,
                      firstImageUrl: widget.knowledge.video?.firstFrameUrl,
                      duration: widget.knowledge.video?.duration,
                      startSeconds: widget.knowledge.video?.startSeconds,
                      endSeconds: widget.knowledge.video?.endSeconds,
                      isMute: widget.knowledge.video?.isMute,
                      locked: widget.knowledge.video?.locked,
                      ass: widget.knowledge.video?.ass,
                      translate: widget.knowledge.video?.translateAss,
                    ),
                  );
                }else{
                  if(imagesUrl == null) return;
                  await ShowBigResourceDialog.showImage(
                    context: context, 
                    imageUrls: [imagesUrl],
                  );
                  
                }

              },
              sclae: 1,
              child: CachedImageWidget(
                imagesUrl ?? "",
                errorWidget: buildEmptyWidget(),
                placeholder: buildLoadingWidget(),
                fadeInDuration: Duration.zero,
              ),
            ),

            Visibility(
              visible: controller.currentShowResource.value == ResourceTypeEnum.video && widget.knowledge.video?.videoUrl != null,
              child: Center(
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
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 42.wMin,
                    ),
                  ),
                ),
              ),
            ),

            Visibility(
              visible: (widget.knowledge.pronunciations?.isNotEmpty ?? false) && (!widget.knowledge.isText && !widget.knowledge.isSong) ,
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(widget.knowledge.pronunciations?.length ?? 0, (index) {
                    return PlayLottieIconWidget(
                      size: 36.wMin,
                      tapPadding: 8.wMin,
                      childPadding: 8.wMin,
                      audioUrl: widget.knowledge.pronunciations?[index]?.audioUrl,
                      backgroundImageUrl: widget.knowledge.pronunciations?[index]?.nationalIconUrl,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAdminImageWidget(){
    if(!Get.isRegistered<ManageSettingController>()) return Container();
    final ManageSettingController settingController = Get.find<ManageSettingController>();

    return Obx((){
      String? imagesUrl = widget.knowledge.imageUrl;
      if(settingController.defaultResources.value == ResourceTypeEnum.video){
        imagesUrl = widget.knowledge.video?.firstFrameUrl;
      }
      
      return AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [

            TapScaleWidget(
              onTap: () async{

                if(settingController.defaultResources.value == ResourceTypeEnum.video){
                  ShowBigResourceDialog.showVideo(
                    context: context, 
                    relationVideo: EnKnowledgeEntityRelationVideo(
                      uid: widget.knowledge.video?.videoRelationId,
                      videoUrl: widget.knowledge.video?.videoUrl,
                      firstImageUrl: widget.knowledge.video?.firstFrameUrl,
                      duration: widget.knowledge.video?.duration,
                      startSeconds: widget.knowledge.video?.startSeconds,
                      endSeconds: widget.knowledge.video?.endSeconds,
                      isMute: widget.knowledge.video?.isMute,
                      locked: widget.knowledge.video?.locked,
                      ass: widget.knowledge.video?.ass,
                      translate: widget.knowledge.video?.translateAss,
                    ),
                  );
                }else{
                  bool res = await ManageLockBigImageDialog.show(
                    context: context, 
                    imageUrl: imagesUrl,
                    relationImageId: widget.knowledge.imageRelationId,
                    locked: widget.knowledge.locked,
                  );
                  if(!res) return;
                  widget.onRefresh?.call(widget.knowledge);
                  
                }

              },
              sclae: 1,
              child: CachedImageWidget(
                imagesUrl??"",
                errorWidget: buildEmptyWidget(),
                placeholder: buildEmptyWidget(),
              ),
            ),

            Visibility(
              visible: settingController.defaultResources.value == ResourceTypeEnum.video && imagesUrl != null,
              child: Center(
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
                            "${widget.knowledge.video?.duration??0}s",
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
            ),

            Positioned(
              left: 4.wMin,
              top: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageTagItemWidget(
                    text: "风格${widget.knowledge.styleCount ?? 0} | 可用${widget.knowledge.availableImageCount ?? 0}",
                    bgColor: const Color(0xff38BDF8).withValues(alpha: 0.8),
                  ),
                  _buildImageTagItemWidget(
                    text: "id: ${widget.knowledge.contentId ?? ""}",
                    bgColor: AppTheme.cSurfaceQuaternary.color,
                    fontColor: AppTheme.cTextPrimary.color,
                  ),
                  Visibility(
                    visible: (widget.knowledge.semanticId??0) > 0,
                    child: _buildImageTagItemWidget(
                      text: "sid: ${widget.knowledge.semanticId ?? ""}",
                      bgColor: AppTheme.cSurfaceQuaternary.color,
                      fontColor: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  Visibility(
                    visible: (widget.knowledge.published??true) == true,
                    child: _buildImageTagItemWidget(
                      text: "音频已发布",
                      bgColor: AppTheme.cSurfaceError.color,
                    ),
                  ),
                  Visibility(
                    visible: widget.knowledge.accessIsVisible,
                    child: _buildImageTagItemWidget(
                      text: "前端可见",
                      bgColor: AppTheme.cSurfaceError.color,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 4.wMin,
              right: 4.wMin,
              child: KnowledgeVideoToolVuttonsWidget(
                uid: widget.knowledge.contentId,
                type: widget.knowledge.contentType,
                semanticId: widget.knowledge.semanticId,
                relationImage: EnKnowledgeEntitySemanticsRelationImage(
                  uid: widget.knowledge.imageRelationId,
                  imageUrl: widget.knowledge.imageUrl,
                  locked: widget.knowledge.locked,
                ),
                relationVideo: EnKnowledgeEntityRelationVideo(
                  uid: widget.knowledge.video?.videoRelationId,
                  videoUrl: widget.knowledge.video?.videoUrl,
                  firstImageUrl: widget.knowledge.video?.firstFrameUrl,
                  duration: widget.knowledge.video?.duration,
                  startSeconds: widget.knowledge.video?.startSeconds,
                  endSeconds: widget.knowledge.video?.endSeconds,
                  isMute: widget.knowledge.video?.isMute,
                  locked: widget.knowledge.video?.locked,
                  ass: widget.knowledge.video?.ass,
                  translate: widget.knowledge.video?.translateAss,
                ),
                onRefresh: () {
                  widget.onRefresh?.call(widget.knowledge);
                },
              ),
            ),


            Visibility(
              visible: (widget.knowledge.pronunciations?.isNotEmpty ?? false) && (!widget.knowledge.isText && !widget.knowledge.isSong) ,
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(widget.knowledge.pronunciations?.length ?? 0, (index) {
                    return PlayLottieIconWidget(
                      size: 36.wMin,
                      tapPadding: 8.wMin,
                      childPadding: 8.wMin,
                      audioUrl: widget.knowledge.pronunciations?[index]?.audioUrl,
                      backgroundImageUrl: widget.knowledge.pronunciations?[index]?.nationalIconUrl,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 图片标签item
  Widget _buildImageTagItemWidget({
    required String text,
    required Color bgColor,
    Color fontColor = AppTheme.cStaticWhite,
  }){
    return Container(
      margin: EdgeInsets.only(top: 4.wMin),
      padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.wMin),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: 14.wMin,
          color: fontColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
  


  /// 标签组
  Widget _buildTagGroupWidget(BuildContext context){
    
    List<UnitKnowledgePointsEntityKnowledgeListTags?> tags = widget.knowledge.tags??[];
    tags.removeWhere((element) => element == null);
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false, // 隐藏滚动条
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 6.wMin,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKnowledgeTypeTagWidget(),
            _buildDifficultyWidget(),
            ...List.generate(tags.length, (index) {
              return _buildTagItemWidget(tag: tags[index]);
            }),
          ],
        ),
      ),
    );
  }

  /// 拓展按钮
  Widget _buildButtonWidget(){
    String buttonText = "拓展";
    if(widget.knowledge.isText){
      buttonText = "听读";
    }else if(widget.knowledge.isSong){
      buttonText = "播放";
    }

    return TapScaleWidget(
      sclae: 1.03,
      onTap: () {
        toPlayPage();
      },
      child: Container(
        height: 48.wMin,
        width: 90.wMin,
        padding: EdgeInsets.only(left: 10.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceQuaternary.color,
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(
            color: AppTheme.cBorderTertiary.color,
            width: 0.6.wMin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 20.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
            ),

          ],
        ),
      ),
    );
  }

  /// 编辑按钮
  Widget _buildEditButtonWidget(){
    if(!widget.isAdminPage){
      return Container();
    }

    final ManageSettingController settingController = Get.find<ManageSettingController>();

    List<CourseDetailsTargetEditToastType> initTypes = [];

    if(settingController.defaultResources.value == ResourceTypeEnum.image){
      if(ManageAuthUtils.isAuths([ManageAuthCode.enContentSemanticList, ManageAuthCode.adminContentReviewKnowledgeImages])){
        initTypes.add(CourseDetailsTargetEditToastType.image);
      }
    }else{
      if(ManageAuthUtils.isAuths([ManageAuthCode.enContentSemanticList, ManageAuthCode.videoReviewKnowledgeVideos])){
        initTypes.add(CourseDetailsTargetEditToastType.video);
      }
    }

    

    if(ManageAuthUtils.isAuths([
      ManageAuthCode.enContentSemanticList, 
      ManageAuthCode.exerciseTypeList,
      ManageAuthCode.exercisePage,
    ])){
      initTypes.add(CourseDetailsTargetEditToastType.exercise);
    }

    if(widget.knowledge.isWord){
      if(ManageAuthUtils.isAuth(ManageAuthCode.enWordPages)){
        initTypes.add(CourseDetailsTargetEditToastType.content);
      }
      if(ManageAuthUtils.isAuth(ManageAuthCode.unitKnowledgeEditSemantic)){
        initTypes.add(CourseDetailsTargetEditToastType.replace);
      }
    } else if(widget.knowledge.isPhrase){
      if(ManageAuthUtils.isAuth(ManageAuthCode.enPhrasePages)){
        initTypes.add(CourseDetailsTargetEditToastType.content);
      }
      if(ManageAuthUtils.isAuth(ManageAuthCode.unitKnowledgeEditSemantic)){
        initTypes.add(CourseDetailsTargetEditToastType.replace);
      }
    }  else if(widget.knowledge.isSentence){
      if(ManageAuthUtils.isAuth(ManageAuthCode.enSentencePages)){
        initTypes.add(CourseDetailsTargetEditToastType.content);
      }
    } else if(widget.knowledge.isText){
      if(ManageAuthUtils.isAuth(ManageAuthCode.enTextPages)){
        initTypes.add(CourseDetailsTargetEditToastType.content);
      }
    }else if(widget.knowledge.isSong){
      if(ManageAuthUtils.isAuth(ManageAuthCode.enSongPages)){
        initTypes.add(CourseDetailsTargetEditToastType.content);
      }
    }

    return _buildEditButtonsWidget(initTypes);

  }

  Widget _buildEditButtonsWidget(List<CourseDetailsTargetEditToastType> types){
    
    return Row(
      spacing: 6.wMin,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(types.length, (index){
        return Builder(
          builder: (ctx) {
            return TapScaleWidget(
              onTap: (){
                if(types[index] == CourseDetailsTargetEditToastType.replace){
                  showReplace(ctx);
                }else{
                  widget.onEditTap?.call(types[index], widget.knowledge);
                }
              },
              sclae: 1.05,
              child: Container(
                height: 30.wMin,
                padding: EdgeInsets.symmetric(horizontal: 4.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: AppTheme.cSurfaceQuinary.color,
                ),
                child: Center(
                  child: Text(
                    types[index].title,
                    style: TextStyle(
                      color: AppTheme.cTextSecondary.color,
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// 知识点类型标签
  Widget _buildKnowledgeTypeTagWidget(){
    if(widget.knowledge.contentTypeTitle == null) return Container();
    ElementsCardColor? cardColor = StatusUtils.getElementsCardColor(widget.knowledge.contentType);

    return Container(
      height: 24.wMin,
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cardColor?.color1,
        borderRadius: BorderRadius.circular(4.wMin),
      ),
      child: Text(
        widget.knowledge.contentTypeTitle??"",
        style: TextStyle(
          fontSize: 14.wMin,
          color: AppTheme.cInverseTextLight.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// 标签item
  Widget _buildTagItemWidget({
    required UnitKnowledgePointsEntityKnowledgeListTags? tag,
  }){
    if(tag == null) return Container();
    
    return Obx((){
      LanguageText? gloss = LearningLangUtils.getShowLList(tag.gloss);
      if(gloss == null) return Container();
      ThemeTextStyleEntity? currentThemeText = StyleUtils.getCurrentThemeText(tag.style);
      TextStyle? textStyle = StyleUtils.getTextStyle(tag.style);
      
      Color? bgColor = ColorUtils.parseColor(currentThemeText?.backgroundColor);
      Color? borderColor = ColorUtils.parseColor(currentThemeText?.borderColor);

      return Container(
        height: 24.wMin,
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4.wMin),
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1.wMin,
          ),
        ),
        child: Text(
          gloss.text??"",
          style: textStyle,
        ),
      );
    });
  }

  int getTextLineCount(String text, TextStyle style, double maxWidth, int maxLines) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.computeLineMetrics().length;
  }

  Widget _buildKnowledgeTextWidget(){
    String? content = (widget.knowledge.isText || widget.knowledge.isSong) ? widget.knowledge.title : widget.knowledge.content;

    TextStyle textStyle = TextStyle(
      fontSize: 32.wMin,
      color: AppTheme.cTextPrimary.color,
      fontWeight: FontWeight.w600,
      height: 1.25,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth - 20.wMin;
        int lineCount = getTextLineCount(content??"", textStyle, maxWidth, 2);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if(!widget.isAdminPage) return;
                if(content == null) return;
                Clipboard.setData(ClipboardData(text: content));
                ToastUtils.showToast(text: "复制成功", type: ToastType.success);
              },
              child: PronunciationsColorWidget(
                content: content,
                ipa: widget.moduleTopic,
                pronunciations: widget.knowledge.pronunciations,
                national: LanguageServiceCode.US,
                maxLines: 2,
                style: textStyle,
              ),
            ),
            _buildGlossTextWidget(maxLines: lineCount == 1 ? 2 : 1),
          ],
        );
      },
    );
  }

  Widget _buildGlossTextWidget({int maxLines = 1}){
    if(widget.knowledge.isText || widget.knowledge.isSong){
      return Text(
        widget.knowledge.content??"",
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 22.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      );
    }
    return Obx(() {
      LanguageText? gloss = LearningLangUtils.getShowForNone(widget.knowledge.gloss ?? []);
      if (gloss == null) return Container();
      return Text(
        gloss.text??"",
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 22.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      );
    });
  }

  Widget _buildDifficultyWidget() {
    if (widget.knowledge.difficulty?.min == widget.knowledge.difficulty?.max) {
      return StatusTagDifficultyWidget(
        difficulty: widget.knowledge.difficulty?.min,
        language: Get.find<ConfigController>().userSetting.value.learningLang,
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        height: 24.wMin,
        alignment: Alignment.center,
      );
    }

    return Row(
      children: [
        StatusTagDifficultyWidget(
          difficulty: widget.knowledge.difficulty?.min,
          language: Get.find<ConfigController>().userSetting.value.learningLang,
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          height: 24.wMin,
          alignment: Alignment.center,
        ),
        Text(
          "-",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        StatusTagDifficultyWidget(
          difficulty: widget.knowledge.difficulty?.max,
          language: Get.find<ConfigController>().userSetting.value.learningLang,
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          height: 24.wMin,
          alignment: Alignment.center,
        ),
      ],
    );
  }

}
