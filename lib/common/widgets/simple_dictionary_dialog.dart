

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/elements_detils/controllers/elements_detils_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/modules/application/common/nav_buttons_widget.dart';
import '../../app/modules/elements/common/elements_cards/elements_type_card_widget.dart';
import '../../app/modules/elements/model/elements_detils_data_model.dart';
import '../enum/elements_card_type.dart';
import '../../app/modules/elements/utils/elements_page_utils.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../https/https.dart';
import '../painter/painter.dart';
import '../public_controller/config_controller.dart';
import 'widgets.dart';



/// 简易词典弹窗
class SimpleDictionaryDialog{

  /// 返回结果 true=跳转到了详情页面 
  static Future<bool> show({
    required BuildContext context,
    required SentenceParsingWordsEntityList wordInfo,
  }) async{

    bool? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return SimpleDictionaryDialogWidget(
          wordInfo: wordInfo,
        );
      },
    );

    return res ?? false;
    
  }


  /// 显示选择卡牌弹窗
  static Future<bool> showAddCardDialog({
    required BuildContext context,
    required List<SimpleDictionaryAddCardParm> parameter,
    required String content,
    String buttonText = "记单词",
  }) async{
    bool? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return SimpleDictionaryAddCardDialogWidget(
          parameter: parameter,
          content: content,
          buttonText: buttonText,
        );
      },
    );
    return res ?? false;
  }

  /// 卡片记忆收集动画弹窗
  static Future<bool> showCollectDialog({
    required BuildContext context,
    int count = 1,
  }) async{
    bool? res = await showDialog<bool>(
      context: context,
      builder: (context) {
        return SimpleDictionaryCollectDialogWidget(
          count: count,
        );
      },
    );
    return res ?? false;
  }


  /// 把知识点卡牌加入到记忆请求
  /// [parameter] 参数 
  /// ```
  /// List<Map<String, dynamic>> parameter = [{
  ///   "uid": contentId,
  ///   "type": contentType,
  ///   "semanticId": semanticId,
  /// }];
  /// ```
  static Future<bool> addKnowledgeCard({
    required BuildContext context,
    required List<SimpleDictionaryAddCardParm> parameter,
  }) async{

    try {
      ToastUtils.showLoading();

      List<Map<String, dynamic>> reqParameter = [];
      for(var item in parameter){
        reqParameter.add({
          "uid": item.uid,
          "type": item.type,
          "semanticId": item.semanticId,
        });
      }

      bool resp = await ListenAndReadRequest.knowledgeAddCards(reqParameter);
      if(resp){

        await SimpleDictionaryDialog.showCollectDialog(
          context: context,
          count: parameter.length,
        );

        ToastUtils.showToast(text: "添加成功", type: ToastType.success);

        return true;

      }
      

    } finally{
      ToastUtils.hideLoading();
    }
    
    return false;
  }

}

class SimpleDictionaryDialogWidget extends StatefulWidget {
  final SentenceParsingWordsEntityList wordInfo;

  const SimpleDictionaryDialogWidget({
    super.key,
    required this.wordInfo,
  });

  @override
  State<SimpleDictionaryDialogWidget> createState() => _SimpleDictionaryDialogWidgetState();
}

class _SimpleDictionaryDialogWidgetState extends State<SimpleDictionaryDialogWidget> {
  


  /// 语言选择下标
  int languageSwitchIndex = 0;

  List<String> titleNavList = ["音节划分", "自然拼读"];
  int titleSwitchIndex = 0;

  List<PlayLottieIconController> playControllers = [];


  @override
  void initState(){
    super.initState();
    initSwitchIndex();
  }

