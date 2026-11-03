import 'package:flutter/material.dart';
import 'package:themed/themed.dart';

import '../common/entities/entities.dart';
import '../common/enum/enum.dart';
import '../common/values/values.dart';
import '../theme/theme.dart';
import '../theme/theme_utils.dart';

/// 状态颜色工具
class StatusUtils {
  /// 获取考核方向标签背景颜色
  static Color getDirectionBackgroundColor(String? direction) {
    if (direction == null || direction.isEmpty) {
      return AppTheme.cDirectionCoreLesson;
    }
    if (direction == "CORE_LESSON") {
      return AppTheme.cDirectionCoreLesson;
    } else if (direction == "PRONUNCIATION") {
      return AppTheme.cDirectionPronunciation;
    } else if (direction == "VOCABULARY") {
      return AppTheme.cDirectionVocabulary;
    } else if (direction == "GRAMMAR") {
      return AppTheme.cDirectionGrammar;
    } else if (direction == "READING") {
      return AppTheme.cDirectionReading;
    } else if (direction == "LISTENING") {
      return AppTheme.cDirectionListening;
    } else if (direction == "SPEAKING") {
      return AppTheme.cDirectionSpeaking;
    } else if (direction == "ASSESSMENT") {
      return AppTheme.cDirectionAssessment;
    }
    return const Color(0xffffffff);
  }

