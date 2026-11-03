import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/generated/assets.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:uuid/uuid.dart';

class SortPopupEntity {
  final String title;
  final String uniqueId;

  SortPopupEntity(this.title, {String? uniqueId}) : uniqueId = uniqueId ?? const Uuid().v6();
}

class SortPopupWindow {
  static void show({
    required BuildContext context,
    required List<SortPopupEntity> list,
    required GlobalKey globalKey,
    Future<bool> Function(int index)? onDel,
    required void Function(int oldIndex, int newIndex) onReorder,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Get.back(),
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: _SortPopupWindowWidget(
              list: list,
              globalKey: globalKey,
              onDel: onDel,
              onReorder: onReorder,
            ),
          ),
        );
      },
    );
  }
}

class _SortPopupWindowWidget extends StatefulWidget {
  final List<SortPopupEntity> list;
  final GlobalKey globalKey;
  final Future<bool> Function(int index)? onDel;
  final void Function(int, int) onReorder;

  const _SortPopupWindowWidget(
      {required this.list,
      this.onDel,
      required this.globalKey,
      required this.onReorder,});

  @override
  State<_SortPopupWindowWidget> createState() => __SortPopupWindowWidgetState();
}

class __SortPopupWindowWidgetState extends State<_SortPopupWindowWidget>
    with WidgetsBindingObserver, SafeSetStateMixin {
  Offset bodyOffset = Offset.zero;
  List<SortPopupEntity> bodyList = [];
  bool backFlag = true;

  @override
  void initState() {
    super.initState();
    bodyList = widget.list;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox? mainRender = context.findRenderObject() as RenderBox?;
      RenderBox? renderBox = widget.globalKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mainRender != null) {
        bodyOffset = renderBox.localToGlobal(Offset.zero);
        bodyOffset = mainRender.globalToLocal(bodyOffset);
        bodyOffset = Offset(bodyOffset.dx - 340.ww, bodyOffset.dy);
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      if (backFlag) {
        backFlag = false;
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildItem(int index, {bool isDrag = false}) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: isDrag ? const Color(0xff1F2438) : Colors.transparent,
          border: Border.all(
            width: isDrag ? 1.wMin : 0,
            color: isDrag ? const Color(0xff2388FF) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 12.wh),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: Colors.transparent,
                border: Border.all(
                  width: 1.wMin,
                  color: const Color(0xff444B5F),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset("assets/svg/manage/icon_drag.svg", width: 24.wMin, height: 24.wMin),
                  SizedBox(width: 16.ww),
                  Expanded(
                    child: Text(
                      bodyList[index].title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: const Color(0xffACB4C0),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(width: 8.ww),
            Visibility(
              visible: widget.onDel != null,
              child: TapScaleWidget(
                  onTap: () async {
                    final bool isDel = await widget.onDel?.call(index) ?? false;
                    if (isDel) {
                      safeSetState(() {
                        bodyList.removeAt(index);
                      });
                      if (bodyList.isEmpty) Get.back();
                    }
                  },
                  child: buildImage(Assets.managerX, width: 26.wMax, height: 26.wMax)),
            ),
          ],
        ),
      );
    }

    return Container(
      alignment: Alignment.topLeft,
      child: Transform.translate(
        offset: bodyOffset,
        child: GestureDetector(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.wMin),
            child: Container(
              width: 340.ww,
              padding: EdgeInsets.all(12.wMin),
              constraints: BoxConstraints(
                maxHeight: 800.wh,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: const Color(0xff19213D),
              ),
              child: SingleChildScrollView(
                child: ReorderableColumn(
                  draggedItemBuilder: (context, index) {
                    return buildItem(index, isDrag: true);
                  },
                  children: List.generate(bodyList.length, (index) {
                    final SortPopupEntity entity = bodyList[index];
                    return Container(
                      key: ValueKey(entity.uniqueId),
                      padding: EdgeInsets.symmetric(vertical: 5.wh),
                      child: buildItem(index),
                    );
                  }),
                  onReorder: (oldIndex, newIndex) {
                    final SortPopupEntity row = bodyList.removeAt(oldIndex);
                    bodyList.insert(newIndex, row);
                    safeSetState(() {});
                    widget.onReorder.call(oldIndex, newIndex);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
