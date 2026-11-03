import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/utils/elements_page_utils.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:lib_common/utils/storage_util.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/public_controller/model/user_setting_model.dart';
import '../../../../../common/values/values.dart';
import '../../../../../utils/utils.dart';
import '../views/official_course_details_flash_setting_dialog.dart';

class OfficialCourseDetailsFlashNotesController extends GetxController with RoutesBreadcrumbMixin {
  static const String _bilingualCode = 'bilingual';
  static const String _originalCode = 'original';
  static const String _translationCode = 'translation';
  static const String _noneCode = 'none';

  final String tagText;
  OfficialCourseDetailsFlashNotesController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES;

  @override
  String get breadcrumbTitle => "闪记";

  List<UnitKnowledgePointsEntityKnowledgeList>? knowledgeListArgs;
  bool enableLearnUpload = false;
  String? learnUploadType;
  bool _hasStartedLearnUpload = false;
  static const String _learnRecordSource = 'official_course_details_flash_notes';

  /// 知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  /// 当前选中的知识点类型
  final RxList<ElementsCardType> selectedKnowledgeTypes = <ElementsCardType>[].obs;

  /// 显示设置
  final Rx<FlashSettingCardShowType> showType = FlashSettingCardShowType.image.obs;

  final PageController pageController = PageController();

  // 当前索引
  RxInt currentIndex = 0.obs;

  /// 翻转状态
  RxBool cardIsFront = true.obs;

  /// 切换节奏
  Rx<double> playInterval = 10.0.obs;

  /// 是否自动播放（根据计时器自动翻到下一张）
  RxBool isAutoPlay = true.obs;

  /// 已经掌握的知识点id列表
  final RxList<int> masteredKnowledgeIds = <int>[].obs;

  /// 待加强的知识点id列表
  final RxList<int> improvedKnowledgeIds = <int>[].obs;

  Timer? _autoNextTimer;

  RxInt audioDuration = 0.obs;

  Rx<double> playSpeed = 1.0.obs;

  /// 发音
  final Rx<LanguageServiceCodeEnum> national = LanguageServiceCodeEnum.US.obs;

  /// 页面是否准备完成
  final RxBool isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
    initUserSetting();
    national.value = LanguageServiceCodeEnum.fromValue(UserStore.to.userInfo.value.config?.national);
    List<double> intervalList = Get.find<ConfigController>().userSetting.value.intervalMenu!.map((e) => e.value!).toList();
    if(intervalList.isEmpty){
      playInterval.value =12.5;
    }else{
      playInterval.value = StorageUtil().getDouble(INTERVAL_SPEED_KEY) ?? intervalList[3];
      final intervalIndex = intervalList.indexOf(playInterval.value);
      if (intervalIndex == -1) {
        playInterval.value = intervalList[3];
      }
    }

