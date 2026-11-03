import 'package:flutter/material.dart';
import 'package:langwise/common/entities/module.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 单元卡片组件
class AppUnitWidget extends StatelessWidget {
  /// 单元数据
  final AppUnitResponseEntity unitEntity;

  /// 单元索引
  final int index;

  /// 内容构建器（必传参数）
  final Widget Function(BuildContext, AppUnitResponseEntity) contentBuilder;

  /// 编辑按钮回调
  final Function(AppUnitResponseEntity)? onEdit;

  /// 构造函数
  const AppUnitWidget({
    Key? key,
    required this.unitEntity,
    required this.index,
    required this.contentBuilder,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 864.ww,
      height: 636.wh,
      margin: EdgeInsets.only(right: 32.wMin),
      padding: EdgeInsets.only(left: 24.wMin, top: 24.wMin, right: 24.wMin),
      decoration: BoxDecoration(
        color: const Color(0xff15171B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24.wMin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Gaps.getHeight(16.wMin),
          Container(height: 1.wMin, width: double.infinity, color: const Color(0x1AFFFFFF)),
          Gaps.getHeight(16.wMin),
          if (unitEntity.hasKnowledgeList) Expanded(child: contentBuilder(context, unitEntity)),
        ],
      ),
    );
  }

  /// 构建单元头部
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            "${unitEntity.name ?? ''}-${unitEntity.uid}",
            maxLines: 1,
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        Gaps.getWidth(8.ww),
        // 编辑按钮
        TapScaleWidget(
          onTap: OptimizeUtils.noneThrottle(() {
            onEdit?.call(unitEntity);
          }, 100),
          child: Icon(
            Icons.edit,
            size: 32.wMin,
            color: AppTheme.cFeedbackDefaultIcon,
          ),
        ),
      ],
    );
  }
}
