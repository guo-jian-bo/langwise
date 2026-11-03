import 'package:themed/themed.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

enum AppThemeKey {
  dark("DARK"),
  light("LIGHT");

  final String value;

  const AppThemeKey(this.value);
}

class AppTheme {
  /// APP 所有的主题
  static Map<dynamic, Map<ThemeRef, Object>> appThemes = {
    AppThemeKey.dark.value: darkTheme, // 暗夜模式
    AppThemeKey.light.value: lightTheme, // 亮色模式
  };

  /// App 民名称
  static Map<String, String> appThemeNames = {
    AppThemeKey.dark.value: "暗色",
    AppThemeKey.light.value: "亮色",
  };

  // ----------- 背景颜色 ---------------
  /// 主要背景颜色，用于应用的主要背景区域
  static const cBgPrimary = ColorRef.fromId("cBgPrimary");

  /// 次要背景颜色，用于区分不同内容区域
  static const cBgSecondary = ColorRef.fromId("cBgSecondary");

  /// 第三级背景色，用于卡片和表单元素
  static const cBgTertiary = ColorRef.fromId("cBgTertiary");

  /// 第三级背景色，用于卡片和表单元素
  static const cBgQuaternary = ColorRef.fromId("cBgQuaternary");

  /// 品牌贝景色，用于强调品牌的区域
  static const cBgBrand = ColorRef.fromId("cBgBrand");

  /// 悬停状态背景色，用于交互元素的悬停效果
  static const cBgHover = ColorRef.fromId("cBgHover");

  /// 激活背景色，用于交互元素的激活状态
  static const cBgActive = ColorRef.fromId("cBgActive");

  /// 禁用背景色，用于禁用状态的元素
  static const cBgDisabled = ColorRef.fromId("cBgDisabled");

  /// 纯色背景
  static const cBgSolid = ColorRef.fromId("cBgSolid");

  // ----------- 文字颜色 ---------------
  /// 主要文本色，用于标题和重要内容
  static const cTextPrimary = ColorRef.fromId("cTextPrimary");

  /// 次要文本色，用于正文和描述性内容
  static const cTextSecondary = ColorRef.fromId("cTextSecondary");

  /// 三级文本色，用于辅助信息和次要内容
  static const cTextTertiary = ColorRef.fromId("cTextTertiary");

  /// 第四级文本色，用于辅助信息和次要内容
  static const cTextQuaternary = ColorRef.fromId("cTextQuaternary");

  /// 禁用状态文本色，用于不可交互的文本元素
  static const cTextDisabled = ColorRef.fromId("cTextDisabled");
  static const cTextDisabled2 = ColorRef.fromId("cTextDisabled2");

  /// 反色文本，用于高对比度背景上的文本
  static const cTextInverse = ColorRef.fromId("cTextInverse");

  /// 品牌文本色，用于强调品牌的文本元素
  static const cTextBrand = ColorRef.fromId("cTextBrand");

  /// 链接文本色，用于可点击的链接
  static const cTextLink = ColorRef.fromId("cTextLink");

  /// 链接悬停文本色，用于链接的悬停状态
  static const cTextLinkHover = ColorRef.fromId("cTextLinkHover");

  /// 激活色，用于交互元素的激活状态
  static const cTextAction = ColorRef.fromId("cTextAction");

  // --------------- 表面色 ---------------
  /// 主要表面色，用于卡片和弹出窗口
  static const cSurfacePrimary = ColorRef.fromId("cSurfacePrimary");

  static const cSurfaceBg = ColorRef.fromId("cSurfaceBg");

  /// 次要表面色，用于次要卡片和面板
  static const cSurfaceSecondary = ColorRef.fromId("cSurfaceSecondary");

  /// 第三表面色，用于嵌套卡片和面板
  static const cSurfaceTertiary = ColorRef.fromId("cSurfaceTertiary");

  /// 第三表面色，用于嵌套卡片和面板
  static const cSurfaceQuaternary = ColorRef.fromId("cSurfaceQuaternary");

  /// 品牌表面色，用于强调品牌的UI元素
  static const cSurfaceQuinary = ColorRef.fromId("cSurfaceQuinary");

  /// 品牌表面色，用于强调品牌的UI元素
  static const cSurfaceBrand = ColorRef.fromId("cSurfaceBrand");

  /// 成功表面色，用于表示成功状态的UI元素
  static const cSurfaceSuccess = ColorRef.fromId("cSurfaceSuccess");

