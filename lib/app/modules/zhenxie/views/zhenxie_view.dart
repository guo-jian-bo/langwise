import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/stores/stores.dart';
import '../bindings/zhenxie_binding.dart';
import '../controllers/zhenxie_controller.dart';

class ZhenxieView extends GetView<ZhenxieController> {
  final String tagText;
  const ZhenxieView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieView(tagText: tag),
      binding: ZhenxieBinding(tagText: tag),
      routeName: Routes.ZHENXIE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Obx(() {
        return Column(
          children: [
            BreadcrumbWidget(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 90.wMin),
                child: Column(
                  children: [
                    _buildTopSectionWidget(),
                    SizedBox(height: 24.wMin),
                    Expanded(child: _buildDesktopContentWidget()),
                    SizedBox(height: 42.wMin),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTopSectionWidget() {
    final List<ZhenxieHomeTopStatData> topStatList = controller.buildTopStatList();
    final String title = controller.buildPageTitleText();
    final String description = controller.buildPageDescriptionText();
    final List<ZhenxieHomeMilestoneData> milestoneList = controller.buildMilestoneList();
    final bool hasLeft = title.isNotEmpty || description.isNotEmpty;
    final bool hasRight = topStatList.isNotEmpty || milestoneList.isNotEmpty;
    if (!hasLeft && !hasRight) return const SizedBox.shrink();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: hasLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: title.isNotEmpty,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 40.wMin,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                      color: AppTheme.cZhenxieFontPrimary.color,
                      height: 1.2,
                    ),
                  ),
                ),
                Visibility(
                  visible: description.isNotEmpty,
                  child: Container(
                    margin: EdgeInsets.only(top: 16.wMin),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontTertiary.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 24.wMin,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(topStatList.length, (index) {
                    final ZhenxieHomeTopStatData item = topStatList[index];
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: item.label,
                            style: TextStyle(
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.cZhenxieFontTertiary.color,
                            ),
                          ),
                          TextSpan(
                            text: " ${item.value}",
                            style: TextStyle(
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFontValue.robotoMono,
                              color: AppTheme.cZhenxieFontPrimary.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                _buildMilestoneAxisWidget(milestoneList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneAxisWidget(List<ZhenxieHomeMilestoneData> milestoneList) {
    if (milestoneList.isEmpty) return const SizedBox.shrink();
    return Row(
      spacing: 18.wMin,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(milestoneList.length, (index) {
        final ZhenxieHomeMilestoneData item = milestoneList[index];
        final bool isCurrent = item.isCurrent;
        return Container(
          constraints: BoxConstraints(
            minWidth: 120.wMin,
          ),
          child: Column(
            children: [
              Container(
                width: 18.wMin,
                height: 18.wMin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? AppTheme.cZhenxieColorPrimary.color : Colors.transparent,
                  border: Border.all(
                    width: 1.5.wMin,
                    color: isCurrent ? Colors.transparent : AppTheme.cZhenxieFontPrimary.color,
                  ),
                  boxShadow: !isCurrent
                      ? null
                      : [
                          BoxShadow(
                            color: AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.18),
                            blurRadius: 0,
                            spreadRadius: 4.wMin,
                          ),
                        ],
                ),
              ),
              SizedBox(height: 8.wMin),
              Text(
                item.title,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                  color: isCurrent ? AppTheme.cZhenxieColorPrimary.color : AppTheme.cZhenxieFontPrimary.color,
                ),
              ),
              SizedBox(height: 4.wMin),
              Text(
                item.alias,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFontValue.robotoMono,
                  color: AppTheme.cZhenxieFontSecondary.color,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDesktopContentWidget() {
    final double gap = 16.wMin;
    final ZhenxieHomeLayerCardData? lexisCardData = controller.buildLayerCardData(
      code: "lexis",
      toastText: "词法建设中",
    );
    final ZhenxieHomeLayerCardData? syntaxCardData = controller.buildLayerCardData(
      code: "syntax",
      toastText: "句法建设中",
    );
    final ZhenxieHomeLayerCardData? discourseCardData = controller.buildLayerCardData(
      code: "discourse",
      toastText: "章法建设中",
    );
    final ZhenxieHomeLayerCardData? examCardData = controller.buildLayerCardData(
      code: "exam",
      toastText: "考点建设中",
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final ZhenxieHomeCourseHeaderData? courseCardData = controller.buildCourseHeaderData();
        final bool hasLeftColumn = lexisCardData != null || syntaxCardData != null || discourseCardData != null;
        final bool hasRightColumn = examCardData != null || courseCardData != null;
        if (!hasLeftColumn && !hasRightColumn) return const SizedBox.shrink();
        final double singleHeight = (constraints.maxHeight - gap * 2) / 3;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasLeftColumn) ...[
              Expanded(
                flex: 60,
                child: Column(
                  children: [
                    if (lexisCardData != null) Expanded(child: _buildLayerCardWidget(_ZxLayerType.lexis, lexisCardData)),
                    if (lexisCardData != null && (syntaxCardData != null || discourseCardData != null)) SizedBox(height: gap),
                    if (syntaxCardData != null) Expanded(child: _buildLayerCardWidget(_ZxLayerType.syntax, syntaxCardData)),
                    if (syntaxCardData != null && discourseCardData != null) SizedBox(height: gap),
                    if (discourseCardData != null) Expanded(child: _buildLayerCardWidget(_ZxLayerType.discourse, discourseCardData)),
                  ],
                ),
              ),
            ],
            if (hasLeftColumn && hasRightColumn && !UserStore.to.userInfo.value.reviewStatus) SizedBox(width: gap),
            if (hasRightColumn && !UserStore.to.userInfo.value.reviewStatus) ...[
              Expanded(
                flex: 40,
                child: Column(
                  children: [
                    if (examCardData != null && courseCardData != null)
                      SizedBox(
                        height: singleHeight,
                        child: _buildLayerCardWidget(_ZxLayerType.exam, examCardData),
                      ),
                    if (examCardData != null && courseCardData != null) SizedBox(height: gap),
                    if (examCardData != null && courseCardData == null)
                      Expanded(child: _buildLayerCardWidget(_ZxLayerType.exam, examCardData)),
                    if (courseCardData != null) Expanded(child: _buildCourseCardWidget(courseCardData)),
                  ],
                ),
              ),
            ],
              
          ],
        );
      },
    );
  }

  Widget _buildLayerCardWidget(_ZxLayerType type, ZhenxieHomeLayerCardData data) {
    return _buildPaperCardWidget(
      onTap: () {
        if (type == _ZxLayerType.lexis) {
          TagRoutes.toNamed(Routes.ZHENXIE_LEXIS);
          return;
        }
        if (type == _ZxLayerType.syntax) {
          TagRoutes.toNamed(Routes.ZHENXIE_SYNTAX);
          return;
        }
        if (type == _ZxLayerType.discourse) {
          // ToastUtils.showToast(text: "努力建设中", type: ToastType.info);
          TagRoutes.toNamed(
            Routes.ZHENXIE_COMPOSITION_STAGES,
            arguments: {"isManagement": false},
          );
          return;
        }
        if (type == _ZxLayerType.exam) {
          // if (controller.homeData.value?.writeCourseInfo?.courseId == null) {
          //   ToastUtils.showToast(text: "努力建设中", type: ToastType.info);
          //   return;
          // }
          TagRoutes.toNamed(
            Routes.ZHENXIE_EXAM,
            arguments: {"stage": "xiaoshengchu"},
          );
          return;
        }
        _showComingSoonToast(data.toastText);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.wMin,
            children: [
              _buildSealWidget(data.title),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.subTitle,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 4.wMin,
                      color: AppTheme.cZhenxieFontSecondary.color,
                      fontFamily: AppFontValue.robotoMono,
                    ),
                  ),
                  Text(
                    data.description,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontTertiary.color,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    "进入",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cZhenxieFontSecondary.color,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/svg/public/icon_w_arrow_right.svg",
                    width: 22.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cZhenxieFontSecondary.color, BlendMode.srcIn),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 32.wMin,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8.wMin,
                    runSpacing: 8.wMin,
                    children: data.chips.map((item) {
                      return _buildChipWidget(
                        item.title,
                        item.count,
                        onTap: _buildLayerChipTap(type, item.title),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: _buildSpecimenWidget(type),
                ),
      
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCardWidget(ZhenxieHomeCourseHeaderData courseHeaderData) {
    if (UserStore.to.userInfo.value.reviewStatus) {
      return Container();
    }
    return _buildPaperCardWidget(
      isLit: true,
      onTap: () {
        controller.openWriteCourse();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSealWidget(courseHeaderData.title),
              if (courseHeaderData.title.isNotEmpty && courseHeaderData.subTitle.isNotEmpty) SizedBox(width: 12.wMin),
              if (courseHeaderData.subTitle.isNotEmpty) ...[
                Text(
                  courseHeaderData.subTitle,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 4.wMin,
                    color: AppTheme.cZhenxieFontSecondary.color,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 32.wMin),
          Text(
            courseHeaderData.levelModuleText,
            style: TextStyle(
              fontSize: 40.wMin,
              fontWeight: FontWeight.w600,
              fontFamily: AppFontValue.sourceHanSerifCN,
              color: AppTheme.cZhenxieFontPrimary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            courseHeaderData.unitText,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
          SizedBox(height: 32.wMin),
          Row(
            children: [
              Text(
                "本级进度",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary.color,
                ),
              ),
              const Spacer(),
              Text(
                "${(courseHeaderData.progress * 100).round()}%",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFontValue.robotoMono,
                  color: AppTheme.cZhenxieFontTertiary.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          Container(
            height: 4.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceLayerElevated.color,
              borderRadius: BorderRadius.circular(999.wMin),
              border: Border.all(width: 0.4.wMin, color: AppTheme.cBorderDark.color),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: courseHeaderData.progress.clamp(0.0, 1.0).toDouble(),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cZhenxieColorPrimary.color,
                    borderRadius: BorderRadius.circular(999.wMin),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 32.wMin),
          Text(
            "本模块单元",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Row(
            spacing: 8.wMin,
            children: List.generate(courseHeaderData.units.length, (index) {
              return Expanded(
                child: _buildCourseUnitBlockWidget(courseHeaderData.units[index]),
              );
            }),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Spacer(),
              ButtonWidget(
                text: courseHeaderData.hasCurrentUnit ? "继续学习" : "开始学习",
                height: 40.wMin,
                padding: EdgeInsets.symmetric(horizontal: 18.wMin),
                borderRadius: 999.wMin,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontColor: AppTheme.cSurfacePrimary.color,
                fontSize: 15.wMin,
                fontWeight: FontWeight.w700,
                sclae: 1.02,
                border: Border.all(width: 1.wMin, color: AppTheme.cZhenxieBorderPrimary.color),
                rightIcon: Padding(
                  padding: EdgeInsets.only(left: 8.wMin),
                  child: Icon(Icons.arrow_forward, size: 16.wMin, color: AppTheme.cSurfacePrimary.color),
                ),
                onTap: () {
                  controller.openWriteCourse();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 写作课单元方块：默认最淡（虚线），单元列表内为中间色，当前单元最深。
  Widget _buildCourseUnitBlockWidget(ZhenxieHomeCourseUnitData unit) {
    Color backgroundColor = Colors.transparent;
    Color borderColor = Colors.white.withValues(alpha: 0.12);
    if (unit.state == ZhenxieHomeCourseUnitState.current) {
      backgroundColor = AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.22);
      borderColor = AppTheme.cZhenxieColorPrimary.color;
    } else if (unit.state == ZhenxieHomeCourseUnitState.normal) {
      backgroundColor = AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.18);
      borderColor = AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.35);
    }
    final Widget content = Container(
      height: 38.wMin,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: backgroundColor,
        border: unit.state == ZhenxieHomeCourseUnitState.none ? null : Border.all(width: 1.wMin, color: borderColor),
      ),
      child: Text(
        unit.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cZhenxieFontTertiary.color,
        ),
      ),
    );
    if (unit.state != ZhenxieHomeCourseUnitState.none) return content;
    return DottedBorder(
      radius: Radius.circular(6.wMin),
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      color: borderColor,
      dashPattern: [3.wMin, 3.wMin],
      strokeWidth: 1.wMin,
      child: content,
    );
  }

  Widget _buildPaperCardWidget({
    required Widget child,
    required VoidCallback onTap,
    bool isLit = false,
  }) {
    return TapScaleWidget(
      sclae: 1.01,
      borderRadius: 24.wMin,
      onTap: onTap,
      backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.04),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          border: Border.all(
            color: isLit ? AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.34) : AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
        ),
        child: child,
      ),
    );
  }

  Widget _buildSealWidget(String text, {EdgeInsetsGeometry? padding}) {
    if(text.isEmpty) return Container();
    return Container(
      height: 48.wMin,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieColorSecondary.color,
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w600,
          fontFamily: AppFontValue.sourceHanSerifCN,
          color: Colors.white,
        ),
      ),
    );
  }

  VoidCallback? _buildLayerChipTap(_ZxLayerType type, String title) {
    switch (type) {
      case _ZxLayerType.lexis:
        return () => TagRoutes.toNamed(
              Routes.ZHENXIE_LEXIS,
              arguments: {"autoOpenDoorCode": _buildLexisDoorCode(title)},
            );
      case _ZxLayerType.syntax:
        return () => TagRoutes.toNamed(
              Routes.ZHENXIE_SYNTAX,
              arguments: {"autoOpenDoorCode": _buildSyntaxDoorCode(title)},
            );
      case _ZxLayerType.discourse:
        return () => TagRoutes.toNamed(
              Routes.ZHENXIE_COMPOSITION_STAGES,
              arguments: {
                "isManagement": false,
                "autoOpenDoorCode": _buildDiscourseDoorCode(title),
                "initialView": title.contains("阶梯") ? "map" : "shelf",
              },
            );
      case _ZxLayerType.exam:
        return null;
    }
  }

  String? _buildLexisDoorCode(String title) {
    if (title.contains("构词")) return "wordMorphology";
    if (title.contains("词源")) return "etymology";
    if (title.contains("对照")) return "phraseParadigm";
    if (title.contains("配对")) return "phrasePair";
    if (title.contains("搭配")) return "phraseCluster";
    if (title.contains("结构")) return "phraseStructure";
    if (title.contains("画像") || title.contains("入句")) return "phraseGrammaticalProfile";
    return null;
  }

  String? _buildSyntaxDoorCode(String title) {
    if (title.contains("金字塔")) return "pyramidPattern";
    if (title.contains("蓝图")) return "sentencePattern";
    if (title.contains("对照")) return "sentenceParadigm";
    if (title.contains("全景")) return "sentenceGrammarGrid";
    if (title.contains("配链")) return "sentenceLinking";
    return null;
  }

  String? _buildDiscourseDoorCode(String title) {
    if (title.contains("段落")) return "paragraphBlueprint";
    if (title.contains("文章")) return "articleBlueprint";
    if (title.contains("阶梯")) return "compositionStage";
    return null;
  }

  Widget _buildChipWidget(String title, int? count, {VoidCallback? onTap}) {
    final Widget child = Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color.withValues(alpha: 0.08), width: 1.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: title,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cZhenxieFontTertiary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            if (count != null) ...[
              TextSpan(
                text: " $count",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFontValue.robotoMono,
                  color: AppTheme.cZhenxieFontSecondary.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }

  Widget _buildSpecimenWidget(_ZxLayerType type) {
    switch (type) {
      case _ZxLayerType.lexis:
        return _buildLexisSpecimenWidget();
      case _ZxLayerType.syntax:
        return _buildSyntaxSpecimenWidget();
      case _ZxLayerType.discourse:
        return _buildDiscourseSpecimenWidget();
      case _ZxLayerType.exam:
        return const SizedBox.shrink();
    }
  }


  Widget _buildLexisSpecimenWidget() {
    final List<ZhenxieHomeLexisSlotRowData> rows = controller.buildLexisSlotRows();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.wMin,
      children: rows.asMap().entries.map((entry) {
        final ZhenxieHomeLexisSlotRowData row = entry.value;
        if(row.tip.isEmpty){
          return _buildMorphRowWidget(row.slots);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMorphRowWidget(row.slots),
            SizedBox(width: 24.wMin),
            Text(
              row.tip,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMorphRowWidget(List<ZhenxieHomeLexisSlotData> list) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.wMin,
      children: list.asMap().entries.map((entry) {
        final ZhenxieHomeLexisSlotData item = entry.value;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            border: item.borderColor == null ? null : Border.all(color: item.borderColor!, width: 1.wMin),
            color: item.backgroundColor ?? Colors.transparent,
          ),
          child: Text(
            item.content,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: item.textColor ?? AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.robotoMono,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSyntaxSpecimenWidget() {
    final List<ZhenxieHomeSyntaxSlotRowData> rows = controller.buildSyntaxSlotRows();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.wMin,
      children: rows.asMap().entries.map((entry) {
        return _buildSyntaxSentenceRowWidget(entry.value.slots);
      }).toList(),
    );
  }

  Widget _buildSyntaxSentenceRowWidget(List<ZhenxieHomeSyntaxSlotData> list) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12.wMin,
      children: list.asMap().entries.map((entry) {
        final ZhenxieHomeSyntaxSlotData item = entry.value;
        final Widget content = Container(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            border: item.dashed || item.color == null ? null : Border.all(color: item.color!, width: 0.8.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.role,
                style: TextStyle(
                  fontSize: 12.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary.color,
                ),
              ),
              SizedBox(height: 4.wMin),
              Text(
                item.content,
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontFamily: AppFontValue.robotoMono,
                ),
              ),
            ],
          ),
        );
        if(!item.dashed){
          return content;
        }
        return DottedBorder(
          radius: Radius.circular(10.wMin),
          borderType: BorderType.RRect,
          padding: EdgeInsets.zero,
          color: item.color ?? AppTheme.cZhenxieFontPrimary.color,
          dashPattern: [3.wMin, 3.wMin],
          strokeWidth: 0.8.wMin,
          child: content,
        );
      }).toList(),
    );
  }

  Widget _buildDiscourseSpecimenWidget() {
    final ZhenxieHomeDiscourseSpecimenData data = controller.buildDiscourseSpecimenData();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              spacing: 8.wMin,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(4, (index) {
                return _buildDiscourseBarWidget(
                  index < data.fourGenreColors.length ? data.fourGenreColors[index] : null,
                  index.isEven ? 40.wMin : 50.wMin,
                );
              }),
            ),
            SizedBox(height: 12.wMin),
            Text(
              "四文类",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
              ),
            ),
          ],
        ),
        
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(4, (index) {
                return _ZxDotWidget(
                  color: index < data.structureColors.length ? data.structureColors[index] : null,
                  hasRightSpacing: index != 3,
                );
              }),
            ),
            SizedBox(height: 12.wMin),
            Text(
              "起承转合",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
              ),
            ),
          ],
        ),
        
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStageMapGlyphWidget(data.stageColors),
            SizedBox(height: 12.wMin),
            Text(
              "阶梯 · 大关",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStageMapGlyphWidget(List<Color?> stageColors) {
    final double glyphWidth = 180.wMin;
    final double glyphHeight = 46.wMin;
    final double lineY = 23.wMin;
    final double dotSize = 14.7.wMin;
    final int dotCount = stageColors.length >= 4 ? stageColors.length : 4;
    final double horizontalInset = 12.wMin;
    final Color dividerColor = stageColors.length > 3 ? (stageColors[3] ?? Colors.transparent) : Colors.transparent;
    return SizedBox(
      width: glyphWidth,
      height: glyphHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double usableWidth = constraints.maxWidth - horizontalInset * 2 - dotSize;
          final double gap = dotCount == 1 ? 0 : usableWidth / (dotCount - 1);
          final List<double> dotPositions = List<double>.generate(dotCount, (index) => horizontalInset + gap * index);
          final List<double> dotCenters = dotPositions.map((left) => left + dotSize / 2).toList();
          final double dividerX = dotCenters.length < 2 ? dotCenters.first : (dotCenters[dotCenters.length - 2] + dotCenters.last) / 2;
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: dotCenters.first,
                right: constraints.maxWidth - dotCenters.last,
                top: lineY,
                child: Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
              ),
              Positioned(
                left: dividerX - 1.wMin,
                top: 11.wMin,
                child: Container(width: 2.wMin, height: 26.wMin, color: dividerColor.withValues(alpha: 0.8)),
              ),
              ...dotPositions.asMap().entries.map((entry) {
                final int index = entry.key;
                final double left = entry.value;
                final bool isLast = index == dotPositions.length - 1;
                final Widget dot = Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLast
                        ? Colors.transparent
                        : (index < stageColors.length ? (stageColors[index] ?? Colors.transparent) : Colors.transparent),
                  ),
                );
                return Positioned(
                  left: left,
                  top: lineY - dotSize / 2,
                  child: isLast
                      ? DottedBorder(
                          borderType: BorderType.Circle,
                          padding: EdgeInsets.zero,
                          color: Colors.white.withValues(alpha: 0.35),
                          dashPattern: [2.wMin, 2.wMin],
                          strokeWidth: 1.wMin,
                          child: dot,
                        )
                      : dot,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiscourseBarWidget(Color? color, double height) {
    return Container(
      width: 28.wMin,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: color ?? Colors.transparent,
      ),
    );
  }

  void _showComingSoonToast(String text) {
    ToastUtils.showToast(text: text);
  }
}

class _ZxDotWidget extends StatelessWidget {
  final Color? color;
  final bool hasRightSpacing;

  const _ZxDotWidget({
    required this.color,
    this.hasRightSpacing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.wMin,
      height: 16.wMin,
      margin: EdgeInsets.only(right: hasRightSpacing ? 6.wMin : 0),
      decoration: BoxDecoration(
        color: color ?? Colors.transparent,
        shape: BoxShape.circle,
      ),
    );
  }
}

enum _ZxLayerType {
  /// 词法
  lexis,
  /// 句法
  syntax,
  /// 章法
  discourse,
  /// 考点
  exam,
}
