import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/activity_tags_entities.dart';
import 'package:langwise/common/https/activity_tags.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../utils/manage_breadcrumb_utils.dart';

enum UserTagGroupOp {
  and,
  or,
}

enum UserTagOperator {
  eq,
  ne,
  inList,
  notInList,
  contains,
  gt,
  gte,
  lt,
  lte,
  between,
}

enum TagTriggerTypeEnum { onetime, manual, realtime, scheduled }

enum TagTypeEnum {
  TASK,
  FILTER,

}

enum ActivateTimeEnum {
  FOREVER,
  TIMELIMIT,
}


enum ActivityTagDurationType {
  day,
  week,
  month,
  quarter,
  year,
}



class UserTagPoolItem {
  final String id;
  final String group;
  final String title;
  final String subtitle;
  final String fieldCode;
  final UserTagOperator op;
  final dynamic value;

  const UserTagPoolItem({
    required this.id,
    required this.group,
    required this.title,
    required this.subtitle,
    required this.fieldCode,
    required this.op,
    required this.value,
  });
}

class UserTagOperationPool {
  final String id;
  final Rx<UserTagGroupOp> op;
  final RxList<UserTagPoolItem> selected;

  UserTagOperationPool({
    required this.id,
    UserTagGroupOp initialOp = UserTagGroupOp.or,
    List<UserTagPoolItem>? selected,
  })  : op = initialOp.obs,
        selected = (selected ?? <UserTagPoolItem>[]).obs;
}

class UserFieldValueOption {
  final String value;
  final String? description;
  final int sortOrder;

  const UserFieldValueOption({
    required this.value,
    this.description,
    required this.sortOrder,
  });
}

class UserFieldDictItem {
  final String code;
  final String name;
  final String paramType;
  final String dataType;
  final List<UserFieldValueOption> values;

  const UserFieldDictItem({
    required this.code,
    required this.name,
    required this.paramType,
    required this.dataType,
    required this.values,
  });
}

