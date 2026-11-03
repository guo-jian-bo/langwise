import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:ui_essentials/ui_essentials.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import 'package:langwise/utils/utils.dart';

class ManagePreviewManager {
  static Future<void>? show(
      {required BuildContext context,
      required ui.Image v1,
      required ui.Image v2,
      // 接收本地文件路径
      final Function(String? v1, int? s1, String? v2, int? s2)? onContinueTap,
      final Function(String? v1, int? s1, String? v2, int? s2)? onStopTap}) {
    return Get.dialog<void>(
      PreviewPage(
        v1,
        v2,
        onContinueTap: onContinueTap,
        onStopTap: onStopTap,
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      print('---扫描预览弹框消失---');
      return value;
    });
  }
}

class PreviewPage extends StatefulWidget {
  final ui.Image leftImage;
  final ui.Image rightImage;
  final Function(String? v1, int? s1, String? v2, int? s2)? onContinueTap;
  final Function(String? v1, int? s1, String? v2, int? s2)? onStopTap;

  const PreviewPage(this.leftImage, this.rightImage, {super.key, this.onContinueTap, this.onStopTap});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> with SafeSetStateMixin {
  late ui.Image? leftImage;
  late ui.Image? rightImage;

  double leftOpacity = 1;
  double rightOpacity = 1;

  @override
  void initState() {
    super.initState();
    leftImage = widget.leftImage;
    rightImage = widget.rightImage;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff040712),
        child: Stack(
          alignment: const Alignment(0, 0),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leftImage != null)
                    _buildImage(leftImage!, leftOpacity, () {
                      safeSetState(() {
                        leftOpacity = 0;
                      });
                    }),
                  Gaps.getWidth(10.ww),
                  if (rightImage != null)
                    _buildImage(rightImage!, rightOpacity, () {
                      safeSetState(() {
                        rightOpacity = 0;
                      });
                    }),
                ],
              ),
            ),
            ..._buildTakeWidget()
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ui.Image image, double opacity, VoidCallback onTap) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 200),
      child: AspectRatio(
        aspectRatio: image.width.ww / image.height.wh,
        child: LayoutBuilder(builder: (context, constraints) {
          final maxSize = constraints.biggest;
          // 动态计算实际显示尺寸
          final width = min(image.width, maxSize.width);
          final height = min(image.height, maxSize.height);
          return Container(
            width: width.toDouble(),
            height: height.toDouble(),
            color: Colors.transparent,
            alignment: const Alignment(0, 0),
            child: Stack(
              children: [
                RawImage(
                  image: image,
                  // 保证图片按比例填充但不溢出
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                Positioned(
                    top: 20.wh,
                    right: 20.ww,
                    child: GestureDetector(
                      // 添加按钮点击区域扩展
                      behavior: HitTestBehavior.opaque,
                      onTap: OptimizeUtils.noneThrottle(() {
                        if (opacity == 0) return;
                        onTap.call();
                      }, 200),
                      child: buildImage(Assets.managerDelete, width: 44.wMax, height: 44.wMax),
                    )),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildTakeWidget() {
    return [
      Positioned(
          bottom: 70.wh,
          right: 240.ww,
          child: TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              Get.back();
            }, 300),
            child: Container(
              width: 80.ww,
              height: 40.wh,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff040712).withValues(alpha: 0.8),
                border: Border.all(
                  color: const Color(0xff666F8D),
                  width: 0.5.wMin,
                ),
                borderRadius: BorderRadius.circular(6.wMin),
              ),
              child: Text(
                "取消",
                style: TextStyle(
                  color: Colours.blue_E5F5FF,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ),
          )),
      Positioned(
          bottom: 70.wh,
          right: 150.ww,
          child: TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() async {
              try {
                final record = await _onSave();
                Navigator.pop(context);
                widget.onContinueTap
                    ?.call(record.v1?.path, record.v1?.lengthSync(), record.v2?.path, record.v2?.lengthSync());
              } catch (e) {
                ToastUtils.showManageToast(text: e.toString());
              }
            }, 800),
            child: Container(
              width: 80.ww,
              height: 40.wh,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff2388FF),
                borderRadius: BorderRadius.circular(6.wMin),
              ),
              child: Text(
                "继续拍照",
                style: TextStyle(
                  color: Colours.blue_E5F5FF,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ),
          )),
      Positioned(
          bottom: 70.wh,
          right: 60.ww,
          child: TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() async {
              final record = await _onSave();
              Navigator.pop(context);

              widget.onStopTap
                  ?.call(record.v1?.path, record.v1?.lengthSync(), record.v2?.path, record.v2?.lengthSync());
            }, 800),
            child: Container(
              width: 80.ww,
              height: 40.wh,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff2388FF),
                borderRadius: BorderRadius.circular(6.wMin),
              ),
              child: Text(
                "结束拍摄",
                style: TextStyle(
                  color: Colours.blue_E5F5FF,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ),
          )),
    ];
  }

  Future<({File? v1, File? v2})> _onSave() async {
    File? v1, v2;
    if (leftOpacity == 1) {
      if (leftImage != null) {
        v1 = await saveImageToLocal(leftImage!, fileName: 'left_image_${const Uuid().v6()}.jpg');
      }
    }

    if (rightOpacity == 1) {
      if (rightImage != null) {
        v2 = await saveImageToLocal(rightImage!, fileName: 'right_image_${const Uuid().v6()}.jpg');
      }
    }

    return (v1: v1, v2: v2);
  }

  // 保存图片到本地
  Future<File?> saveImageToLocal(ui.Image flutterImage, {required String fileName}) async {
    try {
      // 1. 转换ui.Image为字节数据
      final byteData = await flutterImage.toByteData(format: ui.ImageByteFormat.png);
      final pngBuffer = byteData!.buffer.asUint8List();

      // 2. 解码PNG并转换为JPEG
      final decodedImage = img.decodePng(pngBuffer);
      if (decodedImage == null) {
        throw Exception('图片解码失败');
      }

      // 调整图片质量（1-100）
      const jpegQuality = 50;
      final jpegBuffer = img.encodeJpg(decodedImage, quality: jpegQuality);

      // 3. 确保文件名后缀正确
      if (!fileName.toLowerCase().endsWith('.jpg') && !fileName.toLowerCase().endsWith('.jpeg')) {
        fileName += '.jpg';
      }

      // 2. 获取存储路径
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // 3. 写入文件
      final File file = File(filePath);
      await file.writeAsBytes(jpegBuffer);

      print('✅ 图片保存成功: $filePath');
      return file;
    } catch (e) {
      print('❌ 保存失败: $e');
      return null;
    }
  }
}
