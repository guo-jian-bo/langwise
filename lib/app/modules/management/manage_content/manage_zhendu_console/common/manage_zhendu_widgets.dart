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
  final String? title;
  final double? height;
  final bool readOnly;
  final void Function(String value)? onChanged;
  const ManageZhenduInputWidget({
    super.key, 
    this.controller, 
    this.hintText, 
    this.title, 
    this.height,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CardInputWidget(
      title: title,
      titleStyle: TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextSecondary.color,
      ),
      controller: controller,
      hintText: hintText,
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
    );
  }
}

class ManageZhenduNumberInputWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? title;
  final double? height;
  final double jumpValue;
  final double? maxValue;
  final double? minValue;
  final void Function(String)? onChanged;
  const ManageZhenduNumberInputWidget({
    super.key, 
    this.controller, 
    this.hintText, 
    this.title,
    this.height, 
    this.maxValue, 
    this.minValue, 
    this.jumpValue = 1,  
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CardInputWidget(
      title: title,
      titleStyle: TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextSecondary.color,
      ),
      controller: controller,
      hintText: hintText,
      height: height?? 54.wMin,
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
      onClean: () {
        controller?.clear();
      },
      inputFormatters: [DecimalTextInputFormatter(maxValue: maxValue)],
      onChanged: onChanged,
      suffixIcon: Column(
        children: [
      
          Expanded(
            child: TapScaleWidget(
              onTap: () {
                if(controller == null) return;

                Decimal current = Decimal.tryParse(controller!.text) ?? Decimal.zero;
                current = current + Decimal.parse(jumpValue.toString());

                if(maxValue != null){
                  if (current > Decimal.parse(maxValue.toString())) {
                    return;
                  }
                }

                controller?.text = current.toString();

                onChanged?.call(controller?.text??"");

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
                if(controller == null) return;

                Decimal current = Decimal.tryParse(controller!.text) ?? Decimal.zero;
                current = current - Decimal.parse(jumpValue.toString());
                
                if(minValue != null){
                  if (current < Decimal.parse(minValue.toString())) {
                    return;
                  }
                }

                controller?.text = current.toString();

                onChanged?.call(controller?.text??"");

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
    );
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
  const ManageZhenduInputHeightWidget({
    super.key, 
    this.controller, 
    this.hintText, 
    this.title, 
    this.height,
    this.maxLines = 1,
    this.onChanged,
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
        SizedBox(
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
              FocusScope.of(context).requestFocus(FocusNode());
            },
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
  const ManageZhenduDropdownWidget({
    super.key, 
    required this.items, 
    this.selectValue, 
    this.title,
    this.hintText,
    this.onChanged,
    this.height,
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
        IconDropdownSelectWidget(
          height: height??54.wMin,
          selectValue: selectValue,
          items: items,
          hintText: hintText,
          menuHeight: 500.wMin,
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
  const ManageZhenduSelectWidget({
    super.key, 
    this.title, 
    this.hintText, 
    this.value, 
    this.height,
    this.onTap,
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
          onTap: onTap,
          sclae: 1,
          child: Container(
            width: double.infinity,
            height: height??54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceTertiary.color,
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
          
                SvgPicture.asset(
                  "assets/svg/public/icon_caret_down.svg",
                  width: 24.wMin,
                ),
              ],
            ),
          
          ),
        ),
      ],
    );
  }
}

