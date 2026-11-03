import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:lib_common/common.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:video_player/video_player.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../entities/third_party_account_entity.dart';
import '../enum/enum.dart';
import '../https/https.dart';
import '../values/values.dart';
import 'model/user_setting_model.dart';

class ConfigController extends GetxController {
  final Map<String, String> langMap = {
    "en": "英语",
    "zh": "中文简体",
  };

  /// 配置数据
  final Rx<ConfigEntity> appConfig = ConfigEntity().obs;

  final RxList<QuizLettersModel> quizLetters = <QuizLettersModel>[].obs;

  final Rx<LanguageConfigColorEntity> colorConfigs = LanguageConfigColorEntity().obs;

  /// 练习题学习状态说明配置
  final Rx<ExerciseLearnScoreConfigEntity> exerciseLearnScoreConfigs =
      ExerciseLearnScoreConfigEntity().obs;

  /// 第三方账号
  final Rx<ThirdPartyAccountEntity> thirdPartyAccount = ThirdPartyAccountEntity().obs;

  /// * 显示语言的全局设置
  /// * "en"=学习语言，"zh=本土语言，""=双语
  /// * 在单词和短语卡片列表 不能选双语  在句子卡片列表不能选本地语言  在句子详情不能选本地语言
  // final RxString learningLangShowSetting = "".obs;

  /// * 用户的设置 仅本次启动有效
  final Rx<UserSettingModel> userSetting = UserSettingModel().obs;


  // ================== 视觉风格设置 =========================
  
  /// 当前显示的资源 当前是存在设备本地
  final Rx<ResourceTypeEnum> currentShowResource = ResourceTypeEnum.image.obs;

  /// 当前显示的风格code 当前是存在设备本地
  final RxString currentShowStyleCode = "".obs;

  /// 风格原始数据
  final Rx<TeamStyleEntity> originalStyleData = TeamStyleEntity().obs;

  /// 所有风格列表
  final RxList<TeamStyleEntityStyleItems> allStyleList = <TeamStyleEntityStyleItems>[].obs;

  /// 已经有权益的图片列表
  final RxList<TeamStyleEntityStyleItems> allStyleImageList = <TeamStyleEntityStyleItems>[].obs;
  /// 已经有权益的视频列表
  final RxList<TeamStyleEntityStyleItems> allStyleVideoList = <TeamStyleEntityStyleItems>[].obs;

    // ================== 视觉风格设置 =========================

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> initConfig() async {
    try {

      log('[ConfigController] initConfig enter');
      log('[ConfigController] getConfig before');
      await getConfig();
      log('[ConfigController] getConfig after');
      log('[ConfigController] getColorConfig before');
      await getColorConfig();
      log('[ConfigController] getColorConfig after');
      log('[ConfigController] getExerciseLearnScoreConfigs before');
      await getExerciseLearnScoreConfigs();
      log('[ConfigController] getExerciseLearnScoreConfigs after');
      if (!LockUtils.checkExperienceAppStorage()) {
        log('[ConfigController] getThirdPartyAccount before');
        getThirdPartyAccount();
        log('[ConfigController] getThirdPartyAccount triggered');
        log('[ConfigController] UserStore.getUserInfo before');
        final bool hasUserInfo = await UserStore.to.getUserInfo(isInit:true);
        log('[ConfigController] UserStore.getUserInfo after hasUserInfo:$hasUserInfo');
        if (hasUserInfo) {
          unawaited(NativeErrorBridge.consumePendingErrors());
          log('[ConfigController] NativeErrorBridge.consumePendingErrors triggered');
        }
        log('[ConfigController] initUserConfig before');
        initUserConfig();
        getUserStyleList().then((_){
          initUserStyleList();
        });
        log('[ConfigController] initUserConfig triggered');
        log('[ConfigController] getUserRolePermissions before');
        await UserStore.to.getUserRolePermissions();
        log('[ConfigController] getUserRolePermissions after');
      }
    } catch (e) {
      log('[ConfigController] initConfig catch:$e');
      ErrorLogUtils.to.logError(e.toString(), StackTrace.current);
    }
  }

  Future<void> getConfig() async {
    ConfigEntity? configData = await ConfigRequest.getConfig();
    if (configData == null) return;
    appConfig.value = configData;
    CacheManagerUtils.instance.cacheLetterAssets(configData.letters).then((value) {
      if (value != null) {
        quizLetters.value = value;
      }
    });
  }

