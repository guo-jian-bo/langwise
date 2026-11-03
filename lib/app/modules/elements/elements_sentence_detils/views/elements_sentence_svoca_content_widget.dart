import 'package:flutter/widgets.dart';

import '../../../../../common/entities/entities.dart';
import 'elements_sentence_chunk_content_widget.dart';
import 'elements_sentence_chunk_layout_helper.dart';

class ElementsSentenceSvocaContentWidget extends StatelessWidget {
  final EnSentenceStructureDetailEntity detils;

  const ElementsSentenceSvocaContentWidget({
    super.key,
    required this.detils,
  });

  @override
  Widget build(BuildContext context) {
    return ElementsSentenceChunkContentWidget(
      detils: detils,
      analysisMode: SentenceChunkAnalysisMode.svoca,
    );
  }
}
