import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/course_level_tier_entity.dart';
import 'package:langwise/common/enum/study_zone_enum.dart';
import 'package:langwise/common/widgets/card_public_widgets.dart';
import 'package:langwise/common/widgets/list_animation_widget.dart';
import 'package:langwise/common/widgets/select_user_language_level_dialog.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CustomCourseManageGradeAddGradeDialog {
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required int? courseId,
    int? studyTier,
  }) async {
    return await showCupertinoDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) =>
          CustomCourseManageGradeAddGradeDialogWidget(courseId: courseId, studyTier: studyTier),
    );
  }
}

class CustomCourseManageGradeAddGradeDialogWidget extends StatefulWidget {
  final int? courseId;
  final int? studyTier;

  const CustomCourseManageGradeAddGradeDialogWidget(
      {super.key, required this.courseId, this.studyTier});

  @override
  State<CustomCourseManageGradeAddGradeDialogWidget> createState() =>
      _CustomCourseManageGradeAddGradeDialogWidgetState();
}

class _CustomCourseManageGradeAddGradeDialogWidgetState
    extends State<CustomCourseManageGradeAddGradeDialogWidget> {
  final TextEditingController courseNameInput = TextEditingController();
  int? difficulty;
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.studyTier != null) {
      difficulty = widget.studyTier;
    }
  }

  @override
  void dispose() {
    courseNameInput.dispose();
    super.dispose();
  }

  bool checkForm() {
    if (courseNameInput.text.isEmpty) {
      return false;
    }
    if (difficulty == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30.ww, vertical: 30.wh),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: AppTheme.cBgSecondary,
              ),
              width: 600.ww,
              height: 650.wh,
              child: Padding(
                padding: EdgeInsets.all(15.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '添加一个新年级',
                        style: TextStyle(
                          fontSize: 36.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 50.wMin),
                    ListAnimationWidget(
                      index: 1,
                      child: CardInputWidget(
                        title: "年级名称",
                        hintText: "请填写年级名称，例如：一年级等",
                        controller: courseNameInput,
                        enabled: true,
                        maxLength: 10,
                        onClean: () {
                          courseNameInput.clear();
                        },
                        onChanged: (value) {
                          setState(() {
                            isFormValid = checkForm();
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10.wMin),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 10.0.wMin, right: 10.0.wMin),
                      child: Text(
                        "可后续以创建更多年级",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.wMin),
                    Text(
                      "难度等级",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.wMin),
                    InkWell(
                      onTap: () async {
                        CourseLevelTierEntityList? entityList =
                            await SelectUserLanguageLevelDialog.show(
                                context: context, showUnlocked: false, studyZoneEnum: StudyZoneEnum.study,);
                        if (entityList != null) {
                          difficulty = entityList.tier;
                          isFormValid = checkForm();
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 72.wMin,
                        decoration: BoxDecoration(
                          color: AppTheme.cBgTertiary,
                          borderRadius: BorderRadius.circular(12.wMin),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.0.wMin),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: difficulty != null
                              ? Text(
                                  'Level $difficulty',
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    color: AppTheme.cTextPrimary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              : Text(
                                  "请选择难度等级",
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    color: AppTheme.cTextSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        if (isFormValid) {
                          Get.back(result: {
                            'name': courseNameInput.text,
                            'tier': difficulty,
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 72.wMin,
                        decoration: BoxDecoration(
                          color: AppTheme.cBgTertiary,
                          borderRadius: BorderRadius.circular(12.wMin),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.0.wMin),
                        child: Center(
                          child: Text(
                            "确认添加",
                            style: TextStyle(
                              fontSize: 28.wMin,
                              color: isFormValid
                                  ? AppTheme.cTextBrand
                                  : AppTheme.cTextDisabled,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20.wMin,
              right: 20.wMin,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_close.svg",
                  width: 34.wMin,
                  height: 34.wMin,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.cTextDisabled,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
