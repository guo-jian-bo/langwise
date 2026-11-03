import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';

class ZhenxieParagraphExampleCardWidget extends StatefulWidget {
  final ParagraphExampleEntityList data;
  final bool isManagement;
  const ZhenxieParagraphExampleCardWidget({super.key, required this.data, this.isManagement = false});

  @override
  State<ZhenxieParagraphExampleCardWidget> createState() => _ZhenxieParagraphExampleCardWidgetState();
}

class _ZhenxieParagraphExampleCardWidgetState extends State<ZhenxieParagraphExampleCardWidget> {
  /// 悬浮item下标
  int? hoverIndex;

  /// 跳转至写作目标
  void _jumpToWritingTarget(ParagraphExampleEntityListParagraphList? item) {
    TagRoutes.toNamed(
      Routes.ZHENXIE_PARAGRAPH_WRITING_GOAL,
      arguments: {
        "isManagement": widget.isManagement,
        "instanceUid": item?.uid,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ParagraphExampleEntityListParagraphList?> paragraphList = widget.data.paragraphList ?? [];
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(),
          SizedBox(height: 16.wMin),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: paragraphList.length,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.wMin,
              crossAxisSpacing: 16.wMin,
              mainAxisExtent: 248.wMin,
            ),
            itemBuilder: (context, index) {
              return _buildItemWidget(paragraphList[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget() {
    final name = LearningLangUtils.getLocalLang(widget.data.paragraphType?.name);
    return Text(
      name?.text ?? '',
      style: TextStyle(
        fontSize: 28.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextPrimary.color,
      ),
    );
  }

  Widget _buildItemWidget(ParagraphExampleEntityListParagraphList? item, int index) {
    final name = LearningLangUtils.getLocalLang(item?.name);
    int beatCount = item?.beatCount ?? 0;
    int anchorCount = item?.anchorCount ?? 0;
    int usedInCompositionCount = item?.usedInCompositionCount ?? 0;
    String bottomText = '$beatCount拍 · $anchorCount锚点 · 用于$usedInCompositionCount篇';

    bool isHovered = hoverIndex == index;

    return MouseRegion(
      onHover: (event) {
        hoverIndex = index;
        if (mounted) setState(() {});
      },
      onExit: (event) {
        hoverIndex = null;
        if (mounted) setState(() {});
      },
      child: TapScaleWidget(
        onTap: () {
          _jumpToWritingTarget(item);
        },
        sclae: 1.01,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cSurfaceBg.color,
            border: Border.all(
              color: isHovered ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.6) : AppTheme.cBorderDefault.color,
              width: 1.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name?.text ?? '',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(height: 8.wMin),
              Expanded(
                child: Text(
                  item?.content ?? '',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
              ),
              Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
              SizedBox(height: 10.wMin),
              Text(
                bottomText,
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextDisabled.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
