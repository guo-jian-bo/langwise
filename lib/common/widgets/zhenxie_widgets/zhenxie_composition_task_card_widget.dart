import 'package:flutter/material.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';

class ZhenxieCompositionTaskCardWidget extends StatelessWidget {
  static const double _cardHeight = 378;

  final ContentCardData contentData;
  final Widget? actions;
  final VoidCallback? onTap;
  final bool isManagement;

  const ZhenxieCompositionTaskCardWidget({
    super.key,
    required this.contentData,
    this.actions,
    this.onTap,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    return ZhenxieWriteCatalogCardWidget(
      contentData: contentData,
      actions: actions,
      height: _cardHeight,
      copyLabel: '任务',
      isManagement: isManagement,
      onTap: onTap,
    );
  }
}
