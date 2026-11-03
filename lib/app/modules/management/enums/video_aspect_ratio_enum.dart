import 'dart:ui';

/// 视频比例
enum VideoAspectRatioEnum{
  ratio_16_9("标准宽屏", 16, 9),
  ratio_9_16("标准竖屏", 9, 16),
  ratio_4_3("传统电视", 4, 3),
  ratio_3_4("传统竖屏", 3, 4),
  ratio_1_1("正方形", 1, 1),
  ratio_21_9("电影宽银幕", 21, 9);

  final String name;
  final int width;
  final int height;

  const VideoAspectRatioEnum(this.name, this.width, this.height);

}

/// 视频清晰度
enum VideoQualityEnum{
  quality_1k("1K", 720),
  quality_2k("2K", 1080),
  quality_4k("4K", 2160);

  final String name;
  final int value;

  const VideoQualityEnum(this.name, this.value);
}

class VideoRatioQualityUtils{

  /// 分辨率映射表
  static const Map<VideoAspectRatioEnum, Map<VideoQualityEnum, Size>> _resolutionMap = {
    VideoAspectRatioEnum.ratio_16_9: {
      VideoQualityEnum.quality_1k: Size(1280, 720),
      VideoQualityEnum.quality_2k: Size(1920, 1080),
      VideoQualityEnum.quality_4k: Size(3840, 2160),
    },
    VideoAspectRatioEnum.ratio_9_16: {
      VideoQualityEnum.quality_1k: Size(720, 1280),
      VideoQualityEnum.quality_2k: Size(1080, 1920),
      VideoQualityEnum.quality_4k: Size(2160, 3840),
    },
    VideoAspectRatioEnum.ratio_4_3: {
      VideoQualityEnum.quality_1k: Size(960, 720),
      VideoQualityEnum.quality_2k: Size(1440, 1080),
      VideoQualityEnum.quality_4k: Size(2880, 2160),
    },
    VideoAspectRatioEnum.ratio_3_4: {
      VideoQualityEnum.quality_1k: Size(720, 960),
      VideoQualityEnum.quality_2k: Size(1080, 1440),
      VideoQualityEnum.quality_4k: Size(2160, 2880),
    },
    VideoAspectRatioEnum.ratio_1_1: {
      VideoQualityEnum.quality_1k: Size(720, 720),
      VideoQualityEnum.quality_2k: Size(1024, 1024),
      VideoQualityEnum.quality_4k: Size(2160, 2160),
    },
    VideoAspectRatioEnum.ratio_21_9: {
      VideoQualityEnum.quality_1k: Size(1280, 544),
      VideoQualityEnum.quality_2k: Size(1920, 816),
      VideoQualityEnum.quality_4k: Size(3840, 1632),
    },
  };

  /// 根据比例和清晰度获取宽高
  static Size getSize(VideoAspectRatioEnum ratio, VideoQualityEnum quality) {
    return _resolutionMap[ratio]?[quality] ?? Size.zero;
  }

  /// 根据视频宽高获取比例
  static VideoAspectRatioEnum? getAspectRatio(Size size) {
    for (var entry in _resolutionMap.entries) {
      for (var resolution in entry.value.values) {
        if (resolution.width == size.width && resolution.height == size.height) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// 根据视频宽高获取清晰度
  static VideoQualityEnum? getQuality(Size size) {
    for (var ratioEntry in _resolutionMap.entries) {
      for (var qualityEntry in ratioEntry.value.entries) {
        if (qualityEntry.value.width == size.width && qualityEntry.value.height == size.height) {
          return qualityEntry.key;
        }
      }
    }
    return null;
  }


}


