// import 'dart:io';

// import 'package:edge_detection_plus/edge_detection_plus.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image/image.dart' as img;
// import '../../utils/toast_utils.dart';
// import '../../utils/utils.dart';

// /// 边缘检测
// class CameraDetectionPicturesUtils {
//   static Future<String?> degeDetection(BuildContext context) async {
//     if (!(await PermissionUtils.camera(context))) {
//       ToastUtils.showToast(text: '暂无相机权限');
//       return null;
//     }
//     String imagePath = join((await getApplicationSupportDirectory()).path,
//         "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
//     if (Platform.isAndroid) {
//       return await _androidEdgeDetection(imagePath);
//     } else if (Platform.isIOS) {
//       return await _iOSEdgeDetection(imagePath);
//     }

//     return null;
//   }

//   static Future<String?> _androidEdgeDetection(String saveToPath) async {
//     bool success = false;
//     try {
//       success = await EdgeDetectionPlus.detectEdge(
//         saveToPath,
//         // 禁止使用相册库
//         canUseGallery: false,
//         androidScanTitle: '扫描',
//         // use custom localizations for android
//         androidCropTitle: '裁剪',
//         androidCropBlackWhiteTitle: '黑白',
//         androidCropReset: '重置',
//       );
//       print("success: $success");
//     } catch (e) {
//       print(e);
//     } finally {}

//     if (!success) {
//       print('取消拍照');
//       return null;
//     }
//     // 快速解码
//     img.Image? image = img.decodeNamedImage(saveToPath, File(saveToPath).readAsBytesSync());
//     if (image != null) {
//       if (File(saveToPath).existsSync()) {
//         File(saveToPath).deleteSync();
//         print('---😆😆先删除旧数据imagePath:$saveToPath😆😆---');
//       }
//       print('---😆😆再保存新数据imagePath:$saveToPath😆😆---');
//       // 灰度
//       final img.Image grayscale = img.grayscale(image);

//       // 亮度阈值
//       // final img.Image threshold = imga.luminanceThreshold(image);

//       // 编码图片数据到本地文件
//       final bool isOk = await img.encodeImageFile(saveToPath, grayscale);
//       print('---😆😆保存新数据isOk:$isOk😆😆---');

//       if (isOk) {
//         return saveToPath;
//       } else {
//         // todo 看需求是否保存未加滤镜的图片
//       }
//     }

//     return null;
//   }

//   static Future<String?> _iOSEdgeDetection(String saveToPath) async {
//     Map<String, dynamic> success = {};
//     try {
//       final Map<Object?, Object?>? _success = await EdgeDetectionPlus.detectEdgeWithRect(
//         saveToPath,
//         // 禁止使用相册库
//         canUseGallery: false,
//       );

//       print("_success: $_success");

//       if (_success != null) {
//         success = Map<String, dynamic>.from(_success as Map);
//       }
//     } catch (e) {
//       print(e.toString());
//     } finally {}

//     if (success.isEmpty) {
//       print('取消拍照');
//       return null;
//     }

//     // 快速解码
//     img.Image? image = img.decodeNamedImage(saveToPath, File(saveToPath).readAsBytesSync());

//     if (image != null) {
//       final Map<String, dynamic>? topLeft = Map<String, dynamic>.from(success['topLeft'] as Map);
//       final Map<String, dynamic>? topRight = Map<String, dynamic>.from(success['topRight'] as Map);
//       final Map<String, dynamic>? bottomLeft = Map<String, dynamic>.from(success['bottomLeft'] as Map);
//       final Map<String, dynamic>? bottomRight = Map<String, dynamic>.from(success['bottomRight'] as Map);
//       // 其中给定的矩形已映射到完整的映像。矩形
//       image = _copyRectify(image,
//           topLeft: img.Point(topLeft?['x'], topLeft?['y']),
//           topRight: img.Point(topRight?['x'], topRight?['y']),
//           bottomLeft: img.Point(bottomLeft?['x'], bottomLeft?['y']),
//           bottomRight: img.Point(bottomRight?['x'], bottomRight?['y']));

//       if (File(saveToPath).existsSync()) {
//         File(saveToPath).deleteSync();
//         print('---😆😆先删除旧数据imagePath:$saveToPath😆😆---');
//       }
//       print('---😆😆再保存新数据imagePath:$saveToPath😆😆---');

//       // 灰度
//       final img.Image grayscale = img.grayscale(image);

//       // 亮度阈值
//       // final img.Image threshold = img.luminanceThreshold(image);

//       // 编码图片数据到本地文件
//       final bool isOk = await img.encodeImageFile(saveToPath, grayscale);
//       print('---😆😆保存新数据isOk:$isOk😆😆---');

//       if (isOk) {
//         return saveToPath;
//       } else {
//         // todo 看需求是否保存未加滤镜的图片
//       }
//     }
//     return null;
//   }

//   // 使用 image 库的 copyRectify 方法实现透视裁剪
//   static img.Image _copyRectify(
//     img.Image src, {
//     required img.Point topLeft,
//     required img.Point topRight,
//     required img.Point bottomLeft,
//     required img.Point bottomRight,
//     img.Interpolation interpolation = img.Interpolation.nearest,
//     img.Image? toImage,
//   }) {
//     return img.copyRectify(
//       src,
//       topLeft: topLeft,
//       topRight: topRight,
//       bottomLeft: bottomLeft,
//       bottomRight: bottomRight,
//       interpolation: interpolation,
//       toImage: toImage,
//     );
//   }
// }
