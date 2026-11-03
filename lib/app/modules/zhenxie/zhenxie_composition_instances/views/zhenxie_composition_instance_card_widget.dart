import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/commons.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_composition_slot_strip_widget.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';
import '../models/zhenxie_composition_instances_models.dart';

class ZhenxieCompositionInstanceCardWidget extends StatelessWidget {
  static const double _cardHeight = 398;

  final CompositionInstanceModel instance;
  final CompositionGenreModel? genre;
  final Map<String, ParagraphRhetoricalEntityList> beatMap;
  final List<String> beatOrderList;
  final String difficultyLabel;
  final String coverUrl;
  final Color genreColor;
  final bool showCoverOverlay;
  final VoidCallback? onTap;
  final VoidCallback? onReviewImages;
  final VoidCallback? onCropCover;
  final VoidCallback? onEditCover;
  final String Function(List<LanguageText>? values, String lang) langTextGetter;
  final String Function(String? beatNid) beatNameGetter;
  final String Function(CompositionStageModel stage) headLabelGetter;
  final String Function(CompositionStageModel stage) tailLabelGetter;
  final bool Function(CompositionStageModel stage) hasHeadGetter;
  final bool Function(CompositionStageModel stage) hasTailGetter;

  const ZhenxieCompositionInstanceCardWidget({
    super.key,
    required this.instance,
    required this.genre,
    required this.beatMap,
    required this.beatOrderList,
    required this.difficultyLabel,
    required this.coverUrl,
    required this.genreColor,
    required this.showCoverOverlay,
    this.onReviewImages,
    this.onCropCover,
    this.onEditCover,
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
    final CompositionStageModel? stage = instance.stage;
    final String blueprintTitle = langTextGetter(instance.blueprint?.name, 'zh');
    final String title = langTextGetter(instance.title, 'zh');
    final String titleEn = langTextGetter(instance.title, 'en');
    final String genreLabel = langTextGetter(genre?.name, 'zh');

    return ZhenxieWriteCatalogCardWidget(
      height: _cardHeight,
      coverUrl: coverUrl,
      difficultyLabel: difficultyLabel,
      blueprintLabel: blueprintTitle,
      title: title,
      titleEn: titleEn,
      entityLabel: '范文',
      entityValue: instance.uid?.toString() ?? '',
      genreLabel: genreLabel,
      genreColor: genreColor,
      description: '',
      coverOverlay: showCoverOverlay ? _buildCoverOverlay() : null,
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
