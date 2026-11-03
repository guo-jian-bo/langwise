import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../controllers/elements_sentence_analysis_controller.dart';

class ElementsSentenceRelationsContentWidget extends StatelessWidget {
  final ElementsSentenceAnalysisController controller;
  const ElementsSentenceRelationsContentWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<CourseUnitTargetSentenceGrammarGroupEntity> list = controller.relationList.toList();
      if (controller.isRelationsLoading.value && list.isEmpty) {
        return Center(
          
        );
      }
      return SentenceGrammarGroupListWidget(
        list: list,
        controller: controller.relationsScrollController,
        emptyMessage: '当前句子暂无关联',
        padding: EdgeInsets.only(top: 16.wMin, bottom: 120.wMin),
      );
    });
  }
}