class ManageNewCrowdController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageNewCrowdController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_NEW_CROWD;

  @override
  String get breadcrumbTitle => '新建人群';

  final Completer<void> _initCompleter = Completer<void>();

  Future<void> ensureInitialized() => _initCompleter.future;

  final TextEditingController searchCtrl = TextEditingController();
  final RxString keyword = ''.obs;

  final RxList<UserTagPoolItem> poolItems = <UserTagPoolItem>[].obs;
  final RxList<UserTagOperationPool> pools = <UserTagOperationPool>[].obs;
  final RxInt activePoolIndex = 0.obs;

  // pools 之间的连接方式（默认 AND）
  final Rx<UserTagGroupOp> poolsJoinOp = UserTagGroupOp.and.obs;

  final RxList<UserFieldDictItem> fieldDict = <UserFieldDictItem>[].obs;

  final RxList<ActivityTagItemEntity> remoteTags = <ActivityTagItemEntity>[].obs;
  final RxInt remoteTagTotal = 0.obs;

  int _poolSeed = 0;
  int _selectedSeed = 0;

  String nextSelectedId(String baseId) {
    _selectedSeed += 1;
    return '${baseId}_sel_$_selectedSeed';
  }

  String tagTriggerTypeToString(TagTriggerTypeEnum type) {
    switch (type) {
      case TagTriggerTypeEnum.onetime:
        return 'ONETIME';
      case TagTriggerTypeEnum.manual:
        return 'MANUAL';
      case TagTriggerTypeEnum.realtime:
        return 'REALTIME';
      case TagTriggerTypeEnum.scheduled:
        return 'SCHEDULED';
    }
  }

  TagTriggerTypeEnum tagTypeFromString(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'ONETIME':
        return TagTriggerTypeEnum.onetime;
      case 'MANUAL':
        return TagTriggerTypeEnum.manual;
      case 'REALTIME':
        return TagTriggerTypeEnum.realtime;
      case 'SCHEDULED':
        return TagTriggerTypeEnum.scheduled;
    }
    return TagTriggerTypeEnum.onetime;
  }

  String durationTypeToString(ActivityTagDurationType type) {
    switch (type) {
      case ActivityTagDurationType.day:
        return 'DAY';
      case ActivityTagDurationType.week:
        return 'WEEK';
      case ActivityTagDurationType.month:
        return 'MONTH';
      case ActivityTagDurationType.quarter:
        return 'QUARTER';
      case ActivityTagDurationType.year:
        return 'YOUR';
    }
  }

  ActivityTagDurationType durationTypeFromString(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'DAY':
        return ActivityTagDurationType.day;
      case 'WEEK':
        return ActivityTagDurationType.week;
      case 'MONTH':
        return ActivityTagDurationType.month;
      case 'QUARTER':
        return ActivityTagDurationType.quarter;
      case 'YOUR':
      case 'YEAR':
        return ActivityTagDurationType.year;
    }
    return ActivityTagDurationType.day;
  }

  Future<bool> createRemoteTag({
    required String code,
    required String name,
    required String remark,
    required TagTypeEnum tagType,
    required TagTriggerTypeEnum tagTriggerType,
    required ActivateTimeEnum activateTime,
    String? cron,
    required int duration,
    required ActivityTagDurationType durationType,
    Map<String, dynamic>? tagCondition,
  }) async {
    if (code.trim().isEmpty) {
      ToastUtils.showToast(text: 'code 不能为空', type: ToastType.warning);
      return false;
    }
    if (name.trim().isEmpty) {
      ToastUtils.showToast(text: '名称不能为空', type: ToastType.warning);
      return false;
    }
    if (duration <= 0) {
      ToastUtils.showToast(text: 'duration 必须大于 0', type: ToastType.warning);
      return false;
    }
    if (tagTriggerType == TagTriggerTypeEnum.scheduled && (cron == null || cron.trim().isEmpty)) {
      ToastUtils.showToast(text: 'SCHEDULED 类型必须填写 cron', type: ToastType.warning);
      return false;
    }
    bool isEmpty = tagCondition?.values.first.length == 0;
    if(tagType == TagTypeEnum.FILTER && (isEmpty)) {
      ToastUtils.showToast(text: 'FILTER 类型必须填写 tagCondition', type: ToastType.warning);
      return false;
    }

    final body = <String, dynamic>{
      'code': code.trim(),
      'name': name.trim(),
      'remark': remark.trim(),
      'tagTriggerType': tagTriggerTypeToString(tagTriggerType),
      'tagType':tagType.name,
      'activateType': activateTime.name,
      'tagCondition': tagCondition ?? buildTagConditionDsl(),
      'duration': duration,
      'durationType': durationTypeToString(durationType),
    };
    if (tagTriggerType == TagTriggerTypeEnum.scheduled) {
      body['cron'] = cron!.trim();
    }

    final res = await ActivityTagsUtil.createTag(body);
    if (res == null) {
      ToastUtils.showToast(text: '创建失败', type: ToastType.error);
      return false;
    }
    // ResponseEntity code 约定：200 成功
    if (res.code != 200) {
      ToastUtils.showToast(text: res.message ?? '创建失败', type: ToastType.error);
      return false;
    }

    ToastUtils.showToast(text: '创建成功', type: ToastType.success);
    await fetchTagsPage(offset: 0, limit: 30);
    return true;
  }

  String formatValueForUi(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).join('/');
    }
    if (value is Map) {
      final min = value['min']?.toString() ?? '';
      final max = value['max']?.toString() ?? '';
      return '$min~$max';
    }
    return (value ?? '').toString();
  }

  UserTagPoolItem buildEditedItem({
    required UserTagPoolItem base,
    required UserTagOperator op,
    required dynamic value,
  }) {
    final subtitle = '${base.subtitle}\n${operatorToString(op)} ${formatValueForUi(value)}';
    return UserTagPoolItem(
      id: nextSelectedId(base.id),
      group: base.group,
      title: base.title,
      subtitle: subtitle,
      fieldCode: base.fieldCode,
      op: op,
      value: value,
    );
  }

  List<UserTagOperator> allowedOperatorsForField(String fieldCode) {
    final dict = fieldDict.firstWhereOrNull((e) => e.code == fieldCode);
    if (dict == null) return const [UserTagOperator.eq];

    switch (dict.paramType) {
      case 'MULTI_SELECT':
        return const [UserTagOperator.inList, UserTagOperator.notInList];
      case 'SINGLE_SELECT':
        return const [UserTagOperator.eq, UserTagOperator.ne];
      case 'BOOL':
        return const [UserTagOperator.eq, UserTagOperator.ne];
      case 'INPUT':
        return const [UserTagOperator.eq, UserTagOperator.ne, UserTagOperator.contains];
      case 'NUMBER':
        return const [
          UserTagOperator.eq,
          UserTagOperator.ne,
          UserTagOperator.gt,
          UserTagOperator.gte,
          UserTagOperator.lt,
          UserTagOperator.lte,
          UserTagOperator.between,
        ];
    }
    return const [UserTagOperator.eq];
  }

  dynamic defaultValueForField(String fieldCode, UserTagOperator op) {
    final dict = fieldDict.firstWhereOrNull((e) => e.code == fieldCode);
    if (dict == null) return null;

    if (dict.paramType == 'MULTI_SELECT') {
      return <String>[];
    }
    if (dict.paramType == 'SINGLE_SELECT') {
      final values = dict.values.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return values.isNotEmpty ? values.first.value : '';
    }
    if (dict.paramType == 'BOOL') {
      return true;
    }
    if (dict.paramType == 'NUMBER') {
      if (op == UserTagOperator.between) {
        return {'min': null, 'max': null};
      }
      return 0;
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    searchCtrl.addListener(() {
      keyword.value = searchCtrl.text;
    });

    pools.assignAll([_createPool()]);
    fetchParamsAndInit();
  }

  Future<void> fetchParamsAndInit() async {
    try {
      final params = await ActivityTagsUtil.paramsList();
      if (params == null) {
        ToastUtils.showToast(text: '基础标签加载失败', type: ToastType.error);
        return;
      }

      final dict = params.map((p) {
        final options = (p.values ?? const <ActivityTagParamValueEntity>[])..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
        return UserFieldDictItem(
          code: p.code ?? '',
          name: p.name ?? (p.code ?? ''),
          paramType: p.paramType ?? 'INPUT',
          dataType: p.dataType ?? 'STRING',
          values: options
              .map(
                (e) => UserFieldValueOption(
                  value: e.value ?? '',
                  description: e.description,
                  sortOrder: e.sortOrder ?? 0,
                ),
              )
              .toList(),
        );
      }).toList();

      fieldDict.assignAll(dict);

      // 左侧基础标签卡片：每个 param 一张卡，默认 op/value 给 UI 用于弹窗初始值
      poolItems.assignAll(
        dict.map((d) {
          final defaultOp = allowedOperatorsForField(d.code).first;
          final defaultValue = defaultValueForField(d.code, defaultOp);
          final subtitle = (d.values.isNotEmpty) ? d.values.map((e) => (e.description ?? e.value)).join(' / ') : (d.name);
          return UserTagPoolItem(
            id: d.code,
            group: '基础标签',
            title: d.name,
            subtitle: subtitle,
            fieldCode: d.code,
            op: defaultOp,
            value: defaultValue,
          );
        }).toList(),
      );

      await fetchTagsPage(offset: 0, limit: 30);
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  Future<void> fetchTagsPage({required int offset, required int limit}) async {
    final res = await ActivityTagsUtil.tagsPage(offset: offset, limit: limit);
    if (res == null || res.data == null) {
      ToastUtils.showToast(text: '标签列表加载失败', type: ToastType.error);
      return;
    }
    remoteTagTotal.value = res.data?.count ?? 0;
    remoteTags.assignAll(res.data?.datas ?? const <ActivityTagItemEntity>[]);
  }

  void resetPools() {
    pools.assignAll([_createPool()]);
    activePoolIndex.value = 0;
    poolsJoinOp.value = UserTagGroupOp.and;
  }

  void updateRemoteTagBasicInfoLocal({
    required ActivityTagItemEntity tag,
    required String name,
    required String remark,
  }) {
    final idx = remoteTags.indexWhere((e) {
      if (tag.uid != null && e.uid == tag.uid) return true;
      if (tag.code != null && e.code == tag.code) return true;
      return false;
    });
    if (idx < 0) return;

    final old = remoteTags[idx];
    remoteTags[idx] = ActivityTagItemEntity(
      uid: old.uid,
      code: old.code,
      name: name,
      tagTriggerType: old.tagTriggerType,
      cron: old.cron,
      remark: remark,
      tagCondition: old.tagCondition,
      duration: old.duration,
      durationType: old.durationType,
      created: old.created,
      updated: old.updated,
      access: old.access,
    );
  }

  void deleteRemoteTagLocal(ActivityTagItemEntity tag) {
    remoteTags.removeWhere((e) {
      if (tag.uid != null && e.uid == tag.uid) return true;
      if (tag.code != null && e.code == tag.code) return true;
      return false;
    });
    remoteTagTotal.value = remoteTags.length;
  }

  UserTagOperationPool _createPool() {
    _poolSeed += 1;
    return UserTagOperationPool(id: 'pool_$_poolSeed');
  }

  void addPool() {
    pools.add(_createPool());
    activePoolIndex.value = pools.length - 1;
  }

  void removePool(int index) {
    if (index < 0 || index >= pools.length) return;
    if (pools.length <= 1) return;
    pools.removeAt(index);
    if (activePoolIndex.value >= pools.length) {
      activePoolIndex.value = pools.length - 1;
    }
  }

  void setActivePool(int index) {
    if (index < 0 || index >= pools.length) return;
    activePoolIndex.value = index;
  }

  UserTagOperationPool get activePool {
    if (pools.isEmpty) {
      pools.assignAll([_createPool()]);
      activePoolIndex.value = 0;
    }
    final idx = activePoolIndex.value;
    if (idx < 0 || idx >= pools.length) return pools.first;
    return pools[idx];
  }

  void toggleActivePoolOp() {
    final p = activePool;
    p.op.value = p.op.value == UserTagGroupOp.or ? UserTagGroupOp.and : UserTagGroupOp.or;
  }

  void togglePoolsJoinOp() {
    poolsJoinOp.value = poolsJoinOp.value == UserTagGroupOp.or ? UserTagGroupOp.and : UserTagGroupOp.or;
  }

  void addToActivePool(UserTagPoolItem item) {
    final p = activePool;

    // 不做自动合并（合并交给后端）。仅按 id 防重复。
    final exists = p.selected.any((e) => e.id == item.id);
    if (exists) return;
    p.selected.add(item);
  }

  void removeFromActivePool(String itemId) {
    final p = activePool;
    p.selected.removeWhere((e) => e.id == itemId);
  }

  List<String> get groups {
    final set = poolItems.map((e) => e.group).toSet().toList();
    set.sort();
    return set;
  }

  List<UserTagPoolItem> itemsByGroup(String group) {
    final kw = keyword.value.trim().toLowerCase();
    return poolItems.where((e) {
      if (e.group != group) return false;
      if (kw.isEmpty) return true;
      return e.title.toLowerCase().contains(kw) || e.subtitle.toLowerCase().contains(kw) || e.fieldCode.toLowerCase().contains(kw);
    }).toList();
  }

  String operatorToString(UserTagOperator op) {
    switch (op) {
      case UserTagOperator.eq:
        return 'EQ';
      case UserTagOperator.ne:
        return 'NE';
      case UserTagOperator.inList:
        return 'IN';
      case UserTagOperator.notInList:
        return 'NOT_IN';
      case UserTagOperator.contains:
        return 'CONTAINS';
      case UserTagOperator.gt:
        return 'GT';
      case UserTagOperator.gte:
        return 'GTE';
      case UserTagOperator.lt:
        return 'LT';
      case UserTagOperator.lte:
        return 'LTE';
      case UserTagOperator.between:
        return 'BETWEEN';
    }
  }

  UserTagOperator? operatorFromString(String? op) {
    if (op == null) return null;
    switch (op.toUpperCase()) {
      case 'EQ':
        return UserTagOperator.eq;
      case 'NE':
        return UserTagOperator.ne;
      case 'IN':
        return UserTagOperator.inList;
      case 'NIN':
      case 'NOT_IN':
        return UserTagOperator.notInList;
      case 'CONTAINS':
        return UserTagOperator.contains;
      case 'GT':
        return UserTagOperator.gt;
      case 'GTE':
        return UserTagOperator.gte;
      case 'LT':
        return UserTagOperator.lt;
      case 'LTE':
        return UserTagOperator.lte;
      case 'BETWEEN':
        return UserTagOperator.between;
    }
    return null;
  }

  Map<String, dynamic> _ruleToDsl(UserTagPoolItem item) {
    final Map<String, dynamic> node = {
      'code': item.fieldCode,
      'operator': operatorToString(item.op),
    };
    if (item.value is List) {
      node['values'] = item.value;
    } else if (item.value is Map) {
      node.addAll(Map<String, dynamic>.from(item.value as Map));
    } else {
      node['value'] = item.value;
    }
    return {'code': node};
  }

  void applyRemoteTag(ActivityTagItemEntity tag) {
    final condition = tag.tagCondition;
    if (condition == null) {
      ToastUtils.showToast(text: 'tagCondition 为空', type: ToastType.warning);
      return;
    }
    try {
      _applyTagCondition(condition);
      ToastUtils.showToast(text: '已回填标签：${tag.name ?? tag.code ?? ''}', type: ToastType.success);
    } catch (e) {
      ToastUtils.showToast(text: '回填失败', type: ToastType.error);
    }
  }

  void _applyTagCondition(Map<String, dynamic> root) {
    final parsedPools = _parsePoolsFromCondition(root);
    pools.assignAll(parsedPools.isEmpty ? <UserTagOperationPool>[_createPool()] : parsedPools);
    activePoolIndex.value = 0;
  }

  List<UserTagOperationPool> _parsePoolsFromCondition(Map<String, dynamic> root) {
    final normalized = _normalizeGroup(root);
    if (normalized == null) return [];

    // top-level: if it's an AND of groups => map each group to a pool
    if (normalized.op == UserTagGroupOp.and) {
      final pools = <UserTagOperationPool>[];
      for (final child in normalized.children) {
        final g = _normalizeGroup(child);
        if (g == null) {
          final rule = _parseRule(child);
          if (rule != null) {
            pools.add(_poolFromRules(UserTagGroupOp.or, [rule]));
          }
          continue;
        }

        final rules = <UserTagPoolItem>[];
        for (final n in g.children) {
          final rule = _parseRule(n);
          if (rule != null) rules.add(rule);
        }
        if (rules.isNotEmpty) {
          pools.add(_poolFromRules(g.op, rules));
        }
      }
      return pools;
    }

    // otherwise treat as single pool
    final rules = <UserTagPoolItem>[];
    for (final n in normalized.children) {
      final rule = _parseRule(n);
      if (rule != null) rules.add(rule);
    }
    if (rules.isEmpty) return [];
    return <UserTagOperationPool>[_poolFromRules(normalized.op, rules)];
  }

  UserTagOperationPool _poolFromRules(UserTagGroupOp op, List<UserTagPoolItem> rules) {
    _poolSeed += 1;
    return UserTagOperationPool(
      id: 'pool_$_poolSeed',
      initialOp: op,
      selected: rules,
    );
  }

  _NormalizedGroup? _normalizeGroup(dynamic node) {
    if (node is! Map) return null;
    final map = Map<String, dynamic>.from(node);

    if (map.containsKey(r'$and')) {
      final children = _unwrapGroupValue(map[r'$and'], r'$and');
      return _NormalizedGroup(UserTagGroupOp.and, children);
    }
    if (map.containsKey(r'$or')) {
      final children = _unwrapGroupValue(map[r'$or'], r'$or');
      return _NormalizedGroup(UserTagGroupOp.or, children);
    }
    return null;
  }

  List<dynamic> _unwrapGroupValue(dynamic value, String groupKey) {
    if (value is List) return value;
    if (value is Map<String, dynamic>) {
      // backend may nest like {"$and": {"$and": [ ... ]}}
      if (value.containsKey(groupKey)) {
        return _unwrapGroupValue(value[groupKey], groupKey);
      }
      // or nest as {"$and": [ ... ]} already handled above
      return [value];
    }
    return const [];
  }

  UserTagPoolItem? _parseRule(dynamic node) {
    if (node is! Map) return null;
    final map = Map<String, dynamic>.from(node);
    final raw = map['code'];
    if (raw is! Map) return null;

    final codeObj = Map<String, dynamic>.from(raw);
    final fieldCode = codeObj['code']?.toString();
    if (fieldCode == null || fieldCode.isEmpty) return null;

    final opStr = codeObj['operator']?.toString();
    final op = operatorFromString(opStr);
    if (op == null) return null;

    dynamic value;
    if (codeObj.containsKey('values')) {
      final v = codeObj['values'];
      if (v is List) {
        value = v.map((e) => e.toString()).toList();
      }
    } else if (codeObj.containsKey('min') || codeObj.containsKey('max')) {
      value = {
        'min': codeObj['min'],
        'max': codeObj['max'],
      };
    } else if (codeObj.containsKey('value')) {
      value = codeObj['value'];
    }

    final base = poolItems.firstWhereOrNull((e) => e.fieldCode == fieldCode);
    final title = base?.title ?? fieldCode;
    final subtitleBase = base?.subtitle ?? (fieldCode);

    return UserTagPoolItem(
      id: nextSelectedId(fieldCode),
      group: base?.group ?? '基础标签',
      title: title,
      subtitle: '$subtitleBase\n${operatorToString(op)} ${formatValueForUi(value)}',
      fieldCode: fieldCode,
      op: op,
      value: value,
    );
  }

  Map<String, dynamic> _groupToDsl(UserTagGroupOp op, List<Map<String, dynamic>> children) {
    final key = op == UserTagGroupOp.and ? r'$and' : r'$or';
    return {key: children};
  }

  Map<String, dynamic> buildTagConditionDsl() {
    // pools 间按 poolsJoinOp 连接
    final nonEmptyPools = pools.where((p) => p.selected.isNotEmpty).toList();
    if (nonEmptyPools.isEmpty) {
      return {r'$and': []};
    }

    final poolNodes = nonEmptyPools.map((p) {
      final children = p.selected.map(_ruleToDsl).toList();
      return _groupToDsl(p.op.value, children);
    }).toList();

    if (poolNodes.length == 1) return poolNodes.first;
    return _groupToDsl(poolsJoinOp.value, poolNodes);
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}

class _NormalizedGroup {
  final UserTagGroupOp op;
  final List<dynamic> children;

  _NormalizedGroup(this.op, this.children);
}
