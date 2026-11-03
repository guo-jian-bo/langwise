import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 语义词卡组件 - 组合型，支持两种显示样式
/// [displayMode] - 显示模式：card(卡片样式) 或 detail(详情样式)
class CombinedSemanticsWidget extends StatefulWidget {
  final int index;
  final EnEntitySemantics entitySemantics;
  final String displayMode; // 'card' 或 'detail'
  final double width;
  final double height;
  final Function(int, EnEntitySemantics)? onTap;
  final Function(int, EnEntitySemantics)? onSelectTap;
  final Function(int, EnEntitySemantics)? onDeleteTap;

  const CombinedSemanticsWidget({
    super.key,
    required this.index,
    required this.entitySemantics,
    this.displayMode = 'detail', // 默认详情模式
    this.width = 432,
    this.height = 188,
    this.onTap,
    this.onSelectTap,
    this.onDeleteTap,
  });

  @override
  State<CombinedSemanticsWidget> createState() => _CombinedSemanticsWidgetState();
}

class _CombinedSemanticsWidgetState extends State<CombinedSemanticsWidget> {
  EnEntitySemantics? _lastReceivedEntity;

  @override
  void initState() {
    super.initState();
    _lastReceivedEntity = widget.entitySemantics;
  }

  @override
  Widget build(BuildContext context) {
    // 根据显示模式选择不同的UI
    return widget.displayMode == 'card' ? _buildCardMode() : _buildDetailMode();
  }

  /// 构建基础UI（公共部分）
  Widget _buildBaseUI({
    required Widget topRightWidget,
    required BoxDecoration decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    debugPrint("---语义:$_lastReceivedEntity--");
    return Container(
      padding: padding ?? EdgeInsets.all(10.wMin),
      width: width,
      height: height,
      margin: margin,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          topRightWidget,
          SizedBox(height: 8.wMin),
          Expanded(
            child: Row(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.wMin),
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      color: Colors.white.withValues(alpha: 0.1),
                      child: CachedImageWidget(_lastReceivedEntity?.imageUrl ?? '',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          errorWidget: buildImage(Assets.managerImageNotFound,
                              width: double.infinity, height: double.infinity, fit: BoxFit.contain)),
                    ),
                  ),
                ),
                Gaps.getWidth(8.ww),
                Expanded(
                  child: Column(
                    spacing: 10.wMin,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      StatusTagDifficultyWidget(
                        difficulty: _lastReceivedEntity?.difficulty,
                        language: _lastReceivedEntity?.language,
                      ),
                      Text(
                        _lastReceivedEntity?.glossZhTitle ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyleExtension.ts_16_w400_ls8_EDF0F4,
                      ),
                      Text(
                        _lastReceivedEntity?.descriptionZhTitle ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyleExtension.ts_14_w400_ls8_EDF0F4,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 卡片模式 - 对应第一张图片UI样式
  Widget _buildCardMode() {
    String iconUnCheck = "assets/svg/manage/icon_unradio.svg";
    String iconCheck = "assets/svg/manage/icon_radio.svg";

    // 卡片模式特有的装饰
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8.wMin),
      border: (_lastReceivedEntity?.isSelected != null && _lastReceivedEntity!.isSelected)
          ? Border.all(width: 1.wMin, color: const Color(0xff2388FF))
          : Border.all(width: 1.wMin, color: const Color(0xff353E5C)),
      color: const Color(0xff353E5C).withValues(alpha: 0.1),
    );

    // 卡片模式特有的顶部操作区域（选择图标）
    final topRightWidget = Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SelectableText(
            "uid: ${_lastReceivedEntity?.uid}",
            style: TextStyleExtension.ts_16_w400_ls8_EDF0F4,
          ),
          SvgPicture.asset(
            (_lastReceivedEntity?.isSelected != null && _lastReceivedEntity!.isSelected) ? iconCheck : iconUnCheck,
            width: 18.wMin,
          ),
        ],
      ),
    );

    return TapScaleWidget(
      sclae: 1.0,
      onTap: OptimizeUtils.noneThrottle(() {
        if (_lastReceivedEntity != null) {
          widget.onSelectTap?.call(widget.index, _lastReceivedEntity!);
        }
      }, 200),
      child: _buildBaseUI(
        topRightWidget: topRightWidget,
        decoration: decoration,
      ),
    );
  }

  /// 详情模式 - 对应第二张图片UI样式
  Widget _buildDetailMode() {
    // 详情模式特有的装饰（无选中状态边框变化）
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8.wMin),
      color: const Color(0xFF616B85).withValues(alpha: 0.35),
    );

    // 详情模式特有的顶部操作区域（删除按钮）
    final topRightWidget = TapScaleWidget(
      sclae: 1.03,
      onTap: () {
        // 触发删除回调
        debugPrint("删除语义标签: ${_lastReceivedEntity?.uid}");
        if (_lastReceivedEntity != null) {
          widget.onDeleteTap?.call(widget.index, _lastReceivedEntity!);
        }
      },
      child: SizedBox(
        width: 24.wMin,
        height: 24.wMin,
        child: Icon(
          Icons.close,
          size: 18.wMin,
          color: const Color(0xFFB2BAC2),
        ),
      ),
    );

    return _buildBaseUI(
      topRightWidget: topRightWidget,
      decoration: decoration,
      width: widget.width,
      height: widget.height,
      margin: EdgeInsets.only(left: 12.ww),
    );
  }

  @override
  void didUpdateWidget(covariant CombinedSemanticsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 关键逻辑：仅在外源数据真实变化时更新
    if (widget.entitySemantics != _lastReceivedEntity) {
      _lastReceivedEntity = widget.entitySemantics;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _lastReceivedEntity = null;
  }
}
