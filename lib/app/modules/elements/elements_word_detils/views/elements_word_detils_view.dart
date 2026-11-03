import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../utils/lock_utils.dart';
import '../../elements_detils/controllers/elements_detils_controller.dart';
import '../controllers/elements_word_detils_controller.dart';
import 'elements_word_detils_content_widget.dart';

class ElementsWordDetilsView extends GetView<ElementsWordDetilsController> {
  final String tagText;
  const ElementsWordDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: controller.isLoading.value
            ? Container()
            : LockOverlayWidget(
                rights: controller.cardDetils.value.rights,
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 10.wMin + MediaQuery.of(context).padding.top,
                      left: 40.wMin,
                      right: 40.wMin,
                      bottom: 10.wMin + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      children: [
                        const BackWidget(
                          title: "单词卡片",
                          showBorder: true,
                        ),
                        Expanded(
                          child: ElementsWordDetilsContentWidget(
                            controller: controller,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
      );
    });
  }
}
