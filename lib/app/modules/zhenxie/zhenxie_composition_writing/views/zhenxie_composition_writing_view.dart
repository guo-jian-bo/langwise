import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../management/common/commons.dart';
import '../bindings/zhenxie_composition_writing_binding.dart';
import '../controllers/zhenxie_composition_writing_controller.dart';
import '../models/zhenxie_composition_writing_models.dart';
import '../../../../../common/widgets/zhenxie_widgets/zhenxie_composition_task_card_widget.dart';

class ZhenxieCompositionWritingView extends GetView<ZhenxieCompositionWritingController> {
  final String tagText;

  const ZhenxieCompositionWritingView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> toManage<T>({dynamic arguments}) async {
    final String tag = '${Routes.ZHENXIE_COMPOSITION_WRITING}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieCompositionWritingView(tagText: tag),
      binding: ZhenxieCompositionWritingBinding(tagText: tag),
      routeName: Routes.ZHENXIE_COMPOSITION_WRITING,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieCompositionWritingView(tagText: tag),
      binding: ZhenxieCompositionWritingBinding(tagText: tag),
      routeName: Routes.ZHENXIE_COMPOSITION_WRITING,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary,
      onRefresh: controller.initData,
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          SizedBox(height: 12.wMin),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.taskList.isEmpty) {
                return const Center();
              }
              if (controller.taskList.isEmpty) {
                return NotDataWidget(
                  message: controller.stageNid.isEmpty ? "暂无匹配的写作任务" : "当前阶梯暂无写作任务",
                );
              }
              return _buildListContent();
            }),
          ),
        ],
      ),
      floatingActionButton: _buildBottomBarWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBottomBarWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx(() {
        return FilterStripWidget(
          startText: controller.getResultText(),
          sorts: {...controller.filterSorts},
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
          searchSingleWidth: 420.wMin,
          onSorts: controller.onSortsChanged,
          onConditions: controller.onConditionsChanged,
          onReset: controller.onResetFilters,
          onSearch: controller.onSearch,
          onSingleClearSearch: controller.onSearch,
        );
      }),
    );
  }

  Widget _buildListContent() {
    return GridView.builder(
      controller: controller.listScrollController,
      padding: EdgeInsets.only(left: 90.wMin, right: 90.wMin, top: 6.wMin, bottom: 180.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20.wMin,
        mainAxisSpacing: 20.wMin,
        mainAxisExtent: 398.wMin,
      ),
      itemCount: controller.taskList.length,
      itemBuilder: (context, index) {
        final CompositionTaskModel task = controller.taskList[index];
        return ZhenxieCompositionTaskCardWidget(
          task: task,
          genre: controller.findGenre(task.genreNid),
          beatMap: controller.beatMap,
          beatOrderList: controller.beatNidOrderList.toList(),
          difficultyLabel: controller.getDifficultyLabel(task),
          coverUrl: controller.getTaskCoverUrl(task),
          genreColor: controller.getGenreColor(task.genreNid),
          onTap: () => controller.openTaskDetail(task),
          langTextGetter: controller.getLangText,
          beatNameGetter: controller.getBeatName,
          headLabelGetter: controller.getHeadLabel,
          tailLabelGetter: controller.getTailLabel,
          hasHeadGetter: controller.hasHead,
          hasTailGetter: controller.hasTail,
        );
      },
    );
  }
}
