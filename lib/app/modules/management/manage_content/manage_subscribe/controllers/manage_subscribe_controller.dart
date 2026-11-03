import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/stores/base_controller.dart';
import 'package:langwise/utils/utils.dart';

import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../../../routes/routes.dart';

class ManageSubscribeController extends BaseController with ManageBreadcrumbMixin {
  final String tag;
  ManageSubscribeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SUBSCRIBE;

  @override
  String get breadcrumbTitle => '甄听';

  /// 订阅集合列表
  final RxList<ManageSubscribeEntity> collections = <ManageSubscribeEntity>[].obs;
  final RxList<ManageSubscribeGenreEntity> genres = <ManageSubscribeGenreEntity>[].obs;
  final RxInt selectedIndex = (-1).obs;
  RxString genre = ''.obs;
  RxString theme = ''.obs;
  RxInt page = 0.obs;
  RxInt num = 20.obs;
  RxInt total = 0.obs;
  RxBool isLoadingMore = false.obs;
  String? _coverKey = '';
  String? _bannerKey = '';

  String? get coverKey => _coverKey;
  String? get bannerKey => _bannerKey;

  void clearKeys() {
    _coverKey = '';
    _bannerKey = '';
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    getSubscribeList();
    getSearchBarList();
  }

  Future<String?> onAddCover(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (_) => Container(),
    );

    final String? path = await onPickFile(context: context);

    if (path == null) {
      Get.back();
      return null;
    }

    Get.back();

    onGetToken(path, callback: (String? key, int? size) {
      _coverKey = key;
    });

    return path;
  }

  Future<String?> onAddBanner(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (_) => Container(),
    );

    final String? path = await onPickFile(context: context);

    if (path == null) {
      Get.back();
      return null;
    }

    Get.back();

    onGetToken(path, callback: (String? key, int? size) {
      _bannerKey = key;
    });

    return path;
  }

  Future<void> getSubscribeList() async {
    // 并发保护：正在加载中时直接返回
    if (isLoadingMore.value) {
      return;
    }

    if (page.value == 0) {
      collections.clear();
    } else {
      if (page.value >= total.value) {
        ToastUtils.showToast(text: '没有更多了');
        return;
      }
    }

    isLoadingMore.value = true;
    try {
      final ListResponseEntity<ManageSubscribeEntity>? list = await SubscribeRequest.getRevealsList(page.value, num.value, genre: genre.value, theme: theme.value);
      total.value = list?.count ?? 0;
      if (list != null) {
        page.value += list.datas?.length ?? 0;
        collections.addAll(list.datas ?? []);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 下拉刷新：重置页码并重新拉取
  Future<void> refreshList() async {
    page.value = 0;
    await getSubscribeList();
  }

  Future<void> getSearchBarList() async {
    genres.clear();
    final list = await SubscribeRequest.getSearchBarList();
    if (list != null) {
      genres.value = list;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
