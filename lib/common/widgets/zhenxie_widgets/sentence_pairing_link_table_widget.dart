import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../app/modules/management/enums/enums.dart';
import '../../../app/routes/routes.dart';
import '../../../app/routes/tag_routes.dart';
import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import '../../enum/enum.dart';
import '../../values/values.dart';
import '../widgets.dart';
import 'set_expansion_buttons_widget.dart';

class SentencePairingLinkTableWidget extends StatelessWidget {
  final SentencePairRealizationInfoEntity? fromRealization;
  final SentencePairRealizationInfoEntity? toRealization;
  final PairOrderConstraintEnum? pairOrderConstraint;
  final List<SentencePairSentenceRealizationEntity?>? realizationSetList;
  final bool isManagement;

  /// 配对链路
  const SentencePairingLinkTableWidget({
    super.key,
    this.fromRealization,
    this.toRealization,
    this.pairOrderConstraint,
    this.realizationSetList,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    SentencePairSentenceBriefEntity? from;
    SentencePairSentenceBriefEntity? to;
    if (realizationSetList != null && realizationSetList?.isNotEmpty == true) {
      from = realizationSetList?.first?.fromSentenceStruct;
      to = realizationSetList?.first?.toSentenceStruct;
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
              child: _buildContentWidget(
            realization: fromRealization,
            sentenceBrief: from,
          )),
          _buildDivWidget(),
          // SizedBox(
          //   width: 150.wMin,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       SvgPicture.asset(
          //         pairOrderConstraint == PairOrderConstraintEnum.to_before_from ? "assets/svg/public/icon_arrow_back.svg" : "assets/svg/public/icon_arrow_right.svg",
          //         width: 24.wMin,
          //       ),
          //       Text(
          //         pairOrderConstraint?.label??'',
          //         style: TextStyle(
          //           fontSize: 14.wMin,
          //           fontWeight: FontWeight.w400,
          //           color: AppTheme.cTextTertiary.color,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
              child: _buildContentWidget(
            realization: toRealization,
            sentenceBrief: to,
          )),
        ],
      ),
    );
  }

  Widget _buildDivWidget() {
    return SizedBox(
      width: 150.wMin,
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: 150.wMin,
              height: 1.5.wMin,
              color: Color(0xffEC4899).withValues(alpha: 0.55),
            ),
          ),
          Container(
            width: 32.wMin,
            height: 32.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.cBorderDefault.color,
                width: 1.5.wMin,
              ),
            ),
            child: SvgPicture.asset(
              pairOrderConstraint == PairOrderConstraintEnum.to_before_from
                  ? "assets/svg/public/icon_w_arrow_left.svg"
                  : "assets/svg/public/icon_w_arrow_right.svg",
              width: 20.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
            ),
          ),
          Expanded(
            child: Container(
              width: 150.wMin,
              height: 1.5.wMin,
              color: Color(0xffEC4899).withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget({
    SentencePairRealizationInfoEntity? realization,
    SentencePairSentenceBriefEntity? sentenceBrief,
  }) {
    final patternName = LearningLangUtils.getLocalLang(realization?.pattern?.name);

    bool isNormal = sentenceBrief?.isNormal == true;

    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBgPrimary.color,
        border: Border.all(
          color: AppTheme.cBorderDefault.color,
          width: 1.5.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SuperpositionContainerWidget(
                width: 8.wMin,
                height: 8.wMin,
                shape: BoxShape.circle,
                color: AppTheme.cTextPrimary.color,
                foregroundColor: Color(0xffEC4899).withValues(alpha: 0.55),
              ),
              SizedBox(width: 8.wMin),
              SuperpositionTextWidget(
                text: patternName?.text ?? '',
                foregroundColor: Color(0xffEC4899).withValues(alpha: 0.55),
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              if (isManagement)
                Container(
                  margin: EdgeInsets.only(left: 4.wMin),
                  child: CopyTagWidget(
                    name: "对照",
                    value: realization?.patternNid ?? '',
                    isShow: isManagement,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.wMin),
          Visibility(
            visible: sentenceBrief == null,
            child: Text(
              "暂无例句",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ),
          Visibility(
            visible: sentenceBrief != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                  children: [
                    TextSpan(text: sentenceBrief?.content ?? ''),
                    if (isManagement) ...[
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 4.wMin),
                          child: CopyTagWidget(
                            name: "句子",
                            value: sentenceBrief?.sentenceId?.toString() ?? '',
                            isShow: isManagement,
                          ),
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 4.wMin),
                          child: _buildTagWidget(
                            tagText: isNormal ? "已上架" : "未上架",
                            textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                            bgColor: isNormal
                                ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                                : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                            borderColor: isNormal
                                ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                                : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ]
                  ],
                )),
                SizedBox(height: 10.wMin),
                SelectableText(
                  sentenceBrief?.definition ?? '',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ],
            ),
          ),
        ],
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

class SentencePairingLinkDetailTableWidget extends StatelessWidget {
  final SentencePairRealizationInfoEntity? fromRealization;
  final SentencePairRealizationInfoEntity? toRealization;
  final PairOrderConstraintEnum? pairOrderConstraint;
  final List<SentencePairSentenceRealizationEntity?>? realizationSetList;
  final bool isManagement;

  /// 组上下架回调
  final void Function(SentencePairSentenceRealizationEntity? sentenceRealizationSet)? onShelfChange;

  /// 组删除回调
  final void Function(SentencePairSentenceRealizationEntity? sentenceRealizationSet)? onDelete;

  /// 句子上下架回调
  final void Function(SentencePairSentenceBriefEntity? sentenceBinding)? onSentenceShelfChange;
  final void Function(SentencePairSentenceBriefEntity? sentence)? onRefresh;

  /// 配对链路-详细表
  const SentencePairingLinkDetailTableWidget({
    this.pairOrderConstraint,
    this.realizationSetList,
    this.fromRealization,
    this.toRealization,
    this.isManagement = false,
    super.key,
    this.onShelfChange,
    this.onDelete,
    this.onSentenceShelfChange,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    List<SentencePairSentenceRealizationEntity?> sentences = realizationSetList ?? [];
    sentences.sort((a, b) {
      return (a?.order)?.compareTo(b?.order ?? 0) ?? 0;
    });
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cSurfaceLayerElevated.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeaderWidget(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(sentences.length, (index) {
              return _buildSentenceWidget(
                sentenceRealization: sentences[index],
                index: index,
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 表头
  Widget _buildTableHeaderWidget() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildBluePrintHeaderContentWidget(
              realization: fromRealization,
            ),
          ),
          Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
          SizedBox(
            width: 150.wMin,
            child: SvgPicture.asset(
              pairOrderConstraint == PairOrderConstraintEnum.to_before_from
                  ? "assets/svg/public/icon_w_arrow_left.svg"
                  : "assets/svg/public/icon_w_arrow_right.svg",
              width: 32.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
            ),
          ),
          Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
          Expanded(
            child: _buildBluePrintHeaderContentWidget(
              realization: toRealization,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluePrintHeaderContentWidget({
    SentencePairRealizationInfoEntity? realization,
  }) {
    final patternName = LearningLangUtils.getLocalLang(realization?.pattern?.name);
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText.rich(TextSpan(
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: SuperpositionContainerWidget(
                  width: 8.wMin,
                  height: 8.wMin,
                  shape: BoxShape.circle,
                  color: AppTheme.cTextPrimary,
                  foregroundColor: Color(0xffEC4899),
                  margin: EdgeInsets.only(right: 8.wMin),
                ),
              ),
              SuperpositionTextSpanWidget(
                  text: patternName?.text ?? '',
                  backgroundColor: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                  foregroundColor: Color(0xffEC4899).withValues(alpha: 0.44),
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  )),
              if (isManagement)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: EdgeInsets.only(left: 4.wMin),
                    child: CopyTagWidget(
                      name: "句型",
                      value: realization?.patternNid ?? '',
                      isShow: isManagement,
                    ),
                  ),
                ),
              // WidgetSpan(
              //   alignment: PlaceholderAlignment.middle,
              //   child: Container(
              //     margin: EdgeInsets.only(left: 4.wMin),
              //     child: ButtonWidget(
              //       text: "打开蓝图",
              //       height: 34.wMin,
              //       width: 120.wMin,
              //       padding: EdgeInsets.only(left: 10.wMin),
              //       color: AppTheme.cSurfaceLayerElevated.color,
              //       fontSize: 18.wMin,
              //       fontColor: AppTheme.cTextSecondary.color,
              //       fontWeight: FontWeight.w500,
              //       sclae: 1.03,
              //       rightIcon: SvgPicture.asset(
              //         "assets/svg/public/icon_w_arrow_right.svg",
              //         width: 20.wMin,
              //         colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              //       ),
              //       onTap: OptimizeUtils.noneThrottle(() {
              //         if(realization?.patternNid == null) return;
              //         TagRoutes.toNamed(
              //           Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS,
              //           arguments: {
              //             "nid": realization?.patternNid,
              //             "isManagement": isManagement,
              //           },
              //         );
              //       }, 1000),
              //     ),
              //   ),
              // ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildSentenceWidget({
    SentencePairSentenceRealizationEntity? sentenceRealization,
    required int index,
  }) {
    bool isNormal = sentenceRealization?.isNormal ?? false;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
            child: Row(
              children: [
                Text(
                  "配对${index + 1}",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SizedBox(width: 12.wMin),
                _buildTagWidget(
                  tagText: isNormal ? "已上架" : "未上架",
                  textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                  bgColor: isNormal
                      ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                      : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                  borderColor: isNormal
                      ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                      : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                ),
                Spacer(),
                Visibility(
                  visible: isManagement && (onShelfChange != null || onDelete != null),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceTertiary.color,
                      borderRadius: BorderRadius.circular(6.wMin),
                    ),
                    child: Row(
                      children: [
                        Visibility(
                          visible: onShelfChange != null,
                          child: ListingAndDelistingWidget(
                            value: isNormal,
                            showBorder: onDelete != null,
                            onChange: () {
                              onShelfChange?.call(sentenceRealization);
                            },
                          ),
                        ),
                        Visibility(
                          visible: onDelete != null,
                          child: Container(
                            margin: EdgeInsets.only(left: onShelfChange != null ? 8.wMin : 0),
                            child: TapScaleWidget(
                              onTap: () async {
                                onDelete?.call(sentenceRealization);
                              },
                              sclae: 1.1,
                              borderRadius: 8.wMin,
                              backColor: AppTheme.cSurfaceTertiary.color,
                              child: Container(
                                width: 50.wMin,
                                height: 40.wMin,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "assets/svg/public/icon_delete.svg",
                                  width: 24.wMin,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _buildSentenceContentWidget(sentenceRealization?.fromSentenceStruct)),
                _buildDivWidget(),
                Expanded(child: _buildSentenceContentWidget(sentenceRealization?.toSentenceStruct)),
              ],
            ),
          ),
          SizedBox(height: 12.wMin),
        ],
      ),
    );
  }

  Widget _buildDivWidget() {
    return SizedBox(
      width: 150.wMin,
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: 150.wMin,
              height: 1.5.wMin,
              color: Color(0xffEC4899).withValues(alpha: 0.55),
            ),
          ),
          Container(
            width: 32.wMin,
            height: 32.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.cBorderDefault.color,
                width: 1.5.wMin,
              ),
            ),
            child: SvgPicture.asset(
              pairOrderConstraint == PairOrderConstraintEnum.to_before_from
                  ? "assets/svg/public/icon_w_arrow_left.svg"
                  : "assets/svg/public/icon_w_arrow_right.svg",
              width: 20.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
            ),
          ),
          Expanded(
            child: Container(
              width: 150.wMin,
              height: 1.5.wMin,
              color: Color(0xffEC4899).withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceContentWidget(SentencePairSentenceBriefEntity? sentenceBrief) {
    bool isNormal = sentenceBrief?.isNormal ?? false;
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgPrimary.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cBorderDefault.color,
          width: 1.5.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                  children: [
                    TextSpan(text: sentenceBrief?.content ?? ''),
                    if (isManagement) ...[
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 4.wMin),
                          child: CopyTagWidget(
                            name: "句子",
                            value: sentenceBrief?.sentenceId?.toString() ?? '',
                            isShow: isManagement,
                          ),
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 4.wMin),
                          child: _buildTagWidget(
                            tagText: isNormal ? "已上架" : "未上架",
                            textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                            bgColor: isNormal
                                ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                                : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                            borderColor: isNormal
                                ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                                : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ],
                  ],
                )),
              ),
              Visibility(
                visible: isManagement && onSentenceShelfChange != null,
                child: ListingAndDelistingWidget(
                  value: isNormal,
                  showBorder: false,
                  onChange: () {
                    onSentenceShelfChange?.call(sentenceBrief);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          SelectableText(
            sentenceBrief?.definition ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 8.wMin),
          Container(
            alignment: Alignment.centerRight,
            child: SetExpansionButtonsWidget(
              isManagement: isManagement,
              contentId: sentenceBrief?.sentenceId,
              contentType: sentenceBrief?.contentType,
              content: sentenceBrief?.content,
              onRefresh: () {
                onRefresh?.call(sentenceBrief);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color? textColor = AppTheme.cTextSecondary,
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
          color: (borderColor ?? AppTheme.cSurfaceLayerBase.color).withValues(alpha: 0.2),
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

class SentencePairingLinkForkTableWidget extends StatelessWidget {
  final List<SentenceForkSentenceRealizationEntity?>? realizationSetList;
  final bool isManagement;
  final Widget? sentenceWidget;
  final Widget Function(SentenceForkSentenceBriefEntity? sentence)? sentenceWidgetBuilder;

  /// 配对链路-分叉
  const SentencePairingLinkForkTableWidget({
    super.key,
    this.realizationSetList,
    this.isManagement = false,
    this.sentenceWidget,
    this.sentenceWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (realizationSetList == null) {
      return Text(
        "暂无分叉",
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      );
    }
    return Column(
      // spacing: 16.wMin,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(realizationSetList!.length, (index) {
        return Container(
          margin: EdgeInsets.only(
            top: index == 0 ? 0 : 16.wMin,
          ),
          child: _buildListItemWidget(realizationSetList![index]),
        );
      }),
    );
  }

  Widget _buildListItemWidget(SentenceForkSentenceRealizationEntity? item) {
    if (item == null) return Container();
    List<SentenceForkRealizationBranchEntity?> forkToList = item.forkToList ?? [];

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: _buildContentFromWidget(item)),
          Container(
            width: 1.wMin,
            color: AppTheme.cZhenxieBorderPrimary.color,
            margin: EdgeInsets.symmetric(horizontal: 24.wMin),
          ),
          Expanded(
            child: Column(
              spacing: 24.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(forkToList.length, (index) {
                return _buildContentToWidget(forkToList[index]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentFromWidget(SentenceForkSentenceRealizationEntity? item) {
    final Widget? actionWidget = sentenceWidgetBuilder?.call(item?.forkFrom?.sentenceStruct) ?? sentenceWidget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          item?.forkFrom?.sentenceStruct?.content ?? '',
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontPrimary.color,
            fontFamily: AppFontValue.robotoMono,
          ),
        ),
        SizedBox(height: 6.wMin),
        Text(
          item?.forkFrom?.sentenceStruct?.definition ?? '',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
        if (actionWidget != null) SizedBox(height: 8.wMin),
        SizedBox(child: actionWidget),
      ],
    );
  }

  Widget _buildContentToWidget(SentenceForkRealizationBranchEntity? item) {
    final Widget? actionWidget = sentenceWidgetBuilder?.call(item?.sentenceStruct) ?? sentenceWidget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item?.sentenceStruct?.content ?? '',
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontPrimary.color,
            fontFamily: AppFontValue.robotoMono,
          ),
        ),
        Text(
          item?.sentenceStruct?.definition ?? '',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
        if (actionWidget != null) SizedBox(height: 8.wMin),
        SizedBox(child: actionWidget),
      ],
    );
  }
}

class SentencePairingLinkForkDetailsTableWidget extends StatelessWidget {
  final List<SentenceForkSentenceRealizationEntity?>? realizationSetList;
  final bool isManagement;

  /// 组上下架回调
  final void Function(SentenceForkSentenceRealizationEntity? group)? onShelfChange;

  /// 组删除回调
  final void Function(SentenceForkSentenceRealizationEntity? group)? onDelete;

  /// 句子上下架回调
  final void Function(SentenceForkSentenceBriefEntity? sentence)? onSentenceShelfChange;

  final void Function(SentenceForkSentenceBriefEntity? sentence)? onRefresh;

  /// 配对链路-分叉详细
  const SentencePairingLinkForkDetailsTableWidget({
    super.key,
    this.realizationSetList,
    this.isManagement = false,
    this.onShelfChange,
    this.onDelete,
    this.onSentenceShelfChange,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (realizationSetList == null) return Container();
    return Column(
      spacing: 16.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(realizationSetList!.length, (index) {
        return _buildListItemWidget(realizationSetList![index], index);
      }),
    );
  }

  Widget _buildListItemWidget(SentenceForkSentenceRealizationEntity? item, int index) {
    if (item == null) return Container();
    List<SentenceForkRealizationBranchEntity?> forkToList = item.forkToList ?? [];

    return Container(
      padding: EdgeInsets.all(4.wMin),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerElevated.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
            child: Row(
              children: [
                Text(
                  "分叉${index + 1}",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12.wMin),
                  child: _buildTagWidget(
                    tagText: item.isNormal ? "已上架" : "未上架",
                    textColor: item.isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                    bgColor: item.isNormal
                        ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                        : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                    borderColor: item.isNormal
                        ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                        : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                  ),
                ),
                Spacer(),
                Visibility(
                  visible: isManagement && (onShelfChange != null || onDelete != null),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceTertiary.color,
                      borderRadius: BorderRadius.circular(6.wMin),
                    ),
                    child: Row(
                      children: [
                        Visibility(
                          visible: onShelfChange != null,
                          child: ListingAndDelistingWidget(
                            value: item.isNormal,
                            showBorder: onDelete != null,
                            onChange: () {
                              onShelfChange?.call(item);
                            },
                          ),
                        ),
                        Visibility(
                          visible: onDelete != null,
                          child: Container(
                            margin: EdgeInsets.only(left: onShelfChange != null ? 8.wMin : 0),
                            child: TapScaleWidget(
                              onTap: () async {
                                onDelete?.call(item);
                              },
                              sclae: 1.1,
                              borderRadius: 8.wMin,
                              backColor: AppTheme.cSurfaceTertiary.color,
                              child: Container(
                                width: 50.wMin,
                                height: 40.wMin,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "assets/svg/public/icon_delete.svg",
                                  width: 24.wMin,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IntrinsicHeight(
            child: _SentencePairingLinkBranchRowWidget(
              gapWidth: 150.wMin,
              rightSpacing: 16.wMin,
              leftFlex: 4,
              rightFlex: 6,
              leftChild: _buildContentFromWidget(item),
              rightChildren: List.generate(forkToList.length, (index) {
                return _buildContentToWidget(forkToList[index]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentFromWidget(SentenceForkSentenceRealizationEntity? item) {
    LanguageText? patternName = LearningLangUtils.getLocalLang(item?.forkFrom?.sentenceStruct?.patternName);
    bool isNormal = item?.forkFrom?.sentenceStruct?.isNormal ?? false;
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgPrimary.color,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.5.wMin,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CopyTagWidget(
                name: "句型",
                value: item?.forkFrom?.sentenceStruct?.patternNid ?? '',
                isShow: isManagement,
              ),
              SizedBox(height: 10.wMin),
              TapScaleWidget(
                onTap: OptimizeUtils.noneThrottle(() {
                  if (item?.forkFrom?.sentenceStruct?.patternNid == null) return;
                  TagRoutes.toNamed(
                    Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS,
                    arguments: {
                      "nid": item?.forkFrom?.sentenceStruct?.patternNid,
                      "isManagement": isManagement,
                    },
                  );
                }, 1000),
                sclae: 1,
                child: Row(
                  spacing: 8.wMin,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SuperpositionContainerWidget(
                      width: 8.wMin,
                      height: 8.wMin,
                      shape: BoxShape.circle,
                      color: AppTheme.cTextPrimary.color,
                      foregroundColor: Color(0xff00BC7D),
                    ),
                    SuperpositionTextWidget(
                      text: patternName?.text ?? '',
                      foregroundColor: Color(0xff00BC7D),
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/svg/public/icon_w_arrow_right.svg",
                      width: 24.wMin,
                      colorFilter: ColorFilter.mode(Color(0xff00BC7D), BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: isManagement,
                child: Container(
                  margin: EdgeInsets.only(top: 8.wMin),
                  child: Row(
                    children: [
                      CopyTagWidget(
                        name: "句子",
                        value: item?.forkFrom?.sentenceStruct?.sentenceId?.toString() ?? '',
                        isShow: isManagement,
                      ),
                      _buildTagWidget(
                        tagText: isNormal ? "已上架" : "未上架",
                        textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                        bgColor: isNormal
                            ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                            : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                        borderColor: isNormal
                            ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                            : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                      ),
                      Spacer(),
                      Visibility(
                        visible: onSentenceShelfChange != null,
                        child: ListingAndDelistingWidget(
                          value: item?.forkFrom?.sentenceStruct?.isNormal ?? false,
                          showBorder: false,
                          onChange: () {
                            onSentenceShelfChange?.call(item?.forkFrom?.sentenceStruct);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.wMin),
              SelectableText(
                item?.forkFrom?.sentenceStruct?.content ?? '',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SelectableText(
                item?.forkFrom?.sentenceStruct?.definition ?? '',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
              SizedBox(height: 10.wMin),
              _buildTagWidget(
                tagText: "affirmative",
                textColor: AppTheme.cSurfaceWarning.color,
                bgColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                borderColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SetExpansionButtonsWidget(
              isManagement: isManagement,
              contentId: item?.forkFrom?.sentenceStruct?.sentenceId,
              contentType: KnowledgeTypeEnum.EN_SENTENCE.value,
              content: item?.forkFrom?.sentenceStruct?.content,
              onRefresh: () {
                onRefresh?.call(item?.forkFrom?.sentenceStruct);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentToWidget(SentenceForkRealizationBranchEntity? item) {
    LanguageText? patternName = LearningLangUtils.getLocalLang(item?.sentenceStruct?.patternName);

    bool isNormal = item?.sentenceStruct?.isNormal ?? false;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cBgPrimary.color,
        border: Border.all(
          color: AppTheme.cBorderDefault.color,
          width: 1.5.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              if (item?.pairNid == null) return;
              TagRoutes.toNamed(
                Routes.ZHENXIE_SENTENCE_PAIR_DETAILS,
                arguments: {
                  "nid": item?.pairNid,
                  "isManagement": isManagement,
                },
              );
            }, 1000),
            sclae: 1,
            child: Wrap(
              spacing: 4.wMin,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SuperpositionContainerWidget(
                  width: 8.wMin,
                  height: 8.wMin,
                  shape: BoxShape.circle,
                  color: AppTheme.cTextPrimary.color,
                  foregroundColor: Color(0xff00BC7D),
                ),
                SuperpositionTextWidget(
                  text: patternName?.text ?? '',
                  foregroundColor: Color(0xff00BC7D),
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 24.wMin,
                  colorFilter: ColorFilter.mode(Color(0xff00BC7D), BlendMode.srcIn),
                ),
                CopyTagWidget(
                  name: "配对",
                  value: item?.pairNid ?? '',
                  isShow: isManagement,
                ),
              ],
            ),
          ),
          Visibility(
            visible: isManagement,
            child: Container(
              margin: EdgeInsets.only(top: 8.wMin),
              child: Row(
                spacing: 4.wMin,
                children: [
                  CopyTagWidget(
                    name: "句子",
                    value: item?.sentenceId?.toString() ?? '',
                    isShow: isManagement,
                  ),
                  _buildTagWidget(
                    tagText: isNormal ? "已上架" : "未上架",
                    textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                    bgColor: isNormal
                        ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                        : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                    borderColor: isNormal
                        ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                        : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                  ),
                  Spacer(),
                  Visibility(
                    visible: onSentenceShelfChange != null,
                    child: ListingAndDelistingWidget(
                      value: item?.sentenceStruct?.isNormal ?? false,
                      showBorder: false,
                      onChange: () {
                        onSentenceShelfChange?.call(item?.sentenceStruct);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.wMin),
          SelectableText(
            item?.sentenceStruct?.content ?? '',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SelectableText(
            item?.sentenceStruct?.definition ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 8.wMin),
          Container(
            alignment: Alignment.centerRight,
            child: SetExpansionButtonsWidget(
              isManagement: isManagement,
              contentId: item?.sentenceStruct?.sentenceId,
              contentType: KnowledgeTypeEnum.EN_SENTENCE.value,
              content: item?.sentenceStruct?.content,
              onRefresh: () {
                onRefresh?.call(item?.sentenceStruct);
              },
            ),
          ),
        ],
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

/// 左右内容之间的桥接布局，负责测量两侧卡片中心点并在中间区域绘制连线。
class _SentencePairingLinkBranchRowWidget extends StatefulWidget {
  final Widget leftChild;
  final List<Widget> rightChildren;
  final double gapWidth;
  final double rightSpacing;
  final int leftFlex;
  final int rightFlex;

  const _SentencePairingLinkBranchRowWidget({
    required this.leftChild,
    required this.rightChildren,
    required this.gapWidth,
    required this.rightSpacing,
    required this.leftFlex,
    required this.rightFlex,
  });

  @override
  State<_SentencePairingLinkBranchRowWidget> createState() => _SentencePairingLinkBranchRowWidgetState();
}

class _SentencePairingLinkBranchRowWidgetState extends State<_SentencePairingLinkBranchRowWidget> {
  final GlobalKey _rowKey = GlobalKey();
  final GlobalKey _leftKey = GlobalKey();
  List<GlobalKey> _rightKeyList = [];
  double? _leftCenterY;
  List<double> _rightCenterYList = [];

  @override
  void initState() {
    super.initState();
    _resetRightKeys();
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(covariant _SentencePairingLinkBranchRowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rightChildren.length != widget.rightChildren.length) {
      _resetRightKeys();
    }
    _scheduleMeasure();
  }

  /// 等待布局完成后回收两侧组件中心点，供中间画布准确绘线。
  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureAnchorOffset();
    });
  }

  void _resetRightKeys() {
    _rightKeyList = List.generate(widget.rightChildren.length, (_) => GlobalKey());
  }

  void _measureAnchorOffset() {
    final RenderBox? rowRenderBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? leftRenderBox = _leftKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowRenderBox == null || leftRenderBox == null) return;

    final double nextLeftCenterY = _resolveCenterY(
      targetRenderBox: leftRenderBox,
      ancestorRenderBox: rowRenderBox,
    );
    final List<double> nextRightCenterYList = _rightKeyList
        .map((key) {
          final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox == null) return -1.0;
          return _resolveCenterY(
            targetRenderBox: renderBox,
            ancestorRenderBox: rowRenderBox,
          );
        })
        .where((item) => item >= 0)
        .toList();

    if (_leftCenterY != null &&
        (nextLeftCenterY - _leftCenterY!).abs() < 0.5 &&
        _isSameOffsetList(nextRightCenterYList, _rightCenterYList)) {
      return;
    }

    setState(() {
      _leftCenterY = nextLeftCenterY;
      _rightCenterYList = nextRightCenterYList;
    });
  }

  double _resolveCenterY({
    required RenderBox targetRenderBox,
    required RenderBox ancestorRenderBox,
  }) {
    final Offset offset = targetRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);
    return offset.dy + targetRenderBox.size.height / 2;
  }

  bool _isSameOffsetList(List<double> nextList, List<double> currentList) {
    if (nextList.length != currentList.length) return false;
    for (int index = 0; index < nextList.length; index++) {
      if ((nextList[index] - currentList[index]).abs() >= 0.5) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _rowKey,
      child: Row(
        children: [
          Expanded(
            flex: widget.leftFlex,
            child: KeyedSubtree(
              key: _leftKey,
              child: widget.leftChild,
            ),
          ),
          SizedBox(
            width: widget.gapWidth,
            child: _SentencePairingLinkCanvasWidget(
              gapWidth: widget.gapWidth,
              leftCenterY: _leftCenterY,
              rightCenterYList: _rightCenterYList,
            ),
          ),
          Expanded(
            flex: widget.rightFlex,
            child: Column(
              spacing: widget.rightSpacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.rightChildren.length, (index) {
                return KeyedSubtree(
                  key: _rightKeyList[index],
                  child: widget.rightChildren[index],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// 中间桥接画布，绘制连线并在交汇处放置方向箭头。
class _SentencePairingLinkCanvasWidget extends StatelessWidget {
  final double? leftCenterY;
  final List<double> rightCenterYList;
  final double gapWidth;

  const _SentencePairingLinkCanvasWidget({
    required this.leftCenterY,
    required this.rightCenterYList,
    required this.gapWidth,
  });

  @override
  Widget build(BuildContext context) {
    final double circleSize = 32.wMin;
    final double circleRadius = circleSize / 2;
    final double circleCenterX = ((gapWidth - circleSize) / 2) + circleRadius;
    final double centerY = math.max(circleRadius, leftCenterY ?? circleRadius);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _SentencePairingLinkCanvasPainter(
              centerY: centerY,
              rightCenterYList: rightCenterYList,
              circleCenterX: circleCenterX,
            ),
          ),
        ),
        Positioned(
          left: circleCenterX - circleRadius,
          top: math.max(0, centerY - circleRadius),
          child: Container(
            width: circleSize,
            height: circleSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(
                color: Color(0xff00BC7D).withValues(alpha: 0.55),
                width: 1.5.wMin,
              ),
            ),
            child: SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 20.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }
}

/// 负责绘制左右组件之间的分叉连线路径。
class _SentencePairingLinkCanvasPainter extends CustomPainter {
  final double centerY;
  final List<double> rightCenterYList;
  final double circleCenterX;

  const _SentencePairingLinkCanvasPainter({
    required this.centerY,
    required this.rightCenterYList,
    required this.circleCenterX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final Paint paint = Paint()
      ..color = Color(0xff00BC7D).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5.wMin
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, centerY), Offset(circleCenterX, centerY), paint);

    for (final double item in rightCenterYList) {
      _drawBranchPath(
        canvas: canvas,
        paint: paint,
        size: size,
        targetY: (item.clamp(0.0, size.height) as num).toDouble(),
      );
    }
  }

  void _drawBranchPath({
    required Canvas canvas,
    required Paint paint,
    required Size size,
    required double targetY,
  }) {
    final double deltaY = targetY - centerY;
    if (deltaY.abs() < 0.5) {
      canvas.drawLine(Offset(circleCenterX, centerY), Offset(size.width, targetY), paint);
      return;
    }

    final double cornerRadius = math.min(
      12.wMin,
      math.min(deltaY.abs(), math.max(0, size.width - circleCenterX)),
    );
    final double verticalEndY = targetY > centerY ? targetY - cornerRadius : targetY + cornerRadius;
    final double horizontalStartX = math.min(size.width, circleCenterX + cornerRadius);
    final Path path = Path()..moveTo(circleCenterX, centerY);

    path.lineTo(circleCenterX, verticalEndY);
    path.arcToPoint(
      Offset(horizontalStartX, targetY),
      radius: Radius.circular(cornerRadius),
      clockwise: targetY < centerY,
    );
    path.lineTo(size.width, targetY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SentencePairingLinkCanvasPainter oldDelegate) {
    if ((oldDelegate.centerY - centerY).abs() >= 0.5) return true;
    if ((oldDelegate.circleCenterX - circleCenterX).abs() >= 0.5) return true;
    if (oldDelegate.rightCenterYList.length != rightCenterYList.length) return true;
    for (int index = 0; index < rightCenterYList.length; index++) {
      if ((oldDelegate.rightCenterYList[index] - rightCenterYList[index]).abs() >= 0.5) {
        return true;
      }
    }
    return false;
  }
}
