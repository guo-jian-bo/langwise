import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:langwise/app/modules/favourite/views/edit_dialog.dart';
import 'package:langwise/app/modules/favourite/views/move_dialog.dart';
import 'package:langwise/app/modules/favourite/views/my_collection.dart';
import 'package:langwise/app/modules/favourite/views/my_playlist.dart';
import 'package:langwise/app/modules/favourite/views/recent_play.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/favourite_listen_entity.dart';
import 'package:langwise/common/entities/favourite_listen_list_detail_entity.dart';
import 'package:langwise/common/entities/song_theme_entity.dart';
import 'package:langwise/common/https/favourite.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/values/storage.dart';
import 'package:langwise/common/widgets/add_favourite_dialog.dart';
import 'package:langwise/common/widgets/delete_dialog.dart';
import 'package:langwise/common/widgets/parent_password_dialog.dart';
import 'package:langwise/utils/jump_page_utils.dart';
import 'package:langwise/utils/lock_utils.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../utils/play_record_utils/play_record_utils.dart';

class FavouriteController extends GetxController with GetTickerProviderStateMixin {
  List<String> titleList = const ["默认收藏", "我的听单"];
  RxInt selectedIndex = 0.obs;
  RxList<FavouriteListenListDetailItemEntity> listenListDetail = <FavouriteListenListDetailItemEntity>[].obs;
  final RxInt listenListDetailVersion = 0.obs;
  RxList<FavouriteListenListTypeEntity> listenListTypes = <FavouriteListenListTypeEntity>[].obs;
  RxList<FavouriteListenEntity> playList = <FavouriteListenEntity>[].obs;
  RxBool isPlayListEditMode = false.obs;
  RxSet<int> selectedPlayListIds = <int>{}.obs;
  Widget child = const MyCollection();
  TabController? secondTabController;
  final RxInt secondCurrentTabIndex = 0.obs;
  List<String> difficultyList = ['Pre A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  RxInt offset = 0.obs;
  RxInt limit = 30.obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;
  RxInt maxPlayListCount = 5.obs;

  final EasyRefreshController playListRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  final RxInt playListOffset = 0.obs;
  final RxInt playListLimit = 30.obs;
  final RxInt playListTotalCount = 0.obs;
  final RxBool isPlayListLoading = false.obs;

  bool get hasMorePlayList => playListTotalCount.value > playList.length;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    secondCurrentTabIndex.value = 0;
    await getListenListDetail(0, '', reset: true);
  }

  changeIndex(int idx) async {
    selectedIndex.value = idx;
    if (idx != 1) {
      isPlayListEditMode.value = false;
      selectedPlayListIds.clear();
    }
    if (idx == 0) {
      child = const MyCollection();
      initData();
    } else if (idx == 1) {
      child = const MyPlayList();
      await refreshMyPlayList();
    } else {
      child = const RecentPlay();
    }
  }

  Future<void> getListenListDetail(int playListId, String type, {bool reset = false}) async {
    if (isLoading.value) return;
    if (reset) {
      offset.value = 0;
      hasMore.value = true;
      listenListDetail.clear();
      listenListDetailVersion.value++;
    }
    if (!hasMore.value) return;

    isLoading.value = true;
    var res = await FavouriteRequest.getListenListDetail(playListId: playListId, type: type, offset: offset.value, limit: limit.value);
    if (res != null) {
      // 处理返回的数据
      listenListTypes.clear();
      listenListTypes.add(FavouriteListenListTypeEntity(type: '', titles: [
        const LangTextEntity(lang: 'zh', text: '全部'),
        const LangTextEntity(lang: 'en', text: 'All'),
      ]));
      listenListTypes.addAll(res.types ?? []);

      listenListDetail.addAll(res.datas ?? []);
      offset.value += limit.value;
      if ((res.count ?? 0) <= offset.value) {
        hasMore.value = false;
      }
      // 重新初始化 TabController
      secondTabController?.dispose();

      secondTabController = TabController(length: listenListTypes.length, vsync: this, initialIndex: secondCurrentTabIndex.value.clamp(0, listenListTypes.length - 1));
      secondTabController?.addListener(() {
        secondCurrentTabIndex.value = secondTabController?.index ?? 0;
      });
      isLoading.value = false;
    }
  }

  //获取听单列表
  Future<List<FavouriteListenEntity>> getMyPlayList() async {
    await refreshMyPlayList();
    return playList;
  }

  Future<void> refreshMyPlayList() async {
    if (isPlayListLoading.value) {
      playListRefreshController.finishRefresh(IndicatorResult.none);
      return;
    }
    try {
      isPlayListLoading.value = true;
      playListOffset.value = 0;
      playList.clear();
      final res = await FavouriteRequest.getListenListPages(
        offset: playListOffset.value,
        limit: playListLimit.value,
      );
      if (res != null) {
        playList.addAll(res.datas ?? []);
        playListTotalCount.value = res.count ?? 0;
        maxPlayListCount.value = res.maxCount ?? 0;
      }
    } catch (e) {
      playListRefreshController.finishRefresh(IndicatorResult.fail);
    } finally {
      playListRefreshController.finishRefresh(IndicatorResult.none);
      isPlayListLoading.value = false;
    }
  }

