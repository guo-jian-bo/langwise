import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../utils/manage_breadcrumb_utils.dart';

class ManageSelectUnitVocabulayController extends GetxController with ManageBreadcrumbMixin {
  /// 当前页面实例的 tag，用于面包屑和多实例隔离。
  final String tag;
  ManageSelectUnitVocabulayController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SELECT_UNIT_VOCABULAY;

  @override
  String get breadcrumbTitle => breadcrumbTitleText;

  /// 面包屑标题，默认保持原来的“选择单元词汇”。
  String breadcrumbTitleText = '选择单元词汇';

  /// 当前单元 id，用于请求管理端单元目标词汇列表。
  int? unitId;

  /// 当前页面允许选择的知识点类型。
  final RxList<String> contentTypes = <String>[
    ElementsCardType.word.value,
    ElementsCardType.phrase.value,
  ].obs;

  /// 空态文案，默认保持词汇页口径。
  String emptyText = '暂无可选词汇';

  /// 未选择时的提示文案。
  String confirmEmptyText = '请选择词汇';

  /// 页面初始化时带入的已选知识点 id 集合。
  final RxList<int> initIds = <int>[].obs;

  /// 当前单元下全部可选的单词和短语列表。
  final RxList<KnowledgeCommonEntityList> vocabularyList = <KnowledgeCommonEntityList>[].obs;

  /// 当前搜索条件下可见的词汇列表。
  final RxList<KnowledgeCommonEntityList> visibleVocabularyList = <KnowledgeCommonEntityList>[].obs;

  /// 当前已选择的知识点 id 集合。
  final RxList<int> selectedKnowledgeIds = <int>[].obs;

  /// 页面加载状态，-1=加载中，0=有数据，1=空数据。
  final RxInt loadStatus = (-1).obs;

  /// 当前底部锚点高亮的词汇类型。
  final RxString currentAnchorType = ''.obs;

  /// 列表滚动控制器，用于同步底部锚点状态。
  final ScrollController scrollController = ScrollController();

  /// 各分区的锚点 key。
  final Map<String, GlobalKey> sectionKeys = <String, GlobalKey>{
    ElementsCardType.word.value: GlobalKey(),
    ElementsCardType.phrase.value: GlobalKey(),
    ElementsCardType.sentence.value: GlobalKey(),
  };

