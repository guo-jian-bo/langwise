
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
import '../widgets.dart';

class SentencePairingLinkTableWidget extends StatelessWidget {
  final SentencePairRealizationInfoEntity? fromRealization;
  final SentencePairRealizationInfoEntity? toRealization;
  final PairOrderConstraintEnum? pairOrderConstraint;
  final List<SentencePairSentenceRealizationEntity?>? realizationSetList;
  final bool showCopyTags;
  final bool isManagement;
  /// 配对链路
  const SentencePairingLinkTableWidget({
    super.key,
    this.fromRealization,
    this.toRealization,
    this.pairOrderConstraint,
    this.realizationSetList,
    this.showCopyTags = true,
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(),
          IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.cBorderSubtle.color,
                    width: 1.wMin,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildContentWidget(
                    direction: "FROM",
                    realization: fromRealization,
                    sentenceBrief: from,
                  )),
                  Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                  SizedBox(
                    width: 100.wMin,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          pairOrderConstraint == PairOrderConstraintEnum.to_before_from ? "assets/svg/public/icon_arrow_back.svg" : "assets/svg/public/icon_arrow_right.svg",
                          width: 24.wMin,
                        ),
                        Text(
                          pairOrderConstraint?.label??'',
                          style: TextStyle(
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextTertiary.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                  Expanded(child: _buildContentWidget(
                    direction: "TO",
                    realization: toRealization,
                    sentenceBrief: to,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        children: [
          Text(
            "配对链路",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          Text(
            " · ${pairOrderConstraint?.label??''}",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          const Spacer(),
          // Text(
          //   "库内句对",
          //   style: TextStyle(
          //     fontSize: 16.wMin,
          //     fontWeight: FontWeight.w400,
          //     color: AppTheme.cTextTertiary.color,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildContentWidget({
    required String direction,
    SentencePairRealizationInfoEntity? realization,
    SentencePairSentenceBriefEntity? sentenceBrief,
  }){
    final patternName = LearningLangUtils.getLocalLang(realization?.pattern?.name);

    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            direction,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),

          SelectableText.rich(TextSpan(
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
            children: [
              TextSpan(text: patternName?.text??''),
              if (showCopyTags)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: EdgeInsets.only(left: 4.wMin),
                    child: CopyTagWidget(
                      name: "对照",
                      value: realization?.patternNid??'',
                      isShow: isManagement,
                    ),
                  ),
                ),
            ],
          )),

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
                    TextSpan(text: sentenceBrief?.content??''),
                    if (showCopyTags)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 4.wMin),
                          child: CopyTagWidget(
                            name: "句子",
                            value: sentenceBrief?.sentenceId?.toString()??'',
                            isShow: isManagement,
                          ),
                        ),
                      ),
                  ],
                )),

                SizedBox(height: 10.wMin),

                SelectableText(
                  sentenceBrief?.definition??'',
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

}

class SentencePairingLinkDetailTableWidget extends StatelessWidget {
  final SentencePairRealizationInfoEntity? fromRealization;
  final SentencePairRealizationInfoEntity? toRealization;
  final PairOrderConstraintEnum? pairOrderConstraint;
  final List<SentencePairSentenceRealizationEntity?>? realizationSetList;
  final bool showCopyTags;
  final bool isManagement;

  /// 组上下架回调
  final void Function(SentencePairSentenceRealizationEntity? sentenceRealizationSet)? onShelfChange;
  /// 组删除回调
  final void Function(SentencePairSentenceRealizationEntity? sentenceRealizationSet)? onDelete;
  /// 句子上下架回调
  final void Function(SentencePairSentenceBriefEntity? sentenceBinding)? onSentenceShelfChange;

  /// 配对链路-详细表
  const SentencePairingLinkDetailTableWidget({
    this.pairOrderConstraint,
    this.realizationSetList,
    this.fromRealization,
    this.toRealization,
    this.showCopyTags = true,
    this.isManagement = false,
    super.key,
    this.onShelfChange,
    this.onDelete,
    this.onSentenceShelfChange,
  });