  /// 警告表面色，用于表示警告状态的UI元素
  static const cSurfaceWarning = ColorRef.fromId("cSurfaceWarning");

  /// 错误表面色，用于表示错误状态的UI元素
  static const cSurfaceError = ColorRef.fromId("cSurfaceError");

  /// 信息表面色，用于表示信息状态的UI元素
  static const cSurfaceInfo = ColorRef.fromId("cSurfaceInfo");

  static const cSurfaceThin = ColorRef.fromId("cSurfaceThin");

  /// 基础容器层 页面中最底层的基础卡片背景（如大卡片外框）。它定义了容器的基准高度
  static const cSurfaceLayerBase = ColorRef.fromId("cSurfaceLayerBase");
  static const cSurfaceLayerBase2 = ColorRef.fromId("cSurfaceLayerBase2");

  /// 抬升容器层（比 Base 更突出）嵌套在 Base 内部的次级容器（如卡片内的列表项、小卡片）。通过透明度叠加使其在视觉上“浮"于 Base 之上
  static const cSurfaceLayerElevated = ColorRef.fromId("cSurfaceLayerElevated");
  static const cSurfaceLayerElevated2 = ColorRef.fromId("cSurfaceLayerElevated2");

  /// 下凹容器层（比 Base 更深）嵌套在 Base 内部的下凹或暗化区域（如输入框底色、内部深色区块）。通过黑色透明度叠加使其在视觉上“凹”于 Base 之下
  static const cSurfaceLayerDarken = ColorRef.fromId("cSurfaceLayerDarken");
  
  ///
  static const cSurfaceSearchBackground = ColorRef.fromId("cSurfaceSearchBackground");
  /// 
  static const cSurfacePlayerBackground = ColorRef.fromId("cSurfacePlayerBackground");
  /// 
  static const cSurfacePlayerOverlay = ColorRef.fromId("cSurfacePlayerOverlay");
  /// 
  static const cSurfaceGhostBgSubtle = ColorRef.fromId("cSurfaceGhostBgSubtle");
  /// 
  static const cSurfaceGhostBgStrong = ColorRef.fromId("cSurfaceGhostBgStrong");
  /// 
  static const cSurfaceChoice = ColorRef.fromId("cSurfaceChoice");

  static const cSurfaceSoildBg = ColorRef.fromId("cSurfaceSoildBg");
  
  static const cSurfaceTranslucentBase = ColorRef.fromId("cSurfaceTranslucentBase");

  // -------------- 边框颜色 ---------------
  /// 主要边框色，用于大多数UI元素的边框
  static const cBorderPrimary = ColorRef.fromId("cBorderPrimary");

  /// 次要边框色，用于次要UI元素的边框
  static const cBorderSecondary = ColorRef.fromId("cBorderSecondary");

  /// 次要边框色，用于次要UI元素的边框
  static const cBorderTertiary = ColorRef.fromId("cBorderTertiary");

  /// 次要边框色，用于次要UI元素的边框
  static const cBorderQuaternary = ColorRef.fromId("cBorderQuaternary");

  /// 品牌边框色，用于强调品牌的边框
  static const cBorderBrand = ColorRef.fromId("cBorderBrand");

  /// 焦点边框色，用于表示当前聚焦的UI元素
  static const cBorderFocus = ColorRef.fromId("cBorderFocus");

  /// 禁用边框色，用于禁用状态的的边框
  static const cBorderDisabled = ColorRef.fromId("cBorderDisabled");

  /// 最弱的描边，用于卡片内部的分隔线
  static const cBorderSubtle = ColorRef.fromId("cBorderSubtle");

  /// 最弱的描边，用于卡片内部的分隔线
  static const cBorderDefault = ColorRef.fromId("cBorderDefault");

  /// 最弱的描边，用于卡片内部的分隔线
  static const cBorderDark = ColorRef.fromId("cBorderDark");

  static const cBorderNone = ColorRef.fromId("cBorderNone");
  static const cBorderThin = ColorRef.fromId("cBorderThin");

  static const cBorderTranslucentNone = ColorRef.fromId("cBorderTranslucentNone");
  static const cBorderTranslucentNone3 = ColorRef.fromId("cBorderTranslucentNone3");
  static const cBorderTranslucentThin = ColorRef.fromId("cBorderTranslucentThin");


