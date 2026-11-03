
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/favourite_button.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import '../../elements/utils/elements_page_utils.dart';
import '../../management/common/commons.dart';
import '../../management/utils/utils.dart';

enum CourseDetailsTargetEditToastType{
  /// 图片
  image('图片', Color(0xff0EA5E9)),
  /// 题目
  exercise('题目', Color(0xffA855F7)),
  /// 内容
  content('内容', Color(0xff00BC7D)),
  /// 替换
  replace('替换', Color(0xffF97316));

  final String title;
  final Color color;
  const CourseDetailsTargetEditToastType(this.title, this.color);
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
    

    OptionMenuManager.showAtKey(
      context: context,
      key: deleteButtonKey,
      items: [
        OptionMenuItem(
          title: "从知识点列表删除",
          onTap: () {
            // 从当前知识点列表删除，不影响知识库
            widget.onDeleteKnowledgeTap?.call(widget.knowledge);
          },
        ),
        // OptionMenuItem(
        //   title: "从知识库里删除",
        //   onTap: () {
        //     // 从知识库彻底删除
        //     widget.onDeleteKnowledgeFromLibraryTap?.call(widget.knowledge);
        //   },
        // ),
      ],
    );
  

  }


  /// 放大图片
  void showBigImageFunction(BuildContext context) {
    if(!widget.isAdminPage) return;

    if(widget.knowledge.imageUrl == null) return;
    
    ShowBigImageDialog.show(
      context: context,
      imageUrls: [widget.knowledge.imageUrl!],
    );

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
              _buildImageWidget(),
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
                                children: [
                                  _buildEditButtonWidget(),
                                  Visibility(
                                    visible: (widget.knowledge.isSong || widget.knowledge.isText) && widget.knowledge.contentId != null,
                                    child: FavouriteButton(
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
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          TapScaleWidget(
            onTap: !widget.isAdminPage ? null : () {
              showBigImageFunction(context);
            },
            sclae: 1,
            child: CachedImageWidget(
              widget.knowledge.imageUrl ?? "",
              errorWidget: buildEmptyWidget(),
              placeholder: buildLoadingWidget(),
              fadeInDuration: Duration.zero,
            ),
          ),
          Visibility(
            visible: widget.isAdminPage,
            child: Positioned(
              left: 4.wMin,
              top: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageTagItemWidget(
                    text: "${widget.knowledge.styleCount ?? 0} 图片风格",
                    bgColor: AppTheme.cSurfaceBrand.color,
                  ),
                  _buildImageTagItemWidget(
                    text: "${widget.knowledge.availableImageCount ?? 0} 可用图片",
                    bgColor: AppTheme.cSurfaceSuccess.color,
                  ),
                  TapScaleWidget(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.knowledge.contentId?.toString() ?? ""));
                      ToastUtils.showManageToast(text: '已复制contentId');
                    },
                    sclae: 1,
                    child: _buildImageTagItemWidget(
                      text: "id:${widget.knowledge.contentId ?? ""}",
                      bgColor: AppTheme.cSurfaceQuaternary.color,
                    ),
                  ),
                  Visibility(
                    visible: (widget.knowledge.semanticId??0) > 0,
                    child: TapScaleWidget(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.knowledge.semanticId?.toString() ?? ""));
                        ToastUtils.showManageToast(text: '已复制semanticId');
                      },
                      sclae: 1,
                      child: _buildImageTagItemWidget(
                        text: "sid:${widget.knowledge.semanticId ?? ""}",
                        bgColor: AppTheme.cSurfaceQuaternary.color,
                      ),
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
  }

  /// 图片标签item
  Widget _buildImageTagItemWidget({
    required String text,
    required Color bgColor,
  }){
    return Container(
      margin: EdgeInsets.only(top: 4.wMin),
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.wMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.wMin,
          color: AppTheme.cStaticWhite.color,
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
      onTap: () async{

        bool experience = await LockUtils.checkExperienceApp(context);
        if(experience) return;

        bool student = await LockUtils.checkStudent(context);
        if(!student) return;

        
        List<Map<String, dynamic>> contents = [];
        for(var item in widget.allKnowledge){
          if(item.contentType == widget.knowledge.contentType){
            contents.add({
              "contentId": item.contentId,
              "contentType": item.contentType,
            });
          }
        }

        ElementsPageUtils.jumpElementsPage(
          contentId: widget.knowledge.contentId,
          contentType: widget.knowledge.contentType,
          semanticIds: [widget.knowledge.semanticId],
          content: widget.knowledge.content,
          contents: contents,
          type: PlayRecordPageType.unit,
          typeId: widget.unitId,
          
        );
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

    List<CourseDetailsTargetEditToastType> initTypes = [];
    if(ManageAuthUtils.isAuths([ManageAuthCode.enContentSemanticList, ManageAuthCode.adminContentReviewKnowledgeImages])){
      initTypes.add(CourseDetailsTargetEditToastType.image);
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
      spacing: 8.wMin,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(types.length, (index){
        return TapScaleWidget(
          onTap: (){
            widget.onEditTap?.call(types[index], widget.knowledge);
          },
          sclae: 1.05,
          child: Container(
            height: 48.wMin,
            padding: EdgeInsets.symmetric(horizontal: 8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              color: types[index].color.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                types[index].title,
                style: TextStyle(
                  color: types[index].color,
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 知识点类型标签
  Widget _buildKnowledgeTypeTagWidget(){
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