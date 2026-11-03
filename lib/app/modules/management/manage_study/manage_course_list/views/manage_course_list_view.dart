import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_course_list_binding.dart';
import '../controllers/manage_course_list_controller.dart';
import '../widgets/manage_course_list_item_widget.dart';

class ManageCourseListView extends GetView<ManageCourseListController> {
  final String tagText;
  const ManageCourseListView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_COURSE_LIST}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCourseListView(tagText: tag),
      binding: ManageCourseListBinding(tag: tag),
      routeName: Routes.MANAGE_COURSE_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 450.wMin).floor();

    return ManageScaffold(
      body: Column(
        children: [
          _buildTitle(context),
          Obx(() {
            return Expanded(
                child: EasyRefresh(
              onRefresh: () {
                controller.onRefresh();
              },
              onLoad: () {
                controller.onLoadMore();
              },
              controller: controller.refreshController,
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: 20.wh, horizontal: 24.ww),
                controller: controller.courseScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24.ww,
                  mainAxisSpacing: 24.wh,
                  childAspectRatio: 375 / 200,
                ),
                itemCount: controller.courses.length,
                itemBuilder: (context, index) {
                  final data = controller.courses[index];
                  return ManageCourseListItemWidget(
                    index: index,
                    data: data,
                    onTap: () => controller.toAllCourseDetail(data),
                    onLongSecondaryTap: (child) => controller.onLongSecondaryTap(data, context, child),
                  );
                },
              ),
            ));
          })
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.wh),
        Row(
          children: [
            Gaps.getWidth(24.ww),
            Row(
              children: [
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseCreate, ManageAuthCode.courseCopy],
                  child: Obx(() {
                    return TopTabBarWidget(
                        index: 0,
                        title: '添加',
                        leftIcon: Assets.manageIconAdd,
                        isSelected: controller.filterIndex == 0,
                        onTap: (int index) {
                          controller.filterIndex = index;
                          controller.add();
                        });
                  }),
                ),
                Gaps.getWidth(12.ww),
                Builder(
                  builder: (context) {
                    return TopTabBarWidget(
                        index: 1,
                        title: '排序',
                        leftIcon: Assets.manageIconSort,
                        isSelected: controller.filterIndex == 1,
                        onTap: (int index) {
                          controller.filterIndex = index;
                          controller.toSort(context);
                        });
                  },
                ),
                Gaps.getWidth(12.ww),
                Builder(builder: (targetContext) {
                  return Obx(() {
                    return TopTabBarWidget(
                        index: 2,
                        title: '筛选',
                        leftIcon: Assets.manageIconFilter,
                        rightIcon: Assets.manageIconArrowDown,
                        isSelected: controller.filterIndex == 2,
                        onTap: (int index) {
                          controller.filterIndex = index;
                          controller.showFilter(targetContext);
                        });
                  });
                }),
                Gaps.getWidth(12.ww),
              ],
            ),
            const Spacer(),
            SearchWidget(
              width: 160.ww,
              height: 42.wh,
              hintText: 'uid',
              onChanged: (String value) {
                controller.onSetId(value);
              },
              onSubmitted: (String value) {
                controller.onSetId(value, isSubmit: true);
              },
            ),
            Gaps.getWidth(12.ww),
            SearchWidget(
              width: 160.ww,
              height: 42.wh,
              hintText: '课程名',
              onChanged: (String value) {
                controller.onSetName(value);
              },
              onSubmitted: (String value) {
                controller.onSetName(value, isSubmit: true);
              },
            ),
            Gaps.getWidth(24.ww),
          ],
        ),
      ],
    );
  }
}
