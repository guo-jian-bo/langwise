import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../https/https.dart';
import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../../app/modules/elements/common/elements_cards/elements_public_card.dart';
import '../../entities/entities.dart';

/// 知识点卡片弹窗辅助类，负责查询卡片并展示统一弹窗。
class ZhenxieKnowledgeCardHelper {
  /// 根据知识点锚点信息查询卡片并展示弹窗。
  static Future<void> showKnowledgeCard({
    required BuildContext context,
    required String? contentType,
    required int? uid,
    required int? semanticId,
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
    _showKnowledgeDialog(context: context, cardData: cardData);
  }

  /// 展示统一知识点详情弹窗。
  static Future<void> _showKnowledgeDialog({
    required BuildContext context,
    required ElementsCardEntityDatas cardData,
  }) async {
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.wMin),
                    color: AppTheme.cSurfaceSecondary.color,
                  ),
                  child: ElementsPublicCard(
                    data: cardData,
                    height: 500.wMin,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
