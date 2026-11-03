
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/karaoke_subtitles_utils.dart';
import '../widgets.dart';


class PlayerAssData<T>{
  SubtitlesSentenceModel sentence;
  
  AssSubtitle? translate;

  /// 演员名称
  String? actorName;

  /// 演员头像
  String? actorAvatar;

  T? data;

  PlayerAssData({
    required this.sentence,
    this.translate,
    this.actorName,
    this.actorAvatar,
    this.data,
  });
}

class PlayerAssWidget extends StatefulWidget {
  /// 字幕列表
  final List<PlayerAssData> subtitleList;
  /// 当前执行的句子下标
  final int currentSentenceIndex;
  /// 当前执行的单词下标
  final int currentWordIndex;
  /// 语言偏好
  final LangPreference langPreference;
  /// 文字大小
  final FontSizeEnum fontSize;

  /// 点击某一句的回调
  final void Function(PlayerAssData sentence, int index)? onSentence;
  /// 移动端长按/pc右击单词
  final void Function(PlayerAssData sentence, AssSubtitle ass, int sentenceIndex, int index)? onWord;

  const PlayerAssWidget({
    super.key, 
    required this.subtitleList, 
    required this.currentSentenceIndex, 
    required this.currentWordIndex,
    this.onSentence,
    this.onWord,
    this.langPreference = LangPreference.bilingual,
    this.fontSize = FontSizeEnum.standard,
  });

  @override
  State<PlayerAssWidget> createState() => _PlayerAssWidgetState();
}

class _PlayerAssWidgetState extends State<PlayerAssWidget> {

  /// 是否显示字幕列表
  bool isShowList = false;
  final List<GlobalKey> _sentenceKeys = <GlobalKey>[];
  Timer? _autoHideListTimer;


  @override
  void initState(){
    super.initState();
    _syncSentenceKeys();
  }

  @override
  void didUpdateWidget(PlayerAssWidget oldWidget){
    super.didUpdateWidget(oldWidget);
    _syncSentenceKeys();
  }

  void _syncSentenceKeys(){
    if(_sentenceKeys.length == widget.subtitleList.length) return;
    _sentenceKeys
      ..clear()
      ..addAll(List<GlobalKey>.generate(widget.subtitleList.length, (_) => GlobalKey()));
  }

  void _startOrResetAutoHideTimer(){
    _autoHideListTimer?.cancel();
    _autoHideListTimer = Timer(const Duration(seconds: 5), () {
      if(!mounted || !isShowList) return;
      setState(() {
        isShowList = false;
      });
    });
  }

  void _cancelAutoHideTimer(){
    _autoHideListTimer?.cancel();
    _autoHideListTimer = null;
  }

