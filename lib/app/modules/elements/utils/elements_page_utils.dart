
import 'package:video_player/video_player.dart';

import '../../../../common/enum/enum.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../../../routes/tag_routes.dart';

class ElementsPageUtils{

  /// 跳转元素详情页
  /// 
  /// 以下是用作播放列表内的唯一标识 在播放页面用+号链接起来
  /// [contentId] 元素id
  /// [contentType] 元素类型
  /// [semanticId] 语义ID
  /// [styleId] 风格ID
  /// [dialect] 方言
  /// [semanticIds] 元素关联的语义id列表
  /// [content] 元素内容
  /// [pos] 元素词性
  /// [songParam] 歌曲参数 [{"contentId": 123, "contentType": "EN_SONG", "styleId": 123, "dialect": "en-US"}]
  /// [traceAdminHeader] 如果是管理员传入UUID
  static Future<void> jumpElementsPage({
    required int? contentId,
    required String? contentType,
    required int? semanticId,
    required int? styleId,
    required String? dialect,

    List<int?>? semanticIds,
    String? content,
    String? pos,
    List<Map<String, dynamic>>? contents,
    PlayerModeEnum? listenAndReadPlayOrder,
    PlayRecordPageType? type,
    int? typeId,
    String? traceAdminHeader,
  }) async{
    if(contentId == null || contentType == null) return;

      ElementsCardType knowledgeType = ElementsCardType.fromRawValue(contentType);
      switch (knowledgeType) {
        case ElementsCardType.word:
          await TagRoutes.toNamed(
            Routes.EN_WORD_DETAIL,
            arguments: {
              "contentId": contentId,
              "semanticId": semanticId,
              "semanticIds": semanticIds,
            },
          );
          // await Get.to(
          //   ElementsWordDetilsView(tagText: contentId.toString()),
          //   preventDuplicates: false,
          //   binding: ElementsWordDetilsBinding(tagText: contentId.toString()),
          //   arguments: {
          //     "contentId": contentId,
          //     "semanticIds": semanticIds,
          //   },
          // );

          break;
        case ElementsCardType.phrase:
          await TagRoutes.toNamed(
            Routes.EN_PHRASE_DETAIL,
            arguments: {
              "contentId": contentId,
              "semanticIds": semanticIds,
            },
          );
          break;
        case ElementsCardType.sentence:
          await TagRoutes.toNamed(
            Routes.EN_SENTENCE_DETAIL,
            arguments: {
              "contentId": contentId,
              "semanticIds": semanticIds,
            },
          );
          break;
        case ElementsCardType.morpheme:
          if(content == null || pos == null) return;
          await TagRoutes.toNamed(
            Routes.EN_MORPHEME_DETAIL,
            arguments: {
              "content": content,
              "pos": pos,
            },
          );
          break;
        case ElementsCardType.text:
        case ElementsCardType.reveal:
          if(contents == null || contents.isEmpty) return;
          await TagRoutes.toNamed(
            Routes.LISTEN_AND_READ,
            arguments: {
              "contentId": contentId,
              "contentType": contentType,
              "semanticId": semanticId,
              "styleId": styleId,
              "dialect": dialect,
              "contents": contents,
              "playbackMode": listenAndReadPlayOrder?.value,
              "type": type?.value,
              "typeId": typeId,
              "traceAdminHeader": traceAdminHeader,
            },
          );

          break;
        case ElementsCardType.song:
          if(contents == null || contents.isEmpty) return;

          JumpPageUtils.jumpSongMv(
            contents: contents, 
            contentId: contentId, 
            contentType: contentType,
            semanticId: semanticId,
            styleId: styleId,
            dialect: dialect,
            type: type,
            typeId: typeId,
            traceAdminHeader: traceAdminHeader,
          );
          break;
        default:
          break;
      }
  }

}
