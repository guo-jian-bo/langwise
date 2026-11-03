
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/audio_control_widget.dart';
import '../../../../theme/theme.dart';
import '../common/listen_and_read_content_widget.dart';
import '../common/listen_and_read_operation_button_widget.dart';
import '../controllers/listen_and_read_shadowing_controller.dart';
import '../models/reading_ass_model.dart';

class ListenAndReadShadowingView extends GetView<ListenAndReadShadowingController> {
  /// 跟读
  const ListenAndReadShadowingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          Obx((){
            if(controller.listenAndReadController.readingAssTextList.isEmpty) return Container();
            
            return Column(
              children: [
                _buildTitleWidget(context),
                Expanded(
                  child: Obx((){
                    if(controller.titleModeSwitchIndex.value == 0){
                      return _buildModeListWidget(context);
                    }
                    return _buildArticleContent(context);
                  }),
                ),
          
              ],
            );
          }),
        ],
      ),
      floatingActionButton: _buildFullTextRecordingWidget(context),
      bottomNavigationBar: Obx((){
        if(controller.titleModeSwitchIndex.value == 0) return Container(height: 0);
        if(controller.listenAndReadController.currentSong?.audioInfo?.audioUrl == null) return Container();
        if(!controller.listenAndReadController.isShowAudioController.value) return Container();
        return Container(
          padding: EdgeInsets.only(
            top: 16.wMin,
            bottom: 24.wMin + MediaQuery.of(context).padding.bottom,
            left: 80.wMin,
            right: 80.wMin,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                  AppTheme.cBgPrimary.withValues(alpha: 0.8),
                  AppTheme.cBgPrimary.withValues(alpha: 1),
              ],
            ),
          ),
          child: AudioControlWidget(
            audioPlayerUtils: controller.listenAndReadController.audioPlayerUtils,
            initSpeed: controller.listenAndReadController.playbackRate.value,
            initPosition: controller.listenAndReadController.position.value,
            translateValue: controller.listenAndReadController.translateStatus.value,
            showPreviousNextTrackButton: false,
            fontSizeMultiple: controller.listenAndReadController.contentFontSizeMultiple.value,
            showFontSizeButton: true,
            showPlayOrderButton: true,
            playOrderLoopCount: controller.listenAndReadController.playOrderLoopCount.value,
            playOrderValue: controller.listenAndReadController.playOrderStatus.value,
            onSpeedChanged: (speed) {
              controller.listenAndReadController.playbackRate.value = speed;
            },
            onPlayOrderLoopCountChanged: (loopCount) {
              controller.listenAndReadController.setPlayOrderLoopCount(loopCount);
            },
            onPlayOrderChanged: (type) {
              controller.listenAndReadController.setPlayOrderStatus(type);
            },
            onFontSizeMultipleChanged: (fontSizeMultiple) {
              controller.listenAndReadController.contentFontSizeMultiple.value = fontSizeMultiple;
            },
            onTranslateChanged: (type) {
              controller.listenAndReadController.translateStatus.value = type;
            },
            onPreviousNextSentenceChanged: (type) {
              controller.listenAndReadController.nextOrPreviousSentence(type);
            },
            showFavoriteButton: true,
            isFavorite: controller.listenAndReadController.currentSong?.favorited ?? false,
            onFavoriteChanged: (isFavorite) {
              controller.listenAndReadController.toggleFavourite();
            },
          ),
        );
      }),
    );
  }

  /// 全文模式录音
  Widget _buildFullTextRecordingWidget(BuildContext context){
    return Obx((){
      if(controller.titleModeSwitchIndex.value == 0) {
        LangPreference translate = controller.singleSentenceTranslate.value;
        bool isShowTranslate = translate == LangPreference.bilingual;
        return TapScaleWidget(
          onTap: () {
            controller.singleSentenceChangeTranslation();
          },
          sclae: 1.05,
          child: Container(
            width: 72.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cSurfaceQuaternary.color,
            ),
            child: SvgPicture.asset(
              isShowTranslate ? "assets/svg/public/icon_translation_not.svg" : "assets/svg/public/icon_translation.svg",
              width: 32.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
            ),
          ),
        );
      }

      return Row(
        spacing: 48.wMin,
        mainAxisSize: MainAxisSize.min,
        children: [
          IgnorePointer(
            ignoring: !controller.fullTextRecordPcmPath.value.isNotEmpty,
            child: Opacity(
              opacity: controller.fullTextRecordPcmPath.value.isNotEmpty ? 1.0 : 0.3,
              child: TapScaleWidget(
                onTap: (){
                  controller.playbackAudio(controller.fullTextRecordPcmPath.value);
                },
                sclae: 1.05,
                child: Container(
                  width: 76.wMin,
                  height: 76.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceQuaternary.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_recording_playback.svg",
                    width: 28.wMin,
                    height: 28.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
          MicrophoneWidget(
            controller: controller.microphoneController,
            onRecordFailure: controller.onRecordFailure,
            onTapRecord: (){
              controller.playbackArticle(context);
            },
          ),
        ],
      );
    });
  }


  Widget _buildTitleWidget(BuildContext context){
    double topPadding = 110.wMin + MediaQuery.of(context).padding.top;
    return Container(
      margin: EdgeInsets.only(
        top: topPadding,
        left: MediaQuery.of(context).padding.left,
        right: MediaQuery.of(context).padding.right,
      ),
      padding: EdgeInsets.symmetric(horizontal: 64.wMin, vertical: 16.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx((){
            return AnimatedToggleSwitch<int>.size(
              current: controller.titleModeSwitchIndex.value,
              values: List.generate(controller.modeList.length, (index) => index),
              indicatorSize: Size.fromWidth(144.wMin),
              height: 64.wMin,
              iconBuilder: (index){
                return Text(
                  controller.modeList[index],
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
              borderWidth: 4.wMin,
              iconAnimationType: AnimationType.onHover,
              iconOpacity: 1,
              selectedIconScale: 1,
              style: ToggleStyle(
                borderColor: Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: AppTheme.cSurfacePrimary.color,
                indicatorBorderRadius: BorderRadius.circular(999),
                indicatorColor: AppTheme.cSurfaceSecondary.color,
                
              ),
              onChanged: (i) {
                controller.switchMode(i);
              },
            );
          }),
      
        ],
      ),
    );
  }

  /// 全文模式 文章内容
  Widget _buildArticleContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.listenAndReadController.toggleAudioController();
      },
      onDoubleTap: () {
        controller.listenAndReadController.pauseAndPlay();
      },
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).padding.left,
          right: MediaQuery.of(context).padding.right,
        ),
        child: Obx((){
          if(controller.listenAndReadController.readingAssTextList.isEmpty) return Container();
          return ListenAndReadContentWidget(
            isShowEvelResultColor: true,
            contentFontSizeMultiple: controller.listenAndReadController.contentFontSizeMultiple.value,
            translateStatus: controller.listenAndReadController.translateStatus.value,
            readingAssTextList: controller.listenAndReadController.readingAssTextList,
            clickSelectSentence: (sentence) async{
              controller.stopRecord();
              controller.listenAndReadController.clickSelectSentence(sentence);
            },
          );
        }),
      ),
    );
  }


  /// 跟读模式列表
  Widget _buildModeListWidget(BuildContext context){
    List<ReadingAssParagraphModel> readingAssList = controller.listenAndReadController.readingAssTextList;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 40.wMin,
      ),
      child: Column(
        spacing: 60.wMin,
        children: List.generate(readingAssList.length, (paragraphIndex){
          return Column(
            children: List.generate(readingAssList[paragraphIndex].sentences.length, (sentenceIndex){
              return _buildModeSentenceListWidget(context, readingAssList[paragraphIndex].sentences[sentenceIndex], paragraphIndex, sentenceIndex);
            }),
          );
        }),
      ),
    );
  }

  /// 跟读模式 句子
  Widget _buildModeSentenceListWidget(BuildContext context, ReadingAssSentenceModel model, int paragraphIndex, int sentenceIndex){
    return Obx((){
      int currentExpandParagraphIndex = controller.currentExpandParagraphIndex.value;
      int currentExpandSentenceIndex = controller.currentExpandSentenceIndex.value;

      return TapScaleWidget(
        onTap: () {
          controller.switchSentence(paragraphIndex, sentenceIndex);
        },
        sclae: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          alignment: Alignment.center,
          color: AppTheme.cSurfaceSecondary.color.withValues(
            alpha: currentExpandSentenceIndex == sentenceIndex && currentExpandParagraphIndex == paragraphIndex ? 1 : 0,
          ),
          child: AnimatedCrossFade(
            crossFadeState: currentExpandSentenceIndex == sentenceIndex && currentExpandParagraphIndex == paragraphIndex ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            firstChild: Container(
              padding: EdgeInsets.symmetric(vertical: 16.wMin),
              child: _buildWordListWidget(model),
            ),
            secondChild: Column(
              children: [
                SizedBox(height: 16.wMin),
                _buildWordListWidget(model),
                Visibility(
                  visible: currentExpandSentenceIndex == sentenceIndex && currentExpandParagraphIndex == paragraphIndex,
                  child: ListenAndReadOperationButtonWidget(
                    platbackIsShow: model.recordFilePcmPath != null,
                    microphoneController: controller.microphoneController,
                    onPlay: () {
                      controller.playSentence(model);
                    },
                    onRecord: () {
                      controller.onRecord(context, model);
                    },
                    onRecordFailure: () {
                      controller.onRecordFailure();
                    },
                    onPlayback: () {
                      controller.playbackAudio(model.recordFilePcmPath);
                    },
                  ),
                ),
                SizedBox(height: 16.wMin),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 单词列表
  Widget _buildWordListWidget(ReadingAssSentenceModel model){
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 200.wMin),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 4.wMin,
                children: List.generate(model.words.length, (index){
                  return _buildWordContent(model.words[index]);
                }),
              ),
              Visibility(
                visible: controller.singleSentenceTranslate.value == LangPreference.bilingual,
                child: Container(
                  margin: EdgeInsets.only(top: 4.wMin),
                  child: Text(
                    model.sentenceTranslate?.ass.text??"",
                    style: TextStyle(
                      fontSize: 32.wMin,
                      color: AppTheme.cTextSecondary.color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w300,
                      fontFamily: "LXGWWenKaiGBScreen",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Visibility(
          visible: model.evaluationScore != null,
          child: Positioned(
            right: 45.wMin,
            child: Container(
              width: 160.wMin,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 4.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.wMin),
                color: AppTheme.cSurfaceInfo.color,
              ),
              child: Text(
                "评测分数 ${ model.evaluationScore??0}",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }

  /// 单词内容
  Widget _buildWordContent(ReadingAssWordModel word){
    Color wordColor = AppTheme.cTextPrimary.color;

    if(controller.titleModeSwitchIndex.value == 0){
      if(word.evaluationStatus != null){
        wordColor = EvelResultScoreEnum.getJudgmentColor(word.evaluationStatus!);
      }
    }

    TextStyle style = TextStyle(
      color: wordColor,
      fontSize: 46.wMin,
      fontWeight: FontWeight.w300,
      fontFamily: "SourceSerif4",
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(word.ass.leftSpace, style: style),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: AppTheme.cTextBrand.color.withValues(alpha: word.ass.isRead || word.isHighlight ? 0.8 : 0),
          ),
          child: Text(word.ass.text, style: style),
        ),
      ],
    );
  }



}