
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../enum/enum.dart';
import '../https/favourite.dart';
import '../https/https.dart';
import 'add_favourite_dialog.dart';
import 'widgets.dart';

class KnowledgeCardWidget extends StatefulWidget {
  final KnowledgeCommonEntityList knowledgeData;
  final Future<void> Function()? onReturned;

  const KnowledgeCardWidget({
    super.key,
    required this.knowledgeData,
    this.onReturned,
  });

  @override
  State<KnowledgeCardWidget> createState() => _KnowledgeCardWidgetState();
}

class _KnowledgeCardWidgetState extends State<KnowledgeCardWidget> {


  /// 重新获取这条数据的状态
  Future<void> refreshDataStatus() async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.contentCommonCardInfos)) return;

    KnowledgeCommonEntityListContent? content = widget.knowledgeData.content;
    if(content == null) return;
    if(content.uid == null || content.type == null) return;
    Map<String, dynamic> reqData = {
      "contents": [{
        "uid": widget.knowledgeData.content?.uid??0,
        "type": widget.knowledgeData.content?.type??'',
        "semanticId": widget.knowledgeData.content?.semanticId,
      }]
    };
    KnowledgeCommonEntity? res = await LanguageUtil.getKnowledgeCommon(data: reqData);
    if(res == null) return;
    List<KnowledgeCommonEntityList?>? list = res.list??[];
    if(list.isEmpty) return;
    KnowledgeCommonEntityList? entity = list.firstWhereOrNull((element) {
      return element?.content?.uid == widget.knowledgeData.content?.uid 
        && element?.content?.type == widget.knowledgeData.content?.type
        && element?.content?.semanticId == widget.knowledgeData.content?.semanticId;
    });
    if(entity == null) return;

    widget.knowledgeData.favorited = entity.favorited;
    widget.knowledgeData.rights = entity.rights;
    widget.knowledgeData.progress = entity.progress;
    if(mounted) setState(() {});

  }

  Future<void> _handleReturn() async {
    await refreshDataStatus();
    await widget.onReturned?.call();
  }

  /// 收藏
  Future<void> onFavorite() async{
    

    if(widget.knowledgeData.favorited == null) return ToastUtils.showToast(text: "暂不支持");

    if (widget.knowledgeData.favorited == true) {
      if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.favoriteListensPlayListIdContentRemove)) {
        ToastUtils.showToast(text: "无权限");
        return;
      }
      //todo:取消收藏
      widget.knowledgeData.favorited = false;
      var res = await FavouriteRequest.removeContent(
        playListId: 0, 
        uid: widget.knowledgeData.content?.uid??0, 
        type: widget.knowledgeData.content?.type??'', 
        styleId: widget.knowledgeData.content?.styleId, 
        dialect: widget.knowledgeData.content?.dialect,
      );
      if (!res) {
        widget.knowledgeData.favorited = true;
      }
    } else {
      if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.favoriteListensPlayListIdContentAdd)) {
        ToastUtils.showToast(text: "无权限");
        return;
      }
      widget.knowledgeData.favorited = true;
      var res = await FavouriteRequest.addContent(
        playListId: 0, 
        uid: widget.knowledgeData.content?.uid??0, 
        type: widget.knowledgeData.content?.type??'',
        styleId: widget.knowledgeData.content?.styleId, 
        dialect: widget.knowledgeData.content?.dialect,
      );
      if (res) {
        AddFavouriteDialog.show(
          context, 
          widget.knowledgeData.content?.uid??0, 
          widget.knowledgeData.content?.type??'', 
          styleId: widget.knowledgeData.content?.styleId, 
          dialect: widget.knowledgeData.content?.dialect,
        );
      } else {
        widget.knowledgeData.favorited = false;
        ToastUtils.showToast(text: '收藏失败');
      }
    }
    if(mounted) setState(() {});
  }

  /// 记忆
  Future<void> onMemory() async{
    if(widget.knowledgeData.favorited == null) return ToastUtils.showToast(text: "暂不支持");
    if(widget.knowledgeData.favorited == true) return ToastUtils.showToast(text: "已记忆");
    bool res = await SimpleDictionaryDialog.addKnowledgeCard(
      context: context,
      parameter: [SimpleDictionaryAddCardParm(
        uid: widget.knowledgeData.content?.uid,
        type: widget.knowledgeData.content?.type,
        semanticId: widget.knowledgeData.content?.semanticId,
      )],
    );
    if(!res) return;
    widget.knowledgeData.favorited = true;
    if(mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () async{
        if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.contentListBaseInfos)) {
          ToastUtils.showToast(text: "无权限");
          return;
        }
        if(widget.knowledgeData.jump == null) return;
        bool lock = await LockUtils.checkLock(
          widget.knowledgeData.rights, 
          context,
          contentType: widget.knowledgeData.content?.type??'',
        );
        if(lock) return;
        await JumpPageUtils.jumpUserPages(widget.knowledgeData.jump);
        await _handleReturn();
      },
      sclae: 1.01,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceLayerBase2.color,
          border: Border.all(
            color: AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KnowledgeCardImageWidget(knowledgeData: widget.knowledgeData),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.wMin),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTagListWidget(context),
                      Expanded(
                        child: widget.knowledgeData.isDictionary ? _buildDictionaryContentWidget() : _buildOtherContentWidget(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: (widget.knowledgeData.params?.isSource ?? false) == true,
              child: _buildRelatedContentWidget(),
            ),
            Visibility(
              visible: (widget.knowledgeData.params?.isSource ?? false) == false,
              child: _buildContentTextWidget(),
            ),
            Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
            _buildButtonWidget(),
          ],
        ),
      ),
    );
  }

  /// 其他内容区域
  Widget _buildOtherContentWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6.wMin),
        Text(
          widget.knowledgeData.title??"",
          maxLines: widget.knowledgeData.subTitle != null ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Visibility(
          visible: widget.knowledgeData.subTitle != null,
          child: Container(
            margin: EdgeInsets.only(top: 6.wMin),
            child: Text(
              widget.knowledgeData.subTitle??"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.knowledgeData.focus != null,
          child: Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final style = TextStyle(
                    fontSize: 18.wMin,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextSecondary.color,
                  );

                  final lineHeight = (style.fontSize ?? 14) * (style.height ?? 1.0);
                  final calculatedLines = (constraints.maxHeight / lineHeight).floor();
                  final maxLines = calculatedLines < 1 ? 1 : calculatedLines;

                  return Text(
                    LearningLangUtils.getgetShowForLLN(widget.knowledgeData.focus)?.text ?? "",
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  );
                },
              ),
            ),
          ),
        ),

        
      ],
    );
  }

  /// 文本内容
  Widget _buildContentTextWidget(){
    final themeText = StyleUtils.getCurrentThemeText(widget.knowledgeData.contentTypeTitle?.style);
    Color color = ColorUtils.parseColor(themeText?.backgroundColor) ?? Colors.transparent;

    String? text = LearningLangUtils.getgetShowForLLN(widget.knowledgeData.description)?.text;
    if(text == null) return Container();

    return Container(
      padding: EdgeInsets.only(left: 12.wMin, right: 12.wMin),
      margin: EdgeInsets.only(bottom: 10.wMin),
      child: Container(
        padding: EdgeInsets.only(left: 10.wMin),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: color,
              width: 2.wMin,
            ),
          ),
        ),
        child: Text(
          text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ),
    );
  }

  /// 关联内容
  Widget _buildRelatedContentWidget(){
    final themeText = StyleUtils.getCurrentThemeText(widget.knowledgeData.contentTypeTitle?.style);
    Color color = ColorUtils.parseColor(themeText?.backgroundColor) ?? Colors.transparent;

    return Container(
      padding: EdgeInsets.only(left: 12.wMin, right: 12.wMin),
      margin: EdgeInsets.only(bottom: 10.wMin),
      child: TapScaleWidget(
        onTap: () async{
          final jump = widget.knowledgeData.params?.jump;
          if(jump == null) return;
          await JumpPageUtils.jumpUserPages(jump);
          await _handleReturn();
        },
        sclae: 1,
        child: Container(
          padding: EdgeInsets.only(left: 10.wMin),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: color,
                width: 2.wMin,
              ),
            ),
          ),
          child: Row(
            children: [
        
              Container(
                width: 66.wMin,
                height: 66.wMin,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.wMin),
                  border: Border.all(
                    color: AppTheme.cBorderSubtle.color,
                    width: 1.wMin,
                  ),
                ),
                child: CachedImageWidget(
                  widget.knowledgeData.params?.data?.coverUrl??"",
                  errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                  placeholder: buildEmptyWidget(fit: BoxFit.cover),
                ),
              ),
        
              SizedBox(width: 8.wMin),
        
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: widget.knowledgeData.params?.jump != null,
                      child: Row(
                        children: [
                          Text(
                            "关联内容",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/svg/public/icon_w_arrow_right.svg",
                            width: 16.wMin,
                            colorFilter: ColorFilter.mode(Color(0xffA855F7), BlendMode.srcIn),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.knowledgeData.params?.data?.text??"",
                      maxLines: widget.knowledgeData.params?.data?.jump != null ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
        
                  ],
                ),
              ),
        
            ],
          ),
        ),
      ),
    );
  }

  /// 词典内容区域
  Widget _buildDictionaryContentWidget(){

    List<Pronunciations?> pronunciations = widget.knowledgeData.params?.data?.pronunciations??[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.wMin),
        Text(
          widget.knowledgeData.title??"",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Visibility(
          visible: pronunciations.isNotEmpty,
          child: Container(
            margin: EdgeInsets.only(top: 4.wMin),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false, // 隐藏滚动条
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 12.wMin,
                  children: List.generate(pronunciations.length, (index){
                    return KnowledgeCardPlayAudioWidget(
                      pronunciation: pronunciations[index],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 4.wMin),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final style = TextStyle(
                fontSize: 18.wMin,
                height: 1.3,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              );

              final lineHeight = (style.fontSize ?? 14) * (style.height ?? 1.0);
              final calculatedLines = (constraints.maxHeight / lineHeight).floor();
              final maxLines = calculatedLines < 1 ? 1 : calculatedLines;

              return Text(
                widget.knowledgeData.subTitle??"",
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: style,
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildTagListWidget(BuildContext context){
    List<KnowledgeCommonEntityListGloss?> tags = widget.knowledgeData.tags ?? [];

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false, // 隐藏滚动条
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 6.wMin,
          children: List.generate(tags.length, (index){
            return _buildTagWidget(tags[index]);
          }),
        ),
      ),
    );
  }

  Widget _buildTagWidget(KnowledgeCommonEntityListGloss? tag, {double defaultBorderRadius = 99, double defaultSize = 18}){
    if (tag == null) return Container();
    final themeText = StyleUtils.getCurrentThemeText(tag.style);

    TextStyle? textStyle = StyleUtils.getTextStyle(tag.style, defaultSize: defaultSize);

    LanguageText? gloss = LearningLangUtils.getgetShowForLLN(tag.gloss);
    final text = gloss?.text ?? "";
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        color: ColorUtils.parseColor(themeText?.backgroundColor) ?? Colors.transparent,
        borderRadius: BorderRadius.circular(themeText?.borderRadius ?? defaultBorderRadius.wMin),
        border: Border.all(
          color: ColorUtils.parseColor(themeText?.borderColor) ?? Colors.transparent,
          width: 0.8.wMin,
        ),
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }

  Widget _buildButtonWidget(){
    
    final themeText = StyleUtils.getCurrentThemeText(widget.knowledgeData.contentTypeTitle?.style);
    Color color = ColorUtils.parseColor(themeText?.backgroundColor) ?? AppTheme.cSurfaceBrand.color;

    String buttonText = "查看详情";
    String svgPath = "assets/svg/public/icon_learn_know.svg";

    if(widget.knowledgeData.contentTypeEnum == KnowledgeTypeEnum.EN_WORD){
      buttonText = "学习单词";
      svgPath = "assets/svg/public/icon_learn_know.svg";
    }else if(widget.knowledgeData.contentTypeEnum == KnowledgeTypeEnum.EN_PHRASE){
      buttonText = "学习短语";
      svgPath = "assets/svg/public/icon_learn_know.svg";
    }else if(widget.knowledgeData.contentTypeEnum == KnowledgeTypeEnum.EN_SENTENCE){
      buttonText = "学习句子";
      svgPath = "assets/svg/public/icon_learn_know.svg";
    }else if(widget.knowledgeData.contentTypeEnum == KnowledgeTypeEnum.EN_TEXT){
      buttonText = "阅读文章";
      svgPath = "assets/svg/public/icon_read_text.svg";
    }else if(widget.knowledgeData.contentTypeEnum == KnowledgeTypeEnum.EN_SONG){
      buttonText = "播放音乐";
      svgPath = "assets/svg/public/song.svg";
    }else if(widget.knowledgeData.contentTypeEnum == KnowledgeTypeEnum.EN_REVEAL){
      buttonText = "听读时文";
      svgPath = "assets/svg/public/icon_listen_rev.svg";
    }else if(widget.knowledgeData.contentTypeEnum == KnowledgeTypeEnum.SCRIPT){
      buttonText = "进入剧场";
      svgPath = "assets/svg/public/icon_script.svg";
    }

    if(widget.knowledgeData.rights?.allLock == true){
      svgPath = "assets/svg/public/icon_lock_solid.svg";
    }

    String favoriteSvg = "";
    if(widget.knowledgeData.isDictionary){
      if(widget.knowledgeData.favorited == true){
        favoriteSvg = "assets/svg/public/icon_out_memory.svg";
      }else{
        favoriteSvg = "assets/svg/public/icon_out_memory.svg";
      }
    }else{
      if(widget.knowledgeData.favorited == true){
        favoriteSvg = "assets/svg/public/icon_like.svg";
      }else{
        favoriteSvg = "assets/svg/public/icon_dislike.svg";
      }
    }


    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 10.wMin),
      child: Row(
        children: [

          Visibility(
            visible: widget.knowledgeData.favorited != null,
            child: TapScaleWidget(
              onTap: () async{
                if(widget.knowledgeData.isDictionary){
                  onMemory();
                }else{
                  onFavorite();
                }
              },
              sclae: 1.05,
              child: Container(
                width: 40.wMin,
                height: 40.wMin,
                margin: EdgeInsets.only(right: 8.wMin),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.wMin),
                  color: AppTheme.cSurfaceLayerElevated.color,
                  border: Border.all(
                    color: AppTheme.cBorderSubtle.color,
                    width: 0.8.wMin,
                  ),
                ),
                child: SvgPicture.asset(
                  favoriteSvg,
                  width: 24.wMin,
                  colorFilter: widget.knowledgeData.favorited == true ? null : ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                ),
              ),
            ),
          ),

          Expanded(
            child: ButtonWidget(
              text: buttonText,
              width: double.infinity,
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: color.withValues(alpha: 0.45),
              border: Border.all(
                color: color.withValues(alpha: 0.12),
                width: 0.8.wMin,
              ),
              fontColor: AppTheme.cTextPrimary.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 4.wMin),
                child: SvgPicture.asset(
                  svgPath,
                  width: 18.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


}


class KnowledgeCardImageWidget extends StatefulWidget {
  final KnowledgeCommonEntityList knowledgeData;
  const KnowledgeCardImageWidget({super.key, required this.knowledgeData});

  @override
  State<KnowledgeCardImageWidget> createState() => _KnowledgeCardImageWidgetState();
}

class _KnowledgeCardImageWidgetState extends State<KnowledgeCardImageWidget> {


  @override
  void initState(){
    super.initState();

  }


  @override
  Widget build(BuildContext context) {

    return AspectRatio(
      aspectRatio: widget.knowledgeData.isDictionary ? 1 : 4 / 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: PlayVideoWidget(
              videoUrl: widget.knowledgeData.coverVideo?.url,
              imageUrl: widget.knowledgeData.coverImage?.url,
            ),
          ),
    
          Positioned(
            top: 10.wMin,
            left: 10.wMin,
            child: _buildTagWidget(widget.knowledgeData.contentTypeTitle, defaultBorderRadius: 6.wMin),
          ),
    
          Positioned(
            bottom: 10.wMin,
            right: 10.wMin,
            child: Row( 
              children: [
                // _buildImageTagWidget("assets/svg/public/Storyboard.svg", "6 幕"),
                // SizedBox(width: 8.wMin),
                Visibility(
                  visible: widget.knowledgeData.duration != null,
                  child: _buildImageTagWidget(
                    "assets/svg/public/icon_duration1.svg", 
                    DateFormatUtil.convertSecondsToMinSec(widget.knowledgeData.duration??0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildImageTagWidget(String svg, String text){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: Colors.black.withValues(alpha: 0.35),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svg,
            height: 16.wMin,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          SizedBox(width: 4.wMin),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagWidget(KnowledgeCommonEntityListGloss? tag, {double defaultBorderRadius = 99}){
    if (tag == null) return Container();
    final themeText = StyleUtils.getCurrentThemeText(tag.style);

    TextStyle? textStyle = StyleUtils.getTextStyle(tag.style);

    LanguageText? gloss = LearningLangUtils.getgetShowForLLN(tag.gloss);
    final text = gloss?.text ?? "";
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        color: ColorUtils.parseColor(themeText?.backgroundColor) ?? Colors.transparent,
        borderRadius: BorderRadius.circular(themeText?.borderRadius ?? defaultBorderRadius.wMin),
        border: Border.all(
          color: ColorUtils.parseColor(themeText?.borderColor) ?? Colors.transparent,
          width: 0.8.wMin,
        ),
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }

}


class KnowledgeCardPlayAudioWidget extends StatefulWidget {
  final Pronunciations? pronunciation;
  const KnowledgeCardPlayAudioWidget({super.key, this.pronunciation});

  @override
  State<KnowledgeCardPlayAudioWidget> createState() => _KnowledgeCardPlayAudioWidgetState();
}

class _KnowledgeCardPlayAudioWidgetState extends State<KnowledgeCardPlayAudioWidget> {

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {

    String phonetic = "";
    if(widget.pronunciation?.phonetic != null){
      phonetic = " /${widget.pronunciation?.phonetic??""}/";
    }

    return TapScaleWidget(
      onTap: () async{
        if(widget.pronunciation?.audioUrl == null) return;
        
        try {
          isPlaying = true;
          if(mounted) setState(() {});
          await PlayAudioUtils.instance.playSingle(widget.pronunciation?.audioUrl);
        } finally{
          isPlaying = false;
          if(mounted) setState(() {});
        }
      },
      sclae: 1.03,
      child: Container(
        height: 28.wMin,
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99.wMin),
          color: AppTheme.cSurfaceLayerElevated.color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/icon_speaker.json',
              width: 20.wMin,
              height: 20.wMin,
              key: ValueKey(isPlaying),
              repeat: true,
              animate: isPlaying,
            ),
            SizedBox(width: 4.wMin),
            Text(
              "${widget.pronunciation?.national??''}$phonetic",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
                fontFamily: "LXGWWenKaiGBScreen",
              ),
            ),
          ],
        ),
      ),
    );

  }
}
