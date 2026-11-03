import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 知识点列表项组件
///
/// 用于显示单个知识点的卡片，包含图片、状态标签、内容和定义
class AppKnowledgeWidget extends StatelessWidget {
  /// 列表索引
  final int index;

  /// 知识点数据
  final Knowledge knowledge;

  const AppKnowledgeWidget({
    Key? key,
    required this.index,
    required this.knowledge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget topLeftWidget = knowledge.knowledgePointStatus.isNormal
        ? const SizedBox()
        : KnowledgePointStatusWidget(
            status: knowledge.knowledgePointStatus,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cWhiteAlpha10,
              ),
              child: CachedImageWidget(knowledge.coverUrl ?? '',
                  width: 180.ww,
                  height: 180.wh,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(8.wMin),
                  errorWidget: buildImage(
                    Assets.managerImageNotFound,
                    width: 180.ww,
                    height: 180.wh,
                    fit: BoxFit.contain,
                  )),
            ),
            Positioned(
              left: 8.wMin,
              bottom: 8.wMin,
              child: Container(
                width: 24.wMin,
                height: 24.wMin,
                padding: EdgeInsets.all(5.wMin),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff08AFE6),
                ),
                child: SvgPicture.asset("assets/svg/public/icon_speaker.svg"),
              ),
            ),
            Positioned(
              left: 4.wMin,
              top: 4.wMin,
              child: topLeftWidget,
            ),
          ],
        ),
        SizedBox(height: 8.wMin),
        Text(
          knowledge.content ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary,
            letterSpacing: 0.08,
          ),
        ),
        SizedBox(height: 2.wMin),
        Text(
          knowledge.definition ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
            letterSpacing: 0.072,
            height: 1,
          ),
        ),
      ],
    );
  }
}
