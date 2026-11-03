import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:langwise/common/widgets/camera_mobile_dialog.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../common/widgets/widgets.dart';
import '../theme/theme.dart';
import 'image_compress_utils.dart';
import 'video_compress_utils.dart';

class ImagePickerUtils {
  /// 单图成品默认输出宽度。
  static const int _defaultCompressedImageWidth = 1080;

  /// 单图成品默认输出质量。
  static const int _defaultCompressedImageQuality = 90;

  /// 从相册选择单张原始图片。
  ///
  /// 该方法只负责：
  /// - 权限校验
  /// - 平台差异处理
  /// - 文件存在与图片类型校验
  ///
  /// 不负责：
  /// - 裁剪
  /// - 压缩
  static Future<File?> pickImage(BuildContext context) async {
    return _pickImageRaw(context: context);
  }

  /// 从相册选择多张原始图片。
  ///
  /// 该方法与 `pickImage` 一样只负责原图选择，不做裁剪和压缩。
  static Future<List<File>?> pickImages({required BuildContext context, int maxSelectCount = 1, int? imageQuality}) async {
    if (Platform.isMacOS) {
      await _ensureMacOSDirectoryCacheValid();

      final List<XFile> photo = await ImagePicker().pickMultiImage(
        imageQuality: imageQuality,
        limit: maxSelectCount,
      );
      if (photo.isEmpty) return null;
      final bool granted = await _saveAndValidateMacOSDirectory(photo.first.path);
      if (!granted) return null;
      return _buildRawImageList(photo);
    }

    final bool isPhotosPermission = await PermissionUtils.photos(context);
    if (!isPhotosPermission) return null;

    final List<XFile> photo = await ImagePicker().pickMultiImage(
      imageQuality: imageQuality,
      limit: maxSelectCount,
    );
    if (photo.isEmpty) return null;
    return _buildRawImageList(photo);
  }

