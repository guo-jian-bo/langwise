import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageUnitGrammarStepWidget extends StatelessWidget {
  final List<ManageUnitGrammarPipelineStepEntity> steps;
  final bool Function(ManageUnitGrammarPipelineStepEntity step) canRunStep;
  final String Function(ManageUnitGrammarPipelineStepEntity step) getActionLabel;
  final void Function(ManageUnitGrammarPipelineStepEntity step)? onTap;

  const ManageUnitGrammarStepWidget({
    super.key,
    required this.steps,
    required this.canRunStep,
    required this.getActionLabel,
    this.onTap,
  });

  static const Color _activeColor = Color(0xFFF59E0B);
  static const Color _doneColor = Color(0xff34D399);
  static const Color _loadingColor = Color(0xff22D3EE);
  Color get _textPrimary => AppTheme.cTextPrimary.color;
  Color get _textSecondary => AppTheme.cTextSecondary.color;
  Color get _textTertiary => AppTheme.cTextTertiary.color;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          children: List.generate(steps.length, (index) {
            return _buildStepItem(steps[index], index);
          }),
        ),
      ),
    );
  }

  Widget _buildStepItem(ManageUnitGrammarPipelineStepEntity step, int index) {
    final String? status = step.status;
    final bool isLocked = status == 'locked';
    final bool isDone = status == 'done' || status == 'skipped';
    final bool isRunning = status == 'running';
    final bool canRun = canRunStep(step);
    final Color connectorColor =
        isLocked ? _textPrimary.withValues(alpha: 0.15) : _doneColor;
    final Color pointColor = isLocked
        ? _textPrimary.withValues(alpha: 0.35)
        : isRunning
            ? _loadingColor
            : isDone
                ? _doneColor
                : _activeColor;

    return SizedBox(
      width: 210.wMin,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Visibility(
                visible: index != 0,
                child: Positioned(
                  left: -150.wMin,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      height: 2.wMin,
                      width: 140.wMin,
                      color: connectorColor,
                    ),
                  ),
                ),
              ),
              Container(
                width: 42.wMin,
                height: 42.wMin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: !isLocked
                      ? pointColor.withValues(alpha: 0.12)
                      : _textPrimary.withValues(alpha: 0.08),
                  border: Border.all(
                    width: 2.wMin,
                    color: !isLocked
                        ? pointColor.withValues(alpha: 0.2)
                        : _textPrimary.withValues(alpha: 0.15),
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isDone
                        ? SvgPicture.asset(
                            'assets/svg/public/icon_check_w.svg',
                            key: const ValueKey(true),
                            width: 18.wMin,
                            colorFilter: ColorFilter.mode(
                              pointColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : Text(
                            '${step.step ?? 0}'.padLeft(2, '0'),
                            key: const ValueKey(false),
                            style: TextStyle(
                              color: !isLocked
                                  ? pointColor
                                  : _textSecondary,
                              fontSize: 13.wMin,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          Text(
            step.name ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            step.summary ?? '',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12.wMin,
            ),
          ),
          SizedBox(height: 12.wMin),
          _buildActionButton(
            step: step,
            canRun: canRun,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required ManageUnitGrammarPipelineStepEntity step,
    required bool canRun,
  }) {
    final String actionText = getActionLabel(step);
    if (actionText.isEmpty) {
      return SizedBox(height: 34.wMin);
    }
    final _ManageUnitGrammarStepButtonStyle style =
        _buildButtonStyle(step: step, canRun: canRun);

    return TapScaleWidget(
      sclae: canRun ? 1.01 : 1,
      borderRadius: 999.wMin,
      onTap: canRun
          ? OptimizeUtils.noneThrottle(() {
              onTap?.call(step);
            }, 200)
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.wMin,
          vertical: 6.wMin,
        ),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: style.borderColor,
          ),
        ),
        child: Text(
          actionText,
          style: TextStyle(
            color: style.textColor,
            fontSize: 14.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  _ManageUnitGrammarStepButtonStyle _buildButtonStyle({
    required ManageUnitGrammarPipelineStepEntity step,
    required bool canRun,
  }) {
    final String? status = step.status;
    final bool isLocked = status == 'locked';
    final bool isDone = status == 'done' || status == 'skipped';
    final bool isRunning = status == 'running';
    final Color mainColor = AppTheme.cDifficultyBackgroundColor22.color;

    if (isLocked) {
      return _ManageUnitGrammarStepButtonStyle(
        textColor: _textTertiary,
        borderColor: AppTheme.cBorderTranslucentThin.color,
        backgroundColor: AppTheme.cSurfaceLayerBase.color,
      );
    }

    if (isDone && !canRun) {
      return _ManageUnitGrammarStepButtonStyle(
        textColor: _textPrimary,
        borderColor: AppTheme.cSurfaceLayerElevated.color,
        backgroundColor: AppTheme.cSurfaceLayerBase2.color,
      );
    }

    if (isRunning) {
      return _ManageUnitGrammarStepButtonStyle(
        textColor: _darkenColor(mainColor, 0.2),
        borderColor: mainColor.withValues(alpha: 205 / 255),
        backgroundColor: mainColor.withValues(alpha: 0.1),
      );
    }

    if (canRun) {
      return _ManageUnitGrammarStepButtonStyle(
        textColor: mainColor,
        borderColor: mainColor.withValues(alpha: 205 / 255),
        backgroundColor: mainColor.withValues(alpha: 0.1),
      );
    }

    return _ManageUnitGrammarStepButtonStyle(
      textColor: _textTertiary,
      borderColor: AppTheme.cBorderTranslucentThin.color,
      backgroundColor: AppTheme.cSurfaceLayerBase.color,
    );
  }

  Color _darkenColor(Color color, double amount) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    final double lightness = (hslColor.lightness * (1 - amount)).clamp(0.0, 1.0);
    return hslColor.withLightness(lightness).toColor();
  }
}

class _ManageUnitGrammarStepButtonStyle {
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;

  const _ManageUnitGrammarStepButtonStyle({
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });
}
