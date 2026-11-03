

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import 'widgets.dart';

class ShowBigImageDialog{

  static Future<int?> show({
    required BuildContext context,
    required List<String> imageUrls,
    int index = 0,
  }) async{
    return await showDialog<int?>(
      context: context,
      builder: (context) {
        return ShowBigImageDialogWidget(
          imageUrls: imageUrls,
          index: index,
        );
      },
    );
  }

}

class ShowBigImageDialogWidget extends StatefulWidget {
  final List<String> imageUrls;
  final int index;
  const ShowBigImageDialogWidget({super.key, required this.imageUrls, required this.index});

  @override
  State<ShowBigImageDialogWidget> createState() => _ShowBigImageDialogWidgetState();
}

class _ShowBigImageDialogWidgetState extends State<ShowBigImageDialogWidget> {

  late PageController pageController;

  final _viewController = PhotoViewController();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    pageController = PageController(initialPage: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back(result: currentIndex);
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Listener(
                onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final delta = event.scrollDelta.dy;
                  final scale = _viewController.scale ?? 1.0;
                  final newScale = scale - delta / 1000;
                  _viewController.scale = newScale.clamp(0.2, 10.0);
                }
              },
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      controller: _viewController,
                      imageProvider: NetworkImage(widget.imageUrls[index]),
                      initialScale: PhotoViewComputedScale.contained,
                      maxScale: 2.0,
                      minScale: 0.1,
                      heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrls[index]),
                    );
                  },
                  itemCount: widget.imageUrls.length,
                  loadingBuilder: (context, event) => Center(
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: AppTheme.cBgBrand.color,
                        size: 100.wMin,
                      ),
                    ),
                  ),
                  backgroundDecoration: BoxDecoration(color: AppTheme.cBgPrimary.color),
                  pageController: pageController,
                  onPageChanged: (index) {
                    currentIndex = index;
                    if(mounted) setState(() {});
                  },
                ),
              ),
            ),

            Positioned(
              right: 24.wMin + MediaQuery.of(context).padding.right,
              top: 24.wMin + MediaQuery.of(context).padding.top,
              child: TapScaleWidget(
                sclae: 1.05,
                onTap: () => Get.back(result: currentIndex),
                child: Container(
                  width: 42.wMin,
                  height: 42.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceTertiary.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/x.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                  ),
                ),
              ),
            ),

            Positioned(
              right: 24.wMin + MediaQuery.of(context).padding.right,
              bottom: 24.wMin + MediaQuery.of(context).padding.bottom,
              child: Visibility(
                visible: widget.imageUrls.length > 1,
                child: Container(
                  padding: EdgeInsets.all(8.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceTertiary.color,
                    borderRadius: BorderRadius.circular(8.wMin),
                  ),
                  child: Text(
                    "${currentIndex + 1}/${widget.imageUrls.length}",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 48.wMin + MediaQuery.of(context).padding.left,
              child: Visibility(
                visible: widget.imageUrls.length > 1,
                child: TapScaleWidget(
                  onTap: () {
                    if(currentIndex <= 0) return;
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  sclae: 1.05,
                  child: Container(
                    width: 80.wMin,
                    height: 80.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceTertiary.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppTheme.cTextPrimary.color,
                      size: 48.wMin,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              right: 48.wMin + MediaQuery.of(context).padding.left,
              child: Visibility(
                visible: widget.imageUrls.length > 1,
                child: TapScaleWidget(
                  onTap: () {
                    if(currentIndex >= widget.imageUrls.length - 1) return;
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  sclae: 1.05,
                  child: Container(
                    width: 80.wMin,
                    height: 80.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceTertiary.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.cTextPrimary.color,
                      size: 48.wMin,
                    ),
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}