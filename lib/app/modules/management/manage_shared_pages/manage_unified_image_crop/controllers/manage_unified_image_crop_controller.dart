import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../enums/enums.dart';
import '../../../manage_content/manage_zhendu_console/enums/manage_zhendu_enums.dart';
import '../../../utils/manage_breadcrumb_utils.dart';

class ManageUnifiedImageCropController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageUnifiedImageCropController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIFIED_IMAGE_CROP;

  @override
  String get breadcrumbTitle => '图片裁剪';

  // 传进来的参数
  /// 图片id列表 图片编辑时传
  List<int?>? imageIds;
  /// uid 必传
  int? uid;
  /// 类型 必传
  String? type;
  /// 语义id 有语义id时传
  int? semanticId;
  /// 角色设定图类型 创建角色设定图时传
  ManageZhenduPersonaViewEnum? viewType;
  /// 场景图片帧类型 修改场景分镜图时传 
  SceneStoryboardTypeEnum? sceneType;
  /// 视觉项目id 改场景分镜图时必传或者创建场景分镜图时必传
  int? visualProjectId;
  /// 风格id
  int? styleId;
  /// 裁剪是否固定比例
  final RxBool isFixedAspectRatio = true.obs;

  /// 图片详情
  final Rx<ManageCreateImageInfoEntity> imageDetail = ManageCreateImageInfoEntity().obs;

  /// 裁剪图片数据
  final Rx<Uint8List?> croppedImageData = Rx(null);

  /// 裁剪控制器
  final CropController cropController = CropController();

  /// 当前裁剪的尺寸
  final Rx<Size> imageSizeSize = Size.zero.obs;

  /// 原图尺寸
  final Rx<Size> sourceImageSize = Size.zero.obs;

  /// 比例列表
  final List<ImageAspectRatioEnums?> aspectRatioList = [
    null,
    ...ImageAspectRatioEnums.values,
  ];

  /// 图片比例
  final Rx<ImageAspectRatioEnums?> aspectRatio = Rx(null);

  /// 目标宽度
  final TextEditingController targetWidthController = TextEditingController(text: "0");
  /// 目标高度
  final TextEditingController targetHeightController = TextEditingController(text: "0");
  
  /// 实际超分尺寸（按 height 同比超分，width 向上规整到 32 的倍数）
  final Rx<Size> actualUpscaleSize = Size.zero.obs;

  static const int _alignment = 32;
  bool _isCropReady = false;
  Rect? _pendingCropArea;
  Rect _currentCropArea = Rect.zero;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      imageIds = Get.arguments['imageIds']?.whereType<int?>().toList();
      uid = Get.arguments['uid'];
      type = Get.arguments['type'];
      semanticId = Get.arguments['semanticId'];
      viewType = Get.arguments['viewType'];
      sceneType = Get.arguments['sceneType'];
      visualProjectId = Get.arguments['visualProjectId'];
      styleId = Get.arguments['styleId'];
      isFixedAspectRatio.value = Get.arguments['isFixedAspectRatio'] ?? true;
      queryImageDetail();
      
    }
  }

  /// 查询图片详情
  Future<void> queryImageDetail() async{
    // if(uid == null || type == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "subContent": {
          "uid": uid,
          "type": type,
          "semanticId": semanticId,
        }, 
        "imageIds": imageIds,
        "viewType": viewType?.value,
        "sceneType": sceneType?.value,
        "visualProjectId": visualProjectId,
        "styleId": styleId,
      };
      ManageCreateImageInfoEntity? res = await LanguageConsoleRequest.queryCreateImageInfo(data: reqData);
      if(res == null) return;
      imageDetail.value = res;

      Size orgSize = Size(res.output?.width?.toDouble() ?? 0, res.output?.height?.toDouble() ?? 0);
      
      aspectRatio.value = ImageAspectRatioUtils.getAspectRatio(orgSize);

      targetWidthController.text = orgSize.width.toInt().toString();
      targetHeightController.text = orgSize.height.toInt().toString();
      
      if(aspectRatio.value == null){
        isFixedAspectRatio.value = false;
      }

      getCroppedImageData();

    } finally{
      ToastUtils.hideLoading();
    }
  }
  


  /// 获取图片字节数据
  Future<void> getCroppedImageData() async {
    String url = imageDetail.value.images?.first?.imageUrl??"";

    if (url.trim().isEmpty) {
      croppedImageData.value = null;
      return;
    }

    try {
      final uri = Uri.parse(url);
      final byteData = await NetworkAssetBundle(uri).load(uri.toString());
      final bytes = byteData.buffer.asUint8List();
      croppedImageData.value = bytes;
      final decodedSize = await _decodeImageSize(bytes);
      if (decodedSize != null) {
        sourceImageSize.value = decodedSize;
        imageSizeSize.value = _getDefaultCropSize(aspectRatio.value);
      }
      _setCropAreaSafely(_getDefaultCropArea(aspectRatio.value));
      syncByTargetHeight();
    } catch (_) {
      croppedImageData.value = null;
    }
  }

  void _setCropAreaSafely(Rect area) {
    _currentCropArea = area;
    _pendingCropArea = area;
    if (_isCropReady) {
      cropController.area = area;
      _pendingCropArea = null;
    }
  }

  void onCropStatusChanged(CropStatus status) {
    _isCropReady = status == CropStatus.ready;
    if (_isCropReady && _pendingCropArea != null) {
      cropController.area = _pendingCropArea!;
      _pendingCropArea = null;
    }
  }


  int _roundUpToAlignment(int value) {
    if (value <= 0) return 0;
    return ((value + _alignment - 1) ~/ _alignment) * _alignment;
  }

  int _parsePositiveInt(String text, {int fallback = 1}) {
    final int? value = int.tryParse(text.trim());
    if (value == null || value <= 0) return fallback;
    return value;
  }

  Future<Size?> _decodeImageSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }

  Size _getDefaultCropSize(ImageAspectRatioEnums? ratio) {
    return _getDefaultCropArea(ratio).size;
  }

  Rect _getDefaultCropArea(ImageAspectRatioEnums? ratio) {
    final double imageWidth = sourceImageSize.value.width;
    final double imageHeight = sourceImageSize.value.height;
    if (imageWidth <= 0 || imageHeight <= 0) {
      return const Rect.fromLTWH(0, 0, 1024, 768);
    }

    // 对齐 TSX: Any 模式默认 [x:0.15, y:0.12, w:0.7, h:0.72]
    if (ratio == null) {
      return Rect.fromLTWH(
        imageWidth * 0.15,
        imageHeight * 0.12,
        imageWidth * 0.7,
        imageHeight * 0.72,
      );
    }

    final double ratioValue = ratio.width / ratio.height;
    final double imageRatio = imageWidth / imageHeight;
    const double padding = 0.12;

    late final double xFactor;
    late final double yFactor;
    late final double widthFactor;
    late final double heightFactor;

    if (imageRatio >= ratioValue) {
      heightFactor = 1 - padding * 2;
      widthFactor = (heightFactor * ratioValue / imageRatio).clamp(0.08, 0.82);
      xFactor = (1 - widthFactor) / 2;
      yFactor = padding;
    } else {
      widthFactor = 1 - padding * 2;
      heightFactor = (widthFactor * imageRatio / ratioValue).clamp(0.08, 0.82);
      xFactor = padding;
      yFactor = (1 - heightFactor) / 2;
    }

    return Rect.fromLTWH(
      imageWidth * xFactor,
      imageHeight * yFactor,
      (imageWidth * widthFactor).clamp(1, imageWidth),
      (imageHeight * heightFactor).clamp(1, imageHeight),
    );
  }

  void _applyActualUpscaleByHeight(int targetHeight) {
    final double cropWidth = imageSizeSize.value.width;
    final double cropHeight = imageSizeSize.value.height;

    if (cropWidth <= 0 || cropHeight <= 0 || targetHeight <= 0) {
      actualUpscaleSize.value = Size.zero;
      return;
    }

    // 对齐 TSX：高度先向上对齐到 32，再按同比算宽并向上对齐到 32
    final int alignedHeight = _roundUpToAlignment(targetHeight);
    final double scaledWidth = cropWidth * alignedHeight / cropHeight;
    final int alignedWidth = _roundUpToAlignment(scaledWidth.round());
    actualUpscaleSize.value = Size(alignedWidth.toDouble(), alignedHeight.toDouble());
  }

  /// 根据目标高度联动实际超分尺寸
  void syncByTargetHeight() {
    final int targetHeight = _parsePositiveInt(targetHeightController.text, fallback: 1);
    _applyActualUpscaleByHeight(targetHeight);
  }



  /// 切换图片比例
  void switchAspectRatio(ImageAspectRatioEnums? value){
    aspectRatio.value = value;
    imageSizeSize.value = _getDefaultCropSize(value);
    _setCropAreaSafely(_getDefaultCropArea(value));
    syncByTargetHeight();
  }

  /// 裁剪框变化大小
  void cropRectChanged(Rect viewportRect, Rect imageRect){
    if (imageRect.width <= 0 || imageRect.height <= 0) {
      return;
    }

    _currentCropArea = imageRect;
    imageSizeSize.value = Size(
      imageRect.width.clamp(1, sourceImageSize.value.width),
      imageRect.height.clamp(1, sourceImageSize.value.height),
    );
    syncByTargetHeight();
  }

  /// 查看原图
  void viewOriginalImage(BuildContext context){
    if(imageDetail.value.images?.first?.imageUrl == null) return; 
    ShowBigResourceDialog.showImage(
      context: context, 
      imageUrls: [imageDetail.value.images!.first!.imageUrl!],
    );
  }


  /// 撤销裁剪
  Future<void> undoCrop(BuildContext context) async{
    if(imageDetail.value.images?.first?.imageId == null) return; 

    bool res = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认撤销裁剪吗？",
    );
    if(!res) return;

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "imageId": imageDetail.value.images?.first?.imageId,
      };

      String? res = await LanguageConsoleRequest.undoCropImage(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);

    } finally{
      ToastUtils.hideLoading();
    }

  }

  Future<void> confirmCrop(BuildContext context) async{
    if(imageDetail.value.images?.first?.imageId == null) return; 

    bool res = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认裁剪吗？",
    );
    if(!res) return;

    try {
      ToastUtils.showLoading();

      final double sourceWidth = sourceImageSize.value.width;
      final double sourceHeight = sourceImageSize.value.height;
      final Rect normalizedArea = (sourceWidth > 0 && sourceHeight > 0)
          ? _currentCropArea
          : _getDefaultCropArea(aspectRatio.value);

      final double x = (sourceWidth <= 0 ? 0 : normalizedArea.left / sourceWidth).clamp(0.0, 1.0).toDouble();
      final double y = (sourceHeight <= 0 ? 0 : normalizedArea.top / sourceHeight).clamp(0.0, 1.0).toDouble();
      final double width = (sourceWidth <= 0 ? 1 : normalizedArea.width / sourceWidth).clamp(0.0, 1.0 - x).toDouble();
      final double height = (sourceHeight <= 0 ? 1 : normalizedArea.height / sourceHeight).clamp(0.0, 1.0 - y).toDouble();

      Map<String, dynamic> reqData = {
        "subContent": {
          "uid": uid,
          "type": type,
          "semanticId": semanticId,
        },
        "imageId": imageDetail.value.images?.first?.imageId,
        "width": targetWidthController.text,
        "height": targetHeightController.text,
        "visualProjectId": visualProjectId,
        "sceneType": sceneType?.value,
        "viewType": viewType?.value,
        "boxs": [
          double.parse(x.toStringAsFixed(6)),
          double.parse(y.toStringAsFixed(6)),
          double.parse(width.toStringAsFixed(6)),
          double.parse(height.toStringAsFixed(6)),
        ],
      };

      String? res = await LanguageConsoleRequest.cropImage(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);

    } finally{
      ToastUtils.hideLoading();
    }
  }


  @override
  void onClose() {
    targetWidthController.dispose();
    targetHeightController.dispose();
    super.onClose();
  }
}
