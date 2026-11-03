import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_vocal_emotions_binding.dart';
import '../controllers/manage_vocal_emotions_controller.dart';
import 'manage_vocal_emotions_info_widget.dart';
import 'manage_vocal_emotions_list_card_widget.dart';

class ManageVocalEmotionsView extends GetView<ManageVocalEmotionsController> {
  final String tagText;
  const ManageVocalEmotionsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_VOCAL_EMOTIONS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageVocalEmotionsView(tagText: tag),
      binding: ManageVocalEmotionsBinding(tag: tag),
      routeName: Routes.MANAGE_VOCAL_EMOTIONS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: controller.refreshListData,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 140.wMin, vertical: 24.wMin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.wMin,
          children: [
            _buildLeftListWidget(context),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ManageVocalEmotionsInfoWidget(
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatWidget(),
    );
  }

  Widget _buildLeftListWidget(BuildContext context){
    return Container(
      width: 514.wMin,
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        children: [
          CardInputWidget(
            hintText: "搜索nid / 中英文名称",
            controller: controller.searchInput,
            textInputAction: TextInputAction.search,
            height: 54.wMin,
            valueStyle: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
            hintStyle: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
            onSubmitted: (value)  {
             controller.refreshListData();
            },
          ),
          // SizedBox(height: 10.wMin),
          Expanded(
            child: Obx((){
              if(controller.listData.isEmpty) {
                return const NotDataWidget(
                  message: "暂无数据",
                );
              }
              return ListView.separated(
                itemCount: controller.listData.length,
                controller: controller.leftScrollController,
                padding: EdgeInsets.symmetric(vertical: 10.wMin),
                separatorBuilder: (context, index) => SizedBox(height: 8.wMin),
                itemBuilder: (context, index) {
                  return ManageVocalEmotionsListCardWidget(controller: controller, index: index, data: controller.listData[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildFloatWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVoiceEmotionEdit],
          child: ButtonWidget(
            text: "新增情绪",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            height: 44.wMin,
            color: const Color(0xff00D492).withValues(alpha: 0.2),
            borderRadius: 8.wMin,
            border: Border.all(width: 1.wMin, color: const Color(0xff00D492)),
            fontColor: const Color(0xff00D492),
            fontSize: 18.wMin,
            sclae: 1.03,
            onTap: () {
              controller.addEmotions();
            },
          ),
        ),
      ],
    );
  }

}
