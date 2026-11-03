import 'package:flutter/material.dart';
import 'package:langwise/utils/zhenxie_jump_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../entities/entities.dart';
import '../../enum/enum.dart';
import '../not_data_widget.dart';
import 'pattern_blueprint_item_widget.dart';
import 'zhenxie_grammar_panorama_item_widget.dart';
import 'zhenxie_sentence_fork_item_widget.dart';
import 'zhenxie_sentence_pair_item_widget.dart';
import 'zhenxie_sentence_pattern_compare_card_widget.dart';

/// 句组双列卡片列表，供单元目标页和句子分析页复用。
class SentenceGrammarGroupListWidget extends StatelessWidget {
  final List<CourseUnitTargetSentenceGrammarGroupEntity> list;
  final bool isManagement;
  final String emptyMessage;
  final EdgeInsetsGeometry? padding;
  /// 从单元语境进入详情时透传的 unitId，用于后续“添加一组”继续限制候选范围。
  final int? unitId;
  /// 进入详情的时候是否携带uids;
  final bool isToDetailBindRealizationSetId;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  /// 是否跳转至详情
  final bool isToDetail;
  
  const SentenceGrammarGroupListWidget({
    super.key,
    required this.list,
    this.isManagement = false,
    this.emptyMessage = '暂无数据',
    this.padding,
    this.unitId,
    this.isToDetailBindRealizationSetId = false,
    this.controller,
    this.shrinkWrap = false,
    this.isToDetail = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return NotDataWidget(message: emptyMessage);
    }

    final int rowCount = (list.length / 2).ceil();

    return ListView.separated(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: rowCount,
      padding: padding ?? EdgeInsets.only(bottom: 220.wMin, left: 90.wMin, right: 90.wMin, top: 16.wMin),
      separatorBuilder: (context, rowIndex) => SizedBox(height: 16.wMin),
      itemBuilder: (context, rowIndex) {
        final int leftIndex = rowIndex * 2;
        final int rightIndex = leftIndex + 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16.wMin,
            children: [
              Expanded(child: _buildItemWidget(list[leftIndex])),
              Expanded(
                child: rightIndex < list.length ? _buildItemWidget(list[rightIndex]) : SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemWidget(CourseUnitTargetSentenceGrammarGroupEntity item) {
    int? realizationSetId;
    if (isToDetailBindRealizationSetId) {
      final sentenceRealizationSet = item.payload?.sentenceRealizationSet ?? [];
      if (sentenceRealizationSet.isNotEmpty) {
        realizationSetId = sentenceRealizationSet.first?.uid;
      }
    }

    if (item.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN || item.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID) {
      if (item.payload?.patternBlueprintData == null) return SizedBox.shrink();
      return PatternBlueprintItemWidget(
        isManagement: isManagement,
        data: item.payload!.patternBlueprintData!,
        onTap: !isToDetail ? null : () {
          ZhenxieJumpUtils.toSentenceDetails(
            type: item.typeEnum!,
            nid: item.nid,
            isManagement: isManagement,
            isNeedBindRealizationSetId: isToDetailBindRealizationSetId,
            realizationSetId: realizationSetId,
            unitId: unitId,
          );
        },
      );
    } else if (item.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM) {
      if (item.payload?.sentencePatternCompareData == null) return SizedBox.shrink();
      return ZhenxieSentencePatternCompareCardWidget(
        isManagement: isManagement,
        data: item.payload!.sentencePatternCompareData!,
        onTap: !isToDetail ? null : (data) {
          ZhenxieJumpUtils.toSentenceDetails(
            type: item.typeEnum!,
            nid: item.nid,
            isManagement: isManagement,
            isNeedBindRealizationSetId: isToDetailBindRealizationSetId,
            realizationSetId: realizationSetId,
            unitId: unitId,
          );
        },
      );
    } else if (item.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR) {
      if (item.payload?.sentencePairData == null) return SizedBox.shrink();
      return ZhenxieSentencePairItemWidget(
        isManagement: isManagement,
        data: item.payload!.sentencePairData!,
        onTap: !isToDetail ? null : () {
          ZhenxieJumpUtils.toSentenceDetails(
            type: item.typeEnum!,
            nid: item.nid,
            isManagement: isManagement,
            isNeedBindRealizationSetId: isToDetailBindRealizationSetId,
            realizationSetId: realizationSetId,
            unitId: unitId,
          );
        },
      );
    } else if (item.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK) {
      if (item.payload?.sentenceForkData == null) return SizedBox.shrink();
      return ZhenxieSentenceForkItemWidget(
        isManagement: isManagement,
        data: item.payload!.sentenceForkData!,
        onTap: !isToDetail ? null : () {
          ZhenxieJumpUtils.toSentenceDetails(
            type: item.typeEnum!,
            nid: item.nid,
            isManagement: isManagement,
            isNeedBindRealizationSetId: isToDetailBindRealizationSetId,
            realizationSetId: realizationSetId,
            unitId: unitId,
          );
        },
      );
    } else if (item.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID) {
      if (item.payload?.grammarPanoramaData == null) return SizedBox.shrink();
      
      return ZhenxieGrammarPanoramaItemWidget(
        isManagement: isManagement,
        data: item.payload!.grammarPanoramaData!,
        onTap: !isToDetail ? null : () {
          ZhenxieJumpUtils.toSentenceDetails(
            type: item.typeEnum!,
            nid: item.nid,
            isManagement: isManagement,
            isNeedBindRealizationSetId: isToDetailBindRealizationSetId,
            realizationSetId: realizationSetId,
            unitId: unitId,
          );
        },
      );
    }
    return Container();
  }
}
