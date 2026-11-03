import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../entities/entities.dart';
import '../https/https.dart';
import 'widgets.dart';

/// 选择语言等级
class SelectUserLanguageLevelDialog {
  /// studyZoneEnum滚动到相应的区域 [StudyZoneEnum]
  static Future<CourseLevelTierEntityList?> show({
    required BuildContext context,
    String? studyZoneEnum,
    bool showUnlocked = true,
  }) async {
    return await showCupertinoDialog<CourseLevelTierEntityList?>(
      context: context,
      builder: (context) {
        return SelectUserLanguageLevelDialogWidget(
          studyZoneEnum: studyZoneEnum,
          showUnlocked: showUnlocked,
        );
      },
    );
  }
}

class SelectUserLanguageLevelDialogWidget extends StatefulWidget {
  /// studyZoneEnum滚动到相应的区域 [StudyZoneEnum]
  final String? studyZoneEnum;
  final bool showUnlocked;

  const SelectUserLanguageLevelDialogWidget({super.key, this.studyZoneEnum, this.showUnlocked = true});

  @override
  State<SelectUserLanguageLevelDialogWidget> createState() => _SelectLanguageLevelWidgetState();
}

class _SelectLanguageLevelWidgetState extends State<SelectUserLanguageLevelDialogWidget> {
  final ScrollController scrollController = ScrollController();

  int selectedIndex = -1;

  List<CourseLevelTierEntityList> levelTierList = [];

  @override
  void initState() {
    super.initState();
    getCourseLevelTierList();
  }

  Future<void> getCourseLevelTierList() async {
    try {
      ToastUtils.showLoading();
      CourseLevelTierEntity? entity = await StudyPlanRequest.getCourseLevelTierList();
      if (entity == null) return;
      List<CourseLevelTierEntityList?> list = entity.list ?? [];
      for (var item in list) {
        if (item == null) continue;
        levelTierList.add(item);
      }
      if (mounted) setState(() {});
      scrollToStudyZone();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> scrollToStudyZone() async {
    if (widget.studyZoneEnum == null) return;
    if (UserStore.to.userInfo.value.assessmentTier == null) return;
    await Future.delayed(const Duration(milliseconds: 500));

    double offset = 0;
    for (var item in levelTierList) {
      if (item.studyZone == widget.studyZoneEnum) break;
      if (offset == 0) offset = 32.wMin;
      offset += 420.wMin + 24.wMin;
    }

    if (offset != 0) offset -= 24.wMin;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      offset = offset.clamp(0, scrollController.position.maxScrollExtent);
      scrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground.color,
      body: Center(
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 16.wMin),
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              spacing: 24.wMin,
              children: List.generate(levelTierList.length, (index) {
                return _buildLevelItem(index, levelTierList[index]);
              }),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 152.wMin + MediaQuery.of(context).padding.bottom,
        color: AppTheme.cBlackAlpha10.color,
        padding: EdgeInsets.only(left: 96.wMin, right: 96.wMin, top: 24.wMin),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ButtonWidget(
              text: "取消",
              sclae: 1.05,
              width: 180.wMin,
              height: 64.wMin,
              color: AppTheme.cBgQuaternary,
              fontColor: AppTheme.cTextPrimary.color,
              borderRadius: 12.wMin,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              onTap: () => Get.back(),
            ),
            ButtonWidget(
              text: "确认选择",
              sclae: 1.02,
              height: 64.wMin,
              width: 180.wMin,
              color: AppTheme.cSurfaceBrand,
              fontColor: AppTheme.cStaticWhite,
              borderRadius: 12.wMin,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              onTap: () {
                if (selectedIndex == -1) {
                  ToastUtils.showToast(text: "请选择等级");
                  return;
                }
                Get.back(result: levelTierList[selectedIndex]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelItem(int index, CourseLevelTierEntityList data) {
    DifficultyColor levelColor = StatusUtils.getDifficultyColorFromCefr(data.cefr);

    Color studyZoneColor;
    if (UserStore.to.userInfo.value.assessmentTier == null) {
      studyZoneColor = StatusUtils.getCefrBackgroundColor(data.cefr).color2;
    } else {
      studyZoneColor = StatusUtils.getStudyZoneColor(data.studyZone) ?? AppTheme.cTextPrimary.color;
    }

    LanguageText? comments = LearningLangUtils.getLocalLang(data.comments);
    List<LanguageText> commentList = comments != null ? [comments] : [];

    return ListAnimationWidget(
      index: index,
      verticalOffset: -100.wMin,
      child: TapScaleWidget(
        sclae: 1.02,
        onTap: () {
          if (data.disable == true && widget.showUnlocked) return;
          setState(() {
            selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26.wMin),
            border: Border.all(
              color: selectedIndex == index ? AppTheme.cBorderBrand.color : Colors.transparent,
              width: 2.wMin,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.wMin),
            child: Stack(
              children: [
                Container(
                  width: 460.wMin,
                  color: AppTheme.cBgSecondary.color,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
                        color: levelColor.color2.withValues(alpha: 0.1), // 难度等级颜色
                        child: Row(
                          children: [
                            Text(
                              "Level ${data.tier ?? ''}",
                              style: TextStyle(
                                fontSize: 56.wMin,
                                color: studyZoneColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.wMin),
                                color: studyZoneColor,
                              ),
                              child: Text(
                                data.cefr ?? "",
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.wMin),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.wMin),
                          color: AppTheme.cBgPrimary.color,
                        ),
                        height: 150.wMin,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(commentList.length, (index) {
                              return Text(
                                commentList[index].text ?? "",
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  color: AppTheme.cTextSecondary.color,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.wMin),
                      Container(height: 2.wMin, color: AppTheme.cBorderSecondary.color),
                      SizedBox(height: 32.wMin),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                        child: Wrap(
                          runSpacing: 15.wMin,
                          children: List.generate(
                            data.mappings?.length ?? 0,
                            (index) {
                              return _buildTextItemWidget(
                                LearningLangUtils.getLocalLang(data.mappings?[index]?.title)?.text ?? "",
                                data.mappings?[index]?.describe?.join('\n'),
                                levelColor.color2, // 难度等级颜色
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24.wMin),
                    ],
                  ),
                ),
                Visibility(
                  visible: (data.disable ?? false) && widget.showUnlocked,
                  child: Container(
                    width: 420.wMin,
                    color: AppTheme.cBlackAlpha50.color,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_lock_blank.svg",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextItemWidget(String name, String? describe, Color svgColor) {
    return SizedBox(
      width: 200.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Text(
            describe ?? "",
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
