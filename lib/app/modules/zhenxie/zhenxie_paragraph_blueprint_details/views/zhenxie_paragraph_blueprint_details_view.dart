import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/zhenxie_widgets/paragraph_rhetorical_widget.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/common/elements_public_widgets.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_paragraph_blueprint_details_binding.dart';
import '../controllers/zhenxie_paragraph_blueprint_details_controller.dart';
import 'zhenxie_paragraph_blueprint_details_card_widget.dart';

class ZhenxieParagraphBlueprintDetailsView extends GetView<ZhenxieParagraphBlueprintDetailsController> {
  final String tagText;
  const ZhenxieParagraphBlueprintDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieParagraphBlueprintDetailsView(tagText: tag),
      binding: ZhenxieParagraphBlueprintDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PARAGRAPH_BLUEPRINT_DETAILS,
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
          _buildTitleWidget(context),
          SizedBox(height: 10.wMin),
          Expanded(child: _buildListWidget()),
        ],
      ),
      floatingActionButton: _buildBottomTabWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Obx((){
            final data = controller.detailData.value;
            final name = LearningLangUtils.getLocalLang(data.name);
            final description = LearningLangUtils.getLocalLang(data.description);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name?.text??'',
                  style: TextStyle(
                    fontSize: 32.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontPrimary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
                SizedBox(width: 16.wMin),
                Text(
                  description?.text??'',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontTertiary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              ],
            );
          }),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false, // 隐藏滚动条
              ),
              child: Container(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx((){
                    return ParagraphRhetoricalWidget(
                      paragraphRhetoricalList: controller.paragraphRhetoricalList.toList(),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(){
    return Obx((){
      final data = controller.detailData.value;
      final blueprints = data.blueprints??[];
      if (blueprints.isEmpty && !controller.isLoading.value) {
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
          controller: 
          controller.scrollController,
          itemCount: blueprints.length,
          padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
          separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
          itemBuilder: (context, index) {
            return ZhenxieParagraphBlueprintDetailsCardWidget(
              data: blueprints[index],
              paragraphRhetoricalList: controller.paragraphRhetoricalList.toList(),
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
        final data = controller.detailData.value;
        final blueprints = data.blueprints??[];
        if(blueprints.isEmpty) return Container();
        return ElementsSemanticBottomBar(
          items: List.generate(blueprints.length, (index){
            LanguageText? name = LearningLangUtils.getLocalLang(blueprints[index]?.name);
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
