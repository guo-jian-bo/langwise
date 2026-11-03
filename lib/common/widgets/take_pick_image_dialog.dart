import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/list_animation_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import 'widgets.dart';

class TakePickImageDialog {
  static Future<String?> show({
    required BuildContext context,
    bool isScan = true,
    void Function(String filePath)? onSelect,
  }) async {
    return await showCupertinoDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return TakePickImageWidget(
          isScan: isScan,
          onSelect: onSelect,
        );
      },
    );
  }
}

class TakePickImageWidget extends StatefulWidget {
  final bool isScan;
  final void Function(String filePath)? onSelect;

  const TakePickImageWidget({super.key, required this.isScan, this.onSelect});

  @override
  State<TakePickImageWidget> createState() => _TakePickImageWidgetState();
}

class _TakePickImageWidgetState extends State<TakePickImageWidget> {
  /// 拍照
  Future<void> photographImg() async {
    File? file = await ImagePickerUtils.takePhotos(context: context);
    if (file == null) return;
    widget.onSelect?.call(file.path);
    Get.back(result: file.path);
  }

  /// 选择
  Future<void> selectImg() async {
    final File? photo = await ImagePickerUtils.pickImage(context);
    if (photo == null) return;
    if (!(await File(photo.path).exists())) return;
    widget.onSelect?.call(photo.path);
    Get.back(result: photo.path);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildItem(String img, String name, {void Function()? onTap, int index = 0}) {
      return ListAnimationWidget(
        index: index,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TapScaleWidget(
              sclae: 1.05,
              onTap: onTap,
              child: Container(
                width: 170.wMin,
                height: 170.wMin,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cBlackAlpha20,
                ),
                child: SvgPicture.asset(
                  img,
                  width: 100.wMin,
                ),
              ),
            ),
            SizedBox(height: 16.wMin),
            Text(
              name,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 500.wMin,
              padding: EdgeInsets.symmetric(vertical: 60.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cBgTertiary,
              ),
              child: AnimationLimiter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildItem(
                      "assets/svg/public/icon_camera.svg",
                      "去拍照",
                      index: 0,
                      onTap: photographImg,
                    ),
                    SizedBox(height: 88.wMin),
                    buildItem(
                      "assets/svg/public/icon_image.svg",
                      "上传一张照片",
                      index: 1,
                      onTap: selectImg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
