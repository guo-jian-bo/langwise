import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_dropdown_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/modules/management/common/manage_public_widget.dart';
import '../../app/modules/management/common/manage_title_input_widget.dart';
import 'dialog_box_widget.dart';
import 'tap_scale_widget.dart';

/// 管理-新增级别
class AddLevelDialog{

  static Future<bool?> show({
    required BuildContext context,
  }) async{
    return await showCupertinoDialog<bool?>(
      context: context, 
      builder: (context) {
        return const AddLevelDialogWidget();
      },
    );
  }

}

class AddLevelDialogWidget extends StatefulWidget {
  const AddLevelDialogWidget({super.key});

  @override
  State<AddLevelDialogWidget> createState() => _AddLevelDialogWidgetState();
}

class _AddLevelDialogWidgetState extends State<AddLevelDialogWidget> {
  /// 创建方式
  int createWay = 1;

  // ------- 复制 ---------
  /// 原始ID
  final TextEditingController copyOriginalID = TextEditingController();
  /// 名称
  final TextEditingController copyName = TextEditingController();

  // ------- 导入 -----
  /// 名称
  final TextEditingController importName = TextEditingController();
  /// 选择文件的路径
  String importFilePath = "";

  // ------- 手动 -------
  /// ID
  final TextEditingController handMovementId = TextEditingController();
  ///名称
  final TextEditingController handMovementName = TextEditingController();
  ///描述
  final TextEditingController handMovementDescription = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  Future<void> selectLevel() async{
    SelectLevelTableDialog.show(context: context);
  }


  @override
  Widget build(BuildContext context) {

    Widget buildTitleWay(String name, String info, int index){
      return ManageTitleWay(
        name: name,
        info: info,
        selected: createWay == index,
        onTap: () {
          createWay = index;
          if(mounted) setState(() {});
        },
      );
    }

    /// 复制
    Widget buildCopy(){
      return FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          children: [
            ManageTitleInputWidget(
              focusOrder: 0,
              title: "原等级ID",
              hintText: "请输入原等级ID",
              controller: copyOriginalID,
            ),
            SizedBox(height: 24.wMin),
            ManageTitleInputWidget(
              focusOrder: 1,
              title: "新等级名称",
              hintText: "请输入新等级名称",
              controller: copyName,
            ),
          ],
        ),
      );
    }

    /// 导入
    Widget buildImport(){
      return Column(
        spacing: 16.wMin,
        children: [

          ManageBox(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 16.wMin),
            borderRadius: 8.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                      child: Text(
                        "Intermediate English",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffEBEEF3),
                        ),
                      ),
                    ),
                    TapScaleWidget(
                      onTap: (){},
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.all(5.wMin),
                        child: Icon(Icons.clear, color: const Color(0xffBAC0CC), size: 20.wMin),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.wMin),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                  child: Text(
                    "Building on basic skills with more complex language concepts ",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xffACB4C0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          TapScaleWidget(
            onTap: selectLevel,
            sclae: 1.01,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(8.wMin),
              dashPattern: [2.wMin, 3.wMin],
              padding: EdgeInsets.zero,
              strokeCap: StrokeCap.round,
              strokeWidth: 1.wMin,
              color: const Color(0xff4B5268),
              child: Container(
                alignment: Alignment.center,
                height: 122.wMin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/manage/icon_add.svg",
                      height: 22.ww,
                    ),
                    Text(
                      "添加等级",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: const Color(0xffEAECFF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      );
    }

    /// 手动
    Widget buildHandMovement(){
      return FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          children: [
            ManageTitleInputWidget(
              focusOrder: 0,
              title: "级别ID",
              hintText: "请输入级别ID",
              controller: handMovementId,
            ),
            SizedBox(height: 24.wMin),
            ManageTitleInputWidget(
              focusOrder: 1,
              title: "级别名称",
              hintText: "请输入级别名称",
              controller: handMovementName,
            ),
            SizedBox(height: 24.wMin),
            ManageTitleInputWidget(
              focusOrder: 2,
              title: "级别描述",
              hintText: "请输入级别描述",
              controller: handMovementDescription,
            ),
            SizedBox(height: 24.wMin),
            const ManageDropdownWidget(
              title: "语言",
              values: ["英语", "中文", "日语", "韩语"],
              valueMainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ],
        ),
      );
    }
    
    
    return DialogBoxWidget(
      title: "添加级别",
      define: "下一步",
      width: 1080.wMin,
      onCancel: () => Get.back(),
      onDefine: () {
        Get.back(result: true);
      },
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          children: [
            Row(
              children: [
                buildTitleWay("关联级别", "关联现有级别，快速规划内容。", 1),
                SizedBox(width: 16.ww),
                buildTitleWay("复制级别", "从现有级别创建，支持调整学习顺序。", 0),
                SizedBox(width: 16.ww),
                buildTitleWay("手动输入", "完全手动输入", 2),
              ],
            ),
            SizedBox(height: 24.wh),
            Container(
              padding: EdgeInsets.all(16.wMin),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: const Color(0xff22293C),
                borderRadius: BorderRadius.circular(8.wMin),
              ),
              height: 580.wMin,
              child: Builder(
                key: ValueKey(createWay),
                builder: (context) {
                  if(createWay == 1){
                    return buildImport();
                  }else if(createWay == 2){
                    return buildHandMovement();
                  }
                  return buildCopy();
                },
              ),
            ),
          ],
        ),
      ),
    );
    
  }
}