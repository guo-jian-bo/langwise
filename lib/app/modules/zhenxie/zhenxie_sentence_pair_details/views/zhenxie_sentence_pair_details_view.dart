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
import '../../../../../common/values/values.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_sentence_pair_details_binding.dart';
import '../controllers/zhenxie_sentence_pair_details_controller.dart';
import 'zhenxie_sentence_pair_details_table_widget.dart';

class ZhenxieSentencePairDetailsView extends GetView<ZhenxieSentencePairDetailsController> {
  final String tagText;
  const ZhenxieSentencePairDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 管理端入口跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_SENTENCE_PAIR_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieSentencePairDetailsView(tagText: tag),
      binding: ZhenxieSentencePairDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PAIR_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

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
              controller: controller.scrollController,
              padding: EdgeInsets.symmetric(horizontal: 90.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.wMin),
                  _buildInfoWidget(context),
                  _buildForkChainWidget(),
                  _buildWhyMatchWidget(),
                  _buildPairChainTableWidget(context),
                  SizedBox(height: 200.wMin),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFilterWidget(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context) {
    if(!controller.isManagement) return Container();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx(() {
        return FilterStripWidget(
          sorts: {...controller.filterSorts},
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
          searchSingleWidth: 480.wMin,
          onSorts: (sorts) {
            controller.filterSorts.value = sorts;
            controller.refreshExampleList();
          },
          onConditions: (conditions) {
            controller.filterConditions.value = conditions;
            controller.refreshExampleList();
          },
          onReset: (sorts, conditions) {
            controller.filterSorts.value = sorts;
            controller.filterConditions.value = conditions;
            controller.refreshExampleList();
          },
          onSearch: () {
            controller.refreshExampleList();
          },
        );
      }),
    );
  }

  /// 顶部信息区，统一到真写详情页的配色和字体系。
  Widget _buildInfoWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Obx(() {
        SentencePairEntity data = controller.pairDetail.value;
        if (data.nid == null) {
          return Container();
        }

        LanguageText? pairTypeName = LearningLangUtils.getLocalLang(data.pairType?.name);
        LanguageText? name = LearningLangUtils.getLocalLang(data.name);
        LanguageText? description = LearningLangUtils.getLocalLang(data.description);
        String practiceModeText = data.practiceModeEnum?.description ?? '';
        String practiceKindText = data.pairRacticeKindEnum?.description ?? '';
        int count = controller.total > 0 ? controller.total : controller.exampleList.length;
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
                          shape: BoxShape.circle,
                          color: Color(0xffD9D9D9),
                        ),
                      ),
                      SizedBox(width: 6.wMin),
                      Text(
                        pairTypeName?.text ?? '',
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cZhenxieFontTertiary.color,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                        ),
                      ),
                      SizedBox(width: 16.wMin),
                      CopyTagWidget(
                        name: "配对类型",
                        value: data.pairTypeNid ?? '',
                        isShow: controller.isManagement,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 4.wMin,
                    children: [
                      Text(
                        name?.text ?? '',
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cZhenxieFontPrimary.color,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                        ),
                      ),
                      CopyTagWidget(
                        name: "配对",
                        value: data.nid ?? '',
                        isShow: controller.isManagement,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.wMin),
                  Text(
                    description?.text ?? '',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontTertiary.color,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTagWidget(tagText: practiceModeText),
                Visibility(
                  visible: practiceKindText.isNotEmpty,
                  child: Container(
                    margin: EdgeInsets.only(top: 6.wMin),
                    child: _buildTagWidget(tagText: practiceKindText),
                  ),
                ),
                SizedBox(height: 6.wMin),
                Text(
                  count > 0 ? "$count组句对" : "待挑句",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              ],
            ),
            _buildManageButtonsWidget(context),
          ],
        );
      }),
    );
  }

  /// 头部管理按钮区，结构对齐句型对照详情页。
  Widget _buildManageButtonsWidget(BuildContext context) {
    if (!controller.isManagement) return Container();

    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      child: Row(
        children: [
          // ButtonWidget(
          //   text: "编辑句对",
          //   height: 34.wMin,
          //   padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          //   color: AppTheme.cSurfaceLayerBase.color,
          //   border: Border.all(
          //     width: 0.8.wMin,
          //     color: AppTheme.cBorderSubtle.color,
          //   ),
          //   fontSize: 18.wMin,
          //   fontColor: AppTheme.cTextPrimary.color,
          //   fontWeight: FontWeight.w500,
          //   sclae: 1.03,
          //   leftIcon: Container(
          //     margin: EdgeInsets.only(right: 6.wMin),
          //     child: SvgPicture.asset(
          //       "assets/svg/manage/icon_edit.svg",
          //       width: 16.wMin,
          //       colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
          //     ),
          //   ),
          //   onTap: OptimizeUtils.noneThrottle(() {
          //     controller.editPairSentence(context);
          //   }, 1000),
          // ),
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
          ButtonWidget(
            text: "添加一组",
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
                "assets/svg/manage/icon_add.svg",
                width: 16.wMin,
                colorFilter: ColorFilter.mode(
                    AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
            onTap: OptimizeUtils.noneThrottle(() {
              controller.addGroup();
            }, 1000),
          ),
        ],
      ),
    );
  }

  /// 配对链路表
  Widget _buildPairChainTableWidget(BuildContext context) {
    return Obx(() {
      SentencePairEntity data = controller.pairDetail.value;
      if (data.nid == null) {
        return Container();
      }
      final List<SentencePairSentenceRealizationEntity?> realizationSetList =
          controller.exampleList.map((item) => item.realization).toList();
      if (realizationSetList.isEmpty) {
        return Container();
      }

      return Container(
        margin: EdgeInsets.only(top: 32.wMin),
        child: ZhenxieSentencePairDetailsTableWidget(
          realizationSetList: realizationSetList,
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
          onRefresh: () {
            // controller.getPairDetail();
          },
        ),
      );
    });
  }

  /// 分叉链路区，沿用真写详情页的浅底卡片样式。
  Widget _buildForkChainWidget() {
    return Obx(() {
      List<SentencePairForkEntity?> forks = controller.pairDetail.value.pairForks ?? [];
      if (forks.isEmpty) return Container();
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
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            SizedBox(height: 10.wMin),
            SelectableText(
              "同一条配对可以同时出现在肯否对照和换种答法里。点进去看怎么分叉。",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            SizedBox(height: 10.wMin),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.wMin,
              children: List.generate(forks.length, (index) {
                return _buildForkChainItemWidget(forks[index]);
              }),
            ),
          ],
        ),
      );
    });
  }

  /// 分叉链路单项卡片。
  Widget _buildForkChainItemWidget(SentencePairForkEntity? fork) {
    if (fork == null) return Container();

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
                    color: AppTheme.cZhenxieFontPrimary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(right: 4.wMin),
                        child: _buildTagWidget(
                          tagText: fork.pairRacticeKindEnum?.description ?? '',
                          textColor: fork.pairRacticeKindEnum?.color,
                          bgColor: fork.pairRacticeKindEnum?.color.withValues(alpha: 0.12),
                          borderColor: fork.pairRacticeKindEnum?.color.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    TextSpan(text: name?.text ?? ''),
                  ],
                )),
                SelectableText(
                  fork.soloPairPracticeLabel ?? '',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontTertiary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
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

  /// 语义锚点映射区。
  Widget _buildWhyMatchWidget() {
    return Obx(() {
      List<SentencePairSemanticAnchorMappingEntity?> mappings = controller.pairDetail.value.semanticAnchorMappings ?? [];
      if (mappings.isEmpty) return Container();
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
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            SizedBox(height: 10.wMin),
            Wrap(
              spacing: 10.wMin,
              runSpacing: 6.wMin,
              children: List.generate(mappings.length, (index) {
                final fromSlotName = LearningLangUtils.getLocalLang(mappings[index]?.fromPatternSlot?.name);
                final toSlotName = LearningLangUtils.getLocalLang(mappings[index]?.toPatternSlot?.name);
                return _buildTagWidget(
                  tagText: "${fromSlotName?.text ?? ''} → ${toSlotName?.text ?? ''}",
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

  /// 页面内统一标签样式。
  Widget _buildTagWidget({
    required String tagText,
    Color? textColor = AppTheme.cZhenxieFontTertiary,
    Color? bgColor = AppTheme.cSurfaceLayerBase,
    Color? borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: (borderColor ?? AppTheme.cBorderThin).withValues(alpha: 0.2),
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
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ],
      ),
    );
  }
}