  /// 拍摄单张原始图片。
  ///
  /// 该方法只负责拍照结果获取，不做裁剪和压缩。
  static Future<File?> takePhotos(
      {required BuildContext context,
      bool checkCameraPermission = true,
      bool isCoursesBook = false,
      bool isCoursesBookFront = false}) async {
    if (checkCameraPermission) {
      final bool isCameraPermission = await PermissionUtils.camera(context);
      if (!isCameraPermission) {
        return null;
      }
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

      final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft, // 横屏，设备左侧朝上。
        DeviceOrientation.landscapeRight // 横屏，设备右侧朝上。
      ]);
      return _validateRawImagePath(photo?.path);
    } else if (Platform.isMacOS) {
      if (!context.mounted) return null;
      final File? file = await CameraMacosDialog.show(
        context: context,
        isCoursesBook: isCoursesBook,
        isCoursesBookFront: isCoursesBookFront,
      );
      if (file == null) return null;
      if (!(await file.exists())) return null;
      return file;
    } else if (Platform.isWindows) {
      if (!context.mounted) return null;
      final File? file = await CameraWindowsDialog.show(
        context: context,
        isCoursesBook: isCoursesBook,
        isCoursesBookFront: isCoursesBookFront,
      );
      if (file == null) return null;
      if (!(await file.exists())) return null;
      return file;
    }

    return null;
  }

  /// 从相册选择单张图片成品。
  ///
  /// 该方法会先从相册获取单张原图，
  /// 再按配置统一执行裁剪和压缩，最后返回处理后的成品图。
  static Future<File?> pickProcessedImage({
    required BuildContext context,
    int minWidth = 1080,
    int imageQuality = 90,
    double? cropAspectRatio,
    bool showCrop = true,
    bool withCircleUi = false,
    bool compress = true,
  }) async {
    final File? rawFile = await pickImage(context);
    if (rawFile == null) return null;
    if (!context.mounted) return null;
    return _processSelectedImage(
      context: context,
      rawFile: rawFile,
      targetWidth: minWidth,
      imageQuality: imageQuality,
      cropAspectRatio: cropAspectRatio,
      showCrop: showCrop,
      withCircleUi: withCircleUi,
      compress: compress,
    );
  }

  /// 拍摄单张图片成品。
  ///
  /// 该方法会先获取拍照原图，
  /// 再按配置统一执行裁剪和压缩，最后返回处理后的成品图。
  static Future<File?> takeProcessedPhoto({
    required BuildContext context,
    int minWidth = 1080,
    int imageQuality = 90,
    double? cropAspectRatio,
    bool showCrop = true,
    bool withCircleUi = false,
    bool compress = true,
    bool isCoursesBook = false,
    bool isCoursesBookFront = false,
  }) async {
    final File? rawFile = await takePhotos(
      context: context,
      isCoursesBook: isCoursesBook,
      isCoursesBookFront: isCoursesBookFront,
    );
    if (rawFile == null) return null;
    if (!context.mounted) return null;
    return _processSelectedImage(
      context: context,
      rawFile: rawFile,
      targetWidth: minWidth,
      imageQuality: imageQuality,
      cropAspectRatio: cropAspectRatio,
      showCrop: showCrop,
      withCircleUi: withCircleUi,
      compress: compress,
    );
  }

  /// 获取单张图片成品。
  ///
  /// 该方法是单图流程编排入口：
  /// - 用户先选择拍照或相册
  /// - 工具层获取原始图片
  /// - 再统一执行裁剪与最终压缩
  static Future<File?> selectPicture({
    required BuildContext context,
    String title = "选择图片",
    int minWidth = 1080,
    int imageQuality = 90,
    double? cropAspectRatio,
    bool showCrop = true,
    bool withCircleUi = false,
    bool compress = true,
    bool isCoursesBook = false,
    bool isCoursesBookFront = false,
  }) async {
    final int? type = await showSelectTypeDialog(context: context, title: title);
    if (type == null) return null;
    if (!context.mounted) return null;
    final File? rawFile = await _pickRawImageByType(
      context: context,
      type: type,
      isCoursesBook: isCoursesBook,
      isCoursesBookFront: isCoursesBookFront,
    );
    if (rawFile == null) return null;
    if (!context.mounted) return null;
    return _processSelectedImage(
      context: context,
      rawFile: rawFile,
      targetWidth: minWidth,
      imageQuality: imageQuality,
      cropAspectRatio: cropAspectRatio,
      showCrop: showCrop,
      withCircleUi: withCircleUi,
      compress: compress,
    );
  }

  /// 将图片压缩为统一规格的 `webp` 文件。
  ///
  /// 当前方法只负责把旧调用收口到独立的 `ImageCompressUtils`，
  /// 实际的 FFmpeg 压缩细节全部下沉到专用工具文件中。
  static Future<File?> compressImage(File? file, int minWidth, int imageQuality) async {
    if (file == null) return null;
    final int targetWidth = minWidth > 0 ? minWidth : _defaultCompressedImageWidth;
    final int normalizedQuality = imageQuality > 0 ? imageQuality.clamp(1, 100).toInt() : _defaultCompressedImageQuality;
    File? respFile = await ImageCompressUtils.compressImageToWebp(
      file,
      targetWidth: targetWidth,
      quality: normalizedQuality,
    );
    if(respFile != null){
      print("压缩后大小${respFile.lengthSync() / 1024}");
    }
    
    return respFile;
  }

  /// 统一处理单图成品流程。
  ///
  /// 流程顺序固定为：
  /// 1. 使用 raw 文件作为输入
  /// 2. 按需裁剪
  /// 3. 按需压缩为最终产物
  static Future<File?> _processSelectedImage({
    required BuildContext context,
    required File rawFile,
    required int targetWidth,
    required int imageQuality,
    double? cropAspectRatio,
    bool showCrop = true,
    bool withCircleUi = false,
    bool compress = true,
  }) async {
    try {
      print("原始大小${rawFile.lengthSync() / 1024}");
      File file = rawFile;
      if (showCrop) {
        if (!context.mounted) return null;
        final File? cropFile = await ShowCropDialog.show(
          context: context,
          imageFilePath: rawFile.path,
          cropAspectRatio: cropAspectRatio,
          withCircleUi: withCircleUi,
        );
        if (cropFile == null) return null;
        file = cropFile;
      }

      print("裁剪后大小${file.lengthSync() / 1024}");

      if (!compress) {
        return file;
      }

      ToastUtils.showLoading();
      return await compressImage(file, targetWidth, imageQuality);
    } catch (e, stackTrace) {
      await ErrorLogUtils.to.logError(
        '[ImagePickerUtils] 单图成品流程异常 path:${rawFile.path} error:$e',
        stackTrace,
      );
      return null;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 根据选择类型获取原始图片。
  ///
  /// `type == 0` 表示拍照，`type == 1` 表示相册。
  static Future<File?> _pickRawImageByType({
    required BuildContext context,
    required int type,
    bool isCoursesBook = false,
    bool isCoursesBookFront = false,
  }) async {
    if (type == 0) {
      // 弹窗关闭后稍等半拍，避免立即拉起系统拍照时出现层级抖动。
      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return null;
      return takePhotos(
        context: context,
        isCoursesBook: isCoursesBook,
        isCoursesBookFront: isCoursesBookFront,
      );
    }
    if (type == 1) {
      return pickImage(context);
    }
    return null;
  }

  /// 从相册选择单张原始图片。
  static Future<File?> _pickImageRaw({required BuildContext context}) async {
    if (Platform.isMacOS) {
      await _ensureMacOSDirectoryCacheValid();
      final XFile? photo = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (photo == null) return null;
      final bool granted = await _saveAndValidateMacOSDirectory(photo.path);
      if (!granted) return null;
      return _validateRawImagePath(photo.path);
    }

    final bool isPhotosPermission = await PermissionUtils.photos(context);
    if (!isPhotosPermission) return null;
    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    return _validateRawImagePath(photo?.path);
  }

  /// 校验并构造原始图片列表。
  static List<File> _buildRawImageList(List<XFile> files) {
    final List<File> list = [];
    for (final XFile element in files) {
      final File file = File(element.path);
      if (file.existsSync() && CommonUtil.isImage(element.path)) {
        list.add(file);
      }
    }
    return list;
  }

  /// 校验单张原始图片路径是否可用。
  static Future<File?> _validateRawImagePath(String? path) async {
    if (path == null || path.isEmpty) return null;
    final File file = File(path);
    if (!(await file.exists())) return null;
    if (!CommonUtil.isImage(file.path)) {
      ToastUtils.showToast(text: "文件类型不支持");
      return null;
    }
    return file;
  }

  /// 在 macOS 下清理失效的目录缓存。
  static Future<void> _ensureMacOSDirectoryCacheValid() async {
    final String? initialDir = CoverDirectoryCacheUtil.lastDirectory;
    if (initialDir == null) return;
    print("初始目录, initialDir:$initialDir");
    if (!(await Directory(initialDir).exists())) {
      CoverDirectoryCacheUtil.clear();
    }
  }

  /// 在 macOS 下保存本次选择目录，并校验当前目录访问权限。
  static Future<bool> _saveAndValidateMacOSDirectory(String filePath) async {
    final String parentPath = File(filePath).parent.path;
    CoverDirectoryCacheUtil.saveDirectory(parentPath);
    final bool granted = await FileUtils.checkDirAccess(parentPath);
    if (!granted) {
      ToastUtils.showToast(text: '请开启文件权限');
      return false;
    }
    return true;
  }

  /// 选择视频
  static Future<File?> selectVideo({
    Duration maxDuration = const Duration(seconds: 30),
  }) async {
    final List<String> videoExtensions = [
      'mp4',
      'mov',
      'm4v',
      'avi',
      'mkv',
      'webm',
      'wmv',
      '3gp',
      'mpeg',
      'mpg',
    ];
    String? path;
    if (Platform.isAndroid || Platform.isIOS) {
      final XFile? video = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );
      path = video?.path;
    } else {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: videoExtensions,
        lockParentWindow: true,
        dialogTitle: "请选择视频",
      );
      if (result == null) return null;
      if (result.files.isEmpty) return null;
      path = result.files.first.path;
    }
    if (path == null) return null;
    final File file = File(path);
    if (!(await file.exists())) return null;

    try {
      // 选择后先校验视频时长，超出限制时直接拦截。
      final VideoCompressInfo? videoInfo = await VideoCompressUtils.getVideoInfo(file);
      if (videoInfo == null) {
        ToastUtils.showToast(text: "视频解析失败");
        return null;
      }
      if (videoInfo.duration > maxDuration) {
        ToastUtils.showToast(text: "视频时长不能超过 ${maxDuration.inSeconds} 秒");
        return null;
      }

      ToastUtils.showLoading();
      final File? compressedFile = await VideoCompressUtils.compressVideoToHevc(file);
      if (compressedFile == null) {
        ToastUtils.showToast(text: "视频压缩失败");
        return null;
      }
      return compressedFile;
    } catch (e) {
      ToastUtils.showToast(text: "视频解析失败");
      return null;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 录制视频
  static Future<File?> recordVideo({
    required BuildContext context,
    Duration maxDuration = const Duration(seconds: 30),
  }) async {
    bool isCameraPermission = await PermissionUtils.camera(context);
    if (!isCameraPermission) return null;
    if (!context.mounted) return null;

    if (!Platform.isWindows) {
      bool isMicrophonePermission = await PermissionUtils.microphone(context);
      if (!isMicrophonePermission) return null;
    }

    if (!context.mounted) return null;

    final XFile? video = await ImagePicker().pickVideo(
      source: ImageSource.camera, 
      maxDuration: maxDuration,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (video == null) return null;

    final File file = File(video.path);
    if (!(await file.exists())) return null;

    try {
      ToastUtils.showLoading();
      final File? compressedFile = await VideoCompressUtils.compressVideoToHevc(file);
      if (compressedFile == null) {
        ToastUtils.showToast(text: "视频压缩失败");
        return null;
      }
      return compressedFile;
    } finally {
      ToastUtils.hideLoading();
    }
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
  const ShowSelectTypeDialogWidget({super.key, required this.title, this.onTap});

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
              padding: EdgeInsets.symmetric(horizontal: 64.wMin, vertical: 40.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cBgSecondary,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
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

  Widget _buildIconWidget(String svg, String name, {required Function() onTap}) {
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
