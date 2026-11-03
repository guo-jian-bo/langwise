import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/custom_button/LWCircularButton.dart';
import 'package:langwise/common/widgets/platform_backdrop_filter_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../bindings/elements_sentence_analysis_binding.dart';
import '../controllers/elements_sentence_analysis_controller.dart';
import 'elements_sentence_chunk_content_widget.dart';
import 'elements_sentence_relations_content_widget.dart';
import 'elements_sentence_svoca_content_widget.dart';
import 'elements_sentence_syntax_content_widget.dart';

class ElementsSentenceAnalysisView extends GetView<ElementsSentenceAnalysisController> {
  final String tagText;
  const ElementsSentenceAnalysisView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => ElementsSentenceAnalysisView(tagText: tag),
      binding: ElementsSentenceAnalysisBinding(tagText: tag),
      routeName: Routes.EN_SENTENCE_ANALYSIS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final EnSentenceStructureDetailEntity detils = controller.sentenceDetils.value;
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Column(
          children: [
            const BreadcrumbWidget(),
            Expanded(
              child: controller.isLoading.value
                  ? const SizedBox.expand()
                  : Padding(
                      padding: EdgeInsets.fromLTRB(
                        90.wMin,
                        0.wMin,
                        90.wMin,
                        12.wMin ,
                      ),
                      child: _buildContentCard(detils),
                    ),
            ),
          ],
        ),
        floatingActionButton: _buildLayerBar(detils.analysisEntries),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  Widget _buildContentCard(EnSentenceStructureDetailEntity detils) {
    return IndexedStack(
      index: _currentLayerIndex(),
      children: [
        _buildChunksContentWidget(detils),
        _buildSvocaContentWidget(detils),
        _buildSyntaxContentWidget(detils),
        _buildRelationsContentWidget(),
      ],
    );
  }

  Widget _buildChunksContentWidget(EnSentenceStructureDetailEntity detils) {
    return ElementsSentenceChunkContentWidget(detils: detils);
  }

  Widget _buildSvocaContentWidget(EnSentenceStructureDetailEntity detils) {
    return ElementsSentenceSvocaContentWidget(detils: detils);
  }

  Widget _buildSyntaxContentWidget(EnSentenceStructureDetailEntity detils) {
    return ElementsSentenceSyntaxContentWidget(detils: detils);
  }

  Widget _buildRelationsContentWidget() {
    return ElementsSentenceRelationsContentWidget(controller: controller);
  }

  Widget _buildLayerBar(List<EnSentenceStructureAnalysisEntry?>? entries) {
    final List<EnSentenceStructureAnalysisEntry> data = _buildLayerEntryList(entries);
    if (data.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: PlatformBackdropFilterWidget(
        sigmaX: 4.wMin,
        sigmaY: 4.wMin,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          height: 80.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.cSurfaceSearchBackground.color,
            border: Border.all(
              color: AppTheme.cBorderDark.color,
              width: 1.wMin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(data.length, (index) {
              return Padding(
                padding: EdgeInsets.only(right: index == data.length - 1 ? 0 : 12.wMin),
                child: _buildLayerItem(data[index]),
              );
            }),
          ),
        ),
      ),
    );
  }

  List<EnSentenceStructureAnalysisEntry> _buildLayerEntryList(
    List<EnSentenceStructureAnalysisEntry?>? entries,
  ) {
    return (entries ?? <EnSentenceStructureAnalysisEntry?>[])
        .whereType<EnSentenceStructureAnalysisEntry>()
        .toList()
      ..sort((a, b) => (a.index ?? 99).compareTo(b.index ?? 99));
  }

  Widget _buildLayerItem(EnSentenceStructureAnalysisEntry entry) {
    final bool isCurrent = entry.type == controller.analysisLayer.value;
    final Color primaryColor = ColorUtils.parseColor(entry.color?.to) ?? AppTheme.cBgBrand;
    final String title = _languageTextZh(entry.title);
    return LWCircularButtonWidget(
      text: title,
      isAction: isCurrent,
      color: primaryColor,
      onTap: () {
        controller.changeAnalysisLayer(entry.type ?? controller.analysisLayer.value);
      },
    );
  }

  int _currentLayerIndex() {
    final String layer = controller.analysisLayer.value;
    if (layer == 'svoca') return 1;
    if (layer == 'syntax') return 2;
    if (layer == 'relations') return 3;
    return 0;
  }

  String _languageTextZh(List<LanguageText?>? texts) {
    for (final LanguageText? item in texts ?? <LanguageText?>[]) {
      if ((item?.lang ?? '').toLowerCase() == StaticData.zh && (item?.text ?? '').isNotEmpty) {
        return item!.text!;
      }
    }
    for (final LanguageText? item in texts ?? <LanguageText?>[]) {
      if ((item?.text ?? '').isNotEmpty) {
        return item!.text!;
      }
    }
    return '';
  }
}
