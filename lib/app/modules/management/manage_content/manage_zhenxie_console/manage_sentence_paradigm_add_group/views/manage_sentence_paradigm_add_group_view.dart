import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../common/manage_sentence_add_widgets.dart';
import '../bindings/manage_sentence_paradigm_add_group_binding.dart';
import '../controllers/manage_sentence_paradigm_add_group_controller.dart';

class ManageSentenceParadigmAddGroupView extends GetView<ManageSentenceParadigmAddGroupController> {
  final String tagText;

  const ManageSentenceParadigmAddGroupView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> to<T>({dynamic arguments}) async {
    final String tag = '${Routes.MANAGE_SENTENCE_PARADIGM_ADD_GROUP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentenceParadigmAddGroupView(tagText: tag),
      binding: ManageSentenceParadigmAddGroupBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_PARADIGM_ADD_GROUP,
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
              subTitle: "对照表已经印好。每格先看样句：亮的是对照位。按这个样子挑。",
              asset: controller.detailData?.nid,
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
                  return ManageSentenceAddBingWidget(
                    index: index,
                    title: model.title,
                    centerWidget:  ManageSentenceAddBingSentenceWidget(model: model),
                    bottomWidget: model.sentence != null ? null : ManageSentenceAddExampleWidget(
                      sentence: model.exampleSentence,
                      contrastFocus: model.contrastFocus,
                        foci: model.foci,
                    ),
                    hasSentence: model.sentence != null,
                    pickSentence: () {
                      controller.pickSentence(context, index);
                    },
                    inputUid: () {
                      controller.manualInputUid(context, index);
                    },
                    clearSentence: () {
                      controller.boundSentenceMap.remove(index);
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