  // --------------- 成功色 ---------------
  /// 成功状态的背景色，用于成功消息和通知
  static const cFeedbackSuccessBackground = ColorRef.fromId("cFeedbackSuccessBackground");

  /// 成功状态的边框色，用于成功消息和通知
  static const cFeedbackSuccessBorder = ColorRef.fromId("cFeedbackSuccessBorder");

  /// 成功状态的文本色，用于成功消息和通知
  static const cFeedbackSuccessText = ColorRef.fromId("cFeedbackSuccessText");

  /// 成功状态的图标色，用于成功消息和通知
  static const cFeedbackSuccessIcon = ColorRef.fromId("cFeedbackSuccessIcon");

  // -------------- 警告色 ---------------
  /// 警告状态的背景色，用于警告消息和通知
  static const cFeedbackWarningBackground = ColorRef.fromId("cFeedbackWarningBackground");

  /// 警告状态的边框色，用于警告消息和通知
  static const cFeedbackWarningBorder = ColorRef.fromId("cFeedbackWarningBorder");

  /// 警告状态的文本色，用于警告消息和通知
  static const cFeedbackWarningText = ColorRef.fromId("cFeedbackWarningText");

  /// 警告状态的图标色，用于警告消息和通知
  static const cFeedbackWarningIcon = ColorRef.fromId("cFeedbackWarningIcon");
  static const cFeedbackWarningBg = ColorRef.fromId("cFeedbackWarningBg");

  // -------------- 错误色 ---------------
  /// 错误状态的背景色，用于错误消息和通知
  static const cFeedbackErrorBackground = ColorRef.fromId("cFeedbackErrorBackground");

  /// 错误状态的边框色，用于错误消息和通知
  static const cFeedbackErrorBorder = ColorRef.fromId("cFeedbackErrorBorder");

  /// 错误状态的文本色，用于错误消息和通知
  static const cFeedbackErrorText = ColorRef.fromId("cFeedbackErrorText");

  /// 错误状态的图标色，用于错误消息和通知
  static const cFeedbackErrorIcon = ColorRef.fromId("cFeedbackErrorIcon");

  // -------------- 信息色 ---------------
  /// 信息状态的背景色，用于信息消息和通知
  static const cFeedbackInfoBackground = ColorRef.fromId("cFeedbackInfoBackground");

  /// 信息状态的边框色，用于信息消息和通知
  static const cFeedbackInfoBorder = ColorRef.fromId("cFeedbackInfoBorder");

  /// 信息状态的文本色，用于信息消息和通知
  static const cFeedbackInfoText = ColorRef.fromId("cFeedbackInfoText");

  /// 信息状态的图标色，用于信息消息和通知
  static const cFeedbackInfoIcon = ColorRef.fromId("cFeedbackInfoIcon");

  // -------------- 信息状态默认色 ------------------
  /// 信息状态的背景色，用于信息消息和通知
  static const cFeedbackDefaultBackground = ColorRef.fromId("cFeedbackDefaultBackground");

  /// 信息状态的边框色，用于信息消息和通知
  static const cFeedbackDefaultBorder = ColorRef.fromId("cFeedbackDefaultBorder");

  /// 信息状态的文本色，用于信息消息和通知
  static const cFeedbackDefaultText = ColorRef.fromId("cFeedbackDefaultText");

  /// 信息状态的图标色，用于信息消息和通知
  static const cFeedbackDefaultIcon = ColorRef.fromId("cFeedbackDefaultIcon");

  // ------------------ inverse ---------------------
  static const cInverseBg = ColorRef.fromId("cInverseBg");
  static const cInverseSurface = ColorRef.fromId("cInverseSurface");
  static const cInversePrimary = ColorRef.fromId("cInversePrimary");
  static const cInverseGray = ColorRef.fromId("cInverseGray");
  static const cInverseOverlay = ColorRef.fromId("cInverseOverlay");
  static const cInverseOverlay2 = ColorRef.fromId("cInverseOverlay2");
  static const cInverseOverlay3 = ColorRef.fromId("cInverseOverlay3");
  static const cInverseOverlay4 = ColorRef.fromId("cInverseOverlay4");
  static const cInverseOverlay5 = ColorRef.fromId("cInverseOverlay5");
  static const cInverseTextDark = ColorRef.fromId("cInverseTextDark");
  static const cInverseTextLight = ColorRef.fromId("cInverseTextLight");

