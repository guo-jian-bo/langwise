import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../common/manage_sentence_add_widgets.dart';
import '../bindings/manage_sentence_pair_add_group_binding.dart';
import '../controllers/manage_sentence_pair_add_group_controller.dart';

class ManageSentencePairAddGroupView extends GetView<ManageSentencePairAddGroupController> {
  final String tagText;

  const ManageSentencePairAddGroupView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> to<T>({dynamic arguments}) async {
    final String tag = '${Routes.MANAGE_SENTENCE_PAIR_ADD_GROUP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentencePairAddGroupView(tagText: tag),
      binding: ManageSentencePairAddGroupBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_PAIR_ADD_GROUP,
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
            SizedBox(height: 24.wMin),
            Obx(() {
              final List<ManageSentenceAddBindingCardModel> cardList = controller.buildBindingCardList();

              return Column(
                spacing: 10.wMin,
                children: List.generate(cardList.length, (index){
                  final ManageSentenceAddBindingCardModel model = cardList[index];
                  final String cellKey = model.cellKey ?? 'from';
                  final bool isFromCell = cellKey == 'from';
                  final bool isPinnedFromCell = isFromCell && controller.fromPinned;
                  final bool canOperateCell = isFromCell ? !controller.fromPinned : controller.hasBoundFromSentence;
                  return ManageSentenceAddBingWidget(
                    index: index,
                    title: model.title,
                    centerWidget: ManageSentenceAddBingSentenceWidget(model: model),
                    bottomWidget: model.sentence != null ? null : ManageSentenceAddExampleWidget(sentence: model.exampleSentence),
                    hasSentence: model.sentence != null,
                    isClearSentenceEnabled: !isPinnedFromCell,
                    hasSentenceActionText: isPinnedFromCell ? '已选定' : '换一句',
                    isPickSentenceEnabled: canOperateCell,
                    isInputUidEnabled: canOperateCell,
                    pickSentence: () {
                      controller.pickSentence(context, cellKey);
                    },
                    inputUid: () {
                      controller.manualInputUid(context, cellKey);
                    },
                    clearSentence: () {
                      if (isPinnedFromCell) {
                        return;
                      }
                      controller.boundSentenceMap.remove(cellKey);
                    },
                  );
                }),
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
