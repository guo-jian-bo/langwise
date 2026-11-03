import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../common/manage_sentence_add_widgets.dart';
import '../bindings/manage_sentence_fork_add_group_binding.dart';
import '../controllers/manage_sentence_fork_add_group_controller.dart';

class ManageSentenceForkAddGroupView extends GetView<ManageSentenceForkAddGroupController> {
  final String tagText;

  const ManageSentenceForkAddGroupView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> to<T>({dynamic arguments}) async {
    final String tag = '${Routes.MANAGE_SENTENCE_FORK_ADD_GROUP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentenceForkAddGroupView(tagText: tag),
      binding: ManageSentenceForkAddGroupBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_FORK_ADD_GROUP,
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
            ManageSentenceAddTitleWidget(
              desc: controller.fromPinned ? "左边已经钉好上一句。右边每路挑一句，没有就留空再补。" : "先钉左边的上一句。右边每路可以挑，也可以留空再补。",
            ),
            SizedBox(height: 24.wMin),
            Obx(() {
              final List<ManageSentenceAddBindingCardModel> cardList = controller.buildBindingCardList();
              return _buildBindingLayout(context, cardList);
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

  /// 分叉页采用左 from、右多分支的双列布局，更贴近 Web 端结构。
  Widget _buildBindingLayout(BuildContext context, List<ManageSentenceAddBindingCardModel> cardList) {
    final ManageSentenceAddBindingCardModel? fromModel = cardList.firstWhereOrNull((item) => item.cellKey == 'from');
    final List<ManageSentenceAddBindingCardModel> toCardList =
        cardList.where((item) => item.cellKey != 'from').toList();
    if (fromModel == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useColumnLayout = constraints.maxWidth < 1200.wMin;
        if (useColumnLayout) {
          return Column(
            spacing: 10.wMin,
            children: <Widget>[
              _buildForkLegContainer(
                child: _buildForkLeg(context, fromModel),
              ),
              ...toCardList.map(
                (item) => _buildForkLegContainer(
                  child: _buildForkLeg(context, item),
                ),
              ),
            ],
          );
        }

        return IntrinsicHeight(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cZhenxieBackgroundPrimary.color,
              border: Border.all(
                color: AppTheme.cZhenxieBorderPrimary.color,
                width: 1.wMin,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 20.wMin),
                    child: Center(
                      child: _buildForkLeg(context, fromModel),
                    ),
                  ),
                ),
                Container(
                  width: 1.wMin,
                  color: AppTheme.cZhenxieBorderPrimary.color,
                ),
                Expanded(
                  child: Column(
                    children: List<Widget>.generate(toCardList.length, (index) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 18.wMin),
                        decoration: BoxDecoration(
                          border: index == 0
                              ? null
                              : Border(
                                  top: BorderSide(
                                    color: AppTheme.cZhenxieBorderPrimary.color,
                                    width: 1.wMin,
                                  ),
                                ),
                        ),
                        child: _buildForkLeg(context, toCardList[index]),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 小屏时单独包一层容器，保持 fork 分支卡片的纸片感。
  Widget _buildForkLegContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 18.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: child,
    );
  }

  /// 单个 fork 格位的专用布局：上面显示当前句或样句，下面显示动作区。
  Widget _buildForkLeg(BuildContext context, ManageSentenceAddBindingCardModel model) {
    final String cellKey = model.cellKey ?? 'from';
    final String? valueNid = model.valueNid;
    final String storageKey = cellKey == 'from' ? 'from' : 'to:${valueNid ?? ''}';
    final bool isFromCell = cellKey == 'from';
    final bool isPinnedFromCell = isFromCell && controller.fromPinned;
    final bool canOperateCell = isFromCell ? !controller.fromPinned : controller.hasBoundFromSentence;
    final bool hasSentence = model.sentence != null;
    final bool hasExample = model.exampleSentence?.content?.isNotEmpty == true || model.exampleSentence?.definition?.isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          model.title,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 12.wMin),
        if (hasSentence)
          ManageSentenceAddBingSentenceWidget(
            model: model,
            alignment: Alignment.centerLeft,
          )
        else if (hasExample)
          ManageSentenceAddExampleWidget(sentence: model.exampleSentence)
        else
          Text(
            model.title,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        SizedBox(height: 12.wMin),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12.wMin,
          runSpacing: 8.wMin,
          children: <Widget>[
            if (hasSentence)
              isPinnedFromCell
                  ? Text(
                      '已选定',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : ButtonWidget(
                      text: "换一句",
                      height: 48.wMin,
                      width: 110.wMin,
                      color: AppTheme.cSurfaceLayerBase.color,
                      border: Border.all(
                        width: 0.8.wMin,
                        color: AppTheme.cBorderSubtle.color,
                      ),
                      fontSize: 20.wMin,
                      fontColor: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w500,
                      sclae: 1.03,
                      onTap: () {
                        controller.boundSentenceMap.remove(storageKey);
                      },
                    )
            else ...<Widget>[
              ButtonWidget(
                text: "挑一句",
                height: 48.wMin,
                width: 110.wMin,
                color: AppTheme.cSurfaceLayerBase.color,
                border: Border.all(
                  width: 0.8.wMin,
                  color: AppTheme.cBorderSubtle.color,
                ),
                fontSize: 20.wMin,
                fontColor: AppTheme.cTextSecondary.color.withValues(alpha: canOperateCell ? 1 : 0.45),
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  if (!canOperateCell) {
                    return;
                  }
                  controller.pickSentence(context, cellKey: cellKey, valueNid: valueNid);
                },
              ),
              ButtonWidget(
                text: "手输uid",
                height: 48.wMin,
                width: 110.wMin,
                color: AppTheme.cSurfaceLayerBase.color,
                border: Border.all(
                  width: 0.8.wMin,
                  color: AppTheme.cBorderSubtle.color,
                ),
                fontSize: 20.wMin,
                fontColor: AppTheme.cTextSecondary.color.withValues(alpha: canOperateCell ? 1 : 0.45),
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  if (!canOperateCell) {
                    return;
                  }
                  controller.manualInputUid(context, cellKey: cellKey, valueNid: valueNid);
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
