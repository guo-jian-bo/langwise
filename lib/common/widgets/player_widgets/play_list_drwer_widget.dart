
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../widgets.dart';

class PlayListDrwerWidget extends StatefulWidget {
  final List<ZhenduDetilEntity> songs;
  final List<Map<String, dynamic>>? contents;
  final int allCount;
  final String selectedUniqueKey;
  final ValueChanged<ZhenduDetilEntity> onSelected;
  final bool isLoading;
  final void Function()? onScrollEnd;
  const PlayListDrwerWidget({
    super.key, 
    required this.songs, 
    this.contents,
    required this.allCount,
    required this.selectedUniqueKey,
    required this.onSelected,
    this.isLoading = false,
    this.onScrollEnd,
  });

  @override
  State<PlayListDrwerWidget> createState() => _PlayListDrwerWidgetState();
}

class _PlayListDrwerWidgetState extends State<PlayListDrwerWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    _syncItemKeys();

    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedSong();
    });

  }

  @override
  void didUpdateWidget(covariant PlayListDrwerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncItemKeys();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
  }

  void scrollToSelectedSong() {
    final selectedIndex = widget.songs.indexWhere(
      (song) => _buildSongUniqueKey(song) == widget.selectedUniqueKey,
    );
    if (selectedIndex >= 0 && selectedIndex < _itemKeys.length) {
      final ctx = _itemKeys[selectedIndex].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
      );
    }
  }

  void _syncItemKeys() {
    if (_itemKeys.length == widget.songs.length) return;
    if (_itemKeys.length < widget.songs.length) {
      for (int i = _itemKeys.length; i < widget.songs.length; i++) {
        _itemKeys.add(GlobalKey());
      }
      return;
    }
    _itemKeys.removeRange(widget.songs.length, _itemKeys.length);
  }

  String _buildSongUniqueKey(ZhenduDetilEntity song) {
    final contentId = song.contentId;
    const semanticId = null;
    final contentType = song.contentType;
    final styleId = song.contentInfo?.styleId;
    final dialect = song.contentInfo?.dialect;
    return "${contentId ?? ''}+${semanticId ?? '0'}+${contentType ?? ''}+${styleId ?? ''}+${dialect ?? ''}";
  }

  void _scrollListener(){
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_scrollController.position.outOfRange) {
      if (widget.songs.length < widget.allCount && !widget.isLoading) {
        widget.onScrollEnd?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1030.wMin,
      width: 476.wMin,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        right: 24.wMin + MediaQuery.of(context).padding.right,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cSurfacePlayerOverlay.color,
        borderRadius: BorderRadius.circular(20.wMin),
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.wMin),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "播放列表",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(20.wMin),
              child: Column(
                children: List.generate(widget.songs.length, (index) {
                  return _buildSongListItemWidget(widget.songs[index], index);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool getTextIsOverflow(String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    return textPainter.width > maxWidth;
  }

  Widget _buildSongListItemWidget(ZhenduDetilEntity song, int index){
    bool isSelect = _buildSongUniqueKey(song) == widget.selectedUniqueKey;
    List<String> tagText = [];
    List<SongEntityTags?> tags = song.contentInfo?.tags??[];
    for(var tag in tags){
      LanguageText? item = LearningLangUtils.getLearningLang(tag?.gloss);
      if(item == null) continue;
      if(item.text == null) continue;
      tagText.add(item.text!);
    }

    TextStyle titleStyle = TextStyle(
      fontSize: 24.wMin,
      fontWeight: FontWeight.w600,
      color: isSelect ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
    );

    return IgnorePointer(
      ignoring: song.contentInfo?.learnTypeSupport == false,
      child: Opacity(
        opacity: song.contentInfo?.learnTypeSupport == false ? 0.6 : 1,
        child: TapScaleWidget(
          onTap: isSelect ? null : () {
            widget.onSelected(song);
          },
          sclae: 1,
          key: _itemKeys[index],
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(16.wMin),
                decoration: BoxDecoration(
                  color: isSelect ? AppTheme.cFeedbackInfoBackground.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.wMin),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double maxWidth = constraints.maxWidth;
                    bool isOverflow = false;
                    if(isSelect){
                      isOverflow = getTextIsOverflow(song.contentInfo?.title??"", titleStyle, maxWidth);
                    }
                    
                    bool isShowMarquee = isSelect && isOverflow;
                    
                    return Row(
                      spacing: 12.wMin,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.wMin),
                          child: SizedBox(
                            width: 96.wMin,
                            height: 96.wMin,
                            child: CachedImageWidget(
                              song.contentInfo?.imageUrl??"",
                              errorWidget: buildEmptyWidget(),
                              placeholder: buildLoadingWidget(),
                              fadeInDuration: Duration.zero,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: isShowMarquee,
                                          child: Container(
                                            width: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            height: 40.wMin,
                                            child: Marquee(
                                              text: song.contentInfo?.title??"",
                                              blankSpace: 100.wMin,
                                              startAfter: const Duration(seconds: 1),
                                              pauseAfterRound: const Duration(seconds: 5),
                                              style: titleStyle,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: !isShowMarquee,
                                          child: Container(
                                            width: double.infinity,
                                            height: 40.wMin,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              song.contentInfo?.title??"",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: titleStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.wMin),
                                  Text(
                                    (index + 1).toString().padLeft(2, "0"),
                                    style: TextStyle(
                                      fontSize: 16.wMin,
                                      fontWeight: FontWeight.w400,
                                      color: isSelect ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
                                    ),
                                  ),
                
                                ],
                              ),
                              Text(
                                tagText.join(" · "),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: isSelect ? AppTheme.cTextBrand.color.withValues(alpha: 0.8) : AppTheme.cTextSecondary.color,
                                ),
                              ),
                              SizedBox(height: 4.wMin),
                              Visibility(
                                visible: isSelect,
                                child: Text(
                                  "正在播放",
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.cTextBrand.color,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !isSelect && song.contentInfo?.learnTypeSupport == false,
                                child: Text(
                                  "不支持当前播放模式",
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.cSurfaceError.color,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
        
              Container(
                height: 1.wMin,
                color: AppTheme.cBorderPrimary.color,
                margin: EdgeInsets.only(left: 120.wMin),
              ),
        
            ],
          ),
        ),
      ),
    );

  }
  
}
