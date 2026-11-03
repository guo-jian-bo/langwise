import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/common/elements_public_widgets.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_paragraph_example_binding.dart';
import '../controllers/zhenxie_paragraph_example_controller.dart';
import 'zhenxie_paragraph_example_card_widget.dart';

class ZhenxieParagraphExampleView extends GetView<ZhenxieParagraphExampleController> {
  final String tagText;
  const ZhenxieParagraphExampleView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PARAGRAPH_BLUEPRINT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieParagraphExampleView(tagText: tag),
      binding: ZhenxieParagraphExampleBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PARAGRAPH_EXAMPLE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieParagraphExampleView(tagText: tag),
      binding: ZhenxieParagraphExampleBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PARAGRAPH_EXAMPLE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary,
      onRefresh: () {
        controller.getDataList();
      },
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          Expanded(child: _buildListWidget()),
        ],
      ),
      floatingActionButton: _buildBottomTabWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildListWidget(){
    return Obx((){
      if (controller.dataList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "暂无数据");
      }
      return ListViewObserver(
        controller: controller.scrollObserverController,
        onObserve: (result) {
          if (result.firstChild == null) return;
          int index = result.firstChild!.index;
          controller.switchTab(index);
        },
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        child: ListView.separated(
          controller: controller.scrollController,
          itemCount: controller.dataList.length,
          padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 10.wMin),
          separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
          itemBuilder: (context, index) {
            return ZhenxieParagraphExampleCardWidget(
              data: controller.dataList[index],
              isManagement: controller.isManagement,
            );
          },
        ),
      );
    });
  }

  Widget _buildBottomTabWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx((){
        if(controller.dataList.isEmpty) return Container();

        return ElementsSemanticBottomBar(
          items: List.generate(controller.dataList.length, (index){
            LanguageText? name = LearningLangUtils.getLocalLang(controller.dataList[index].paragraphType?.name);
            return SemanticChipData(id: index, text: name?.text?? '');
          }),
          currentId: controller.currentTabIndex.value,
          showFilter: false,
          isFiltered: false,
          filterColor: AppTheme.cSurfaceSuccess.color,
          onTapItem: (int index) {
            controller.switchBottomTab(index);
          },
        );
      }),
    );
  }


}
