import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/commons.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../models/zhenxie_composition_instances_models.dart';

class ZhenxieCompositionInstanceCardWidget extends StatelessWidget {
  static const double _cardHeight = 358;
  final bool isManagement;
  final CompositionInstanceModel instance;
  final ContentCardData contentData;
  final bool showCoverOverlay;
  final VoidCallback? onTap;
  final VoidCallback? onReviewImages;
  final VoidCallback? onCropCover;
  final VoidCallback? onEditCover;
  final VoidCallback? onToggleAccess;
  final Function()? onRefreshServiceData;

  const ZhenxieCompositionInstanceCardWidget({
    super.key,
    required this.instance,
    required this.contentData,
    required this.showCoverOverlay,
    this.onReviewImages,
    this.onCropCover,
    this.onEditCover,
    this.onToggleAccess,
    this.isManagement = false,
    this.onTap,
    this.onRefreshServiceData,
  });

  @override
  Widget build(BuildContext context) {
    bool isNormal = contentData.isNormal;
    return ZhenxieWriteCatalogCardWidget(
      contentData: contentData,
      height: _cardHeight,
      copyLabel: '范文',
      isManagement: isManagement,
      actions: !isManagement ? null : Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: (){},
                  child: ManageEnKnowledgeAudioListWidget(
                    audioList: instance.audioList,
                    contentType: KnowledgeTypeEnum.EN_COMPOSITION.value,
                    contentId: contentData.uid,
                    onRefreshServiceData: onRefreshServiceData,
                    isShowUploadBtn: true,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.wMin),
            ListingAndDelistingWidget(
              value: isNormal,
              onChange: onToggleAccess,
              showBorder: false,
            ),
          ],
        ),
      ),
      coverOverlay: showCoverOverlay ? _buildCoverOverlay() : null,
      onTap: onTap,
    );
  }

  Widget _buildCoverOverlay() {
    final ModuleImageInfoEntity? image = instance.imageReview?.image;
    final List<int> imageTaskIds = instance.imageReview?.imageTaskIds ?? <int>[];
    final List<Widget> metaTagList = <Widget>[
      if (image?.imageId != null) _buildCoverMetaTag('uid:${image!.imageId}'),
      _buildCoverMetaTag('范文封面'),
      if ((image?.styleTitle ?? '').isNotEmpty) _buildCoverMetaTag(image!.styleTitle!),
      if ((image?.localeTitle ?? '').isNotEmpty) _buildCoverMetaTag(image!.localeTitle!),
    ];

    return Stack(
      children: [
        Positioned(
          left: 8.wMin,
          top: 8.wMin,
          child: SizedBox(
            width: 104.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: metaTagList,
            ),
          ),
        ),
        Positioned(
          top: 8.wMin,
          right: 8.wMin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (image?.imageId != null)
                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.adminContentReviewImageCrop],
                      child: _buildCoverIconTag(
                        icon: Icons.crop,
                        onTap: onCropCover ?? () => ToastUtils.showManageToast(text: '当前范文暂无可裁剪封面'),
                      ),
                    ),
                  if (image?.imageId != null) SizedBox(width: 4.wMin),
                  if (image?.imageId != null)
                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.contentReviewImageCreateInfo],
                      child: _buildCoverIconTag(
                        icon: Icons.edit_outlined,
                        onTap: onEditCover ?? () => ToastUtils.showManageToast(text: '范文封面编辑待接入'),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.wMin),
              _buildCoverTextButtonTag(
                imageTaskIds.isEmpty ? '无待审核' : '待审核',
                onTap: onReviewImages ?? () => ToastUtils.showManageToast(text: '当前暂无待审核图片'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverMetaTag(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.wMin),
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
      decoration: _buildCoverTagDecoration(),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildCoverIconTag({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.0,
      child: Container(
        padding: EdgeInsets.all(6.wMin),
        decoration: _buildCoverTagDecoration(),
        child: Icon(
          icon,
          size: 12.wMin,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }

  Widget _buildCoverTextButtonTag(
    String text, {
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
        decoration: _buildCoverTagDecoration(),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCoverTagDecoration() {
    return BoxDecoration(
      color: Colors.black.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(6.wMin),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15),
        width: 1.wMin,
      ),
    );
  }
}
