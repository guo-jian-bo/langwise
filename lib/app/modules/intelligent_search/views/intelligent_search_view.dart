import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/intelligent_search_binding.dart';
import '../controllers/intelligent_search_controller.dart';
import 'intelligent_search_recommendation_widget.dart';
import 'intelligent_search_result_widget.dart';

class IntelligentSearchView extends GetView<IntelligentSearchController> {
  final String tagText;
  const IntelligentSearchView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      IntelligentSearchView(tagText: tag),
      binding: IntelligentSearchBinding(tagText: tag),
      routeName: Routes.INTELLIGENT_SEARCH,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  void _handleBack() {
    if (controller.isShowSearchResult.value) {
      controller.resetFilterConditions();
      return;
    }
    Get.back();
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: !controller.isShowSearchResult.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.resetFilterConditions();
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            backgroundColor: AppTheme.cBgPrimary.color,
            body: Container(
              alignment: Alignment.topCenter,
              
              child: Column(
                children: [
                  BreadcrumbWidget(onBack: _handleBack),
                  if (!controller.isShowSearchResult.value)
                    IntelligentSearchRecommendationWidget(controller: controller)
                  else
                    IntelligentSearchResultWidget(controller: controller),
                ],
              ),
            ),
            floatingActionButton: _buildFilterWidget(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        ),
      );
    });
  }

  
  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx((){
        return FilterStripWidget(
          width: double.infinity,
          conditions: {...controller.filterConditions},
          searchs: {...controller.filterSearchs},
          searchSingleWidth: 700.wMin,
          onConditions: (conditions) {
            controller.filterConditions.value = conditions;
            controller.onFilterConditionsChange();
          },
          onReset: (sorts, conditions) {
            controller.filterConditions.value = conditions;
            controller.resetFilterConditions();
          },
          onSearch: () {
            controller.onClickSearch();
          },
          onSingleClearSearch: () {
            controller.onClickClearSearch();
          },
        );
      }),
    );
  }




}
