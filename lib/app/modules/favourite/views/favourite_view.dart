import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:langwise/app/modules/favourite/views/edit_dialog.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../bindings/favourite_binding.dart';
import '../controllers/favourite_controller.dart';

class FavouriteView extends GetView<FavouriteController> {
  final String tagText;
  const FavouriteView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      FavouriteView(tagText: tag),
      binding: FavouriteBinding(tagText: tag),
      routeName: Routes.FAVOURITE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Obx(
          () => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 24.wMin),
            Row(
              children: [
                SizedBox(width: 70.wMin),
                GestureDetector(
                    onTap: () => Get.back(),
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                        width: 52.wMin,
                        height: 52.wMin,
                        alignment: Alignment.center,
                        child: SvgPicture.asset('assets/svg/public/icon_arrow_back.svg', width: 32.wMin, height: 32.wMin))),
                SizedBox(width: 8.wMin),
                Row(
                    spacing: 40.wMin,
                    children: List.generate(controller.titleList.length, (idx) {
                      return GestureDetector(
                        onTap: () {
                          if (controller.selectedIndex.value == idx) {
                            return;
                          }
                          controller.changeIndex(idx);
                        },
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                controller.titleList[idx],
                                style: TextStyle(
                                  fontSize: 28.wMin,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.cTextPrimary.color,
                                ),
                              ),
                              SizedBox(height: 2.wMin),
                              AnimatedContainer(
                                height: 4.wMin,
                                width: getTextWidth(controller.titleList[idx], TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500)) - 56.wMin,
                                color: controller.selectedIndex.value == idx ? AppTheme.cBorderBrand.color : Colors.transparent,
                                duration: const Duration(milliseconds: 200),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()),
                Spacer(),
                if (controller.selectedIndex.value == 1)
                  GestureDetector(
                    onTap: () {
                      controller.togglePlayListEditMode();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.wMin),
                        border: Border.all(color: AppTheme.cBorderPrimary.color, width: 1.wMin),
                      ),
                      child: Text(
                        controller.isPlayListEditMode.value ? '完成' : '编辑',
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                  ),
                if (controller.selectedIndex.value == 1) SizedBox(width: 16.wMin),
                if(controller.selectedIndex.value == 1)GestureDetector(
                  onTap: () async {
                    if(controller.maxPlayListCount.value <= controller.playList.length){
                      ToastUtils.showToast(text: '听单数量已达到上限',type: ToastType.info);
                      return;
                    }
                    var res = await PlayListEditDialog.show(Get.context!, null, tagText);
                    if(res!=""){
                      controller.getMyPlayList();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.wMin,vertical: 10.wMin),
                    decoration: BoxDecoration(color: AppTheme.cSurfaceInfo.color, borderRadius: BorderRadius.circular(8.wMin)), child: Text('新建听单', style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cInverseTextLight.color))),
                ),
                  SizedBox(width: 70.wMin)
              ],
            ),
            Expanded(child: controller.child),
          ]),
        ));
  }

  double getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr, // 必须指定方向
    )..layout(); // 先 layout 才能拿到 size

    return textPainter.size.width;
  }
}
