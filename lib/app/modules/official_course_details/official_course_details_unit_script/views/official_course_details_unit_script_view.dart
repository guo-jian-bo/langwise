import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhendu/widgets/zhendu_script_card_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../routes/routes.dart';
import '../bindings/official_course_details_unit_script_binding.dart';
import '../controllers/official_course_details_unit_script_controller.dart';

class OfficialCourseDetailsUnitScriptView
    extends GetView<OfficialCourseDetailsUnitScriptController> {
  final String tagText;
  const OfficialCourseDetailsUnitScriptView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      OfficialCourseDetailsUnitScriptView(tagText: tag),
      binding: OfficialCourseDetailsUnitScriptBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_UNIT_SCRIPT_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              final status = controller.loadStatus.value;
              if (status == -1) {
                return const Center();
              }
              if (status == 1) {
                return NotDataWidget(
                  message: '加载失败',
                  buttonText: '重试',
                  onButton: controller.fetchList,
                );
              }
              if (status == 4) {
                return NotDataWidget(
                  message: '暂无剧场内容',
                  buttonText: '刷新',
                  onButton: controller.fetchList,
                );
              }
              return _buildContent(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24.wMin,
        left: 40.wMin,
        right: 40.wMin,
        bottom: 20.wMin,
      ),
      child: Row(
        children: [
          const BackWidget(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: TapScaleWidget(
                        sclae: 1.02,
                        onTap: () {
                          controller.toCourseListPage();
                        },
                        child: Text(
                          controller.courseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' / ',
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary.color.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: TapScaleWidget(
                        sclae: 1.02,
                        onTap: () {
                          controller.toCourseDetailsPage();
                        },
                        child: Text(
                          controller.moduleName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' / ',
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary.color.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        controller.unitName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100.wMin ? 3 : (width >= 720.wMin ? 2 : 1);
        final paddingX = switch (columns) { 3 => 50.wMin, 2 => 64.wMin, _ => 20.wMin };
        final itemHeight = 700.wMin;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            paddingX,
            20.wMin,
            paddingX,
            40.wMin + MediaQuery.of(context).padding.bottom,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 50.wMin,
              mainAxisSpacing: 26.wMin,
              mainAxisExtent: itemHeight,
            ),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return ZhenduScriptCardWidget(
                item: item,
                coverUrl: controller.getResolvedCoverUrl(item),
                onTap: () {
                  controller.openScriptDetail(item);
                },
              );
            },
          ),
        );
      },
    );
  }
}
