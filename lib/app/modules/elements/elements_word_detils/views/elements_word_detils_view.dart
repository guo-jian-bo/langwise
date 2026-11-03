import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../utils/lock_utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/elements_word_detils_binding.dart';
import '../controllers/elements_word_detils_controller.dart';
import 'elements_word_detils_content_widget.dart';

class ElementsWordDetilsView extends GetView<ElementsWordDetilsController> {
  final String tagText;
  const ElementsWordDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => ElementsWordDetilsView(tagText: tag),
      binding: ElementsWordDetilsBinding(tagText: tag),
      routeName: Routes.EN_WORD_DETAIL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasLock =
          controller.cardDetils.value.rights?.isLock == true ||
          controller.cardDetils.value.rights?.isNoRights == true;
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Column(
          children: [
            const BreadcrumbWidget(),
            Expanded(
              child: controller.isLoading.value
                  ? const SizedBox.expand()
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: hasLock,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 40.wMin,
                                right: 40.wMin,
                                bottom: 10.wMin +
                                    MediaQuery.of(context).padding.bottom,
                              ),
                              child: ElementsWordDetilsContentWidget(
                                controller: controller,
                              ),
                            ),
                          ),
                        ),
                        if (hasLock)
                          Positioned.fill(
                            child: LockOverlayWidget(
                              rights: controller.cardDetils.value.rights,
                              child: const SizedBox.expand(),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      );
    });
  }
}