  @override
  Widget build(BuildContext context) {
    List<SentencePairSentenceRealizationEntity?> sentences = realizationSetList??[];
    sentences.sort((a, b){
      return (a?.order)?.compareTo(b?.order??0)??0;
    });
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(),
          _buildBluePrintHeaderWidget(),
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

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        children: [
          Text(
            "配对链路",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          Text(
            " · ${pairOrderConstraint?.label??''}",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  /// 蓝图表头
  Widget _buildBluePrintHeaderWidget(){
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildBluePrintHeaderContentWidget(
                direction: "FROM", 
                realization: fromRealization,
              ),
            ),
            Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            SizedBox(
              width: 100.wMin,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    pairOrderConstraint == PairOrderConstraintEnum.to_before_from ? "assets/svg/public/icon_arrow_back.svg" : "assets/svg/public/icon_arrow_right.svg",
                    width: 24.wMin,
                  ),
                  Text(
                    pairOrderConstraint?.label??'',
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            Expanded(
              child: _buildBluePrintHeaderContentWidget(
                direction: "TO", 
                realization: toRealization,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBluePrintHeaderContentWidget({
    required String direction,
    SentencePairRealizationInfoEntity? realization,
  }){
    final patternName = LearningLangUtils.getLocalLang(realization?.pattern?.name);
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$direction · 蓝图表头",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 8.wMin),

          SelectableText.rich(TextSpan(
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
            children: [
              TextSpan(text: patternName?.text??''),
              if (showCopyTags)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: EdgeInsets.only(left: 4.wMin),
                    child: CopyTagWidget(
                      name: "对照",
                      value: realization?.patternNid??'',
                      isShow: isManagement,
                    ),
                  ),
                ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  margin: EdgeInsets.only(left: 4.wMin),
                  child: ButtonWidget(
                    text: "打开蓝图",
                    height: 34.wMin,
                    width: 120.wMin,
                    padding: EdgeInsets.only(left: 10.wMin),
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
                      if(realization?.patternNid == null) return;
                      TagRoutes.toNamed(
                        Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS,
                        arguments: {
                          "nid": realization?.patternNid,
                          "isManagement": isManagement,
                        },
                      );
                    }, 1000),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildSentenceWidget({
    SentencePairSentenceRealizationEntity? sentenceRealization,
    required int index,
  }){
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
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
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
                            value: sentenceRealization?.isNormal ?? false,
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
          Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),          
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _buildSentenceContentWidget(sentenceRealization?.fromSentenceStruct)),
                Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                SizedBox(
                  width: 100.wMin,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        pairOrderConstraint == PairOrderConstraintEnum.to_before_from ? "assets/svg/public/icon_arrow_back.svg" : "assets/svg/public/icon_arrow_right.svg",
                        width: 24.wMin,
                      ),
                      Text(
                        "#${index + 1}",
                        style: TextStyle(
                          fontSize: 14.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                Expanded(child: _buildSentenceContentWidget(sentenceRealization?.toSentenceStruct)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceContentWidget(SentencePairSentenceBriefEntity? sentenceBrief){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SelectableText.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                  children: [
                    TextSpan(text: sentenceBrief?.content??''),
                    if (showCopyTags)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 4.wMin),
                          child: CopyTagWidget(
                            name: "句子",
                            value: sentenceBrief?.sentenceId?.toString()??'',
                            isShow: isManagement,
                          ),
                        ),
                      ),
                  ],
                )),
              ),
              Visibility(
                visible: isManagement && onSentenceShelfChange != null,
                child: ListingAndDelistingWidget(
                  value: sentenceBrief?.isNormal ?? false,
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
            sentenceBrief?.definition??'',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ),
    );
  }

}











class SentencePairingLinkForkTableWidget extends StatelessWidget {
  final bool showCopyTags;
  final List<SentenceForkSentenceRealizationEntity?>? realizationSetList;
  final bool isManagement;
  /// 配对链路-分叉
  const SentencePairingLinkForkTableWidget({
    super.key,
    this.realizationSetList,
    this.showCopyTags = true,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    if(realizationSetList == null) return Container();
    return Column(
      spacing: 16.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(realizationSetList!.length, (index){
        return _buildListItemWidget(realizationSetList![index]);
      }),
    );
  }

  Widget _buildListItemWidget(SentenceForkSentenceRealizationEntity? item){
    if(item == null) return Container();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.cBorderSubtle.color,
              width: 1.wMin,
            ),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildContentFromWidget(item),
              ),
              Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
              Expanded(
                flex: 6,
                child: _buildContentToWidget(item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentFromWidget(SentenceForkSentenceRealizationEntity? item){
    LanguageText? patternName = LearningLangUtils.getLocalLang(item?.forkFrom?.sentenceStruct?.patternName);
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "FROM",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 6.wMin),
          SelectableText(
            patternName?.text??'',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SelectableText(
            item?.forkFrom?.sentenceStruct?.content??'',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SelectableText(
            item?.forkFrom?.sentenceStruct?.definition??'',
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

  Widget _buildContentToWidget(SentenceForkSentenceRealizationEntity? item){
    List<SentenceForkRealizationBranchEntity?> forkToList = item?.forkToList??[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(forkToList.length, (index){
        final valueLabelName = LearningLangUtils.getLocalLang(forkToList[index]?.valueLabel?.name);
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.wMin),
          decoration: index == 0 ? null : BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppTheme.cBorderSubtle.color,
                width: 1.wMin,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                valueLabelName?.text ?? (forkToList[index]?.valueNid??''),
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
              SelectableText(
                forkToList[index]?.sentenceStruct?.content??'',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SelectableText(
                forkToList[index]?.sentenceStruct?.definition??'',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }


}


class SentencePairingLinkForkDetailsTableWidget extends StatelessWidget {
  final List<SentenceForkSentenceRealizationEntity?>? realizationSetList;
  final bool showCopyTags;
  final bool isManagement;

  /// 组上下架回调
  final void Function(SentenceForkSentenceRealizationEntity? group)? onShelfChange;
  /// 组删除回调
  final void Function(SentenceForkSentenceRealizationEntity? group)? onDelete;
  /// 句子上下架回调
  final void Function(SentenceForkSentenceBriefEntity? sentence)? onSentenceShelfChange;

  /// 配对链路-分叉详细
  const SentencePairingLinkForkDetailsTableWidget({
    super.key, 
    this.realizationSetList,
    this.showCopyTags = true,
    this.isManagement = false,
    this.onShelfChange,
    this.onDelete,
    this.onSentenceShelfChange,
  });

  @override
  Widget build(BuildContext context) {
    if(realizationSetList == null) return Container();
    return Column(
      spacing: 16.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(realizationSetList!.length, (index){
        return _buildListItemWidget(realizationSetList![index], index);
      }),
    );
  }
  

  Widget _buildListItemWidget(SentenceForkSentenceRealizationEntity? item, int index){
    if(item == null) return Container();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
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
          Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildContentFromWidget(item),
                ),
                Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                Expanded(
                  flex: 6,
                  child: _buildContentToWidget(item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentFromWidget(SentenceForkSentenceRealizationEntity? item){
    LanguageText? patternName = LearningLangUtils.getLocalLang(item?.forkFrom?.sentenceStruct?.patternName);
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            spacing: 4.wMin,
            children: [
              Text(
                "FROM",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
              if (showCopyTags)
                CopyTagWidget(
                  name: "句型",
                  value: item?.forkFrom?.sentenceStruct?.patternNid??'',
                  isShow: isManagement,
                ),
              Spacer(),
              Visibility(
                visible: isManagement && onSentenceShelfChange != null,
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
          SizedBox(height: 6.wMin),
          SelectableText(
            patternName?.text??'',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SelectableText(
            item?.forkFrom?.sentenceStruct?.content??'',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SelectableText(
            item?.forkFrom?.sentenceStruct?.definition??'',
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 6.wMin),
          _buildTagWidget(
            tagText: "affirmative",
            textColor: AppTheme.cSurfaceWarning.color,
            bgColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
            borderColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
          ),
          SizedBox(height: 6.wMin),
          Row(
            children: [
              ButtonWidget(
                text: "打开蓝图",
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
                  if(item?.forkFrom?.sentenceStruct?.patternNid == null) return;
                  TagRoutes.toNamed(
                    Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS,
                    arguments: {
                      "nid": item?.forkFrom?.sentenceStruct?.patternNid,
                      "isManagement": isManagement,
                    },
                  );
                }, 1000),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildContentToWidget(SentenceForkSentenceRealizationEntity? item){
    List<SentenceForkRealizationBranchEntity?> forkToList = item?.forkToList??[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(forkToList.length, (index){

        LanguageText? patternName = LearningLangUtils.getLocalLang(forkToList[index]?.sentenceStruct?.patternName);
        final valueLabelName = LearningLangUtils.getLocalLang(forkToList[index]?.valueLabel?.name);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.wMin),
          decoration: index == 0 ? null : BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppTheme.cBorderSubtle.color,
                width: 1.wMin,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 4.wMin,
                children: [
                  SelectableText(
                    valueLabelName?.text ?? (forkToList[index]?.valueNid??''),
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                  if (showCopyTags)
                    CopyTagWidget(
                      name: "配对",
                      value: forkToList[index]?.pairNid??'',
                      isShow: isManagement,
                    ),
                  const Spacer(),
                  ButtonWidget(
                    text: "打开这条配对",
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
                      if(forkToList[index]?.pairNid == null) return;
                      TagRoutes.toNamed(
                        Routes.ZHENXIE_SENTENCE_PAIR_DETAILS,
                        arguments: {
                          "nid": forkToList[index]?.pairNid,
                          "isManagement": isManagement,
                        },
                      );
                    }, 1000),
                  ),
                  Visibility(
                    visible: isManagement && onSentenceShelfChange != null,
                    child: ListingAndDelistingWidget(
                      value: forkToList[index]?.sentenceStruct?.isNormal ?? false,
                      showBorder: false,
                      onChange: () {
                        onSentenceShelfChange?.call(forkToList[index]?.sentenceStruct);
                      },
                    ),
                  ),
                ],
              ),
              SelectableText(
                patternName?.text??'',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SelectableText(
                forkToList[index]?.sentenceStruct?.content??'',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              SelectableText(
                forkToList[index]?.sentenceStruct?.definition??'',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }


  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }){
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
