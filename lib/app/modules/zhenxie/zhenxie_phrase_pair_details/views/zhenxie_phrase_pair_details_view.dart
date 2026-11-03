import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/values/app_font_value.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/common/elements_cards/elements_public_card.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            BreadcrumbWidget(
              isCompatibleManage: controller.isManagement,
              actionWidget: GeneralSettingButtonWidget(
                isManagement: controller.isManagement,
              ),
            ),
          Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 90.wMin),
                child: _buildBodyWidget(context),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyWidget(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const SizedBox.shrink();
      final data = controller.detailData.value;
      final slots = data.pool?.slots ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.wMin),
          _buildTitleWidget(),
          _buildContentWidget(),
          SizedBox(height: 32.wMin),
          Expanded(child: _buildSlotsWidget(context, slots)),
          SizedBox(height: 40.wMin),
        ],
      );
    });
  }

  Widget _buildSlotsWidget(BuildContext context, List<PhrasePairEntitySlots?> slots) {
    if (slots.isEmpty) {
      return const NotDataWidget(message: "暂无成员卡片");
    }
    final displaySlots = slots.length > 4 ? slots.sublist(0, 4) : slots;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(4, (index) {
        final slot = index < displaySlots.length ? displaySlots[index] : null;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 3 ? 0 : 24.wMin),
            child: slot == null ? const SizedBox.shrink() : _buildSlotSectionWidget(context, slot),
          ),
        );
      }),
    );
  }

  Widget _buildSlotSectionWidget(BuildContext context, PhrasePairEntitySlots? slot) {
    final members = slot?.members ?? [];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        color: AppTheme.cTextPrimary.color.withValues(alpha: 0.05),
        border: Border.all(
          color: AppTheme.cTextPrimary.color.withValues(alpha: 0.08),
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.wMin, 19.wMin, 20.wMin, 15.wMin),
            child: _buildSlotHeaderWidget(slot, members.length),
          ),
          Divider(height: 1.wMin, thickness: 1.wMin, color: AppTheme.cTextPrimary.color.withValues(alpha: 0.08)),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(30.wMin, 16.wMin, 30.wMin, 19.wMin),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  return AspectRatio(
                    aspectRatio: 346 / 546,
                    child: _buildCardItemContentWidget(members[index]),
                  );
                },
                separatorBuilder: (_, __) => SizedBox(height: 12.wMin),
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
      final name = LearningLangUtils.getLocalLang(data.name);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.wMin,
                      height: 8.wMin,
                      decoration: BoxDecoration(
                        color: AppTheme.cTextSecondary.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    Text(
                      data.pairTypeNameZh??'',
                      style: TextStyle(
                        fontFamily: AppFontValue.sourceHanSerifCN,
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.wMin),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name?.text??'',
                        style: TextStyle(
                          fontFamily: AppFontValue.sourceHanSerifCN,
                          fontSize: 40.wMin,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    CopyTagWidget(
                      name: "配对",
                      value: data.nid??'',
                      isShow: controller.isManagement,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 24.wMin),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTagWidget(
                tagText: data.relationDirection??'',
              ),
              SizedBox(height: 8.wMin),
              _buildTagWidget(
                tagText: "${min?.name?.text??''} - ${max?.name?.text??''}",
              ),
              SizedBox(height: 8.wMin),
              _buildTagWidget(
                tagText: "$pairCount对",
                textColor: pairCount == 0 ? AppTheme.cTextSecondary.color : AppTheme.cSurfaceSuccess.color,
                bgColor: pairCount == 0 ? AppTheme.cSurfaceLayerBase.color : AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12), 
                borderColor: pairCount == 0 ? AppTheme.cBorderThin.color : AppTheme.cBorderSubtle.color.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildContentWidget(){
    return Obx((){
      PhrasePairEntity data = controller.detailData.value;
      final description = LearningLangUtils.getLocalLang(data.description);
      return Padding(
        padding: EdgeInsets.only(top: 12.wMin),
        child: Text(
          description?.text??'',
          style: TextStyle(
            fontFamily: AppFontValue.sourceHanSerifCN,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      );
    });
  }

    Widget _buildSlotHeaderWidget(PhrasePairEntitySlots? slot, int memberCount){
      return Row(
        children: [
          Text(
            slot?.eyebrow??'',
            style: TextStyle(
              fontFamily: AppFontValue.sourceHanSerifCN,
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          Spacer(),
          Text(
            "$memberCount条",
            style: TextStyle(
              fontFamily: AppFontValue.sourceHanSerifCN,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      );
  }

  Widget _buildCardItemContentWidget(PhrasePairEntitySlotsMembers? member){
    if(member?.contentCard?.contentId == null){
        return Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceLayerBase.color,
            border: Border.all(
              color: AppTheme.cBorderThin.color,
              width: 1.wMin,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                member?.surface??'',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              SizedBox(height: 8.wMin),
              Text(
                "错误的句式，没有对应的卡牌",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
      );
    }
    return ElementsDictReadCard(
      data: member?.contentCard,
      isManagement: controller.isManagement,
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
              fontFamily: AppFontValue.robotoMono,
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
