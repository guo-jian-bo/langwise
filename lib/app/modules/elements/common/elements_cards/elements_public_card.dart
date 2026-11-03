import 'dart:io';
import 'dart:math' as math;

import 'package:api/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../routes/routes.dart';
import '../../../management/common/commons.dart';
import '../../../management/common/manage_select_knowledge_table/view.dart';
import '../../../management/common/manage_select_knowledge_table/views/select_semantic_widget.dart';
import '../../../management/utils/utils.dart';
import '../elements_card_star_level_widget.dart';
import '../../model/elements_detils_data_model.dart';
import '../../utils/elements_page_utils.dart';
import '../elements_public_widgets.dart';

class ElementsPublicCard extends StatefulWidget {
  final double? height;
  final double? width;
  final ElementsCardEntityDatas? data;
  final bool isManagement;

  /// 高亮文本(暂时用于句子)
  final List<ElementsDetilsDataHighlightModel>? sentenceHighlights;
  const ElementsPublicCard({
    super.key,
    this.height,
    this.width,
    required this.data,
    this.isManagement = false,
    this.sentenceHighlights,
  });

  @override
  State<ElementsPublicCard> createState() => _ElementsPublicCardState();
}



class _ElementsPublicCardState extends State<ElementsPublicCard> {
  int _playingIndex = -1;

  Future<void> _togglePlay(int index) async {
    if (widget.data?.pronunciations == null) return;
    final String audioUrl = (widget.data?.pronunciations?[index]?.audioUrl ?? '').trim();
    if (audioUrl.isEmpty) return;

    if (_playingIndex == index) {
      await PlayAudioUtils.instance.stopAll();
      _playingIndex = -1;
      if (mounted) setState(() {});
      return;
    }

    await PlayAudioUtils.instance.stopAll();
    _playingIndex = index;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(audioUrl);
    _playingIndex = -1;
    if (mounted) setState(() {});
  }

