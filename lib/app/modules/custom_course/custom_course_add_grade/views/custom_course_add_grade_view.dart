import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/entities/theme_style_entity.dart';
import 'package:langwise/common/enum/study_zone_enum.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/color_utils.dart';
import 'package:langwise/utils/status_utils.dart';
import 'package:langwise/utils/style_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../bindings/custom_course_add_grade_binding.dart';
import '../controllers/custom_course_add_grade_controller.dart';

class CustomCourseAddGradeView extends GetView<CustomCourseAddGradeController> {
  final String tagText;
  const CustomCourseAddGradeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => CustomCourseAddGradeView(tagText: tag),
      binding: CustomCourseAddGradeBinding(tagText: tag),
      routeName: Routes.CUSTOM_COURSE_ADD_GRADE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.cEditBookBackground,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 24.wMin),
          child: Column(
            children: [
              BreadcrumbWidget(
                actionWidget: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: UserStore.to.userInfo.value.assessmentTier != null,
                        child: Row(
                          children: [
                            _buildColorInfoItemWidget("舒适区", StudyZoneEnum.comfort),
                            SizedBox(width: 20.wMin),
                            _buildColorInfoItemWidget("学习区", StudyZoneEnum.study),
                            SizedBox(width: 20.wMin),
                            _buildColorInfoItemWidget("困难区", StudyZoneEnum.panic),
                            SizedBox(width: 20.wMin),
                            _buildColorInfoItemWidget("未定级", null),
                            SizedBox(width: 20.wMin),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.addGrade();
                        },
                        child: Container(
                          width: 176.wMin,
                          height: 60.wMin,
                          decoration: BoxDecoration(
                            color: AppTheme.cTextBrand,
                            borderRadius: BorderRadius.circular(30.wMin),
                          ),
                          child: Center(
                            child: Text(
                              "新增年级",
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: Colors.white,
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
              SizedBox(height: 70.wMin),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    controller: controller.scrollController,
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 20.wMin),
                        child: _buildAddGradeWidget(controller.levelList[index]),
                      );
                    },
                    itemCount: controller.levelList.length,
                  ),
                ),
              ),
              SizedBox(height: 70.wMin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorInfoItemWidget(String title, String? studyZoneEnum) {
    Color? color = StatusUtils.getStudyZoneColor(studyZoneEnum) ?? AppTheme.cTextPrimary.color;
    return Row(
      spacing: 4.wMin,
      children: [
        Container(
          width: 10.wMin,
          height: 10.wMin,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            color: color,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  Widget _buildAddGradeWidget(CourseLevelEntityLevelList? model) {
    Color? cefrColor;
    if (UserStore.to.userInfo.value.assessmentTier == null) {
      cefrColor = StatusUtils.getCefrBackgroundColor(model?.cefr).color2;
    } else {
      cefrColor = StatusUtils.getStudyZoneColor(model?.studyZone) ?? AppTheme.cTextPrimary.color;
    }

    return AspectRatio(
      aspectRatio: 0.6,
      child: InkWell(
        onTap: () {
          controller.addModule(model);
        },
        child: Container(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(30.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cEditBookGradeBackground,
            borderRadius: BorderRadius.circular(20.wMin),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Visibility(
                visible: model?.studyZone == StudyZoneEnum.study,
                child: Positioned(
                  left: -20.wMin,
                  top: -45.wMin,
                  child: SizedBox(
                    height: 70.wMin,
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          "assets/svg/public/icon_tag_flag.svg",
                          height: 70.wMin,
                        ),
                        Positioned(
                          top: 14.wMin,
                          left: 8.wMin,
                          child: Transform.rotate(
                            angle: -0.13,
                            child: Text(
                              "推荐起点",
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: AppTheme.cStaticWhite.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 8.wMin, right: 8.wMin),
                        decoration: BoxDecoration(
                          color: cefrColor,
                          borderRadius: BorderRadius.circular(8.0.wMin),
                        ),
                        child: Text(
                          model?.cefr ?? '',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8.wMin,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 8.wMin),
                        decoration: BoxDecoration(
                          color: cefrColor,
                          borderRadius: BorderRadius.circular(8.0.wMin),
                        ),
                        child: Text(
                          'Level ${model?.tier} ',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15.wMin,
                      ),
                      Text(
                        model?.name ?? "",
                        style: TextStyle(
                          fontSize: 40.wMin,
                          color: StatusUtils.getStudyZoneColor(model?.studyZone) ?? AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.wMin),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(15.wMin),
                      decoration: BoxDecoration(
                        color: AppTheme.cEditBookCellBackground,
                        borderRadius: BorderRadius.circular(20.wMin),
                        border: Border.all(
                          color: AppTheme.cBorderSecondary,
                          width: 1.0.wMin,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(24.wMin),
                            child: Wrap(
                              spacing: 10.wMin,
                              runSpacing: 10.wMin,
                              children: List.generate(
                                model?.tierMappings?.length ?? 0,
                                (index) {
                                  ThemeTextEntity? themeTextEntity = model?.tierMappings?[index];

                                  ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(themeTextEntity?.style);
                                  Color? bgColor = ColorUtils.parseColor(style?.backgroundColor);

                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.wMin),
                                      color: bgColor,
                                    ),
                                    child: StyleUtils.getText(themeTextEntity),
                                  );
                                },
                              ),
                            ),
                          ),
                          Center(
                            child: ClipOval(
                              child: Container(
                                color: AppTheme.cWhiteAlpha10,
                                width: 80.wMin,
                                height: 80.wMin,
                                child: SvgPicture.asset(
                                  Assets.publicIconAdd,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
