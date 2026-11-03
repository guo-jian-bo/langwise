


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';

class ManageShowDeleteOptionDialog{


  Future<int?> show({
    required BuildContext context,
    required int selectedCount,
  }) async{
    return await showCupertinoDialog<int?>(
      context: context,
      builder: (context) {
        return ManageShowDeleteOptionDialogWidget(selectedCount: selectedCount);
      },
    );
  }

}

class ManageShowDeleteOptionDialogWidget extends StatefulWidget {
  final int selectedCount;
  const ManageShowDeleteOptionDialogWidget({
    super.key,
    required this.selectedCount,
  });

  @override
  State<ManageShowDeleteOptionDialogWidget> createState() => _ManageShowDeleteOptionDialogWidgetState();
}

class _ManageShowDeleteOptionDialogWidgetState extends State<ManageShowDeleteOptionDialogWidget> {
  int selectedType = 1;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff040712).withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 520.wMin,
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            color: const Color(0xff23283D),
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(
              width: 1.wMin,
              color: const Color(0xff2C3348),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWidget(),
              SizedBox(height: 12.wMin),
              Text(
                "已选${widget.selectedCount}道题，请选择删除方式",
                style: TextStyle(
                  color: const Color(0xffACB4C0),
                  fontSize: 15.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.wMin),
              _buildOptionWidget(
                title: "从当前课程删除",
                desc: "仅从本课时移除关联，题目资源仍保留。",
                index: 1,
              ),
              SizedBox(height: 12.wMin),
              _buildOptionWidget(
                title: "永久删除",
                desc: "从数据库彻底删除该题目资源。",
                index: 0,
              ),
              if (selectedType == 0) ...[
                SizedBox(height: 12.wMin),
                Text(
                  widget.selectedCount > 1 ? "这些题目会从数据库永久删除，不可恢复。" : "这个题目会从数据库永久删除，不可恢复。",
                  style: TextStyle(
                    color: const Color(0xffF43F5E),
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: 24.wMin),
              _buildBottomButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionWidget({
    required String title,
    required String desc,
    required int index,
  }){
    final bool isSelected = selectedType == index;
    final bool isDanger = index == 0;
    final Color borderColor;
    final Color backgroundColor;
    final Color radioColor;
    if (isSelected) {
      borderColor = isDanger ? const Color(0xff7F1D1D) : const Color(0xff0EA5E9);
      backgroundColor = isDanger ? const Color(0xff3A2027) : const Color(0xff13374B);
      radioColor = isDanger ? const Color(0xffF43F5E) : const Color(0xff0EA5E9);
    } else {
      borderColor = const Color(0xff2C3348);
      backgroundColor = const Color(0xff23283D);
      radioColor = const Color(0xff5D6477);
    }

    return TapScaleWidget(
      onTap: () {
        selectedType = index;
        if (mounted) setState(() {});
      },
      sclae: 1.02,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.wMin),
          color: backgroundColor,
          border: Border.all(
            width: 1.wMin,
            color: borderColor,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xffEBEEF3),
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6.wMin),
                  Text(
                    desc,
                    style: TextStyle(
                      color: const Color(0xff8E97A7),
                      fontSize: 13.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.wMin),
            SvgPicture.asset(
              isSelected ? "assets/svg/manage/icon_radio.svg" : "assets/svg/manage/icon_unradio.svg",
              width: 22.wMin,
              height: 22.wMin,
              colorFilter: ColorFilter.mode(
                radioColor,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtonWidget() {
    return Row(
      children: [
        Expanded(
          child: ButtonWidget(
            text: "取消",
            height: 44.wMin,
            borderRadius: 8.wMin,
            color: const Color(0xff3A3F4A),
            fontSize: 16.wMin,
            fontColor: const Color(0xffEBEEF3),
            onTap: () {
              Get.back();
            },
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: ButtonWidget(
            text: "确认删除（${widget.selectedCount}）",
            height: 44.wMin,
            borderRadius: 8.wMin,
            color: const Color(0xff6D2B33),
            fontSize: 16.wMin,
            fontColor: const Color(0xffFF5A6B),
            onTap: () {
              Get.back(result: selectedType);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "删除题目",
          style: TextStyle(
            color: const Color(0xffEBEEF3),
            fontSize: 18.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
        TapScaleWidget(
          onTap: () {
            Get.back();
          },
          child: Container(
            color: Colors.transparent,
            width: 24.wMin,
            height: 24.wMin,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              "assets/svg/manage/icon_close.svg",
              width: 20.wMin,
              height: 20.wMin,
            ),
          ),
        ),
      ],
    );
  }

}
