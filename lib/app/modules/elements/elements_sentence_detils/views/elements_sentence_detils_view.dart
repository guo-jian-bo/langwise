import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/lock_utils.dart';
import '../controllers/elements_sentence_detils_controller.dart';
import 'elements_sentence_detils_content_widget.dart';

class ElementsSentenceDetilsView extends GetView<ElementsSentenceDetilsController> {
  final String tagText;
  const ElementsSentenceDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: LockOverlayWidget(
          rights: controller.sentencesDetils.value.rights,
          child: controller.isLoading.value
              ? Container()
              : Container(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.only(
                      top:  10.wMin + MediaQuery.of(context).padding.top,
                      left: 40.wMin,
                      right: 40.wMin,
                      bottom: 10.wMin + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      children: [
                        const BackWidget(title: "句子卡片", showBorder: true),
                        Expanded(
                          child: ElementsSentenceDetilsContentWidget(
                            controller: controller,
                            tagText: tagText,
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
