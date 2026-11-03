import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/enum/enum.dart';

/// 真写相关页面跳转工具。
class ZhenxieJumpUtils {
  /// 跳转真写语法组详情页。
  static Future<dynamic> toSentenceDetails({
    required ZhenxieEnSentenceType type,
    required String? nid,
    bool isManagement = false,
    bool isNeedBindRealizationSetId = false,
    int? realizationSetId,
    int? unitId,
  }) async {
    if (nid == null) return;
    if (isNeedBindRealizationSetId && realizationSetId == null) return;

    final String? route = _getSentenceGrammarDetailsRoute(type);
    if (route == null) return;

    final Map<String, dynamic> arguments = {
      "nid": nid,
      "isManagement": isManagement,
      "realizationSetId": realizationSetId,
      "unitId": unitId,
    };
    if (type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID) {
      arguments["supportsPyramid"] = true;
    }

    return await TagRoutes.toNamed(route, arguments: arguments);
  }

  /// 根据真写句组类型获取详情页路由。
  static String? _getSentenceGrammarDetailsRoute(ZhenxieEnSentenceType type) {
    if (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN || type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID) {
      return Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS;
    } else if (type == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM) {
      return Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE_DETAILS;
    } else if (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR) {
      return Routes.ZHENXIE_SENTENCE_PAIR_DETAILS;
    } else if (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK) {
      return Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS;
    } else if (type == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID) {
      return Routes.ZHENXIE_GRAMMAR_PANORAMA_DETAILS;
    }
    return null;
  }
}