  Future<void> loadMoreMyPlayList() async {
    if (isPlayListLoading.value) {
      playListRefreshController.finishLoad(IndicatorResult.none);
      return;
    }
    if (!hasMorePlayList) {
      playListRefreshController.finishLoad(IndicatorResult.none);
      return;
    }
    try {
      isPlayListLoading.value = true;
      final nextOffset = playListOffset.value + playListLimit.value;
      final res = await FavouriteRequest.getListenListPages(
        offset: nextOffset,
        limit: playListLimit.value,
      );
      if (res != null) {
        playListOffset.value = nextOffset;
        playList.addAll(res.datas ?? []);
        playListTotalCount.value = res.count ?? playListTotalCount.value;
        maxPlayListCount.value = res.maxCount ?? maxPlayListCount.value;
      }
    } catch (e) {
      playListRefreshController.finishLoad(IndicatorResult.fail);
    } finally {
      playListRefreshController.finishLoad(IndicatorResult.none);
      isPlayListLoading.value = false;
    }
  }

  Future<void> togglePlayListEditMode() async {
    if (!isPlayListEditMode.value) {
      var isAllowed = await ParentPasswordialog.show(context: Get.context!);
      if (!isAllowed) return;
    }

    isPlayListEditMode.value = !isPlayListEditMode.value;
    if (!isPlayListEditMode.value) {
      selectedPlayListIds.clear();
    } else {}
  }

  void togglePlayListSelected(int uid) {
    if (selectedPlayListIds.contains(uid)) {
      selectedPlayListIds.remove(uid);
    } else {
      selectedPlayListIds.add(uid);
    }
  }

  void selectAllPlayLists() {
    final ids = playList.map((e) => e.uid).whereType<int>().toSet();
    selectedPlayListIds
      ..clear()
      ..addAll(ids);
  }

  void clearPlayListSelection() {
    selectedPlayListIds.clear();
  }

  bool get isAllPlayListsSelected {
    final ids = playList.map((e) => e.uid).whereType<int>().toSet();
    if (ids.isEmpty) return false;
    return selectedPlayListIds.containsAll(ids);
  }

  Future<void> deleteSelectedPlayLists() async {
    if (selectedPlayListIds.isEmpty) return;
    bool res = await DeleteDialog.show(
      context: Get.context!,
      title: "删除听单",
      subTitle: "确认要删除选中的听单吗？",
    );
    if (!res) return;

    final ids = selectedPlayListIds.toList();
    final bool ok = await FavouriteRequest.batchRemoveListenList(uid: ids);
    if (!ok) return;

    ToastUtils.showToast(text: "删除成功", type: ToastType.success);
    selectedPlayListIds.clear();
    await refreshMyPlayList();
  }

  // 更新听单信息弹窗
  Future<void> updatePlayList(FavouriteListenEntity entity) async {
    if (entity.uid == null) return;
    String? res = await PlayListEditDialog.show(Get.context!, entity);
    if (res != "") {
      //刷新列表
      entity.name = res;
      playList.refresh();
    }
  }

  //编辑听单信息
  Future<bool> editPlayList(int uid, String name, String description) async {
    var res = await FavouriteRequest.editListenList(uid: uid, name: name, description: description);
    if (res != null) {
      return true;
    } else {
      return false;
    }
  }

  //新建听单
  Future<bool> createPlayList(String name, String des) async {
    var res = await FavouriteRequest.createListenList(name: name, description: des);
    if (res != null) {
      return true;
    } else {
      return false;
    }
  }

  //添加收藏
  Future<bool> addContent(int playListId, int uid, String type) async {
    var res = await FavouriteRequest.addContent(playListId: playListId, uid: uid, type: type);
    return res;
  }

  //批量添加收藏
  Future<bool> addContentBatch(List<int> playListIds, int uid, String type) async {
    if (playListIds.isEmpty) return true;
    final results = await Future.wait(playListIds.map((id) => addContent(id, uid, type)));
    return results.every((e) => e == true);
  }

  //显示听单详情
  Future<void> showPlayListDetail(FavouriteListenEntity entity) async {
    secondCurrentTabIndex.value = 0;
    await getListenListDetail(entity.uid!, '', reset: true);
    Get.to(() => MyCollection(entity: entity))?.then((_) async {
      // await refreshMyPlayList();
    });
  }

  //播放听单
  Future<void> playAll(FavouriteListenEntity entity) async {
    var res = await FavouriteRequest.getListenListDetail(playListId: entity.uid!, type: '', offset: 0, limit: 9999);
    if (res != null) {
      List<Map<String, dynamic>> params = [];
      var datas = res.datas ?? [];
      if (datas.isEmpty) {
        ToastUtils.showToast(text: "听单为空", type: ToastType.info);
        return;
      }
      for (var d in datas) {
        params.add({
          "contentId": d.contentId,
          "contentType": d.contentType,
        });
      }
      JumpPageUtils.jumpSongMv(
        contents: params,
        contentId: datas.first.contentId,
        contentType: datas.first.contentType,
        type: PlayRecordPageType.favorite,
        typeId: entity.uid,
      ).then((_) async {
        await refreshMyPlayList();
      });
    }
  }

