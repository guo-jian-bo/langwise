import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/utils/lock_utils.dart';

import '../../../utils/play_record_utils/play_record_utils.dart';

class SubListenDetailsController extends GetxController {
  static SubListenDetailsController get to => Get.find();

  final RxList<UserRevealDetailItemEntity> items = <UserRevealDetailItemEntity>[].obs;
  final RxInt total = 0.obs;
  final RxInt offset = 0.obs;
  final RxInt limit = 30.obs;
  final RxBool isLoading = false.obs;
  RxInt userDifficulty = 0.obs;
  RxInt settingDifficulty = 0.obs;
  final RxBool hasMore = true.obs;
  late final int collectionId;
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  List<String> difficultyList = ['Pre A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  Map<int, String> dif = {
    0: "Pre A1",
    1: "A1",
    2: "A2",
    3: "B1",
    4: "B2",
    5: "C1",
    6: "C2",
  };

  @override
  void onInit() {
    super.onInit();
    collectionId = Get.arguments['collectionId'];
    title.value = Get.arguments['title'];
    description.value = Get.arguments['description'];
    _loadMemberDifficulty().then((_) {
      loadPage(reset: true);
    });
  }

  Future<void> readReveal(UserRevealDetailItemEntity item, int index) async {
    // var mRights = await MusicRequest.isBuyReveal(data: {'type': item.contentType!, 'contentId': item.contentId!});
    var mRights = item.cardRights;
    if (mRights == null) return;
    bool lock = await LockUtils.checkLock(
      mRights,
      Get.context!,
      contentType: item.contentType,
    );
    if (lock) return;
    //更新用户信息，奶币余额
    UserStore.to.getUserInfo();

    List<Map<String, dynamic>> contents = [];
    for(int i = 0; i < items.length; i++){
      contents.add({
        "contentId": items[i].contentId,
        "contentType": items[i].contentType,
        "styleId": items[i].styleId,
        "dialect": items[i].dialect,
      });
    }

    Get.toNamed(
      Routes.LISTEN_AND_READ,
      arguments: {
        "contentId": item.contentId,
        "contentType": item.contentType,
        "contents": contents,
        "type": PlayRecordPageType.collection.value,
        "typeId": collectionId,
      },
    )!
        .then((_) {
      loadPage(reset: true);
    });
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

  Future<void> loadPage({bool reset = false}) async {
    if (isLoading.value) return;
    if (!hasMore.value && !reset) return;

    try {
      isLoading.value = true;

      if (reset) {
        offset.value = 0;
        hasMore.value = true;
        total.value = 0;
        items.clear();
      }

      final page = await SubscribeRequest.getRevealDetailsPage(
        collectionId: collectionId,
        offset: offset.value,
        limit: limit.value,
        difficulty: settingDifficulty.value,
      );

      if (page == null) {
        hasMore.value = false;
        return;
      }

      total.value = page.count ?? 0;
      final list = page.datas ?? [];
      if (list.isEmpty) {
        hasMore.value = false;
        return;
      }

      items.addAll(list);
      offset.value += limit.value;
      if (offset.value >= total.value) {
        hasMore.value = false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPage() async {
    await loadPage(reset: true);
  }
}
