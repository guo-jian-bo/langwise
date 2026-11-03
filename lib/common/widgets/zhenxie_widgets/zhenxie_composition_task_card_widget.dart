import 'package:flutter/material.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_composition_slot_strip_widget.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/common/entities/entities.dart';

import '../../../app/modules/zhenxie/zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';
import '../../../app/modules/zhenxie/zhenxie_composition_writing/models/zhenxie_composition_writing_models.dart';

class ZhenxieCompositionTaskCardWidget extends StatelessWidget {
  static const double _cardHeight = 398;

  final CompositionTaskModel task;
  final CompositionGenreModel? genre;
  final Map<String, ParagraphRhetoricalEntityList> beatMap;
  final List<String> beatOrderList;
  final String difficultyLabel;
  final String coverUrl;
  final Color genreColor;
  final VoidCallback? onTap;
  final String Function(List<LanguageText>? values, String lang) langTextGetter;
  final String Function(String? beatNid) beatNameGetter;
  final String Function(CompositionStageModel stage) headLabelGetter;
  final String Function(CompositionStageModel stage) tailLabelGetter;
  final bool Function(CompositionStageModel stage) hasHeadGetter;
  final bool Function(CompositionStageModel stage) hasTailGetter;

  const ZhenxieCompositionTaskCardWidget({
    super.key,
    required this.task,
    required this.genre,
    required this.beatMap,
    required this.beatOrderList,
    required this.difficultyLabel,
    required this.coverUrl,
    required this.genreColor,
    required this.langTextGetter,
    required this.beatNameGetter,
    required this.headLabelGetter,
    required this.tailLabelGetter,
    required this.hasHeadGetter,
    required this.hasTailGetter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final CompositionStageModel? stage = task.stage;
    final String blueprintTitle = langTextGetter(task.blueprint?.name, 'zh');
    final String title = langTextGetter(task.name, 'zh');
    final String titleEn = langTextGetter(task.name, 'en');
    final String description = langTextGetter(task.stem, 'zh');
    final String genreLabel = langTextGetter(genre?.name, 'zh');

    return ZhenxieWriteCatalogCardWidget(
      height: _cardHeight,
      coverUrl: coverUrl,
      difficultyLabel: difficultyLabel,
      blueprintLabel: blueprintTitle,
      title: title,
      titleEn: titleEn,
      entityLabel: '任务',
      entityValue: task.uid?.toString() ?? '',
      genreLabel: genreLabel,
      genreColor: genreColor,
      description: description,
      slotStrip: stage == null
          ? const SizedBox.shrink()
          : ZhenxieCompositionSlotStripWidget(
              stage: stage,
              beatMap: beatMap,
              beatOrderList: beatOrderList,
              langTextGetter: langTextGetter,
              beatNameGetter: beatNameGetter,
              headLabelGetter: headLabelGetter,
              tailLabelGetter: tailLabelGetter,
              hasHeadGetter: hasHeadGetter,
              hasTailGetter: hasTailGetter,
            ),
      onTap: onTap,
    );
  }
}
