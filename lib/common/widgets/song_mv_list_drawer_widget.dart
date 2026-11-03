
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../entities/entities.dart';
import 'widgets.dart';
import '../../theme/theme.dart';
import '../../utils/utils.dart';


class SongMvListDrawerWidget extends StatefulWidget {
  final List<SongEntityList> songs;
  final int allCount;
  final int selectedId;
  final ValueChanged<SongEntityList> onSelected;
  final bool isLoading;
  final void Function()? onScrollEnd;
  const SongMvListDrawerWidget({
    super.key, 
    required this.songs, 
    required this.allCount, 
    required this.selectedId, 
    required this.onSelected,
    this.isLoading = false,
    this.onScrollEnd,
  });

  @override
  State<SongMvListDrawerWidget> createState() => _SongMvListDrawerWidgetState();
}

class _SongMvListDrawerWidgetState extends State<SongMvListDrawerWidget> {

  AutoScrollController autoScrollController = AutoScrollController();

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollToSelected();
    });

    autoScrollController.addListener(_scrollListener);

  }

  @override
  void dispose() {
    super.dispose();
    autoScrollController.removeListener(_scrollListener);
    autoScrollController.dispose();
  }

  /// 滚动到当前选择的位置
  void scrollToSelected(){
    int index = widget.songs.indexWhere((element) => element.contentId == widget.selectedId);
    if(index == -1) return;

    autoScrollController.scrollToIndex(
      index, 
      preferPosition: AutoScrollPosition.middle,
      duration: const Duration(milliseconds: 1),
    );
    
  }

  void _scrollListener(){
    if (autoScrollController.position.pixels >= autoScrollController.position.maxScrollExtent - 100 && !autoScrollController.position.outOfRange) {
      if (widget.songs.length < widget.allCount && !widget.isLoading) {
        widget.onScrollEnd?.call();
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Container(
      height: 800.wMin,
      width: 400.wMin,
      margin: EdgeInsets.only(bottom: 80.wMin + MediaQuery.of(context).padding.bottom),
      
      decoration: BoxDecoration(
        color: AppTheme.cInverseOverlay2.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.wMin),
          bottomLeft: Radius.circular(24.wMin),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.wMin),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            child: Text(
              "播放列表",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: autoScrollController,
              itemCount: widget.songs.length,
              padding: EdgeInsets.all(16.wMin),
              separatorBuilder: (context, index) {
                return SizedBox(height: 12.wMin);
              },
              itemBuilder: (context, index) {
                return _buildSongListItemWidget(widget.songs[index], index);
              },
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

  Widget _buildSongListItemWidget(SongEntityList song, int index){
    bool isSelect = widget.selectedId == song.contentId;
    List<String> tagText = [];
    List<SongEntityTags?> tags = song.tags??[];
    for(var tag in tags){
      LanguageText? item = LearningLangUtils.getLearningLang(tag?.gloss);
      if(item == null) continue;
      if(item.text == null) continue;
      tagText.add(item.text!);
    }

    TextStyle titleStyle = TextStyle(
      fontSize: 24.wMin,
      fontWeight: FontWeight.w600,
      color: AppTheme.cTextPrimary.color,
    );

    return AutoScrollTag(
      key: ValueKey(index),
      controller: autoScrollController,
      index: index,
      child: TapScaleWidget(
        onTap: () {
          widget.onSelected(song);
        },
        sclae: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 120.wMin,
          decoration: BoxDecoration(
            color: AppTheme.cFeedbackInfoBorder.color.withValues(alpha: isSelect ? 0.1 : 0),
            border: Border(
              left: BorderSide(
                color: AppTheme.cBorderBrand.color.withValues(alpha: isSelect ? 1 : 0),
                width: 2.wMin,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth = constraints.maxWidth;
              bool isOverflow = false;
              if(isSelect){
                isOverflow = getTextIsOverflow(song.title??"", titleStyle, maxWidth);
              }
      
              bool isShowMarquee = isSelect && isOverflow;
      
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: isShowMarquee,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      height: 40.wMin,
                      child: Marquee(
                        text: song.title??"",
                        startPadding: 16.wMin,
                        blankSpace: 100.wMin,
                        startAfter: const Duration(seconds: 1),
                        pauseAfterRound: const Duration(seconds: 5),
                        style: titleStyle,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16.wMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                        visible: !isShowMarquee,
                        child: Container(
                          width: double.infinity,
                          height: 40.wMin,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            song.title??"",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          ),
                        ),
                      ),
                      Text(
                        tagText.join(" · "),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      ),
                      SizedBox(height: 4.wMin),
                      Visibility(
                        visible: song.subContentCount != null,
                        child: Text(
                          "共 ${song.subContentCount??0} 个知识点",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary.color,
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
      ),
    );

  }

  
}