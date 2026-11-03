import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_sentence_pair_details_binding.dart';
import '../controllers/zhenxie_sentence_pair_details_controller.dart';

class ZhenxieSentencePairDetailsView extends GetView<ZhenxieSentencePairDetailsController> {
  final String tagText;
  const ZhenxieSentencePairDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieSentencePairDetailsView(tagText: tag),
      binding: ZhenxieSentencePairDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PAIR_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getPairDetail();
      },
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 90.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.wMin),
                  _buildInfoWidget(context),
                  SizedBox(height: 32.wMin),
                  _buildPairChainTableWidget(context),
                  _buildForkChainWidget(),
                  _buildWhyMatchWidget(),
                  SizedBox(height: 32.wMin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context){
    return Obx((){
      SentencePairEntity data = controller.pairDetail.value;
      LanguageText? pairTypeName = LearningLangUtils.getLocalLang(data.pairType?.name);
      LanguageText? name = LearningLangUtils.getLocalLang(data.name);
      LanguageText? description = LearningLangUtils.getLocalLang(data.description);
      int count = data.realizationSetList?.length??0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SelectableText(
                pairTypeName?.text??'',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              const Spacer(),
              ButtonWidget(
                text: "编辑名称说明",
                height: 34.wMin,
                padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
                border: Border.all(
                  width: 0.8.wMin,
                  color: AppTheme.cBorderSubtle.color,
                ),
                fontSize: 18.wMin,
                fontColor: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                leftIcon: Container(
                  margin: EdgeInsets.only(right: 6.wMin),
                  child: SvgPicture.asset(
                    "assets/svg/manage/icon_edit.svg",
                    width: 16.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                ),
                onTap: OptimizeUtils.noneThrottle(() {
                  controller.editNameDesc(context);
                }, 1000),
              ),
              SizedBox(width: 6.wMin),
              ButtonWidget(
                text: "编辑句对",
                height: 34.wMin,
                padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
                border: Border.all(
                  width: 0.8.wMin,
                  color: AppTheme.cBorderSubtle.color,
                ),
                fontSize: 18.wMin,
                fontColor: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                leftIcon: Container(
                  margin: EdgeInsets.only(right: 6.wMin),
                  child: SvgPicture.asset(
                    "assets/svg/manage/icon_edit.svg",
                    width: 16.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                ),
                onTap: OptimizeUtils.noneThrottle(() {
                  controller.editPairSentence(context);
                }, 1000),
              ),
            ],
          ),
          Row(
            spacing: 4.wMin,
            children: [
              SelectableText(
                name?.text??'',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              CopyTagWidget(
                name: "配对",
                value: data.nid??'',
                isShow: controller.isManagement,
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          SelectableText(
            description?.text??'',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Row(
            children: [
              _buildTagWidget(
                tagText: data.practiceModeEnum?.description??'',
                textColor: data.practiceModeEnum?.color,
                bgColor: data.practiceModeEnum?.color.withValues(alpha: 0.12),
                borderColor: data.practiceModeEnum?.color.withValues(alpha: 0.2),
              ),
              Visibility(
                visible: data.pairRacticeKindEnum != null,
                child: Container(
                  margin: EdgeInsets.only(left: 4.wMin),
                  child: _buildTagWidget(
                    tagText: data.pairRacticeKindEnum?.description??'',
                    textColor: data.pairRacticeKindEnum?.color,
                    bgColor: data.pairRacticeKindEnum?.color.withValues(alpha: 0.12),
                    borderColor: data.pairRacticeKindEnum?.color.withValues(alpha: 0.2),
                  ),
                ),
              ),
              SizedBox(width: 4.wMin),
              Visibility(
                visible: count > 0,
                child: _buildTagWidget(
                  tagText: "$count组句对",
                  textColor: Color(0xff22C55E),
                  bgColor: Color(0xff22C55E).withValues(alpha: 0.12),
                  borderColor: Color(0xff22C55E).withValues(alpha: 0.2),
                ),
              ),
              Visibility(
                visible: count <= 0,
                child: _buildTagWidget(
                  tagText: "待挑句",
                ),
              ),
            ],
          ),

        ],
      );
    });
  }

  /// 配对链路表
  Widget _buildPairChainTableWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: Obx((){
        SentencePairEntity data = controller.pairDetail.value;
        return SentencePairingLinkDetailTableWidget(
          pairOrderConstraint: data.orderConstraintEnum,
          realizationSetList: data.realizationSetList,
          fromRealization: data.fromRealization,
          toRealization: data.toRealization,
          isManagement: controller.isManagement,
          onShelfChange: (sentenceRealizationSet) {
            controller.exampleSentenceGroupShelf(sentenceRealizationSet);
          },
          onDelete: (sentenceRealizationSet) {
            controller.exampleSentenceGroupDelete(context, sentenceRealizationSet);
          },
          onSentenceShelfChange: (sentenceBinding) {
            controller.exampleSentenceShelf(sentenceBinding);
          },
        );
      }),
    );
  }

  /// 出现在那些分叉链路
  Widget _buildForkChainWidget(){
    return Obx((){
      List<SentencePairForkEntity?> forks = controller.pairDetail.value.pairForks??[];
      if(forks.isEmpty) return Container();
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 32.wMin),
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 0.8.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              "出现在那些分叉链路",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            SelectableText(
              "同一条配对可以同时出现在肯否对照和换种答法里。点进去看怎么分叉。",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.wMin,
              children: List.generate(forks.length, (index){
                return _buildForkChainItemWidget(forks[index]);
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildForkChainItemWidget(SentencePairForkEntity? fork){
    if(fork == null) return Container();

    final name = LearningLangUtils.getLocalLang(fork.name);

    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(right: 4.wMin),
                        child: _buildTagWidget(
                          tagText: fork.pairRacticeKindEnum?.description??'',
                          textColor: fork.pairRacticeKindEnum?.color,
                          bgColor: fork.pairRacticeKindEnum?.color.withValues(alpha: 0.12),
                          borderColor: fork.pairRacticeKindEnum?.color.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    TextSpan(text: name?.text??''),
                  ],
                )),
                SelectableText(
                  fork.soloPairPracticeLabel??'',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ],
            ),
          ),
          ButtonWidget(
            text: "打开棋盘",
            height: 34.wMin,
            padding: EdgeInsets.only(left: 12.wMin, right: 4.wMin),
            color: AppTheme.cSurfaceLayerElevated.color,
            fontSize: 18.wMin,
            fontColor: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            rightIcon: SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 20.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
            ),
            onTap: OptimizeUtils.noneThrottle(() {
              controller.toForkDetails(fork);
            }, 1000),
          ),
        ],
      ),
    );
  }

  /// 为何能配
  Widget _buildWhyMatchWidget(){
    return Obx((){
      List<SentencePairSemanticAnchorMappingEntity?> mappings = controller.pairDetail.value.semanticAnchorMappings??[];
      if(mappings.isEmpty) return Container();
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 32.wMin),
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 0.8.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              "为何能配",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            Wrap(
              spacing: 10.wMin,
              runSpacing: 6.wMin,
              children: List.generate(mappings.length, (index){
                final fromSlotName = LearningLangUtils.getLocalLang(mappings[index]?.fromPatternSlot?.name);
                final toSlotName = LearningLangUtils.getLocalLang(mappings[index]?.toPatternSlot?.name);
                return _buildTagWidget(
                  tagText: "${fromSlotName?.text??''} → ${toSlotName?.text??''}",
                  bgColor: AppTheme.cSurfaceLayerBase2.color,
                  borderColor: AppTheme.cBorderThin.color,
                );
              }),
            ),
          ],
        ),
      );
    });
  }


  Widget _buildTagWidget({
    required String tagText,
    Color? textColor = AppTheme.cTextSecondary,
    Color? bgColor = AppTheme.cSurfaceLayerBase,
    Color? borderColor = AppTheme.cBorderThin,
  }){
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: (borderColor??AppTheme.cBorderThin).withValues(alpha: 0.2),
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
