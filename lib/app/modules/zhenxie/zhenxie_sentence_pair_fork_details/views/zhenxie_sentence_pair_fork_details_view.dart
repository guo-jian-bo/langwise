import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
import '../bindings/zhenxie_sentence_pair_fork_details_binding.dart';
import '../controllers/zhenxie_sentence_pair_fork_details_controller.dart';
import 'zhenxie_sentence_pair_fork_details_table_widget.dart';

class ZhenxieSentencePairForkDetailsView extends GetView<ZhenxieSentencePairForkDetailsController> {
  final String tagText;
  const ZhenxieSentencePairForkDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 管理端入口跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieSentencePairForkDetailsView(tagText: tag),
      binding: ZhenxieSentencePairForkDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieSentencePairForkDetailsView(tagText: tag),
      binding: ZhenxieSentencePairForkDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getForkDetail();
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
                  _buildHowToUseWidget(),
                  _buildForkChainWidget(context),
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

  /// 顶部信息区，结构对齐真写详情页卡片布局。
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
        SentenceForkEntity data = controller.forkDetail.value;
        if (data.nid == null) {
          return Container();
        }
        LanguageText? pairTypeName = LearningLangUtils.getLocalLang(data.pairType?.name);
        LanguageText? contrastDimensionName = LearningLangUtils.getLocalLang(data.contrastDimension?.name);
        LanguageText? name = LearningLangUtils.getLocalLang(data.name);
        LanguageText? description = LearningLangUtils.getLocalLang(data.description);
        int memberCount = data.members?.length ?? 0;
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
                        "${pairTypeName?.text ?? ''} · ${contrastDimensionName?.text ?? ''}",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cZhenxieFontTertiary.color,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                        ),
                      ),
                      SizedBox(width: 16.wMin),
                      CopyTagWidget(
                        name: "维度",
                        value: data.contrastDimensionNid ?? '',
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
                        name: "分叉",
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
                Visibility(
                  visible: data.kindEnum != null,
                  child: _buildTagWidget(tagText: data.kindEnum?.description ?? ''),
                ),
                SizedBox(height: 6.wMin),
                _buildTagWidget(tagText: data.soloPairPracticeEnum?.description ?? ''),
                SizedBox(height: 6.wMin),
                Text(
                  "$memberCount种接法",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
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
          //   text: "编辑名称说明",
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
          //     controller.editNameDesc(context);
          //   }, 1000),
          // ),
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

  /// 分叉表
  Widget _buildForkChainWidget(BuildContext context) {
    return Obx(() {
      if (controller.exampleList.isEmpty) {
        return Container();
      }
      final List<ZhenxieRealizationSetsEntity?> realizationSets = controller.exampleList.map((item) {
        return ZhenxieRealizationSetsEntity(
          uid: item.uid,
          order: item.order,
          access: item.access,
          members: item.members,
        );
      }).toList();
      if (realizationSets.isEmpty) {
        return Container();
      }
      return Container(
        margin: EdgeInsets.only(top: 32.wMin),
        child: ZhenxieSentencePairForkDetailsTableWidget(
          realizationSets: realizationSets,
          isManagement: controller.isManagement,
          onShelfChange: (group) {
            controller.exampleSentenceGroupShelf(group);
          },
          onDelete: (group) {
            controller.exampleSentenceGroupDelete(context, group);
          },
          onSentenceShelfChange: (sentence) {
            controller.exampleSentenceShelf(sentence);
          },
          onRefresh: () {
            // controller.getForkDetail();
          },
        ),
      );
    });
  }

  /// 出题人怎么用
  Widget _buildHowToUseWidget() {
    if (!controller.isManagement) {
      return Container();
    }
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
            "出题人怎么用",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          SizedBox(height: 10.wMin),
          Obx(() {
            SentenceForkEntity data = controller.forkDetail.value;
            LanguageText? usage = LearningLangUtils.getLocalLang(data.usage);
            return SelectableText(
              usage?.text ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            );
          }),
        ],
      ),
    );
  }

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
