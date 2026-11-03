import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:flutter/foundation.dart';

class ZhenduShowDetailController extends GetxController {
  int? contentId;
  int? collectionId;
  int? difficulty;
  String? initialCoverUrl;
  String? locate;
  int? styleId;
  String? dialect;
  /// 是否是管理端的标识
  String? traceAdminHeader;

  final RxBool isLoading = false.obs;
  final RxInt loadStatus = (-1).obs;

  final Rx<ZhenduScriptDetailEntity?> detail = Rx<ZhenduScriptDetailEntity?>(null);

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    initPage();
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args is! Map) return;
    contentId = _readInt(args, 'contentId');
    collectionId = _readInt(args, 'collectionId');
    difficulty = _readInt(args, 'difficulty');
    initialCoverUrl = _readString(args, 'initialCoverUrl');
    locate = _readString(args, 'locate');
    styleId = _readInt(args, 'styleId');
    dialect = _readString(args, 'dialect');
    traceAdminHeader = _readString(args, 'traceAdminHeader');
  }

  int? _readInt(Map args, String key) {
    final value = args[key];
    if (value is int) return value;
    return int.tryParse((value ?? '').toString().trim());
  }

  String? _readString(Map args, String key) {
    final value = (args[key] ?? '').toString().trim();
    return value.isEmpty ? null : value;
  }

  Future<void> initPage() async {
    final sid = contentId;
    if (sid == null) {
      loadStatus.value = 1;
      if (kDebugMode) debugPrint('[ZhenduShowDetail] invalid arguments: ${Get.arguments}');
      return;
    }
    isLoading.value = true;
    loadStatus.value = -1;
    ToastUtils.showLoading();
    try {
      final parameters = <String, dynamic>{};
      final locateValue = locate?.trim() ?? '';
      if (locateValue.isNotEmpty) parameters['locate'] = locateValue;
      if (styleId != null) parameters['styleId'] = styleId;
      final dialectValue = dialect?.trim() ?? '';
      if (dialectValue.isNotEmpty) parameters['dialect'] = dialectValue;
      final resp = await ZhenduRequest.getScriptDetail(
        uid: sid,
        collectionId: collectionId,
        difficulty: difficulty,
        traceAdminHeader: traceAdminHeader,
        parameters: parameters.isEmpty ? null : parameters,
      );
      if (resp == null) {
        loadStatus.value = 1;
        return;
      }
      detail.value = resp;
      loadStatus.value = 0;
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  String getPreferredCoverUrl(ZhenduScriptDetailEntity? value) {
    final initial = initialCoverUrl?.trim() ?? '';
    if (initial.isNotEmpty) return initial;
    return value?.coverUrl?.trim() ?? '';
  }
}