  // --------------- icon -----------------
  /// 用于i标签的icon颜色
  static const cIconHelp = ColorRef.fromId("cIconHelp");

  // -------------- 遮罩层 ---------------
  /// 遮罩层背景色，用于模态框和弹出层的背景
  static const cOverlayBackground = ColorRef.fromId("cOverlayBackground");

  /// 遮罩层的悬停色，提供视觉反馈
  static const cOverlayHover = ColorRef.fromId("cOverlayHover");

  /// 遮罩层激活色，提供视觉反馈
  static const cOverlayActive = ColorRef.fromId("cOverlayActive");

  /// 遮罩层禁用色，提供视觉反馈
  static const cOverlayDisabled = ColorRef.fromId("cOverlayDisabled");

  // ------------- 阴影 -----------------
  /// 轻微阴影，用于轻量级UI元素
  static const cShadowLight = ColorRef.fromId("cShadowLight");

  /// 中等阴影，用于中等强调的UI元素
  static const cShadowMedium = ColorRef.fromId("cShadowMedium");

  /// 深色阴影，用于高强调的UI元素
  static const cShadowDark = ColorRef.fromId("cShadowDark");
  static const cDark = ColorRef.fromId("cDark");

  // --------------- 不跟随主题的颜色 -----------
  static const cStaticWhite = ColorRef.fromId("cStaticWhite");
  static const cStaticBlack = ColorRef.fromId("cStaticBlack");
  static const cStaticTransparent = ColorRef.fromId("cStaticTransparent");
  static const cTransparentBrand1 = ColorRef.fromId("cTransparentBrand1");
  static const cTransparentBrand2 = ColorRef.fromId("cTransparentBrand2");
  static const cWhiteAlpha10 = ColorRef.fromId("cWhiteAlpha10");
  static const cWhiteAlpha20 = ColorRef.fromId("cWhiteAlpha20");
  static const cWhiteAlpha50 = ColorRef.fromId("cWhiteAlpha50");
  static const cWhiteAlpha70 = ColorRef.fromId("cWhiteAlpha70");
  static const cStaticDeprecatedWhite50 = ColorRef.fromId("cStaticDeprecatedWhite50");
  static const cBlackAlpha10 = ColorRef.fromId("cBlackAlpha10");
  static const cBlackAlpha20 = ColorRef.fromId("cBlackAlpha20");
  static const cBlackAlpha50 = ColorRef.fromId("cBlackAlpha50");
  static const cStaticDeprecatedBlack60 = ColorRef.fromId("cStaticDeprecatedBlack60");
  static const cBlackAlpha70 = ColorRef.fromId("cBlackAlpha70");
  static const cStaticPrimary = ColorRef.fromId("cStaticPrimary");

  /// 视觉风格激活标签颜色
  static const cVisualStyleActivation = ColorRef.fromId("cVisualStyleActivation");

  // ---------- 考核方向标签颜色 ---------
  /// 主课程
  static const cDirectionCoreLesson = ColorRef.fromId("cDirectionCoreLesson");

  /// 发音
  static const cDirectionPronunciation = ColorRef.fromId("cDirectionPronunciation");

  /// 词汇
  static const cDirectionVocabulary = ColorRef.fromId("cDirectionVocabulary");

  /// 语法
  static const cDirectionGrammar = ColorRef.fromId("cDirectionGrammar");

  /// 阅读
  static const cDirectionReading = ColorRef.fromId("cDirectionReading");

  /// 听力
  static const cDirectionListening = ColorRef.fromId("cDirectionListening");

  /// 口语
  static const cDirectionSpeaking = ColorRef.fromId("cDirectionSpeaking");

  /// 单元测试
  static const cDirectionAssessment = ColorRef.fromId("cDirectionAssessment");

