import 'package:langwise/common/entities/entities.dart';

class ImageModerationDetailState {
  /// 图片风格/地区选项列表
  List<ImageFilterOption> styles = <ImageFilterOption>[];

  /// 当前选中的风格选项
  ImageFilterOption? selectedStyle;

  /// 当前选中的地区选项
  ImageFilterOption? selectedLocale;

  /// 获取风格列表（根据 style 字段去重）
  List<ImageFilterOption> getStyleOptions() {
    if (styles.isEmpty) return [];

    // 使用Set来存储唯一的style值
    final Set<String?> uniqueStyles = {};
    final List<ImageFilterOption> result = [];

    // 首先添加“所有风格”选项
    result.add(ImageFilterOption(
      uid: 0,
      style: 'all',
      styleTitle: '所有风格',
    ));

    // 遍历所有样式，添加唯一的风格
    for (final option in styles) {
      if (option.style != null && !uniqueStyles.contains(option.style)) {
        uniqueStyles.add(option.style);
        result.add(option);
      }
    }

    return result;
  }

  /// 获取地区列表（根据 locale 字段去重）
  List<ImageFilterOption> getLocaleOptions() {
    if (styles.isEmpty) return [];

    // 使用Set来存储唯一的locale值
    final Set<String?> uniqueLocales = {};
    final List<ImageFilterOption> result = [];

    // 首先添加“所有地区”选项
    result.add(ImageFilterOption(
      uid: 0,
      locale: 'all',
      localeTitle: '所有地区',
    ));

    // 遍历所有样式，添加唯一的地区
    for (final option in styles) {
      if (option.locale != null && !uniqueLocales.contains(option.locale)) {
        uniqueLocales.add(option.locale);
        result.add(option);
      }
    }

    return result;
  }

  /// 当前选中的知识点
  KnowledgePointDetail? selectedKnowledgePoint;

  /// 判断是否有选中的知识点
  bool get hasSelectedKnowledgePoint => selectedKnowledgePoint != null;

  /// 当前选中的图片
  ImageItem? selectedImage;

  /// 判断是否有选中的图片
  bool get hasSelectedImage => selectedImage != null;

  /// 当前选中的词性
  PosGroup? selectedPos;

  /// 当前选中的释义
  GlossItem? selectedGloss;

  /// 审核状态筛选
  ReviewStatus statusFilter = ReviewStatus.pending;

  /// 搜索关键词
  String searchTerm = '';

  /// 下一个词性信息
  Map<String, String> nextPosInfo = {'pos': '', 'gloss': ''};

  /// 当前选中的快速筛选索引
  int selectedFilterIndex = 0;

  /// 快速筛选项列表
  final List<Map<String, dynamic>> filterItems = [
    {'label': '全部图片', 'count': 0},
    {'label': '未审核', 'count': 0},
    {'label': '已审核', 'count': 0}
  ];

  /// 当前筛选状态
  /// null: 全部图片, 0: 未审核, 1: 已审核
  int? filterStatus;

  /// 批量审核模式标志
  bool isBatchMode = false;

  /// 是否可以进入批量审核模式
  bool get canBatchReview => hasSelectedKnowledgePoint && selectedKnowledgePoint!.canBatchReview;

  /// 获取内容词性列表，如果不存在则返回空列表
  List<PosGroup> get contentPosList => selectedKnowledgePoint?.contentPosList ?? [];

  /// 判断内容词性列表是否为空
  bool get hasContentPosList => contentPosList.isNotEmpty;

  /// 获取所有图片
  List<ImageItem> getAllImages() {
    if (!hasSelectedKnowledgePoint) {
      return [];
    }

    final List<ImageItem> allImages = [];
    for (final posGroup in contentPosList) {
      for (final gloss in posGroup.semanticList) {
        allImages.addAll(gloss.images);
      }
    }
    return allImages;
  }

  /// 获取当前选中词性的释义列表
  List<GlossItem> getCurrentGlosses() {
    if (!hasContentPosList || selectedPos == null) {
      return [];
    }

    final posGroup = selectedKnowledgePoint!.contentPosList!.firstWhere(
      (group) => group == selectedPos,
      orElse: () => PosGroup(semanticList: []),
    );

    return posGroup.semanticList;
  }

  /// 获取当前选中释义
  GlossItem? getCurrentGloss() {
    return selectedGloss;
  }

  /// 获取当前选中释义的图片列表
  List<ImageItem> getCurrentImages() {
    final gloss = getCurrentGloss();
    if (gloss == null) {
      return [];
    }

    // 获取释义中的所有图片
    final allImages = gloss.images;

    // 根据选中的风格和地区进行过滤
    List<ImageItem> filteredImages = allImages;

    // 风格过滤（如果选中了特定风格且不是"所有风格"）
    if (selectedStyle != null && selectedStyle!.style != 'all') {
      filteredImages = filteredImages.where((img) => img.style == selectedStyle!.style).toList();
    }

    // 地区过滤（如果选中了特定地区且不是"所有地区"）
    if (selectedLocale != null && selectedLocale!.locale != 'all') {
      filteredImages = filteredImages.where((img) => img.locale == selectedLocale!.locale).toList();
    }

    // 根据筛选状态进一步过滤
    if (filterStatus == null) {
      // 全部图片（已经按风格和地区过滤）
      return filteredImages;
    } else if (filterStatus == 0) {
      // 未审核图片 (imageScore == null 或 imageScore == 0)
      return filteredImages.where((img) => img.needsReview).toList();
    } else {
      // 已审核图片 (imageScore > 0)
      return filteredImages.where((img) => !img.needsReview).toList();
    }
  }

  /// 获取已审核图片数量
  int getReviewedImagesCount() {
    return getAllImages().where((img) => !img.needsReview).length;
  }

  /// 获取总图片数量
  int getTotalImagesCount() {
    return getAllImages().length;
  }

  /// 清空状态
  void clear() {
    selectedKnowledgePoint = null;
    selectedImage = null;
    selectedPos = null;
    selectedGloss = null;
    statusFilter = ReviewStatus.pending;
    searchTerm = '';
    nextPosInfo = {'pos': '', 'gloss': ''};
  }
}
