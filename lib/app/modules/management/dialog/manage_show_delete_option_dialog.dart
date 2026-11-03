


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';

class ManageShowDeleteOptionDialog{


  Future<int?> show({
    required BuildContext context,
  }) async{
    return await showCupertinoDialog<int?>(
      context: context,
      builder: (context) {
        return const ManageShowDeleteOptionDialogWidget();
      },
    );
  }

}

class ManageShowDeleteOptionDialogWidget extends StatefulWidget {
  const ManageShowDeleteOptionDialogWidget({
    super.key,
  });

  @override
  State<ManageShowDeleteOptionDialogWidget> createState() => _ManageShowDeleteOptionDialogWidgetState();
}

class _ManageShowDeleteOptionDialogWidgetState extends State<ManageShowDeleteOptionDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff040712).withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 446.wMin,
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            color: const Color(0xff23283D),
            borderRadius: BorderRadius.circular(16.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWidget(),
              SizedBox(height: 45.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildButtonWidget("从后台数据库", "assets/svg/manage/icon_detele_dept.svg", 0),
                  _buildButtonWidget("从当前课程中", "assets/svg/manage/icon_book_open.svg", 1),
                ],
              ),
              SizedBox(height: 56.wMin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonWidget(String text, String svg, int index){
    return Column(
      spacing: 8.wMin,
      children: [
        TapScaleWidget(
          onTap: () {
            Get.back(result: index);
          },
          sclae: 1.03,
          child: Container(
            width: 104.wMin,
            height: 104.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.wMin),
              color: const Color(0xff353E5C),
            ),
            child: SvgPicture.asset(
              svg,
              width: 48.wMin,
            ),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xffACB4C0),
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 24.wMin),
        Text(
          "删除",
          style: TextStyle(
            color: const Color(0xffEBEEF3),
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
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
