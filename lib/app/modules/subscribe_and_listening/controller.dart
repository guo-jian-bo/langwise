import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/subscribe_and_listening/notice_dialog.dart';
import 'package:langwise/app/modules/subscribe_and_listening/sub_manage_dialog.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/music.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/values/storage.dart';
import 'package:lib_common/utils/storage_util.dart';

import '../../../utils/utils.dart';

class SubListenController extends GetxController with GetTickerProviderStateMixin {
  RxInt selectedIndex = 0.obs;

  RxList<ManageSubscribeGenreEntity> themes = <ManageSubscribeGenreEntity>[].obs;
  RxList<UserRevealCollectionEntity> reveals = <UserRevealCollectionEntity>[].obs;
  final Rx<LockEntity> rights = LockEntity().obs;
  RxInt page = 0.obs; // 当前 offset
  RxInt num = 20.obs; // page size
  RxInt total = 0.obs; // 总条数
  RxString genre = "".obs;
  RxString theme = "".obs;
  RxBool hasMore = true.obs;
  RxBool isLoadingMore = false.obs;
  UserRevealPushRecordEntity? pushRecord;

  /// 搜索
  final TextEditingController searchInput = TextEditingController();

  /// 是否点击了输入框 如果点击了那么禁用页面收起键盘350毫秒 350毫秒之后再允许点击
  final RxBool isSearchClick = false.obs;

  TabController? tabController;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initPage();
  }

  initPage({bool showNotice = true}) {
    page.value = 0;
    hasMore.value = true;
    if (!LockUtils.checkExperienceAppStorage()) {
      UserStore.to.getUserInfo();
    }
    _loadRevealGenres();
    getUserRevealsPage(showNotice: showNotice);
  }

  Future<void> initTab() async {
    var mRights = await MusicRequest.isBuyReveal(data: {'type': "EN_REVEAL"});
    if (mRights == null) return;
    rights.value = mRights;
  }

  /// 执行搜索
  Future<void> searchCard(String text) async {
    theme.value = text;
    refreshUserRevealsPage();
  }

  /// 初始化曲风/主题列表
  Future<void> _loadRevealGenres() async {
    final list = await SubscribeRequest.getRevealGenresList();
    if (list == null) return;

    // 第一个为“全部”虚拟项
    final result = <ManageSubscribeGenreEntity>[];

    final allItem = ManageSubscribeGenreEntity(
      name: [ManageSubscribeNameItem(lang: 'zh', text: '全部主题'), ManageSubscribeNameItem(lang: 'en', text: 'All Themes')],
    );
    result.add(allItem);

    // 后面追加接口返回的真实曲风
    result.addAll(list);

    themes.value = result;

    tabController = TabController(length: result.length, vsync: this, initialIndex: currentTabIndex.value);
    tabController?.addListener(() {
      currentTabIndex.value = tabController?.index ?? 0;
    });
  }

  ///获取用户专栏列表（分页，参数为主题和难度）
  Future<void> getUserRevealsPage({bool showNotice = true}) async {
    // 并发保护：正在加载中时直接返回
    if (isLoadingMore.value) {
      return;
    }

    // 如果已经没有更多并且不是首次加载，直接返回
    if (!hasMore.value && page.value != 0) {
      return;
    }

    isLoadingMore.value = true;
    try {
      // 首次加载或刷新：清空数据并重置标记
      if (page.value == 0) {
        reveals.clear();
        hasMore.value = true;
        total.value = 0;
      }

      final pageData = await SubscribeRequest.getUserRevealsPage(
        genre: genre.value,
        theme: theme.value,
        offset: page.value,
        limit: num.value,
      );
      if (pageData == null) {
        hasMore.value = false;
        return;
      }

      if ((pageData.warnDialog ?? false) && total.value == 0) {
        var record = StorageUtil().getString(SUB_LISTEN_NOT_REMIND_KEY);
        bool isToday = false;

        if (record.isNotEmpty) {
          final saved = DateTime.tryParse(record);
          final now = DateTime.now();
          isToday = saved?.year == now.year && saved?.month == now.month && saved?.day == now.day;
        }

        bool isFree = UserStore.to.userInfo.value.isFree;
        if(!isFree){
          if (!isToday && showNotice) {
            NoticeDialog.show(Get.context!, pageData.warnMessage ?? "");
          }
        }
        
      }

      // 记录总数，用于判断是否有下一页
      total.value = pageData.count ?? 0;
      rights.value = pageData.rights!;

      final List<UserRevealCollectionEntity>? list = pageData.datas;
      if (list == null || list.isEmpty) {
        hasMore.value = false;
        return;
      }

      reveals.addAll(list);

      // 使用 offset + pageSize 与 total 对比判断是否还有下一页
      page.value += num.value;
      if (page.value >= total.value) {
        hasMore.value = false;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 下拉刷新
  Future<void> refreshUserRevealsPage() async {
    page.value = 0;
    hasMore.value = true;
    await getUserRevealsPage();
  }

  ///订阅；取消订阅
  Future<void> toggleSubscribe({required int collectionId, required bool isSubscribed}) async {
    final access = isSubscribed ? 'NORMAL' : 'DELETED';
    var res = await SubscribeRequest.userToggleSubscribe(collectionId: collectionId, access: access);
    // 刷新列表
    if (res!.code == HttpStatus.ok) {
      Get.back(result: access);
    } else {
      Get.back(result: 'error');
    }
  }

  ///订阅管理
  Future<void> getUserSubscribeConfig() async {
    final res = await SubscribeRequest.getUserSubscribeConfig();
    if (res != null) {
      SubManageDialog.show(Get.context!, res).then((needRefresh) {});
    }
  }

  /// 推送 / 甄听历史记录
  Future<void> loadUserRevealPushRecord() async {
    pushRecord = await SubscribeRequest.userRevealPushRecord();
  }
}
