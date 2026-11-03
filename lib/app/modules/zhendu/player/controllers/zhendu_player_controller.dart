import 'dart:async';

import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

enum ZhenduLearnMode {
  listen('listen', '听'),
  read('read', '读'),
  watch('watch', '看'),
  perform('perform', '演'),
  practice('practice', '练');

  final String type;
  final String zhName;
  const ZhenduLearnMode(this.type, this.zhName);

  static ZhenduLearnMode? fromType(String? type) {
    if (type == null) return null;
    for (final v in values) {
      if (v.type == type) return v;
    }
    return null;
  }
}

class ZhenduPlayerController extends GetxController {
  final int scriptId;
  final String initialMode;

  ZhenduPlayerController({
    required this.scriptId,
    required this.initialMode,
  });

  final RxBool isLoading = false.obs;
  final RxInt loadStatus = (-1).obs;

  final Rx<ZhenduScriptDetailEntity?> detail = Rx<ZhenduScriptDetailEntity?>(null);
  final Rx<ZhenduLearnMode> mode = ZhenduLearnMode.watch.obs;

  final RxBool systemUiVisible = true.obs;
  Timer? _autoHideTimer;

  final RxBool isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    mode.value = ZhenduLearnMode.fromType(initialMode) ?? ZhenduLearnMode.watch;
    initPage();
  }

  @override
  void onClose() {
    _autoHideTimer?.cancel();
    super.onClose();
  }

  Future<void> initPage() async {
    isLoading.value = true;
    loadStatus.value = -1;
    try {
      final resp = await ZhenduRequest.getScriptDetail(uid: scriptId);
      if (resp == null) {
        loadStatus.value = 1;
        return;
      }
      detail.value = resp;
      loadStatus.value = 0;
      _refreshSystemUiPolicy();
    } finally {
      isLoading.value = false;
    }
  }

  void togglePlay() {
    isPlaying.value = !isPlaying.value;
    onUserInteraction();
  }

  void onUserInteraction() {
    final alwaysVisible = _isSystemUiAlwaysVisibleMode(mode.value);
    if (alwaysVisible) {
      systemUiVisible.value = true;
      _autoHideTimer?.cancel();
      return;
    }
    systemUiVisible.value = true;
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      systemUiVisible.value = false;
    });
  }

  void toggleSystemUi() {
    final alwaysVisible = _isSystemUiAlwaysVisibleMode(mode.value);
    if (alwaysVisible) return;
    systemUiVisible.value = !systemUiVisible.value;
    if (systemUiVisible.value) {
      onUserInteraction();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  void switchMode(ZhenduLearnMode next) {
    if (mode.value == next) return;
    if (!isModeAvailable(next)) {
      final item = findLearnItem(next);
      final tip = (item?.learnTip ?? item?.statusTip ?? '').trim();
      ToastUtils.showToast(text: tip.isEmpty ? '${next.zhName}模式暂未开放' : tip);
      return;
    }
    mode.value = next;
    _refreshSystemUiPolicy();
  }

  void openReadMode() {
    switchMode(ZhenduLearnMode.read);
  }

  ZhenduLearnItemEntity? findLearnItem(ZhenduLearnMode target) {
    final items = detail.value?.learnItems ?? const <ZhenduLearnItemEntity>[];
    for (final item in items) {
      if (item.type == target.type) return item;
    }
    return null;
  }

  bool isModeAvailable(ZhenduLearnMode target) {
    return (findLearnItem(target)?.status ?? 0) == 1;
  }

  void _refreshSystemUiPolicy() {
    if (_isSystemUiAlwaysVisibleMode(mode.value)) {
      systemUiVisible.value = true;
      _autoHideTimer?.cancel();
      return;
    }
    systemUiVisible.value = true;
    onUserInteraction();
  }

  bool _isSystemUiAlwaysVisibleMode(ZhenduLearnMode m) {
    return m == ZhenduLearnMode.read || m == ZhenduLearnMode.practice;
  }
}
