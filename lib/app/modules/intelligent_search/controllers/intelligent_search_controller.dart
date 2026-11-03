import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';

class IntelligentSearchController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  IntelligentSearchController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.INTELLIGENT_SEARCH;

  @override
  String get breadcrumbTitle => "学习探索";

  // 传进来的参数 如果不为空 需要查询对应的接口获取单元的意图卡
  /// 课程id
  int? courseId;
  /// 等级id
  int? levelId;
  /// 模块id
  int? moduleId;
  /// 单元id 
  int? unitId;
  /// 是否可选模式
  bool isSelectable = false;
  Map<String, List<String>> presetFilters = {};
  String? searchHint;
  final Set<String> preSelectedContentKeys = <String>{};

  final ConfigController configController = Get.find<ConfigController>();

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  // final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final String searchKey = "query";
  final RxMap<String, FilterSearchsData> filterSearchs = <String, FilterSearchsData>{}.obs;

  /// 尝试搜索的文本
  final RxList<String> trySearchText = <String>[].obs;

  /// 是否展示搜索结果
  final RxBool isShowSearchResult = false.obs;

  /// 正在学习的单元意图卡
  final RxList<SearchLearnIntentionEntityList> learnIntentionList = <SearchLearnIntentionEntityList>[].obs;


  /// 当前搜索的意图卡下标
  final RxInt currentSearchIndex = (-1).obs;
  /// 当前搜索的意图卡分类下标
  final RxInt currentSearchKindIndex = (-1).obs;
  /// 意图卡页面滚动控制器
  final ScrollController learnIntentionController = ScrollController();
  /// 记录当前意图卡的滚动位置
  double learnIntentionScrollPosition = 0.0;


  /// 搜索的offset
  int offset = 0;
  /// 搜索的limit
  int limit = 20;
  /// 搜索的结果数量
  final RxInt count = 0.obs;
  /// 是否正在进行搜索请求
  final RxBool isSearching = false.obs;
  /// 是否还有更多搜索结果
  final RxBool hasMoreSearchResults = false.obs;

  /// 搜索结果的滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 搜索结果
  final Rx<SearchResultsEntity> searchResults = SearchResultsEntity().obs;
  /// 搜索的结果列表
  final RxList<KnowledgeCommonEntityList> searchResultsList = <KnowledgeCommonEntityList>[].obs;
  /// 可选模式下已选择的内容
  final RxMap<String, KnowledgeCommonEntityListContent> selectedContents = <String, KnowledgeCommonEntityListContent>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      courseId = Get.arguments["courseId"];
      levelId = Get.arguments["levelId"];
      moduleId = Get.arguments["moduleId"];
      unitId = Get.arguments["unitId"];
      isSelectable = _parseBool(Get.arguments["isSelectable"]);
      presetFilters = _parsePresetFilters(Get.arguments["presetFilters"]);
      searchHint = Get.arguments["searchHint"]?.toString();
      _parsePreSelectedContentList(Get.arguments["contentList"]);
    }

    onScrollControllerChange();
    
    getRecommendedScreening();
    getLearnIntentionEntityList();
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == "true";
    return false;
  }

  Map<String, List<String>> _parsePresetFilters(dynamic value) {
    if(value is! Map) return {};
    Map<String, List<String>> res = {};
    value.forEach((key, v) {
      if(key == null) return;
      String k = key.toString();
      if(k.isEmpty) return;
      if(v is List){
        res[k] = v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      }else if(v != null){
        String t = v.toString();
        if(t.isNotEmpty) res[k] = [t];
      }
    });
    return res;
  }

  void _parsePreSelectedContentList(dynamic value){
    if(value is! List) return;
    for (int i = 0; i < value.length; i++) {
      dynamic item = value[i];
      if(item is! Map) continue;
      dynamic content = item["content"];
      if(content is! Map) continue;
      String? type = content["type"]?.toString();
      int? uid = int.tryParse(content["uid"]?.toString() ?? "");
      if(type == null || type.isEmpty || uid == null) continue;
      preSelectedContentKeys.add("${type}_$uid");
    }
  }

  bool _isPreSelected(KnowledgeCommonEntityListContent content){
    String? type = content.type;
    int? uid = content.uid;
    if(type == null || uid == null) return false;
    return preSelectedContentKeys.contains("${type}_$uid");
  }

  String _buildSelectedContentKey(KnowledgeCommonEntityListContent content) {
    return "${content.type}_${content.uid}_${content.semanticId ?? 0}";
  }

  bool isContentSelected(KnowledgeCommonEntityList item) {
    KnowledgeCommonEntityListContent? content = item.content;
    if(content == null || content.uid == null || content.type == null) return false;
    String key = _buildSelectedContentKey(content);
    bool isSelected = selectedContents.containsKey(key);
    if(isSelected) return true;
    return _isPreSelected(content);
  }

  void toggleSelectedContent(KnowledgeCommonEntityList item) {
    KnowledgeCommonEntityListContent? content = item.content;
    if(content == null || content.uid == null || content.type == null) {
      ToastUtils.showToast(text: "当前内容暂不支持选择");
      return;
    }
    if(_isPreSelected(content)){
      ToastUtils.showToast(text: "该内容已添加");
      return;
    }
    String key = _buildSelectedContentKey(content);
    if(selectedContents.containsKey(key)){
      selectedContents.remove(key);
      return;
    }
    selectedContents[key] = content;
  }

  void onConfirmSelect() {
    if(selectedContents.isEmpty) {
      ToastUtils.showToast(text: "请选择内容");
      return;
    }
    Get.back(result: selectedContents.values.map((e) => e.toJson()).toList());
  }

  /// 监听搜索结果的滚动控制器
  void onScrollControllerChange(){
    scrollController.addListener(() {
      if(!scrollController.hasClients || isSearching.value || !hasMoreSearchResults.value) return;

      ScrollPosition position = scrollController.position;
      if(position.outOfRange) return;
      if(position.pixels < position.maxScrollExtent - 300) return;

      offset += limit;
      requestSearch();
    });
  }


  /// 获取推荐筛选搜索列表
  Future<void> getRecommendedScreening() async{
    filterSearchs.value = {
      searchKey: FilterSearchsData(
        title: "智能搜索",
        hintText: "请输入搜索内容",
        controller: TextEditingController(),
      ),
    }.obs;

    ZhenduScriptQueryMetaGroupListEntity? entity = await LanguageUtil.getRecommendedScreening();
    if(entity == null) return;

    List<ZhenduScriptQuerySearchHintEntity> searchHints = entity.searchHints;
    List<String> searchHintsTexts = searchHints.map((item) => item.text?.trim() ?? "").toList();
    List<String> randomSearchTexts = searchHintsTexts.where((text) => text.isNotEmpty).toList();
    randomSearchTexts.shuffle();

    trySearchText.clear();
    trySearchText.addAll(randomSearchTexts.take(6));

    if(trySearchText.isNotEmpty){
      filterSearchs[searchKey]?.hintText = randomSearchTexts[Random().nextInt(randomSearchTexts.length)];
      filterSearchs.refresh();
    }
    if((searchHint ?? "").trim().isNotEmpty){
      filterSearchs[searchKey]?.hintText = searchHint?.trim() ?? "";
      filterSearchs.refresh();
    }

    List<ZhenduScriptQueryMetaGroupEntity> filters = entity.filters;

    for (var element in filters) {
      String? groupName = element.groupName;
      String? groupCode = element.groupCode;
      if(groupName == null || groupCode == null) continue;
      bool isRadioGroup = element.radioGroup ?? false;
      List<ZhenduScriptQueryMetaItemEntity> items = element.items;
      List<String> presetValues = presetFilters[groupCode] ?? [];
      List<FilterConditionsItem> conditions = [];
      for(int i = 0; i < items.length; i++){
        if(items[i].value == null || items[i].name == null) continue;
        bool selected = (items[i].defaultValue ?? false);
        if(presetValues.isNotEmpty){
          selected = presetValues.contains(items[i].value);
        }
        conditions.add(FilterConditionsItem( 
          name: items[i].name ?? "",
          value: items[i].value ?? "",
          selected: selected,
        ));
      }
      filterConditions[groupCode] = FilterConditionsData(
        title: groupName,
        isSingle: isRadioGroup,
        conditions: conditions,
      );
    }
    filterConditions.refresh();

    // List<ZhenduScriptQueryMetaGroupEntity> orders = entity.orders;

    // for (var element in orders) {
    //   String? groupName = element.groupName;
    //   String? groupCode = element.groupCode;
    //   if(groupName == null || groupCode == null) continue;
    //   List<ZhenduScriptQueryMetaItemEntity> items = element.items;
    //   List<FilterSortsItem> sorts = [];
    //   for(int i = 0; i < items.length; i++){
    //     if(items[i].value == null || items[i].name == null) continue;
    //     sorts.add(FilterSortsItem( 
    //       name: items[i].name ?? "",
    //       selected: items[i].defaultValue ?? false,
    //       direction: (items[i].value ?? '').startsWith('-')? FilterSortDirection.down : FilterSortDirection.up
    //     ));
    //   }

    //   filterSorts[groupCode] = FilterSortsData(
    //     title: groupName,
    //     sorts: sorts,
    //   );
    // }

    // filterSorts.refresh();
  }

  /// 获取正在学习的单元意图卡
  Future<void> getLearnIntentionEntityList({bool showLoading = true}) async{
    try {
      if(showLoading) ToastUtils.showLoading();
      SearchLearnIntentionEntity? entity;
      if(isSelectable && moduleId != null && unitId != null){
        Map<String, dynamic> reqData = {
          "moduleId": moduleId,
          "unitId": unitId,
        };
        entity = await LanguageUtil.getUnitContentIntentListByUnit(data: reqData);
      }else if(courseId != null && levelId != null && moduleId != null && unitId != null){
        Map<String, dynamic> reqData = {
          "units": [{
            "courseId": courseId,
            "levelId": levelId,
            "moduleId": moduleId,
            "unitId": unitId,
          }],
        };
        entity = await LanguageUtil.getLearnIntentionListByUnit(data: reqData);
      }else{
        entity = await LanguageUtil.getLearnIntentionEntityList();
      }
      
      if(entity == null) return;
      List<SearchLearnIntentionEntityList?> list = entity.list??[];

      learnIntentionList.clear();

      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        learnIntentionList.add(list[i]!);
      }

    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 重置筛选条件
  Future<void> resetFilterConditions() async{
    filterSearchs[searchKey]?.controller.clear();
    selectedContents.clear();
    filterConditions.forEach((key, value) {
      for (var element in value.conditions) {
        element.selected = false;
      }
    });

    filterSearchs.refresh();
    await onFilterConditionsChange();
  }

  /// 点击尝试搜索的按钮
  Future<void> onClickTrySearch(String text) async{
    filterSearchs[searchKey]?.controller.text = text;
    filterSearchs.refresh();
    await onFilterConditionsChange();
  }

  /// 点击搜索按钮
  Future<void> onClickSearch() async{
    String? query = filterSearchs[searchKey]?.controller.text;
    if(query == null || query.isEmpty){
      String hintText = filterSearchs[searchKey]?.hintText ?? "";
      if(hintText.isNotEmpty){
        filterSearchs[searchKey]?.controller.text = hintText;
      }
    }
    filterSearchs.refresh();
    await onFilterConditionsChange();
  }

  /// 清空搜索框
  Future<void> onClickClearSearch() async{
    filterSearchs[searchKey]?.controller.clear();
    filterSearchs.refresh();
    // await onFilterConditionsChange();
  }

  /// 筛选条件改变
  Future<void> onFilterConditionsChange() async{
    // query 非空
    Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
    if(searchParams.isEmpty) {
      // 没有搜索内容，展示所有意图卡
      getLearnIntentionEntityList(showLoading: false);

      searchResults.value = SearchResultsEntity();
      searchResultsList.clear();
      count.value = 0;
      offset = 0;
      hasMoreSearchResults.value = false;
      currentSearchIndex.value = -1;
      currentSearchKindIndex.value = -1;

      isShowSearchResult.value = false;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(learnIntentionController.hasClients){
          learnIntentionController.jumpTo(learnIntentionScrollPosition);
        }
      });
      return;
    }

    searchResults.value = SearchResultsEntity();
    searchResultsList.clear();
    count.value = 0;
    offset = 0;
    hasMoreSearchResults.value = true;
    
    await requestSearch();

    if(learnIntentionController.hasClients){
      learnIntentionScrollPosition = learnIntentionController.position.pixels;
    }
    // 搜索
    isShowSearchResult.value = true;
  }

  /// 点击卡片搜索
  Future<void> onClickCardSearch(SearchLearnIntentionEntityListIntentCards? intentCard, int index, int kindIndex) async{
    if(intentCard == null) return;

    LanguageText? query = LearningLangUtils.getShowForNone(intentCard.query);
    if(query != null) {
      filterSearchs[searchKey]?.controller.text = query.text ?? "";
      filterSearchs.refresh();
    }

    List<String?> contentTypes = intentCard.contentTypeValues;
    List<String?> difficultys = intentCard.difficultyValues;

    // 把筛选条件里面对应条件选择改为true
    filterConditions.forEach((key, value) {
      for (var element in value.conditions) {
        if(contentTypes.contains(element.value)){
          element.selected = true;
        }
        if(difficultys.contains(element.value)){
          element.selected = true;
        }
      }
    });

    filterConditions.refresh();

    currentSearchIndex.value = index;
    currentSearchKindIndex.value = kindIndex;

    await onFilterConditionsChange();
  }


  /// 请求搜索
  Future<void> requestSearch() async{
    Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(conditions: filterConditions);
    Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);

    List<Map<String, dynamic>> filters = [];
    conditionParams.forEach((key, value) {
      filters.add({
        "code": key,
        "values": value,
      });
    });

    Map<String, dynamic> reqData = {};
    if(searchParams.isNotEmpty){
      reqData.addAll(searchParams);
    }

    if(filters.isNotEmpty){
      reqData["filters"] = filters;
    }

    Map<String, dynamic> params = {
      "offset": offset,
      "limit": limit,
    };

    try {
      isSearching.value = true;

      ToastUtils.showLoading();
      SearchResultsEntity? entity = await LanguageUtil.universalSearch(data: reqData, parameters: params);
      if(entity == null) return;
      searchResults.value = entity;
      count.value = entity.count ?? 0;

      List<KnowledgeCommonEntityList?> datas = entity.datas??[];

      List<KnowledgeCommonEntityList> res = [];
      for(int i = 0; i < datas.length; i++){
        if(datas[i] == null) continue;
        res.add(datas[i]!);
      }

      searchResultsList.addAll(res);
      hasMoreSearchResults.value = res.isNotEmpty && res.length >= limit && searchResultsList.length < count.value;

    } finally{
      ToastUtils.hideLoading();
      isSearching.value = false;
    }
  }





  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
