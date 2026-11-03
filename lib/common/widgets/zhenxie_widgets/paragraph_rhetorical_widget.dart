import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../../enum/enum.dart';
import '../../values/values.dart';
import '../widgets.dart';

class ParagraphRhetoricalWidget extends StatefulWidget {
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;

  /// 段落步骤列表示意
  const ParagraphRhetoricalWidget({super.key, required this.paragraphRhetoricalList});

  @override
  State<ParagraphRhetoricalWidget> createState() => _ParagraphRhetoricalWidgetState();
}

class _ParagraphRhetoricalWidgetState extends State<ParagraphRhetoricalWidget> {
  /// 优先使用当前主题配置的修辞色，避免继续依赖旧的顶层 color 字段。
  Color _getParagraphPrimaryColor(ParagraphRhetoricalEntityList? paragraphRhetorical, {required Color fallbackColor}) {
    return paragraphRhetorical?.currentThemeColor?.colorValue ?? fallbackColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 15.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        border: Border.all(color: AppTheme.cBorderSubtle.color, width: 1.wMin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.paragraphRhetoricalList.length, (index) {
              return _buildStepItemWidget(widget.paragraphRhetoricalList[index], index);
            }),
          ),
          SizedBox(width: 32.wMin),
          Container(
            width: 1.wMin,
            height: 50.wMin,
            color: AppTheme.cBorderSubtle.color,
          ),
          SizedBox(width: 32.wMin),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 24.wMin,
            children: [
              _buildStatusItemWidget(ParagraphRhetoricalStatusEnum.required),
              _buildStatusItemWidget(ParagraphRhetoricalStatusEnum.optional),
              _buildStatusItemWidget(ParagraphRhetoricalStatusEnum.empty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItemWidget(ParagraphRhetoricalEntityList paragraphRhetorical, int index) {
    LanguageText? name = LearningLangUtils.getLocalLang(paragraphRhetorical.name);
    LanguageText? gloss = LearningLangUtils.getLocalLang(paragraphRhetorical.gloss);
    Color color = _getParagraphPrimaryColor(paragraphRhetorical, fallbackColor: AppTheme.cTextPrimary.color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SuperpositionTextWidget(
              text: name?.text ?? '',
              foregroundColor: color.withValues(alpha: 0.55),
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            SizedBox(height: 4.wMin),
            Text(
              gloss?.text ?? '',
              style: TextStyle(
                fontSize: 12.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
          ],
        ),
        Visibility(
          visible: index != widget.paragraphRhetoricalList.length - 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.wMin),
            child: SvgPicture.asset(
              "assets/svg/public/icon_arrow_right.svg",
              width: 24.wMin,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItemWidget(ParagraphRhetoricalStatusEnum status) {
    Widget statusWidget = Container();
    if (status == ParagraphRhetoricalStatusEnum.required) {
      statusWidget = _buildStatusItemRequiredWidget();
    } else if (status == ParagraphRhetoricalStatusEnum.optional) {
      statusWidget = _buildStatusItemOptionalWidget();
    } else if (status == ParagraphRhetoricalStatusEnum.empty) {
      statusWidget = _buildStatusItemEmptyWidget();
    }
    return Column(
      spacing: 4.wMin,
      children: [
        statusWidget,
        Text(
          status.name,
          style: TextStyle(
            fontSize: 14.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontTertiary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItemRequiredWidget() {
    return Container(
      width: 55.wMin,
      height: 36.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(color: AppTheme.cInverseGray.color.withValues(alpha: 0.3), width: 1.wMin),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.cInverseGray.color.withValues(alpha: 0.2),
            AppTheme.cInverseGray.color.withValues(alpha: 0.08),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItemOptionalWidget() {
    return DottedBorder(
      color: AppTheme.cInverseGray.color.withValues(alpha: 0.3),
      strokeWidth: 1.0.wMin,
      dashPattern: [3.wMin, 3.wMin],
      borderType: BorderType.RRect,
      radius: Radius.circular(16.0.wMin),
      padding: EdgeInsets.zero,
      child: Container(
        width: 55.wMin,
        height: 36.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
        ),
      ),
    );
  }

  Widget _buildStatusItemEmptyWidget() {
    return SizedBox(
      width: 55.wMin,
      height: 36.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DottedBorder(
            color: AppTheme.cBorderDark.color,
            strokeWidth: 1.0.wMin,
            dashPattern: [3.wMin, 3.wMin],
            borderType: BorderType.RRect,
            radius: Radius.circular(16.0.wMin),
            padding: EdgeInsets.zero,
            child: Container(
              width: 55.wMin,
              height: 36.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.45,
            child: Container(
              width: 4.wMin,
              height: 56.wMin,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cInverseGray.color.withValues(alpha: 0.15),
                    AppTheme.cInverseGray.color.withValues(alpha: 0.3),
                    AppTheme.cInverseGray.color.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParagraphRhetoricalContainerData {
  ParagraphRhetoricalStatusEnum status;
  String? beatNid;

  BeatNidEnum get beatNidEnum => BeatNidEnum.fromValue(beatNid);

  ParagraphRhetoricalContainerData({
    required this.status,
    this.beatNid,
  });
}

class ParagraphRhetoricalContainerWidget extends StatefulWidget {
  /// 段落修辞步骤元数据，提供起承转合的名称、描述和颜色。
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;

  /// 每个步骤对应的槽位状态数据，决定显隐、样式和点击回调时返回的内容。
  final List<ParagraphRhetoricalContainerData> statusList;

  /// 自定义步骤卡片内容；若不传，则使用组件内置的默认展示。
  final Widget Function(ParagraphRhetoricalContainerData status, ParagraphRhetoricalEntityList? paragraphRhetorical, int index)?
      statusItemWidgetBuilder;

  const ParagraphRhetoricalContainerWidget({
    super.key,
    required this.paragraphRhetoricalList,
    required this.statusList,
    this.statusItemWidgetBuilder,
  });

  @override
  State<ParagraphRhetoricalContainerWidget> createState() => _ParagraphRhetoricalContainerWidgetState();
}

class _ParagraphRhetoricalContainerWidgetState extends State<ParagraphRhetoricalContainerWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.statusList.isEmpty) return SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeaderWidget(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.statusList.length, (index) {
            final ParagraphRhetoricalContainerData status = widget.statusList[index];
            final ParagraphRhetoricalEntityList? paragraphRhetorical = widget.paragraphRhetoricalList.firstWhereOrNull(
              (element) => element.nid == status.beatNid,
            );
            final Widget child = widget.statusItemWidgetBuilder?.call(widget.statusList[index], paragraphRhetorical, index) ?? Container();
            return Expanded(
              child: child,
            );
          }),
        ),
      ],
    );
  }

  /// 优先使用当前主题配置的修辞色，避免直接依赖旧的顶层 color 字段。
  Color _getParagraphPrimaryColor(ParagraphRhetoricalEntityList? paragraphRhetorical, {required Color fallbackColor}) {
    return paragraphRhetorical?.currentThemeColor?.colorValue ?? fallbackColor;
  }

  /// 绘制顶部连线、圆点和步骤简称。
  Widget _buildHeaderWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int count = widget.statusList.length;
        final double halfWidth = count > 0 ? constraints.maxWidth / count / 2 : 0;

        return SizedBox(
          child: Stack(
            children: [
              if (count > 1)
                Positioned(
                  left: halfWidth,
                  right: halfWidth,
                  top: 12.wMin,
                  child: Row(
                    children: List.generate(count - 1, (index) {
                      return Expanded(child: _buildRailWidget(index));
                    }),
                  ),
                ),
              Row(
                children: List.generate(count, (index) {
                  return Expanded(child: _buildHeaderItemWidget(widget.statusList[index], index));
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 绘制相邻两个步骤之间的连线。
  Widget _buildRailWidget(int index) {
    final ParagraphRhetoricalContainerData next = widget.statusList[index + 1];
    final ParagraphRhetoricalEntityList? nextParagraphRhetorical = widget.paragraphRhetoricalList.firstWhereOrNull(
      (element) => element.nid == next.beatNid,
    );
    Color primaryColor = _getParagraphPrimaryColor(nextParagraphRhetorical, fallbackColor: AppTheme.cBorderDark.color);
    Color nextColor = primaryColor.withValues(alpha: 0.55);
    bool isEmpty = next.status == ParagraphRhetoricalStatusEnum.empty;
    if (isEmpty) {
      nextColor = AppTheme.cBorderDark.color;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.wMin),
      child: DottedBorder(
        color: nextColor,
        strokeWidth: 1.5.wMin,
        dashPattern: [5.wMin, isEmpty ? 3.wMin : 0],
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        customPath: (size) => Path()
          ..moveTo(0, size.height)
          ..relativeLineTo(size.width, 0),
        child: Container(
          height: 1.5.wMin,
        ),
      ),
    );
  }

  /// 绘制单个步骤顶部的圆点和简称。
  Widget _buildHeaderItemWidget(ParagraphRhetoricalContainerData step, int index) {
    final ParagraphRhetoricalEntityList? paragraphRhetorical = widget.paragraphRhetoricalList.firstWhereOrNull(
      (element) => element.nid == step.beatNid,
    );
    final String stepName = LearningLangUtils.getLocalLang(paragraphRhetorical?.name)?.text ?? '';
    Color? primaryColor =
        paragraphRhetorical == null ? null : _getParagraphPrimaryColor(paragraphRhetorical, fallbackColor: AppTheme.cTextPrimary.color);
    final Color textColor = primaryColor ?? AppTheme.cTextPrimary.color;
    Color bgColor = primaryColor ?? Colors.transparent;
    Color borderColor = Colors.white.withValues(alpha: 0.6);
    bool isDotted = step.status == ParagraphRhetoricalStatusEnum.optional || step.status == ParagraphRhetoricalStatusEnum.empty;
    if (step.status == ParagraphRhetoricalStatusEnum.optional) {
      borderColor = primaryColor ?? Colors.transparent;
      bgColor = Colors.transparent;
    } else if (step.status == ParagraphRhetoricalStatusEnum.empty) {
      borderColor = AppTheme.cBorderDark.color;
      bgColor = Colors.transparent;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DottedBorder(
          color: borderColor,
          strokeWidth: 1.5.wMin,
          dashPattern: [3.wMin, isDotted ? 3.wMin : 0],
          borderType: BorderType.Circle,
          padding: EdgeInsets.zero,
          child: Container(
            width: 24.wMin,
            height: 24.wMin,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(height: 6.wMin),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              stepName,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            Visibility(
              visible: step.status == ParagraphRhetoricalStatusEnum.optional,
              child: Positioned(
                left: 30.wMin,
                child: Text(
                  step.status.name,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
