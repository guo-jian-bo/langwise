import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:langwise/common/widgets/camera_mobile_dialog.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:image/image.dart' as img;

import '../common/widgets/widgets.dart';
import '../theme/theme.dart';

class ImagePickerUtils {
  /// 选择图片
  static Future<File?> pickImage(BuildContext context) async {
    if (Platform.isMacOS) {
      String? initialDir = CoverDirectoryCacheUtil.lastDirectory;
      print("初始目录, initialDir:$initialDir");
      // 验证缓存目录有效性
      if (initialDir != null) {
        final dir = Directory(initialDir);
        if (!(await dir.exists())) {
          CoverDirectoryCacheUtil.clear();
          initialDir = null;
        }
      }

      final XFile? photo = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (ObjectUtil.isNotEmpty(photo?.path)) {
        // 保存本次选择的目录
        final parentPath = File(photo!.path).parent.path;
        CoverDirectoryCacheUtil.saveDirectory(parentPath);

        // 文件有效
        final bool granted = await FileUtils.checkDirAccess(parentPath);
        if (!granted) {
          ToastUtils.showToast(text: '请开启文件权限');
          return null;
        } else {
          if (!CommonUtil.isImage(photo.path)) {
            ToastUtils.showToast(text: "文件类型不支持");
            return null;
          }
          return File(photo.path);
        }
      }
      return null;
    }

    bool isPhotosPermission = await PermissionUtils.photos(context);
    if (!isPhotosPermission) return null;

    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (photo == null) return null;
    if (!(await File(photo.path).exists())) return null;
    if (!CommonUtil.isImage(photo.path)) {
      ToastUtils.showToast(text: "文件类型不支持");
      return null;
    }
    return File(photo.path);
  }

  /// 选择图片
  static Future<List<File>?> pickImages(
      {required BuildContext context,
      int maxSelectCount = 1,
      int? imageQuality}) async {
    if (Platform.isMacOS) {
      String? initialDir = CoverDirectoryCacheUtil.lastDirectory;
      print("初始目录, initialDir:$initialDir");
      // 验证缓存目录有效性
      if (initialDir != null) {
        final dir = Directory(initialDir);
        if (!(await dir.exists())) {
          CoverDirectoryCacheUtil.clear();
          initialDir = null;
        }
      }

      final List<XFile> photo = await ImagePicker().pickMultiImage(
        imageQuality: imageQuality,
        limit: maxSelectCount,
      );
      if (photo.isEmpty) return null;

      if (ObjectUtil.isNotEmpty(photo.first.path)) {
        // 保存本次选择的目录
        final parentPath = File(photo.first.path).parent.path;
        CoverDirectoryCacheUtil.saveDirectory(parentPath);

        // 文件有效
        final bool granted = await FileUtils.checkDirAccess(parentPath);
        if (!granted) {
          ToastUtils.showToast(text: '请开启文件权限');
          return null;
        } else {
          List<File> list = [];
          for (var element in photo) {
            list.add(File(element.path));
          }
          return list;
        }
      }
      return null;
    }

    bool isPhotosPermission = await PermissionUtils.photos(context);
    if (!isPhotosPermission) return null;

    final List<XFile> photo = await ImagePicker().pickMultiImage(
      imageQuality: imageQuality,
      limit: maxSelectCount,
    );
    if (photo.isEmpty) return null;
    List<File> list = [];
    for (var element in photo) {
      if (CommonUtil.isImage(element.path)) {
        list.add(File(element.path));
      }
    }
    return list;
  }

