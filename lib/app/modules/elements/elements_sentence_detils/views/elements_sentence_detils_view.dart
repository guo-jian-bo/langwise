import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/general_setting_button_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../theme/theme.dart';
import '../../../../../utils/lock_utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/elements_sentence_detils_binding.dart';
import '../controllers/elements_sentence_detils_v2_controller.dart';
import 'elements_sentence_detils_v2_content_widget.dart';

class ElementsSentenceDetilsView extends GetView<ElementsSentenceDetilsV2Controller> {
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
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const BreadcrumbWidget(
              actionWidget: GeneralSettingButtonWidget(
                hideTranslationOption: true,
              ),
            ),
            Expanded(
              child: controller.isLoading.value
                  ? const SizedBox.expand()
                  : Padding(
                      padding: EdgeInsets.fromLTRB(
                        90.wMin,
                        0.wMin,
                        90.wMin,
                        24.wMin + MediaQuery.of(context).padding.bottom,
                      ),
                      child: LockOverlayWidget(
                        rights: controller.sentenceDetils.value.study?.rights,
                        showBack: false,
                        child: ElementsSentenceDetilsV2ContentWidget(
                          controller: controller,
                          tagText: tagText,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}
