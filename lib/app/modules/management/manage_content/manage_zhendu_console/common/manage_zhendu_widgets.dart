import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:decimal/decimal.dart';

import '../../../../../../common/input_formatters/decimal_textInput_formatter.dart';
import '../../../../../../common/widgets/widgets.dart';

class ManageZhenduInputWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? prefixText;
  final String? title;
  final double? height;
  final bool readOnly;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;
  final void Function(PointerDownEvent)? onTapOutside;
  const ManageZhenduInputWidget({
    super.key, 
    this.controller, 
    this.hintText, 
    this.prefixText, 
    this.title, 
    this.height,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    return CardInputWidget(
      title: title,
      fillColor: readOnly ? Colors.transparent : AppTheme.cSurfaceTertiary.color,
      borderColor: AppTheme.cBorderSecondary.color,
      titleStyle: TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextSecondary.color,
      ),
      controller: controller,
      hintText: hintText,
      prefixText: prefixText,
      height: height ?? 54.wMin,
      readOnly: readOnly,
      borderRadius: BorderRadius.circular(8.wMin),
      
      valueStyle: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextPrimary.color,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextTertiary.color,
        fontWeight: FontWeight.w400,
      ),
      onClean: readOnly ? null : () {
        if(readOnly) return;
        controller?.clear();
      },
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
    );
  }
}

class ManageZhenduNumberInputWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? title;
  final double? height;
  final bool readOnly;
  final double jumpValue;
  final double? maxValue;
  final double? minValue;
  /// 是否是整数，默认否
  final bool isInt;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function(String)? onStepChanged;
  final Duration stepChangedDebounceDuration;
  const ManageZhenduNumberInputWidget({
    super.key, 
    this.controller, 
    this.hintText, 
    this.title,
    this.height, 
    this.readOnly = false,
    this.maxValue, 
    this.minValue, 
    this.jumpValue = 1,  
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.onStepChanged,
    this.stepChangedDebounceDuration = const Duration(milliseconds: 600),
    this.isInt = false,
  });

  @override
  State<ManageZhenduNumberInputWidget> createState() => _ManageZhenduNumberInputWidgetState();
}

class _ManageZhenduNumberInputWidgetState extends State<ManageZhenduNumberInputWidget> {
  Timer? _stepChangedDebounceTimer;

  void _scheduleStepChangedCallback() {
    final String value = widget.controller?.text ?? "";
    _stepChangedDebounceTimer?.cancel();
    _stepChangedDebounceTimer = Timer(widget.stepChangedDebounceDuration, () {
      widget.onStepChanged?.call(value);
    });
  }

  @override
  void dispose() {
    _stepChangedDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int fractionDigits = _jumpValueFractionDigits(widget.jumpValue);

    return CardInputWidget(
      title: widget.title,
      fillColor: widget.readOnly ? Colors.transparent : AppTheme.cSurfaceTertiary.color,
      borderColor: AppTheme.cBorderSecondary.color,
      titleStyle: TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextSecondary.color,
      ),
      controller: widget.controller,
      hintText: widget.hintText,
      height: widget.height?? 54.wMin,
      readOnly: widget.readOnly,
      borderRadius: BorderRadius.circular(8.wMin),
      valueStyle: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextPrimary.color,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextTertiary.color,
        fontWeight: FontWeight.w400,
      ),
      onClean: widget.readOnly ? null : () {
        widget.controller?.clear();
      },
      inputFormatters: [DecimalTextInputFormatter(maxValue: widget.maxValue)],
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTapOutside: widget.onTapOutside,
      suffixIcon: Visibility(
        visible: !widget.readOnly,
        child: Column(
          children: [
        
            Expanded(
              child: TapScaleWidget(
                onTap: () {
                  if(widget.readOnly) return;
                  if(widget.controller == null) return;
        
                  Decimal current = Decimal.tryParse(widget.controller!.text) ?? Decimal.zero;
                  current = current + Decimal.parse(widget.jumpValue.toString());
        
                  if(widget.maxValue != null){
                    if (current > Decimal.parse(widget.maxValue.toString())) {
                      return;
                    }
                  }
        
                  widget.controller?.text = _formatDecimalValue(current, fractionDigits);
        
                  _scheduleStepChangedCallback();
        
                },
                sclae: 1.03,
                backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
                child: Container(
                  width: 50.wMin,
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/manage/icon_chevron_up.svg",
                    height: 20.wMin,
                  ),
                ),
              
              ),
            ),
            Expanded(
              child: TapScaleWidget(
                onTap: () {
                  if(widget.readOnly) return;
                  if(widget.controller == null) return;
        
                  Decimal current = Decimal.tryParse(widget.controller!.text) ?? Decimal.zero;
                  current = current - Decimal.parse(widget.jumpValue.toString());
                  
                  if(widget.minValue != null){
                    if (current < Decimal.parse(widget.minValue.toString())) {
                      return;
                    }
                  }
        
                  widget.controller?.text = _formatDecimalValue(current, fractionDigits);
        
                  _scheduleStepChangedCallback();
        
                },
                sclae: 1.03,
                backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
                child: Container(
                  width: 50.wMin,
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/manage/icon_chevron_down.svg",
                    height: 20.wMin,
                  ),
                ),
              
              ),
            ),
        
          ],
        ),
      ),
    );
  }

  int _jumpValueFractionDigits(double value) {
    if(widget.isInt) return 0;
    final String text = value.toString();
    if (!text.contains('.')) return 0;
    return text.split('.').last.length;
  }

  String _formatDecimalValue(Decimal value, int fractionDigits) {
    final String text = value.toString();
    if (fractionDigits <= 0) return text.split('.').first;

    final List<String> parts = text.split('.');
    final String integerPart = parts.first;
    final String decimalPart = parts.length > 1 ? parts[1] : '';

    if (decimalPart.length >= fractionDigits) {
      return '$integerPart.${decimalPart.substring(0, fractionDigits)}';
    }

    return '$integerPart.${decimalPart.padRight(fractionDigits, '0')}';
  }
}

class ManageZhenduInputHeightWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? title;
  final double? height;
  final int? maxLines;
  final bool readOnly;
  final Color fillColor;
  final Color borderColor;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;
  final void Function(PointerDownEvent)? onTapOutside;
  final VoidCallback? onFocusLost;
  const ManageZhenduInputHeightWidget({
    super.key, 
    this.controller, 
    this.hintText, 
    this.title, 
    this.height,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.onFocusLost,
    this.readOnly = false,
    this.fillColor = AppTheme.cSurfaceTertiary,
    this.borderColor = AppTheme.cBorderSecondary,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.wMin),
      borderSide: BorderSide(width: 1.wMin, color: borderColor),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 4.wMin),
            child: Text(
              title ?? "",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ),
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              onFocusLost?.call();
            }
          },
          child: SizedBox(
            height: height ?? 54.wMin,
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
              onTapOutside: (event) {
                onTapOutside?.call(event);
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onSubmitted: onSubmitted,
              readOnly: readOnly,
              decoration: InputDecoration(
                isDense: true,
                counterText: "",
                fillColor: fillColor,
                filled: true,
                border: border,
                focusedBorder: border,
                enabledBorder: border,
                disabledBorder: border,
                hintText: hintText,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
                hintStyle: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class ManageZhenduDropdownWidget extends StatelessWidget {
  final String? title;
  final String? hintText;
  final List<IconDropdownCheckData<dynamic>> items;
  final dynamic selectValue;
  final void Function(IconDropdownCheckData<dynamic> choiceData, int index)? onChanged;
  final double? height;
  final bool readOnly;
  const ManageZhenduDropdownWidget({
    super.key, 
    required this.items, 
    this.selectValue, 
    this.title,
    this.hintText,
    this.onChanged,
    this.height,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 4.wMin),
            child: Text(
              title ?? "",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: readOnly,
          child: IconDropdownSelectWidget(
            height: height??54.wMin,
            selectValue: selectValue,
            items: items,
            hintText: hintText,
            menuHeight: 500.wMin,
            fillColor: readOnly ? Colors.transparent : AppTheme.cSurfaceTertiary.color,
            borderRadius: BorderRadius.circular(8.wMin),
            valueStyle: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
            hintStyle: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class ManageZhenduSelectWidget extends StatelessWidget {
  final String? title;
  final String? hintText;
  final String? value;
  final double? height;
  final void Function()? onTap;
  final bool readOnly;
  const ManageZhenduSelectWidget({
    super.key, 
    this.title, 
    this.hintText, 
    this.value, 
    this.height,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 4.wMin),
            child: Text(
              title ?? "",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ),
        TapScaleWidget(
          onTap: readOnly ? null : onTap,
          sclae: 1,
          child: Container(
            width: double.infinity,
            height: height??54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            decoration: BoxDecoration(
              color: readOnly ? Colors.transparent : AppTheme.cSurfaceTertiary.color,
              borderRadius: BorderRadius.circular(8.wMin),
              border: Border.all(
                color: AppTheme.cBorderSecondary.color,
                width: 1.wMin,
              ),
            ),
            child: Row(
              children: [
                Visibility(
                  visible: value != null && (value??"").isNotEmpty,
                  child: Expanded(
                    child: Text(
                      value??"",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: value == null || (value??"").isEmpty,
                  child: Expanded(
                    child: Text(
                      hintText??"",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
          
                Visibility(
                  visible: !readOnly,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_caret_down.svg",
                    width: 24.wMin,
                  ),
                ),
              ],
            ),
          
          ),
        ),
      ],
    );
  }
}
