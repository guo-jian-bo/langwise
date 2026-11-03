import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';

class ManageBookWordListState {
  // 是否可编辑
  final RxBool _editEnable = false.obs;

  bool get editEnable => _editEnable.value;

  set editEnable(value) => _editEnable.value = value;

  // 词汇表
  final RxList<UnitResponseEntity> _units = <UnitResponseEntity>[].obs;

  set units(value) => _units.value = value;

  List<UnitResponseEntity> get units => _units;

  // 简单词汇表
  final RxList<UnitResponseEntity> _simpleUnits = <UnitResponseEntity>[].obs;

  set simpleUnits(value) => _simpleUnits.value = value;

  List<UnitResponseEntity> get simpleUnits => _simpleUnits;

  // 选中的UnitResponseEntity
  final RxList<UnitResponseEntity> _selectedRows = <UnitResponseEntity>[].obs;

  set selectedRows(value) => _selectedRows.value = value;

  List<UnitResponseEntity> get selectedRows => _selectedRows;

  /// 排序字段similarity
  String sortField = 'similarity';

  /// 排序方向(默认升序)asc、desc
  String sortDirection = 'asc';

  /// 单元过滤
  UnitResponseEntity? unitResponseEntityFilter;
  final unitResponseEntityFilterKey = GlobalKey();

  /// 状态筛选，null表示全部状态
  String? statusFilter;
  int statusFilterIndex = 0;
  final statusFilterKey = GlobalKey();
  /// 匹配list
  var matchTypeList = [null, "已匹配", "未匹配"];
}