  /// 获取难度等级标签背景颜色
  static DifficultyColor getDifficultyBackgroundColor(int? difficulty) {
    if (difficulty == null) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor0,
        color2: AppTheme.cDifficultyBackgroundColor00,
      );
    }
    if (difficulty == 0) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor0,
        color2: AppTheme.cDifficultyBackgroundColor00,
      );
    } else if (difficulty == 1) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor1,
        color2: AppTheme.cDifficultyBackgroundColor11,
      );
    } else if (difficulty == 2) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor2,
        color2: AppTheme.cDifficultyBackgroundColor22,
      );
    } else if (difficulty == 3) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor3,
        color2: AppTheme.cDifficultyBackgroundColor33,
      );
    } else if (difficulty == 4) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor4,
        color2: AppTheme.cDifficultyBackgroundColor44,
      );
    } else if (difficulty == 5) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor5,
        color2: AppTheme.cDifficultyBackgroundColor55,
      );
    } else if (difficulty == 6) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor6,
        color2: AppTheme.cDifficultyBackgroundColor66,
      );
    }
    return DifficultyColor(
      color1: AppTheme.cDifficultyBackgroundColor0,
      color2: AppTheme.cDifficultyBackgroundColor00,
    );
  }

  /// 获取cefr标签背景颜色
  static DifficultyColor getCefrBackgroundColor(String? cefr) {
    if (cefr == null) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor0,
        color2: AppTheme.cDifficultyBackgroundColor00,
      );
    }
    if (cefr == CefrEnum.preA1) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor0,
        color2: AppTheme.cDifficultyBackgroundColor00,
      );
    } else if (cefr == CefrEnum.a1) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor1,
        color2: AppTheme.cDifficultyBackgroundColor11,
      );
    } else if (cefr == CefrEnum.a2) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor2,
        color2: AppTheme.cDifficultyBackgroundColor22,
      );
    } else if (cefr == CefrEnum.b1) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor3,
        color2: AppTheme.cDifficultyBackgroundColor33,
      );
    } else if (cefr == CefrEnum.b2) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor4,
        color2: AppTheme.cDifficultyBackgroundColor44,
      );
    } else if (cefr == CefrEnum.c1) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor5,
        color2: AppTheme.cDifficultyBackgroundColor55,
      );
    } else if (cefr == CefrEnum.c2) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor6,
        color2: AppTheme.cDifficultyBackgroundColor66,
      );
    }
    return DifficultyColor(
      color1: AppTheme.cDifficultyBackgroundColor0,
      color2: AppTheme.cDifficultyBackgroundColor00,
    );
  }

  /// 获取level标签背景颜色
  static DifficultyColor getLevelBackgroundColor(int? level) {
    if (level == null) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor0,
        color2: AppTheme.cDifficultyBackgroundColor00,
      );
    }
    if (level == 0 || level == 1 || level == 2 || level == 3) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor0,
        color2: AppTheme.cDifficultyBackgroundColor00,
      );
    } else if (level == 4 || level == 5 || level == 6) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor1,
        color2: AppTheme.cDifficultyBackgroundColor11,
      );
    } else if (level == 7 || level == 8 || level == 9) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor2,
        color2: AppTheme.cDifficultyBackgroundColor22,
      );
    } else if (level == 10 || level == 11 || level == 12) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor3,
        color2: AppTheme.cDifficultyBackgroundColor33,
      );
    } else if (level == 13 || level == 14 || level == 15) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor4,
        color2: AppTheme.cDifficultyBackgroundColor44,
      );
    } else if (level == 16 || level == 17 || level == 18) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor5,
        color2: AppTheme.cDifficultyBackgroundColor55,
      );
    } else if (level == 19 || level == 20 || level == 21) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor6,
        color2: AppTheme.cDifficultyBackgroundColor66,
      );
    }
    return DifficultyColor(
      color1: AppTheme.cDifficultyBackgroundColor0,
      color2: AppTheme.cDifficultyBackgroundColor00,
    );
  }

  /// 获取难度等级标签背景颜色
  static DifficultyColor getDifficultyColorFromCefr(String? cefrEnum) {
    if (cefrEnum == null) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor0,
        color2: AppTheme.cDifficultyBackgroundColor00,
      );
    }
    cefrEnum = cefrEnum.toLowerCase();
    if (cefrEnum == CefrEnum.preA1.toLowerCase()) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor0,
        color2: AppTheme.cDifficultyBackgroundColor00,
      );
    } else if (cefrEnum == CefrEnum.a1.toLowerCase()) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor1,
        color2: AppTheme.cDifficultyBackgroundColor11,
      );
    } else if (cefrEnum == CefrEnum.a2.toLowerCase()) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor2,
        color2: AppTheme.cDifficultyBackgroundColor22,
      );
    } else if (cefrEnum == CefrEnum.b1.toLowerCase()) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor3,
        color2: AppTheme.cDifficultyBackgroundColor33,
      );
    } else if (cefrEnum == CefrEnum.b2.toLowerCase()) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor4,
        color2: AppTheme.cDifficultyBackgroundColor44,
      );
    } else if (cefrEnum == CefrEnum.c1.toLowerCase()) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor5,
        color2: AppTheme.cDifficultyBackgroundColor55,
      );
    } else if (cefrEnum == CefrEnum.c2.toLowerCase()) {
      return DifficultyColor(
        color1: AppTheme.cDifficultyBackgroundColor6,
        color2: AppTheme.cDifficultyBackgroundColor66,
      );
    }
    return DifficultyColor(
      color1: AppTheme.cDifficultyBackgroundColor0,
      color2: AppTheme.cDifficultyBackgroundColor00,
    );
  }

  /// 获取会员等级颜色
  static MemberColorsModel getMemberColors(String member) {
    if (member == "Free") {
      return MemberColorsModel(
        color1: AppTheme.cUserFreeMember1.color,
        color2: AppTheme.cUserFreeMember2.color,
      );
    } else if (member == "Plus") {
      return MemberColorsModel(
        color1: AppTheme.cUserPlusMember1.color,
        color2: AppTheme.cUserPlusMember2.color,
      );
    } else if (member == "Pro") {
      return MemberColorsModel(
        color1: AppTheme.cUserProMember1.color,
        color2: AppTheme.cUserProMember2.color,
      );
    } else if (member == "Max") {
      return MemberColorsModel(
        color1: AppTheme.cUserMaxMember1.color,
        color2: AppTheme.cUserMaxMember2.color,
      );
    }
    return MemberColorsModel(
      color1: AppTheme.cUserFreeMember1.color,
      color2: AppTheme.cUserFreeMember2.color,
    );
  }

  /// 获取奖励的颜色
  static Color getRewardColor(ReferralAwardTypeEnum? type){
    if(type == ReferralAwardTypeEnum.POINTS){
      return AppTheme.cLearnSomethingPrimary.color;
    }else if(type == ReferralAwardTypeEnum.CREDIT){
      return AppTheme.cNsCoinBgPrimary.color;
    }else if(type == ReferralAwardTypeEnum.PLUS_VIP){
      return AppTheme.cUserPlusMember1.color;
    }else if(type == ReferralAwardTypeEnum.PRO_VIP){
      return AppTheme.cUserProMember1.color;
    }else if(type == ReferralAwardTypeEnum.MAX_VIP){
      return AppTheme.cUserMaxMember1.color;
    }else if(type == ReferralAwardTypeEnum.CREDIT){
      return const Color(0xffC4B5FD);
    } else if(type == ReferralAwardTypeEnum.COUPON){
      return AppTheme.cSurfaceBrand.color;
    }
    return AppTheme.cSurfaceBrand.color;
  }


  /// 获取奖励状态颜色
  static Color getRewardStatusColor(ReferralAwardStatusEnum status){
    if(status == ReferralAwardStatusEnum.CLAIMABLE){
      return AppTheme.cSurfaceWarning.color;
    }else if(status == ReferralAwardStatusEnum.PENDING){
      return AppTheme.cSurfaceInfo.color;
    }else if(status == ReferralAwardStatusEnum.CLAIMED){
      return AppTheme.cSurfaceSuccess.color;
    }
    return AppTheme.cTextPrimary.color;
  }



  static MemberLevelColor getMemberColorsByVipConfigs(List<UserInfoEntityVipConfigs?>? vipConfigs, String? member) {
    Color deep = Colors.transparent;
    Color pale = Colors.transparent;
    if (vipConfigs != null) {
      for (var vipConfig in vipConfigs) {
        if (vipConfig == null) continue;
        if (vipConfig.vipType == null) continue;
        if (vipConfig.color == null) continue;
        if (vipConfig.color?.deep == null) continue;
        if (vipConfig.color?.pale == null) continue;

        if (vipConfig.vipType?.toLowerCase() == member?.toLowerCase()) {
          int? deepInt = int.tryParse(vipConfig.color!.deep!);
          int? paleInt = int.tryParse(vipConfig.color!.pale!);
          if (deepInt != null) {
            deep = Color(deepInt);
          }
          if (paleInt != null) {
            pale = Color(paleInt);
          }
          break;
        }
      }
    }
    return MemberLevelColor(
      deep: deep,
      pale: pale,
    );
  }

  static ElementsCardColor? getElementsCardColor(String? type) {
    if (type == ElementsCardType.word.value) {
      return ElementsCardColor(
        color1: AppTheme.cWordCardColor1.color,
        color2: AppTheme.cWordCardColor2.color,
      );
    } else if (type == ElementsCardType.phrase.value) {
      return ElementsCardColor(
        color1: AppTheme.cPhraseCardColor1.color,
        color2: AppTheme.cPhraseCardColor2.color,
      );
    } else if (type == ElementsCardType.sentence.value) {
      return ElementsCardColor(
        color1: AppTheme.cSentenceCardColor1.color,
        color2: AppTheme.cSentenceCardColor2.color,
      );
    } else if (type == ElementsCardType.morpheme.value) {
      return ElementsCardColor(
        color1: AppTheme.cMorphemeCardColor1.color,
        color2: AppTheme.cMorphemeCardColor2.color,
      );
    } else if (type == ElementsCardType.text.value) {
      return ElementsCardColor(
        color1: AppTheme.cTextCardColor1.color,
        color2: AppTheme.cTextCardColor1.color,
      );
    } else if (type == ElementsCardType.song.value) {
      return ElementsCardColor(
        color1: AppTheme.cSongCardColor1.color,
        color2: AppTheme.cSongCardColor1.color,
      );
    }
    return null;
  }


  /// 获取词素标签颜色
  static Color getMorphemeTagColor(String? type) {
    type = type?.toUpperCase();
    if (type == "PREFIX") {
      return AppTheme.cMorphemeTagPrefix;
    } else if (type == "ROOT") {
      return AppTheme.cMorphemeTagRoot;
    } else if (type == "SUFFIX") {
      return AppTheme.cMorphemeTagSuffix;
    } else if (type == "INFIX") {
      return AppTheme.cMorphemeTagInfix;
    } else if (type == "COMBINING_FORM") {
      return AppTheme.cMorphemeTagCombiningForm;
    } else if (type == "INTERFIX") {
      return AppTheme.cMorphemeTagInterfix;
    }
    return AppTheme.cMorphemeTagPrefix;
  }

  /// 获取卡券的颜色
  static Color getCouponColor(String? type) {
    type = type?.toUpperCase();
    if (type == "DISCOUNT") {
      return Color(0xffFF1C1C);
    } else if (type == "VIP") {
      return AppTheme.cMemberPrimary.color;
    } else if (type == "CREDIT") {
      return AppTheme.cLearnSomethingPrimary.color;
    } else if (type == "STYLE") {
      return AppTheme.cImageStylePrimary.color;
    } else if (type == "EXCHANGE") {
      return AppTheme.cBgBrand.color;
    }
    return AppTheme.cBgBrand.color;
  }

  /// 根据code 获取对应颜色
  static LanguageConfigColorModel? getConfigColor(List<LanguageConfigColorEntityInfo?>? configs, String? code) {
    if (configs == null || code == null) return null;
    final punctuationRegex = RegExp(r'[。.！!?？；;：:，,]');
    if (punctuationRegex.hasMatch(code)) {
      code = "SYM";
    }

    for (var config in configs) {
      if (config?.code?.toUpperCase() == code.toUpperCase()) {
        final LanguageConfigColorEntityThemeColors? themeColors = resolveThemeColors(config);
        return LanguageConfigColorModel(
          code: config?.code,
          abbr: config?.abbr,
          title: config?.title,
          color: LanguageConfigColorModelColors(
            bgColor: themeColors?.backgroundColorC ?? AppTheme.cBgBrand.addOpacity(0.1),
            textColor: themeColors?.textColorC ?? AppTheme.cBgBrand,
            borderColor: themeColors?.borderColorC ?? AppTheme.cBgBrand,
          ),
        );
      }
    }
    return null;
  }

  /// 解析当前主题生效的颜色项：优先 colors 数组按 theme 匹配，fallback 旧 color 结构
  static LanguageConfigColorEntityThemeColors? resolveThemeColors(LanguageConfigColorEntityInfo? info) {
    if (info == null) return null;
    final List<LanguageConfigColorEntityThemeColors?> themeList = info.colors ?? const <LanguageConfigColorEntityThemeColors?>[];
    if (themeList.isNotEmpty) {
      final String themeKey = ThemeUtils.isCurrentTheme(AppThemeKey.light.value)
          ? AppThemeKey.light.value
          : AppThemeKey.dark.value;
      LanguageConfigColorEntityThemeColors? first;
      for (final LanguageConfigColorEntityThemeColors? item in themeList) {
        if (item == null) continue;
        first ??= item;
        if ((item.theme ?? '').toUpperCase() == themeKey) return item;
      }
      return first;
    }
    final LanguageConfigColorEntityColors? old = info.color;
    if (old == null) return null;
    return LanguageConfigColorEntityThemeColors(
      color: old.textColor,
      textColor: old.textColor,
      backgroundColor: old.bgColor,
      borderColor: old.borderColor,
    );
  }

  static LanguageConfigColorModel? getConfigColorForAbbr(List<LanguageConfigColorEntityInfo?>? configs, String? abbr) {
    if (configs == null || abbr == null) return null;
    for (var config in configs) {
      if (config?.abbr?.toUpperCase() == abbr.toUpperCase()) {
        final LanguageConfigColorEntityThemeColors? themeColors = resolveThemeColors(config);
        return LanguageConfigColorModel(
          code: config?.code,
          abbr: config?.abbr,
          title: config?.title,
          color: LanguageConfigColorModelColors(
            bgColor: themeColors?.backgroundColorC ?? AppTheme.cBgBrand.addOpacity(0.1),
            textColor: themeColors?.textColorC ?? AppTheme.cBgBrand,
            borderColor: themeColors?.borderColorC ?? AppTheme.cBgBrand,
          ),
        );
      }
    }
    return null;
  }

  /// 获取学练测记的颜色
  static LearnTypeColors getLearnTypeColor(String learningTypeEnum, {String? result, bool isCurrent = false}) {
    /// 优良中差
    Color statusBgColor = AppTheme.cQuizDefaultBackground.color;
    Color statusBorderColor = AppTheme.cQuizDefaultBorder.color;

    if (result == QuizReportReslutEnum.excellent) {
      statusBgColor = AppTheme.cQuizExcellentBackground.color;
      statusBorderColor = AppTheme.cQuizExcellentBorder.color;
    } else if (result == QuizReportReslutEnum.good) {
      statusBgColor = AppTheme.cQuizGoodBackground.color;
      statusBorderColor = AppTheme.cQuizGoodBorder.color;
    } else if (result == QuizReportReslutEnum.pass) {
      statusBgColor = AppTheme.cQuizPassBackground.color;
      statusBorderColor = AppTheme.cQuizPassBorder.color;
    } else if (result == QuizReportReslutEnum.poor) {
      statusBgColor = AppTheme.cQuizPoorBackground.color;
      statusBorderColor = AppTheme.cQuizPoorBorder.color;
    }

    Color learnTypeColor = Colors.transparent;
    if (learningTypeEnum == LearningTypeEnum.LEARN) {
      learnTypeColor = AppTheme.cLearnPrimary.color;
    } else if (learningTypeEnum == LearningTypeEnum.PRACTICE) {
      learnTypeColor = AppTheme.cPracticePrimary.color;
    } else if (learningTypeEnum == LearningTypeEnum.TEST) {
      learnTypeColor = AppTheme.cTestPrimary.color;
    } else if (learningTypeEnum == LearningTypeEnum.MEMORY) {
      learnTypeColor = AppTheme.cMemoryPrimary.color;
    } else if (learningTypeEnum == LearningTypeEnum.EXAM) {
      learnTypeColor = AppTheme.cExamPrimary.color;
    }

    if (isCurrent || result != null) {
      return LearnTypeColors(
        shadowTypeColor: learnTypeColor,
        statusBgColor: statusBgColor,
        statusBorderColor: statusBorderColor,
      );
    }

    return LearnTypeColors(
      shadowTypeColor: Colors.transparent,
      statusBgColor: statusBgColor,
      statusBorderColor: statusBorderColor,
    );
  }

  /// 获取听说读写颜色
  static LSRWStatusColor getLSRWStatusColor(String type) {
    if (type == LSRWEnum.listening) {
      return LSRWStatusColor(
        primary: AppTheme.cListenPrimary.color,
        bg1: AppTheme.cListenBg1.color,
        bg2: AppTheme.cListenBg2.color,
        svg: "assets/svg/public/icon_listen.svg",
      );
    } else if (type == LSRWEnum.speaking) {
      return LSRWStatusColor(
        primary: AppTheme.cSayPrimary.color,
        bg1: AppTheme.cSayBg1.color,
        bg2: AppTheme.cSayBg2.color,
        svg: "assets/svg/public/icon_speak.svg",
      );
    } else if (type == LSRWEnum.reading) {
      return LSRWStatusColor(
        primary: AppTheme.cReadPrimary.color,
        bg1: AppTheme.cReadBg1.color,
        bg2: AppTheme.cReadBg2.color,
        svg: "assets/svg/public/icon_read.svg",
      );
    } else if (type == LSRWEnum.writing) {
      return LSRWStatusColor(
        primary: AppTheme.cWritePrimary.color,
        bg1: AppTheme.cWriteBg1.color,
        bg2: AppTheme.cWriteBg2.color,
        svg: "assets/svg/public/icon_write.svg",
      );
    }
    return LSRWStatusColor(
      primary: AppTheme.cBgBrand.color,
      bg1: AppTheme.cFeedbackInfoBackground.color,
      bg2: AppTheme.cFeedbackInfoBackground.color,
      svg: "assets/svg/public/icon_upapp_rocket.svg",
    );
  }

  /// 获取学习区域颜色
  static Color? getStudyZoneColor(String? studyZoneEnum) {
    if (studyZoneEnum == StudyZoneEnum.comfort) {
      return AppTheme.cFeedbackSuccessText.color;
    } else if (studyZoneEnum == StudyZoneEnum.study) {
      return AppTheme.cFeedbackWarningText.color;
    } else if (studyZoneEnum == StudyZoneEnum.panic) {
      return AppTheme.cFeedbackErrorText.color;
    }
    return null;
  }
}

