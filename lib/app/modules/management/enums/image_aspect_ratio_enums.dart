
import 'dart:ui';

/// 图片比例
enum ImageAspectRatioEnums{

  ratio_1_1("1:1", 1, 1),
  ratio_4_3("4:3", 4, 3),
  ratio_3_4("3:4", 3, 4),
  ratio_16_9("16:9", 16, 9),
  ratio_9_16("9:16", 9, 16),
  ratio_2_3("2:3", 2, 3),
  ratio_3_2("3:2", 3, 2),
  ratio_4_5("4:5", 4, 5),
  ratio_5_4("5:4", 5, 4),
  ratio_21_9("21:9", 21, 9);

  final String name;
  final int width;
  final int height;

  const ImageAspectRatioEnums(this.name, this.width, this.height);
}


/// 图片分辨率
enum ImageQualityEnums{
  quality_512("512", 512),
  quality_1024("1K", 1024),
  quality_2048("2K", 2048),
  quality_4096("4K", 3072);

  final String name;
  final int value;

  const ImageQualityEnums(this.name, this.value);
}

class ImageAspectRatioUtils{

  static const double _ratioTolerance = 0.01;
  static const double _baseQualityValue = 3072.0;

  /// 与 Web 端 ImageTaskCreatePage 保持一致的 4K 基准分辨率
  static const Map<ImageAspectRatioEnums, Size> _baseResolution4K = {
    ImageAspectRatioEnums.ratio_4_3: Size(2880, 2160),
    ImageAspectRatioEnums.ratio_3_4: Size(2160, 2880),
    ImageAspectRatioEnums.ratio_16_9: Size(3840, 2160),
    ImageAspectRatioEnums.ratio_9_16: Size(2160, 3840),
    ImageAspectRatioEnums.ratio_2_3: Size(2400, 3600),
    ImageAspectRatioEnums.ratio_3_2: Size(3600, 2400),
    ImageAspectRatioEnums.ratio_1_1: Size(3072, 3072),
    ImageAspectRatioEnums.ratio_4_5: Size(2400, 3000),
    ImageAspectRatioEnums.ratio_5_4: Size(3000, 2400),
    ImageAspectRatioEnums.ratio_21_9: Size(3780, 1620),
  };


  /// 获取图片的宽高
  static Size getImageSize(ImageAspectRatioEnums aspectRatio, ImageQualityEnums quality){
    final Size baseSize = _baseResolution4K[aspectRatio] ?? Size.zero;
    final double scale = quality.value / _baseQualityValue;
    return Size(
      (baseSize.width * scale).roundToDouble(),
      (baseSize.height * scale).roundToDouble(),
    );
  }


  /// 根据宽高算出比例
  static ImageAspectRatioEnums? getAspectRatio(Size widthHeight){
    if (widthHeight.width <= 0 || widthHeight.height <= 0) {
      return null;
    }

    final double targetRatio = widthHeight.width / widthHeight.height;
    ImageAspectRatioEnums? bestRatio;
    double bestDiff = double.infinity;

    for (final ratio in ImageAspectRatioEnums.values) {
      final double enumRatio = ratio.width / ratio.height;
      final double diff = (targetRatio - enumRatio).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestRatio = ratio;
      }
    }

    if (bestDiff <= _ratioTolerance) {
      return bestRatio;
    }
    return null;
  }

  /// 根据宽高算出分辨率
  static ImageQualityEnums? getQuality(Size widthHeight){
    if (widthHeight.width <= 0 || widthHeight.height <= 0) {
      return null;
    }

    final ImageAspectRatioEnums? ratio = getAspectRatio(widthHeight);
    if (ratio == null) {
      return null;
    }

    final Size? baseSize = _baseResolution4K[ratio];
    if (baseSize == null || baseSize.width <= 0 || baseSize.height <= 0) {
      return null;
    }

    final double widthScale = widthHeight.width / baseSize.width;
    final double heightScale = widthHeight.height / baseSize.height;
    final double scale = (widthScale + heightScale) / 2;
    final double targetQualityValue = scale * _baseQualityValue;

    ImageQualityEnums? bestQuality;
    double bestDiff = double.infinity;
    for (final quality in ImageQualityEnums.values) {
      final double diff = (quality.value - targetQualityValue).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestQuality = quality;
      }
    }
    return bestQuality;
  }

}
