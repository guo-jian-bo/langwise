import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../common/manage_sentence_add_widgets.dart';
import '../bindings/manage_sentence_grammar_add_group_binding.dart';
import '../controllers/manage_sentence_grammar_add_group_controller.dart';

class ManageSentenceGrammarAddGroupView extends GetView<ManageSentenceGrammarAddGroupController> {
  final String tagText;

  const ManageSentenceGrammarAddGroupView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> to<T>({dynamic arguments}) async {
    final String tag = '${Routes.MANAGE_SENTENCE_GRAMMAR_ADD_GROUP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentenceGrammarAddGroupView(tagText: tag),
      binding: ManageSentenceGrammarAddGroupBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_GRAMMAR_ADD_GROUP,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 90.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 32.wMin),
            ManageSentenceAddTitleWidget(),
            SizedBox(height: 32.wMin),
            ManageSentenceAddTableWidget(
              subTitle: "盘面是满配全部格，裁剪只在详情浏览。每格先看样句，亮的是这一格随轴变化的形态。",
              asset: controller.grammarDetail?.nid,
            ),
            SizedBox(height: 24.wMin),
            Container(
              width: double.infinity,
              height: 1.wMin,
              color: AppTheme.cBorderDefault.color,
            ),
            SizedBox(height: 24.wMin),
            Obx(() {
              final List<ManageSentenceAddBindingCardModel> cardList = controller.buildBindingCardList();
              return ManageSentenceAddBingListWidget(
                itemCount: cardList.length,
                itemBuilder: (int index) {
                  final ManageSentenceAddBindingCardModel model = cardList[index];
                  final String? cellKey = model.cellKey;
                  final cell = controller.cellList.firstWhereOrNull((item) => item.key == cellKey);
                  return ManageSentenceAddBingWidget(
                    index: index,
                    title: model.title,
                    centerWidget: ManageSentenceAddBingSentenceWidget(model: model),
                    bottomWidget: ManageSentenceAddExampleWidget(sentence: model.exampleSentence),
                    hasSentence: model.sentence != null,
                    pickSentence: () {
                      if (cell == null) return;
                      controller.pickSentence(context, cell);
                    },
                    inputUid: () {
                      if (cell == null) return;
                      controller.manualInputUid(context, cell);
                    },
                    clearSentence: () {
                      if (cellKey == null) return;
                      controller.boundSentenceMap.remove(cellKey);
                    },
                  );
                },
              );
            }),
            SizedBox(height: 200.wMin),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        return ManageSentenceAddButtonsWidget(
          bindCount: controller.bindCount,
          totalCount: controller.totalCount,
          addSentence: controller.addSentence,
          fullSentence: controller.fullSentence,
          isAddSentenceEnabled: controller.isAddSentenceEnabled,
          isFullSentenceEnabled: controller.isFullSentenceEnabled,
        );
      }),
    );
  }
}