  /// 分区展示顺序，只保留单词和短语。
  final RxList<String> sectionTypeOrder = <String>[
    ElementsCardType.word.value,
    ElementsCardType.phrase.value,
  ].obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "搜索知识点",
      controller: TextEditingController(),
    ),
  };

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    scrollController.addListener(_syncCurrentAnchorTypeByScroll);
    _initArguments();
    getVocabularyList();
  }

  @override
  void onClose() {
    scrollController.dispose();
    filterSearchs.forEach((key, value) {
      value.controller.dispose();
    });
    super.onClose();
  }

  /// 解析页面入参，提取单元 id 和初始选中项。
  void _initArguments() {
    if (Get.arguments == null) return;
    unitId = Get.arguments["unitId"];
    final dynamic rawContentTypes = Get.arguments["contentTypes"];
    final List<String> parsedContentTypes = _parseContentTypes(rawContentTypes);
    if (parsedContentTypes.isNotEmpty) {
      contentTypes.assignAll(parsedContentTypes);
      sectionTypeOrder.assignAll(parsedContentTypes);
    }
    final String breadcrumbTitle = Get.arguments["breadcrumbTitle"]?.toString() ?? '';
    if (breadcrumbTitle.isNotEmpty) {
      breadcrumbTitleText = breadcrumbTitle;
    }
    final String pageEmptyText = Get.arguments["emptyText"]?.toString() ?? '';
    if (pageEmptyText.isNotEmpty) {
      emptyText = pageEmptyText;
    }
    final String pageConfirmEmptyText = Get.arguments["confirmEmptyText"]?.toString() ?? '';
    if (pageConfirmEmptyText.isNotEmpty) {
      confirmEmptyText = pageConfirmEmptyText;
    }
    final dynamic rawInitIds = Get.arguments["initIds"];
    if (rawInitIds is! List) return;
    final List<int> ids = <int>[];
    for (final dynamic item in rawInitIds) {
      if (item is int && item > 0) {
        ids.add(item);
      }
    }
    initIds.assignAll(ids);
    selectedKnowledgeIds.assignAll(ids);
  }

  List<String> _parseContentTypes(dynamic value) {
    if (value is! List) return const <String>[];
    final List<String> resp = <String>[];
    for (final dynamic item in value) {
      final String contentType = item?.toString() ?? '';
      if (contentType.isEmpty) continue;
      if (resp.contains(contentType)) continue;
      resp.add(contentType);
    }
    return resp;
  }

  /// 拉取当前单元的可选词汇列表，只保留单词和短语。
  Future<void> getVocabularyList() async {
    if (unitId == null) {
      loadStatus.value = 1;
      return;
    }
    try {
      loadStatus.value = -1;
      ToastUtils.showLoading();
      final Map<String, dynamic> parameters = <String, dynamic>{};
      if (Get.isRegistered<ManageSettingController>()) {
        final ManageSettingController settingController = Get.find<ManageSettingController>();
        if (settingController.defaultResources.value == ResourceTypeEnum.video) {
          parameters['mediaMode'] = 1;
        }
        parameters['styleId'] = await settingController.getDefaultStyleId();
      }
      final CourseUnitTargetEntity? entity = await CourseConsoleRequest.getCourseUnitTargetList(
        unitId: unitId!,
        params: parameters,
        data: {
          'contentTypes': contentTypes.toList(),
        },
      );
      if (entity == null || isClosed) return;
      final List<KnowledgeCommonEntityList> list = <KnowledgeCommonEntityList>[];
      for (final KnowledgeCommonEntityList? item in entity.knowledgeList ?? const <KnowledgeCommonEntityList?>[]) {
        if (item == null || !_isVocabularyItem(item)) continue;
        list.add(item);
      }
      vocabularyList.assignAll(list);
      visibleVocabularyList.assignAll(list);
      loadStatus.value = list.isEmpty ? 1 : 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncCurrentAnchorTypeByScroll();
      });
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 执行搜索，按关键词过滤当前单元下的词汇列表。
  void onSearch() {
    _applySearchResult();
  }

  /// 清空单个搜索框后恢复全部词汇列表。
  void onSingleClearSearch() {
    filterSearchs['content']?.controller.clear();
    _applySearchResult();
  }

  /// 重置筛选条时同步清空搜索条件。
  void onReset(Map<String, FilterSortsData> sorts, Map<String, FilterConditionsData> conditions) {
    filterSearchs['content']?.controller.clear();
    _applySearchResult();
  }

  /// 根据当前搜索词刷新页面可见词汇结果。
  void _applySearchResult() {
    final String keyword = filterSearchs['content']?.controller.text.trim().toLowerCase() ?? '';
    if (keyword.isEmpty) {
      visibleVocabularyList.assignAll(vocabularyList);
    } else {
      final List<KnowledgeCommonEntityList> list = <KnowledgeCommonEntityList>[];
      for (final KnowledgeCommonEntityList item in vocabularyList) {
        if (_matchSearchKeyword(item, keyword)) {
          list.add(item);
        }
      }
      visibleVocabularyList.assignAll(list);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        _syncCurrentAnchorTypeByScroll();
        return;
      }
      scrollController.jumpTo(0);
      _syncCurrentAnchorTypeByScroll();
    });
  }

  /// 当前词汇是否命中搜索关键词，兼容标题、释义和 id 搜索。
  bool _matchSearchKeyword(KnowledgeCommonEntityList item, String keyword) {
    final List<String> candidates = <String>[
      item.title ?? '',
      item.subTitle ?? '',
    ];
    for (final LanguageText text in item.subTitles?.whereType<LanguageText>() ?? const <LanguageText>[]) {
      final String value = text.text ?? '';
      if (value.isNotEmpty) {
        candidates.add(value);
      }
    }
    if ((item.contentId ?? 0) > 0) {
      candidates.add(item.contentId.toString());
    }
    if ((item.knowledgeId ?? 0) > 0) {
      candidates.add(item.knowledgeId.toString());
    }
    if ((item.content?.uid ?? 0) > 0) {
      candidates.add(item.content!.uid.toString());
    }
    for (final String candidate in candidates) {
      if (candidate.toLowerCase().contains(keyword)) return true;
    }
    return false;
  }

  /// 当前列表项是否属于本页面允许选择的词汇类型。
  bool _isVocabularyItem(KnowledgeCommonEntityList item) {
    final String contentType = item.contentType ?? '';
    if (contentType.isEmpty) return false;
    return contentTypes.contains(contentType);
  }

  /// 获取指定类型下当前可见的词汇列表。
  List<KnowledgeCommonEntityList> getVisibleItemsByType(String contentType) {
    final List<KnowledgeCommonEntityList> resp = <KnowledgeCommonEntityList>[];
    for (final KnowledgeCommonEntityList item in visibleVocabularyList) {
      if (item.contentType != contentType) continue;
      resp.add(item);
    }
    return resp;
  }

  /// 当前页面是否还有可见词汇，用于空态切换。
  bool hasVisibleItems() {
    for (final String type in sectionTypeOrder) {
      if (getVisibleItemsByType(type).isNotEmpty) return true;
    }
    return false;
  }

  /// 当前词汇是否处于选中状态。
  bool isSelected(KnowledgeCommonEntityList item) {
    final int knowledgeId = _resolveKnowledgeId(item);
    if (knowledgeId <= 0) return false;
    return selectedKnowledgeIds.contains(knowledgeId);
  }

  /// 切换单个词汇的选中状态。
  void toggleSelect(KnowledgeCommonEntityList item) {
    final int knowledgeId = _resolveKnowledgeId(item);
    if (knowledgeId <= 0) return;
    if (selectedKnowledgeIds.contains(knowledgeId)) {
      selectedKnowledgeIds.remove(knowledgeId);
      return;
    }
    selectedKnowledgeIds.add(knowledgeId);
  }

  /// 当前分区是否已经全选。
  bool isSectionAllSelected(String contentType) {
    final List<KnowledgeCommonEntityList> items = getVisibleItemsByType(contentType);
    if (items.isEmpty) return false;
    return items.every((KnowledgeCommonEntityList item) => isSelected(item));
  }

  /// 切换当前分区的全选状态。
  void toggleSectionSelect(String contentType) {
    final List<KnowledgeCommonEntityList> items = getVisibleItemsByType(contentType);
    if (items.isEmpty) return;
    final bool isAllSelected = items.every((KnowledgeCommonEntityList item) => isSelected(item));
    if (isAllSelected) {
      for (final KnowledgeCommonEntityList item in items) {
        final int knowledgeId = _resolveKnowledgeId(item);
        if (knowledgeId > 0) {
          selectedKnowledgeIds.remove(knowledgeId);
        }
      }
      return;
    }
    for (final KnowledgeCommonEntityList item in items) {
      final int knowledgeId = _resolveKnowledgeId(item);
      if (knowledgeId > 0 && !selectedKnowledgeIds.contains(knowledgeId)) {
        selectedKnowledgeIds.add(knowledgeId);
      }
    }
  }

  /// 构建分区标题文案，格式为“类型 已选 / 总数”。
  String buildTypeCountLabel(String contentType) {
    final ElementsCardType type = ElementsCardType.fromRawValue(contentType);
    return "${type.name} ${selectedCountForType(contentType)} / ${totalCountForType(contentType)}";
  }

  /// 构建分区按钮文案。
  String buildSectionActionLabel(String contentType) {
    return isSectionAllSelected(contentType) ? "取消全选" : "全选";
  }

  /// 获取指定分区已选数量。
  int selectedCountForType(String contentType) {
    final List<KnowledgeCommonEntityList> items = getVisibleItemsByType(contentType);
    int count = 0;
    for (final KnowledgeCommonEntityList item in items) {
      if (isSelected(item)) count++;
    }
    return count;
  }

  /// 获取指定分区总数量。
  int totalCountForType(String contentType) {
    return getVisibleItemsByType(contentType).length;
  }

  /// 获取当前总已选数量。
  int getSelectedCount() {
    return selectedKnowledgeIds.length;
  }

  /// 滚动到指定类型分区。
  Future<void> scrollToType(String contentType) async {
    currentAnchorType.value = contentType;
    final BuildContext? context = sectionKeys[contentType]?.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
  }

  /// 根据滚动位置同步当前高亮的底部锚点。
  void _syncCurrentAnchorTypeByScroll() {
    final List<String> sectionTypes = <String>[];
    for (final String type in sectionTypeOrder) {
      if (sectionKeys[type]?.currentContext != null && totalCountForType(type) > 0) {
        sectionTypes.add(type);
      }
    }
    if (sectionTypes.isEmpty) {
      currentAnchorType.value = '';
      return;
    }
    const double anchorTop = 110;
    String nextType = sectionTypes.first;
    bool hasSectionAboveAnchor = false;
    for (final String type in sectionTypes) {
      final BuildContext? context = sectionKeys[type]?.currentContext;
      if (context == null) continue;
      final RenderObject? renderObject = context.findRenderObject();
      if (renderObject is! RenderBox) continue;
      final double dy = renderObject.localToGlobal(Offset.zero).dy;
      if (dy <= anchorTop) {
        nextType = type;
        hasSectionAboveAnchor = true;
        continue;
      }
      if (!hasSectionAboveAnchor) {
        nextType = type;
      }
      break;
    }
    if (currentAnchorType.value != nextType) {
      currentAnchorType.value = nextType;
    }
  }

  /// 点击确认后返回上级页面，并带回已选择的词汇实体列表。
  void confirmSelection() {
    if (selectedKnowledgeIds.isEmpty) {
      ToastUtils.showManageToast(text: confirmEmptyText);
      return;
    }
    final List<KnowledgeCommonEntityList> resp = <KnowledgeCommonEntityList>[];
    for (final KnowledgeCommonEntityList item in vocabularyList) {
      final int knowledgeId = _resolveKnowledgeId(item);
      if (knowledgeId > 0 && selectedKnowledgeIds.contains(knowledgeId)) {
        resp.add(item);
      }
    }
    Get.back(result: resp);
  }

  /// 把课程目标词汇实体转换成选择卡片可直接消费的实体。
  UnitKnowledgePointsEntityKnowledgeList buildCardData(KnowledgeCommonEntityList item) {
    return UnitKnowledgePointsEntityKnowledgeList(
      uid: _resolveKnowledgeId(item),
      contentType: item.contentType,
      contentId: item.contentId,
      styleId: item.content?.styleId,
      dialect: item.content?.dialect,
      title: item.title,
      content: item.title,
      semanticId: item.content?.semanticId,
      definition: item.subTitle,
      audioUrl: _resolveAudioUrl(item),
      imageUrl: item.coverImage?.url,
      posTitle: item.posTitle,
      locked: item.locked,
      gloss: item.subTitles,
      pronunciations: _resolvePronunciations(item),
      tags: _buildTagList(item.tags),
      video: _buildVideo(item),
      favorited: item.favorited,
      access: item.access ?? item.rights?.access,
    );
  }

  /// 解析当前词汇的稳定选择 id，优先使用 knowledgeId。
  int _resolveKnowledgeId(KnowledgeCommonEntityList item) {
    return item.knowledgeId ?? item.content?.uid ?? item.contentId ?? 0;
  }

  /// 从 params 中抽取卡片需要的发音音频地址。
  String _resolveAudioUrl(KnowledgeCommonEntityList item) {
    final List<Pronunciations?> list = item.params?.data?.pronunciations ?? const <Pronunciations?>[];
    for (final Pronunciations pronunciation in list.whereType<Pronunciations>()) {
      final String url = (pronunciation.audioUrl ?? '').trim();
      if (url.isNotEmpty) return url;
    }
    return '';
  }

  /// 从 params 中抽取卡片和播放逻辑需要的发音数组。
  List<PronunciationsEntity>? _resolvePronunciations(KnowledgeCommonEntityList item) {
    final List<Pronunciations?> list = item.params?.data?.pronunciations ?? const <Pronunciations?>[];
    if (list.isEmpty) return null;
    final List<PronunciationsEntity> resp = <PronunciationsEntity>[];
    for (final Pronunciations pronunciation in list.whereType<Pronunciations>()) {
      resp.add(PronunciationsEntity.fromJson(pronunciation.toJson()));
    }
    return resp.isEmpty ? null : resp;
  }

  /// 把通用标签结构转换成词汇卡片标签结构。
  List<UnitKnowledgePointsEntityKnowledgeListTags>? _buildTagList(List<KnowledgeCommonEntityListGloss?>? tags) {
    if (tags == null || tags.isEmpty) return null;
    final List<UnitKnowledgePointsEntityKnowledgeListTags> resp = <UnitKnowledgePointsEntityKnowledgeListTags>[];
    for (final KnowledgeCommonEntityListGloss tag in tags.whereType<KnowledgeCommonEntityListGloss>()) {
      resp.add(UnitKnowledgePointsEntityKnowledgeListTags(
        gloss: tag.gloss,
        style: tag.style,
      ));
    }
    return resp.isEmpty ? null : resp;
  }

  /// 组装卡片视频字段，优先使用封面视频，同时兜底首帧图。
  UnitKnowledgePointsEntityVideo? _buildVideo(KnowledgeCommonEntityList item) {
    final bool hasVideo = (item.coverVideo?.url ?? '').isNotEmpty;
    final bool hasImage = (item.coverImage?.url ?? '').isNotEmpty;
    if (!hasVideo && !hasImage) return null;
    return UnitKnowledgePointsEntityVideo(
      videoId: item.coverVideo?.mediaId,
      videoUrl: item.coverVideo?.url,
      videoKey: item.coverVideo?.key,
      duration: item.coverVideo?.duration,
      firstFrameUrl: item.coverImage?.url,
      firstFrameKey: item.coverImage?.key,
      firstFrameMd5: item.coverImage?.md5,
    );
  }
}