  // --------- 难度等级标签颜色 ----------
  static const cDifficultyBackgroundColor0 = ColorRef.fromId("cDifficultyBackgroundColor0");
  static const cDifficultyBackgroundColor00 = ColorRef.fromId("cDifficultyBackgroundColor00");
  static const cDifficultyBackgroundColor1 = ColorRef.fromId("cDifficultyBackgroundColor1");
  static const cDifficultyBackgroundColor11 = ColorRef.fromId("cDifficultyBackgroundColor11");
  static const cDifficultyBackgroundColor2 = ColorRef.fromId("cDifficultyBackgroundColor2");
  static const cDifficultyBackgroundColor22 = ColorRef.fromId("cDifficultyBackgroundColor22");
  static const cDifficultyBackgroundColor3 = ColorRef.fromId("cDifficultyBackgroundColor3");
  static const cDifficultyBackgroundColor33 = ColorRef.fromId("cDifficultyBackgroundColor33");
  static const cDifficultyBackgroundColor4 = ColorRef.fromId("cDifficultyBackgroundColor4");
  static const cDifficultyBackgroundColor44 = ColorRef.fromId("cDifficultyBackgroundColor44");
  static const cDifficultyBackgroundColor5 = ColorRef.fromId("cDifficultyBackgroundColor5");
  static const cDifficultyBackgroundColor55 = ColorRef.fromId("cDifficultyBackgroundColor55");
  static const cDifficultyBackgroundColor6 = ColorRef.fromId("cDifficultyBackgroundColor6");
  static const cDifficultyBackgroundColor66 = ColorRef.fromId("cDifficultyBackgroundColor66");

  // --------- 要素卡片等级颜色 ----------
  static const cCardLevelColor0 = ColorRef.fromId("cCardLevelColor0");
  static const cCardLevelColor1 = ColorRef.fromId("cCardLevelColor1");
  static const cCardLevelColor2 = ColorRef.fromId("cCardLevelColor2");
  static const cCardLevelColor3 = ColorRef.fromId("cCardLevelColor3");
  static const cCardLevelColor4 = ColorRef.fromId("cCardLevelColor4");
  static const cCardLevelColor5 = ColorRef.fromId("cCardLevelColor5");

  // --------- 要素卡片颜色 ----------

  ///首页单词卡片 颜色1
  static const cWordCardColor1 = ColorRef.fromId("cWordCardColor1");

  ///首页单词卡片 颜色2
  static const cWordCardColor2 = ColorRef.fromId("cWordCardColor2");

  ///首页短语卡片 颜色1
  static const cPhraseCardColor1 = ColorRef.fromId("cPhraseCardColor1");

  ///首页短语卡片 颜色2
  static const cPhraseCardColor2 = ColorRef.fromId("cPhraseCardColor2");

  ///首页句子卡片 颜色1
  static const cSentenceCardColor1 = ColorRef.fromId("cSentenceCardColor1");

  ///首页句子卡片 颜色2
  static const cSentenceCardColor2 = ColorRef.fromId("cSentenceCardColor2");

  ///首页词素卡片 颜色1
  static const cMorphemeCardColor1 = ColorRef.fromId("cMorphemeCardColor1");

  ///首页词素卡片 颜色2
  static const cMorphemeCardColor2 = ColorRef.fromId("cMorphemeCardColor2");

  /// 首页自拼卡片 颜色1
  static const cPhonicsCardColor1 = ColorRef.fromId("cPhonicsCardColor1");

  /// 首页自拼卡片 颜色2
  static const cPhonicsCardColor2 = ColorRef.fromId("cPhonicsCardColor2");

  /// 首页音标卡片 颜色1
  static const cPhoneticsCardColor1 = ColorRef.fromId("cPhoneticsCardColor1");

  /// 首页音标卡片 颜色2
  static const cPhoneticsCardColor2 = ColorRef.fromId("cPhoneticsCardColor2");

  /// 首页文本卡片 颜色1
  static const cTextCardColor1 = ColorRef.fromId("cTextCardColor1");

  /// 首页歌曲卡片 颜色1
  static const cSongCardColor1 = ColorRef.fromId("cSongCardColor1");

  /// 卡券背景颜色
  static const cCardCouponsBg = ColorRef.fromId("cCardCouponsBg");

  /// 卡券主色
  static const cCardCouponsPrimary = ColorRef.fromId("cCardCouponsPrimary");

  /// 学点背景颜色
  static const cLearnSomethingBg = ColorRef.fromId("cLearnSomethingBg");

  /// 学点主色
  static const cLearnSomethingPrimary = ColorRef.fromId("cLearnSomethingPrimary");

  /// 乃币背景颜色
  static const cNsCoinBg = ColorRef.fromId("cNsCoinBg");

  /// 乃币主色
  static const cNsCoinBgPrimary = ColorRef.fromId("cNsCoinBgPrimary");

  /// 会员主色
  static const cMemberPrimary = ColorRef.fromId("cMemberPrimary");

  /// 图片风格主色
  static const cImageStylePrimary = ColorRef.fromId("cImageStylePrimary");

