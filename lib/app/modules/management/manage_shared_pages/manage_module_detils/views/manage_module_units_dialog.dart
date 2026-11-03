import 'dart:convert';
import 'dart:io';

import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../utils/utils.dart';

class ManageModuleUnitsDialog {
  static Future<void> show({
    required BuildContext context,
    required List<NewUnitResponseEntity<LessonResponseEntity>> units,
  }) {
    return Get.dialog<void>(
      Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff040712).withValues(alpha: 0.8),
        child: UnconstrainedBox(
          alignment: Alignment.center,
          child: _ManageModuleUnitsDialogWidget(
            units: units,
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );
  }
}

class _ManageModuleUnitDialogItem {
  const _ManageModuleUnitDialogItem({
    required this.unit,
    required this.key,
  });

  final NewUnitResponseEntity<LessonResponseEntity> unit;
  final String key;
}

class _ManageModuleUnitsDialogWidget extends StatefulWidget {
  final List<NewUnitResponseEntity<LessonResponseEntity>> units;

  const _ManageModuleUnitsDialogWidget({
    required this.units,
  });

  @override
  State<_ManageModuleUnitsDialogWidget> createState() => _ManageModuleUnitsDialogWidgetState();
}

class _ManageModuleUnitsDialogWidgetState extends State<_ManageModuleUnitsDialogWidget> {
  late final List<_ManageModuleUnitDialogItem> _items;
  int? _debugDragIndex;
  bool _debugDidLogProxyBuild = false;
  bool _debugDidLogPlaceholder = false;
  bool _debugDidLogDraggedItemRebuild = false;

  @override
  void initState() {
    super.initState();
    _items = widget.units
        .map(
          (unit) => _ManageModuleUnitDialogItem(
            unit: unit,
            key: 'unit_${unit.uid}',
          ),
        )
        .toList(growable: true);
  }

