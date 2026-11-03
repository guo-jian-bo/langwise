import 'dart:async';
import 'dart:io';
import 'package:edge_detection_plus/edge_detection_plus.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as imga;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
  }

  Future<void> getImageFromCamera() async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted = await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      // Have not permission to camera
      return;
    }

    // Generate filepath for saving
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    print('---😆😆imagePath:$imagePath😆😆---');

    Map<String, dynamic> success = {};

    try {
      // Make sure to await the call to detectEdge.
      final Map<Object?, Object?> _success = await EdgeDetectionPlus.detectEdgeWithRect(
        imagePath,
        canUseGallery: true,
        androidScanTitle: 'Scanning',
        // use custom localizations for android
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );
      print("_success: $_success");
      success = Map<String, dynamic>.from(_success as Map);
    } catch (e) {
      print(e);
    }

    print('success: $success, Type success: ${success.runtimeType}');

    if (!mounted) return;

    // 解码
    imga.Image? image = imga.decodeImage(File(imagePath).readAsBytesSync());

    if (image != null) {
      final Map<String, dynamic>? topLeft = Map<String, dynamic>.from(success['topLeft'] as Map);
      final Map<String, dynamic>? topRight = Map<String, dynamic>.from(success['topRight'] as Map);
      final Map<String, dynamic>? bottomLeft = Map<String, dynamic>.from(success['bottomLeft'] as Map);
      final Map<String, dynamic>? bottomRight = Map<String, dynamic>.from(success['bottomRight'] as Map);
      // 其中给定的矩形已映射到完整的映像。矩形
      image = copyRectify(image,
          topLeft: imga.Point(topLeft?['x'], topLeft?['y']),
          topRight: imga.Point(topRight?['x'], topRight?['y']),
          bottomLeft: imga.Point(bottomLeft?['x'], bottomLeft?['y']),
          bottomRight: imga.Point(bottomRight?['x'], bottomRight?['y']));

      if (File(imagePath).existsSync()) {
        File(imagePath).deleteSync();
        print('---😆😆先删除imagePath:$imagePath😆😆---');
        imagePath = File(imagePath).path;
      }
      print('---😆😆再保存imagePath:$imagePath😆😆---');

      // 灰度
      // final imga.Image grayscale = imga.grayscale(image);

      // 对比度
      final imga.Image contrast = imga.contrast(image, contrast: 110);

      // 亮度阈值
      // final imga.Image threshold = imga.luminanceThreshold(image);

      // 编码图片数据到本地文件
      await imga.encodeImageFile(imagePath, contrast);
    }

    setState(() {
      if (success.isNotEmpty) {
        _imagePath = imagePath;
      }
    });
  }

  // Future<void> getImageFromCamera() async {
  //   bool isCameraGranted = await Permission.camera.request().isGranted;
  //   if (!isCameraGranted) {
  //     isCameraGranted = await Permission.camera.request() == PermissionStatus.granted;
  //   }
  //
  //   if (!isCameraGranted) {
  //     // Have not permission to camera
  //     return;
  //   }
  //
  //   // Generate filepath for saving
  //   String imagePath = join((await getApplicationSupportDirectory()).path,
  //       "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
  //
  //   bool success = false;
  //
  //   try {
  //     //Make sure to await the call to detectEdge.
  //     success = await EdgeDetectionPlus.detectEdge(
  //       imagePath,
  //       canUseGallery: true,
  //       androidScanTitle: 'Scanning',
  //       // use custom localizations for android
  //       androidCropTitle: 'Crop',
  //       androidCropBlackWhiteTitle: 'Black White',
  //       androidCropReset: 'Reset',
  //     );
  //     print("success: $success");
  //   } catch (e) {
  //     print(e);
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //
  //   imga.Image? image = imga.decodeImage(File(imagePath).readAsBytesSync());
  //
  //   if (image != null) {
  //     // copyRectify(image, );
  //   }
  //
  //   setState(() {
  //     if (success) {
  //       _imagePath = imagePath;
  //     }
  //   });
  // }

  Future<void> getImageFromGallery() async {
    // Generate filepath for saving
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    bool success = false;
    try {
      //Make sure to await the call to detectEdgeFromGallery.
      success = await EdgeDetectionPlus.detectEdgeFromGallery(
        imagePath,
        androidCropTitle: 'Crop', // use custom localizations for android
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );
      print("success: $success");
    } catch (e) {
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (success) {
        _imagePath = imagePath;
      }
    });
  }

  // 使用 image 库的 copyRectify 方法实现透视裁剪
  imga.Image copyRectify(
    imga.Image src, {
    required imga.Point topLeft,
    required imga.Point topRight,
    required imga.Point bottomLeft,
    required imga.Point bottomRight,
    imga.Interpolation interpolation = imga.Interpolation.nearest,
    imga.Image? toImage,
  }) {
    return imga.copyRectify(
      src,
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
      interpolation: interpolation,
      toImage: toImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: getImageFromCamera,
                      child: Text('Scan'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: getImageFromGallery,
                      child: Text('Upload'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Cropped image path:'),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                    child: Text(
                      _imagePath.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Visibility(
                  visible: _imagePath != null,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.all(8),
                    child: Image.file(
                      File(
                        _imagePath ?? '',
                      ),
                      fit: BoxFit.contain,
                    ),
                  )),
            )
          ],
        ),
      ),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: getImageFromCamera,
                  child: Text('Scan'),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: getImageFromGallery,
                  child: Text('Upload'),
                ),
              ),
              SizedBox(height: 20),
              Text('Cropped image path:'),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                child: Text(
                  _imagePath.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Visibility(
                visible: _imagePath != null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(
                      _imagePath ?? '',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
