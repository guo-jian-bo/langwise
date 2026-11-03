import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../../common/elements_cards/elements_type_card_widget.dart';
import '../../../../../common/enum/elements_card_type.dart';
import '../../model/elements_detils_data_model.dart';
import '../bindings/memory_card_list_binding.dart';
import '../controllers/memory_card_list_controller.dart';

class MemoryCardListView extends GetView<MemoryCardListController> {
  final String tagText;
  const MemoryCardListView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => MemoryCardListView(tagText: tag),
      binding: MemoryCardListBinding(tagText: tag),
      routeName: Routes.MEMORY_CARD_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          _buildTitleWidget(),
          Expanded(
            child: GridView.builder(
              itemCount: 210,
              padding: EdgeInsets.only(
                top: 12.wMin,
                bottom: 150.wMin + MediaQuery.of(context).padding.bottom,
                left: 40.wMin,
                right: 40.wMin,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 24.wMin,
                crossAxisSpacing: 24.wMin,
                childAspectRatio: 346 / 546,
              ),
              itemBuilder: (context, index) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return ElementsTypeCardWidget(
                      side: CardSide.BACK,
                      data: ElementsDetilsDataModel(
                        type: ElementsCardType.word,
                      ),
                      onTap: (data) {
                        controller.toCardMemoryDetil();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatButtonWidget(),
    );
  }

  Widget _buildTitleWidget(){
    return const BreadcrumbWidget(
      actionWidget: DisplayLanguageFilteringIconWidget(),
    );
  }

  Widget _buildFloatButtonWidget(){
    return TapScaleWidget(
      onTap: () {
        
      },
      sclae: 1.03,
      child: Container(
        width: 184.wMin,
        height: 72.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: AppTheme.cMemoryPrimary.color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_memory.svg",
              width: 40.wMin,
            ),
            SizedBox(width: 8.wMin),
            Text(
              "再记一遍",
              style: TextStyle(
                color: AppTheme.cStaticWhite.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
