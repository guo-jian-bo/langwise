import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:themed/themed.dart';

Map<ThemeRef, Object> darkTheme = {
  // ----------- 背景颜色 ---------------
  AppTheme.cBgPrimary: const Color(0xFF000000),
  AppTheme.cBgSecondary: const Color(0xFF1D2021),
  AppTheme.cBgTertiary: const Color(0xFF26292A),
  AppTheme.cBgQuaternary: const Color(0xFF303335),
  AppTheme.cBgBrand: const Color(0xFF38BDF8),
  AppTheme.cBgHover: const Color(0xFF2C2D2F),
  AppTheme.cBgActive: const Color(0xFF26292A),
  AppTheme.cBgDisabled: const Color(0xFF1D2021),
  AppTheme.cBgSolid: Colors.black,

  // ----------- 文字颜色 ---------------
  AppTheme.cTextPrimary: const Color(0xFFFFFFFF),
  AppTheme.cTextSecondary: const Color(0xFFE8EDF4),
  AppTheme.cTextTertiary: const Color(0xFFACB5BC),
  AppTheme.cTextQuaternary: const Color(0xFF5B6167),
  AppTheme.cTextDisabled: const Color(0xFF46494C),
  AppTheme.cTextInverse: const Color(0xFF131617),
  AppTheme.cTextBrand: const Color(0xFF38BDF8),
  AppTheme.cTextLink: const Color(0xFF60A5FA),
  AppTheme.cTextLinkHover: const Color(0xFF93C5FD),

  // -------------- 边框颜色 ---------------
  AppTheme.cBorderPrimary: const Color(0xFF303335),
  AppTheme.cBorderSecondary: const Color(0xFF46494C),
  AppTheme.cBorderTertiary: const Color(0xFF5B6167),
  AppTheme.cBorderQuaternary: const Color(0xFFD0D7DF),
  AppTheme.cBorderBrand: const Color(0xFF38BDF8),
  AppTheme.cBorderFocus: const Color(0xFF7DD3FC),
  AppTheme.cBorderDisabled: const Color(0xFF303335),

  // --------------- 表面色 ---------------
  AppTheme.cSurfacePrimary: const Color(0xFF1D2021),
  AppTheme.cSurfaceSecondary: const Color(0xFF26292A),
  AppTheme.cSurfaceTertiary: const Color(0xFF303335),
  AppTheme.cSurfaceQuaternary: const Color(0xFF46494C),
  AppTheme.cSurfaceQuinary: const Color(0xFF5B6167),
  AppTheme.cSurfaceBrand: const Color(0xFF38BDF8),
  AppTheme.cSurfaceSuccess: const Color(0xFF00D492),
  AppTheme.cSurfaceWarning: const Color(0xFFFB923C),
  AppTheme.cSurfaceError: const Color(0xFFF43F5E),
  AppTheme.cSurfaceInfo: const Color(0xFF38BDF8),

  // --------------- 成功色 ---------------
  AppTheme.cFeedbackSuccessBackground: const Color(0xFF00D492).withValues(alpha: 0.2),
  AppTheme.cFeedbackSuccessBorder: const Color(0xFF00BC7D),
  AppTheme.cFeedbackSuccessText: const Color(0xFF00BC7D),
  AppTheme.cFeedbackSuccessIcon: const Color(0xFF00BC7D),

  // --------------- 警告色 ---------------
  AppTheme.cFeedbackWarningBackground: const Color(0xFFFBBF24).withValues(alpha: 0.2),
  AppTheme.cFeedbackWarningBorder: const Color(0xFFF59E0B),
  AppTheme.cFeedbackWarningText: const Color(0xFFF59E0B),
  AppTheme.cFeedbackWarningIcon: const Color(0xFFF59E0B),

  // --------------- 错误色 ---------------
  AppTheme.cFeedbackErrorBackground: const Color(0xFFFB7185).withValues(alpha: 0.2),
  AppTheme.cFeedbackErrorBorder: const Color(0xFFF43F5E),
  AppTheme.cFeedbackErrorText: const Color(0xFFF43F5E),
  AppTheme.cFeedbackErrorIcon: const Color(0xFFF43F5E),

  // --------------- 信息色 ---------------
  AppTheme.cFeedbackInfoBackground: const Color(0xFF38BDF8).withValues(alpha: 0.2),
  AppTheme.cFeedbackInfoBorder: const Color(0xFF0EA5E9),
  AppTheme.cFeedbackInfoText: const Color(0xFF0EA5E9),
  AppTheme.cFeedbackInfoIcon: const Color(0xFF0EA5E9),

  // --------------- 信息状态默认色 ---------------
  AppTheme.cFeedbackDefaultBackground: const Color(0xFF878A90).withValues(alpha: 0.2),
  AppTheme.cFeedbackDefaultBorder: const Color(0xFFCACACE),
  AppTheme.cFeedbackDefaultText: const Color(0xFFCACACE),
  AppTheme.cFeedbackDefaultIcon: const Color(0xFFCACACE),

  // ------------------ inverse ---------------------
  AppTheme.cInverseBg: const Color(0xFFFFFFFF),
  AppTheme.cInverseSurface: const Color(0xFFFFFFFF),
  AppTheme.cInversePrimary: const Color(0xFF38BDF8),
  AppTheme.cInverseGray: const Color(0xFFACB5BC),
  AppTheme.cInverseOverlay: const Color(0xFF000000).withValues(alpha: 0.65),
  AppTheme.cInverseOverlay2: const Color(0xFF1D2021).withValues(alpha: 0.95),
  AppTheme.cInverseOverlay3: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
  AppTheme.cInverseOverlay4: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
  AppTheme.cInverseOverlay5: const Color(0xFFFFFFFF).withValues(alpha: 0.15),
  AppTheme.cInverseTextDark: const Color(0xFF131617),
  AppTheme.cInverseTextLight: const Color(0xFFFFFFFF),

  // --------------- icon -----------------
  AppTheme.cIconHelp: const Color(0xFFFFFFFF),

  // --------------- 遮罩层 ---------------
  AppTheme.cOverlayBackground: const Color(0xFF000000).withValues(alpha: 0.7),
  AppTheme.cOverlayHover: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
  AppTheme.cOverlayActive: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
  AppTheme.cOverlayDisabled: const Color(0xFF000000).withValues(alpha: 0.5),

  // ------------- 阴影 -----------------
  AppTheme.cShadowLight: const Color(0xFF000000).withValues(alpha: 0.1),
  AppTheme.cShadowMedium: const Color(0xFF000000).withValues(alpha: 0.2),
  AppTheme.cShadowDark: const Color(0xFF000000).withValues(alpha: 0.3),
  AppTheme.cDark: const Color(0xFFFFFFFF).withValues(alpha: 0.15),

  // ------------- 不跟随主题的颜色 -----------
  AppTheme.cStaticWhite: const Color(0xFFFFFFFF),
  AppTheme.cStaticBlack: const Color(0xFF000000),
  AppTheme.cStaticTransparent: const Color(0x00FFFFFF),
  AppTheme.cTransparentBrand1: const Color(0xff0369A1).withValues(alpha: 0.2),
  AppTheme.cTransparentBrand2: const Color(0xFF082F49).withValues(alpha: 0.2),
  AppTheme.cWhiteAlpha10: const Color(0xFFFFFFFF).withValues(alpha: 0.08),
  AppTheme.cWhiteAlpha20: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
  AppTheme.cWhiteAlpha50: const Color(0xFFFFFFFF).withValues(alpha: 0.48),
  AppTheme.cWhiteAlpha70: const Color(0xFFFFFFFF).withValues(alpha: 0.7),
  AppTheme.cBlackAlpha10: const Color(0xFF000000).withValues(alpha: 0.1),
  AppTheme.cBlackAlpha20: const Color(0xFF000000).withValues(alpha: 0.2),
  AppTheme.cBlackAlpha50: const Color(0xFF000000).withValues(alpha: 0.5),
  AppTheme.cBlackAlpha70: const Color(0xFF000000).withValues(alpha: 0.7),
  AppTheme.cStaticPrimary: const Color(0xFFF9F9FA),

  /// 视觉风格激活标签颜色
  AppTheme.cVisualStyleActivation: const Color(0xff115E59),

  // ---------- 考核方向标签颜色 ---------
  AppTheme.cDirectionCoreLesson: const Color(0xff0369A1),
  AppTheme.cDirectionPronunciation: const Color(0xff831843),
  AppTheme.cDirectionVocabulary: const Color(0xff4C1D95),
  AppTheme.cDirectionGrammar: const Color(0xff1E3A8A),
  AppTheme.cDirectionReading: const Color(0xff006045),
  AppTheme.cDirectionListening: const Color(0xff78350F),
  AppTheme.cDirectionSpeaking: const Color(0xff9A3412),
  AppTheme.cDirectionAssessment: const Color(0xff312E81),

  // --------- 难度等级标签颜色 ----------
  AppTheme.cDifficultyBackgroundColor0: const Color(0xff94A3B8),
  AppTheme.cDifficultyBackgroundColor00: const Color(0xff64748B),
  AppTheme.cDifficultyBackgroundColor1: const Color(0xff00D492),
  AppTheme.cDifficultyBackgroundColor11: const Color(0xff00BC7D),
  AppTheme.cDifficultyBackgroundColor2: const Color(0xff38BDF8),
  AppTheme.cDifficultyBackgroundColor22: const Color(0xff0EA5E9),
  AppTheme.cDifficultyBackgroundColor3: const Color(0xff818CF8),
  AppTheme.cDifficultyBackgroundColor33: const Color(0xff4F46E5),
  AppTheme.cDifficultyBackgroundColor4: const Color(0xffE879F9),
  AppTheme.cDifficultyBackgroundColor44: const Color(0xffC026D3),
  AppTheme.cDifficultyBackgroundColor5: const Color(0xffFB7185),
  AppTheme.cDifficultyBackgroundColor55: const Color(0xffF43F5E),
  AppTheme.cDifficultyBackgroundColor6: const Color(0xffFB923C),
  AppTheme.cDifficultyBackgroundColor66: const Color(0xffF97316),

  // --------- 要素卡片等级颜色 ----------
  AppTheme.cCardLevelColor0: const Color(0xff858A8F),
  AppTheme.cCardLevelColor1: const Color(0xff00BC7D),
  AppTheme.cCardLevelColor2: const Color(0xff3B82F6),
  AppTheme.cCardLevelColor3: const Color(0xffA855F7),
  AppTheme.cCardLevelColor4: const Color(0xffF59E0B),
  AppTheme.cCardLevelColor5: const Color(0xffF97316),

  // --------- 要素卡片颜色 ----------
  AppTheme.cWordCardColor1: const Color(0xff0EA5E9),
  AppTheme.cWordCardColor2: const Color(0xff38BDF8),
  AppTheme.cPhraseCardColor1: const Color(0xff14B8A6),
  AppTheme.cPhraseCardColor2: const Color(0xff14B8A6),
  AppTheme.cSentenceCardColor1: const Color(0xff00BC7D),
  AppTheme.cSentenceCardColor2: const Color(0xff14B8A6),
  AppTheme.cMorphemeCardColor1: const Color(0xffF97316),
  AppTheme.cMorphemeCardColor2: const Color(0xffF97316),
  AppTheme.cPhonicsCardColor1: const Color(0xff8B5CF6),
  AppTheme.cPhonicsCardColor2: const Color(0xff8B5CF6),
  AppTheme.cPhoneticsCardColor1: const Color(0xffD946EF),
  AppTheme.cPhoneticsCardColor2: const Color(0xffD946EF),
  AppTheme.cTextCardColor1: const Color(0xffF97316),
  AppTheme.cSongCardColor1: const Color(0xff8B5CF6),

  AppTheme.cCardCouponsBg: const Color(0xffFB7185),
  AppTheme.cCardCouponsPrimary: const Color(0xffF43F5E),
  AppTheme.cLearnSomethingBg: const Color(0xffFBBF24),
  AppTheme.cLearnSomethingPrimary: const Color(0xffF59E0B),
  AppTheme.cNsCoinBg: const Color(0xff38BDF8),
  AppTheme.cNsCoinBgPrimary: const Color(0xff0EA5E9),
  AppTheme.cMemberPrimary: const Color(0xffF97316),
  AppTheme.cImageStylePrimary: const Color(0xff14B8A6),

  // ----------- 会员颜色 -------------
  AppTheme.cUserFreeMember1: const Color(0xff0D9488),
  AppTheme.cUserFreeMember2: const Color(0xff2DD4BF),

  AppTheme.cUserPlusMember1: const Color(0xff0284C7),
  AppTheme.cUserPlusMember2: const Color(0xff38BDF8),

  AppTheme.cUserProMember1: const Color(0xff9333EA),
  AppTheme.cUserProMember2: const Color(0xffC084FC),

  AppTheme.cUserMaxMember1: const Color(0xffEA580C),
  AppTheme.cUserMaxMember2: const Color(0xffFB923C),

  AppTheme.cUserSeatCard1: const Color(0xff475569),
  AppTheme.cUserSeatCard2: const Color(0xff94A3B8),

  // ------------ 学点明细 统计颜色 -------------
  /// 当前余额
  AppTheme.cLearningPointBalance: const Color(0xff38BDF8),

  /// 总收入
  AppTheme.cLearningPointTotalIncome: const Color(0xff00BC7D),

  /// 总支出
  AppTheme.cLearningPointTotalExpenditure: const Color(0xffEF4444),

  // ------------ 升卡智能分析相关 --------------
  AppTheme.cPronunciationAccuracy: const Color(0xffF43F5E),
  AppTheme.cContextApplicationAbility: const Color(0xffF97316),
  AppTheme.cMasteryOfGrammaticalStructures: const Color(0xff14B8A6),

  // ------------- 词素标签 --------------
  AppTheme.cMorphemeTagPrefix: const Color(0xff22C55E),
  AppTheme.cMorphemeTagRoot: const Color(0xff3B82F6),
  AppTheme.cMorphemeTagSuffix: const Color(0xffA855F7),
  AppTheme.cMorphemeTagInfix: const Color(0xffEC4899),
  AppTheme.cMorphemeTagCombiningForm: const Color(0xffF59E0B),
  AppTheme.cMorphemeTagInterfix: const Color(0xff6366F1),

  // -------------- 学练测记 --------------
  /// 学习主色
  AppTheme.cLearnPrimary: const Color(0xff84CC16),

  /// 练习主色
  AppTheme.cPracticePrimary: const Color(0xffD946EF),

  /// 测试主色
  AppTheme.cTestPrimary: const Color(0xff38BDF8),

  /// 记忆主色
  AppTheme.cMemoryPrimary: const Color(0xffF97316),

  /// 备考主色
  AppTheme.cExamPrimary: const Color(0xff6366F1),

  // ----------------- 听说读写 ------------------
  AppTheme.cListenPrimary: const Color(0xff38BDF8),
  AppTheme.cListenBg1: const Color(0xff38BDF8),
  AppTheme.cListenBg2: const Color(0xff0EA5E9),

  AppTheme.cSayPrimary: const Color(0xff00D492),
  AppTheme.cSayBg1: const Color(0xff00D492),
  AppTheme.cSayBg2: const Color(0xff00BC7D),

  AppTheme.cReadPrimary: const Color(0xffA855F7),
  AppTheme.cReadBg1: const Color(0xffE879F9),
  AppTheme.cReadBg2: const Color(0xffC026D3),

  AppTheme.cWritePrimary: const Color(0xffFB923C),
  AppTheme.cWriteBg1: const Color(0xffFB923C),
  AppTheme.cWriteBg2: const Color(0xffF97316),

  /// ---------------------- 做题的状态 ----------------
  AppTheme.cQuizExcellentBackground: const Color(0xFF00BC7D),
  AppTheme.cQuizExcellentBorder: const Color(0xFF009966),

  AppTheme.cQuizGoodBackground: const Color(0xFF3B82F6),
  AppTheme.cQuizGoodBorder: const Color(0xFF2563EB),

  AppTheme.cQuizPassBackground: const Color(0xFFFBBF24),
  AppTheme.cQuizPassBorder: const Color(0xFFF59E0B),

  AppTheme.cQuizPoorBackground: const Color(0xFFF43F5E),
  AppTheme.cQuizPoorBorder: const Color(0xFFE11D48),

  AppTheme.cQuizDefaultBackground: const Color(0xFFACB5BC),
  AppTheme.cQuizDefaultBorder: const Color(0xFF5B6167),

  /// ---------------------- 会员卡管理 ----------------
  AppTheme.cMemberCardActiveBackground: const Color(0xFF26292A),
  AppTheme.cMemberCardInactiveBackground: const Color(0xFF46494C),
  AppTheme.cMemberCardLevelFont: const Color(0xFFDDE3EA),
  AppTheme.cMemberCardSearchBackground: const Color(0xFF1D2021),

  /// ---------------------- 编辑教材 ----------------
  AppTheme.cEditBookBackground: const Color(0xFF131617),
  AppTheme.cEditBookDotted: const Color(0xFF5B6167),
  AppTheme.cEditBookCellBackground: const Color(0xFF303335),
  AppTheme.cEditBookGradeBackground: const Color(0xFF26292A),

  ///去预习背景色
  AppTheme.cCoursePreviewBackground: const Color(0xFF26292A),

  /// 去听写按钮背景色
  AppTheme.cCourseDictationButtonBackground: const Color(0xFF1D2021),

  // ---------------------- 音频字幕编辑器 ----------------
  AppTheme.cEditorPromptAction: const Color(0xffA78BFA),
};
