import 'dart:async';

import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../utils/utils.dart';

class OfficialCourseDetailsDictationCheckController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  OfficialCourseDetailsDictationCheckController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK;

  @override
  String get breadcrumbTitle => "核对答案";

  /// 知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;
  final Set<String> _cachingMediaKeys = <String>{};

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);

    if (Get.arguments != null) {
      try {
        knowledgeList.value = Get.arguments["knowledgeList"];
        unawaited(_cacheCheckAssets());
      } catch (_) {
        
      }
    }

  }

  PronunciationsEntity? _resolvePlayablePronunciation(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final List<PronunciationsEntity?> pronunciations = knowledge.pronunciations ?? [];
    for (final item in pronunciations) {
      if (item == null) continue;
      if (item.audioUrl?.isNotEmpty ?? false) {
        return item;
      }
    }
    return null;
  }

  Future<void> _cacheMediaFile(
    String? url,
    ResourceType type, {
    int? timeoutMilliseconds,
  }) async {
    final String normalizedUrl = url?.trim() ?? '';
    if (normalizedUrl.isEmpty || !GetUtils.isURL(normalizedUrl)) return;
    final String cacheKey = '${type.toString()}::$normalizedUrl';
    if (!_cachingMediaKeys.add(cacheKey)) return;
    try {
      await CacheManagerUtils.instance.getFile(
        normalizedUrl,
        type,
        timeoutMilliseconds: timeoutMilliseconds,
      );
    } finally {
      _cachingMediaKeys.remove(cacheKey);
    }
  }

  Future<void> _cacheKnowledgeAssets(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) async {
    await _cacheMediaFile(knowledge.imageUrl, ResourceType.image);
    await _cacheMediaFile(knowledge.video?.firstFrameUrl, ResourceType.image);
    await _cacheMediaFile(
      knowledge.video?.videoUrl,
      ResourceType.video,
      timeoutMilliseconds: 3000,
    );
    await _cacheMediaFile(
      _resolvePlayablePronunciation(knowledge)?.audioUrl,
      ResourceType.audio,
      timeoutMilliseconds: 3000,
    );
  }

  Future<void> _cacheCheckAssets() async {
    if (knowledgeList.isEmpty) return;
    final int immediateCount = knowledgeList.length < 9 ? knowledgeList.length : 9;
    for (int i = 0; i < immediateCount; i++) {
      await _cacheKnowledgeAssets(knowledgeList[i]);
    }
    for (int i = immediateCount; i < knowledgeList.length; i++) {
      unawaited(_cacheKnowledgeAssets(knowledgeList[i]));
    }
  }

}
