import 'package:get/get.dart';

import '../../../../common/enum/elements_card_type.dart';
import '../../../../common/widgets/audio_control_widget.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../elements_morpheme_detils/bindings/elements_morpheme_detils_binding.dart';
import '../elements_morpheme_detils/views/elements_morpheme_detils_view.dart';
import '../elements_phrase_detils/bindings/elements_phrase_detils_binding.dart';
import '../elements_phrase_detils/views/elements_phrase_detils_view.dart';
import '../elements_sentence_detils/bindings/elements_sentence_detils_binding.dart';
import '../elements_sentence_detils/views/elements_sentence_detils_view.dart';
import '../elements_word_detils/bindings/elements_word_detils_binding.dart';
import '../elements_word_detils/views/elements_word_detils_view.dart';

class ElementsPageUtils{

  /// 跳转元素详情页
  /// 
  /// [contentId] 元素id
  /// [contentType] 元素类型
  /// [semanticIds] 元素关联的语义id列表
  /// [content] 元素内容
  /// [pos] 元素词性
  /// [songParam] 歌曲参数 [{"contentId": 123, "contentType": "EN_SONG"}]
  static Future<void> jumpElementsPage({
    required int? contentId,
    String? contentType,
    List<int?>? semanticIds,
    String? content,
    String? pos,
    List<Map<String, dynamic>>? contents,
    AudioControlPlayOrder? listenAndReadPlayOrder,
    PlayRecordPageType? type,
    int? typeId,
  }) async{
    if(contentId == null || contentType == null) return;

      ElementsCardType knowledgeType = ElementsCardType.fromRawValue(contentType);
      switch (knowledgeType) {
        case ElementsCardType.word:
          await Get.to(
            ElementsWordDetilsView(tagText: contentId.toString()),
            preventDuplicates: false,
            binding: ElementsWordDetilsBinding(tagText: contentId.toString()),
            arguments: {
              "contentId": contentId,
              "semanticIds": semanticIds,
            },
          );

          break;
        case ElementsCardType.phrase:
          await Get.to(
            ElementsPhraseDetilsView(tagText: contentId.toString()),
            preventDuplicates: false,
            binding: ElementsPhraseDetilsBinding(tagText: contentId.toString()),
            arguments: {
              "contentId": contentId,
              "semanticIds": semanticIds,
            },
          );
          break;
        case ElementsCardType.sentence:
          await Get.to(
            ElementsSentenceDetilsView(tagText: contentId.toString()),
            preventDuplicates: false,
            binding: ElementsSentenceDetilsBinding(tagText: contentId.toString()),
            arguments: {
              "contentId": contentId,
              "semanticIds": semanticIds,
            },
          );
          break;
        case ElementsCardType.morpheme:
          if(content == null || pos == null) return;
          await Get.to(
            ElementsMorphemeDetilsView(tagText: "$content+$pos"),
            preventDuplicates: false,
            binding: ElementsMorphemeDetilsBinding(tagText: "$content+$pos"),
            arguments: {
              "content": content,
              "pos": pos,
            },
          );
          break;
        case ElementsCardType.text:
        case ElementsCardType.reveal:
          if(contents == null || contents.isEmpty) return;
          Get.toNamed(
            Routes.LISTEN_AND_READ,
            arguments: {
              "contentId": contentId,
              "contentType": contentType,
              "contents": contents,
              "playbackMode": listenAndReadPlayOrder?.key,
              "type": type?.value,
              "typeId": typeId,
            },
          );

          break;
        case ElementsCardType.song:
          if(contents == null || contents.isEmpty) return;

          JumpPageUtils.jumpSongMv(
            contents: contents, 
            contentId: contentId, 
            contentType: contentType,
            type: type,
            typeId: typeId,
          );
          break;
        default:
          break;
      }
  }

}
