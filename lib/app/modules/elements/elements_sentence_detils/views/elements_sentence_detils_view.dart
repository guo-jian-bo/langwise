import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../theme/theme.dart';
import '../../../../../utils/lock_utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/elements_sentence_detils_binding.dart';
import '../controllers/elements_sentence_detils_controller.dart';
import 'elements_sentence_detils_content_widget.dart';

class ElementsSentenceDetilsView extends GetView<ElementsSentenceDetilsController> {
  final String tagText;
  const ElementsSentenceDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => ElementsSentenceDetilsView(tagText: tag),
      binding: ElementsSentenceDetilsBinding(tagText: tag),
      routeName: Routes.EN_SENTENCE_DETAIL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasLock =
          controller.sentencesDetils.value.rights?.isLock == true ||
          controller.sentencesDetils.value.rights?.isNoRights == true;
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
                                bottom: 10.wMin +
                                    MediaQuery.of(context).padding.bottom,
                              ),
                              child: ElementsSentenceDetilsContentWidget(
                                controller: controller,
                                tagText: tagText,
                              ),
                            ),
                          ),
                        ),
                        if (hasLock)
                          Positioned.fill(
                            child: LockOverlayWidget(
                              rights: controller.sentencesDetils.value.rights,
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
