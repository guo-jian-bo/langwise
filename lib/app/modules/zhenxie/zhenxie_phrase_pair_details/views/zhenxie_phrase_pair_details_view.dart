import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/common/elements_cards/elements_type_card_widget.dart';
import '../../../elements/model/elements_detils_data_model.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_phrase_pair_details_binding.dart';
import '../controllers/zhenxie_phrase_pair_details_controller.dart';

class ZhenxiePhrasePairDetailsView extends GetView<ZhenxiePhrasePairDetailsController> {
  final String tagText;
  const ZhenxiePhrasePairDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PHRASE_PAIR_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxiePhrasePairDetailsView(tagText: tag),
      binding: ZhenxiePhrasePairDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_PAIR_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxiePhrasePairDetailsView(tagText: tag),
      binding: ZhenxiePhrasePairDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_PAIR_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getDetails();
      },
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),

          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 90.wMin,
                vertical: 24.wMin,
              ),
              child: Column(
                children: [
                  _buildTitleWidget(),
                  _buildContentWidget(),
                  SizedBox(height: 32.wMin),
                  Expanded(
                    child: Obx((){
                      PhrasePairEntity data = controller.detailData.value;
                      List<PhrasePairEntitySlots?> slots = data.pool?.slots??[];
                      return Row(
                        spacing: 8.wMin,
                        children: List.generate(slots.length, (index){
                          return _buildCardItemWidget(slots[index]);
                        }),
                      );
                    }),
                  ),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Obx((){
      PhrasePairEntity data = controller.detailData.value;
      ConfigController configController = Get.find<ConfigController>();
      DifficultieEntity? min = DifficultieUtils.getLanguageDifficultieLevel(
        configController.appConfig.value,
        "en",
        data.difficulty?.min,
      );
      DifficultieEntity? max = DifficultieUtils.getLanguageDifficultieLevel(
        configController.appConfig.value,
        "en",
        data.difficulty?.max,
      );
      int pairCount = data.pairCount??0;
      
      return Row(
        children: [
          Text(
            data.pairTypeNameZh??'',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(width: 16.wMin),
          Spacer(),
          _buildTagWidget(
            tagText: data.relationDirection??'',
          ),
          SizedBox(width: 6.wMin),
          _buildTagWidget(
            tagText: "${min?.name?.text??''} - ${max?.name?.text??''}",
          ),
          SizedBox(width: 6.wMin),
          _buildTagWidget(
            tagText: "$pairCount对",
            textColor: pairCount == 0 ? AppTheme.cTextSecondary.color : AppTheme.cSurfaceSuccess.color,
            bgColor: pairCount == 0 ? AppTheme.cSurfaceLayerBase.color : AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12), 
            borderColor: pairCount == 0 ? AppTheme.cBorderThin.color : AppTheme.cBorderSubtle.color.withValues(alpha: 0.2),
          ),
        ],
      );
    });
  }

  Widget _buildContentWidget(){
    return Obx((){
      PhrasePairEntity data = controller.detailData.value;
      final name = LearningLangUtils.getLocalLang(data.name);
      final description = LearningLangUtils.getLocalLang(data.description);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.wMin),
          Row(
            children: [
              Text(
                name?.text??'',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(width: 4.wMin),
              CopyTagWidget(
                name: "配对",
                value: data.nid??'',
                isShow: controller.isManagement,
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          Text(
            description?.text??'',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCardItemWidget(PhrasePairEntitySlots? slot){
    List<PhrasePairEntitySlotsMembers?> members = slot?.members ?? [];

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.wMin),
              child: Row(
                children: [
                  Text(
                    slot?.eyebrow??'',
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "${members.length}条",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
            Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.wMin),
              child: Column(
                spacing: 16.wMin,
                children: List.generate(members.length, (index){
                  return _buildCardItemContentWidget(members[index]);
                }),
              ),
            ),
          ),

          ],
        ),
      ),
    );
  }

  Widget _buildCardItemContentWidget(PhrasePairEntitySlotsMembers? member){
    if(member?.contentCard?.contentId == null){
      return Column(
        children: [
          Text(
            member?.surface??'',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          Text(
            "错误的句式，没有对应的卡牌",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      );
    }
    return ElementsTypeCardWidget(
      data: ElementsDetilsDataModel(
        type: member?.contentCard?.cardType ?? ElementsCardType.phrase,
        data: member?.contentCard,
      ),
    );
  }



  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }


}
