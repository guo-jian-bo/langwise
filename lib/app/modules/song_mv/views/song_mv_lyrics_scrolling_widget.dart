/// ============================================================================
/// 歌词滚动组件 (SongMvLyricsScrollingWidget)
/// ============================================================================
///
/// 功能说明：
/// 1. 显示歌词列表，当前播放的句子高亮显示，其他句子半透明
/// 2. 支持上下滑动浏览歌词
/// 3. 用户滑动后，1秒内不自动滚动，1秒后自动回到当前播放位置
/// 4. 用户滑动停止后，通过回调返回当前可见的句子数据
///
/// 核心逻辑：
/// - 使用 ScrollController 控制歌词列表的滚动
/// - 使用 Timer 实现1秒延迟后自动回滚到当前播放位置
/// - 使用 NotificationListener 监听用户滑动事件
/// - 当 currentSentenceIndex 变化时，自动滚动到对应位置
/// - 当前句子使用高亮样式，其他句子使用半透明样式
///
/// 状态管理：
/// - _isUserScrolling: 标记用户是否正在手动滑动
/// - _autoScrollTimer: 自动回滚的定时器
/// - _scrollController: 滚动控制器
/// - _itemKeys: 存储每个歌词项的 GlobalKey，用于计算滚动位置
/// ============================================================================

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';
import '../models/song_sentence_model.dart';

class SongMvLyricsScrollingWidget extends StatefulWidget {
  final List<SongSentenceModel> playSentenceList;
  final int currentSentenceIndex;
  final LangPreference audioControlTranslate;
  final double audioFontSizeMultiple;
  /// 单击某个句子
  final void Function(SongSentenceModel sentence, int sentenceIndex)? onSentenceTap;
  /// 长按单词
  final void Function(
    BuildContext context, 
    SongSentenceModel sentence, 
    int index, 
    {required void Function() onLongPressEnd}
  )? onWordLongPress;

  /// 歌词滚动
  const SongMvLyricsScrollingWidget({
    super.key,
    required this.playSentenceList,
    required this.currentSentenceIndex,
    this.audioControlTranslate = LangPreference.bilingual,
    this.audioFontSizeMultiple = 1.0,
    this.onSentenceTap,
    this.onWordLongPress,
  });

  @override
  State<SongMvLyricsScrollingWidget> createState() => _SongMvLyricsScrollingWidgetState();
}

class _SongMvLyricsScrollingWidgetState extends State<SongMvLyricsScrollingWidget> {
  /// 标记用户是否正在手动滑动
  bool _isUserScrolling = false;

  /// 用户手动滑动静止timer
  Timer? _userScrollStopTimer;

