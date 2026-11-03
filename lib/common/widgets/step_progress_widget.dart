import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../entities/entities.dart';

class StepProgressWidget extends StatefulWidget {
  final List<StepProgressData> steps;
  final void Function(StepProgressData data)? onTap;
  final bool isTask;

  /// 步骤进度
  const StepProgressWidget({super.key, required this.steps, this.onTap, this.isTask = false});

  @override
  State<StepProgressWidget> createState() => _StepProgressWidgetState();
}

class _StepProgressWidgetState extends State<StepProgressWidget> {
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        // 核心代码：复制当前的滚动行为，但强制关闭滚动条
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              children: List.generate(widget.steps.length, (index) {
                return _buildStepItemWidget(widget.steps[index], index);
              }),
            ),
          ),
        ));
  }

  Widget _buildStepItemWidget(StepProgressData data, int index) {
    return SizedBox(
      width: 230.wMin,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Visibility(
                visible: index != 0,
                child: Positioned(
                  left: -162.5.wMin,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      height: 4.wMin,
                      width: 150.wMin,
                      color: data.complete ? AppTheme.cBgBrand : AppTheme.cTextTertiary,
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 55.wMin,
                height: 55.wMin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.complete ? AppTheme.cBgBrand : AppTheme.cStaticWhite,
                  border: Border.all(
                    width: 3.wMin,
                    color: widget.isTask
                        ? data.current || data.complete
                            ? AppTheme.cBgBrand
                            : AppTheme.cTextTertiary
                        : data.current
                            ? AppTheme.cBgBrand
                            : AppTheme.cTextTertiary,
                  ),
                ),
                child: _buildCircleBody(data.complete, data.step),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Text(
            data.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.wMin,
              color: widget.isTask
                  ? data.buttonText == '未解锁'
                      ? AppTheme.cTextTertiary
                      : AppTheme.cTextPrimary
                  : data.current
                      ? AppTheme.cTextPrimary
                      : AppTheme.cTextPrimary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          Visibility(
            visible: data.subName != null,
            child: Container(
              margin: EdgeInsets.only(top: 10.wMin),
              child: Text(
                data.subName ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cWhiteAlpha50,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Visibility(
            visible: data.buttonText != null,
            child: Container(
              margin: EdgeInsets.only(top: 8.wMin),
              child: TapScaleWidget(
                onTap: () {
                  widget.onTap?.call(data);
                },
                sclae: 1.05,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.wMin, horizontal: 16.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    border: Border.all(
                        color: widget.isTask
                            ? data.buttonText == '去完成'
                                ? Colors.transparent
                                : AppTheme.cBorderTertiary
                            : Colors.transparent),
                    color: widget.isTask
                        ? data.buttonText == "去完成"
                            ? AppTheme.cSurfaceBrand.color
                            : data.buttonText == "已完成"
                                ? Colors.transparent
                                : AppTheme.cSurfaceSecondary
                        : AppTheme.cSurfaceBrand.color,
                  ),
                  child: Text(
                    data.buttonText ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.isTask ? 22.wMin : 24.wMin,
                      color: widget.isTask
                          ? data.buttonText == "去完成"
                              ? AppTheme.cInverseTextLight
                              : data.buttonText == "已完成"
                                  ? AppTheme.cTextQuaternary
                                  : AppTheme.cTextTertiary
                          : AppTheme.cStaticWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBody(bool complete, int step) {
    Widget checkWidget = SvgPicture.asset(
      "assets/svg/public/icon_check_w.svg",
      width: 40.wMin,
      key: const ValueKey(true),
    );

    Widget stepTextWidget = Text(
      step.toString().padLeft(2, "0"),
      key: const ValueKey(false),
      style: TextStyle(
        fontSize: 22.wMin,
        color: AppTheme.cStaticBlack,
        fontWeight: FontWeight.w500,
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: complete ? checkWidget : stepTextWidget,
    );
  }
}

class StepProgressEnum {
  static String COURSE_UN_CREATED = "COURSE_UN_CREATED";
  static String COURSE_CREATED = "COURSE_CREATED";

  static String LEVEL_UN_CREATED = "LEVEL_UN_CREATED";
  static String LEVEL_CREATED = "LEVEL_CREATED";

  static String MODULE_UN_CREATED = "MODULE_UN_CREATED";
  static String MODULE_CREATED = "MODULE_CREATED";

  static String KNOWLEDGE_ADDING = "KNOWLEDGE_ADDING";
  static String KNOWLEDGE_COMPLETED = "KNOWLEDGE_COMPLETED";

  static String KNOWLEDGE_VALIDATE = "KNOWLEDGE_VALIDATE";
  static String KNOWLEDGE_VALIDATED = "KNOWLEDGE_VALIDATED";

  static String COURSE_GENERATE = "COURSE_GENERATE";
  static String COURSE_FINISHED = "COURSE_FINISHED";
}

class StepProgressData {
  int step;
  String? code;
  String name;
  String? subName;
  String? buttonText;
  bool complete;
  bool current;
  PushMessageEntityJump? jump;
  List<StepProgressDataItems>? items;

  StepProgressData({
    required this.step,
    required this.name,
    this.code,
    this.subName,
    this.buttonText,
    this.complete = false,
    this.current = false,
    this.jump,
    this.items,
  });
}

class StepProgressDataItems {
/*
{
  "code": "COURSE_CREATED",
  "title": "课程已创建",
  "index": 1
} 
*/

  String? code;
  String? title;
  int? index;

  StepProgressDataItems({
    this.code,
    this.title,
    this.index,
  });
  StepProgressDataItems.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    title = json['title']?.toString();
    index = json['index']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['title'] = title;
    data['index'] = index;
    return data;
  }
}

class CopyStepProgressWidget extends StatefulWidget {
  final List<CopyStepProgressData> steps;
  final void Function(CopyStepProgressData data)? onTap;

  /// 步骤进度
  const CopyStepProgressWidget({super.key, required this.steps, this.onTap});

  @override
  State<CopyStepProgressWidget> createState() => _CopyStepProgressWidgetState();
}

class _CopyStepProgressWidgetState extends State<CopyStepProgressWidget> with SafeSetStateMixin {
  bool _circleCompleted = false;

  final double circleWidth = 55.wMin;

  @override
  void initState() {
    super.initState();
    // 使用WidgetsBinding.instance.addPostFrameCallback来确保在布局完成后获取位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      0.35.delay(() {
        safeSetState(() {
          _circleCompleted = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 圆圈和横线的Row布局
        _buildProgressIndicatorRow(),
        SizedBox(height: 16.wMin),
        // 文本标签的Stack布局，需要固定高度
        if (_circleCompleted)
          SizedBox(
            width: double.infinity,
            // 为文本标签预留足够的高度
            height: containHeight(),
            child: _buildTextLabelsRow(),
          ),
      ],
    );
  }

  // 知识点校对的subName不为空,高度增加
  double containHeight() {
    if (ObjectUtil.isNotEmpty(widget.steps[4].subName)) {
      return 120.wh;
    }
    return 40.wh;
  }

  /// 构建进度指示器行（圆圈和横线）
  Widget _buildProgressIndicatorRow() {
    final List<Widget> children = [];

    for (int index = 0; index < widget.steps.length; index++) {
      final data = widget.steps[index];

      // 添加圆形步骤指示器
      children.add(_buildStepCircle(data));

      // 添加横线指示器（除了最后一个元素）
      if (index < widget.steps.length - 1) {
        children.add(_buildIndicatorLine(widget.steps[index]));
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  /// 构建文本标签行
  Widget _buildTextLabelsRow() {
    return Stack(
      children: List.generate(widget.steps.length, (index) {
        final data = widget.steps[index];
        return _buildPositionedText(data, index);
      }),
    );
  }

  final double textWidth = 200.wMin;

  /// 构建定位的文本组件
  Widget _buildPositionedText(CopyStepProgressData data, int index) {
    return Positioned(
      top: 0,
      left: _getTextLeftPosition(
        data,
        index,
      ),
      child: SizedBox(
        // 固定文本容器宽度
        width: textWidth,
        child: _buildStepTextWidget(data),
      ),
    );
  }

  double _getTextLeftPosition(CopyStepProgressData data, int index) {
    final record = CommonUtils.getSizeAndPosition(data.circleKey);
    // print("😆😆size: ${record.size}, localPosition: ${record.localPosition}, globalPosition:${record.globalPosition}");
    final double circleCenter = record.globalPosition.dx + circleWidth / 2;
    return circleCenter - (textWidth / 2);
  }

  /// 构建单个步骤的文本部分
  Widget _buildStepTextWidget(CopyStepProgressData data) {
    return Column(
      children: [
        Text(
          data.status == StepProgressStatus.completed ? data.completeName : data.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.wMin,
            color: data.current ? AppTheme.cStaticWhite : AppTheme.cWhiteAlpha50,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (data.subName != null)
          Container(
            margin: EdgeInsets.only(top: 10.wMin),
            child: Text(
              data.subName ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cWhiteAlpha50,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (data.buttonText != null)
          Container(
            margin: EdgeInsets.only(top: 4.wMin),
            child: TapScaleWidget(
              onTap: () {
                widget.onTap?.call(data);
              },
              sclae: 1.05,
              child: Container(
                padding: EdgeInsets.all(8.wMin),
                color: Colors.transparent,
                child: Text(
                  data.buttonText ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cSurfaceBrand,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建指示器横线
  /// AI模式使用渐变色，普通模式使用单色
  Widget _buildIndicatorLine(CopyStepProgressData data) {
    // print("---😆😆isAi: ${data.isAi}, name:${data.name}, status: ${data.status}");
    if (data.isAi) {
      // AI模式使用渐变色横线
      final List<Color> colors = [];
      if (data.status == StepProgressStatus.normal) {
        colors.addAll([
          AppTheme.cWhiteAlpha50, // BC82F3
          AppTheme.cWhiteAlpha50, // F5B9EA
          AppTheme.cWhiteAlpha50, // 8D99FF
          AppTheme.cWhiteAlpha50, // AA6EEE
          AppTheme.cWhiteAlpha50, // FF6778
          AppTheme.cWhiteAlpha50, // FFBA71
        ]);
      } else if (data.status == StepProgressStatus.selected) {
        colors.addAll([
          AppTheme.cWhiteAlpha50, // BC82F3
          AppTheme.cWhiteAlpha50, // F5B9EA
          AppTheme.cWhiteAlpha50, // 8D99FF
          AppTheme.cWhiteAlpha50, // AA6EEE
          AppTheme.cWhiteAlpha50, // FF6778
          AppTheme.cWhiteAlpha50, // FFBA71
        ]);
      } else if (data.status == StepProgressStatus.completed) {
        colors.addAll([
          const Color(0xFFBC82F3), // BC82F3
          const Color(0xFFF5B9EA), // F5B9EA
          const Color(0xFF8D99FF), // 8D99FF
          const Color(0xFFAA6EEE), // AA6EEE
          const Color(0xFFFF6778), // FF6778
          const Color(0xFFFFBA71), // FFBA71
        ]);
      }

      return Container(
        height: 4.wMin,
        width: 135.wMin,
        margin: EdgeInsets.only(left: 14.wMin, right: 14.wMin),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      );
    } else {
      // 普通模式使用单色横线
      return Container(
        height: 4.wMin,
        width: 135.wMin,
        margin: EdgeInsets.only(left: 14.wMin, right: 14.wMin),
        color: _indicatorColor(data),
      );
    }
  }

  /// 获取指示器颜色（用于普通模式）
  Color _indicatorColor(CopyStepProgressData data) {
    if (data.status == StepProgressStatus.completed) {
      return AppTheme.cBgBrand;
    } else {
      return AppTheme.cWhiteAlpha50;
    }
  }

  Widget _buildCircleBody(CopyStepProgressData data) {
    Widget checkWidget = SvgPicture.asset(
      Assets.publicIconCheckW,
      width: 40.wMin,
      key: const ValueKey(true),
    );

    if (data.isAi) {
      checkWidget = SvgPicture.asset(
        Assets.publicIconCheckAi,
        width: 40.wMin,
        key: const ValueKey(true),
      );
    }

    Widget stepTextWidget = Text(
      data.step.toString().padLeft(2, "0"),
      key: const ValueKey(false),
      style: TextStyle(
        fontSize: 22.wMin,
        color: const Color(0xff242E39),
        fontWeight: FontWeight.w500,
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: data.status == StepProgressStatus.completed ? checkWidget : stepTextWidget,
    );
  }

  /// 构建步骤圆形指示器
  /// AI模式在选中/完成状态下使用渐变边框
  Widget _buildStepCircle(CopyStepProgressData data) {
    bool isCompleted = data.status == StepProgressStatus.completed;

    if (data.isAi) {
      // AI模式使用渐变色横线
      final List<Color> colors = [];
      if (data.status == StepProgressStatus.normal) {
        colors.addAll([
          AppTheme.cWhiteAlpha50, // BC82F3
          AppTheme.cWhiteAlpha50, // F5B9EA
          AppTheme.cWhiteAlpha50, // 8D99FF
          AppTheme.cWhiteAlpha50, // AA6EEE
          AppTheme.cWhiteAlpha50, // FF6778
          AppTheme.cWhiteAlpha50, // FFBA71
        ]);
      } else if (data.status == StepProgressStatus.selected) {
        colors.addAll([
          const Color(0xFFBC82F3), // BC82F3
          const Color(0xFFF5B9EA), // F5B9EA
          const Color(0xFF8D99FF), // 8D99FF
          const Color(0xFFAA6EEE), // AA6EEE
          const Color(0xFFFF6778), // FF6778
          const Color(0xFFFFBA71), // FFBA71
        ]);
      } else if (data.status == StepProgressStatus.completed) {
        colors.addAll([
          const Color(0xFFBC82F3), // BC82F3
          const Color(0xFFF5B9EA), // F5B9EA
          const Color(0xFF8D99FF), // 8D99FF
          const Color(0xFFAA6EEE), // AA6EEE
          const Color(0xFFFF6778), // FF6778
          const Color(0xFFFFBA71), // FFBA71
        ]);
      }

      // AI模式使用渐变边框
      return AnimatedContainer(
        key: data.circleKey,
        duration: const Duration(milliseconds: 300),
        width: circleWidth,
        height: circleWidth,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(3.wMin),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cStaticWhite,
          ),
          child: _buildCircleBody(data),
        ),
      );
    } else {
      // 普通模式使用单色边框
      return AnimatedContainer(
        key: data.circleKey,
        duration: const Duration(milliseconds: 300),
        width: circleWidth,
        height: circleWidth,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? AppTheme.cBgBrand : AppTheme.cStaticWhite,
          border: Border.all(
            width: 3.wMin,
            color: _getBorderColor(data),
          ),
        ),
        child: _buildCircleBody(data),
      );
    }
  }

  /// 根据步骤状态获取边框颜色（用于普通模式）
  Color _getBorderColor(CopyStepProgressData data) {
    if (data.status == StepProgressStatus.normal) {
      return AppTheme.cTextTertiary.withValues(alpha: 0.2);
    } else if (data.status == StepProgressStatus.selected) {
      return AppTheme.cBgBrand;
    } else {
      return AppTheme.cBgBrand;
    }
  }
}

/// 步骤进度状态枚举
enum StepProgressStatus {
  /// 默认状态
  normal,

  /// 选中状态
  selected,

  /// 完成状态
  completed,
}

class CopyStepProgressData {
  int step;
  String name;
  String completeName;
  String? subName;
  String? buttonText;
  bool current;

  /// 步骤状态
  StepProgressStatus status;

  /// 是否ai
  bool isAi;

  /// 用于获取圆圈位置的GlobalKey
  final GlobalKey circleKey;

  CopyStepProgressData({
    required this.step,
    required this.name,
    required this.completeName,
    this.subName,
    this.buttonText,
    this.current = false,
    this.status = StepProgressStatus.normal,
    this.isAi = false,
  }) : circleKey = GlobalKey();
}
