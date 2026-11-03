import 'dart:async';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
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

  AudioPlayerEx audioPlayEx = AudioPlayerEx();

  StreamSubscription<Duration>? positionSubscription;
  StreamSubscription<void>? completeSubscription;

  @override
  void initState() {
    super.initState();
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
      pronunciation = widget.pronunciations?[widget.englishAmericanType];
      assSubtitles = pronunciation?.assSubtitles??[];
    }
  }

  @override
  void dispose() {
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
    String? fileUrl = await CacheManagerUtils.instance.getFile(pronunciation?.audioUrl, ResourceType.audio);
    audioPlayEx.playFileOrNet(
      url: pronunciation?.audioUrl??"",
      filePath: fileUrl,
      playbackRate: Get.find<ConfigController>().userSetting.value.expandAudioSpeed,
    );
  }

  @override
  Widget build(BuildContext context) {

    return  Container(
      decoration: BoxDecoration(

       borderRadius: BorderRadius.circular(28.wMin),
      border: Border.all(
        color: AppTheme.cBorderPrimary.color,

      ),),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElementsUSUKTabWidget(
            pronunciations: widget.pronunciations ?? [],
            englishAmericanType: widget.englishAmericanType,
            onTap: (index) async{
              if(widget.englishAmericanType == index) return;
              await audioPlayEx.stop();
              cleanAssColor();
              widget.onTap(index);
            },
          ),
          Visibility(
            visible: pronunciation != null,
            child: Container(
              height: 2.wMin,
              color: AppTheme.cBorderPrimary.color,
            ),
          ),
          SizedBox(height: 24.wMin),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            child: Column(
              children: [
                _buildPlayButtonWidget(),
                SizedBox(height: 20.wMin),
                _buildHasPracticeWidget(),
                SizedBox(height: 40.wMin),
              ],
            ),
          ),
          // LayoutBuilder(
          //     builder: (context, constraints) {
          //       double maxWidth = constraints.maxWidth;
          //       return Row(
          //         spacing: 24.wMin,
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Container(
          //             constraints: BoxConstraints(
          //               maxWidth: maxWidth - 24.wMin - 80.wMin,
          //             ),
          //             child: _buildAssWidget(),
          //           ),
          //           _buildPlayButtonWidget(),
          //         ],
          //       );
          //     }
          // ),
          // _buildHasPracticeWidget(),
          // SizedBox(height: 40.wMin),
        ],
      ),
    );

  }

  Widget _buildAssWidget(){
    TextStyle style = TextStyle(
      fontSize: 32.wMin,
      fontWeight: FontWeight.w600,
      color: AppTheme.cTextPrimary.color,
    );

    if(assSubtitles.isEmpty){
      return Text(widget.content??"", style: style);
    }

    return Wrap(
      children: List.generate(assSubtitles.length, (index){
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(assSubtitles[index].leftSpace, style: style),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cTextBrand.color.withValues(alpha: assSubtitles[index].isRead ? 0.8 : 0),
                borderRadius: BorderRadius.circular(4.wMin)
              ),
              child: Text(
                assSubtitles[index].text,
                style: style,
              ),
            ),
            Text(assSubtitles[index].rightSpace, style: style),
          ],
        );
      }),
    );
  }

  Widget _buildPlayButtonWidget(){
    return ElementsPlayButtonCircle(
      onTap: playAudio,
      enabled: (pronunciation?.audioUrl ?? '').isNotEmpty,
    );
  }

  /// 是否有练习题按钮
  Widget _buildHasPracticeWidget(){
    if(pronunciation?.isExercise != true) return Container();
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.only(top: 24.wMin, right: 40.wMin),
      child: ElementsGoPracticeButton(
        height: 62,
        onTap: () async{
          await audioPlayEx.stop();
          cleanAssColor();
          ReviewExerciseUtils.toEval(widget.contentType, widget.contentId, pronunciation?.national);
        },
      ),
    );
  }

}
