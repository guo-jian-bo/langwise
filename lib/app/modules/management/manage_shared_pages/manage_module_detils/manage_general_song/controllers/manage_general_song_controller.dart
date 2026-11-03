import 'dart:math';

import 'package:api/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:langwise/common/entities/song_theme_entity.dart';
import 'package:langwise/utils/utils.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageGeneralSongController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageGeneralSongController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_GENERAL_SONG_PAGE;

  @override
  String get breadcrumbTitle => '生成歌曲';

  RxInt unitId = 0.obs;
  RxInt songNumber = 1.obs;
  RxInt songMin = 1.obs;
  RxInt songMax = 1.obs;
  RxInt isPlaying = (-1).obs;
  TextEditingController songNumberController = TextEditingController();

  /// 单元歌曲完整信息
  final Rx<SongGenresResponseEntity?> songUnitInfo = Rx<SongGenresResponseEntity?>(null);

  /// 选中的歌曲风格索引集合
  final RxSet<int> selectedGenreIndexes = <int>{}.obs;

  void subSong() {
    songNumber.value = max(songMin.value, songNumber.value - 1);
    songNumberController.text = songNumber.value.toString();
  }

  /// 切换单个风格选中状态
  void toggleGenre(int index) {
    if (selectedGenreIndexes.contains(index)) {
      selectedGenreIndexes.remove(index);
    } else {
      selectedGenreIndexes.add(index);
    }
    songMax.value = min(10, max(1, selectedGenreIndexes.length));
    songNumber.value = min(10, max(1, selectedGenreIndexes.length));
    songNumberController.text = songNumber.value.toString();
  }

  /// 全选 / 取消全选
  void toggleAllGenres() {
    final genres = songUnitInfo.value?.genres;
    if (genres == null || genres.isEmpty) return;
    if (selectedGenreIndexes.length == genres.length) {
      selectedGenreIndexes.clear();
    } else {
      selectedGenreIndexes
        ..clear()
        ..addAll(List<int>.generate(genres.length, (index) => index));
    }
    songMax.value = min(10, max(1, selectedGenreIndexes.length));
    songNumber.value = min(10, max(1, selectedGenreIndexes.length));
    songNumberController.text = songNumber.value.toString();
  }

  void addSong() {
    songNumber.value = min(songMax.value, songNumber.value + 1);
    songNumberController.text = songNumber.value.toString();
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    unitId.value = Get.arguments['unitId'] as int;
    initPageData();
  }

  initPageData() async {
    var res = await songGenres(config: RequestConfig(requireToken: true, requireCache: true), unitId: unitId.value);
    songUnitInfo.value = res.data!;
  }

  /// 获取单元歌曲信息 + 歌曲风格列表的合并数据
  static Future<ResponseEntity<SongGenresResponseEntity>> songGenres({
    required int unitId,
    required RequestConfig config,
  }) async {
    final response = await WiseHttp().request(
      "/course-console/course/unit/$unitId/song/genres",
      Method.post,
      data: config.data,
      requireToken: config.requireToken,
      requireCache: config.requireCache,
      headers: config.headers,
    );

    return ResponseEntity<SongGenresResponseEntity>.fromJson(
      response,
      fromJson: (json) => SongGenresResponseEntity.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> createSongs() async {
    if (selectedGenreIndexes.isEmpty) {
      ToastUtils.showManageToast(text: '请至少选择一种风格');
      return;
    }
    try {
      var config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          "numberOfSongs": songNumber.value,
          "moduleId": songUnitInfo.value!.unitKnowledgeDTO!.moduleId ?? 0,
          "genres": selectedGenreIndexes.map((e) => songUnitInfo.value?.genres![e].name!.first.text).toList(),
        },
      );
      final response = await WiseHttp().request(
        "/course-console/course/unit/${unitId.value}/song/generate",
        Method.post,
        data: config.data,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: config.headers,
      );

      if (response == null) return;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return;
      } else {
        ToastUtils.showManageToast(
          text: "开始生成",
          type: ManageToastType.aiComplete,
        );
        Get.back(result: true);
      }
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return;
    }
  }

  @override
  void onClose() {
    songNumberController.dispose();
    super.onClose();
  }
}
