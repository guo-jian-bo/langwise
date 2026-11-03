import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
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
      ElementsPhraseDetilsView(tagText: tag),
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
        body: LockOverlayWidget(
          rights: controller.cardDetils.value.rights,
          child: Container(
            alignment: Alignment.topCenter,
            child: controller.isLoading.value
                ? Container()
                : Container(
                    padding: EdgeInsets.only(
                      top: 10.wMin + MediaQuery.of(context).padding.top,
                      left: 40.wMin,
                      right: 40.wMin,
                      bottom:10.wMin + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      children: [
                        const BackWidget(title: "短语卡片", showBorder: true),
                        Expanded(
                          child: ElementsPhraseDetilsContentWidget(
                            controller: controller,
                            prototypeWord: controller.cardDetils.value.content,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