  void initSwitchIndex(){
    List<SentenceParsingWordsEntityListPronunciations?> pronunciations = widget.wordInfo.pronunciations??[];
    if(pronunciations.isEmpty) return;

    playControllers = pronunciations.map((e) => PlayLottieIconController()).toList();

    List<SentenceParsingWordsEntityListPronunciationsSyllables?> syllables = widget.wordInfo.pronunciations?[languageSwitchIndex]?.syllables??[];
    List<SentenceParsingWordsEntityListPronunciationsPhonetics?> phonetics = widget.wordInfo.pronunciations?[languageSwitchIndex]?.phonetics??[];

    if (syllables.isNotEmpty) {
      titleSwitchIndex = 0;
      if ((syllables.length) <= 1) {
        titleSwitchIndex = 1;
      }
    } else if (phonetics.isNotEmpty) {
      titleSwitchIndex = 1;
    }
  
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cBlackAlpha10.color,
                offset: Offset(2.wMin, 4.wMin),
                blurRadius: 16.wMin,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.wMin),
            child: Stack(
              children: [
                Container(
                  width: 800.wMin,
                  color: AppTheme.cSurfaceSecondary.color,
                  constraints: BoxConstraints(
                    maxHeight: 828.wMin,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildImageHeardWidget(),
                        _buildContentWidget(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 8.wMin,
                  top: 8.wMin,
                  child: TapScaleWidget(
                    sclae: 1.05,
                    onTap: () => Get.back(result: false),
                    child: Container(
                      width: 42.wMin,
                      height: 42.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cSurfaceTertiary.color,
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/public/x.svg",
                        width: 24.wMin,
                        height: 24.wMin,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16.wMin,
                  right: 16.wMin,
                  child: _buildButtonsWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildButtonsWidget(){
    List<SentenceParsingWordsEntityListContentPosList?> contentPosList = widget.wordInfo.contentPosList??[];

    return Row(
      spacing: 16.wMin,
      children: [

        SimpleDictionaryMemoryButton(
          buttonText: "记单词",
          content: widget.wordInfo.content,
          parameter: contentPosList.map((e) => SimpleDictionaryAddCardParm(
            uid: e?.contentId,
            type: e?.contentType,
          )).toList(),
          onSuccess: () {
            if(Get.isRegistered<ElementsDetilsController>()){ 
              ElementsDetilsController controller = Get.find<ElementsDetilsController>();
              controller.refreshStudyListData();
            }
          },
        ),

        ButtonWidget(
          text: "查看更多",
          height: 68.wMin,
          width: 144.wMin,
          borderRadius: 999,
          color: AppTheme.cBgBrand.color,
          fontSize: 24.wMin,
          fontWeight: FontWeight.w600,
          fontColor: AppTheme.cInverseTextLight.color,
          sclae: 1.02,
          onTap: () {
            List<SentenceParsingWordsEntityListContentPosList?> posList = widget.wordInfo.contentPosList??[];
            if(posList.isEmpty) return;
            Get.back(result: true);

            ElementsPageUtils.jumpElementsPage(
              contentId: posList.first?.contentId,
              contentType: ElementsCardType.word.value,
              content: widget.wordInfo.content,
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageHeardWidget(){
     List<SentenceParsingWordsEntityListPronunciations?> pronunciations = widget.wordInfo.pronunciations??[];

    return Container(
      padding: EdgeInsets.only(
        top: 16.wMin,
        bottom: 16.wMin,
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.wMin),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.wMin,
            color: AppTheme.cBorderSecondary.color,
          ),
        ),
      ),
      child: Row(
        spacing: 16.wMin,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.wMin),
            child: SizedBox(
              width: 200.wMin,
              height: 200.wMin,
              child: CachedImageWidget(
                widget.wordInfo.imageUrl ?? "",
                errorWidget: buildEmptyWidget(),
                placeholder: buildEmptyWidget(),
                fadeInDuration: Duration.zero,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.wordInfo.content??"",
                  style: TextStyle(
                    fontSize: 56.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Wrap(
                  spacing: 8.wMin,
                  runSpacing: 8.wMin,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: List.generate(pronunciations.length, (index){
                    return _buildPronunciationItemWIdget(pronunciations[index], index);
                  }),
                ),
      
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPronunciationItemWIdget(SentenceParsingWordsEntityListPronunciations? pronunciation, int index){
  

    return TapScaleWidget(
      onTap: () {
        playControllers[index].play();
      },
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.only(
          left: 2.wMin,
          right: 16.wMin,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.wMin,
          children: [
            PlayLottieIconWidget(
              size: 42.wMin,
              audioUrl: pronunciation?.audioUrl,
              backgroundImageUrl: pronunciation?.nationalIconUrl,
              controller: playControllers[index],
            ),
            Text(
              pronunciation?.nationalTitle??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "/ ${pronunciation?.phonetic??''} /",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
                fontFamily: "AndikaRegular",
              ),
            ),
      
          ],
        ),
      ),
    );
  }

  

  Widget _buildContentWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        children: [
          _buildTitleSwitchWidget(),
          _buildListWordInfoListWidget(),

          SizedBox(height: 80.wMin),
        ],
      ),
    );
  }

  /// 音节划分自然拼读切换按钮
  Widget _buildTitleSwitchWidget(){
    if(widget.wordInfo.pronunciations == null || widget.wordInfo.pronunciations!.isEmpty) return Container();
    List<SentenceParsingWordsEntityListPronunciationsSyllables?> syllables = widget.wordInfo.pronunciations?[languageSwitchIndex]?.syllables??[];
    List<SentenceParsingWordsEntityListPronunciationsPhonetics?> phonetics = widget.wordInfo.pronunciations?[languageSwitchIndex]?.phonetics??[];
    if(syllables.isEmpty && phonetics.isEmpty) return Container();
    
    return Column(
      children: [
        _buildLanguageSwitchWidget(),
        Container(
          height: 2.wMin,
          width: 1020.wMin,
          color: AppTheme.cBorderPrimary.color,
        ),
        SizedBox(height: 10.wMin),
        AnimatedToggleSwitch<int>.size(
          current: titleSwitchIndex,
          values: List.generate(titleNavList.length, (index) => index),
          indicatorSize: Size.fromWidth(222.wMin),
          height: 64.wMin,
          iconBuilder: (index){
            return Text(
              titleNavList[index],
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
            borderRadius: BorderRadius.circular(16.wMin),
            backgroundColor: AppTheme.cSurfaceTertiary.color,
            indicatorBorderRadius: BorderRadius.circular(14.wMin),
            indicatorColor: AppTheme.cSurfaceSecondary.color,
            
          ),
          onChanged: (i) {
            setState(() {
              titleSwitchIndex = i;
            });
          },
        ),
        SizedBox(height: 10.wMin),
        _buildSpellingAndDisassemblyWidget(),

      ],
    );
  }

  /// 语言方言切换
  Widget _buildLanguageSwitchWidget(){
    List<SentenceParsingWordsEntityListPronunciations?> pronunciations = widget.wordInfo.pronunciations??[];

    return Container(
      height: 50.wMin,
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        children: List.generate(pronunciations.length, (index){
          return Expanded(
            child: Row(
              children: [
                Visibility(
                  visible: index > 0,
                  child: Center(
                    child: Container(
                      width: 2.wMin,
                      height: 26.wMin,
                      color: AppTheme.cBorderPrimary.color,
                    ),
                  ),
                ),
                Expanded(
                  child: TapScaleWidget(
                    onTap: () {
                      languageSwitchIndex = index;
                      if(mounted) setState(() {});
                    },
                    sclae: 1,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: Text(
                        pronunciations[index]?.nationalTitle ?? "",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: languageSwitchIndex == index ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 划分
  Widget _buildSpellingAndDisassemblyWidget(){
    List<SentenceParsingWordsEntityListPronunciationsSyllables?> syllables = widget.wordInfo.pronunciations?[languageSwitchIndex]?.syllables??[];
    List<SentenceParsingWordsEntityListPronunciationsPhonetics?> phonetics = widget.wordInfo.pronunciations?[languageSwitchIndex]?.phonetics??[];

    if(titleSwitchIndex == 0){
      return SimpleDictionaryDialogSyllableWidget(
        syllables: syllables,
        audioUrl: widget.wordInfo.pronunciations?[languageSwitchIndex]?.audioUrl,
        content: widget.wordInfo.content,
      );
    }
    return SimpleDictionaryDialogPhoneticesWidget(
      audioUrl: widget.wordInfo.pronunciations?[languageSwitchIndex]?.audioUrl,
      phonetics: phonetics,
      content: widget.wordInfo.content,
    );
  }

  Widget _buildListWordInfoListWidget(){
    List<SentenceParsingWordsEntityListContentPosList?> contentPosList = widget.wordInfo.contentPosList??[];
    contentPosList.removeWhere((element) => element == null);
    if(contentPosList.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: ListView.separated(
        itemCount: contentPosList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        separatorBuilder: (context, index) {
          return SizedBox(height: 16.wMin);
        },
        itemBuilder: (context, index) {
          return _buildListWordInfoItemWidget(contentPosList[index]);
        },
      ),
    );
  }

  Widget _buildListWordInfoItemWidget(SentenceParsingWordsEntityListContentPosList? posList){
    if(posList == null) return Container();

    List<LanguageConfigColorEntityInfo?>? posColors = Get.find<ConfigController>().colorConfigs.value.pos;
    
    LanguageConfigColorModel? colors = StatusUtils.getConfigColorForAbbr(posColors, posList.pos);

    List<LanguageText?> gloss = posList.gloss??[];
    gloss.removeWhere((element) => element == null);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        border: Border(
          left: BorderSide(width: 4.wMin, color: AppTheme.cBorderTertiary.color),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: (colors?.color?.bgColor??AppTheme.cFeedbackInfoBackground.color).withValues(alpha: 0.2),
            ),
            child: Text(
              "${posList.pos??''} ${posList.posTitle??''}",
              style: TextStyle(
                fontSize: 22.wMin,
                color: colors?.color?.bgColor ?? AppTheme.cTextBrand.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 4.wMin),

          Column(
            spacing: 4.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(gloss.length, (index){
              TextStyle textStyle = TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              );
              if(index == 0){
                textStyle = TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                );
              }

              return Text(
                gloss[index]?.text??'',
                style: textStyle,
              );
            }),
          ),

        ],
      ),
    );
  }

  


}




class SimpleDictionaryDialogPhoneticesWidget extends StatefulWidget {
  final String? content;
  final String? audioUrl;
  final List<SentenceParsingWordsEntityListPronunciationsPhonetics?> phonetics;

  /// 自然拼读
  const SimpleDictionaryDialogPhoneticesWidget({
    super.key, 
    this.content,
    this.audioUrl, 
    required this.phonetics,
  });

  @override
  State<SimpleDictionaryDialogPhoneticesWidget> createState() => _SimpleDictionaryDialogPhoneticesWidgetState();
}

class _SimpleDictionaryDialogPhoneticesWidgetState extends State<SimpleDictionaryDialogPhoneticesWidget> {
  int playingIndex = -1;

  /// 自然拼读 字母
  List<DecodingGradingLetterModel> gradingLetters = [];
  /// 自然拼读 音节
  List<String> phoneticsStrs = [];
  /// 自然拼读 位置
  List<List<int?>> phoneticsPos = [];

  @override
  void initState() {
    super.initState();
    setGradingLettersData();
  }

  @override
  void dispose() {
    super.dispose();
    PlayAudioUtils.instance.stopAll();
  }

  void setGradingLettersData() {
    List<SentenceParsingWordsEntityListPronunciationsPhonetics?> phonetics = widget.phonetics;

    if (phonetics.isEmpty) return;
    phoneticsStrs.clear();
    phoneticsPos.clear();
    for (var item in phonetics) {
      if (item == null) continue;
      phoneticsStrs.add(item.ipa ?? "");
      List<int?> positions = item.positions ?? [];
      if (item.ipa == null || item.ipa == "") {
        positions = [];
      }
      phoneticsPos.add(positions);
    }

    gradingLetters.clear();
    for (int i = 0; i < (widget.content?.length??0); i++) {
      gradingLetters.add(DecodingGradingLetterModel(
        letter: widget.content?[i]??'',
        key: GlobalKey(),
      ));
    }
    if (mounted) setState(() {});
  }
  

  /// 开始播放自然拼读
  Future<void> startPlayPhonetics() async {
    if (playingIndex != -1) return;
    List<SentenceParsingWordsEntityListPronunciationsPhonetics?> phonetics = widget.phonetics;
    for (int i = 0; i < phonetics.length; i++) {
      if (phonetics[i] == null) continue;
      if (phonetics[i]?.audioUrl == null) continue;
      playingIndex = i;
      if (mounted) setState(() {});
      await PlayAudioUtils.instance.playSingle(phonetics[i]?.audioUrl);
      if (!mounted) return;
    }

    playingIndex = 999;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(widget.audioUrl);
    if (!mounted) return;
    playingIndex = -1;
    if (mounted) setState(() {});
  }

  /// 点击单个自然拼读字母播放
  Future<void> playPhoneticsItem(int index) async {
    if (playingIndex != -1) return;
    List<SentenceParsingWordsEntityListPronunciationsPhonetics?> phonetics = widget.phonetics;
    /// 自然拼读 位置
    List<List<int?>> phoneticsPos = [];

    for (var item in phonetics) {
      if (item == null) continue;
      List<int?> positions = item.positions ?? [];
      if (item.ipa == null || item.ipa == "") {
        positions = [];
      }
      phoneticsPos.add(positions);
    }

    for (int i = 0; i < phonetics.length; i++) {
      if (phoneticsPos[i].contains(index)) {
        if (phonetics[i] == null) continue;
        if (phonetics[i]?.audioUrl == null) continue;
        playingIndex = i;
        if (mounted) setState(() {});
        await PlayAudioUtils.instance.playSingle(phonetics[i]?.audioUrl);
        break;
      }
    }
    playingIndex = -1;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool all = playingIndex == 999;
    bool none = playingIndex == -1;

    if (gradingLetters.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        CustomPaint(
          painter: DecodingGradingPainter(
            strokeWidth: 5.wMin,
            curveRadius: 25.wMin,
            letterBottomHeight: 4.wMin,
            models: gradingLetters,
            positions: phoneticsPos,
            color: AppTheme.cTextBrand.color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(gradingLetters.length, (index) {
              Color textColor = AppTheme.cTextPrimary.color;
              if (none) {
                textColor = AppTheme.cTextPrimary.color;
              } else if (all) {
                textColor = AppTheme.cTextBrand.color;
              } else {
                if (playingIndex != -1 && playingIndex != 999) {
                  if (phoneticsPos[playingIndex].contains(index)) {
                    textColor = AppTheme.cTextBrand.color;
                  } else {
                    textColor = AppTheme.cTextPrimary.color;
                  }
                }
              }

              return TapScaleWidget(
                onTap: () {
                  playPhoneticsItem(index);
                },
                sclae: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.wMin),
                  color: Colors.transparent,
                  child: Text(
                    gradingLetters[index].letter,
                    key: gradingLetters[index].key,
                    style: TextStyle(
                      fontSize: 48.wMin,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 10.wMin),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "/ ",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
                fontFamily: "AndikaRegular",
              ),
            ),
            Row(
              children: List.generate(phoneticsStrs.length, (index) {
                Color textColor = AppTheme.cTextPrimary.color;
                if (none) {
                  textColor = AppTheme.cTextPrimary.color;
                } else if (all) {
                  textColor = AppTheme.cTextBrand.color;
                } else {
                  if (playingIndex != -1 && playingIndex != 999) {
                    if (playingIndex == index) {
                      textColor = AppTheme.cTextBrand.color;
                    } else {
                      textColor = AppTheme.cTextPrimary.color;
                    }
                  }
                }
                return Text(
                  phoneticsStrs[index],
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: textColor,
                    fontWeight: FontWeight.w400,
                    fontFamily: "AndikaRegular",
                  ),
                );
              }),
            ),
            Text(
              " /",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
                fontFamily: "AndikaRegular",
              ),
            ),
            SizedBox(width: 10.wMin),
            TapScaleWidget(
              onTap: () {
                startPlayPhonetics();
              },
              sclae: 1.03,
              child: _buildPlayButtonWidget(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayButtonWidget() {
    return Container(
      width: 64.wMin,
      height: 64.wMin,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: SvgPicture.asset(
        "assets/svg/public/icon_speaker.svg",
        width: 40.wMin,
        height: 40.wMin,
        colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
      ),
    );
  }

}

class SimpleDictionaryDialogSyllableWidget extends StatefulWidget {
  final String? audioUrl;
  final List<SentenceParsingWordsEntityListPronunciationsSyllables?> syllables;
  final String? content;
  /// 音节拆分
  const SimpleDictionaryDialogSyllableWidget({super.key, this.audioUrl, required this.syllables, this.content});

  @override
  State<SimpleDictionaryDialogSyllableWidget> createState() => _SimpleDictionaryDialogSyllableWidgetState();
}

class _SimpleDictionaryDialogSyllableWidgetState extends State<SimpleDictionaryDialogSyllableWidget> {

  int playingIndex = -1;

    /// 播放音节Item
  Future<void> playSyllablesItem(int index) async {
    if (playingIndex != -1) return;
    if (index >= widget.syllables.length) return;
    if (widget.syllables[index] == null) return;
    if (widget.syllables[index]?.audioUrl == null) return;
    playingIndex = index;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(widget.syllables[index]?.audioUrl ?? "");
    if (!mounted) return;
    playingIndex = -1;
    if (mounted) setState(() {});
  }

  /// 开始播放音节
  Future<void> startPlaySyllables() async {
    if (playingIndex != -1) return;
    for (int i = 0; i < widget.syllables.length; i++) {
      if (widget.syllables[i] == null) continue;
      if (widget.syllables[i]?.audioUrl == null) continue;
      playingIndex = i;
      if (mounted) setState(() {});
      await PlayAudioUtils.instance.playSingle(widget.syllables[i]?.audioUrl ?? "");
      if (!mounted) return;
    }

    if (widget.syllables.length == 1) {
      playingIndex = -1;
      if (mounted) setState(() {});
      return;
    }

    playingIndex = 999;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(widget.audioUrl ?? "");
    if (!mounted) return;
    playingIndex = -1;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    PlayAudioUtils.instance.stopAll();
  }

  @override
  Widget build(BuildContext context) {
    bool all = playingIndex == 999;
    bool none = playingIndex == -1;

    TextStyle textStyle = TextStyle(
      fontSize: 48.wMin,
      color: AppTheme.cTextPrimary.color,
      fontWeight: FontWeight.w500,
    );

    String original = widget.content ?? "";
    int letters = 0;
    Map<int, int> hyphenMap = {};
    for (int i = 0; i < original.length; i++) {
      String ch = original[i];
      if (ch == '-') {
        hyphenMap[letters] = (hyphenMap[letters] ?? 0) + 1;
      } else {
        letters++;
      }
    }

    final List<String> displayTexts = [];
    final List<int?> displaySources = [];
    int acc = 0;
    for (int sourceIndex = 0; sourceIndex < widget.syllables.length; sourceIndex++) {
      String g = widget.syllables[sourceIndex]?.graphemes ?? "";
      displayTexts.add(g);
      displaySources.add(sourceIndex);
      acc += g.length;
      int hyphenCount = hyphenMap[acc] ?? 0;
      for (int h = 0; h < hyphenCount; h++) {
        displayTexts.add("-");
        displaySources.add(null);
      }
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6.wMin,
          children: List.generate(displayTexts.length, (index) {
            int? srcIdx = displaySources[index];
            bool isActive = playingIndex == 999 || (srcIdx != null && playingIndex == srcIdx);
            if (srcIdx == null) {
              return Text(displayTexts[index], style: textStyle);
            }
            return TapScaleWidget(
              onTap: () {
                playSyllablesItem(srcIdx);
              },
              sclae: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: isActive ? AppTheme.cTextBrand.color.withValues(alpha: 0.8) : AppTheme.cBgQuaternary.color,
                ),
                child: Text(
                  displayTexts[index],
                  style: textStyle,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 10.wMin),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "/ ",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
                fontFamily: "AndikaRegular",
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.syllables.length, (index) {
                Color textColor = AppTheme.cTextPrimary.color;
                if (none) {
                  textColor = AppTheme.cTextPrimary.color;
                } else if (all) {
                  textColor = AppTheme.cTextBrand.color;
                } else {
                  if (playingIndex != -1 && playingIndex != 999) {
                    if (playingIndex == index) {
                      textColor = AppTheme.cTextBrand.color;
                    } else {
                      textColor = AppTheme.cTextPrimary.color;
                    }
                  }
                }

                return Text(
                  widget.syllables[index]?.ipa ?? "",
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: "AndikaRegular",
                  ),
                );
              }),
            ),
            Text(
              " /",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
                fontFamily: "AndikaRegular",
              ),
            ),
            SizedBox(width: 10.wMin),
            TapScaleWidget(
              onTap: () {
                startPlaySyllables();
              },
              sclae: 1.03,
              child: _buildPlayButtonWidget(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayButtonWidget() {
    return Container(
      width: 64.wMin,
      height: 64.wMin,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: SvgPicture.asset(
        "assets/svg/public/icon_speaker.svg",
        width: 40.wMin,
        height: 40.wMin,
        colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
      ),
    );
  }
}



class SimpleDictionaryAddCardParm{
  int? uid;
  String? type;
  int? semanticId;

  SimpleDictionaryAddCardParm({
    this.uid,
    this.type,
    this.semanticId,
  });
}

/// 加入卡册弹窗
class SimpleDictionaryAddCardDialogWidget extends StatefulWidget {
  final List<SimpleDictionaryAddCardParm> parameter;
  final String content;
  final String buttonText;
  const SimpleDictionaryAddCardDialogWidget({
    super.key, 
    required this.parameter,
    required this.content,
    this.buttonText = "记单词",
  });

  @override
  State<SimpleDictionaryAddCardDialogWidget> createState() => _SimpleDictionaryAddCardDialogWidgetState();
}

class _SimpleDictionaryAddCardDialogWidgetState extends State<SimpleDictionaryAddCardDialogWidget> {

  List<_SimpleDicCardSimModel> cardList = [];
  
  ElementsCardEntityDatas? selectData;



  @override
  void initState() {
    super.initState();
    getCardList();
  }


  Future<void> getCardList() async{

    try {
        ToastUtils.showLoading();
        List<Map<String, dynamic>> reqData = [];

        for (var element in widget.parameter) {
        reqData.add({
          "uid": element.uid,
          "type": element.type,
        });
      }

      Map<String, dynamic> reqDataMap = {
        "contents": reqData,
      };

      List<ElementsCardEntityDatas>? resp = await ListenAndReadRequest.getKnowledgeSemantics(reqDataMap);
      if(resp == null) return;
      cardList = resp.map((e) {
        return _SimpleDicCardSimModel(
          data: e,
        );
      }).toList();

      if(mounted) setState(() {});


    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 添加
  Future<void> addCard() async{
    if(selectData == null) {
      ToastUtils.showToast(text: "请选择一个释义");
      return;
    }

    SimpleDictionaryAddCardParm reqData = SimpleDictionaryAddCardParm(
      uid: selectData?.contentId,
      type: selectData?.contentType,
      semanticId: selectData?.semanticId,
    );

    bool resp = await SimpleDictionaryDialog.addKnowledgeCard(
      context: context,
      parameter: [reqData],
    );
    if(!resp) return;
    Get.back(result: true);

  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: 1836.wMin,
            height: 900.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: Column(
              children: [
                _buildTitleWidget(),
                Expanded(child: _buildCardListWidget()),
                _buildButtonWidget(),
              ],
            ),
          ),
        ),
        

      ),

    );
  }

  

  Widget _buildTitleWidget(){
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 16.wMin),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cBorderSecondary.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.content,
              style: TextStyle(
                fontSize: 36.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TapScaleWidget(
            sclae: 1.05,
            onTap: () => Get.back(),
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cSurfaceTertiary.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 32.wMin,
                height: 32.wMin,
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildCardListWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: ListView.separated(
        itemCount: cardList.length,
        padding: EdgeInsets.symmetric(vertical: 24.wMin),
        separatorBuilder: (context, index) {
          return Container(
            height: 1.wMin,
            color: AppTheme.cBorderSecondary.color,
            margin: EdgeInsets.symmetric(vertical: 16.wMin),
          );
        },
        itemBuilder: (context, index) {
          return _buildCardItemListWidget(cardList[index]);
        },
      ),
      
    );
  }

  Widget _buildCardItemListWidget(_SimpleDicCardSimModel data){

    List<LanguageText?> gloss = data.data.gloss??[];
    gloss.removeWhere((element) => element == null);

    List<ElementsCardEntityDatas?> contentList = data.data.contentList??[];
    contentList.removeWhere((element) => element == null);

    List<ElementsCardEntityDatasags?> tags = data.data.tags??[];
    tags.removeWhere((element) => element == null);

    return Column(
      children: [

        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              left: BorderSide(
                color: AppTheme.cBorderTertiary.color,
                width: 4.wMin,
              ),
            ),
          ),
          child: Row(
            spacing: 8.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: tags.isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(top: 6.wMin),
                  child: Row(
                    spacing: 4.wMin,
                    children: List.generate(tags.length, (index){
                  
                      TextStyle? style = StyleUtils.getTextStyle(tags[index]?.style);

                       ThemeTextStyleEntity? themeText = StyleUtils.getCurrentThemeText(tags[index]?.style);

                      Color? backgroundColor = ColorUtils.parseColor(themeText?.backgroundColor);
                      Color? borderColor = ColorUtils.parseColor(themeText?.borderColor);
                  
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.wMin),
                          color: backgroundColor,
                          border: Border.all(
                            color: borderColor??AppTheme.cBorderTertiary.color,
                            width: 1.wMin,
                          ),
                        ),
                        child: Text(
                          tags[index]?.gloss?.map((e) => e?.text).join(" ")??'',
                          style: style,
                        ),
                      );
                  
                    }),
                  ),
                ),
              ),

              Expanded(
                child: Row(
                  spacing: 8.wMin,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(gloss.length, (index){
                          TextStyle textStyle = TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextSecondary.color,
                            fontWeight: FontWeight.w400,
                          );
                          if(index == 0){
                            textStyle = TextStyle(
                              fontSize: 28.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w500,
                            );
                          }

                          return Text(gloss[index]!.text??'', style: textStyle);

                        }),
                      ),
                    ),
                
                    // SvgPicture.asset(
                    //   "assets/svg/public/icon_caret_down.svg",
                    //   width: 32.wMin,
                    // ),
                  ],
                ),
              ),

            ],
          ),
        ),


        GridView.builder(
          itemCount: contentList.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.wMin, top: 16.wMin),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16.wMin,
            crossAxisSpacing: 16.wMin,
            mainAxisExtent: 180.wMin,
          ),
          itemBuilder: (context, index) {
            return _buildCardItemWidget(contentList[index]);
          },
        ),



      ],
    );
  }


  Widget _buildCardItemWidget(ElementsCardEntityDatas? data){

    List<LanguageText?> gloss = LearningLangUtils.sortLocalLangFirst(data?.gloss??[]);

    // List<ElementsCardEntityDatasags?> tags = data?.tags??[];

    bool isFavorited = data?.isFavorited??false;
    
    bool selected = selectData?.contentId == data?.contentId && selectData?.semanticId == data?.semanticId;

    return TapScaleWidget(
      onTap: isFavorited ? null : () {
        if(data?.isFavorited??false) {
          return;
        }
        selectData = data;
        if(mounted) setState(() {});
      },
      sclae: 1.01,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.wMin),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTertiary.color,
          ),
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    CachedImageWidget(
                      data?.imageUrl??"",
                      errorWidget: buildEmptyWidget(),
                      placeholder: buildEmptyWidget(),
                      fadeInDuration: Duration.zero,
                    ),
                    Positioned(
                      top: 6.wMin,
                      left: 6.wMin,
                      child: Visibility(
                        visible: isFavorited,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: AppTheme.cMemoryPrimary.color,
                          ),
                          child: Text(
                            "已记忆",
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: AppTheme.cInverseTextLight.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDifficultyWidget(data?.difficulty),
                          Opacity(
                            opacity: !isFavorited ? 1 : 0,
                            child: SvgPicture.asset(
                              selected ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                              width: 32.wMin,
                            ),
                          ),
      
                        ],
                      ),
                      SizedBox(height: 16.wMin),
      
                      Column(
                        spacing: 4.wMin,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(gloss.length, (index){
                          TextStyle textStyle = TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w600,
                          );
                          if(index == 0){
                            return Text(
                              gloss[index]!.text??'', 
                              style: textStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                          return Text(
                            gloss[index]!.text??'', 
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22.wMin,
                              color: AppTheme.cTextTertiary.color,
                              fontWeight: FontWeight.w400,
                            ),
                          );
      
                        }),
                      ),
                      
      
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyWidget(CardContentDifficulty? difficulty) {
    if (difficulty?.min == difficulty?.max) {
      return StatusTagDifficultyWidget(
        difficulty: difficulty?.min,
        language: Get.find<ConfigController>().userSetting.value.learningLang,
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        height: 24.wMin,
        alignment: Alignment.center,
      );
    }

    return Row(
      children: [
        StatusTagDifficultyWidget(
          difficulty: difficulty?.min,
          language: Get.find<ConfigController>().userSetting.value.learningLang,
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          height: 24.wMin,
          alignment: Alignment.center,
        ),
        Text(
          "-",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        StatusTagDifficultyWidget(
          difficulty: difficulty?.max,
          language: Get.find<ConfigController>().userSetting.value.learningLang,
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          height: 24.wMin,
          alignment: Alignment.center,
        ),
      ],
    );
  }


  Widget _buildButtonWidget(){
    bool isSelect = selectData != null;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "选择一个释义，加入到卡册，会自动加入到日常的规划，帮助${widget.buttonText}。",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 12.wMin),
          ButtonWidget(
            text: widget.buttonText,
            width: 388.wMin,
            height: 72.wMin,
            borderRadius: 12.wMin,
            color: isSelect ? AppTheme.cMemoryPrimary.color : AppTheme.cSurfaceTertiary.color,
            fontColor: isSelect ? AppTheme.cInverseTextLight.color : AppTheme.cTextPrimary.color,
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: !isSelect ? null : () {
              addCard();
            },
          ),
        ],
      ),
    );
  }


  
}


class _CardAnimDataModel{
  Offset offset;
  double scale = 1.0;
  GlobalKey key;
  ElementsDetilsDataModel? data;

  _CardAnimDataModel({
    required this.key,
    required this.data,
    this.offset = Offset.zero,
  });
}

/// 卡片记忆收集动画弹窗
class SimpleDictionaryCollectDialogWidget extends StatefulWidget {
  final int count;
  const SimpleDictionaryCollectDialogWidget({super.key, required this.count});

  @override
  State<SimpleDictionaryCollectDialogWidget> createState() => _SimpleDictionaryCollectDialogWidgetState();
}

class _SimpleDictionaryCollectDialogWidgetState extends State<SimpleDictionaryCollectDialogWidget> with TickerProviderStateMixin{

  final GlobalKey _cardBooksKey = GlobalKey();

  List<_CardAnimDataModel> cardpileDatas = [];

  @override
  void initState() {
    super.initState();
    initData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      runCollectAnimation();
    });
  }

  /// 初始化数据
  void initData(){
    for(int i = 0; i < widget.count; i++){
      cardpileDatas.add(_CardAnimDataModel(
        key: GlobalKey(),
        data: ElementsDetilsDataModel(
          type: ElementsCardType.word,
          data: ElementsCardEntityDatas(
            
          ),
        ),
        offset: Offset(-(i * 10.wMin), i * (15.wMin)),
      ));
    }
  }


 /// 运行集卡动画
  Future<void> runCollectAnimation() async{
    if(mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 1000));

    RenderBox? stackBox = context.findRenderObject() as RenderBox?;
    if(stackBox == null) return;
    Size stackSize = stackBox.size;

    // 获取目标位置（导航栏图标）
    RenderBox? targetBox = _cardBooksKey.currentContext?.findRenderObject() as RenderBox?;
    if(targetBox == null) return;
    
    Size targetSize = targetBox.size;
    Offset end = stackBox.globalToLocal(targetBox.localToGlobal(Offset.zero));
    end = end - Offset((stackSize.width - targetSize.width) / 2, 100.wMin);
    // 纵向对齐到图标中心，避免以左上角导致位置偏差
    end = end + Offset(0, targetSize.height / 2);
   
    for(int i = cardpileDatas.length - 1; i >= 0; i--){
      await Future.delayed(const Duration(milliseconds: 100));
      if(!mounted) break;
      GlobalKey key = cardpileDatas[i].key;
      RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
      if(box == null) continue;
      Size boxSize = box.size;
      // 开始位置就是当前卡片的offset位置
      Offset begin = cardpileDatas[i].offset;
      Offset offset = end - Offset(0, boxSize.height / 2);

      toOffset(
        begin: begin,
        end: offset,
        onUpdate: (offset, value){
          cardpileDatas[i].scale = 1.0 - value * 0.95; // 缩放到0.2而不是0
          cardpileDatas[i].offset = offset;
          if(mounted) setState(() {});
        },
        onCompleted: (){
          cardpileDatas.removeAt(i);
          if(mounted) setState(() {});
          if(cardpileDatas.isEmpty){
            Future.delayed(const Duration(milliseconds: 500), (){
              Get.back(result: true);
            });
          }
        },
      );
    }
  }

  void toOffset({
    required Offset begin, 
    required Offset end, 
    int milliseconds = 200,
    Curve curve = Curves.linear,
    void Function(Offset, double)? onUpdate, 
    void Function()? onCompleted,
  }){
    final AnimationController matchController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: milliseconds), 
    );