  //播放歌曲
  Future<void> songPlay(FavouriteListenListDetailItemEntity song, FavouriteListenEntity? entity) async {
    bool experience = await LockUtils.checkExperienceApp(Get.context!);
    if (experience) return;
    List<Map<String, dynamic>> songParam = [];
    for (var lisDetail in listenListDetail) {
      songParam.add({
        "contentId": lisDetail.contentId,
        "contentType": lisDetail.contentType,
      });
    }
    JumpPageUtils.jumpSongMv(
      contents: songParam, 
      contentId: song.contentId, 
      contentType: song.contentType,
      type: PlayRecordPageType.favorite,
      typeId: entity == null ? 0 : entity.uid,
    ).then((_) {
      getListenListDetail(entity == null ? 0 : entity.uid!, listenListTypes[secondCurrentTabIndex.value].type ?? '', reset: true);
    });
  }

  //播放文章
  Future<void> readReveal(FavouriteListenListDetailItemEntity item, FavouriteListenEntity? entity) async {
    var mRights = item.cardRights;
    if (mRights == null) return;
    bool lock = await LockUtils.checkLock(
      mRights,
      Get.context!,
      hintStorageKey: SPECIAL_PAY_NOT_REMIND_KEY,
    );
    if (lock) return;
    //更新用户信息，奶币余额
    UserStore.to.getUserInfo();
    List<Map<String, dynamic>> revealParam = [];
    for (var lisDetail in listenListDetail) {
      revealParam.add({
        "contentId": lisDetail.contentId,
        "contentType": lisDetail.contentType,
      });
    }
    Get.toNamed(
      Routes.LISTEN_AND_READ,
      arguments: {
        "contentId": item.contentId,
        "contentType": item.contentType,
        "contents": revealParam,
        "type": PlayRecordPageType.favorite.value,
        "typeId": entity == null ? 0 : entity.uid,
      },
    )!
        .then((_) {
      getListenListDetail(entity == null ? 0 : entity.uid!, listenListTypes[secondCurrentTabIndex.value].type ?? '', reset: true);
    });
  }

  //刷新单个听单
  void freshSingle(FavouriteListenListDetailItemEntity item, bool isPlayList) {
    final idx = listenListDetail.indexWhere(
      (e) => e.contentId == item.contentId && e.contentType == item.contentType,
    );
    if (idx < 0) return;

    if (isPlayList) {
      final current = listenListDetail[idx].isFavourited ?? false;
      listenListDetail[idx].isFavourited = !current;
    } else {
      listenListDetail.removeAt(idx);
    }
    listenListDetail.refresh();
  }

  //听单排序
  Future<void> orderPlayList(int index, int uid) async {
    await FavouriteRequest.sortListenList(index: index, uid: uid);
    // refreshMyPlayList();
  }

  //删除听单
  Future<void> deletePlayList(int uid) async {
    var isAllowed = await ParentPasswordialog.show(context: Get.context!);
    if (!isAllowed) return;
    bool res = await DeleteDialog.show(
      context: Get.context!,
      title: "删除听单",
      subTitle: "确认要删除当前听单吗？",
    );
    if (!res) return;
    var result = await FavouriteRequest.removeListenList(uid: uid);
    if (!result) return;
    ToastUtils.showToast(text: "删除成功", type: ToastType.success);
    getMyPlayList();
  }

  //从听单中删除
  Future<void> remove(int playListId, int contentId, String contentType) async {
    String des = contentType == 'EN_SONG'
        ? '歌曲'
        : contentType == 'EN_REVEAL'
            ? '甄听专栏'
            : '文章';
    bool res = await DeleteDialog.show(
      context: Get.context!,
      title: "删除$des",
      subTitle: "确认要删除当前$des吗？",
    );
    if (!res) return;
    var result = await FavouriteRequest.removeContent(playListId: playListId, uid: contentId, type: contentType);
    if (!result) return;
    ToastUtils.showToast(text: "删除成功", type: ToastType.success);
    playList.where((e) => e.uid == playListId).forEach((e) {
      int cnt = e.contentCount ?? 1;
      e.contentCount = cnt - 1;
    });
    playList.refresh();
    getListenListDetail(playListId, contentType, reset: true);
  }

  //听单内容迁移
  Future<void> moveToPlayList(FavouriteListenListDetailItemEntity item) async {
    MovePlayListDialog.show(Get.context!, item.contentId!, item.contentType!);
  }

  Future<void> collectTo(FavouriteListenListDetailItemEntity item, int playListId) async {
    AddFavouriteDialog.show(
      Get.context!,
      item.contentId!,
      item.contentType!,
      playListId: playListId,
      isNew: false,
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    secondTabController?.dispose();
    playListRefreshController.dispose();
    super.onClose();
  }
}
