import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../theme/theme.dart';
import '../../../../../utils/lock_utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/elements_phrase_detils_binding.dart';
import '../controllers/elements_phrase_detils_controller.dart';
import 'elements_phrase_detils_content_widget.dart';

class ElementsPhraseDetilsView extends GetView<ElementsPhraseDetilsController> {
  final String tagText;

  const ElementsPhraseDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => ElementsPhraseDetilsView(tagText: tag),
      binding: ElementsPhraseDetilsBinding(tagText: tag),
      routeName: Routes.EN_PHRASE_DETAIL,
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
                            child: Container(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: 10.wMin +
                                      MediaQuery.of(context).padding.bottom,
                                ),
                                child: ElementsPhraseDetilsContentWidget(
                                  controller: controller,
                                  prototypeWord:
                                      controller.cardDetils.value.content,
                                ),
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