  // ----------- 会员颜色 -------------

  /// Free 会员
  static const cUserFreeMember1 = ColorRef.fromId("cUserFreeMember1");

  /// Free 会员
  static const cUserFreeMember2 = ColorRef.fromId("cUserFreeMember2");

  /// Plus 会员
  static const cUserPlusMember1 = ColorRef.fromId("cUserPlusMember1");

  /// Plus 会员
  static const cUserPlusMember2 = ColorRef.fromId("cUserPlusMember2");

  /// Pro 会员
  static const cUserProMember1 = ColorRef.fromId("cUserProMember1");

  /// Pro 会员
  static const cUserProMember2 = ColorRef.fromId("cUserProMember2");

  // Max 会员
  static const cUserMaxMember1 = ColorRef.fromId("cUserMaxMember1");

  /// Max 会员
  static const cUserMaxMember2 = ColorRef.fromId("cUserMaxMember2");

  /// 席位卡
  static const cUserSeatCard1 = ColorRef.fromId("cUserSeatCard1");

  static const cUserSeatCard2 = ColorRef.fromId("cUserSeatCard2");

  // ------------ 学点明细 统计颜色 -------------
  /// 当前余额
  static const cLearningPointBalance = ColorRef.fromId("cLearningPointBalance");

  /// 总收入
  static const cLearningPointTotalIncome = ColorRef.fromId("cLearningPointTotalIncome");

  /// 总支出
  static const cLearningPointTotalExpenditure = ColorRef.fromId("cLearningPointTotalExpenditure");

  // ------------ 升卡智能分析相关 --------------
  /// 升卡智能分析 发音准确度
  static const cPronunciationAccuracy = ColorRef.fromId("cPronunciationAccuracy");

  /// 升卡智能分析 语境应用能力
  static const cContextApplicationAbility = ColorRef.fromId("cContextApplicationAbility");

  /// 升卡智能分析 语法结构掌握
  static const cMasteryOfGrammaticalStructures = ColorRef.fromId("cMasteryOfGrammaticalStructures");

  // ------------- 词素标签 --------------
  /// 词素标签 前缀 PREFIX
  static const cMorphemeTagPrefix = ColorRef.fromId("cMorphemeTagPrefix");

  /// 词素标签 词根 ROOT
  static const cMorphemeTagRoot = ColorRef.fromId("cMorphemeTagRoot");

  /// 词素标签 后缀 SUFFIX
  static const cMorphemeTagSuffix = ColorRef.fromId("cMorphemeTagSuffix");

  /// 词素标签 中缀 INFIX
  static const cMorphemeTagInfix = ColorRef.fromId("cMorphemeTagInfix");

  /// 词素标签 连接形式 COMBINING_FORM
  static const cMorphemeTagCombiningForm = ColorRef.fromId("cMorphemeTagCombiningForm");

  /// 词素标签 连接词素 INTERFIX
  static const cMorphemeTagInterfix = ColorRef.fromId("cMorphemeTagInterfix");

  // -------------- 学练测记 --------------
  /// 学习主色
  static const cLearnPrimary = ColorRef.fromId("cLearnPrimary");

  /// 练习主色
  static const cPracticePrimary = ColorRef.fromId("cPracticePrimary");

  /// 测试主色
  static const cTestPrimary = ColorRef.fromId("cTestPrimary");

  /// 记忆主色
  static const cMemoryPrimary = ColorRef.fromId("cMemoryPrimary");

  /// 备考主色
  static const cExamPrimary = ColorRef.fromId("cExamPrimary");

  // ----------------- 听说读写 ------------------
  /// 听-主色
  static const cListenPrimary = ColorRef.fromId("cListenPrimary");

  /// 听-背景1
  static const cListenBg1 = ColorRef.fromId("cListenBg1");

  /// 听-背景2
  static const cListenBg2 = ColorRef.fromId("cListenBg2");

  /// 说-主色
  static const cSayPrimary = ColorRef.fromId("cSayPrimary");

  /// 说-背景1
  static const cSayBg1 = ColorRef.fromId("cSayBg1");

  /// 说-背景2
  static const cSayBg2 = ColorRef.fromId("cSayBg2");

  /// 读-主色
  static const cReadPrimary = ColorRef.fromId("cReadPrimary");

  /// 读-背景1
  static const cReadBg1 = ColorRef.fromId("cReadBg1");

