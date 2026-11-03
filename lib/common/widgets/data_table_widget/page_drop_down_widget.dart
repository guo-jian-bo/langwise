import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/values/values.dart';
import 'package:ui_essentials/ui_essentials.dart';

class PageDropDownManager {
  static bool _isShow = false;

  static void show({
    required BuildContext context,
    required List<int> list,
    int initIndex = 0,
    double? top,
    double? left,
    void Function(int index)? onTap,
  }) {
    if (_isShow) {
      return;
    }
    _isShow = true;
    Get.dialog(
      GestureDetector(
        onTap: () {
          _removeOverlay();
          Get.back();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          padding: EdgeInsets.only(left: left ?? 0, top: top ?? 0),
          child: UnconstrainedBox(
            alignment: Alignment.topLeft,
            child: _PageDropDownWidget(
              list: list,
              initIndex: initIndex,
              onTap: (index) {
                print('---hide---');
                _removeOverlay();
                Get.back();
                // Navigator.pop(context);
                onTap?.call(index);
              },
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );
  }

  static _removeOverlay() {
    _isShow = false;
  }
}

class _PageDropDownWidget extends StatefulWidget {
  final List<int> list;
  final int initIndex;
  final void Function(int index)? onTap;

  const _PageDropDownWidget({required this.list, required this.initIndex, this.onTap});

  @override
  State<_PageDropDownWidget> createState() => __PageDropDownWidgetState();
}

class __PageDropDownWidgetState extends State<_PageDropDownWidget> with SafeSetStateMixin {
  int hoverIndex = -1;

  int selectIndex = 0;

  @override
  void initState() {
    super.initState();
    selectIndex = widget.initIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Container(
          width: AppConstant.managerPageNumberDropDownWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: const Color(0xff303650),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.list.length, (index) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onHover: (event) {
                  safeSetState(() {
                    hoverIndex = index;
                  });
                },
                onExit: (event) {
                  safeSetState(() {
                    hoverIndex = -1;
                  });
                },
                child: GestureDetector(
                  onTapDown: (details) {
                    safeSetState(() {
                      hoverIndex = index;
                    });
                  },
                  onTapCancel: () {
                    safeSetState(() {
                      hoverIndex = -1;
                    });
                  },
                  onTapUp: (details) {
                    selectIndex = index;
                    widget.onTap?.call(index);
                  },
                  child: Container(
                      height: 44.wh,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: hoverIndex == index ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                        border: index == widget.list.length - 1
                            ? null
                            : Border(
                                bottom: BorderSide(
                                  width: 1.wh,
                                  color: const Color(0xff19213D).withValues(alpha: 0.65),
                                ),
                              ),
                      ),
                      child: Text(
                        '${widget.list[index]}',
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: selectIndex == index ? Colors.white : const Color(0xffCFD5DF),
                        ),
                      )),
                ),
              );
            }),
          ),
        ));
  }
}
