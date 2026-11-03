import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';

class ManageScanState {
  // 保存添加/排序/筛选索引
  final RxInt _filterIndex = 5.obs;
  set filterIndex(int value) => _filterIndex.value = value;
  int get filterIndex => _filterIndex.value;

  // 存储临时拍摄/选择本地的图片数据(待上传)
  final RxList<WordImageEntity> _tempScanImages = <WordImageEntity>[].obs;
  set tempScanImages(value) => _tempScanImages.value = value;
  List<WordImageEntity> get tempScanImages => _tempScanImages;

  // 词汇表(网络数据)
  final RxList<WordImageEntity> _scanImages = <WordImageEntity>[].obs;
  set scanImages(value) => _scanImages.value = value;
  List<WordImageEntity> get scanImages => _scanImages;

  final statusFilterKey = GlobalKey();

  /// 状态筛选，null表示全部状态
  ScanWordType? statusFilter;
}