    if (Get.arguments != null) {
      knowledgeListArgs = List<UnitKnowledgePointsEntityKnowledgeList>.from(Get.arguments["knowledgeList"]).toList();
      enableLearnUpload = Get.arguments["enableLearnUpload"] == true;
      learnUploadType = Get.arguments["learnUploadType"]?.toString();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSetting(isFirst: true);
      });
    }
  }

  /// 获取本地储存的设置
  Future<void> initUserSetting() async{
    if(Get.isRegistered<ConfigController>()){
      UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;
      playSpeed.value = userSetting.expandAudioSpeed;
    }
  }

  /// 开始或暂停自动播放
  void toggleAutoPlay() {
    isAutoPlay.value = !isAutoPlay.value;
    if (isAutoPlay.value) {
      nextCard();
      restartAutoNextTimer();
    } else {
      cancelAutoNextTimer();
    }
  }

  /// 重启自动翻页计时器
  void restartAutoNextTimer() async {
    cancelAutoNextTimer();
    if (!isAutoPlay.value) return;
    if (knowledgeList.isEmpty) return;

    _autoNextTimer = Timer(Duration(milliseconds: audioDuration.value), () {
      // 触发下一张，并在成功后继续计时
      if (!isAutoPlay.value) return;
      if (knowledgeList.isEmpty) return;
      nextCard();
      // nextCard 内部会再次调用 _restartAutoNextTimer
    });
  }

  void cancelAutoNextTimer() {
    _autoNextTimer?.cancel();
    _autoNextTimer = null;
  }

  Future<void> showSetting({bool isFirst = false}) async {
    if (knowledgeListArgs == null) return;
    if (Get.context == null) return;

    List<UnitKnowledgePointsEntityKnowledgeList> words = [];
    List<UnitKnowledgePointsEntityKnowledgeList> phrases = [];
    List<UnitKnowledgePointsEntityKnowledgeList> sentences = [];

    for (int i = 0; i < knowledgeListArgs!.length; i++) {
      if (knowledgeListArgs![i].isWord) {
        words.add(knowledgeListArgs![i]);
      } else if (knowledgeListArgs![i].isPhrase) {
        phrases.add(knowledgeListArgs![i]);
      } else if (knowledgeListArgs![i].isSentence) {
        sentences.add(knowledgeListArgs![i]);
      }
    }

    List<FlashSettingKnowledgeTypeItemModel> knowledgePoints = [];
    if (words.isNotEmpty) {
      knowledgePoints.add(FlashSettingKnowledgeTypeItemModel(
        type: ElementsCardType.word,
        typeText: '单词',
        count: words.length,
      ));
    }
    if (phrases.isNotEmpty) {
      knowledgePoints.add(FlashSettingKnowledgeTypeItemModel(
        type: ElementsCardType.phrase,
        typeText: '短语',
        count: phrases.length,
      ));
    }
    if (sentences.isNotEmpty) {
      knowledgePoints.add(FlashSettingKnowledgeTypeItemModel(
        type: ElementsCardType.sentence,
        typeText: '句子',
        count: sentences.length,
      ));
    }

    FlashSettingModel? newGraph = await OfficialCourseDetailsFlashSettingDialog.show(
      context: Get.context!,
      showKonwlede: isFirst,
      initSetting: FlashSettingModel(
          knowledgePoints: knowledgePoints,
          selectedKnowledgePoints: selectedKnowledgeTypes.isEmpty
              ? knowledgePoints.map((e) => e.type).toList()
              : knowledgePoints
                  .where((e) => selectedKnowledgeTypes.contains(e.type))
                  .map((e) => e.type)
                  .toList(),
          showType: showType.value,
          interval: playInterval.value,
          playSpeed: playSpeed.value,
          national: national.value,
          textDisplayCode: _currentTextDisplayCode),
    );
    if (newGraph == null) {
      if (isFirst) {
        Get.back();
      }
      return;
    }

    showType.value = newGraph.showType;
    playInterval.value = newGraph.interval;
    playSpeed.value = newGraph.playSpeed;
    national.value = newGraph.national;
    selectedKnowledgeTypes.value = newGraph.selectedKnowledgePoints.toList();
    StorageUtil().setDouble(INTERVAL_SPEED_KEY, playInterval.value);
    Get.find<ConfigController>().setUserSetting(
      expandAudioSpeed: playSpeed.value,
      expandTranslationType: newGraph.textDisplayCode,
    );
    knowledgeList.value = knowledgeListArgs!.toList();
    knowledgeList.removeWhere((element) => !newGraph.selectedKnowledgePoints.contains(element.cardType));
    currentIndex.value = 0;
    cardIsFront.value = true;
    if (knowledgeList.isEmpty) {
      return;
    }
    await _startLearnUploadIfNeeded();
    _markCurrentContentViewed();
    setAudioDuration().then((_) {
      isReady.value = true;
      restartAutoNextTimer();
    });
  }

  Future<void> setAudioDuration() async {
    // 优先使用当前卡片的发音音频 URL 计算时长
    final current = knowledgeList[currentIndex.value];
    String? audioUrl;
    if (current.pronunciations != null && current.pronunciations!.isNotEmpty) {
      audioUrl = current.pronunciations!.first?.audioUrl;
    }
    audioUrl ??= current.audioUrl;

    int duration = 0;
    duration = current.pronunciations!.first!.duration!.toInt() * 1000;

    int delayMs;
    if (duration == 0) {
      delayMs = (playInterval.value * 1000).toInt();
    } else {
      delayMs = (duration * playInterval.value).toInt();
    }
    audioDuration.value = delayMs;
  }

  /// 上一张卡片
  Future<void> previousCard() async {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      pageController.animateToPage(currentIndex.value, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      ToastUtils.showToast(text: '当前已是第一个');
      update();
      return;
    }
    cardIsFront.value = true;
  }

  /// 下一张卡片
  Future<void> nextCard() async {
    if (currentIndex.value < knowledgeList.length - 1) {
      currentIndex.value++;
      pageController.animateToPage(currentIndex.value, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      isAutoPlay.value = false; 
      ToastUtils.showToast(text: '当前已是最后一个');
      update();
      return;
    }
    cardIsFront.value = true;
  }

  /// 改变下标
  void changeIndex(int index) {
    currentIndex.value = index;
    cardIsFront.value = true;
    _markCurrentContentViewed();
    setAudioDuration().then((_) {
      restartAutoNextTimer();
    });
  }

  /// 已掌握
  void masteredClick() {
    UnitKnowledgePointsEntityKnowledgeList knowledge = knowledgeList[currentIndex.value];
    if (knowledge.contentId != null) {
      if (improvedKnowledgeIds.contains(knowledge.contentId!)) {
        improvedKnowledgeIds.remove(knowledge.contentId!);
      }
      if (!masteredKnowledgeIds.contains(knowledge.contentId!)) {
        masteredKnowledgeIds.add(knowledge.contentId!);
      }
    }

    nextCard();
  }

  /// 待加强
  void improvedClick() {
    UnitKnowledgePointsEntityKnowledgeList knowledge = knowledgeList[currentIndex.value];
    if (knowledge.contentId != null) {
      if (masteredKnowledgeIds.contains(knowledge.contentId!)) {
        masteredKnowledgeIds.remove(knowledge.contentId!);
      }
      if (!improvedKnowledgeIds.contains(knowledge.contentId!)) {
        improvedKnowledgeIds.add(knowledge.contentId!);
      }
    }

    nextCard();
  }

  /// 键盘事件处理
  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (knowledgeList.isEmpty) return true;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        previousCard();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        nextCard();
        return true;
      }
    }
    return true;
  }

    /// 修改播放速度
  void changePlaySpeed(double speed) async {
    playSpeed.value = speed;
    
    ConfigController configController = Get.find<ConfigController>();
    configController.setUserSetting(expandAudioSpeed: speed);
  }

  void revealAnswer() {
    cardIsFront.value = false;
    restartAutoNextTimer();
  }

  void coverAnswer() {
    cardIsFront.value = true;
    restartAutoNextTimer();
  }

  Future<void> openCurrentKnowledgeDetail() async {
    if (knowledgeList.isEmpty) return;
    final currentKnowledge = knowledgeList[currentIndex.value];
    await ElementsPageUtils.jumpElementsPage(
      contentId: currentKnowledge.contentId,
      contentType: currentKnowledge.contentType,
      semanticId: currentKnowledge.semanticId,
      styleId: currentKnowledge.styleId,
      dialect: currentKnowledge.dialect,
      semanticIds: currentKnowledge.semanticId == null
          ? null
          : [currentKnowledge.semanticId],
      content: currentKnowledge.content,
      pos: currentKnowledge.posTitle,
    );
  }

  String get currentPronunciationLabel => national.value.text;

  String get currentTextDisplayLabel {
    final String code = _currentTextDisplayCode;
    if (code == _originalCode) return '原文语言';
    if (code == _translationCode) return '译文语言';
    if (code == _noneCode) return '隐藏文本';
    return '双语对照';
  }

  String get currentIntervalLabel {
    final List<UserPreferenceIntervalSpeedOption> menu =
        Get.find<ConfigController>().userSetting.value.intervalMenu ?? [];
    for (final item in menu) {
      if (item.value == playInterval.value) {
        return '节奏${item.title ?? playInterval.value}';
      }
    }
    return '节奏${playInterval.value}';
  }

  String get currentShowTypeLabel => showType.value.value;

  String get currentSpeedLabel => '倍速 ${playSpeed.value.toStringAsFixed(1)}x';

  String get _currentTextDisplayCode {
    final ConfigController configController = Get.find<ConfigController>();
    final String currentCode = configController.userSetting.value.expandLang.code;
    if (currentCode.isNotEmpty) {
      return currentCode;
    }
    final menus = configController.userSetting.value.expandDropdownMenu ?? const [];
    for (final item in menus) {
      final String code = (item.code ?? '').trim();
      if (code.isNotEmpty) {
        return code;
      }
    }
    return _bilingualCode;
  }

  @override
  void onClose() {
    if (enableLearnUpload) {
      unawaited(LearnRecordManager.instance.stopTracking(source: _learnRecordSource));
    }
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    cancelAutoNextTimer();
    super.onClose();
  }

  Future<void> _startLearnUploadIfNeeded() async {
    if (!enableLearnUpload || _hasStartedLearnUpload || knowledgeList.isEmpty) return;
    _hasStartedLearnUpload = true;
    await LearnRecordManager.instance.startTracking(
      source: _learnRecordSource,
      type: learnUploadType,
    );
  }

  void _markCurrentContentViewed() {
    if (!enableLearnUpload || knowledgeList.isEmpty) return;
    unawaited(LearnRecordManager.instance.markContentViewed(knowledgeList[currentIndex.value]));
  }
}