  Future<void> _toDetails() async {
    if (widget.data?.contentId == null) return;
    await ElementsPageUtils.jumpElementsPage(
      contentId: widget.data?.contentId,
      contentType: widget.data?.contentType,
      semanticId: widget.data?.semanticId,
      styleId: null,
      dialect: null,
      semanticIds: widget.data?.semanticIds,
      content: widget.data?.content,
      pos: widget.data?.pos,
      isManagement: widget.isManagement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        _toDetails();
      },
      sclae: 1.01,
      child: Container(
        width: widget.width ?? 334.wMin,
        height: widget.height ?? 534.wMin,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
        ),
        child: Column(
          children: [
            _buildImageWidget(),
            _buildContentWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PlayVideoWidget(
            videoUrl: widget.data?.video?.videoUrl,
            firstFrameUrl: widget.data?.video?.firstFrameUrl,
            imageUrl: widget.data?.imageUrl,
            isManagement: widget.isManagement,
          ),
          Positioned(
            left: 8.wMin,
            top: 8.wMin,
            child: Visibility(
              visible: widget.data?.posTitle != null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: Colors.black45,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  widget.data?.posTitle ?? "",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    final pronunciations = widget.data?.pronunciations ?? [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.wMin),
          _buildContentTextWidget(),
          SizedBox(height: 10.wMin),
          Obx(() {
            final gloss = LearningLangUtils.getShowLList(widget.data?.gloss);
            return Text(
              gloss?.text ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            );
          }),
          SizedBox(height: 8.wMin),
          Row(
            spacing: 16.wMin,
            children: List.generate(pronunciations.length, (index) {
              return ElementsPronunciationCapsuleButton(
                label: pronunciations[index]?.national ?? "",
                isSelected: false,
                isPlaying: _playingIndex == index,
                onTap: () {
                  _togglePlay(index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 内容文本，高亮数组为空时保持原始展示。
  Widget _buildContentTextWidget() {
    final String contentText = widget.data?.content ?? '';
    final highlightList = (widget.sentenceHighlights ?? const <ElementsDetilsDataHighlightModel?>[])
        .whereType<ElementsDetilsDataHighlightModel>()
        .where((item) => (item.start ?? -1) >= 0 && (item.end ?? -1) > (item.start ?? -1) && (item.end ?? 0) <= contentText.length)
        .toList();
    final textStyle = TextStyle(
      fontSize: 28.wMin,
      color: AppTheme.cTextPrimary.color,
      fontWeight: FontWeight.w500,
    );
    if (highlightList.isEmpty) {
      return Text(
        contentText,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }

    highlightList.sort((a, b) => (a.start ?? 0).compareTo(b.start ?? 0));
    final spanList = <TextSpan>[];
    int cursor = 0;
    for (final item in highlightList) {
      final start = item.start ?? 0;
      final end = item.end ?? start;
      if (start < cursor) continue;
      if (start > cursor) spanList.add(TextSpan(text: contentText.substring(cursor, start)));
      spanList.add(TextSpan(
        text: contentText.substring(start, end),
        style: TextStyle(color: item.highlightColor),
      ));
      cursor = end;
    }
    if (cursor < contentText.length) spanList.add(TextSpan(text: contentText.substring(cursor)));
    return Text.rich(
      TextSpan(style: textStyle, children: spanList),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}



class ElementsDictStampCard extends StatefulWidget {
  final KnowledgeCommonEntityList? data;
  final int? subTitleMaxLines;
  final int? titleMaxLines;
  final String? badgeText;
  final Color? borderColor;
  final bool isManagement;

  /// 是否根据系统设置显示视频
  final bool settingShowVideo;
  const ElementsDictStampCard({
    super.key,
    this.data,
    this.subTitleMaxLines = 3,
    this.titleMaxLines,
    this.badgeText,
    this.borderColor,
    this.isManagement = false,
    this.settingShowVideo = true,
  });

  @override
  State<ElementsDictStampCard> createState() => _ElementsDictStampCardState();
}

class _ElementsDictStampCardState extends State<ElementsDictStampCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTranslucentBase.color,
        border: Border.all(
          color: widget.borderColor ?? AppTheme.cBorderDefault.color,
          width: 1.wMin,
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PlayVideoWidget(
            videoUrl: widget.settingShowVideo ? widget.data?.coverVideo?.url : '',
            firstFrameUrl: widget.data?.coverImage?.url,
            imageUrl: widget.data?.coverImage?.url,
            isManagement: widget.isManagement,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0),
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.data?.title ?? '',
                  maxLines: widget.titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx((){
                  String? subTitle = LearningLangUtils.getShowLList(widget.data?.subTitles)?.text;
                  if(subTitle == null){
                    if(widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_SONG
                      || widget.data?.contentTypeEnum == KnowledgeTypeEnum.SCRIPT
                      || widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_REVEAL){
                      subTitle = widget.data?.subTitle;
                    }
                  }
                  if(subTitle == null) return Container();
                  return Text(
                    subTitle,
                    maxLines: widget.subTitleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  );

                }),
                
              ],
            ),
          ),
          if ((widget.badgeText ?? '').trim().isNotEmpty)
            Positioned(
              top: 8.wMin,
              left: 8.wMin,
              child: Container(
                constraints: BoxConstraints(maxWidth: 120.wMin),
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999.wMin),
                  color: Colors.black.withValues(alpha: 0.45),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  widget.badgeText!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



class ElementsDictCiteCard extends StatelessWidget {
  final KnowledgeCommonEntityList? data;
  final Color? bgColor;
  final Color? borderColor;
  const ElementsDictCiteCard({super.key, this.data, this.bgColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    ConfigController configController = Get.find<ConfigController>();
    final posColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, data?.pos ?? '');
    Color posBgColor = posColor?.color?.bgColor ?? (AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2));
    Color posTextColor = posColor?.color?.textColor ?? (AppTheme.cSurfaceBrand.color);

    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: bgColor ?? AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: borderColor ?? AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data?.title ?? '',
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Obx((){
            String? subTitle = LearningLangUtils.getShowLList(data?.subTitles)?.text;
            if(subTitle == null && data?.posTitle == null) return Container();
            return Container(
              margin: EdgeInsets.only(top: 8.wMin),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: data?.posTitle?.isNotEmpty ?? false,
                    child: Container(
                      margin: EdgeInsets.only(right: 4.wMin),
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.wMin),
                        color: posBgColor,
                      ),
                      child: Text(
                        data?.posTitle ?? "",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: posTextColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      subTitle??"",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}



class ElementsDictReadCard extends StatefulWidget {
  final KnowledgeCommonEntityList? data;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCardStarArea;
  final List<ElementsDetilsDataHighlightModel>? sentenceHighlights;
  final List<ElementsTitleHighlightRule>? titleHighlightRules;
  final bool isManagement;
  final Widget? bottomWidget;
  final Widget? imageButtonWidget;
  final VoidCallback? onDetailBack;
  const ElementsDictReadCard({
    super.key,
    this.data,
    this.onTap,
    this.onLongPress,
    this.showCardStarArea = false,
    this.sentenceHighlights,
    this.titleHighlightRules,
    this.isManagement = false,
    this.bottomWidget,
    this.imageButtonWidget,
    this.onDetailBack,
  });

  @override
  State<ElementsDictReadCard> createState() => _ElementsDictReadCardState();
}

class _ElementsDictReadCardState extends State<ElementsDictReadCard> {
  int _playingIndex = -1;

  Future<void> _togglePlay(int index) async {
    final String audioUrl = (widget.data?.params?.data?.pronunciations?[index]?.audioUrl ?? '').trim();
    if (audioUrl.isEmpty) return;

    if (_playingIndex == index) {
      await PlayAudioUtils.instance.stopAll();
      _playingIndex = -1;
      if (mounted) setState(() {});
      return;
    }

    await PlayAudioUtils.instance.stopAll();
    _playingIndex = index;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(audioUrl);
    _playingIndex = -1;
    if (mounted) setState(() {});
  }

  Future<void> _toDetails() async {
    if (widget.data?.contentId == null) return;
    await ElementsPageUtils.jumpElementsPage(
      contentId: widget.data?.contentId,
      contentType: widget.data?.contentType,
      semanticId: widget.data?.content?.semanticId,
      styleId: null,
      dialect: null,
      content: widget.data?.title,
      pos: widget.data?.pos,
      isManagement: widget.isManagement,
    );
    widget.onDetailBack?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ElementsCardStar? cardStar = widget.data?.memberStudy?.starInfo;
    String? videoFirstFrameUrl = widget.data?.coverImage?.url;
    if(widget.isManagement){
      if(widget.data?.coverVideo == null){
        videoFirstFrameUrl = null;
      }
    }

    return TapScaleWidget(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
          return;
        }
        _toDetails();
      },
      onLongPress: widget.onLongPress,
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16.wMin,
          widget.showCardStarArea ? 0 : 16.wMin,
          16.wMin,
          16.wMin,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgSecondary,
          border: Border.all(
            color: ColorUtils.parseColor(cardStar?.color) ?? AppTheme.cBorderThin.color,
            width: 2.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showCardStarArea) ...[
              ElemenetsCardStarLevelWidget(star: cardStar),
              SizedBox(height: 6.wMin),
            ],
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.wMin),
                child: Stack(
                  children: [
                    PlayVideoWidget(
                      videoUrl: widget.data?.coverVideo?.url,
                      firstFrameUrl: videoFirstFrameUrl,
                      imageUrl: widget.data?.coverImage?.url,
                      isManagement: widget.isManagement,
                    ),
                    Positioned(
                      top: 8.wMin,
                      right: 8.wMin,
                      child: SizedBox(child: widget.imageButtonWidget),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.wMin),
            _buildTagListWidget(context),
            SizedBox(height: 8.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx((){
                      final subTitle = LearningLangUtils.getShowLList(widget.data?.subTitles);
                      return ElementsCardReadTextWidget(
                        titleText: widget.data?.title ?? '',
                        subTitleText: subTitle?.text??'',
                        sentenceHighlights: widget.sentenceHighlights,
                        titleHighlightRules: widget.titleHighlightRules,
                      );
                    }),
                  ),
                  SizedBox(height: 6.wMin),
                  Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
                  _buildButtonsWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagListWidget(BuildContext context) {
    List<KnowledgeCommonEntityListGloss?> tags = widget.data?.tags ?? [];

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false, // 隐藏滚动条
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 6.wMin,
          children: List.generate(tags.length, (index) {
            return _buildTagWidget(tags[index]);
          }),
        ),
      ),
    );
  }

  Widget _buildTagWidget(KnowledgeCommonEntityListGloss? tag, {double defaultBorderRadius = 6, double defaultSize = 16}) {
    if (tag == null) return Container();
    final themeText = StyleUtils.getCurrentThemeText(tag.style);

    TextStyle? textStyle = StyleUtils.getTextStyle(tag.style, defaultSize: defaultSize);

    return Obx((){
      LanguageText? gloss = LearningLangUtils.getShowLList(tag.gloss);
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
    });
  }

  Widget _buildButtonsWidget() {
    List<Pronunciations?> pronunciations = widget.data?.params?.data?.pronunciations ?? [];

    return Container(
      padding: EdgeInsets.only(top: 10.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(child: widget.bottomWidget),
          Row(
            children: [
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
                        children: List.generate(pronunciations.length, (index) {
                          return ElementsPronunciationCapsuleButton(
                            label: pronunciations[index]?.national ?? "",
                            phonetic: pronunciations[index]?.phonetic,
                            isPlaying: _playingIndex == index,
                            onTap: () => _togglePlay(index),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Text(
                "详情",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SvgPicture.asset(
                "assets/svg/public/icon_w_arrow_right.svg",
                width: 18.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
              )
            ],
          ),
        ],
      ),
    );
  }
}


class ElementsSelectKnowledgeCard extends StatelessWidget {
  final UnitKnowledgePointsEntityKnowledgeList? data;
  final bool selected;
  final bool isNew;
  final bool showNewOld;
  final bool isManagement;
  final void Function()? onTap;
  final Widget? bottomWidget;
  const ElementsSelectKnowledgeCard({
    super.key,
    this.data,
    this.selected = false,
    this.isNew = false,
    this.showNewOld = false,
    this.isManagement = false,
    this.onTap,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    String titleText = data?.content ?? '';
    

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceTranslucentBase.color,
          border: Border.all(
            color: selected ? AppTheme.cSurfaceBrand.color : AppTheme.cBorderThin.color,
            width: 1.5.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.wMin),
                child: Stack(
                  children: [
                    PlayVideoWidget(
                      videoUrl: data?.video?.videoUrl,
                      firstFrameUrl: data?.video?.firstFrameUrl,
                      imageUrl: data?.imageUrl,
                      isManagement: isManagement,
                    ),
                    Positioned(
                      top: 16.wMin,
                      left: 16.wMin,
                      child: _buildStatusBadge(isNew),
                    ),
                    Positioned(
                      right: 16.wMin,
                      top: 16.wMin,
                      child: SvgPicture.asset(
                        selected ? "assets/svg/public/icon_check2.svg" : "assets/svg/public/icon_uncheck1.svg",
                        width: 32.wMin,
                      ),
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 8.wMin),
            _buildTagListWidget(context),
            SizedBox(height: 8.wMin),
            Expanded(
              child: Obx((){
                String subTitleText = LearningLangUtils.getShowLList(data?.gloss)?.text??'';
                return ElementsCardReadTextWidget(titleText: titleText, subTitleText: subTitleText);
              }),
            ),
            SizedBox(child: bottomWidget),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isNew) {
    if (!showNewOld) return const SizedBox.shrink();
    final color = isNew ? const Color(0xFF65A30D) : const Color(0xFFF97316);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.wMin),
      ),
      child: Text(
        isNew ? '新知' : '旧识',
        style: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cStaticWhite.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTagListWidget(BuildContext context) {
    List<UnitKnowledgePointsEntityKnowledgeListTags?> tags = data?.tags ?? [];

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false, // 隐藏滚动条
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 6.wMin,
          children: List.generate(tags.length, (index) {
            return _buildTagWidget(tags[index]);
          }),
        ),
      ),
    );
  }

  Widget _buildTagWidget(UnitKnowledgePointsEntityKnowledgeListTags? tag, {double defaultBorderRadius = 6, double defaultSize = 16}) {
    if (tag == null) return Container();
    final themeText = StyleUtils.getCurrentThemeText(tag.style);

    TextStyle? textStyle = StyleUtils.getTextStyle(tag.style, defaultSize: defaultSize);

    LanguageText? gloss = LearningLangUtils.getShowLList(tag.gloss);
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

/// 卡片中部标题/副标题区域，统一处理高亮和自适应排版。
class ElementsCardReadTextWidget extends StatelessWidget {
  /// 主标题文本，通常展示原文。
  final String titleText;

  /// 副标题文本，通常展示释义或翻译。
  final String subTitleText;

  /// 句子命中的显式高亮区间。
  final List<ElementsDetilsDataHighlightModel>? sentenceHighlights;

  /// 基于关键字规则补充的标题高亮配置。
  final List<ElementsTitleHighlightRule>? titleHighlightRules;

  static const double _readTitleMaxFont = 30;
  static const double _readTitleMinFont = 16;
  static const double _readSubTitleMaxFont = 18;
  static const double _readSubTitleMinFont = 14;
  static const int _readTitleMaxLines = 5;
  static const double _readTitleLineHeight = 1.2;
  static const double _readSubTitleLineHeight = 1.2;
  static const double _readTextSpacing = 6;
  static const double _readMeasureReservedWidth = 6;
  static const double _readMeasureReservedHeight = 10;

  const ElementsCardReadTextWidget({
    super.key,
    required this.titleText,
    required this.subTitleText,
    this.sentenceHighlights,
    this.titleHighlightRules,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSubTitle = subTitleText.isNotEmpty;
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final List<ElementsDetilsDataHighlightModel> highlightList = <ElementsDetilsDataHighlightModel>[
      ...(sentenceHighlights ?? const <ElementsDetilsDataHighlightModel?>[])
          .whereType<ElementsDetilsDataHighlightModel>()
          .where((item) => (item.start ?? -1) >= 0 && (item.end ?? -1) > (item.start ?? -1) && (item.end ?? 0) <= titleText.length),
      ..._buildRuleBasedTitleHighlights(titleText),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final _ReadTextLayoutResult layout = _resolveReadTextLayout(
          context: context,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          titleText: titleText,
          subTitleText: subTitleText,
        );
        final TextStyle titleStyle = TextStyle(
          fontSize: layout.titleFontSize,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
          height: _readTitleLineHeight,
        );
        final TextStyle subTitleStyle = TextStyle(
          fontSize: layout.subTitleFontSize,
          color: AppTheme.cTextSecondary.color,
          fontWeight: FontWeight.w400,
          height: _readSubTitleLineHeight,
        );
        final StrutStyle titleStrutStyle = _buildReadTextStrutStyle(titleStyle);
        final StrutStyle subTitleStrutStyle = _buildReadTextStrutStyle(subTitleStyle);

        return Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (titleText.isNotEmpty)
                highlightList.isEmpty
                    ? Text(
                        titleText,
                        maxLines: layout.titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                          strutStyle: titleStrutStyle,
                          textScaler: textScaler,
                      )
                    : Text.rich(
                        TextSpan(
                          style: titleStyle,
                          children: _buildHighlightTitleSpans(titleText, highlightList),
                        ),
                        maxLines: layout.titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                          strutStyle: titleStrutStyle,
                          textScaler: textScaler,
                      ),
              if (hasSubTitle) ...[
                if (titleText.isNotEmpty) SizedBox(height: _readTextSpacing.wMin),
                Text(
                  subTitleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: subTitleStyle,
                    strutStyle: subTitleStrutStyle,
                    textScaler: textScaler,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 联合测量标题与副标题，在有限高度里选出标题优先的最优显示方案。
  _ReadTextLayoutResult _resolveReadTextLayout({
    required BuildContext context,
    required double maxWidth,
    required double maxHeight,
    required String titleText,
    required String subTitleText,
  }) {
    final double measureMaxWidth = math.max(0, maxWidth - _readMeasureReservedWidth);
    final double measureMaxHeight = math.max(0, maxHeight - _readMeasureReservedHeight);
    if (measureMaxWidth <= 0 || measureMaxHeight <= 0 || maxHeight == double.infinity) {
      return _ReadTextLayoutResult(
        titleFontSize: _readTitleMaxFont.wMin,
        subTitleFontSize: _readSubTitleMaxFont.wMin,
        titleMaxLines: 1,
      );
    }

    if (titleText.isEmpty && subTitleText.isEmpty) {
      return _ReadTextLayoutResult(
        titleFontSize: _readTitleMaxFont.wMin,
        subTitleFontSize: _readSubTitleMaxFont.wMin,
        titleMaxLines: 1,
      );
    }

    final TextDirection textDirection = Directionality.of(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    if (titleText.isEmpty) {
      return _resolveSubTitleOnlyLayout(
        textDirection: textDirection,
        textScaler: textScaler,
        maxWidth: measureMaxWidth,
        maxHeight: measureMaxHeight,
        subTitleText: subTitleText,
      );
    }

    if (subTitleText.isEmpty) {
      return _resolveTitleOnlyLayout(
        textDirection: textDirection,
        textScaler: textScaler,
        maxWidth: measureMaxWidth,
        maxHeight: measureMaxHeight,
        titleText: titleText,
      );
    }

    _ReadTextLayoutCandidate? bestCandidate;
    for (int titleFont = _readTitleMaxFont.toInt(); titleFont >= _readTitleMinFont.toInt(); titleFont--) {
      final TextStyle titleStyle = TextStyle(
        fontSize: titleFont.wMin,
        fontWeight: FontWeight.w600,
        height: _readTitleLineHeight,
      );

      for (int subTitleFont = _readSubTitleMaxFont.toInt(); subTitleFont >= _readSubTitleMinFont.toInt(); subTitleFont--) {
        final TextStyle subTitleStyle = TextStyle(
          fontSize: subTitleFont.wMin,
          fontWeight: FontWeight.w400,
          height: _readSubTitleLineHeight,
        );
        final TextPainter subTitlePainter = _measureTextPainter(
          textDirection: textDirection,
          textScaler: textScaler,
          maxWidth: measureMaxWidth,
          text: subTitleText,
          style: subTitleStyle,
          maxLines: 1,
        );
        final double gapHeight = _readTextSpacing.wMin;
        final double availableTitleHeight = measureMaxHeight - subTitlePainter.height - gapHeight;
        if (availableTitleHeight <= 0) continue;

        final _ReadTitleMeasureResult? titleMeasure = _measureFittingTitle(
          textDirection: textDirection,
          textScaler: textScaler,
          maxWidth: measureMaxWidth,
          maxHeight: availableTitleHeight,
          titleText: titleText,
          titleStyle: titleStyle,
        );
        if (titleMeasure == null) continue;

        final int titleMaxLines = titleMeasure.maxLines;
        final TextPainter titlePainter = titleMeasure.painter;
        final double totalHeight = titlePainter.height + gapHeight + subTitlePainter.height;
        if (totalHeight > measureMaxHeight + 0.5) continue;

        final _ReadTextLayoutCandidate candidate = _ReadTextLayoutCandidate(
          titleFontSize: titleFont.wMin,
          subTitleFontSize: subTitleFont.wMin,
          titleMaxLines: titleMaxLines,
          titleVisibleCharacters: _measureVisibleCharacters(painter: titlePainter, textLength: titleText.length, maxWidth: measureMaxWidth),
          subTitleVisibleCharacters: _measureVisibleCharacters(
            painter: subTitlePainter,
            textLength: subTitleText.length,
            maxWidth: measureMaxWidth,
          ),
          titleIsComplete: !titlePainter.didExceedMaxLines,
          subTitleIsComplete: !subTitlePainter.didExceedMaxLines,
        );
        if (bestCandidate == null || candidate.isBetterThan(bestCandidate)) bestCandidate = candidate;
      }
    }

    if (bestCandidate != null) return bestCandidate.toLayoutResult();

    return _ReadTextLayoutResult(
      titleFontSize: _readTitleMinFont.wMin,
      subTitleFontSize: _readSubTitleMinFont.wMin,
      titleMaxLines: 1,
    );
  }

  /// 只有标题时，优先保证展示内容更多，其次才是字号更大。
  _ReadTextLayoutResult _resolveTitleOnlyLayout({
    required TextDirection textDirection,
    required TextScaler textScaler,
    required double maxWidth,
    required double maxHeight,
    required String titleText,
  }) {
    _ReadTextLayoutCandidate? bestCandidate;
    for (int titleFont = _readTitleMaxFont.toInt(); titleFont >= _readTitleMinFont.toInt(); titleFont--) {
      final TextStyle titleStyle = TextStyle(
        fontSize: titleFont.wMin,
        fontWeight: FontWeight.w600,
        height: _readTitleLineHeight,
      );
      final _ReadTitleMeasureResult? titleMeasure = _measureFittingTitle(
        textDirection: textDirection,
        textScaler: textScaler,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        titleText: titleText,
        titleStyle: titleStyle,
      );
      if (titleMeasure == null) continue;

      final _ReadTextLayoutCandidate candidate = _ReadTextLayoutCandidate(
        titleFontSize: titleFont.wMin,
        subTitleFontSize: _readSubTitleMaxFont.wMin,
        titleMaxLines: titleMeasure.maxLines,
        titleVisibleCharacters: _measureVisibleCharacters(painter: titleMeasure.painter, textLength: titleText.length, maxWidth: maxWidth),
        subTitleVisibleCharacters: 0,
        titleIsComplete: !titleMeasure.painter.didExceedMaxLines,
        subTitleIsComplete: true,
      );
      if (bestCandidate == null || candidate.isBetterThan(bestCandidate)) bestCandidate = candidate;
    }

    return bestCandidate?.toLayoutResult() ??
        _ReadTextLayoutResult(
          titleFontSize: _readTitleMinFont.wMin,
          subTitleFontSize: _readSubTitleMaxFont.wMin,
          titleMaxLines: 1,
        );
  }

  /// 只有副标题时，直接选出能容纳一行且字号最大的方案。
  _ReadTextLayoutResult _resolveSubTitleOnlyLayout({
    required TextDirection textDirection,
    required TextScaler textScaler,
    required double maxWidth,
    required double maxHeight,
    required String subTitleText,
  }) {
    _ReadTextLayoutCandidate? bestCandidate;
    for (int subTitleFont = _readSubTitleMaxFont.toInt(); subTitleFont >= _readSubTitleMinFont.toInt(); subTitleFont--) {
      final TextStyle subTitleStyle = TextStyle(
        fontSize: subTitleFont.wMin,
        fontWeight: FontWeight.w400,
        height: _readSubTitleLineHeight,
      );
      final TextPainter subTitlePainter = _measureTextPainter(
        textDirection: textDirection,
        textScaler: textScaler,
        maxWidth: maxWidth,
        text: subTitleText,
        style: subTitleStyle,
        maxLines: 1,
      );
      if (subTitlePainter.height > maxHeight + 0.5) continue;

      final _ReadTextLayoutCandidate candidate = _ReadTextLayoutCandidate(
        titleFontSize: _readTitleMaxFont.wMin,
        subTitleFontSize: subTitleFont.wMin,
        titleMaxLines: 1,
        titleVisibleCharacters: 0,
        subTitleVisibleCharacters: _measureVisibleCharacters(
          painter: subTitlePainter,
          textLength: subTitleText.length,
          maxWidth: maxWidth,
        ),
        titleIsComplete: true,
        subTitleIsComplete: !subTitlePainter.didExceedMaxLines,
      );
      if (bestCandidate == null || candidate.isBetterThan(bestCandidate, preferTitle: false)) bestCandidate = candidate;
    }

    return bestCandidate?.toLayoutResult() ??
        _ReadTextLayoutResult(
          titleFontSize: _readTitleMaxFont.wMin,
          subTitleFontSize: _readSubTitleMinFont.wMin,
          titleMaxLines: 1,
        );
  }

  /// 用 TextPainter 测量真实排版结果，避免视觉占位和计算占位脱节。
  TextPainter _measureTextPainter({
    required TextDirection textDirection,
    required TextScaler textScaler,
    required double maxWidth,
    required String text,
    required TextStyle style,
    required int maxLines,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: maxLines,
      strutStyle: _buildReadTextStrutStyle(style),
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);
    return painter;
  }

  /// 直接试排不同最大行数，避免单行高度估算导致可用空间被误判。
  _ReadTitleMeasureResult? _measureFittingTitle({
    required TextDirection textDirection,
    required TextScaler textScaler,
    required double maxWidth,
    required double maxHeight,
    required String titleText,
    required TextStyle titleStyle,
  }) {
    for (int titleMaxLines = _readTitleMaxLines; titleMaxLines >= 1; titleMaxLines--) {
      final TextPainter titlePainter = _measureTextPainter(
        textDirection: textDirection,
        textScaler: textScaler,
        maxWidth: maxWidth,
        text: titleText,
        style: titleStyle,
        maxLines: titleMaxLines,
      );
      if (titlePainter.height <= maxHeight + 0.5) {
        return _ReadTitleMeasureResult(maxLines: titleMaxLines, painter: titlePainter);
      }
    }
    return null;
  }

  /// 统一真实渲染与测量阶段的行高规则，降低字体边界差异带来的溢出误差。
  StrutStyle _buildReadTextStrutStyle(TextStyle style) {
    return StrutStyle(
      fontSize: style.fontSize,
      height: style.height,
      forceStrutHeight: true,
    );
  }

  /// 近似估算当前方案能看到的字符数，用于在截断时比较哪个方案更优。
  int _measureVisibleCharacters({
    required TextPainter painter,
    required int textLength,
    required double maxWidth,
  }) {
    if (!painter.didExceedMaxLines) return textLength;
    final TextPosition position = painter.getPositionForOffset(
      Offset(
        math.max(0, maxWidth - 1),
        math.max(0, painter.height - 1),
      ),
    );
    return position.offset.clamp(0, textLength);
  }

  /// 构建标题高亮片段，保持原顺序输出。
  List<TextSpan> _buildHighlightTitleSpans(
    String titleText,
    List<ElementsDetilsDataHighlightModel> highlightList,
  ) {
    highlightList.sort((a, b) => (a.start ?? 0).compareTo(b.start ?? 0));
    final List<TextSpan> spanList = <TextSpan>[];
    int cursor = 0;
    for (final ElementsDetilsDataHighlightModel item in highlightList) {
      final int start = item.start ?? 0;
      final int end = item.end ?? start;
      if (start < cursor) continue;
      if (start > cursor) spanList.add(TextSpan(text: titleText.substring(cursor, start)));
      spanList.add(TextSpan(
        text: titleText.substring(start, end),
        style: TextStyle(color: item.highlightColor),
      ));
      cursor = end;
    }
    if (cursor < titleText.length) spanList.add(TextSpan(text: titleText.substring(cursor)));
    return spanList;
  }

  /// 根据关键词规则补充标题高亮区间。
  List<ElementsDetilsDataHighlightModel> _buildRuleBasedTitleHighlights(String titleText) {
    if (titleText.isEmpty) return const <ElementsDetilsDataHighlightModel>[];
    final List<ElementsTitleHighlightRule> rules =
        (titleHighlightRules ?? const <ElementsTitleHighlightRule?>[]).whereType<ElementsTitleHighlightRule>().toList();
    if (rules.isEmpty) return const <ElementsDetilsDataHighlightModel>[];

    final String lowerTitleText = titleText.toLowerCase();
    final List<ElementsDetilsDataHighlightModel> result = <ElementsDetilsDataHighlightModel>[];
    for (int i = 0; i < rules.length; i++) {
      final String matchText = rules[i].text.trim();
      if (matchText.isEmpty) continue;
      final int start = lowerTitleText.indexOf(matchText.toLowerCase());
      if (start < 0) continue;
      result.add(
        ElementsDetilsDataHighlightModel(
          text: matchText,
          start: start,
          end: start + matchText.length,
          highlightColor: rules[i].color,
        ),
      );
    }
    return result;
  }
}


class _ReadTextLayoutResult {
  final double titleFontSize;
  final double subTitleFontSize;
  final int titleMaxLines;

  const _ReadTextLayoutResult({
    required this.titleFontSize,
    required this.subTitleFontSize,
    required this.titleMaxLines,
  });
}


class _ReadTitleMeasureResult {
  final int maxLines;
  final TextPainter painter;
  const _ReadTitleMeasureResult({
    required this.maxLines,
    required this.painter,
  });
}

class ElementsTitleHighlightRule {
  final String text;
  final Color? color;

  const ElementsTitleHighlightRule({
    required this.text,
    this.color,
  });
}



class _ReadTextLayoutCandidate {
  final double titleFontSize;
  final double subTitleFontSize;
  final int titleMaxLines;
  final int titleVisibleCharacters;
  final int subTitleVisibleCharacters;
  final bool titleIsComplete;
  final bool subTitleIsComplete;

  const _ReadTextLayoutCandidate({
    required this.titleFontSize,
    required this.subTitleFontSize,
    required this.titleMaxLines,
    required this.titleVisibleCharacters,
    required this.subTitleVisibleCharacters,
    required this.titleIsComplete,
    required this.subTitleIsComplete,
  });

  /// 按标题优先的规则比较两个候选方案。
  bool isBetterThan(_ReadTextLayoutCandidate other, {bool preferTitle = true}) {
    if (!preferTitle) {
      if (subTitleIsComplete != other.subTitleIsComplete) {
        return subTitleIsComplete;
      }
      if (subTitleVisibleCharacters != other.subTitleVisibleCharacters) {
        return subTitleVisibleCharacters > other.subTitleVisibleCharacters;
      }
      return subTitleFontSize > other.subTitleFontSize;
    }

    if (titleIsComplete != other.titleIsComplete) return titleIsComplete;

    if (titleIsComplete) {
      if (titleFontSize != other.titleFontSize) return titleFontSize > other.titleFontSize;
    } else {
      if (titleMaxLines != other.titleMaxLines) return titleMaxLines > other.titleMaxLines;
      if (titleVisibleCharacters != other.titleVisibleCharacters) {
        return titleVisibleCharacters > other.titleVisibleCharacters;
      }
      if (titleFontSize != other.titleFontSize) return titleFontSize > other.titleFontSize;
    }

    if (subTitleIsComplete != other.subTitleIsComplete) return subTitleIsComplete;
    if (subTitleVisibleCharacters != other.subTitleVisibleCharacters) {
      return subTitleVisibleCharacters > other.subTitleVisibleCharacters;
    }
    return subTitleFontSize > other.subTitleFontSize;
  }

  _ReadTextLayoutResult toLayoutResult() {
    return _ReadTextLayoutResult(
      titleFontSize: titleFontSize,
      subTitleFontSize: subTitleFontSize,
      titleMaxLines: titleMaxLines,
    );
  }
}



class ElementsCardManageButtonsWidget extends StatefulWidget {
  final KnowledgeCommonEntityList? data;
  final int? moduleId;
  final int? unitId;
  final void Function()? onRefresh;
  const ElementsCardManageButtonsWidget({super.key, this.data, this.moduleId, this.unitId, this.onRefresh});

  @override
  State<ElementsCardManageButtonsWidget> createState() => _ElementsCardManageButtonsWidgetState();
}

class _ElementsCardManageButtonsWidgetState extends State<ElementsCardManageButtonsWidget> {
  /// 复制id
  void _copyId() {
    Clipboard.setData(ClipboardData(text: widget.data?.contentId?.toString() ?? ''));
    ToastUtils.showToast(text: "复制成功", type: ToastType.success);
  }

  /// 跳转至内容页
  Future<void> _jumpToContent() async {
    if (widget.data?.contentId == null) return;
    String routes = "";
    if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_WORD) {
      routes = Routes.MANAGE_WORD;
    } else if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_PHRASE) {
      routes = Routes.MANAGE_PHRASE;
    } else if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_SENTENCE) {
      routes = Routes.MANAGE_SENTENCE;
    } else if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_TEXT) {
      routes = Routes.MANAGE_ARTICLE;
    } else if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_SONG) {
      routes = Routes.MANAGE_SONG;
    }
    if (routes.isEmpty) return;

    await ManagePageRegistry.jumpTo(
      routes,
      arguments: {
        "uid": widget.data!.contentId!,
      },
    );
    widget.onRefresh?.call();
  }

  /// 跳转至视觉/题目页面
  Future<void> _jumpToVisual(int type) async {
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': widget.data?.contentType,
        'uid': widget.data?.contentId,
        'semanticId': widget.data?.content?.semanticId,
        "quizOrImage": type,
      },
    );
    widget.onRefresh?.call();
  }

  /// 替换
  Future<void> _showReplace(BuildContext ctx) async {
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
    if (res == null) return;
    if (res == 0) {
      adminEditReplaceSemanticsFunction(context);
    } else {
      adminEditReplaceWordFunction(context);
    }
  }

  /// 管理端替换义方法
  Future<void> adminEditReplaceSemanticsFunction(BuildContext context) async {
    List<EnEntitySemantics>? semantics = await getEnDefinition();
    if (semantics == null) return;
    SelectSemanticManager.show(
      context: context,
      semantics: semantics,
      onOkTap: (List<EnEntitySemantics> semantics) {
        print("选中的语义: ${semantics.length},$semantics");
        if (semantics.isEmpty) return;

        final EnEntitySemantics? selectedSemantics = semantics.firstWhereOrNull((element) => element.isSelected);
        if (selectedSemantics == null) return;

        onEditKnowledgeSemantic(selectedSemantics);
      },
    );
  }

  /// 管理端替换词方法
  Future<void> adminEditReplaceWordFunction(BuildContext context) async {
    List<BaseKnowledge>? selectList = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: [],
      selectMax: 1,
      singleSelectionMode: true,
      showEmptyTip: false,
      currentKnowledgeType: widget.data?.contentTypeEnum ?? KnowledgeTypeEnum.EN_WORD,
      word: widget.data?.title,
    );
    if (selectList == null) return;
    if (selectList.isEmpty) return;

    EnEntitySemantics? selectedSemantics;
    if (selectList.first is EnWordEntity) {
      EnWordEntity entity = selectList.first as EnWordEntity;
      selectedSemantics = entity.selectedSemantics;
    } else if (selectList.first is EnPhraseEntity) {
      EnPhraseEntity entity = selectList.first as EnPhraseEntity;
      selectedSemantics = entity.selectedSemantics;
    }
    if (selectedSemantics == null) return;

    onEditKnowledgeSemantic(selectedSemantics, contentId: selectList.first.uid);
  }

  /// 获取释义
  Future<List<EnEntitySemantics>?> getEnDefinition() async {
    Map<String, dynamic> parameters = {
      'offset': 0,
      'limit': 30,
      "order": "-wordFreq",
    };
    Map<String, dynamic> data = {
      "uid": [widget.data?.contentId!]
    };

    List<EnEntitySemantics>? semantics;

    try {
      ToastUtils.showLoading();
      if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_WORD) {
        //单词
        final ListResponseEntity<EnWordEntity>? response = await ManageSelectQuziKnowledge.getEnWordKnowledgeList(
          parameters: parameters,
          data: data,
        );
        if ((response?.datas ?? []).isEmpty) {
          ToastUtils.showToast(text: "暂无数据");
          return null;
        }
        final EnWordEntity enWord = response!.datas!.first;
        semantics = enWord.semantics!.map((s) => s.copyWith(language: "en")).toList();
      } else if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_PHRASE) {
        //短语
        final ListResponseEntity<EnPhraseEntity>? response = await ManageSelectQuziKnowledge.getEnPhraseKnowledgeList(
          parameters: parameters,
          data: data,
        );
        if ((response?.datas ?? []).isEmpty) {
          ToastUtils.showToast(text: "暂无数据");
          return null;
        }
        final EnPhraseEntity enPhrase = response!.datas!.first;
        semantics = enPhrase.semantics!.map((s) => s.copyWith(language: "en")).toList();
      }
      if (semantics == null) return null;
      for (final EnEntitySemantics s in semantics) {
        if (s.uid == widget.data?.content?.semanticId) {
          s.isSelected = true;
        }
      }
      return semantics;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }

    return null;
  }

  /// 替换语义接口
  Future<void> onEditKnowledgeSemantic(EnEntitySemantics selectedSemantics, {int? contentId}) async {
    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.editKnowledgeSemantic(
        unitId: widget.unitId,
        knowledgeId: widget.data?.knowledgeId,
        semanticId: selectedSemantics.uid,
        config: RequestConfig(
          requireToken: true,
          parameters: {
            "contentId": contentId,
          },
        ),
      );

      if (response.data == null) {
        throw response.message ?? "未知错误";
      }

      widget.onRefresh?.call();
      ToastUtils.showToast(text: "替换成功", type: ToastType.success);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 句组
  Future<void> jumpToSentenceGroup() async {
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SELECT_SENTENCE_GROUP,
      arguments: {
        "sentenceId": widget.data?.content?.uid,
        "moduleId": widget.moduleId,
        "unitId": widget.unitId,
      },
    );
    if(res != true) return;
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false, // 隐藏滚动条
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildButtonsWidget(),
      ),
    );
  }

  Widget _buildButtonsWidget() {
    if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_WORD || widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_PHRASE) {
      return Row(
        spacing: 4.wMin,
        children: [
          _buildButtonWidget(
            text: "ID ${widget.data?.contentId ?? ''}",
            onTap: _copyId,
          ),
          _buildButtonWidget(
            text: "内容",
            onTap: _jumpToContent,
          ),
          _buildButtonWidget(
            text: "视觉",
            onTap: () => _jumpToVisual(1),
          ),
          _buildButtonWidget(
            text: "题目",
            onTap: () => _jumpToVisual(0),
          ),
          if (widget.unitId != null) ...[
            Builder(
              builder: (context) {
                return _buildButtonWidget(
                  text: "替换",
                  onTap: () => _showReplace(context),
                );
              },
            ),
          ],
        ],
      );
    } else if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_SENTENCE) {
      return Row(
        spacing: 4.wMin,
        children: [
          _buildButtonWidget(
            text: "句 ${widget.data?.contentId ?? ''}",
            onTap: _copyId,
          ),
          _buildButtonWidget(
            text: "内容",
            onTap: _jumpToContent,
          ),
          _buildButtonWidget(
            text: "视觉",
            onTap: () => _jumpToVisual(1),
          ),
          _buildButtonWidget(
            text: "题目",
            onTap: () => _jumpToVisual(0),
          ),
          _buildButtonWidget(
            text: "句组",
            onTap: () => jumpToSentenceGroup(),
          ),
        ],
      );
    } else if (widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_TEXT ||
        widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_SONG ||
        widget.data?.contentTypeEnum == KnowledgeTypeEnum.EN_REVEAL ||
        widget.data?.contentTypeEnum == KnowledgeTypeEnum.SCRIPT) {
      return Row(
        spacing: 4.wMin,
        children: [
          _buildButtonWidget(
            text: "ID ${widget.data?.contentId ?? ''}",
            onTap: _copyId,
          ),
          _buildButtonWidget(
            text: "内容",
            onTap: _jumpToContent,
          ),
          _buildButtonWidget(
            text: "视觉",
            onTap: () => _jumpToVisual(1),
          ),
          _buildButtonWidget(
            text: "题目",
            onTap: () => _jumpToVisual(0),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildButtonWidget({
    required String text,
    void Function()? onTap,
  }) {
    return ButtonWidget(
      text: text,
      padding: EdgeInsets.symmetric(horizontal: 6.wMin),
      height: 32.wMin,
      borderRadius: 8.wMin,
      color: AppTheme.cSurfaceLayerElevated.color,
      border: Border.all(
        color: AppTheme.cBorderThin.color,
        width: 0.8.wMin,
      ),
      fontColor: AppTheme.cTextSecondary.color,
      fontSize: 16.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      onTap: onTap,
    );
  }
}



class ElementsCardManageEditButtonsWidget extends StatefulWidget {
  final KnowledgeCommonEntityList? data;
  final int? unitId;
  final void Function()? onRefresh;
  const ElementsCardManageEditButtonsWidget({super.key, this.data, this.onRefresh, this.unitId});

  @override
  State<ElementsCardManageEditButtonsWidget> createState() => _ElementsCardManageEditButtonsWidgetState();
}

class _ElementsCardManageEditButtonsWidgetState extends State<ElementsCardManageEditButtonsWidget> {
  /// 知识点删除
  /// flag: 1 表示从当前知识点列表删除，0 表示从知识库里彻底删除
  Future<void> adminDeleteKnowledgeTap(BuildContext context, int flag) async {
    if (widget.data?.knowledgeId == null) return;
    bool askRes = await DeleteDialog.show(
      context: context,
      title: "从知识点列表删除",
      subTitle: "确定删除知识点吗？",
      content: "从当前知识点列表删除，不影响知识库",
      showCountdown: false,
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      RequestConfig requestConfig = RequestConfig(
        requireToken: true,
        parameters: {
          "uid": [widget.data?.knowledgeId],
          "flag": flag
        },
      );
      final response = await UnitUtil.deleteKnowledge(unitId: widget.unitId, config: requestConfig);
      if (response.code == HttpStatus.ok) {
        ToastUtils.showManageToast(text: '删除成功');
        widget.onRefresh?.call();
      } else {
        ToastUtils.showManageToast(text: response.message ?? '删除失败');
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 复制SID
  void _copyId() {
    Clipboard.setData(ClipboardData(text: widget.data?.content?.semanticId?.toString() ?? ""));
    ToastUtils.showToast(text: "复制成功", type: ToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: widget.data?.knowledgeId != null,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.unitKnowledgeRemove],
            child: TapScaleWidget(
              onTap: () => adminDeleteKnowledgeTap(context, 1),
              sclae: 1.05,
              child: SvgPicture.asset(
                "assets/svg/public/icon_delete.svg",
                width: 32.wMin,
              ),
            ),
          ),
        ),
        Visibility(
          visible: (widget.data?.content?.semanticId ?? 0) > 0,
          child: _buildImageTagItemWidget(
            text: "sid: ${widget.data?.content?.semanticId ?? ""}",
            bgColor: AppTheme.cSurfaceQuaternary.color,
            fontColor: AppTheme.cTextPrimary.color,
            onTap: _copyId,
          ),
        ),
        Visibility(
          visible: (widget.data?.accessIsVisible ?? false) == true,
          child: _buildImageTagItemWidget(
            text: "前端可见",
            bgColor: AppTheme.cSurfaceError.color,
          ),
        ),
      ],
    );
  }

  /// 图片标签item
  Widget _buildImageTagItemWidget({
    required String text,
    required Color bgColor,
    Color fontColor = AppTheme.cStaticWhite,
    void Function()? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.05,
      child: Container(
        margin: EdgeInsets.only(top: 4.wMin),
        padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 2.wMin),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4.wMin),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.wMin,
            color: fontColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
