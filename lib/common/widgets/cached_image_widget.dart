


import 'package:flutter/material.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

class CachedImageWidget extends StatefulWidget {
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
  final Widget? placeholder;
  final Widget? errorWidget;
  const CachedImageWidget(this.url, {
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
    this.placeholder,
    this.errorWidget, 
    this.headers,
  });

  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        border: widget.border,
        borderRadius: widget.borderRadius,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius??BorderRadius.zero,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.url.isEmpty ? Container(child: widget.placeholder) : CachedImage(
            url: widget.url,
            width: widget.width,
            height: widget.height,
            headers: widget.headers,
            fit: widget.fit,
            alignment: widget.alignment,
            fadeInDuration: widget.fadeInDuration,
            gaplessPlayback: widget.gaplessPlayback,
            placeholder: widget.placeholder,
            errorWidget: widget.errorWidget,
          ),
        ),
      ),
    );
  }



}
