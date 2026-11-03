import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';

class ElementsIconInput extends StatefulWidget {
  final double? width;
  final double? height;
  final String? hintText;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;
  final void Function()? onClean;
  final TextEditingController? controller;
  final int? maxLength;
  final Color fillColor;
  final Color borderColor;
  final String? prefixSvg;
  
  const ElementsIconInput({
    super.key, 
    this.width, 
    this.height,
    this.hintText,
    this.onChanged, 
    this.controller, 
    this.maxLength, 
    this.onSubmitted, 
    this.onClean,
    this.fillColor = Colors.transparent,
    this.borderColor = const Color(0xff2B2C2F), 
    this.prefixSvg,
  });

  @override
  State<ElementsIconInput> createState() => _ElementsIconInputState();
}

class _ElementsIconInputState extends State<ElementsIconInput> {
  final FocusNode focusNode = FocusNode();
  bool isFocus = false;
  bool isEmpty = true;

  @override
  void initState() {
    super.initState();
    focusNode.addListener((){
      isFocus = focusNode.hasFocus;
      if(mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.wMin),
      borderSide: BorderSide(width: 1.wMin, color: widget.borderColor),
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextField(
        focusNode: focusNode,
        onChanged: (value) {
          isEmpty = value.isEmpty;
          if(mounted) setState(() {});
          widget.onChanged?.call(value);
        },
        onSubmitted: widget.onSubmitted,
        controller: widget.controller,
        maxLength: widget.maxLength,
        style: TextStyle(
          fontSize: 24.wMin,
          color: const Color(0xffF2F4F9),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          counterText: "",
          isDense: true,
          fillColor: widget.fillColor,
          filled: true,
          border: border,
          focusedBorder: border,
          enabledBorder: border,
          hintText: widget.hintText,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.wMin),
          hintStyle: TextStyle(
            fontSize: 24.wMin,
            color: const Color(0xffA4ABB8),
            fontWeight: FontWeight.w400,
          ),
          prefixIconConstraints: BoxConstraints(
            maxWidth: 48.wMin,
            minHeight: 48.wMin,
            minWidth: 6.wMin,
          ),
          prefixIcon: Visibility(
            visible: widget.prefixSvg != null,
            child: Container(
              height: 64.wMin,
              width: 64.wMin,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: SvgPicture.asset(
                widget.prefixSvg??"",
                width: 32.wMin,
              ),
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            maxWidth: 64.wMin,
            minHeight: 64.wMin,
            minWidth: 6.wMin,
          ),
          suffixIcon: Visibility(
            visible: widget.onClean != null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isFocus ? 1 : (isEmpty ? 0 : 0.5),
              child: TapScaleWidget(
                onTap: (){
                  isEmpty = true;
                  if(mounted) setState(() {});
                  widget.onClean?.call();
                },
                child: Container(
                  height: 64.wMin,
                  width: 64.wMin,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_clean.svg",
                    width: 24.wMin,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}