class LearnTypeColors {
  /// 学练测记考
  Color shadowTypeColor;

  /// 优良中差
  Color statusBgColor;

  /// 优良中差
  Color statusBorderColor;

  LearnTypeColors({
    required this.shadowTypeColor,
    required this.statusBgColor,
    required this.statusBorderColor,
  });
}

class LSRWStatusColor {
  Color primary;
  Color bg1;
  Color bg2;
  String svg;
  LSRWStatusColor({
    required this.primary,
    required this.bg1,
    required this.bg2,
    required this.svg,
  });
}

class LanguageConfigColorModel {
  String? code;
  String? abbr;
  String? title;
  LanguageConfigColorModelColors? color;

  LanguageConfigColorModel({
    this.code,
    this.abbr,
    this.title,
    this.color,
  });
}

class LanguageConfigColorModelColors {
  Color bgColor;
  Color textColor;
  Color borderColor;

  LanguageConfigColorModelColors({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });
}

class ElementsCardColor {
  final Color color1;
  final Color color2;

  ElementsCardColor({
    required this.color1,
    required this.color2,
  });
}

class MemberLevelColor {
  Color deep;
  Color pale;
  MemberLevelColor({
    required this.deep,
    required this.pale,
  });
}

class MemberColorsModel {
  Color color1;
  Color color2;

  MemberColorsModel({
    required this.color1,
    required this.color2,
  });
}

class BgBorderColor {
  Color bgColor;
  Color borderColor;
  BgBorderColor({
    required this.bgColor,
    required this.borderColor,
  });
}

class DifficultyColor {
  Color color1;
  Color color2;
  DifficultyColor({
    required this.color1,
    required this.color2,
  });
}
