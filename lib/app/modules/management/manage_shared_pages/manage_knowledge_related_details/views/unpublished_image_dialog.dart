import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

class UnpublishedImageDialog {
  static Future<bool> show({
    required BuildContext context,
    String title = '是否下架该图片',
    String content = '下架后将不再展示，并会同步删除该数据。\n请确认是否继续操作。',
    String cancelText = '再想想',
    String confirmText = '确定下架',
  }) async {
    final bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return _UnpublishedImageDialogWidget(
          title: title,
          content: content,
          cancelText: cancelText,
          confirmText: confirmText,
        );
      },
    );
    return res ?? false;
  }
}

class _UnpublishedImageDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;

  const _UnpublishedImageDialogWidget({
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff040712).withValues(alpha: 0.6),
      child: Center(
        child: Container(
          width: 576.wMin,
          height: 300.wMin,
          padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 32.wMin),
          decoration: BoxDecoration(
            color: const Color(0xff23283D),
            borderRadius: BorderRadius.circular(16.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/manage/icon_warn.svg',
                    width: 27.wMin,
                    height: 27.wMin,
                    colorFilter: const ColorFilter.mode(Color(0xFFFF8A2D), BlendMode.srcIn),
                  ),
                  SizedBox(width: 19.wMin),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 22.wMin,
                        color: const Color(0xffEBEEF3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  TapScaleWidget(
                    sclae: 1.05,
                    onTap: () => Get.back(result: false),
                    child: Container(
                      width: 38.wMin,
                      height: 38.wMin,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/svg/manage/icon_close.svg',
                        width: 20.wMin,
                        height: 20.wMin,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.wMin),
              Padding(
                padding: EdgeInsets.only(left: 40.wMin),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 19.wMin,
                    color: const Color(0xffACB4C0),
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ButtonWidget(
                    text: cancelText,
                    borderRadius: 8.wMin,
                    height: 54.wMin,
                    width: 108.wMin,
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    border: Border.all(width: 1.wMin, color: const Color(0xff767E95)),
                    fontSize: 19.wMin,
                    fontColor: const Color(0xffEBEEF3),
                    sclae: 1.02,
                    onTap: () => Get.back(result: false),
                  ),
                  SizedBox(width: 18.wMin),
                  ButtonWidget(
                    text: confirmText,
                    borderRadius: 8.wMin,
                    alignment: Alignment.center,
                    height: 54.wMin,
                    width: 108.wMin,
                    color: const Color(0xff2388FF),
                    fontSize: 19.wMin,
                    fontColor: const Color(0xffEBEEF3),
                    sclae: 1.02,
                    onTap: () => Get.back(result: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