  void _debugLog(
    String hypothesisId,
    String message, {
    Map<String, dynamic>? data,
  }) {
    Future<void>(() async {
      String serverUrl = 'http://127.0.0.1:7777/event';
      String sessionId = 'unit-drag-flicker';
      try {
        final String envText = await File('.dbg/unit-drag-flicker.env').readAsString();
        for (final String line in envText.split('\n')) {
          if (line.startsWith('DEBUG_SERVER_URL=')) {
            serverUrl = line.substring('DEBUG_SERVER_URL='.length).trim();
          } else if (line.startsWith('DEBUG_SESSION_ID=')) {
            sessionId = line.substring('DEBUG_SESSION_ID='.length).trim();
          }
        }
      } catch (_) {}
      try {
        final HttpClient client = HttpClient();
        final HttpClientRequest request = await client.postUrl(Uri.parse(serverUrl));
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode({
          'sessionId': sessionId,
          'runId': 'pre-fix',
          'hypothesisId': hypothesisId,
          'location': 'manage_module_units_dialog.dart',
          'msg': '[DEBUG] $message',
          'data': data ?? <String, dynamic>{},
          'ts': DateTime.now().millisecondsSinceEpoch,
        }));
        await request.close();
        client.close(force: true);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 1320.wMin,
        height: 860.wMin,
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          color: const Color(0xff181B25),
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
        ),
        child: Column(
          children: [
            ManageTitleWidget(
              title: '管理单元',
              onCloseTap: () {
                Get.back();
              },
            ),
            SizedBox(height: 24.wMin),
            Expanded(
              child: AnimatedReorderableGridView<_ManageModuleUnitDialogItem>(
                items: _items,
                padding: EdgeInsets.zero,
                shrinkWrap: false,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                dragStartDelay: const Duration(milliseconds: 200),
                insertDuration: const Duration(milliseconds: 200),
                removeDuration: const Duration(milliseconds: 200),
                sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 18.wMin,
                  mainAxisSpacing: 18.wMin,
                  childAspectRatio: 1,
                ),
                isSameItem: (a, b) => a.key == b.key,
                proxyDecorator: _proxyDecorator,
                onReorderStart: (index) {
                  _debugDragIndex = index;
                  _debugDidLogProxyBuild = false;
                  _debugDidLogPlaceholder = false;
                  _debugDidLogDraggedItemRebuild = false;
                  // #region debug-point A:drag-start
                  _debugLog(
                    'A',
                    'drag started',
                    data: {
                      'index': index,
                      'itemKey': index >= 0 && index < _items.length ? _items[index].key : null,
                    },
                  );
                  // #endregion
                },
                onReorderEnd: (index) {
                  // #region debug-point A:drag-end
                  _debugLog(
                    'A',
                    'drag ended',
                    data: {
                      'index': index,
                      'itemKey': index >= 0 && index < _items.length ? _items[index].key : null,
                    },
                  );
                  // #endregion
                  _debugDragIndex = null;
                  _debugDidLogProxyBuild = false;
                  _debugDidLogPlaceholder = false;
                  _debugDidLogDraggedItemRebuild = false;
                },
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < 0 || oldIndex >= _items.length) return;
                  var targetIndex = newIndex;
                  if (targetIndex < 0) targetIndex = 0;
                  if (targetIndex >= _items.length) targetIndex = _items.length - 1;
                  setState(() {
                    final item = _items.removeAt(oldIndex);
                    _items.insert(targetIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  if (_debugDragIndex == index && !_debugDidLogDraggedItemRebuild) {
                    _debugDidLogDraggedItemRebuild = true;
                    // #region debug-point A:dragged-item-rebuild
                    _debugLog(
                      'A',
                      'dragged item rebuilt in grid',
                      data: {
                        'index': index,
                        'itemKey': item.key,
                      },
                    );
                    // #endregion
                  }
                  return KeyedSubtree(
                    key: ValueKey(item.key),
                    child: _buildGridItem(item.unit, index),
                  );
                },
              ),
            ),
            SizedBox(height: 24.wMin),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(NewUnitResponseEntity<LessonResponseEntity> unit, int index) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.wMin),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.wMin,
            ),
            color: const Color(0xff111626),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildCover(unit.coverUrl, index),
              Positioned(
                left: 12.wMin,
                top: 12.wMin,
                child: StatusTagDifficultyWidget(
                  difficulty: unit.difficulty?.min,
                  language: unit.language,
                ),
              ),
              Positioned(
                right: 12.wMin,
                top: 12.wMin,
                child: Container(
                  height: 34.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1.wMin,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/manage/icon_drag.svg",
                        width: 18.wMin,
                        height: 18.wMin,
                      ),
                      SizedBox(width: 4.wMin),
                      Text(
                        '拖动',
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(14.wMin, 28.wMin, 14.wMin, 14.wMin),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0),
                        Colors.black.withValues(alpha: 0.82),
                      ],
                    ),
                  ),
                  child: Text(
                    unit.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(String? url, int index) {
    if ((url ?? '').isEmpty) {
      return Container(
        color: const Color(0xff151B2A),
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: 42.wMin,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      );
    }
    return CachedImageWidget(
      url ?? '',
      fit: BoxFit.cover,
        gaplessPlayback: true,
      errorWidget: Container(
        color: const Color(0xff151B2A),
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          size: 42.wMin,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
        placeholder: Builder(
          builder: (context) {
            if (_debugDragIndex == index && !_debugDidLogPlaceholder) {
              _debugDidLogPlaceholder = true;
              // #region debug-point B:placeholder-hit
              _debugLog(
                'B',
                'dragged item cover hit placeholder',
                data: {
                  'index': index,
                  'url': url,
                },
              );
              // #endregion
            }
            return Container(
              color: const Color(0xff151B2A),
            );
          },
        ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '拖到目标单元左侧插入•共${_items.length}个单元',
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        ManageButton(
          text: '取消',
          width: 108.wMin,
          height: 44.wMin,
          color: const Color(0xff23283D),
          borderColor: const Color(0xff4B5268),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 12.wMin),
        ManageButton(
          text: '保存排序',
          width: 132.wMin,
          height: 44.wMin,
          color: const Color(0xff2388FF),
          borderColor: Colors.transparent,
          onTap: () {
            ToastUtils.showToast(text: '保存排序暂未接入');
          },
        ),
      ],
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    if (_debugDragIndex == index && !_debugDidLogProxyBuild) {
      _debugDidLogProxyBuild = true;
      // #region debug-point D:proxy-build
      _debugLog(
        'D',
        'proxy decorator first build',
        data: {
          'index': index,
          'animationValue': animation.value,
        },
      );
      // #endregion
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          elevation: 10,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16.wMin),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: child,
    );
  }
}
