

import '../../../app/routes/routes.dart';
import '../../../app/routes/tag_routes.dart';
import '../../../utils/play_record_utils/play_record_utils.dart';
import '../../../utils/utils.dart';
import '../../enum/enum.dart';


class PlayerJumpPageUtils{
  
  /// * 跳转到对应的播放器页面
  /// * [pageType] 播放器页面类型
  /// 以下是用作播放列表内的唯一标识 在播放页面用+号链接起来
  /// * [contentId] 内容ID
  /// * [semanticId] 语义ID
  /// * [styleId] 风格ID
  /// * [dialect] 方言
  /// * [contentType] 内容类型
  /// 
  /// * [contents] 内容列表 [{"contentId": 123, "contentType": "EN_SONG", "styleId": 123, "dialect": "en-US"}]
  /// * [type] 播放记录页面类型
  /// * [typeId] 播放记录页面类型ID
  static Future<T?>? jumpToPage<T>({
    required ZhenduPageTypeEnum? pageType,
    required int? contentId,
    required String? contentType,
    required int? semanticId,
    required int? styleId,
    required String? dialect,
    required List<Map<String, dynamic>>? contents,
    PlayRecordPageType? type,
    int? typeId,
    int? collectionId,
    int? difficulty,
    String? locate,
    String? traceAdminHeader,
  }) async {
    
    if(pageType == null || contentId == null || contentType == null || contents == null || contents.isEmpty) return null;
    switch (pageType) {
      case ZhenduPageTypeEnum.listen:
        await JumpPageUtils.jumpSongMv(
          contents: contents, 
          contentId: contentId, 
          semanticId: semanticId,
          styleId: styleId,
          dialect: dialect,
          contentType: contentType,
          type: type,
          typeId: typeId,
          isReplaceRoute: true,
          traceAdminHeader: traceAdminHeader,
        );
        return null;
      case ZhenduPageTypeEnum.read:
        return await TagRoutes.offAndToNamed(
          Routes.LISTEN_AND_READ,
          arguments: {
            "contentId": contentId,
            "contentType": contentType,
            "semanticId": semanticId,
            "styleId": styleId,
            "dialect": dialect,
            "contents": contents,
            "type": type?.value,
            "typeId": typeId,
            "traceAdminHeader": traceAdminHeader,
          },
        );
      case ZhenduPageTypeEnum.watch:
        return await TagRoutes.offAndToNamed(
          Routes.ZHENDU_LOOK,
          arguments: {
            "contentId": contentId,
            "contentType": contentType,
            "semanticId": semanticId,
            "styleId": styleId,
            "dialect": dialect,
            "contents": contents,
            "type": type?.value,
            "typeId": typeId,
            "traceAdminHeader": traceAdminHeader,
          },
        );
      case ZhenduPageTypeEnum.perform:
        return await TagRoutes.offAndToNamed(
          Routes.ZHENDU_PERFORM,
          arguments: {
            "contentId": contentId,
            "contentType": contentType,
            "semanticId": semanticId,
            "styleId": styleId,
            "dialect": dialect,
            "contents": contents,
            "type": type?.value,
            "typeId": typeId,
            "traceAdminHeader": traceAdminHeader,
          },
        );
      case ZhenduPageTypeEnum.practice:
        return await TagRoutes.offAndToNamed(
          Routes.ZHENDU_PRACTICE,
          arguments: {
            "contentId": contentId,
            "contentType": contentType,
            "semanticId": semanticId,
            "styleId": styleId,
            "dialect": dialect,
            "contents": contents,
            "type": type?.value,
            "typeId": typeId,
            "traceAdminHeader": traceAdminHeader,
          },
        );
      }

  }

  /// * 跳转到对应的播放器页面
  /// * [pageType] 播放器页面类型
  /// 以下是用作播放列表内的唯一标识 在播放页面用+号链接起来
  /// * [contentId] 内容ID
  /// * [semanticId] 语义ID
  /// * [styleId] 风格ID
  /// * [dialect] 方言
  /// * [contentType] 内容类型
  /// * [contents] 内容列表 [{"contentId": 123, "contentType": "EN_SONG", "styleId": 123, "dialect": "en-US"}]
  /// * [type] 播放记录页面类型
  /// * [typeId] 播放记录页面类型ID
  static Future<T?>? jumpZhenduDetail<T>({
    required ZhenduPageTypeEnum? pageType,
    required int? contentId,
    required String? contentType,
    required int? semanticId,
    required int? styleId,
    required String? dialect,
    List<Map<String, dynamic>>? contents,
    PlayRecordPageType? type,
    int? typeId,
    int? collectionId,
    int? difficulty,
    String? locate,
    String? traceAdminHeader,
  }) async
  {
    
    if(pageType == null || contentId == null || contentType == null) return null;
    switch (pageType) {
      case ZhenduPageTypeEnum.listen:
        await JumpPageUtils.jumpSongMv(
          contents: contents, 
          contentId: contentId, 
          semanticId: semanticId,
          styleId: styleId,
          dialect: dialect,
          contentType: contentType,
          type: type,
          typeId: typeId,
          isReplaceRoute: false,
          traceAdminHeader: traceAdminHeader,
        );
        return null;
      case ZhenduPageTypeEnum.read:
        return await TagRoutes.toNamed(
          Routes.LISTEN_AND_READ,
          arguments: {
            "contentId": contentId,
            "contentType": contentType,
            "semanticId": semanticId,
            "styleId": styleId,
            "dialect": dialect,
            "contents": contents,
            "type": type?.value,
            "typeId": typeId,
            "traceAdminHeader": traceAdminHeader,
          },
        );
      case ZhenduPageTypeEnum.watch:
        return await TagRoutes.toNamed(
          Routes.ZHENDU_LOOK,
          arguments: {
            "contentId": contentId,
            "contentType": contentType,
            "semanticId": semanticId,
            "styleId": styleId,
            "dialect": dialect,
            "contents": contents,
            "type": type?.value,
            "typeId": typeId,
            "traceAdminHeader": traceAdminHeader,
          },
        );
      case ZhenduPageTypeEnum.perform:
        return await TagRoutes.toNamed(
          Routes.ZHENDU_PERFORM,
          arguments: {
            "contentId": contentId,
            "contentType": contentType,
            "semanticId": semanticId,
            "styleId": styleId,
            "dialect": dialect,
            "contents": contents,
            "type": type?.value,
            "typeId": typeId,
            "traceAdminHeader": traceAdminHeader,
          },
        );
      case ZhenduPageTypeEnum.practice:
        return await TagRoutes.toNamed(
          Routes.ZHENDU_PRACTICE,
          arguments: {
            "contentId": contentId,
            "contentType": contentType,
            "semanticId": semanticId,
            "styleId": styleId,
            "dialect": dialect,
            "contents": contents,
            "type": type?.value,
            "typeId": typeId,
            "traceAdminHeader": traceAdminHeader,
          },
        );
      }

  }


}