  /// 获取难度列表
  Future<List<ConfigEntityDifficulties>?> getDifficultieList() async {
    if (appConfig.value.difficulties == null) {
      ConfigEntity? configData = await ConfigRequest.getConfig();
      if (configData == null) return null;
      appConfig.value = configData;
    }
    List<ConfigEntityDifficulties?> difficulties = appConfig.value.difficulties ?? [];
    List<ConfigEntityDifficulties> respDifficulties = [];
    for (int i = 0; i < difficulties.length; i++) {
      if (difficulties[i] == null) continue;
      respDifficulties.add(difficulties[i]!);
    }
    return respDifficulties;
  }

  /// 获取颜色配置
  Future<void> getColorConfig() async {
    LanguageConfigColorEntity? colorConfigData = await ConfigRequest.getCardColorConfig();
    if (colorConfigData == null) return;
    colorConfigs.value = colorConfigData;
  }

  /// 获取练习题学习状态说明配置
  Future<void> getExerciseLearnScoreConfigs() async {
    final data = await ConfigRequest.getExerciseLearnScoreConfigs();
    if (data == null) return;
    exerciseLearnScoreConfigs.value = data;
  }

  /// 获取用户配置设置
  Future<UserPreferenceOptionEntity?> getUserConfig() async {
    UserPreferenceOptionEntity? option = await UserRequest.getUserPreferenceOption();
    if (option == null) return null;
    return option;
  }

  /// 获取用户配置设置
  Future<void> initUserConfig() async {
    UserInfoEntity userInfo = UserStore.to.userInfo.value;
    userSetting.value.courseLang = LangPreference.fromRawValue(userInfo.config?.exerciseConfig!.translationType ?? '');
    userSetting.value.courseAudioSpeed = userInfo.config?.exerciseConfig!.playSpeed ?? 1.0;

    userSetting.value.expandLang = LangPreference.fromRawValue(userInfo.config?.extensionConfig!.translationType ?? '');
    userSetting.value.expandAudioSpeed = userInfo.config?.extensionConfig?.playSpeed ?? 1.0;
    userSetting.value.expandPronunciationCode = userInfo.config?.national ?? LanguageServiceCode.US;

    final AudioControlSettingModel? audioSetting = AudioControlUtils.getSetting();
    final double savedExpandInterval = StorageUtil().getDouble(INTERVAL_SPEED_KEY) ?? userSetting.value.expandInterval;
    userSetting.value.expandInterval = savedExpandInterval;
    userSetting.value.expandPlayOrder = audioSetting?.playOrder?.value ?? userSetting.value.expandPlayOrder;
    userSetting.value.expandPlayOrderLoopCount = audioSetting?.playOrderLoopCount ?? userSetting.value.expandPlayOrderLoopCount;

    UserPreferenceOptionEntity? option = await UserRequest.getUserPreferenceOption();
    if (option == null) return;

    if (option.intervalSpeed!.options != null) {
      userSetting.value.intervalMenu = option.intervalSpeed!.options!;
    }

    List<UserPreferenceDefinitionDisplayModeOption?>? exerciseOptions = option.exercisePreference?.definitionDisplayMode?.options;
    if (exerciseOptions != null) {
      List<UserPreferenceDefinitionDisplayModeOption> courseDropdownMenu = [];
      for (int i = 0; i < exerciseOptions.length; i++) {
        if (exerciseOptions[i] == null) continue;
        courseDropdownMenu.add(exerciseOptions[i]!);
      }
      userSetting.value.courseDropdownMenu = courseDropdownMenu;
    }

    List<double?>? exercisePlaySpeedOptions = option.exercisePreference?.playSpeed?.options;
    if (exercisePlaySpeedOptions != null) {
      userSetting.value.courseAudioSpeedList = exercisePlaySpeedOptions.whereType<double>().toList();
      if(!userSetting.value.courseAudioSpeedList.contains(userSetting.value.courseAudioSpeed)){
        userSetting.value.courseAudioSpeed = 1;
      }
    }

    List<UserPreferenceDefinitionDisplayModeOption?>? extensionOptions = option.extensionPreference?.definitionDisplayMode?.options;
    if (extensionOptions != null) {
      List<UserPreferenceDefinitionDisplayModeOption> expanDropdownMenu = [];
      for (int i = 0; i < extensionOptions.length; i++) {
        if (extensionOptions[i] == null) continue;
        expanDropdownMenu.add(extensionOptions[i]!);
      }
      userSetting.value.expandDropdownMenu = expanDropdownMenu;
    }

    List<double?>? extensionPlaySpeedDefaultOption = option.extensionPreference?.playSpeed?.options;
    if (extensionPlaySpeedDefaultOption != null) {
      userSetting.value.expandAudioSpeedList = extensionPlaySpeedDefaultOption.whereType<double>().toList();
      if(!userSetting.value.expandAudioSpeedList.contains(userSetting.value.expandAudioSpeed)){
        userSetting.value.expandAudioSpeed = 1;
      }
    }

  }

