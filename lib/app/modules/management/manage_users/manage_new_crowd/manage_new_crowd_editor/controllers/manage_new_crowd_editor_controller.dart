import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/activity_tags_entities.dart';

import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../controllers/manage_new_crowd_controller.dart';

class ManageNewCrowdEditorController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageNewCrowdEditorController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_NEW_CROWD_EDITOR;

  @override
  String get breadcrumbTitle => '人群编辑';

  ManageNewCrowdController? _parentController;
  ManageNewCrowdController get parentController {
    if (_parentController == null) {
      final parentTag = (Get.arguments as Map?)?['parentTag'] as String?;
      if (parentTag != null && Get.isRegistered<ManageNewCrowdController>(tag: parentTag)) {
        _parentController = Get.find<ManageNewCrowdController>(tag: parentTag);
      }
    }
    return _parentController!;
  }

  ActivityTagItemEntity? tagEntity;
  bool get isEdit => tagEntity != null;

  late final TextEditingController codeCtrl;
  late final TextEditingController nameCtrl;
  late final TextEditingController remarkCtrl;
  late final TextEditingController cronCtrl;

  late final Rx<TagTriggerTypeEnum> tagTriggerType;
  late final Rx<TagTypeEnum> tagType;
  late final Rx<ActivateTimeEnum> activateTime;
  late final Rx<ActivityTagDurationType> durationType;
  late final RxInt duration;

  final RxList<UserTagOperationPool> pools = <UserTagOperationPool>[].obs;
  final RxInt activePoolIndex = 0.obs;
  final RxList<UserTagGroupOp> poolsJoinOps = <UserTagGroupOp>[].obs;

  int _poolSeed = 0;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    final args = (Get.arguments ?? {}) as Map;
    tagEntity = args['tag'] is ActivityTagItemEntity ? (args['tag'] as ActivityTagItemEntity) : null;

    codeCtrl = TextEditingController(text: tagEntity?.code ?? '');
    nameCtrl = TextEditingController(text: tagEntity?.name ?? '');
    remarkCtrl = TextEditingController(text: tagEntity?.remark ?? '');
    cronCtrl = TextEditingController(text: tagEntity?.cron ?? '');

    tagTriggerType = parentController.tagTypeFromString(tagEntity?.tagTriggerType).obs;
    tagType = TagTypeEnum.FILTER.obs;
    activateTime = ActivateTimeEnum.FOREVER.obs;
    durationType = parentController.durationTypeFromString(tagEntity?.durationType).obs;
    duration = ((tagEntity?.duration ?? 7) > 0 ? (tagEntity?.duration ?? 7) : 7).obs;

    pools.assignAll([_createPool()]);
    activePoolIndex.value = 0;
    poolsJoinOps.assignAll(const []);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await parentController.ensureInitialized();
      if (isEdit) {
        final condition = tagEntity!.tagCondition;
        if (condition != null) {
          applyTagCondition(condition);
        } else {
          resetPools();
        }
      } else {
        resetPools();
      }
    });
  }

  UserTagOperationPool _createPool() {
    _poolSeed += 1;
    return UserTagOperationPool(id: 'editor_pool_$_poolSeed');
  }

  void resetPools() {
    pools.assignAll([_createPool()]);
    activePoolIndex.value = 0;
    poolsJoinOps.assignAll(const []);
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

  void addPool() {
    pools.add(_createPool());
    activePoolIndex.value = pools.length - 1;
    if (pools.length > 1 && poolsJoinOps.length != pools.length - 1) {
      poolsJoinOps.assignAll(List<UserTagGroupOp>.filled(pools.length - 1, UserTagGroupOp.and));
    }
  }

  void removePool(int index) {
    if (index < 0 || index >= pools.length) return;
    if (pools.length <= 1) return;
    if (pools.length > 1 && poolsJoinOps.length != pools.length - 1) {
      poolsJoinOps.assignAll(List<UserTagGroupOp>.filled(pools.length - 1, UserTagGroupOp.and));
    }

    pools.removeAt(index);

    if (pools.length <= 1) {
      poolsJoinOps.assignAll(const []);
    } else {
      final removedIndex = index.clamp(0, poolsJoinOps.length);
      if (removedIndex == 0) {
        if (poolsJoinOps.isNotEmpty) poolsJoinOps.removeAt(0);
      } else if (removedIndex >= poolsJoinOps.length) {
        if (poolsJoinOps.isNotEmpty) poolsJoinOps.removeLast();
      } else {
        poolsJoinOps.removeAt(removedIndex);
      }

      if (poolsJoinOps.length != pools.length - 1) {
        poolsJoinOps.assignAll(List<UserTagGroupOp>.filled(pools.length - 1, UserTagGroupOp.and));
      }
    }

    if (activePoolIndex.value >= pools.length) {
      activePoolIndex.value = pools.length - 1;
    }
  }

  void setPoolsJoinOp(int index, UserTagGroupOp op) {
    if (pools.length <= 1) return;
    if (poolsJoinOps.length != pools.length - 1) {
      poolsJoinOps.assignAll(List<UserTagGroupOp>.filled(pools.length - 1, UserTagGroupOp.and));
    }
    if (index < 0 || index >= poolsJoinOps.length) return;
    poolsJoinOps[index] = op;
    poolsJoinOps.refresh();
  }

  void toggleActivePoolOp() {
    final p = activePool;
    p.op.value = p.op.value == UserTagGroupOp.or ? UserTagGroupOp.and : UserTagGroupOp.or;
  }

  void addToActivePool(UserTagPoolItem item) {
    final p = activePool;
    final exists = p.selected.any((e) => e.id == item.id);
    if (exists) return;
    p.selected.add(item);
  }

  void addToPool({required int poolIndex, required UserTagPoolItem item}) {
    if (pools.isEmpty) {
      pools.assignAll([_createPool()]);
      activePoolIndex.value = 0;
    }
    if (poolIndex < 0 || poolIndex >= pools.length) return;
    final p = pools[poolIndex];
    final exists = p.selected.any((e) => e.id == item.id);
    if (exists) return;
    p.selected.add(item);
  }

  void removeFromActivePool(String itemId) {
    final p = activePool;
    p.selected.removeWhere((e) => e.id == itemId);
  }

  void removeFromPool({required int poolIndex, required String itemId}) {
    if (poolIndex < 0 || poolIndex >= pools.length) return;
    final p = pools[poolIndex];
    p.selected.removeWhere((e) => e.id == itemId);
  }

  void applyTagCondition(Map<String, dynamic> root) {
    final parsed = _parsePoolsAndJoinOpsFromCondition(root);
    final parsedPools = parsed.pools;
    pools.assignAll(parsedPools.isEmpty ? <UserTagOperationPool>[_createPool()] : parsedPools);
    poolsJoinOps.assignAll(parsed.joinOps);
    if (pools.length <= 1) {
      poolsJoinOps.assignAll(const []);
    } else if (poolsJoinOps.length != pools.length - 1) {
      poolsJoinOps.assignAll(List<UserTagGroupOp>.filled(pools.length - 1, UserTagGroupOp.and));
    }
    activePoolIndex.value = 0;
  }

  _ParsedPoolsAndJoinOps _parsePoolsAndJoinOpsFromCondition(Map<String, dynamic> root) {
    final expr = _parseExpr(root);
    if (expr == null) {
      return const _ParsedPoolsAndJoinOps([], []);
    }
    final flat = _flattenExpr(expr);
    return flat;
  }

  _Expr? _parseExpr(dynamic node) {
    final normalized = _normalizeGroup(node);
    if (normalized == null) {
      final rule = _parseRule(node);
      if (rule == null) return null;
      return _Expr.pool(op: UserTagGroupOp.or, rules: [rule]);
    }

    final poolRules = <UserTagPoolItem>[];
    for (final n in normalized.children) {
      final r = _parseRule(n);
      if (r == null) {
        poolRules.clear();
        break;
      }
      poolRules.add(r);
    }
    if (poolRules.isNotEmpty) {
      return _Expr.pool(op: normalized.op, rules: poolRules);
    }

    final children = <_Expr>[];
    for (final c in normalized.children) {
      final e = _parseExpr(c);
      if (e != null) children.add(e);
    }
    if (children.isEmpty) return null;
    var expr = children.first;
    for (int i = 1; i < children.length; i++) {
      expr = _Expr.combine(op: normalized.op, left: expr, right: children[i]);
    }
    return expr;
  }

  _ParsedPoolsAndJoinOps _flattenExpr(_Expr expr) {
    if (expr.kind == _ExprKind.pool) {
      final p = _poolFromRules(expr.poolOp!, expr.poolRules!);
      return _ParsedPoolsAndJoinOps([p], const []);
    }

    final left = _flattenExpr(expr.left!);
    final right = _flattenExpr(expr.right!);
    return _ParsedPoolsAndJoinOps(
      [...left.pools, ...right.pools],
      [...left.joinOps, expr.combineOp!, ...right.joinOps],
    );
  }

  UserTagOperationPool _poolFromRules(UserTagGroupOp op, List<UserTagPoolItem> rules) {
    final p = _createPool();
    p.op.value = op;
    p.selected.assignAll(rules);
    return p;
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
      if (value.containsKey(groupKey)) {
        return _unwrapGroupValue(value[groupKey], groupKey);
      }
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
    final op = parentController.operatorFromString(opStr);
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

    final base = parentController.poolItems.firstWhereOrNull((e) => e.fieldCode == fieldCode);
    final title = base?.title ?? fieldCode;
    final subtitleBase = base?.subtitle ?? (fieldCode);

    return UserTagPoolItem(
      id: parentController.nextSelectedId(fieldCode),
      group: base?.group ?? '基础标签',
      title: title,
      subtitle: '$subtitleBase\n${parentController.operatorToString(op)} ${parentController.formatValueForUi(value)}',
      fieldCode: fieldCode,
      op: op,
      value: value,
    );
  }

  Map<String, dynamic> _itemToDsl(UserTagPoolItem item) {
    final node = <String, dynamic>{
      'operator': parentController.operatorToString(item.op),
      'code': item.fieldCode,
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

  Map<String, dynamic> _groupToDsl(UserTagGroupOp op, List<Map<String, dynamic>> children) {
    final key = op == UserTagGroupOp.and ? r'$and' : r'$or';
    return {key: children};
  }

  Map<String, dynamic> buildTagConditionDsl() {
    if (pools.isEmpty) return {r'$and': []};

    final idx = <int>[];
    for (int i = 0; i < pools.length; i++) {
      if (pools[i].selected.isNotEmpty) idx.add(i);
    }
    if (idx.isEmpty) {
      return {r'$and': []};
    }

    if (idx.length == 1) {
      final p = pools[idx.first];
      final ruleNodes = p.selected.map(_itemToDsl).toList();
      return _groupToDsl(p.op.value, ruleNodes);
    }

    if (poolsJoinOps.length != pools.length - 1) {
      poolsJoinOps.assignAll(List<UserTagGroupOp>.filled(pools.length - 1, UserTagGroupOp.and));
    }

    Map<String, dynamic> acc;
    {
      final p = pools[idx.first];
      final ruleNodes = p.selected.map(_itemToDsl).toList();
      acc = _groupToDsl(p.op.value, ruleNodes);
    }

    for (int j = 1; j < idx.length; j++) {
      final currentIndex = idx[j];
      final opBetween = poolsJoinOps[(currentIndex - 1).clamp(0, poolsJoinOps.length - 1)];
      final p = pools[currentIndex];
      final ruleNodes = p.selected.map(_itemToDsl).toList();
      final right = _groupToDsl(p.op.value, ruleNodes);
      acc = _combineGroups(opBetween, acc, right);
    }

    return acc;
  }

  Map<String, dynamic> _combineGroups(UserTagGroupOp op, Map<String, dynamic> left, Map<String, dynamic> right) {
    final key = op == UserTagGroupOp.and ? r'$and' : r'$or';
    final children = <dynamic>[];
    if (left.containsKey(key) && left[key] is List) {
      children.addAll(left[key] as List);
    } else {
      children.add(left);
    }
    if (right.containsKey(key) && right[key] is List) {
      children.addAll(right[key] as List);
    } else {
      children.add(right);
    }
    return {key: children};
  }

  @override
  void onClose() {
    codeCtrl.dispose();
    nameCtrl.dispose();
    remarkCtrl.dispose();
    cronCtrl.dispose();
    super.onClose();
  }

  void back({dynamic result}) {
    Get.back(result: result);
  }
}

class _NormalizedGroup {
  final UserTagGroupOp op;
  final List<dynamic> children;

  const _NormalizedGroup(this.op, this.children);
}

class _ParsedPoolsAndJoinOps {
  final List<UserTagOperationPool> pools;
  final List<UserTagGroupOp> joinOps;

  const _ParsedPoolsAndJoinOps(this.pools, this.joinOps);
}

enum _ExprKind { pool, combine }

class _Expr {
  final _ExprKind kind;
  final UserTagGroupOp? poolOp;
  final List<UserTagPoolItem>? poolRules;

  final UserTagGroupOp? combineOp;
  final _Expr? left;
  final _Expr? right;

  const _Expr._({
    required this.kind,
    this.poolOp,
    this.poolRules,
    this.combineOp,
    this.left,
    this.right,
  });

  factory _Expr.pool({required UserTagGroupOp op, required List<UserTagPoolItem> rules}) {
    return _Expr._(kind: _ExprKind.pool, poolOp: op, poolRules: rules);
  }

  factory _Expr.combine({required UserTagGroupOp op, required _Expr left, required _Expr right}) {
    return _Expr._(kind: _ExprKind.combine, combineOp: op, left: left, right: right);
  }
}
