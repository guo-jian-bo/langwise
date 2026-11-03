import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/lock_entity.dart';
import 'package:langwise/common/entities/song_theme_entity.dart';
import 'package:langwise/common/entities/song_entity.dart';
import 'package:langwise/common/https/music.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:video_player/video_player.dart';

class MusicController extends GetxController with GetTickerProviderStateMixin {
  /// 搜索
  final TextEditingController searchInput = TextEditingController();

  /// 歌曲主题实体列表
  final RxList<SongThemeEntity> songThemes = <SongThemeEntity>[].obs;
  final RxList<SongGenreEntity> songGenres = <SongGenreEntity>[].obs;
  final Rx<LockEntity> rights = LockEntity().obs;

  /// 一级、二级主题展示文案
  RxList<String> themes = <String>[].obs;
  RxList<String> secondThemes = <String>[].obs;

  /// 歌曲分页列表
  final RxList<SongDetailsItem> songList = <SongDetailsItem>[].obs;
  final RxInt totalCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  int _offset = 0;
  final int _limit = 30;
  int _loadSongRequestToken = 0;

  /// 是否点击了输入框 如果点击了那么禁用页面收起键盘350毫秒 350毫秒之后再允许点击
  final RxBool isSearchClick = false.obs;
  RxString theme = "".obs;
  RxString genre = "".obs;

  /// 是否展开分类列表
  final RxBool isExpanded = false.obs;

  TabController? secondTabController;
  final RxInt secondCurrentTabIndex = 0.obs;
  RxInt selectedIndex = 0.obs;
  RxInt secondSelectedIndex = 0.obs;
  RxInt userDifficulty = 0.obs;
  RxInt settingDifficulty = 0.obs;
  List<String> difficultyList = ['Pre A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  RxString systemCondition = "".obs;

  Map<int, String> dif = {
    0: "Pre A1",
    1: "A1",
    2: "A2",
    3: "B1",
    4: "B2",
    5: "C1",
    6: "C2",
  };

  /// 执行搜索
  Future<void> searchCard(String text) async {
    loadSong(reset: true);
  }

  @override
  void onInit() {
    super.onInit();
    initPage();
  }

  initPage() {
    // initTab();
    systemCondition.value = LangPreference.fromRawValue(UserStore.to.userInfo.value.config?.extensionConfig!.translationType ?? '').langCode;
    _loadThemes();
    _loadMemberDifficulty().then((_) {
      loadSong(reset: true);
    });
  }

  Future<void> initTab() async {
    var mRights = await MusicRequest.isBuyReveal(data: {'type': "EN_SONG"});
    if (mRights == null) return;
    rights.value = mRights;
  }

  Future<void> _loadThemes() async {
    final List<SongThemeEntity>? themeList = await MusicRequest.getSongThemesList();
    if (themeList == null || themeList.isEmpty) return;

    songThemes.assignAll(themeList);

    // 一级主题：中文名
    final List<String> themeZh = <String>['全部主题'];
    if (systemCondition.value == "en") {
      themeZh.clear();
      themeZh.add('All Themes');
    }
    for (final item in songThemes) {
      final zh = _getLangText(item.name, 'zh');
      if (zh != null && zh.isNotEmpty) {
        themeZh.add(zh);
      }
    }

    themes.value = themeZh;

    // 二级曲风：中文名
    final List<SongGenreEntity>? genreList = await MusicRequest.getSongGenresList();
    songGenres.assignAll(genreList ?? []);
    final List<String> genreZh = <String>['全部'];
    if (systemCondition.value == "en") {
      genreZh.clear();
      genreZh.add('All Genres');
    }
    if (genreList != null && genreList.isNotEmpty) {
      for (final item in genreList) {
        final zh = _getLangText(item.name, 'zh');
        if (zh != null && zh.isNotEmpty) {
          genreZh.add(zh);
        }
      }
    }

    secondThemes.value = genreZh;

    // 重新初始化 TabController
    secondTabController?.dispose();

    secondTabController = TabController(length: secondThemes.length, vsync: this, initialIndex: secondCurrentTabIndex.value.clamp(0, secondThemes.length - 1));
    secondTabController?.addListener(() {
      secondCurrentTabIndex.value = secondTabController?.index ?? 0;
    });
  }

  String? _getLangText(List<LangTextEntity>? list, String lang, {bool ignore = false}) {
    if (systemCondition.value != "" && !ignore) {
      lang = systemCondition.value;
    }
    if (list == null) return null;
    for (final item in list) {
      if (item.lang == lang) return item.text;
    }
    return null;
  }

  /// 刷新歌曲列表
  Future<void> refreshSongs() async {
    await loadSong(reset: true);
  }

  Future<void> resetBySecondTheme() async {
    if (secondSelectedIndex.value == 0) {
      genre.value = '';
    } else {
      genre.value = _getLangText(songGenres[secondSelectedIndex.value - 1].name, 'en', ignore: true) ?? '';
    }
    await loadSong(reset: true);
  }

  Future<void> resetByTheme() async {
    if (selectedIndex.value == 0) {
      theme.value = '';
    } else {
      theme.value = _getLangText(songThemes[selectedIndex.value - 1].name, 'en', ignore: true) ?? '';
    }
    await loadSong(reset: true);
  }

  /// 加载歌曲分页数据
  Future<void> loadSong({bool reset = false}) async {
    // 分页加载时避免并发；但 reset（主/副标题快速切换）必须允许并发，
    // 否则会导致最后一次选择被 isLoading 拦截。
    if (!reset && isLoading.value) return;

    try {
      final int requestToken = ++_loadSongRequestToken;
      if (reset) {
        _offset = 0;
        hasMore.value = true;
        songList.clear();
      }
      if (!hasMore.value) return;

      isLoading.value = true;
      final SongDetailsPageData? page = await MusicRequest.getSongDetailsPage(
        offset: _offset,
        limit: _limit,
        genre: genre.value,
        theme: theme.value,
        title: searchInput.text.trim(),
        difficulty: settingDifficulty.value,
      );

      // 只处理最后一次请求的结果，旧请求回包直接丢弃
      if (requestToken != _loadSongRequestToken) return;

      isLoading.value = false;

      if (page == null) return;
      rights.value = page.rights!;
      totalCount.value = page.count ?? 0;
      final List<SongDetailsItem> items = (page.datas ?? <SongDetailsItem?>[]).whereType<SongDetailsItem>().toList();

      songList.addAll(items);
      _offset = songList.length;
      hasMore.value = songList.length < totalCount.value;
    } finally{
    }
  }

  /// 初始化学员难度
  Future<void> _loadMemberDifficulty() async {
    final res = await SubscribeRequest.memberDifficulty();
    if (res == null || res.data == null) return;

    final dynamic data = res.data;
    if (data is int) {
      userDifficulty.value = data;
      settingDifficulty.value = data;
    }
  }

  void freshSingleSong(SongDetailsItem item) {
    item.favourite = !item.favourite!;
    songList.refresh();
  }

  @override
  void onClose() {
    secondTabController?.dispose();
    searchInput.dispose();
    super.onClose();
  }
}