  /// 单独设置用户配置
  void setUserSetting({
    double? courseAudioSpeed,
    double? expandAudioSpeed,
    String? courseTranslationType,
    String? expandTranslationType,
    String? expandPronunciationCode,
    double? expandInterval,
    String? expandPlayOrder,
    int? expandPlayOrderLoopCount,
  }) {
    if (courseAudioSpeed != null) {
      userSetting.value.courseAudioSpeed = courseAudioSpeed;
    }
    if (expandAudioSpeed != null) {
      userSetting.value.expandAudioSpeed = expandAudioSpeed;
    }
    if (courseTranslationType != null) {
      userSetting.value.courseLang = LangPreference.fromRawValue(courseTranslationType);
    }
    if (expandTranslationType != null) {
      userSetting.value.expandLang = LangPreference.fromRawValue(expandTranslationType);
    }
    if (expandPronunciationCode != null) {
      userSetting.value.expandPronunciationCode = expandPronunciationCode;
    }
    if (expandInterval != null) {
      userSetting.value.expandInterval = expandInterval;
    }
    if (expandPlayOrder != null) {
      userSetting.value.expandPlayOrder = expandPlayOrder;
    }
    if (expandPlayOrderLoopCount != null) {
      userSetting.value.expandPlayOrderLoopCount = expandPlayOrderLoopCount;
    }
    userSetting.refresh();
  }