  @override
  void initState() {
    super.initState();
    // 初始化时滚动到当前句子
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentSentence(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant SongMvLyricsScrollingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当前句子索引变化时，如果用户没有在手动滑动，则自动滚动到当前句子
    if (oldWidget.currentSentenceIndex != widget.currentSentenceIndex && !_isUserScrolling) {
      _scrollToCurrentSentence(animate: true);
    }
    if (widget.audioFontSizeMultiple != oldWidget.audioFontSizeMultiple || widget.audioControlTranslate != oldWidget.audioControlTranslate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentSentence(animate: false);
      });
    }
  }

  @override
  void dispose() {
    _userScrollStopTimer?.cancel();
    super.dispose();
  }

  /// 滚动到当前播放的句子
  void _scrollToCurrentSentence({bool animate = true}) {
    if (widget.playSentenceList.isEmpty) return;

    final targetIndex = widget.currentSentenceIndex;
    if (targetIndex < 0 || targetIndex >= widget.playSentenceList.length) return;

    // 获取目标项的 GlobalKey
    final targetKey = widget.playSentenceList[targetIndex].key;
    if (targetKey.currentContext == null) return;

    // 使用 Scrollable.ensureVisible 精确滚动到目标位置
    Scrollable.ensureVisible(
      targetKey.currentContext!,
      duration: animate ? const Duration(milliseconds: 100) : Duration.zero,
      curve: Curves.easeOutCubic,
      alignment: 0.4, // 0.5 表示将目标项滚动到视图中心
    );
  }

  /// 处理用户开始滑动
  void _onUserScrollStart() {
    _isUserScrolling = true;
    if (mounted) setState(() {});
  }

  /// 处理用户结束滑动
  void _onUserScrollEnd() {
    _userScrollStopTimer?.cancel();
    _userScrollStopTimer = Timer(const Duration(seconds: 3), () {
      _isUserScrolling = false;
      _scrollToCurrentSentence();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isShowLyric = widget.audioControlTranslate != LangPreference.none;
    if (!isShowLyric) return const SizedBox();
    if (widget.playSentenceList.isEmpty) return const SizedBox();

    return Center(
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            // 鼠标滚轮或触摸板滚动
            _onUserScrollStart();
            _onUserScrollEnd();
          }
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification && notification.dragDetails != null) {
              // 用户开始滚动
              _onUserScrollStart();
            } else if (notification is ScrollUpdateNotification && notification.dragDetails != null) {
              // 滚动中，重置计时器
              _onUserScrollEnd();
            } else if (notification is ScrollEndNotification && notification.dragDetails != null) {
              // 滚动结束
              _onUserScrollEnd();
            }
            return false;
          },
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false, // 隐藏滚动条
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 100.wMin,
                right: 100.wMin,
                top: 400.wMin,
                bottom: 600.wMin,
              ),
              child: Column(
                spacing: 60.wMin,
                children: List.generate(widget.playSentenceList.length, (index) {
                  return _buildLyricSentenceContent(context, widget.playSentenceList[index], index);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建歌词句子内容
  Widget _buildLyricSentenceContent(
    BuildContext context,
    SongSentenceModel sentence,
    int sentenceIndex,
  ) {
    if (sentence.sentence.isEmpty) return const SizedBox();

    bool current = sentenceIndex == widget.currentSentenceIndex;

    double fontSize = current ? 60 * widget.audioFontSizeMultiple : 40 * widget.audioFontSizeMultiple;
    bool isShowTranslate = widget.audioControlTranslate == LangPreference.bilingual || widget.audioControlTranslate == LangPreference.translation;

    double opacity = 1.0;
    if (current) {
      opacity = 1.0;
    }else{
      if(sentenceIndex == widget.currentSentenceIndex - 1){
        opacity = 0.5;
      }else if(sentenceIndex == widget.currentSentenceIndex + 1){
        opacity = 0.5;
      } else if (_isUserScrolling) {
        opacity = 0.5;
      } else {
        opacity = 0.0;
      }
    }

    return IgnorePointer(
      ignoring: opacity == 0.0,
      key: sentence.key,
      child: TapScaleWidget(
        onTap: () {
          widget.onSentenceTap?.call(sentence, sentenceIndex);
        },
        sclae: 1,
        borderRadius: 8.wMin,
        milliseconds: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 歌词文本
            Visibility(
              visible: widget.audioControlTranslate == LangPreference.bilingual || widget.audioControlTranslate == LangPreference.original,
              child: Wrap(
                spacing: 20.wMin,
                runSpacing: 8.wMin,
                alignment: WrapAlignment.center,
                children: List.generate(sentence.sentence.length, (wordIndex) {
                  return _buildLyricWordWidget(
                    sentence,
                    sentenceIndex,
                    wordIndex,
                    sentence.sentence[wordIndex],
                    current,
                  );
                }),
              ),
            ),
            // 翻译文本
            Visibility(
              visible: sentence.translate?.text != null && isShowTranslate,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: opacity,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 100),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cInverseTextLight.color,
                    fontFamily: Theme.of(context).textTheme.displayMedium?.fontFamily,
                    shadows: [
                      Shadow(
                        color: AppTheme.cStaticBlack.color.withValues(alpha: 0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 4.wMin,
                      ),
                    ],
                  ),
                  child: Text(sentence.translate?.text ?? ""),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 歌词每个单词
  Widget _buildLyricWordWidget(SongSentenceModel sentence, int sentenceIndex, int wordIndex, AssSubtitle sub, bool isCurrent) {
    bool isRead = sub.isRead;

    double fontSize = isCurrent ? 90 * widget.audioFontSizeMultiple : 70 * widget.audioFontSizeMultiple;

    bool isHighlight = sentence.selectedWordIndex == wordIndex;

    double opacity = 1.0;
    if(isCurrent || isHighlight){
      opacity = 1.0;
    }else{
      if(sentenceIndex == widget.currentSentenceIndex - 1){
        opacity = 0.5;
      }else if(sentenceIndex == widget.currentSentenceIndex + 1){
        opacity = 0.5;
      }else if(_isUserScrolling){
        opacity = 0.5;
      }else {
        opacity = 0.0;
      }
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: opacity,
      child: Builder(
        builder: (ctx) {
          return TapScaleLongRightWidget(
            onLongSecondaryTap: widget.onWordLongPress == null ? null : (globalPosition, localPosition) {
              _userScrollStopTimer?.cancel();
              _onUserScrollStart();
              
              widget.onWordLongPress?.call(ctx, sentence, wordIndex, onLongPressEnd: (){
                _onUserScrollEnd();
              });
            },
            sclae: 1.02,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: isHighlight ? AppTheme.cTextBrand.color.withValues(alpha: 0.6) : Colors.transparent,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 100),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize.wMin,
                  fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
                  color: isRead ? AppTheme.cTextBrand.color : AppTheme.cInverseTextLight.color,
                  fontFamily: Theme.of(ctx).textTheme.displaySmall?.fontFamily,
                  shadows: [
                    Shadow(
                      color: AppTheme.cStaticBlack.color.withValues(alpha: 0.4),
                      offset: const Offset(0, 2),
                      blurRadius: 4.wMin,
                    ),
                  ],
                ),
                child: Text(sub.text),
              ),
            ),
          );
        },
      ),
    );
  }
}
