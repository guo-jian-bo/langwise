import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';

class ElementsCardMediaWidget extends StatelessWidget {
  final ElementsCardEntityDatas? data;
  final Widget? fallbackChild;
  final bool disableImagePreview;

  const ElementsCardMediaWidget({
    super.key,
    this.data,
    this.fallbackChild,
    this.disableImagePreview = false,
  });

  ConfigController get _configController => Get.find<ConfigController>();

  bool get _hasPlayableVideo => data?.video?.videoUrl?.trim().isNotEmpty ?? false;

  String get _coverUrl {
    final bool useVideoCover = _configController.currentShowResource.value == ResourceTypeEnum.video && _hasPlayableVideo;
    final String firstFrameUrl = data?.video?.firstFrameUrl?.trim() ?? "";
    if (useVideoCover && firstFrameUrl.isNotEmpty) return firstFrameUrl;
    return data?.imageUrl?.trim() ?? firstFrameUrl;
  }

  Future<void> _showImageDialog(BuildContext context, String imageUrl) async {
    if (imageUrl.trim().isEmpty) return;
    await ShowBigResourceDialog.showImage(
      context: context,
      imageUrls: [imageUrl],
    );
  }

  Future<void> _showVideoDialog(BuildContext context) async {
    if (!_hasPlayableVideo) return;
    await ShowBigResourceDialog.showVideo(
      context: context,
      relationVideo: EnKnowledgeEntityRelationVideo(
        uid: data?.video?.videoId,
        videoId: data?.video?.videoId,
        type: data?.contentType,
        contentId: data?.contentId,
        semanticId: data?.semanticId,
        videoUrl: data?.video?.videoUrl,
        videoKey: data?.video?.videoKey,
        duration: data?.video?.duration,
        startSeconds: data?.video?.startSeconds,
        endSeconds: data?.video?.endSeconds,
        firstImageUrl: data?.video?.firstFrameUrl,
        firstFrameUrl: data?.video?.firstFrameUrl,
        firstFrameKey: data?.video?.firstFrameKey,
        firstFrameMd5: data?.video?.firstFrameMd5,
        ass: data?.video?.ass,
        translateAss: data?.video?.translateAss,
        translate: data?.video?.translateAss,
        isMute: data?.video?.isMute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String imageUrl = _coverUrl;
      final bool showVideo = _configController.currentShowResource.value == ResourceTypeEnum.video && _hasPlayableVideo;
      final Widget baseMedia = imageUrl.isNotEmpty
          ? CachedImageWidget(
              imageUrl,
              errorWidget: buildEmptyWidget(),
              placeholder: buildLoadingWidget(),
              fadeInDuration: Duration.zero,
            )
          : (fallbackChild != null
              ? Center(child: fallbackChild!)
              : buildEmptyWidget());

      if (showVideo) {
        return TapScaleWidget(
          onTap: () async {
            await _showVideoDialog(context);
          },
          sclae: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              baseMedia,
              Center(
                child: ClipOval(
                  child: Container(
                    width: 80.wMin,
                    height: 80.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cInverseTextLight.withValues(alpha: 0.03),
                      border: Border.all(
                        color: AppTheme.cInverseTextLight.withValues(alpha: 0.4),
                        width: 1.wMin,
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: AppTheme.cInverseTextLight,
                      size: 50.wMin,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (imageUrl.isNotEmpty) {
        if (disableImagePreview) {
          return baseMedia;
        }
        return TapScaleWidget(
          onTap: () async {
            await _showImageDialog(context, imageUrl);
          },
          sclae: 1,
          child: baseMedia,
        );
      }

      return baseMedia;
    });
  }
}