  /// 获取第三方账号
  Future<void> getThirdPartyAccount() async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.secretSupplierApp)) return;
    
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String? encryptedString = await ConfigRequest.getThirdPartyAccount(timestamp);
    if (encryptedString == null) return;
    int? userId = UserStore.to.userInfo.value.userId;
    if (userId == null) return;
    String userIdStr = userId.toString();

    const String timelywise = 'timelywiseMUbh';

    String secretKey = '$userIdStr$timelywise$timestamp';

    try {
      final String decrypted = EasUtils.decryptGCM(encryptedString, secretKey);
      if (decrypted.isEmpty) return;
      final Map<String, dynamic> data = jsonDecode(decrypted);
      thirdPartyAccount.value = ThirdPartyAccountEntity.fromJson(data);
    } catch (e) {
      print('Decryption error: $e');
    }
  }

  /// 根据code[ThirdPartyAccountEnum]获取第三方账号
  Future<ThirdPartyAccountEntityList?> getThirdPartyAccountByCode(String code) async {
    if (thirdPartyAccount.value.list == null) {
      await getThirdPartyAccount();
    }
    List<ThirdPartyAccountEntityList?> list = thirdPartyAccount.value.list ?? [];

    for (int i = 0; i < list.length; i++) {
      if (list[i] == null) continue;
      if (list[i]!.code == code) {
        return list[i];
      }
    }
    return null;
  }

  /// * 改变显示语言的全局设置
  /// * value 设置选项 "en"=学习语言，"zh"=本土语言，""=双语
  /// * 单词和短语卡片列表 不能选双语  在句子卡片列表不能选本地语言  在句子详情不能选本地语言
  void setLearLangSetting(String code, LearModePreference mode) {
    if (mode == LearModePreference.course) {
      userSetting.value.courseLang = LangPreference.fromRawValue(code);
    } else if (mode == LearModePreference.extension) {
      userSetting.value.expandLang = LangPreference.fromRawValue(code);
    }
    userSetting.refresh();
  }

  /// * 获取学习语言
  String getLangStr(String langCode) {
    return langMap[langCode] ?? langCode;
  }


  // ======================== 视觉风格 ==========================

  int get currentMediaMode => currentShowResource.value == ResourceTypeEnum.video ? 1 : 0;

  String get currentStyleForRequest => Uri.encodeComponent(currentShowStyleCode.value);

  Future<void> ensureStyleReady() async {
    if (allStyleList.isNotEmpty && currentShowStyleCode.value.isNotEmpty) {
      return;
    }
    await getUserStyleList();
    initUserStyleList();
    if (currentShowStyleCode.value.isEmpty && allStyleList.isNotEmpty) {
      getLocalStyleCode();
    }
  }

  /// 获取用户视觉风格列表
  Future<void> getUserStyleList() async{
    if(!UserStore.to.isLogin) return;
    try {
      TeamStyleEntity? res = await AccountUtil.getTeamStyle();
      if(res == null) return;
      originalStyleData.value = res;
    } catch (_) {}
  }

  /// 初始化用户视觉风格设置
  void initUserStyleList() {
    List<TeamStyleEntityStyleItems?> styleItems = originalStyleData.value.styleItems??[];
    allStyleList.clear();
    allStyleImageList.clear();
    allStyleVideoList.clear();
    for(int i = 0; i < styleItems.length; i++){
      if(styleItems[i] == null) continue;
      allStyleList.add(styleItems[i]!);
      if(styleItems[i]?.imageStatus == 1){
        allStyleImageList.add(styleItems[i]!);
      }
      if(styleItems[i]?.videoStatus == 1){
        allStyleVideoList.add(styleItems[i]!);
      }
    }
    ResourceTypeEnum resourceType = originalStyleData.value.mediaModeUse == 1 ? ResourceTypeEnum.video : ResourceTypeEnum.image;
    if(allStyleVideoList.isEmpty){
      resourceType = ResourceTypeEnum.image;
    }
    // 设置资源类型
    changeCurrentShowResource(resourceType);
    getLocalStyleCode();
  }


  /// 获取设备本地储存的 风格id
  void getLocalStyleCode(){
    List<TeamStyleEntityStyleItems> list = [];
    if(currentShowResource.value == ResourceTypeEnum.image){
      list = allStyleImageList.toList();
    }else{
      list = allStyleVideoList.toList();
    }
    if(list.isEmpty) return;

    String backendStyleCode = originalStyleData.value.mainStyleUse ?? "";
    if (backendStyleCode.isEmpty) {
      backendStyleCode = originalStyleData.value.imageStyleUses?.firstOrNull ?? "";
    }
    currentShowStyleCode.value = backendStyleCode;

    bool isValidStyle = false;
    for (int i = 0; i < list.length; i++) {
      if (currentShowStyleCode.value == list[i].style) {
        isValidStyle = true;
      }
    }

    if (!isValidStyle) {
      currentShowStyleCode.value = list.first.style ?? "";
    }
    StorageUtil().setString(DEFAULT_STYLE_CODE, currentShowStyleCode.value);
  }


  /// 切换资源列表
  void changeCurrentShowResource(ResourceTypeEnum type){
    if(type == ResourceTypeEnum.video){
      if(allStyleVideoList.isEmpty){
        return ToastUtils.showToast(text: "当前暂无可用视频风格");
      }
    }
    currentShowResource.value = type;
    
  }

  /// 切换风格
  void changeCurrentStyleCode(String style){
    List<TeamStyleEntityStyleItems> list = [];
    if(currentShowResource.value == ResourceTypeEnum.image){
      list = allStyleImageList.toList();
    }else{
      list = allStyleVideoList.toList();
    }
    if(list.isEmpty) return;

    bool isRights = false;
    for(int i = 0; i < list.length; i++){
      if(style == list[i].style){
        isRights = true;
      }
    }

    if(!isRights){
      ToastUtils.showToast(text: "当前风格暂不可用");
      return;
    }

    currentShowStyleCode.value = style;
    StorageUtil().setString(DEFAULT_STYLE_CODE, currentShowStyleCode.value);
  }

  // 获取当前风格的名称
  String getCurrentStyleName(String style){
    for(int i = 0; i < allStyleList.length; i++){
      if(allStyleList[i].style == style){
        LanguageText? text = LearningLangUtils.getLocalLang(allStyleList[i].styleTitle);
        return text?.text??"";
      }
    }
    return "";
  }


  // ======================== 视觉风格 ==========================




}
