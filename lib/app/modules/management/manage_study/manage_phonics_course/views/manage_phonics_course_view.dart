import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../generated/assets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/manage_scaffold.dart';
import '../../../common/page_back_widget.dart';
import '../bindings/manage_phonics_course_binding.dart';
import '../controllers/manage_phonics_course_controller.dart';
import 'manage_phonics_course_item_widget.dart';

class ManagePhonicsCourseView extends GetView<ManagePhonicsCourseController> {
  final String tagText;
  const ManagePhonicsCourseView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态导航方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_PHONICS_COURSE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManagePhonicsCourseView(tagText: tag),
      binding: ManagePhonicsCourseBinding(tag: tag),
      routeName: Routes.MANAGE_PHONICS_COURSE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = (screenWidth / 450.wMin).floor();

        return ManageScaffold(
          body: PageBackWidget(
            child: Column(
              children: [
                _buildTitleWidget(context),
                Expanded(
                  child: Obx((){
                    return GridView.builder(
                      controller: controller.scrollController,
                      itemCount: controller.courses.length,
                      padding: EdgeInsets.symmetric(vertical: 20.wMin, horizontal: 24.wMin),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 24.wMin,
                        mainAxisSpacing: 24.wMin,
                        childAspectRatio: 375 / 200,
                      ),
                      itemBuilder: (context, index) {
                        return TapScaleLongRightWidget(
                          onTap: () {
                            controller.toCourseDetail(controller.courses[index]);
                          },
                          onLongSecondaryTap: (globalPosition, localPosition) {
                            controller.onLongSecondaryTap(
                              controller.courses[index], 
                              context, 
                              ManagePhonicsCourseItemWidget(course: controller.courses[index]),
                            );
                          },
                          sclae: 1.03,
                          key: controller.courses[index].globalKey,
                          child: ManagePhonicsCourseItemWidget(course: controller.courses[index]),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: 20.wMin),
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        children: [
          TopTabBarWidget(
            index: 0,
            title: '添加',
            leftIcon: Assets.manageIconAdd,
            onTap: (int index) {
              controller.addCourse(context);
            },
          ),
          SizedBox(width: 12.wMin),
          Builder(
            builder: (ctx) {
              return TopTabBarWidget(
                index: 1,
                title: '排序',
                leftIcon: Assets.manageIconSort,
                onTap: (int index) {
                  controller.sortCourse(ctx);
                },
              );
            }
          ),
          SizedBox(width: 12.wMin),
          Builder(
            builder: (ctx) {
              return TopTabBarWidget(
                index: 2,
                title: '筛选',
                leftIcon: Assets.manageIconFilter,
                rightIcon: Assets.manageIconArrowDown,
                onTap: (int index) {
                  controller.filterCourse(ctx);
                },
              );
            },
          ),
           const Spacer(),
          SearchWidget(
            width: 160.wMin,
            height: 42.wMin,
            hintText: 'uid',
            controller: controller.uidController,
            onSubmitted: (String value) {
              controller.refreshData();
            },
          ),
          SizedBox(width: 12.wMin),
          SearchWidget(
            width: 160.wMin,
            height: 42.wMin,
            hintText: '课程名',
            controller: controller.nameController,
            onSubmitted: (String value) {
              controller.refreshData();
            },
          ),
        ],
      ),
    );
  }
}
