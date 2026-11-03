import 'dart:async';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/karaoke_subtitles_utils.dart';
import '../../common/elements_public_widgets.dart';

class ElementsSentencePronunciationWidget extends StatefulWidget {
  final String? content;
  final String? contentType;
  final int? contentId;
  final List<PronunciationsEntity?>? pronunciations;
  final void Function(int) onTap;
  final int englishAmericanType;
  const ElementsSentencePronunciationWidget({
    super.key, 
    this.content, 
    required this.contentType, 
    required this.contentId, 
    this.pronunciations, 
    required this.onTap, 
    required this.englishAmericanType,
  });

  @override
  State<ElementsSentencePronunciationWidget> createState() => _ElementsSentencePronunciationWidgetState();
}

class _ElementsSentencePronunciationWidgetState extends State<ElementsSentencePronunciationWidget> {
  List<AssSubtitle> assSubtitles = [];
  PronunciationsEntity? pronunciation;
  int playingButtonIndex = -1;

  AudioPlayerEx audioPlayEx = AudioPlayerEx();

  StreamSubscription<Duration>? positionSubscription;
  StreamSubscription<void>? completeSubscription;

  @override
  void initState() {
    super.initState();
    PlaybackInterlockUtils.instance.registerAudioStopper(this, _stopLocalPlayback);
    if(widget.pronunciations != null && (widget.pronunciations??[]).isNotEmpty){
      pronunciation = widget.pronunciations?[widget.englishAmericanType];
      assSubtitles = pronunciation?.assSubtitles??[];
      initAudio();
    }
    
  }

