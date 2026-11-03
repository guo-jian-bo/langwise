import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/elements/common/elements_cards/elements_public_card.dart';
import '../../https/https.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';

/// 知识点卡片弹窗辅助类，负责查询卡片并展示统一弹窗。
class ZhenxieKnowledgeCardHelper {
  /// 根据知识点锚点信息查询卡片并展示弹窗。
  static Future<void> showKnowledgeCard({
    required BuildContext context,
    required String? contentType,
    required int? uid,
    required int? semanticId,
    bool isManagement = false,
  }) async {
    if (contentType == null || uid == null) return;
    ElementsCardEntityDatas? cardData;
    try {
      ToastUtils.showLoading();
      final list = await LanguageUtil.getKnowledgeList(data: [
        {
          "type": contentType,
          "uid": uid,
          "semanticId": semanticId,
        },
      ]);
      if (list == null) return;
      for (final item in list) {
        if (item.contentId == uid) {
          cardData = item;
          break;
        }
      }
    } finally {
      ToastUtils.hideLoading();
    }
    if (cardData == null || !context.mounted) return;
    _showKnowledgeDialog(
      context: context,
      cardData: cardData,
      isManagement: isManagement,
    );
  }

  /// 展示统一知识点详情弹窗。
  static Future<void> _showKnowledgeDialog({
    required BuildContext context,
    required ElementsCardEntityDatas cardData,
    bool isManagement = false,
  }) async {
    final dialogCardData = _buildDictReadCardData(cardData);
    if (dialogCardData == null) return;
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(dialogContext).pop(),
          child: Material(
            type: MaterialType.transparency,
            color: Colors.transparent,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: SizedBox(
                  width: 346.wMin,
                  height: 546.wMin,
                  child: ElementsDictReadCard(
                    data: dialogCardData,
                    isManagement: isManagement,
                    onDetailBack: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 将知识点接口卡片数据转换成词典朗读卡需要的实体。
  static KnowledgeCommonEntityList? _buildDictReadCardData(ElementsCardEntityDatas cardData) {
    if ((cardData.contentType ?? '').isEmpty || cardData.contentId == null) return null;

    return KnowledgeCommonEntityList(
      contentType: cardData.contentType,
      contentId: cardData.contentId,
      content: KnowledgeCommonEntityListContent(
        type: cardData.contentType,
        uid: cardData.contentId,
        semanticId: cardData.semanticId,
      ),
      title: cardData.content,
      subTitles: (cardData.definition ?? '').isEmpty
          ? null
          : [
              LanguageText(
                lang: 'zh',
                text: cardData.definition,
              ),
            ],
      coverImage: _buildCoverImage(cardData),
      coverVideo: _buildCoverVideo(cardData),
      tags: (cardData.tags ?? [])
          .whereType<ElementsCardEntityDatasags>()
          .map(
            (item) => KnowledgeCommonEntityListGloss(
              gloss: item.gloss,
              style: item.style,
            ),
          )
          .toList(),
      memberStudy: cardData.cardStar == null
          ? null
          : KnowledgeCommonEntityListMemberStudy(
              starInfo: cardData.cardStar,
            ),
      params: _buildCardParams(cardData),
      favorited: cardData.favorited,
      pos: cardData.pos,
      posTitle: cardData.posTitle,
      access: cardData.rights,
    );
  }

  /// 构造词典卡片封面图，视频卡优先使用首帧图。
  static KnowledgeCommonEntityListCoverImage? _buildCoverImage(ElementsCardEntityDatas cardData) {
    final imageUrl = cardData.video?.firstFrameUrl ?? cardData.imageUrl;
    if ((imageUrl ?? '').isEmpty) return null;

    return KnowledgeCommonEntityListCoverImage(
      url: imageUrl,
      key: cardData.video?.firstFrameKey,
      md5: cardData.video?.firstFrameMd5,
    );
  }

  /// 构造词典卡片视频信息，供弹窗内视频卡直接播放。
  static KnowledgeCommonEntityListCoverVideo? _buildCoverVideo(ElementsCardEntityDatas cardData) {
    if ((cardData.video?.videoUrl ?? '').isEmpty) return null;

    return KnowledgeCommonEntityListCoverVideo(
      mediaId: cardData.video?.videoId,
      url: cardData.video?.videoUrl,
      key: cardData.video?.videoKey,
      md5: cardData.video?.md5,
      duration: cardData.video?.duration,
      start: cardData.video?.startSeconds?.toInt(),
      end: cardData.video?.endSeconds,
    );
  }

  /// 构造词典卡片底部的发音胶囊数据。
  static KnowledgeCommonEntityListParams? _buildCardParams(ElementsCardEntityDatas cardData) {
    final pronunciations = (cardData.pronunciations ?? [])
        .whereType<PronunciationsEntity>()
        .map((item) => Pronunciations.fromJson(item.toJson()))
        .toList();
    if (pronunciations.isEmpty) return null;

    return KnowledgeCommonEntityListParams(
      data: KnowledgeCommonEntityListParamsData(
        pronunciations: pronunciations,
      ),
    );
  }
}
