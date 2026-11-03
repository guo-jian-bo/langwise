import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/general_setting_button_widget.dart';
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
                        rights: controller.cardDetils.value.rights,
                        showBack: false,
                        child: ElementsPhraseDetilsContentWidget(
                          controller: controller,
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
