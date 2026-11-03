import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/widgets.dart';

class ManageAllCouresSort {
  static Future<String?> show({
    required BuildContext context,
    TextEditingController? controller,
    void Function(String text)? onChanged,
    void Function(String)? onSubmitted,
  }) async {
    return await showCupertinoDialog<String?>(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Material(
            color: const Color(0xff141828).withValues(alpha: 0.7),
            child: Center(
              child: _ManageAllCouresSortWidget(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ManageAllCouresSortWidget extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String text)? onChanged;
  final void Function(String)? onSubmitted;

  const _ManageAllCouresSortWidget({this.controller, this.onChanged, this.onSubmitted});

  @override
  State<_ManageAllCouresSortWidget> createState() => __ManageAllCouresSortWidgetState();
}

class __ManageAllCouresSortWidgetState extends State<_ManageAllCouresSortWidget> {
  String inputText = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 376.ww,
      padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: const Color(0xff23283D),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "将此课程排序到",
            style: TextStyle(
              fontSize: 16.wMin,
              color: const Color(0xffEBEEF3),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.ww),
          Text(
            "排序",
            style: TextStyle(
              fontSize: 12.wMin,
              color: const Color(0xffBAC0CC),
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 8.ww),
            margin: EdgeInsets.only(top: 12.wh),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              border: Border.all(width: 0.8.wMin, color: const Color(0xff4B5268)),
              color: Colors.transparent,
            ),
            child: TextField(
              controller: widget.controller,
              style: TextStyle(
                fontSize: 16.wMin,
                color: const Color(0xffF7F8FA),
                fontWeight: FontWeight.w400,
              ),
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 5,
              decoration: InputDecoration(
                isDense: true,
                counterText: "",
                hintText: '请输入数字',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintStyle: TextStyle(
                    fontSize: 14.wMin,
                    height: 1.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff666F8D),
                    textBaseline: TextBaseline.alphabetic),
              ),
              onChanged: (value) {
                inputText = value;
                widget.onChanged?.call(value);
              },
              onSubmitted: (value) {
                widget.onSubmitted?.call(value);
                Get.back(result: value);
              },
            ),
          ),
          SizedBox(height: 24.wh),
          Row(
            children: [
              Expanded(
                child: TapScaleWidget(
                  onTap: () => Get.back(),
                  sclae: 1.1,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8.wh),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.wMin),
                      border: Border.all(width: 1.wMin, color: const Color(0xff4B5268)),
                    ),
                    child: Text(
                      "取消",
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffE3E7ED),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.ww),
              Expanded(
                child: TapScaleWidget(
                  onTap: () {
                    widget.onSubmitted?.call(inputText);
                    Get.back(result: inputText);
                  },
                  sclae: 1.1,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8.wh),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.wMin),
                      color: const Color(0xff0679FF),
                    ),
                    child: Text(
                      "确定",
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffE3E7ED),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