    final Animation<Offset> animation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: matchController,
      curve: curve,
    ));

    matchController.addListener(() {
      onUpdate?.call(animation.value, matchController.value);
    });

    matchController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        matchController.dispose();
        onCompleted?.call();
      }
    });
    matchController.forward();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: _buildCardpileWidget(),
      ),
      bottomNavigationBar: _buildNavWidget(),
    );
  }

    /// 卡堆
  Widget _buildCardpileWidget(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.only(top: 100.wMin),
      child: Stack(
        alignment: Alignment.topCenter,
        children: List.generate(cardpileDatas.length, (index){
          return Transform.translate(
            offset: cardpileDatas[index].offset,
            child: Transform.scale(
              scale: cardpileDatas[index].scale,
              child: ElementsTypeCardWidget(
                key: cardpileDatas[index].key,
                side: CardSide.BACK,
                disableTap: true,
                data: cardpileDatas[index].data,
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildNavWidget(){
    return GestureDetector(
      onTap: (){
        // runCollectAnimation();
      },
      child: NavButtonsWidget(
        disableButton: true,
        // 关键修复：将GlobalKey绑定到“要素”图标，而不是整个Nav容器
        cardsKey: _cardBooksKey,
        opactiyButton: true,
      ),
    );
  }
}


class _SimpleDicCardSimModel{
  ElementsCardEntityDatas data;
  
  // bool open;

  _SimpleDicCardSimModel({
    required this.data,
    // this.open = true,
  });
}





class SimpleDictionaryMemoryButton extends StatelessWidget {
  final String buttonText;
  final String? content;
  final List<SimpleDictionaryAddCardParm> parameter;
  final bool directCollect;
  final void Function()? onSuccess;
  /// 记忆按钮
  const SimpleDictionaryMemoryButton({
    super.key, 
    required this.buttonText,
    this.content, 
    required this.parameter,
    this.directCollect = false,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () async{
        if(directCollect){
          bool res = await SimpleDictionaryDialog.addKnowledgeCard(
            context: context, 
            parameter: parameter,
          ); 
          if(!res) return;
        }else{
          bool res = await SimpleDictionaryDialog.showAddCardDialog(
            context: context, 
            content: content??"",
            parameter: parameter,
            buttonText: buttonText,
          ); 
          if(!res) return;
        }
        
        onSuccess?.call();
      },
      sclae: 1.02,
      child: Container(
        height: 68.wMin,
        width: 172.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: AppTheme.cSurfaceQuaternary.color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8.wMin,
          children: [
            const MemoryIconWidget(),
            Text(
              buttonText,
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            )
          ],
        ),
      ),
      
    );
  }
}