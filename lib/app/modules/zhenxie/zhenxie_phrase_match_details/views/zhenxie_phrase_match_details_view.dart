import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../bindings/zhenxie_phrase_match_details_binding.dart';
import '../controllers/zhenxie_phrase_match_details_controller.dart';

class ZhenxiePhraseMatchDetailsView extends GetView<ZhenxiePhraseMatchDetailsController> {
  final String tagText;
  const ZhenxiePhraseMatchDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PHRASE_MATCH_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxiePhraseMatchDetailsView(tagText: tag),
      binding: ZhenxiePhraseMatchDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_MATCH_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxiePhraseMatchDetailsView(tagText: tag),
      binding: ZhenxiePhraseMatchDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_MATCH_DETAILS,
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
      floatingActionButton: _buildExtrasButtonWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  Widget _buildExtrasButtonWidget() {
    return Obx(() {
      final int extrasCount = controller.detailData.value.extrasCount ?? 0;
      if (extrasCount < 1) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: 12.wMin),
        child: TapScaleWidget(
          onTap: controller.toExtras,
          sclae: 1.02,
          child: Container(
            height: 64.wMin,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(

                color: AppTheme.cBorderDefault,
                width: 1.wMin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 6.wMin),
                Text(
                  "补充",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SizedBox(width: 6.wMin),
                Text(
                  "$extrasCount",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSlotsWidget(BuildContext context, List<PhraseMatchEntitySlots?> slots) {
    if (slots.isEmpty) {
      return const NotDataWidget(message: "暂无成员卡片");
    }
    final displaySlots = slots.length > 4 ? slots.sublist(0, 4) : slots;
    return Row(
      spacing: 24.wMin,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(4, (index) {
        final slot = index < displaySlots.length ? displaySlots[index] : null;
        return Expanded(
          child: slot == null ? const SizedBox.shrink() : _buildSlotSectionWidget(context, slot),
        );
      }),
    );
  }

  Widget _buildSlotSectionWidget(BuildContext context, PhraseMatchEntitySlots? slot) {
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
      PhraseMatchEntity? data = controller.detailData.value;
      ConfigController configController = Get.find<ConfigController>();
      LanguageText? name = LearningLangUtils.getLocalLang(data.name);
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
      int filledSlots = data.pool?.filledSlots??0;

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
                      data.clusterTypeNameZh??'',
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
                      name: "搭配组",
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
                tagText: "${min?.name?.text??''} - ${max?.name?.text??''}",
              ),
              SizedBox(height: 8.wMin),
              _buildTagWidget(
                tagText: "${data.pool?.totalSlots??0} 目录槽",
              ),
              SizedBox(height: 8.wMin),
              _buildTagWidget(
                tagText: "$filledSlots/${data.pool?.totalSlots??0}槽·${data.pool?.issuedCount??0}条",
                textColor: filledSlots == 0 ? AppTheme.cTextSecondary.color : AppTheme.cSurfaceSuccess.color,
                bgColor: filledSlots == 0 ? AppTheme.cSurfaceLayerBase.color : AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12),
                borderColor: filledSlots == 0 ? AppTheme.cBorderThin.color : AppTheme.cBorderSubtle.color.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildContentWidget(){
    return Obx((){
      PhraseMatchEntity? data = controller.detailData.value;
      LanguageText? description = LearningLangUtils.getLocalLang(data.description);
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

    Widget _buildSlotHeaderWidget(PhraseMatchEntitySlots? slot, int memberCount){
      return Row(
        children: [
          Text(
            slot?.role == "anchor" ? "锚点" : "教例槽",
            style: TextStyle(
              fontFamily: AppFontValue.sourceHanSerifCN,
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(width: 6.wMin),
          CopyTagWidget(
            name: "成员",
            value: slot?.eyebrowNid??'',
            isShow: controller.isManagement,
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

  Widget _buildCardItemContentWidget(PhraseMatchEntitySlotsMembers? member){
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
                "没有对应的卡牌",
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
