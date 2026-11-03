import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_scaffold.dart';
import '../bindings/approved_images_confirm_binding.dart';
import '../controllers/approved_images_confirm_controller.dart';

class ApprovedImagesConfirmView extends GetView<ApprovedImagesConfirmController> {
  final String tagText;
  const ApprovedImagesConfirmView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.APPROVED_IMAGES_CONFIRM}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ApprovedImagesConfirmView(tagText: tag),
      binding: ApprovedImagesConfirmBinding(tag: tag),
      routeName: Routes.APPROVED_IMAGES_CONFIRM,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
        showCollectButton: false,
        title: "确认审核",
        body: Container(
          padding: EdgeInsets.all(20.wMin),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '是否覆盖已经审核通过的图片',
                      style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 18.wMin, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.wMin),
              Expanded(
                child: Obx(() {
                  final selectedUrl = controller.selectedImageUrl;
                  final images = controller.images;
                  final approvedUrls = images.map((e) => e.imageUrl ?? '').where((e) => e.isNotEmpty).toList();
                  final allUrls = <String>[
                    ...approvedUrls,
                    if (selectedUrl.isNotEmpty) selectedUrl,
                  ];

                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.wMin),
                          decoration: BoxDecoration(
                            color: AppTheme.cSurfaceSecondary.color,
                            borderRadius: BorderRadius.circular(12.wMin),
                            border: Border.all(color: AppTheme.cBorderPrimary.color),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text('原审核通过图片:', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 18.wMin, fontWeight: FontWeight.w600))),
                              SizedBox(height: 8.wMin),
                              Expanded(
                                child: approvedUrls.isEmpty
                                    ? Center(child: Text('暂无图片', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 14.wMin)))
                                    : AspectRatio(
                                        aspectRatio: 1,
                                        child: PageView.builder(
                                          itemCount: approvedUrls.length,
                                          itemBuilder: (context, index) {
                                            final url = approvedUrls[index];
                                            return Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Positioned.fill(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8.wMin),
                                                    child: Image.network(
                                                      url,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (ctx, e, stack) => buildEmptyWidget(),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 10.wMin,
                                                  bottom: 10.wMin,
                                                  child: GestureDetector(
                                                    behavior: HitTestBehavior.opaque,
                                                    onTap: () {
                                                      ShowBigResourceDialog.showImage(context: context, imageUrls: allUrls, index: 0);
                                                    },
                                                    child: Container(
                                                      width: 34.wMin,
                                                      height: 34.wMin,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black.withOpacity(0.45),
                                                        borderRadius: BorderRadius.circular(8.wMin),
                                                      ),
                                                      child: Icon(Icons.zoom_out_map, color: Colors.white, size: 18.wMin),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.wMin),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.wMin),
                          decoration: BoxDecoration(
                            color: AppTheme.cSurfaceSecondary.color,
                            borderRadius: BorderRadius.circular(12.wMin),
                            border: Border.all(color: AppTheme.cBorderPrimary.color),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '本次选择图片:',
                                  style: TextStyle(
                                    color: AppTheme.cTextPrimary.color,
                                    fontSize: 18.wMin,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.wMin),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.wMin),
                                          child: Image.network(
                                            selectedUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder: (ctx, e, stackTrace) => buildEmptyWidget(),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 10.wMin,
                                        bottom: 10.wMin,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            if (selectedUrl.isEmpty) return;
                                            ShowBigResourceDialog.showImage(context: context, imageUrls: allUrls, index: approvedUrls.length);
                                          },
                                          child: Container(
                                            width: 34.wMin,
                                            height: 34.wMin,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.45),
                                              borderRadius: BorderRadius.circular(8.wMin),
                                            ),
                                            child: Icon(Icons.zoom_out_map, color: Colors.white, size: 18.wMin),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }),
              ),
              SizedBox(height: 16.wMin),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.wMin), border: Border.all(color: AppTheme.cBorderPrimary.color)),
                height: 104.wMin,
                padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                width: double.infinity,
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        controller.closePage();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.cBorderSecondary.color, width: 1.wMin),
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: Colors.transparent,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                          height: 40.wMin,
                          alignment: Alignment.center,
                          child: Text('取消', style: TextStyle(color: AppTheme.cTextPrimary.color))),
                    ),
                    SizedBox(width: 13.wMin),
                    GestureDetector(
                      onTap: () {
                        controller.submit();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: Color(0xFFFF781F),
                          ),
                          height: 40.wMin,
                          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                          alignment: Alignment.center,
                          child: Text('确认覆盖', style: TextStyle(color: Colors.white))),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
