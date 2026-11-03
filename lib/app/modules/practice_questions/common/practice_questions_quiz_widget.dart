

import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:quiz_play/models/oral_evaluation_config.dart';
import 'package:quiz_play/models/quiz_play_show_config.dart';
import 'package:quiz_play/utils/language_config.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../common/configs/sheng_tong_config.dart';
import '../../../../common/entities/third_party_account_entity.dart';
import '../../../../common/values/values.dart';
import '../../../../theme/theme.dart';
import '../../../../theme/theme_quiz_utils.dart';

class PracticeQuestionsQuizWidget extends StatefulWidget {
  final QuizModel? data;
  final List<QuizLettersModel>? letters;
  final StreamController<QuizStateType>? stateController;
  final QuizPlayListener listener;
  final bool endPractice;
  final ThirdPartyAccountEntityList soundAccount;
  final bool isJudgeScore;
  final bool hideResultAutoEnd;
  final QuizPlayShowConfig? showConfig;
  final bool isShowUpDownStatus;
  final double? playSpeed;
  const PracticeQuestionsQuizWidget({
    super.key, 
    this.data, 
    required this.letters, 
    required this.stateController, 
    required this.listener,
    required this.endPractice,
    required this.soundAccount,
    this.isJudgeScore = false,
    this.hideResultAutoEnd = false,
    this.showConfig,
    this.isShowUpDownStatus = false,
    this.playSpeed,
  });

  @override
  State<PracticeQuestionsQuizWidget> createState() => _PracticeQuestionsQuizWidgetState();
}

class _PracticeQuestionsQuizWidgetState extends State<PracticeQuestionsQuizWidget> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver{

  /// 窗口是否正在发生改变
  bool windowIsResized = false;

  Timer? windowIsResizedTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if(Platform.isMacOS || Platform.isWindows || Platform.isLinux){
      
      if(!windowIsResized){
        windowIsResized = true;
        if(mounted) setState(() {});
        windowIsResizedTimer?.cancel();
        windowIsResizedTimer = null;
      }
      windowIsResizedTimer ??= Timer(const Duration(seconds: 1), () {
        windowIsResized = false;
        if(mounted) setState(() {});
      });
    }
    
  }


  @override
  void dispose() {
    windowIsResizedTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(windowIsResized) return Container();

    String showIdText = "ID:${widget.data?.uid??''}";
    if(widget.isShowUpDownStatus){
      showIdText += " ${widget.data?.accessStr??''}";
    }

    return Container(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DefaultTextStyle(
            style: const TextStyle(fontFamily: "LangWiseFont"),
            child: Theme(
              data: ThemeData().copyWith(
                textTheme: ThemeData().textTheme.apply(fontFamily: "LangWiseFont"),
              ),
              child: IgnorePointer(
                ignoring: widget.endPractice,
                child: QuizPlayWidget(
                  stateController: widget.stateController,
                  data: widget.data,
                  letters: widget.letters,
                  listener: widget.listener,
                  isDemo: widget.endPractice,
                  playSpeed: widget.playSpeed ?? Get.find<ConfigController>().userSetting.value.courseAudioSpeed,
                  playSpeedList: Get.find<ConfigController>().userSetting.value.courseAudioSpeedList,
                  quizPlayStyle: ThemeQuizUtils.getQuizPlayStyle(),
                  showConfig: widget.showConfig ?? const QuizPlayShowConfig(),
                  languageConfig: LanguageConfig(
                    localLang: Get.find<ConfigController>().userSetting.value.localLang,
                    learningLang: Get.find<ConfigController>().userSetting.value.learningLang,
                    learningLangShowSetting: Get.find<ConfigController>().userSetting.value.courseLang.langCode,
                  ),
                  oralEvaluationConfig: OralEvaluationConfig(
                    age: UserStore.to.userInfo.value.memberAge??0,
                    dictDialect: LanguageServiceCode.getEvelDctDialect(UserStore.to.userInfo.value.config?.national),
                    appkey: widget.soundAccount.app?.appId??"",
                    secretkey: widget.soundAccount.app?.secretKey??"",
                    userid: "TimelyWise",
                    wordCoreType: ShengTongConfig.wordCoreType,
                    url: ShengTongConfig.shengtongUrl,
                    sentCoreType: ShengTongConfig.sentCoreType,
                    wsUrl: ShengTongConfig.shengtongWsUrl,
                    isJudgeScore: widget.isJudgeScore,
                    hideResultAutoEnd: widget.hideResultAutoEnd,
                    passScore: ShengTongConfig.passScore,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 2.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: AppTheme.cBgTertiary,
              ),
              child: Text(
                showIdText,
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

}