  /// 读-背景2
  static const cReadBg2 = ColorRef.fromId("cReadBg2");

  /// 写-主色
  static const cWritePrimary = ColorRef.fromId("cWritePrimary");

  /// 写-背景1
  static const cWriteBg1 = ColorRef.fromId("cWriteBg1");

  /// 写-背景2
  static const cWriteBg2 = ColorRef.fromId("cWriteBg2");

  /// ---------------------- 做题的状态 ----------------

  /// 做题状态 优秀背景
  static const cQuizExcellentBackground = ColorRef.fromId("cQuizExcellentBackground");

  /// 做题状态 优秀边框
  static const cQuizExcellentBorder = ColorRef.fromId("cQuizExcellentBorder");

  /// 做题状态 良好背景
  static const cQuizGoodBackground = ColorRef.fromId("cQuizGoodBackground");

  /// 做题状态 良好边框
  static const cQuizGoodBorder = ColorRef.fromId("cQuizGoodBorder");

  /// 做题状态 及格背景
  static const cQuizPassBackground = ColorRef.fromId("cQuizPassBackground");

  /// 做题状态 及格边框
  static const cQuizPassBorder = ColorRef.fromId("cQuizPassBorder");

  /// 做题状态 不及格背景
  static const cQuizPoorBackground = ColorRef.fromId("cQuizPoorBackground");

  /// 做题状态 不及格边框
  static const cQuizPoorBorder = ColorRef.fromId("cQuizPoorBorder");

  /// 信息状态的背景色，用于做题状态
  static const cQuizDefaultBackground = ColorRef.fromId("cQuizDefaultBackground");

  /// 信息状态的边框色，用于做题状态
  static const cQuizDefaultBorder = ColorRef.fromId("cQuizDefaultBorder");

  /// ---------------------- 会员卡管理 ----------------

  /// 会员卡管理已激活按钮背景
  static const cMemberCardActiveBackground = ColorRef.fromId("cMemberCardActiveBackground");

  /// 会员卡管理未激活按钮背景
  static const cMemberCardInactiveBackground = ColorRef.fromId("cMemberCardInactiveBackground");

  ///会员卡等级字体色
  static const cMemberCardLevelFont = ColorRef.fromId("cMemberCardLevelFont");

  ///会员卡搜索背景色
  static const cMemberCardSearchBackground = ColorRef.fromId("cMemberCardSearchBackground");

  /// ---------------------- 编辑教材 ----------------
  static const cEditBookBackground = ColorRef.fromId("cEditBookBackground");
  static const cEditBookDotted = ColorRef.fromId("cEditBookDotted");
  static const cEditBookGradeBackground = ColorRef.fromId("cEditBookGradeBackground");
  static const cEditBookCellBackground = ColorRef.fromId("cEditBookCellBackground");

  ///去预习背景色
  static const cCoursePreviewBackground = ColorRef.fromId("cPreviewBackground");

  /// 去听写按钮背景色
  static const cCourseDictationButtonBackground = ColorRef.fromId("cCourseDictationButtonBackground");

  // ---------------------- 音频字幕编辑器 ----------------
  /// 曲风Prompt 动作按钮颜色
  static const cEditorPromptAction = ColorRef.fromId("cEditorPromptAction");
  /// 曲风Prompt 动作按钮背景色
  static const cSurfaceBlurSubtle = ColorRef.fromId("cSurfaceBlurSubtle");
  static const cLevelA2Text = ColorRef.fromId("cLevelA2Text");
  static const cLevelA2Border = ColorRef.fromId("cLevelA2Border");
  static const cLevelA2Background = ColorRef.fromId("cLevelA2Background");
  static const cAmber = ColorRef.fromId("cAmber");
  static const cPhonics = ColorRef.fromId("cPhonics");
  static const cSurfaceSoildTertiary = ColorRef.fromId("cSurfaceSoildTertiary");
  static const cBorderSoildSecondary = ColorRef.fromId("cBorderSoildSecondary");
  static const cSurfaceTranslucentElevated = ColorRef.fromId("cSurfaceTranslucentElevated");
  static const cBorderTranslucentSubtle = ColorRef.fromId("cBorderTranslucentSubtle");
  static const cSurfaceTranslucentThin = ColorRef.fromId("cSurfaceTranslucentThin");
  static const cBorderTranslucentDefault = ColorRef.fromId("cBorderTranslucentDefault");




}
