import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/activity_tags_entities.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/commons.dart';
import '../../controllers/manage_new_crowd_controller.dart';
import '../../views/manage_new_crowd_tag_create_dialog.dart';
import '../bindings/manage_new_crowd_editor_binding.dart';
import '../controllers/manage_new_crowd_editor_controller.dart';

class ManageNewCrowdEditorView extends GetView<ManageNewCrowdEditorController> {
  final String tagText;
  const ManageNewCrowdEditorView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（兼容 ManagePageRegistry）
  static Future<T?> to<T>({dynamic arguments}) async {
    final args = arguments is Map ? arguments : <String, dynamic>{};
    final tag = '${Routes.MANAGE_NEW_CROWD_EDITOR}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageNewCrowdEditorView(tagText: tag),
      binding: ManageNewCrowdEditorBinding(tag: tag),
      routeName: Routes.MANAGE_NEW_CROWD_EDITOR,
      arguments: {
        'tag': args['tag'],
        'parentTag': args['parentTag'],
      },
      preventDuplicates: false,
    );
  }

  static const Color _bg = Color(0xFF050916);
  static const Color _panel = Color(0xFF0B1221);
  static const Color _panel2 = Color(0xFF0E172A);
  static const Color _border = Color(0x1FFFFFFF);
  static const Color _text = Color(0xFFEBEEF3);
  static const Color _text2 = Color(0xFFACB4C0);
  static const Color _primary = Color(0xFF2388FF);

  String _operatorLabel(UserTagOperator op) {
    switch (op) {
      case UserTagOperator.eq:
        return '等于';
      case UserTagOperator.ne:
        return '不等于';
      case UserTagOperator.inList:
        return '包含';
      case UserTagOperator.notInList:
        return '不包含';
      case UserTagOperator.contains:
        return '包含（模糊）';
      case UserTagOperator.gt:
        return '大于';
      case UserTagOperator.gte:
        return '大于等于';
      case UserTagOperator.lt:
        return '小于';
      case UserTagOperator.lte:
        return '小于等于';
      case UserTagOperator.between:
        return '区间';
    }
  }

  String _poolItemDisplayText(ManageNewCrowdController userController, UserTagPoolItem item) {
    final opText = _operatorLabel(item.op);
    final valueText = userController.formatValueForUi(item.value);
    if (item.op == UserTagOperator.between) {
      return '${item.title} $opText $valueText';
    }
    return '${item.title} $opText $valueText';
  }

  Future<void> _showTagEditDialogWithPool(
    BuildContext context,
    ManageNewCrowdController userController,
    UserTagPoolItem base,
    int poolIndex,
  ) async {
    final editorController = controller;
    final dict = userController.fieldDict.firstWhereOrNull((e) => e.code == base.fieldCode);
    final allowedOps = userController.allowedOperatorsForField(base.fieldCode);
    final Rx<UserTagOperator> op = (allowedOps.contains(base.op) ? base.op : allowedOps.first).obs;
    dynamic value = base.value;
    if (value == null) {
      value = userController.defaultValueForField(base.fieldCode, op.value);
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('编辑标签条件', style: TextStyle(fontSize: 14.wMin, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 560.wMin,
            child: StatefulBuilder(
              builder: (context, setState) {
                Widget valueEditor() {
                  if (dict == null) {
                    return const SizedBox.shrink();
                  }

                  if (dict.paramType == 'MULTI_SELECT') {
                    final options = dict.values.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                    final selected = (value is List) ? (value as List).map((e) => e.toString()).toSet() : <String>{};
                    return Wrap(
                      spacing: 8.wMin,
                      runSpacing: 8.wMin,
                      children: options.map((opt) {
                        final isSel = selected.contains(opt.value);
                        return FilterChip(
                          label: Text(opt.description ?? opt.value, style: TextStyle(fontSize: 12.wMin)),
                          selected: isSel,
                          onSelected: (v) {
                            final next = selected.toSet();
                            if (v) {
                              next.add(opt.value);
                            } else {
                              next.remove(opt.value);
                            }
                            setState(() {
                              value = next.toList();
                            });
                          },
                        );
                      }).toList(),
                    );
                  }

                  if (dict.paramType == 'SINGLE_SELECT') {
                    final options = dict.values.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                    final current = (value ?? (options.isNotEmpty ? options.first.value : '')).toString();
                    return DropdownButtonFormField<String>(
                      value: current,
                      isDense: true,
                      items: options.map((e) => DropdownMenuItem<String>(value: e.value, child: Text(e.description ?? e.value))).toList(),
                      onChanged: (v) {
                        setState(() {
                          value = v;
                        });
                      },
                      decoration: const InputDecoration(labelText: '值'),
                    );
                  }

                  if (dict.paramType == 'BOOL') {
                    final bool current = value is bool ? (value as bool) : (value?.toString() == 'true');
                    return DropdownButtonFormField<bool>(
                      value: current,
                      isDense: true,
                      items: const [
                        DropdownMenuItem<bool>(value: true, child: Text('true')),
                        DropdownMenuItem<bool>(value: false, child: Text('false')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          value = v;
                        });
                      },
                      decoration: const InputDecoration(labelText: '值'),
                    );
                  }

                  if (dict.paramType == 'NUMBER') {
                    if (op.value == UserTagOperator.between) {
                      final map = (value is Map) ? (value as Map) : <String, dynamic>{};
                      final minText = (map['min'] ?? '').toString();
                      final maxText = (map['max'] ?? '').toString();
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: minText,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'min'),
                              onChanged: (v) {
                                setState(() {
                                  value = {
                                    'min': int.tryParse(v),
                                    'max': int.tryParse(maxText),
                                  };
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: TextFormField(
                              initialValue: maxText,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'max'),
                              onChanged: (v) {
                                setState(() {
                                  value = {
                                    'min': int.tryParse(minText),
                                    'max': int.tryParse(v),
                                  };
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    return TextFormField(
                      initialValue: (value ?? '').toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '值'),
                      onChanged: (v) {
                        setState(() {
                          value = int.tryParse(v) ?? 0;
                        });
                      },
                    );
                  }

                  return TextFormField(
                    initialValue: (value ?? '').toString(),
                    decoration: const InputDecoration(labelText: '值'),
                    onChanged: (v) {
                      setState(() {
                        value = v;
                      });
                    },
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${base.title} (${base.fieldCode})', style: TextStyle(fontSize: 13.wMin, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12.wMin),
                    Obx(() {
                      return DropdownButtonFormField<UserTagOperator>(
                        value: op.value,
                        isDense: true,
                        items: allowedOps.map((e) => DropdownMenuItem<UserTagOperator>(value: e, child: Text(_operatorLabel(e)))).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          op.value = v;
                          setState(() {
                            value = userController.defaultValueForField(base.fieldCode, v);
                          });
                        },
                        decoration: const InputDecoration(labelText: '操作符'),
                      );
                    }),
                    SizedBox(height: 12.wMin),
                    valueEditor(),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final edited = userController.buildEditedItem(base: base, op: op.value, value: value);
                editorController.addToPool(poolIndex: poolIndex, item: edited);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('确认添加'),
            ),
          ],
        );
      },
    );
  }

  Future<int?> _showPoolPickMenu(BuildContext context, Offset globalPos) async {
    final poolCount = controller.pools.length;
    if (poolCount <= 1) return 0;
    final items = <PopupMenuEntry<int>>[];
    for (int i = 0; i < poolCount; i++) {
      items.add(
        PopupMenuItem<int>(
          value: i,
          child: Text('添加到 运算池 ${i + 1}', style: TextStyle(fontSize: 13.wMin)),
        ),
      );
    }

    final overlay = Overlay.of(context).context.findRenderObject();
    if (overlay is! RenderBox) return null;
    final local = overlay.globalToLocal(globalPos);

    return showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        local.dx,
        local.dy,
        overlay.size.width - local.dx,
        overlay.size.height - local.dy,
      ),
      items: items,
    );
  }

  Future<void> _showDslDialog(BuildContext context) async {
    final dsl = controller.buildTagConditionDsl();
    final text = const JsonEncoder.withIndent('  ').convert(dsl);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('运算结果', style: TextStyle(fontSize: 14.wMin, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 720.wMin,
            child: SelectableText(
              text,
              style: TextStyle(color: _text2, fontSize: 11.wMin, height: 1.25),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                ToastUtils.showToast(text: '已复制', type: ToastType.success);
              },
              child: const Text('复制'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  Widget _poolListCard(BuildContext context, ManageNewCrowdController userController, int index) {
    return Obx(() {
      final pools = controller.pools;
      // final activeIdx = controller.activePoolIndex.value;
      if (index < 0 || index >= pools.length) return const SizedBox.shrink();
      final pool = pools[index];

      // final isActive = activeIdx == index;

      final isAnd = pool.op.value == UserTagGroupOp.and;

      void setPoolOp(UserTagGroupOp op) {
        pool.op.value = op;
      }

      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '运算池${index + 1}',
                  style: TextStyle(color: _text, fontSize: 12.wMin, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  height: 28.wMin,
                  decoration: BoxDecoration(
                    color: _panel2,
                    borderRadius: BorderRadius.circular(8.wMin),
                    border: Border.all(color: _border, width: 1.wMin),
                  ),
                  child: ToggleButtons(
                    isSelected: [!isAnd, isAnd],
                    onPressed: (idx) {
                      if (idx == 0) {
                        setPoolOp(UserTagGroupOp.or);
                      } else {
                        setPoolOp(UserTagGroupOp.and);
                      }
                    },
                    borderRadius: BorderRadius.circular(8.wMin),
                    borderColor: Colors.transparent,
                    selectedBorderColor: Colors.transparent,
                    fillColor: _primary.withValues(alpha: 0.2),
                    constraints: BoxConstraints(minWidth: 92.wMin, minHeight: 28.wMin),
                    children: [
                      Text('池内取并集', style: TextStyle(color: !isAnd ? Color(0xFF2388FF) : _text2, fontSize: 11.wMin, fontWeight: FontWeight.w600)),
                      Text('池内取交集', style: TextStyle(color: isAnd ? Color(0xFF2388FF):_text2  , fontSize: 11.wMin, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                SizedBox(width: 8.wMin),
                if (controller.pools.length > 1)
                  GestureDetector(
                    onTap: () => controller.removePool(index),
                    child: Icon(Icons.delete_outline, size: 18.wMin, color: _text2),
                  ),
              ],
            ),
            SizedBox(height: 10.wMin),
            DragTarget<_PoolDragPayload>(
              onWillAcceptWithDetails: (details) {
                final payload = details.data;
                if (payload.fromPoolIndex == index) return false;
                return true;
              },
              onAcceptWithDetails: (details) {
                final payload = details.data;
                controller.removeFromPool(poolIndex: payload.fromPoolIndex, itemId: payload.item.id);
                controller.addToPool(poolIndex: index, item: payload.item);
              },
              builder: (context, candidates, rejects) {
                final isHover = candidates.isNotEmpty;
                return Obx(() {
                  final selected = pool.selected;
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.wMin),
                    decoration: BoxDecoration(
                      color: _panel2,
                      borderRadius: BorderRadius.circular(10.wMin),
                      border: Border.all(
                        color: isHover ? _primary.withValues(alpha: 0.9) : _border,
                        width: 1.wMin,
                      ),
                    ),
                    child: selected.isEmpty
                        ? SizedBox(
                            height: 84.wMin,
                            child: Center(
                              child: Text('请从左侧列表中添加标签', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                            ),
                          )
                        : Wrap(
                            spacing: 8.wMin,
                            runSpacing: 8.wMin,
                            children: selected.map((e) {
                              final chip = InkWell(
                                onTap: () {
                                  controller.removeFromPool(poolIndex: index, itemId: e.id);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 8.wMin),
                                  decoration: BoxDecoration(
                                    color: _panel,
                                    borderRadius: BorderRadius.circular(8.wMin),
                                    border: Border.all(color: _border, width: 1.wMin),
                                  ),
                                  child: Text(
                                    _poolItemDisplayText(userController, e),
                                    style: TextStyle(color: _text, fontSize: 12.wMin),
                                  ),
                                ),
                              );

                              return Draggable<_PoolDragPayload>(
                                data: _PoolDragPayload(fromPoolIndex: index, item: e),
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Opacity(opacity: 0.9, child: chip),
                                ),
                                childWhenDragging: Opacity(opacity: 0.35, child: chip),
                                child: chip,
                              );
                            }).toList(),
                          ),
                  );
                });
              },
            ),
          ],
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = controller.parentController;

    return ManageScaffold(
      backgroundColor: _bg,
      body: Container(
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          children: [
            SizedBox(height: 6.wMin),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.all(16.wMin),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(12.wMin),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('标签属性库', style: TextStyle(color: _text, fontSize: 16.wMin, fontWeight: FontWeight.w600)),
                          SizedBox(height: 12.wMin),
                          SizedBox(
                            height: 40.wMin,
                            child: TextField(
                              controller: userController.searchCtrl,
                              style: TextStyle(color: _text, fontSize: 12.wMin, height: 1.2),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '搜索标签或属性',
                                hintStyle: TextStyle(color: _text2, fontSize: 12.wMin),
                                filled: true,
                                fillColor: _panel2,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 10.wMin),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.wMin),
                                  borderSide: BorderSide(color: _border, width: 1.wMin),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.wMin),
                                  borderSide: BorderSide(color: _border, width: 1.wMin),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.wMin),
                                  borderSide: BorderSide(color: _primary.withValues(alpha: 0.7), width: 1.wMin),
                                ),
                                prefixIcon: Icon(Icons.search, color: _text2, size: 18.wMin),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.wMin),
                          Expanded(
                            child: Obx(() {
                              final groups = userController.groups;
                              return ListView.builder(
                                itemCount: groups.length,
                                itemBuilder: (_, index) {
                                  final g = groups[index];
                                  final items = userController.itemsByGroup(g);
                                  if (items.isEmpty) return const SizedBox.shrink();

                                  return Builder(
                                    builder: (ctx) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 14.wMin),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(g, style: TextStyle(color: _text, fontSize: 13.wMin, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 10.wMin),
                                            Wrap(
                                              spacing: 10.wMin,
                                              runSpacing: 10.wMin,
                                              children: items.map((e) {
                                                return InkWell(
                                                  onTapDown: (d) async {
                                                    final poolIndex = await _showPoolPickMenu(ctx, d.globalPosition);
                                                    if (poolIndex == null) return;
                                                    await _showTagEditDialogWithPool(ctx, userController, e, poolIndex);
                                                  },
                                                  child: Container(
                                                    width: 220.wMin,
                                                    padding: EdgeInsets.all(12.wMin),
                                                    decoration: BoxDecoration(
                                                      color: _panel2,
                                                      borderRadius: BorderRadius.circular(10.wMin),
                                                      border: Border.all(color: _border, width: 1.wMin),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(e.title, style: TextStyle(color: _text, fontSize: 12.wMin, fontWeight: FontWeight.w600)),
                                                        SizedBox(height: 6.wMin),
                                                        Text(e.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: _text2, fontSize: 11.wMin, height: 1.2)),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16.wMin),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(16.wMin),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(12.wMin),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('运算池', style: TextStyle(color: _text, fontSize: 14.wMin, fontWeight: FontWeight.w600)),
                          SizedBox(height: 12.wMin),
                          Expanded(
                            child: Obx(() {
                              final pools = controller.pools;
                              if (pools.isEmpty) {
                                return Center(child: Text('暂无运算池', style: TextStyle(color: _text2, fontSize: 12.wMin)));
                              }
                              return ListView.separated(
                                itemCount: pools.length,
                                separatorBuilder: (_, index) {
                                  if (pools.length <= 1) return SizedBox(height: 10.wMin);
                                  return Obx(() {
                                    if (controller.poolsJoinOps.length != pools.length - 1) {
                                      return SizedBox(height: 10.wMin);
                                    }

                                    final op = controller.poolsJoinOps[index];
                                    final isAnd = op == UserTagGroupOp.and;

                                    Widget buildBtn({required String text, required bool selected, required VoidCallback onTap}) {
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: onTap,
                                          child: Container(
                                            height: 36.wMin,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: selected ? _primary.withValues(alpha: 0.2) : _panel2,
                                              borderRadius: BorderRadius.circular(8.wMin),
                                              border: Border.all(color: selected ? _primary.withValues(alpha: 0.9) : _border, width: 1.wMin),
                                            ),
                                            child: Text(
                                              text,
                                              style: TextStyle(color: selected ? _primary : _text2, fontSize: 12.wMin, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10.wMin),
                                      child: Container(
                                        padding: EdgeInsets.all(10.wMin),
                                        decoration: BoxDecoration(
                                          color: _panel2,
                                          borderRadius: BorderRadius.circular(10.wMin),
                                          border: Border.all(color: _border, width: 1.wMin),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('选择运算池${index+1}和${index+2}之间关系', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                                            SizedBox(height: 10.wMin),
                                            Row(
                                              children: [
                                                buildBtn(
                                                  text: '交集',
                                                  selected: isAnd,
                                                  onTap: () => controller.setPoolsJoinOp(index, UserTagGroupOp.and),
                                                ),
                                                SizedBox(width: 10.wMin),
                                                buildBtn(
                                                  text: '并集',
                                                  selected: !isAnd,
                                                  onTap: () => controller.setPoolsJoinOp(index, UserTagGroupOp.or),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                },
                                itemBuilder: (_, index) => _poolListCard(context, userController, index),
                              );
                            }),
                          ),
                          SizedBox(height: 12.wMin),
                          GestureDetector(
                            onTap: controller.addPool,
                            child: Container(
                              height: 44.wMin,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.wMin),
                                border: Border.all(color: _border, width: 1.wMin),
                                color: _panel2,
                              ),
                              alignment: Alignment.center,
                              child: Text('+ 添加运算池', style: TextStyle(color: _text, fontSize: 13.wMin, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(height: 14.wMin),
                          Divider(color: _border, height: 1.wMin),
                          SizedBox(height: 14.wMin),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showDslDialog(context),
                                  child: Container(
                                    height: 44.wMin,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.wMin),
                                      border: Border.all(color: _border, width: 1.wMin),
                                      color: _panel2,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('查看运算结果', style: TextStyle(color: _text, fontSize: 13.wMin, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.wMin),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final infoOk = await ManageUserTagCreateDialog.show(context: context);
                                    if (infoOk != true) return;

                                    final code = controller.codeCtrl.text.trim();
                                    final name = controller.nameCtrl.text.trim();
                                    final remark = controller.remarkCtrl.text.trim();
                                    final cron = controller.cronCtrl.text.trim();

                                    if (controller.isEdit) {
                                      userController.updateRemoteTagBasicInfoLocal(tag: controller.tag as ActivityTagItemEntity, name: name, remark: remark);
                                      controller.back(result: true);
                                      return;
                                    }

                                    final ok = await userController.createRemoteTag(
                                      code: code,
                                      name: name,
                                      remark: remark,
                                      tagTriggerType: controller.tagTriggerType.value,
                                      activateTime: controller.activateTime.value,
                                      tagType: controller.tagType.value,
                                      cron: controller.tagTriggerType.value == TagTriggerTypeEnum.scheduled ? cron : null,
                                      duration: controller.duration.value,
                                      durationType: controller.durationType.value,
                                      tagCondition: controller.buildTagConditionDsl(),
                                    );
                                    if (ok) {
                                      controller.back(result: true);
                                    }
                                  },
                                  child: Container(
                                    height: 44.wMin,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.wMin),
                                      border: Border.all(color: _border, width: 1.wMin),
                                      color: _primary,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      controller.isEdit ? '保存' : '创建',
                                      style: TextStyle(color: Colors.white, fontSize: 13.wMin, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoolDragPayload {
  final int fromPoolIndex;
  final UserTagPoolItem item;

  const _PoolDragPayload({required this.fromPoolIndex, required this.item});
}
