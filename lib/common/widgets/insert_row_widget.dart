import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class InsertRowManager {
  static Future<void>? show(
      {required BuildContext context, final Function()? onUpTap, final Function()? onDownTap}) {
    return Get.dialog<void>(
      GestureDetector(
        onTap: () {
          dismiss();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xff040712).withValues(alpha: 0.8),
          child: UnconstrainedBox(
            alignment: Alignment.center,
            child: InsertRowWidget(
              onUpTap: onUpTap,
              onDownTap: onDownTap,
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      print('---😆😆插入单词弹框消失😆😆---');
      return value;
    });
  }

  static dismiss() {
    Get.back();
  }
}

class InsertRowWidget extends StatefulWidget {
  final Function()? onUpTap;
  final Function()? onDownTap;

  const InsertRowWidget({super.key, this.onUpTap, this.onDownTap});

  @override
  _InsertRowWidgetState createState() => _InsertRowWidgetState();
}

class _InsertRowWidgetState extends State<InsertRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(10.ww),
        width: 240.wMax,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff353E5C),
          border: Border.all(
            color: const Color(0xff767E95),
            width: 0.5.wMin,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: OptimizeUtils.noneThrottle(() {
                widget.onUpTap?.call();
              }, 200),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "向上插入",
                      style: TextStyle(
                        color: const Color(0xffEBEEF3),
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40.wMax,
                      height: 22.wMax,
                      alignment: const Alignment(0, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.wMin),
                        color: const Color(0xff353E5C),
                        border: Border.all(
                          color: const Color(0xff616B85),
                          width: 0.5.wMin,
                        ),
                      ),
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: const Color(0xffEBEEF3),
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                        ),
                      ),
                    ),
                    Gaps.getWidth(6.ww),
                    Text(
                      '行',
                      style: TextStyle(
                        color: const Color(0xffEBEEF3),
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gaps.getHeight(12.wh),
            GestureDetector(
              onTap: OptimizeUtils.noneThrottle(() {
                widget.onDownTap?.call();
              }, 200),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "向下插入",
                      style: TextStyle(
                        color: const Color(0xffEBEEF3),
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40.wMax,
                      height: 22.wMax,
                      alignment: const Alignment(0, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.wMin),
                        color: const Color(0xff353E5C),
                        border: Border.all(
                          color: const Color(0xff616B85),
                          width: 0.5.wMin,
                        ),
                      ),
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: const Color(0xffEBEEF3),
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                        ),
                      ),
                    ),
                    Gaps.getWidth(6.ww),
                    Text(
                      '行',
                      style: TextStyle(
                        color: const Color(0xffEBEEF3),
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
