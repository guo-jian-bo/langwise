import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';

class ElementsCardSearchWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final double cornerRadius;
  final double btnRadius;
  final double leftPadding;
  final double rightPadding;
  final void Function(String)? onSearch;
  final void Function(String value)? onChange;
  final void Function()? onTap;
  const ElementsCardSearchWidget({super.key, this.controller, this.onSearch, this.onChange, this.onTap, this.hintText = "搜索知识点卡片",this.cornerRadius = 999,this.btnRadius = 999,this.leftPadding = 12,this.rightPadding = 3});

  @override
  State<ElementsCardSearchWidget> createState() => _ElementsCardSearchWidgetState();
}

class _ElementsCardSearchWidgetState extends State<ElementsCardSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 382.wMin,
      height: 54.wMin,
      padding: EdgeInsets.only(
        left: widget.leftPadding.wMin,
        right: widget.rightPadding.wMin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.cornerRadius.wMin),
        color: AppTheme.cBgQuaternary.color,
      ),
      child: Row(
        children: [
          SizedBox(width: 6.wMin),
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
              textInputAction: TextInputAction.search,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                counterText: "",
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w500,
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 40.wMin,
                  minHeight: 38.wMin,
                ),
                prefixIcon: SvgPicture.asset(
                  "assets/svg/elements/icon_search.svg",
                  width: 38.wMin,
                  height: 38.wMin,
                  colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
                ),
              ),
              onSubmitted: (value) {
                widget.onSearch?.call(value);
              },
              onChanged: widget.onChange,
              onTap: widget.onTap,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 6.wMin),
            child: TapScaleWidget(
              onTap: () {
                widget.onSearch?.call(widget.controller?.text ?? "");
              },
              sclae: 1.05,
              child: Container(
                width: 88.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.btnRadius.wMin),
                  color: AppTheme.cFeedbackDefaultBackground.color,
                ),
                child: Text(
                  "搜索",
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
