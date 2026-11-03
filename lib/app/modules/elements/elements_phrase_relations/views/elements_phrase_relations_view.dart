import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../../../zhenxie/zhenxie_phrase_contrast/views/zhenxie_phrase_contrast_card_widget.dart';
import '../../../zhenxie/zhenxie_phrase_match/views/zhenxie_phrase_match_card_widget.dart';
import '../../../zhenxie/zhenxie_phrase_pair/views/zhenxie_phrase_pair_card_widget.dart';
import '../bindings/elements_phrase_relations_binding.dart';
import '../controllers/elements_phrase_relations_controller.dart';

class ElementsPhraseRelationsView extends GetView<ElementsPhraseRelationsController> {
  final String tagText;

  const ElementsPhraseRelationsView({
    super.key,
    required this.tagText,
  });

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({
    dynamic arguments,
    required String tag,
  }) async {
    return Get.to<T>(
      () => ElementsPhraseRelationsView(tagText: tag),
      binding: ElementsPhraseRelationsBinding(tagText: tag),
      routeName: Routes.EN_PHRASE_RELATIONS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Obx(() {
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Column(
          children: [
            const BreadcrumbWidget(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  90.wMin,
                  0,
                  90.wMin,
                  24.wMin + bottomInset,
                ),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBody() {
    final List<CardPhraseRelationGroup> groups = controller.relationGroups();
    if (controller.isLoading.value && groups.isEmpty) {
      return const SizedBox.expand();
    }
    if (groups.isEmpty) {
      return _buildNotDataWidget();
    }
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 12.wMin, bottom: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(groups.length, (index) {
          final CardPhraseRelationGroup group = groups[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == groups.length - 1 ? 0 : 24.wMin),
            child: _buildGroupWidget(group),
          );
        }),
      ),
    );
  }

  Widget _buildGroupWidget(CardPhraseRelationGroup group) {
    final List<CardPhraseRelationItem> items =
        group.items?.whereType<CardPhraseRelationItem>().toList() ?? <CardPhraseRelationItem>[];
    final Color color = controller.resolveGroupColor(group);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12.wMin,
              height: 12.wMin,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10.wMin),
            Text(
              group.title ?? '',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.wMin),
        if (items.isEmpty)
          _buildEmptyGroupWidget()
        else
          Column(
            children: List.generate(items.length, (index) {
              final CardPhraseRelationItem item = items[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 16.wMin),
                child: _buildRelationCard(group, item),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildRelationCard(
    CardPhraseRelationGroup group,
    CardPhraseRelationItem item,
  ) {
    final String code = (group.code ?? '').trim();
    Widget child = const SizedBox.shrink();
    if (code == 'paradigm') {
      final PhraseParadigmEntity? data = controller.buildParadigmEntity(item);
      if (data != null) {
        child = ZhenxiePhraseContrastCardWidget(data: data, isManagement: false);
      }
    } else if (code == 'pair') {
      final PhrasePairEntity? data = controller.buildPairEntity(item);
      if (data != null) {
        child = ZhenxiePhrasePairCardWidget(data: data, isManagement: false);
      }
    } else if (code == 'cluster') {
      final PhraseMatchEntity? data = controller.buildMatchEntity(item);
      if (data != null) {
        child = ZhenxiePhraseMatchCardWidget(data: data, isManagement: false);
      }
    }
    if (child is SizedBox) {
      return _buildEmptyGroupWidget();
    }
    return TapScaleWidget(
      onTap: () => controller.openRelationItem(group, item),
      sclae: 1.01,
      child: child,
    );
  }

  Widget _buildEmptyGroupWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Text(
        '暂无关联内容',
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      ),
    );
  }

  Widget _buildNotDataWidget() {
    return Container(
      alignment: Alignment.center,
      child: NotDataWidget(
        other: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '还没有关联短语',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              '当前短语下暂时没有可展示的对照、配对或搭配组。',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