  @override
  void didUpdateWidget(covariant ElementsSentencePronunciationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.englishAmericanType != widget.englishAmericanType){
      cleanAssColor();
      pronunciation = widget.pronunciations?[widget.englishAmericanType];
      assSubtitles = pronunciation?.assSubtitles??[];
      playingButtonIndex = -1;
    }
  }

  @override
  void dispose() {
    PlaybackInterlockUtils.instance.unregisterAudioStopper(this);
    positionSubscription?.cancel();
    completeSubscription?.cancel();
    audioPlayEx.dispose();
    super.dispose();
  }

  Future<void> initAudio() async{
    positionSubscription = audioPlayEx.onPositionChanged.listen((event) {
      if(audioPlayEx.isPlaying){
        cleanAssColor();
        int? index = findIndexByTime(event.inMilliseconds);
        if(index == null) return;
        setState(() {
          assSubtitles[index].isRead = true;
        });
      }
    });

    completeSubscription = audioPlayEx.onPlayerComplete.listen((_) {
      playingButtonIndex = -1;
      cleanAssColor();
    });
  }

  void cleanAssColor(){
    setState(() {
      for (var element in assSubtitles) {
        element.isRead = false;
      }
    });
  }

  int? findIndexByTime(int time){
    for(int i = 0; i < assSubtitles.length; i++){
      if(assSubtitles[i].startTime <= time && assSubtitles[i].endTime >= time){
        return i;
      }
    }
    return null;
  }

  Future<void> playAudio() async{
    if(pronunciation?.audioUrl == null) return;
    await PlaybackInterlockUtils.instance.stopAllMedia(exceptAudioOwner: this);
    String? fileUrl = await CacheManagerUtils.instance.getFile(pronunciation?.audioUrl, ResourceType.audio);
    audioPlayEx.playFileOrNet(
      url: pronunciation?.audioUrl??"",
      filePath: fileUrl,
      playbackRate: Get.find<ConfigController>().userSetting.value.expandAudioSpeed,
    );
  }

  Future<void> _stopLocalPlayback() async {
    await audioPlayEx.stop();
    if (!mounted) return;
    setState(() {
      playingButtonIndex = -1;
      for (final element in assSubtitles) {
        element.isRead = false;
      }
    });
  }

  Future<void> _playPronunciationByIndex(int index) async {
    if (widget.pronunciations == null || index >= (widget.pronunciations?.length ?? 0)) {
      return;
    }
    await audioPlayEx.stop();
    cleanAssColor();
    final PronunciationsEntity? item = widget.pronunciations?[index];
    if (item == null || (item.audioUrl ?? '').isEmpty) return;
    setState(() {
      playingButtonIndex = index;
    });
    if (widget.englishAmericanType != index) {
      widget.onTap(index);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(playAudio());
      });
      return;
    }
    await playAudio();
  }

  @override
  Widget build(BuildContext context) {

    return  Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.wMin),
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.wMin, 24.wMin, 24.wMin, 28.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInlineContentWidget(),
            
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildHasPracticeWidget(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildInlineContentWidget(){
    final double fontSize = _resolveInlineFontSize();
    TextStyle style = TextStyle(
      fontSize: fontSize.wMin,
      fontWeight: FontWeight.w600,
      color: AppTheme.cTextPrimary.color,
      height: 1.35,
    );

    return RichText(
      text: TextSpan(
        style: style,
        children: _buildContentSpans(style),
      ),
    );
  }

  double _resolveInlineFontSize() {
    final String content = _resolveInlineDisplayText();
    final int length = content.runes.length;
    if (length > 180) return 20;
    if (length > 130) return 24;
    if (length > 90) return 28;
    if (length > 60) return 32;
    return 38;
  }

  String _resolveInlineDisplayText() {
    if (assSubtitles.isNotEmpty) {
      return assSubtitles
          .map((AssSubtitle item) => '${item.leftSpace}${item.text}${item.rightSpace}')
          .join();
    }
    return widget.content ?? "";
  }

  List<InlineSpan> _buildContentSpans(TextStyle style) {
    final List<InlineSpan> spans = <InlineSpan>[];
    if(assSubtitles.isEmpty){
      spans.add(TextSpan(text: widget.content??""));
    } else {
      for (int index = 0; index < assSubtitles.length; index++) {
        spans.add(TextSpan(text: assSubtitles[index].leftSpace));
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 2.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cTextBrand.color.withValues(alpha: assSubtitles[index].isRead ? 0.16 : 0),
                borderRadius: BorderRadius.circular(8.wMin),
              ),
              child: Text(
                assSubtitles[index].text,
                style: style.copyWith(
                  color: assSubtitles[index].isRead
                      ? AppTheme.cTextBrand.color
                      : AppTheme.cTextPrimary.color,
                ),
              ),
            ),
          ),
        );
        spans.add(TextSpan(text: assSubtitles[index].rightSpace));
      }
    }

    final List<PronunciationsEntity> pronunciations =
        (widget.pronunciations ?? <PronunciationsEntity?>[]).whereType<PronunciationsEntity>().toList();
    if (pronunciations.isNotEmpty) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(left: 12.wMin),
            child: _buildPronunciationButtonsGroup(pronunciations),
          ),
        ),
      );
    }
    return spans;
  }

  Widget _buildPronunciationButtonsGroup(List<PronunciationsEntity> pronunciations) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(pronunciations.length, (int index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index == pronunciations.length - 1 ? 0 : 8.wMin,
          ),
          child: ElementsPronunciationCapsuleButton(
            label: _resolvePronunciationLabel(pronunciations[index]),
            isSelected: false,
            isPlaying: playingButtonIndex == index,
            onTap: () => _playPronunciationByIndex(index),
          ),
        );
      }),
    );
  }

  String _resolvePronunciationLabel(PronunciationsEntity item) {
    final String national = (item.national ?? '').trim().toUpperCase();
    if (national.isNotEmpty) return national;
    return (item.nationalTitle ?? '').contains('英') ? 'UK' : 'US';
  }

  /// 是否有练习题按钮
  Widget _buildHasPracticeWidget(){
    if(pronunciation?.isExercise != true) return const SizedBox.shrink();
    return ElementsGoPracticeButton(
      height: 62,
      onTap: () async{
        await audioPlayEx.stop();
        cleanAssColor();
        ReviewExerciseUtils.toEval(widget.contentType, widget.contentId, pronunciation?.national);
      },
    );
  }

}