  /// 拍照
  static Future<File?> takePhotos(
      {required BuildContext context,
      bool isCoursesBook = false,
      bool isCoursesBookFront = false}) async {
    bool isCameraPermission = await PermissionUtils.camera(context);
    if (!isCameraPermission) {
      return null;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      if (isCoursesBook) {
        final CameraMobileWidget cameraMobileWidget = CameraMobileWidget(
          isCoursesBook: isCoursesBook,
          isCoursesBookFront: isCoursesBookFront,
        );
        File? photo = await Get.to(cameraMobileWidget);
        if (photo == null) return null;
        return photo;
      }

      final XFile? photo =
          await ImagePicker().pickImage(source: ImageSource.camera);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft, // 横屏，设备左侧朝上。
        DeviceOrientation.landscapeRight // 横屏，设备右侧朝上。
      ]);
      if (photo == null) return null;
      if (!(await File(photo.path).exists())) return null;
      return File(photo.path);
    } else if (Platform.isMacOS) {
      File? file = await CameraMacosDialog.show(
          context: context,
          isCoursesBook: isCoursesBook,
          isCoursesBookFront: isCoursesBookFront);
      if (file == null) return null;
      return file;
    } else if (Platform.isWindows) {
      File? file = await CameraWindowsDialog.show(
          context: context,
          isCoursesBook: isCoursesBook,
          isCoursesBookFront: isCoursesBookFront);
      if (file == null) return null;
      return file;
    }

    return null;
  }

  static Future<File?> coursePickImage({
    required BuildContext context,
    int minWidth = 1080,
    int minHeight = 1080,
    int imageQuality = 90,
    double? cropAspectRatio,
    bool showCrop = true,
    bool withCircleUi = false,
    bool compress = true,
    bool isCoursesBook = false,
  }) async {
    try {
      File? file = await select(context: context);
      if (file == null) return null;

      print("原始大小${file.lengthSync() / 1024}");

      File? crop;
      if (showCrop) {
        crop = await ShowCropDialog.show(
          context: context,
          imageFilePath: file.path,
          cropAspectRatio: cropAspectRatio,
          withCircleUi: withCircleUi,
          isCoursesBook: isCoursesBook,
        );
        if (crop == null) return null;
      } else {
        crop = file;
      }

      print("裁剪后大小${crop.lengthSync() / 1024}");

      if (!compress) {
        return crop;
      }

      ToastUtils.showLoading();

      File? comRes =
          await compressImage(crop, minWidth, minHeight, imageQuality);
      if (comRes == null) return null;

      return comRes;
    } catch (e) {
      return null;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  static Future<File?> courseTakePhoto({
    required BuildContext context,
    int minWidth = 1080,
    int minHeight = 1080,
    int imageQuality = 90,
    double? cropAspectRatio,
    bool showCrop = true,
    bool withCircleUi = false,
    bool compress = true,
    bool isCoursesBook = false,
    bool isCoursesBookFront = false,
  }) async {
    try {
      File? file = await takePhotos(
          context: context,
          isCoursesBook: isCoursesBook,
          isCoursesBookFront: isCoursesBookFront);
      if (file == null) return null;

      print("原始大小${file.lengthSync() / 1024}");

      File? crop;
      if (showCrop) {
        crop = await ShowCropDialog.show(
          context: context,
          imageFilePath: file.path,
          cropAspectRatio: cropAspectRatio,
          withCircleUi: withCircleUi,
          isCoursesBook: isCoursesBook,
        );
        if (crop == null) return null;
      } else {
        crop = file;
      }

      print("裁剪后大小${crop.lengthSync() / 1024}");

      if (!compress) {
        return crop;
      }

      ToastUtils.showLoading();

      File? comRes =
          await compressImage(crop, minWidth, minHeight, imageQuality);
      if (comRes == null) return null;

      return comRes;
    } catch (e) {
      return null;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  static Future<File?> selectPicture({
    required BuildContext context,
    String title = "选择图片",
    int minWidth = 1080,
    int minHeight = 1080,
    int imageQuality = 90,
    double? cropAspectRatio,
    bool showCrop = true,
    bool withCircleUi = false,
    bool compress = true,
    bool isCoursesBook = false,
    bool isCoursesBookFront = false,
  }) async {
    try {
      int? type = await showSelectTypeDialog(context: context, title: title);
      if (type == null) return null;
      File? file;
      if (type == 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        file = await takePhotos(
            context: context,
            isCoursesBook: isCoursesBook,
            isCoursesBookFront: isCoursesBookFront);
      } else if (type == 1) {
        file = await select(context: context);
      }
      if (file == null) return null;

      print("原始大小${file.lengthSync() / 1024}");

      File? crop;
      if (showCrop) {
        crop = await ShowCropDialog.show(
          context: context,
          imageFilePath: file.path,
          cropAspectRatio: cropAspectRatio,
          withCircleUi: withCircleUi,
          isCoursesBook: isCoursesBook,
        );
        if (crop == null) return null;
      } else {
        crop = file;
      }

      print("裁剪后大小${crop.lengthSync() / 1024}");

      if (!compress) {
        return crop;
      }

      ToastUtils.showLoading();

      File? comRes =
          await compressImage(crop, minWidth, minHeight, imageQuality);
      if (comRes == null) return null;

      return comRes;
    } catch (e) {
      return null;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  static Future<File?> compressImage(
      File? file, int minWidth, int minHeight, int imageQuality) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return null;
    // 预先计算目标尺寸，避免不必要的处理
    final originalWidth = image.width;
    Uint8List? compressedBytes;
    if (originalWidth <= minWidth) {
      // 直接压缩质量，不改变尺寸
      compressedBytes = img.encodeJpg(image, quality: imageQuality);
    } else {
      if (Platform.isWindows) {
        final smallerImage = img.copyResize(
          image,
          width: minWidth,
          height: minHeight,
          maintainAspect: true,
          interpolation: img.Interpolation.linear,
        );
        compressedBytes = img.encodeJpg(smallerImage, quality: imageQuality);
      } else {
        compressedBytes = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: minWidth,
          minHeight: minHeight,
          quality: imageQuality,
        );
      }
    }

    if (compressedBytes == null) return null;

    final tempDir = await Directory.systemTemp.create();
    int time = DateTime.now().millisecondsSinceEpoch;
    String savePath =
        '${tempDir.path}${Platform.pathSeparator}image_compression_$time.jpg';
    final tempFile = File(savePath);
    await tempFile.writeAsBytes(compressedBytes);

    print("压缩后大小${tempFile.lengthSync() / 1024}");
    print("压缩后地址:$savePath");

    return tempFile;
  }

  static Future<File?> select({required BuildContext context}) async {
    File? selectFile;
    if (Platform.isMacOS) {
      String? initialDir = CoverDirectoryCacheUtil.lastDirectory;
      // 验证缓存目录有效性
      if (initialDir != null) {
        if (!(await Directory(initialDir).exists())) {
          CoverDirectoryCacheUtil.clear();
        }
      }
      final XFile? photo =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (photo == null) return null;
      // 保存本次选择的目录
      final parentPath = File(photo.path).parent.path;
      CoverDirectoryCacheUtil.saveDirectory(parentPath);
      // 文件有效
      final bool granted = await FileUtils.checkDirAccess(parentPath);
      if (!granted) {
        ToastUtils.showToast(text: '请开启文件权限');
        return null;
      }
      if (!CommonUtil.isImage(photo.path)) {
        ToastUtils.showToast(text: "文件类型不支持");
        return null;
      }
      selectFile = File(photo.path);
    } else {
      bool isPhotosPermission = await PermissionUtils.photos(context);
      if (!isPhotosPermission) return null;
      final XFile? photo =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (photo == null) return null;
      if (!(await File(photo.path).exists())) return null;
      selectFile = File(photo.path);
    }
    if (!CommonUtil.isImage(selectFile.path)) {
      ToastUtils.showToast(text: "文件类型不支持");
      return null;
    }
    return selectFile;
  }

  static Future<int?> showSelectTypeDialog({
    required BuildContext context,
    required String title,
  }) {
    return showCupertinoDialog<int?>(
      context: context,
      builder: (context) {
        return ShowSelectTypeDialogWidget(title: title);
      },
    );
  }
}

class ShowSelectTypeDialogWidget extends StatelessWidget {
  final String title;
  final void Function(int type)? onTap;
  const ShowSelectTypeDialogWidget(
      {super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 560.wMin,
              padding:
                  EdgeInsets.symmetric(horizontal: 64.wMin, vertical: 40.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cBgSecondary,
                border:
                    Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 72.wMin),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIconWidget(
                        "assets/svg/public/icon_camera1.svg",
                        "拍照",
                        onTap: () {
                          Get.back(result: 0);
                        },
                      ),
                      SizedBox(width: 24.wMin),
                      _buildIconWidget(
                        "assets/svg/public/icon_image1.svg",
                        "相册",
                        onTap: () {
                          Get.back(result: 1);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 64.wMin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWidget(String svg, String name,
      {required Function() onTap}) {
    return Column(
      spacing: 8.wMin,
      children: [
        TapScaleWidget(
          onTap: onTap,
          sclae: 1.05,
          child: Container(
            width: 80.wMin,
            height: 80.wMin,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cFeedbackInfoBackground,
            ),
            child: SvgPicture.asset(svg, width: 40.wMin),
          ),
        ),
        Text(
          name,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
