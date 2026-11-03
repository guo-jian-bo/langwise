import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/customized_courses_l_m_entity.dart';
import 'package:langwise/common/widgets/back_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../bindings/custom_course_manage_grade_sort_binding.dart';
import '../controllers/custom_course_manage_grade_sort_controller.dart';

class CustomCourseManageGradeSortView extends GetView<CustomCourseManageGradeSortController> {
  final String tagText;
  const CustomCourseManageGradeSortView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      CustomCourseManageGradeSortView(tagText: tag),
      binding: CustomCourseManageGradeSortBinding(tagText: tag),
      routeName: Routes.CUSTOM_COURSE_MANAGE_GRADE_SORT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 24.wMin),
          child: Column(
            children: [
              const BackWidget(title: "手动排序"),
              SizedBox(
                height: 20.wMin,
              ),
              Expanded(
                child: Obx(
                  () => ReorderableWrap(
                    spacing: 20.wMin,
                    runSpacing: 20.wMin,
                    children: controller.levelList.map((e) => _buildItem(e)).toList(),
                    onReorder: (int oldIndex, int newIndex) {
                      controller.swap(oldIndex, newIndex);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(CustomizedCoursesLMEntityListLevelList? item) {
    String moduleCount;
    if (item?.moduleList?.isNotEmpty ?? false) {
      moduleCount = '${item?.moduleList?.length ?? 0}本教材';
    } else {
      moduleCount = "暂无教材";
    }

    return Container(
      width: 300.wMin,
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20.wMin,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item?.name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 5.wMin),
              SvgPicture.asset(
                "assets/svg/manage/icon_drag.svg",
                width: 16.wMin,
                colorFilter: const ColorFilter.mode(
                  AppTheme.cTextSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cBgTertiary,
              borderRadius: BorderRadius.circular(12.wMin),
            ),
            child: Text(
              moduleCount,
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
