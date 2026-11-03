import 'dart:math' as math;

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

class OptimizedCourseCachedImageWidget extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Border? border;
  final Map<String, String>? headers;
  final BoxFit fit;
  final Alignment alignment;
  final Duration fadeInDuration;
  final bool gaplessPlayback;
  final FilterQuality filterQuality;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const OptimizedCourseCachedImageWidget(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.margin,
    this.borderRadius,
    this.border,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.fadeInDuration = Duration.zero,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.medium,
    this.placeholder,
    this.errorWidget,
    this.headers,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        border: border,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: SizedBox(
          width: width,
          height: height,
          child: url.isEmpty
              ? Container(child: placeholder)
              : _buildImage(context),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final String effectiveKey = ResourceCacheManager.instance.extractKey(url);
    final String normalizedKey = _normalizeKey(effectiveKey);
    final double devicePixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    final int? effectiveMemCacheWidth =
        memCacheWidth ?? _resolveCachePixels(width, devicePixelRatio);
    final int? effectiveMemCacheHeight =
        memCacheHeight ?? _resolveCachePixels(height, devicePixelRatio);

    return CachedNetworkImage(
      imageUrl: url,
      cacheKey: normalizedKey.isEmpty ? null : normalizedKey,
      cacheManager: ResourceCacheManager.instance.cacheManager,
      httpHeaders: headers,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: Duration.zero,
      filterQuality: filterQuality,
      memCacheWidth: effectiveMemCacheWidth,
      memCacheHeight: effectiveMemCacheHeight,
      placeholder: (context, _) => placeholder ?? const SizedBox.shrink(),
      errorBuilder: (context, _, __) => errorWidget ?? const SizedBox.shrink(),
      imageBuilder: (context, imageProvider) {
        if (normalizedKey.isNotEmpty) {
          ResourceCacheManager.instance.touch(
            normalizedKey,
            ResourceType.image,
          );
        }
        return Image(
          image: imageProvider,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          filterQuality: filterQuality,
          gaplessPlayback: gaplessPlayback,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? const SizedBox.shrink();
          },
        );
      },
    );
  }

  int? _resolveCachePixels(double? logicalSize, double devicePixelRatio) {
    if (logicalSize == null || logicalSize <= 0) return null;
    final double scaledPixels = logicalSize * math.max(1.0, devicePixelRatio);
    return scaledPixels.ceil().clamp(1, 4096);
  }

  String _normalizeKey(String key) {
    if (key.isEmpty) return '';
    final int dotIndex = key.lastIndexOf('.');
    if (dotIndex > 0) {
      return key.substring(0, dotIndex);
    }
    return key;
  }
}
