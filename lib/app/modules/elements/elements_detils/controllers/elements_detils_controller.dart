import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_bottom_menu_widget.dart';
import '../../dialog/elements_card_filter_dialog.dart';
import '../../dialog/elements_delete_card_dialog.dart';
import '../../elements_enums/elements_card_mode.dart';
import '../../model/elements_detils_data_model.dart';






class ElementsDetilsController extends GetxController with GetTickerProviderStateMixin {
  final ConfigController configController = Get.find<ConfigController>();
  Worker? _styleWatcher;

  void _scheduleDisposeControllers(List<ScrollController> controllers) {
    if (controllers.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final ScrollController c in controllers) {
        try {
          c.dispose();
        } catch (_) {}
      }
    });
  }

  /// 回顾模式的排序
  final List<NameValueModel> reviewModeSort = [
    SortType.updated,
    SortType.level,
    SortType.difficultyMin,
  ];

  /// 词典模式的排序
  final List<NameValueModel> dictModeSort = [
    SortType.letterOrder,
    SortType.wordFreq,
    SortType.difficultyMin,
  ];

  StartEndCalenderData startEndCalenderData = StartEndCalenderData(
    initiType: DateTypeEnum.updated,
    initValue: DateTypeEnum.all,
    typeList: [
      StartEndCalenderType(value: DateTypeEnum.updated, name: "上次学习时间"),
      StartEndCalenderType(value: DateTypeEnum.created, name: "首次获得时间"),
    ],
    valueList: [
      StartEndCalenderType(value: DateTypeEnum.all, name: "全部"),
      StartEndCalenderType(value: DateTypeEnum.today, name: "今天"),
      StartEndCalenderType(value: DateTypeEnum.yesterday, name: "昨天"),
      StartEndCalenderType(value: DateTypeEnum.last_3_days, name: "最近3天"),
      StartEndCalenderType(value: DateTypeEnum.last_7_days, name: "最近7天"),
      StartEndCalenderType(value: DateTypeEnum.last_14_days, name: "最近14天"),
      StartEndCalenderType(value: DateTypeEnum.last_30_days, name: "最近30天"),
    ],
  );

  final RxBool isLoading = true.obs;

  final RxList<ElementsDetilsTabModel> tabListData = <ElementsDetilsTabModel>[].obs;

  final Rx<LockEntity> rights = LockEntity().obs;
  final RxList<ElementsTabEntityList> serviceTabList = <ElementsTabEntityList>[].obs;

  /// 模式列表
  final RxList<CardDictModeEntityList> dictModeList = <CardDictModeEntityList>[].obs;

  TabController? tabController;
  final RxInt currentTabIndex = 1.obs;

  /// 0=回顾模式 1=词典模式
  final RxString mode = ElementsCardMode.studyCard.obs;

  /// 卡片总数
  final RxInt cardTotal = 0.obs;

  // ------ 以下是筛选条件 -------------
  /// 搜索
  final TextEditingController searchInput = TextEditingController();
  /// 是否点击了输入框 如果点击了那么禁用页面收起键盘350毫秒 350毫秒之后再允许点击
  final RxBool isSearchClick = false.obs;

  /// 条件筛选-难度等级
  List<int> filterDifficultyList = [];

  /// 条件筛选-星级
  List<int> filterStarRatingList = [];

  /// 排序 是否是升序
  bool sortIsAsc = false;

  /// 排序
  final Rx<NameValueModel> sortData = SortType.updated.obs;

  /// 词典模式是否隐藏筛选
  final RxBool dictModeIsFilter = false.obs;

  @override
  void onInit() {
    super.onInit();
    _styleWatcher = debounce(configController.styleModeVersion, (_) {
      Future.microtask(() async {
        try {
          _clearAllTabCache();
          await Future<void>.delayed(const Duration(milliseconds: 0));
          refreshListData(showLoading: false);
        } catch (_) {}
      });
    }, time: const Duration(milliseconds: 80));
    initTab(showLoading: false);
  }

  /// 外部刷新
  Future<void> externalRefresh() async {
    currentTabIndex.value = 0;

    mode.value = ElementsCardMode.studyCard;
    searchInput.clear();
    dictModeIsFilter.value = false;
    filterDifficultyList.clear();
    filterStarRatingList.clear();
    sortData.value = SortType.updated;
    sortIsAsc = false;
    await initTab(showLoading: false);
  }

  Future<void> initTab({bool showLoading = true}) async {
    if (LockUtils.checkExperienceAppStorage()) return;
    await getTabData();
    isLoading.value = true;
    _scheduleDisposeControllers(
      tabListData.map((e) => e.scrollController).toList(),
    );
    tabController?.dispose();
    tabListData.clear();

    if (mode.value == ElementsCardMode.studyCard) {
      tabListData.value = [ElementsDetilsTabModel(name: "全部", scrollController: ScrollController())];

      for (int i = 0; i < serviceTabList.length; i++) {
        if (serviceTabList[i].type == ElementsCardType.morpheme.value) continue;
        tabListData.add(ElementsDetilsTabModel(
          name: serviceTabList[i].option ?? "",
          scrollController: ScrollController(),
          type: ElementsCardType.fromRawValue(serviceTabList[i].type ?? ""),
        ));
      }
    } else {
      tabListData.value = [
        ElementsDetilsTabModel(
          name: "词典",
          scrollController: ScrollController(),
        ),
        ElementsDetilsTabModel(
          name: "词素",
          scrollController: ScrollController(),
          type: ElementsCardType.morpheme,
        ),
      ];
    }

    if (tabListData.length <= currentTabIndex.value) {
      currentTabIndex.value = 0;
    }

    tabController = TabController(length: tabListData.length, vsync: this, initialIndex: currentTabIndex.value);
    tabController?.addListener(() {
      currentTabIndex.value = tabController?.index ?? 0;
      initTabPage();
      if (tabListData[currentTabIndex.value].data?.isEmpty ?? true) {
        if (!(tabController?.indexIsChanging ?? false)) {
          refreshListData();
        }
      }
    });

    initTabPage();
    refreshListData(showLoading: showLoading);

    isLoading.value = false;
  }

  /// 初始化几个tab
  void initTabPage() {
    ElementsDetilsTabModel item = tabListData[currentTabIndex.value];
    if (item.isInit) return;
    item.isInit = true;
    item.scrollController.addListener(() {
      if (item.scrollController.position.pixels >= item.scrollController.position.maxScrollExtent - 100 && !item.scrollController.position.outOfRange) {
        if ((item.offset + item.limit) < item.count && !item.isLoading) {
          item.isLoading = true;
          item.offset += item.limit;
          initListData();
        }
      }
    });
  }

  Future<void> refreshListData({bool showLoading = true, bool showRightCountToast = false}) async {
    ElementsDetilsTabModel item = tabListData[currentTabIndex.value];
    item.offset = 0;
    item.count = 0;
    item.isLoading = false;
    item.data?.clear();
    tabListData.refresh();
    await initListData(showLoading: showLoading);
    if (showRightCountToast && mode.value == ElementsCardMode.searchCard) {
      String total = cardTotal.value.toString();
      if (cardTotal.value > 10000) {
        total = "${(cardTotal.value / 10000).round().toString()}万";
      }
      ToastUtils.showToast(
        text: "从 $total 词条中，为你找到 ${item.count} 条与「${searchInput.text}」相关的结果。",
        type: ToastType.info,
        marginBottom: 100.wMin,
      );
    }
    getDictMode(showRightCountToast: showRightCountToast);
  }

  /// 只刷新回顾模式
  Future<void> refreshStudyListData() async {
    if(mode.value == ElementsCardMode.studyCard){
      refreshListData(showLoading: false);
    }
  }

  /// 切换模式
  Future<void> changeMode(String type) async {
    filterDifficultyList.clear();
    filterStarRatingList.clear();
    currentTabIndex.value = 0;
    searchInput.clear();
    dictModeIsFilter.value = false;
    cardTotal.value = 0;
    mode.value = type;
    if (type == ElementsCardMode.studyCard) {
      sortIsAsc = false;
      sortData.value = SortType.updated;
    } else {
      sortIsAsc = true;
      sortData.value = SortType.letterOrder;
    }
    await initTab();
  }

  void _clearAllTabCache() {
    for (int i = 0; i < tabListData.length; i++) {
      tabListData[i].data?.clear();
      tabListData[i].count = 0;
      tabListData[i].offset = 0;
      tabListData[i].isNotData.value = false;
      tabListData[i].isLoading = false;
    }
    cardTotal.value = 0;
    tabListData.refresh();
  }

  Future<void> getTabData() async {
    ElementsTabEntity? tabs = await ElementsRequest.getTab();
    if (tabs == null) return;
    if (tabs.rights != null) {
      rights.value = tabs.rights!;
    }
    List<ElementsTabEntityList?>? list = tabs.list;
    if (list == null) return;
    serviceTabList.clear();
    for (var element in list) {
      if (element == null) continue;
      serviceTabList.add(element);
    }
  }

  Future<void> initListData({bool showLoading = true}) async {
    ElementsDetilsTabModel item = tabListData[currentTabIndex.value];

    await configController.ensureStyleReady();
    if (showLoading) ToastUtils.showLoading();
    ElementsCardEntity? cards = await getCardList(item.type?.value, item.offset, item.limit);
    if (showLoading) ToastUtils.hideLoading();
    if (cards == null) {
      item.isNotData.value = true;
      return;
    }
    item.rights = cards.rights;
    item.count = cards.count ?? 0;
    cardTotal.value = cards.total ?? 0;
    if (cards.datas == null) {
      item.isNotData.value = true;
      return;
    }

    List<ElementsDetilsDataModel> list = [];
    for (int i = 0; i < cards.datas!.length; i++) {
      ElementsCardEntityDatas? data = cards.datas?[i];
      if (data == null) continue;
      if (data.contentType == null) continue;

      list.add(ElementsDetilsDataModel(
        type: ElementsCardType.fromRawValue(data.contentType ?? ""),
        data: data,
      ));
    }
    item.data ??= [];
    item.data?.addAll(list);

    if (list.isEmpty) {
      item.isNotData.value = true;
    } else {
      item.isNotData.value = false;
    }
    item.isLoading = false;
    tabListData.refresh();
  }

  /// 获取卡片列表
  Future<ElementsCardEntity?> getCardList(String? type, int offset, int limit) async {
    Map<String, dynamic> reqData = {};
    Map<String, dynamic> parameters = {
      "offset": offset,
      "limit": limit,
      "style": configController.currentStyleForRequest,
      "mediaMode": 0,
    };
    if (type?.isNotEmpty ?? false) {
      parameters["contentType"] = type;
    }
    // parameters['order'] = sortIsAsc ? sortData.value.value : "-${sortData.value.value}";

    reqData['studied'] = mode.value == ElementsCardMode.studyCard;
    if (mode.value == ElementsCardMode.studyCard) {
      // if(filterStarRatingList.isNotEmpty){
      //   reqData["levels"] = filterStarRatingList;
      // }
      if (startEndCalenderData.initiType != null) {
        reqData["timeType"] = startEndCalenderData.initiType;
      }
      if (startEndCalenderData.initValue != null) {
        DateTypeEnumResult? timeRange = DateTypeEnum.getFilterTimeRange(startEndCalenderData.initValue!);
        if (timeRange != null) {
          reqData["start"] = DateFormatUtil.formatStr(timeRange.start, newPattern: "yyyy-MM-dd'T'HH:mm:ss");
          reqData["end"] = DateFormatUtil.formatStr(timeRange.end, newPattern: "yyyy-MM-dd'T'HH:mm:ss");
        }
      }

      parameters['order'] = sortIsAsc ? sortData.value.value : "-${sortData.value.value}";
    } else {
      if (filterDifficultyList.isNotEmpty) {
        reqData["difficulties"] = filterDifficultyList;
      }
      parameters['order'] = "${sortData.value.value},-in_course_cnt";
    }
    if (searchInput.text.isNotEmpty) {
      reqData["content"] = searchInput.text;
    }

    ElementsCardEntity? cards = await ElementsRequest.getCardList(parameters, reqData);
    return cards;
  }

  /// 执行搜索
  Future<void> searchCard(String text) async {
    // if(searchInput.text.trim().isEmpty) return;
    // 搜索清空筛选
    filterDifficultyList.clear();
    filterStarRatingList.clear();
    for (int i = 0; i < tabListData.length; i++) {
      tabListData[i].data?.clear();
      tabListData[i].offset = 0;
      tabListData[i].count = 0;
    }
    refreshListData(showRightCountToast: text.trim().isNotEmpty);
  }

  /// 清空搜索
  Future<void> clearSearch() async {
    if (searchInput.text.trim().isEmpty){
      resetKey();
      return;
    }
    searchInput.clear();
    dictModeIsFilter.value = false;
    filterDifficultyList.clear();
    filterStarRatingList.clear();
    if (mode.value == ElementsCardMode.studyCard) {
      sortIsAsc = false;
      sortData.value = SortType.updated;
    } else {
      sortIsAsc = true;
      sortData.value = SortType.letterOrder;
    }
    for (int i = 0; i < tabListData.length; i++) {
      tabListData[i].data?.clear();
      tabListData[i].offset = 0;
      tabListData[i].count = 0;
    }
    await refreshListData(showLoading: false);
  }

  /// 重新赋值key
  void resetKey(){
    for (int i = 0; i < tabListData.length; i++) {
      tabListData[i].data?.forEach((element) {
        element.key = GlobalKey();
      });
    }
    tabListData.refresh();
  }



  /// 获取模式
  Future<void> getDictMode({bool showRightCountToast = false}) async {
    CardDictModeEntity? data = await ElementsRequest.getDictMode();
    if (data == null) return;
    List<CardDictModeEntityList?>? list = data.list;
    if (list == null) return;
    dictModeList.clear();
    int? rightCount;
    LockEntity? rights;
    for (int i = 0; i < list.length; i++) {
      if (list[i] == null) continue;
      dictModeList.add(list[i]!);
      if (list[i]?.module == mode.value) {
        rightCount = list[i]?.rightCount;
        rights = list[i]?.rights;
      }
    }

    if (showRightCountToast && rightCount != null) {
      if (rightCount > 0) {
        ToastUtils.showToast(
          text: "您还有$rightCount次搜索卡片",
          type: ToastType.warning,
          onlyOne: false,
        );
      } else {
        if (mode.value == ElementsCardMode.searchCard && rights?.allLock == true) {
          ToastUtils.showToast(text: "您的搜索次数已用完", onlyOne: false);
        }
      }
    }
  }

  /// 获取权益数量
  Future<void> getRightCount() async {
    RightCountDetailsEntity? rightCountDetailsEntity = await UserRequest.getCardRightCount();
    if (rightCountDetailsEntity == null) return;
    int searchCard = rightCountDetailsEntity.searchCard ?? 0;
    if (searchCard == 0) return;
    ToastUtils.showToast(text: "您还有$searchCard次搜索卡片", type: ToastType.warning);
  }

  /// 执行条件筛选
  void filterCard(ElementsCardFilterResult value) {
    if (value.difficultyList == filterDifficultyList && value.starRatingList == filterStarRatingList) {
      return;
    }
    filterDifficultyList = value.difficultyList;
    filterStarRatingList = value.starRatingList;
    for (int i = 0; i < tabListData.length; i++) {
      tabListData[i].data?.clear();
    }
    refreshListData();
  }

  /// 执行排序
  void sortCard(NameValueModel sort, bool isAsc) {
    if (sortData.value.value == sort.value && isAsc == sortIsAsc) {
      return;
    }
    sortData.value = sort;
    sortIsAsc = isAsc;
    for (int i = 0; i < tabListData.length; i++) {
      tabListData[i].data?.clear();
      tabListData[i].offset = 0;
      tabListData[i].count = 0;
    }
    refreshListData();
  }

  /// 长按卡片弹出删除遮罩层
  Future<void> showDeleteMask(BuildContext context, ElementsDetilsDataModel? data) async {
    if (data == null) return;
    if (mode.value != ElementsCardMode.studyCard) return; // 只有回顾模式可以删除
    ElementsDeleteCardDialog.show(
      context: context,
      data: data,
      onTap: (type) {
        if (type == 1) {
          // 删除卡片
          deleteCard(context, data);
        }
      },
    );
  }

  /// 删除卡片
  Future<void> deleteCard(BuildContext context, ElementsDetilsDataModel data) async {
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return;
    bool deleteRes = await DeleteDialog.show(
        context: context,
        title: "重置学习计划",
        subTitle: "你确定要重置 ${data.data?.content ?? ""} 这个知识点吗？\n重置后，该知识点将恢复为“未学习”状态，并不会再出现在复习中。",
        content: "提示：此操作不可逆！",
        subContent: "此操作仅建议在误学高年级知识点时使用。",
        confirmText: "确认重置");
    if (!deleteRes) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "uid": data.data?.contentId,
        "type": data.data?.contentType,
      };
      bool res = await ElementsRequest.deleteCard(reqData);
      if (!res) return;
      for (int i = 0; i < tabListData.length; i++) {
        tabListData[i].data?.clear();
        tabListData[i].offset = 0;
        tabListData[i].count = 0;
      }
      await refreshListData(showLoading: false);
      ToastUtils.showToast(text: "重置成功", type: ToastType.success);
      Get.back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> bottomMenuTypeFun(ElementsBottomMenuType type, BuildContext context) async {
    if (type == ElementsBottomMenuType.upgradeCard) {
      await showUpgradeCardDialog(context);
    } else if (type == ElementsBottomMenuType.collectCard) {
      await collectCard(context);
    }
  }

  /// 集卡
  Future<void> collectCard(BuildContext context) async {
    // dynamic collectRes = await Get.toNamed(Routes.ELEMENTS_COLLECT_CARD);
    // if(collectRes == null) return;
    // dynamic pageRes = await Get.toNamed(Routes.PRACTICE_QUESTIONS);
    // if(pageRes == null) return;
    // await ElementsCollectResultDialog.show(context: context);

    // await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> showUpgradeCardDialog(BuildContext context) async {
    // dynamic updateRes = await Get.toNamed(Routes.ELEMENTS_UPGRADE_CARD);
    // if(updateRes == null) return;
    // // TODO: 升卡
    // dynamic pageRes = await Get.toNamed(Routes.PRACTICE_QUESTIONS);
    // if(pageRes == null) return;
    // ElementsStartUpgradeDialog.show(context: context);
  }

  ///去听写
  Future<void> goDictate() async {
    List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = [];
    for (ElementsDetilsDataModel cardModel in tabListData[currentTabIndex.value].data ?? []) {
      ElementsCardEntityDatas? data = cardModel.data;
      if (data == null) continue;
      knowledgeList.add(
        UnitKnowledgePointsEntityKnowledgeList(
          contentId: data.contentId,
          contentType: data.contentType,
          content: data.content,
          semanticId: data.semanticId,
          difficulty: data.difficulty,
          definition: data.definition,
          audioUrl: data.audioUrl,
          imageUrl: data.imageUrl,
          gloss: data.gloss,
          pronunciations: data.pronunciations,
        ),
      );
    }
    if (knowledgeList.isEmpty) return;

    Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_DICTATION, arguments: {
      "knowledgeList": knowledgeList,
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _styleWatcher?.dispose();
    if (!isLoading.value) {
      tabController?.dispose();
    }
    for (int i = 0; i < tabListData.length; i++) {
      tabListData[i].scrollController.dispose();
    }
    super.onClose();
  }
}
