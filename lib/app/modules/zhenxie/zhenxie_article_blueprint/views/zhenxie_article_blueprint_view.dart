import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/common/elements_public_widgets.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_article_blueprint_binding.dart';
import '../controllers/zhenxie_article_blueprint_controller.dart';
import 'zhenxie_article_blueprint_card_widget.dart';

class ZhenxieArticleBlueprintView extends GetView<ZhenxieArticleBlueprintController> {
  final String tagText;
  const ZhenxieArticleBlueprintView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 管理端入口跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_ARTICLE_BLUEPRINT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieArticleBlueprintView(tagText: tag),
      binding: ZhenxieArticleBlueprintBinding(tagText: tag),
      routeName: Routes.ZHENXIE_ARTICLE_BLUEPRINT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieArticleBlueprintView(tagText: tag),
      binding: ZhenxieArticleBlueprintBinding(tagText: tag),
      routeName: Routes.ZHENXIE_ARTICLE_BLUEPRINT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary,
      onRefresh: () {
        controller.initData();
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
            return ZhenxieArticleBlueprintCardWidget(
              data: controller.dataList[index],
              paragraphRhetoricalList: controller.paragraphRhetoricalList.toList(),
              isManagement: controller.isManagement,
              onTap: (data) {
                controller.toDetails(data);
              },
              onTapBlueprint: (data, blueprint) {
                controller.toDetails(data, blueprint: blueprint);
              },
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
            LanguageText? name = LearningLangUtils.getLocalLang(controller.dataList[index].name);
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
