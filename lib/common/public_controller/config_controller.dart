import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../entities/third_party_account_entity.dart';
import '../enum/enum.dart';
import '../https/https.dart';
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

  /// 第三方账号
  final Rx<ThirdPartyAccountEntity> thirdPartyAccount = ThirdPartyAccountEntity().obs;

  /// * 显示语言的全局设置
  /// * "en"=学习语言，"zh=本土语言，""=双语
  /// * 在单词和短语卡片列表 不能选双语  在句子卡片列表不能选本地语言  在句子详情不能选本地语言
  // final RxString learningLangShowSetting = "".obs;

  /// * 用户的设置 仅本次启动有效
  final Rx<UserSettingModel> userSetting = UserSettingModel().obs;

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
      if (!LockUtils.checkExperienceAppStorage()) {
        log('[ConfigController] getThirdPartyAccount before');
        getThirdPartyAccount();
        log('[ConfigController] getThirdPartyAccount triggered');
        log('[ConfigController] UserStore.getUserInfo before');
        await UserStore.to.getUserInfo(isInit:true);
        log('[ConfigController] UserStore.getUserInfo after');
        log('[ConfigController] getUserConfig before');
        getUserConfig();
        log('[ConfigController] getUserConfig triggered');
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

  /// 获取用户配置设置
  Future<UserPreferenceOptionEntity?> getUserConfig() async {
    UserInfoEntity userInfo = UserStore.to.userInfo.value;
    userSetting.value.courseLang = LangPreference.fromRawValue(userInfo.config?.exerciseConfig!.translationType ?? '');
    userSetting.value.courseAudioSpeed = userInfo.config?.exerciseConfig!.playSpeed ?? 1.0;

    userSetting.value.expandLang = LangPreference.fromRawValue(userInfo.config?.extensionConfig!.translationType ?? '');
    userSetting.value.expandAudioSpeed = userInfo.config?.extensionConfig?.playSpeed ?? 1.0;

    UserPreferenceOptionEntity? option = await UserRequest.getUserPreferenceOption();
    if (option == null) return null;

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
    }

    return option;
  }

  /// 单独设置用户配置
  void setUserSetting({
    double? courseAudioSpeed,
    double? expandAudioSpeed,
    String? courseTranslationType,
    String? expandTranslationType,
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
    userSetting.refresh();
  }

  /// 获取第三方账号
  Future<void> getThirdPartyAccount() async {
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
}