  /// 获取显示的名称字符串
  /// 中文显示全名 其他显示名称首字母 中文用AcCode编码
  String _getActorName(String? actorName){
    if(actorName == null || actorName == "") return "";

    String fistStr = actorName[0].toString();
    if(fistStr.isEmpty) return "";
    /// 判断字符串中是否包含中文
    bool containsChinese = RegExp(r'[\u4e00-\u9fa5]').hasMatch(actorName);
    if(containsChinese){
      return actorName;
    }

    return fistStr;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _buildAssListWidget(),
        _buildCurrentAssWidget(),
      ],
    );
  }

  Widget _buildCurrentAssWidget(){
    if(widget.subtitleList.isEmpty) return Container();
    if(widget.currentSentenceIndex < 0) return Container();
    if(widget.currentSentenceIndex >= widget.subtitleList.length) return Container();
    final PlayerAssData assData = widget.subtitleList[widget.currentSentenceIndex];

    return IgnorePointer(
      ignoring: isShowList,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: isShowList ? 0 : 1,
        child: _buildAssItemWidget(assData, widget.currentSentenceIndex),
      ),
    );
  }

  Widget _buildAssListWidget(){
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: isShowList ? 1 : 0,
      child: IgnorePointer(
        ignoring: !isShowList,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if(isShowList){
              _startOrResetAutoHideTimer();
            }
            return false;
          },
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false, // 隐藏滚动条
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 500.wMin),
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 64.wMin,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(widget.subtitleList.length, (index){
                  return SizedBox(
                    key: _sentenceKeys[index],
                    child: _buildAssItemWidget(widget.subtitleList[index], index),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildAssItemWidget(PlayerAssData assData, int sentenceIndex){

    bool showTranslate = (widget.langPreference == LangPreference.bilingual || widget.langPreference == LangPreference.translation) && assData.translate?.text != null;

    bool isRightHide = widget.langPreference == LangPreference.none || (assData.translate?.text == null);

    /// 名称 使用字符串中的第一个字母作为名称
    String actorName = _getActorName(assData.actorName);

    return TapScaleWidget(
      onTap: () {
        isShowList = !isShowList;
        if(isShowList){
          _startOrResetAutoHideTimer();
        }else{
          _cancelAutoHideTimer();
        }
        if(mounted) setState(() {});
        if(isShowList){
          // 等列表显示之后 在下一帧滚动到对应的index
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 定位到对应的index
            if(sentenceIndex < 0 || sentenceIndex >= _sentenceKeys.length) return;
            final BuildContext? ctx = _sentenceKeys[sentenceIndex].currentContext;
            if(ctx != null){
              // 滚动到对应的index
              Scrollable.ensureVisible(
                ctx,
                alignment: 0.5,
              );
            }
          });
        }else{
          // 点击了列表中的句子
          widget.onSentence?.call(assData, sentenceIndex);
        }
      },
      sclae: 1,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        
            Visibility(
              visible: assData.actorAvatar != null,
              child: Container(
                margin: EdgeInsets.only(right: isRightHide ? 0 : 12.wMin),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.wMin),
                  child: SizedBox(
                    width: 98.wMin,
                    height: 98.wMin,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: CachedImageWidget(
                            assData.actorAvatar??"",
                            alignment: Alignment.topCenter,
                            errorWidget: buildEmptyWidget(),
                            placeholder: buildEmptyWidget(),
                          ),
                        ),
                        
                        Positioned(
                          bottom: 0,
                          width: 90.wMin,
                          child: Text(
                            actorName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.wMin,
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
            ),
        
            Container(
              constraints: BoxConstraints(maxWidth: 1600.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              
                  Visibility(
                    visible: widget.langPreference == LangPreference.bilingual || widget.langPreference == LangPreference.original,
                    child: Wrap(
                      children: List.generate(assData.sentence.words.length, (index){
                        return _buildAssTextWidget(assData, assData.sentence.words[index], sentenceIndex, index);
                      }),
                    ),
                  ),

                  Visibility(
                    visible: showTranslate,
                    child: _buildTranslateWidget(assData),
                  ),
              
                ],
              ),
            ),
        
          ],
        ),
      ),
    );
  }

  Widget _buildAssTextWidget(PlayerAssData sentence, AssSubtitle ass, int sentenceIndex, int index){

    double fontSize = 48.wMin;
    if(widget.fontSize == FontSizeEnum.extraSmall){
      fontSize = 32.wMin;
    }else if(widget.fontSize == FontSizeEnum.small){
      fontSize = 40.wMin;
    }else if(widget.fontSize == FontSizeEnum.large){
      fontSize = 56.wMin;
    }else if(widget.fontSize == FontSizeEnum.extraLarge){
      fontSize = 64.wMin;
    }else if(widget.fontSize == FontSizeEnum.extraExtraLarge){
      fontSize = 72.wMin;
    }

    bool isCurrent = sentenceIndex == widget.currentSentenceIndex && index == widget.currentWordIndex;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ass.leftSpace,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        TapScaleLongRightWidget(
          onLongSecondaryTap: (globalPosition, localPosition) {
            widget.onWord?.call(sentence, ass, sentenceIndex, index);
          },
          sclae: 1,
          child: Container(
            color: Colors.transparent,
            child: Text(
              ass.text,
              style: TextStyle(
                color: isCurrent? AppTheme.cTextBrand.color : Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    blurRadius: 4.wMin,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
        Text(
          ass.rightSpace,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTranslateWidget(PlayerAssData assData){
    if(assData.translate?.text == null) return const SizedBox.shrink();
    double fontSize = 28.wMin;
    if(widget.fontSize == FontSizeEnum.extraSmall){
      fontSize = 16.wMin;
    }else if(widget.fontSize == FontSizeEnum.small){
      fontSize = 22.wMin;
    }else if(widget.fontSize == FontSizeEnum.large){
      fontSize = 34.wMin;
    }else if(widget.fontSize == FontSizeEnum.extraLarge){
      fontSize = 40.wMin;
    }else if(widget.fontSize == FontSizeEnum.extraExtraLarge){
      fontSize = 46.wMin;
    }

    return Text(
      assData.translate?.text??"",
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        shadows: [
          Shadow(
            blurRadius: 4.wMin,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

}
