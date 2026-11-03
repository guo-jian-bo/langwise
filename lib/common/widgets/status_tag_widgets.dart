import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/video_image_inner_button_widget.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../enum/elements_card_type.dart';
import '../../theme/theme.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../public_controller/config_controller.dart';

class StatusTagDifficultyWidget extends StatelessWidget {
  final int? difficulty;
  final String? language;
  final double? fontSize;
  final Color? defaultColor;
  final EdgeInsetsGeometry? padding;
  final Color? fontColor;
  final double? borderRadius;
  final double? height;
  final AlignmentGeometry? alignment;
  final bool isIcon;

  /// 难度等级标签
  const StatusTagDifficultyWidget({
    super.key,
    this.difficulty,
    this.language,
    this.fontSize,
    this.defaultColor,
    this.padding,
    this.fontColor,
    this.borderRadius,
    this.height,
    this.alignment,
    this.isIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    if (difficulty == null || language == null) {
      return Container();
    }
    final configEntity = Get.find<ConfigController>().appConfig.value;

    DifficultieEntity? currentDifficulty = DifficultieUtils.getLanguageDifficultieLevel(configEntity, language, difficulty);
    if (currentDifficulty == null) return Container();

    final color = defaultColor ?? StatusUtils.getDifficultyBackgroundColor(difficulty).color1;
    return 

    isIcon
    ? VideoImageInnerButtonWidget(
      text: currentDifficulty.name?.text ?? "",
    )
    : Container(
      height: height,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      alignment: alignment,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius??4.wMin),
        color: color,
        border: Border.all(
          color: color,
          width: 1.wMin,
        ),
      ),
      child: 
      Text(
        currentDifficulty.name?.text ?? "",
        style: TextStyle(
          color: fontColor ?? Colors.white,
          fontSize: fontSize ?? 14.wMin,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class StatusTagDirectionWidget extends StatelessWidget {
  final String? direction;

  /// 考核方向标签
  const StatusTagDirectionWidget({super.key, this.direction});

  @override
  Widget build(BuildContext context) {
    if (direction == null) {
      return Container();
    }
    final configEntity = Get.find<ConfigController>().appConfig.value;
    ConfigEntityAbilities? currentDirection = AbilitieUtils.getAbilitieName(configEntity, direction);
    if (currentDirection == null) return Container();

    final color = StatusUtils.getDirectionBackgroundColor(direction);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: color,
      ),
      child: Text(
        currentDirection.title ?? "",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.wMin,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class StatusTagAiQueueWidget extends StatelessWidget {
  /// 状态 0 生成完成，但是没有处理 1 有多少任务在跑 2 总题目
  final int status;
  final int? count;

  /// AI队列标签
  const StatusTagAiQueueWidget({super.key, required this.status, this.count});

  @override
  Widget build(BuildContext context) {
    Color color = const Color(0xffFF3F56);
    if (status == 1) {
      color = const Color(0xff2388FF);
    } else if (status == 2) {
      color = const Color(0xff44AF5C);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: color, // 根据状态显示颜色
      ),
      child: Text(
        (count ?? 0).toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.wMin,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class StatusTagAiStatusWidget extends StatelessWidget {
  final int? status;
  final int? handle;
  const StatusTagAiStatusWidget({super.key, this.status, this.handle});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color(0xffFF3F56);
    String text = "";
    if ((status == 2 || status == 3) && (handle == 0 || handle == null)) {
      text = "待确认";
    } else if (status == 1) {
      text = "生成中";
      backgroundColor = const Color(0xff2388FF);
    } else if (status == 2 && handle == 1) {
      text = "已完成";
      backgroundColor = const Color(0xff44AF5C);
    } else if (handle == 2) {
      text = "已放弃";
      backgroundColor = const Color(0xff353E5C);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: backgroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.wMin,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class StatusMembersOnlyWidget extends StatelessWidget {
  final String? member;
  final List<UserInfoEntityVipConfigs?>? vipConfigs;

  /// 会员专享标签
  const StatusMembersOnlyWidget({super.key, this.member, this.vipConfigs});

  @override
  Widget build(BuildContext context) {
    if (member == null || vipConfigs == null) return Container();

    MemberLevelColor currentColors = StatusUtils.getMemberColorsByVipConfigs(vipConfigs, member);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: currentColors.pale,
        boxShadow: [
          BoxShadow(
            color: AppTheme.cShadowLight,
            blurRadius: 4.wMin,
          ),
        ],
      ),
      child: Text(
        "$member 专享",
        style: TextStyle(
          fontSize: 24.wMin,
          color: AppTheme.cStaticWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class StatusSentenceGrammaticalFeaturesTagWidget extends StatelessWidget {
  final List<LanguageText?>? categoryName;
  final String feature;
  final List<LanguageText?>? featureName;
  final List<LanguageConfigColorEntityInfo?>? colorConfigs;

  /// 句子 语法特征 标签
  const StatusSentenceGrammaticalFeaturesTagWidget({
    super.key,
    required this.categoryName,
    required this.feature,
    required this.featureName,
    this.colorConfigs,
  });

  @override
  Widget build(BuildContext context) {
    LanguageConfigColorModel? configColor = StatusUtils.getConfigColor(colorConfigs, feature);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        color: configColor?.color?.bgColor ?? AppTheme.cBgBrand.addOpacity(0.1),
        borderRadius: BorderRadius.circular(4.wMin),
      ),
      child: Obx(() {
        List<LanguageText> categories = LearningLangUtils.getShowLBList(categoryName);
        List<LanguageText> names = LearningLangUtils.getShowLBList(featureName);

        String value = "";
        if (categories.isNotEmpty) {
          value += "${categories.map((e) => e.text).join(" / ")}:";
        }
        if (names.isNotEmpty) {
          value += " ${names.map((e) => e.text).join(" / ")}";
        }

        return Text(
          value,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: configColor?.color?.textColor ?? AppTheme.cBgBrand,
          ),
        );
      }),
    );
  }
}

class StatusSentenceChunksTagWidget extends StatelessWidget {
  final String value;
  final String? type;
  final List<LanguageConfigColorEntityInfo?>? colorConfigs;

  /// 句子 语块标签
  const StatusSentenceChunksTagWidget({super.key, required this.value, this.type, this.colorConfigs});

  @override
  Widget build(BuildContext context) {
    LanguageConfigColorModel? configColor = StatusUtils.getConfigColor(colorConfigs, type);

    String text = "";
    if (configColor?.title?.isNotEmpty ?? false) {
      text += "${configColor?.title} / ";
    }
    text += value;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        color: configColor?.color?.bgColor ?? AppTheme.cBgBrand.addOpacity(0.1),
        borderRadius: BorderRadius.circular(4.wMin),
        border: Border.all(
          color: configColor?.color?.borderColor ?? Colors.transparent,
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w400,
          color: configColor?.color?.textColor ?? AppTheme.cBgBrand,
        ),
      ),
    );
  }
}

class StatusKnowlegeTypeTagWidget extends StatelessWidget {
  final ElementsCardType type;
  final String? value;
  final EdgeInsetsGeometry? padding;

  /// 知识点类型
  const StatusKnowlegeTypeTagWidget({super.key, required this.type, this.value, this.padding});

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return Container();
    }

    ElementsCardColor? cardColor = StatusUtils.getElementsCardColor(type.value);
    if (cardColor == null) return Container();

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        color: cardColor.color1.addOpacity(0.2),
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Text(
        value ?? "",
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
          color: cardColor.color1,
        ),
      ),
    );
  }
}
