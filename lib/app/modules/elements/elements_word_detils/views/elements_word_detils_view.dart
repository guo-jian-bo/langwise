import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/general_setting_button_widget.dart';
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
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BreadcrumbWidget(
              actionWidget: GeneralSettingButtonWidget(),
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
                        child: ElementsWordDetilsContentWidget(
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
