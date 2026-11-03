import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 图片预览页面组件
///
/// 用于全屏预览图片，支持左右切换
class ImagePreviewWidget extends StatefulWidget {
  /// 图片列表
  final List<ImageItem> images;

  /// 初始显示的图片索引
  final int initialIndex;

  const ImagePreviewWidget({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  /// 显示图片预览页面
  ///
  /// [context] 上下文
  /// [images] 图片列表
  /// [initialIndex] 初始显示的图片索引
  static Future<void> show({
    required BuildContext context,
    required List<ImageItem> images,
    int initialIndex = 0,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (BuildContext context, _, __) {
          return ImagePreviewWidget(
            images: images,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 切换到上一张图片
  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 切换到下一张图片
  void _nextImage() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 关闭预览页面
  void _closePreview() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: GestureDetector(
        onTap: _closePreview,
        child: Stack(
          children: [
            // 图片展示区域
            Center(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  final image = widget.images[index];
                  return GestureDetector(
                    onTap: () {}, // 阻止点击图片时关闭预览
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.ww),
                      child: CachedImageWidget(
                        image.imageUrl ?? '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        placeholder: buildLoadingWidget(),
                        errorWidget: buildImage(
                          Assets.managerImageNotFound,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 左侧切换按钮
            if (_currentIndex > 0)
              Positioned(
                left: 260.ww,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: OptimizeUtils.noneThrottle(() {
                    _previousImage();
                  }, 100),
                  child: Container(
                    width: 50.ww,
                    height: 50.ww,
                    decoration: BoxDecoration(
                      color: const Color(0xff2388FF).withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 30.wMin,
                    ),
                  ),
                ),
              ),

            // 右侧切换按钮
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 260.ww,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: OptimizeUtils.noneThrottle(() {
                    _nextImage();
                  }, 100),
                  child: Container(
                    width: 50.ww,
                    height: 50.ww,
                    decoration: BoxDecoration(
                      color: const Color(0xff2388FF).withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 30.wMin,
                    ),
                  ),
                ),
              ),

            // 顶部关闭按钮和图片计数
            Positioned(
              top: MediaQuery.of(context).padding.top + 50.wh,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 图片计数
                  Padding(
                    padding: EdgeInsets.only(left: 50.ww),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // 关闭按钮
                  Padding(
                    padding: EdgeInsets.only(right: 50.ww),
                    child: GestureDetector(
                      onTap: _closePreview,
                      child: Container(
                        width: 40.ww,
                        height: 40.ww,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.wMin,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
