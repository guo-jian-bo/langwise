import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../https/https.dart';
import 'dialog_box_widget.dart';
import 'quiz_public_widget.dart';
import 'tap_scale_widget.dart';

class SelectQuizTemplateDialog{
  static Future<ManageQuizTemplateEntity?> show({
    required BuildContext context,
  }) async {
    
    return await showCupertinoDialog<ManageQuizTemplateEntity?>(
      context: context,
      builder: (context) {
        return const SelectQuizTemplateDialogWidget();
      },
    );
  }
}

class SelectQuizTemplateDialogWidget extends StatefulWidget {
  const SelectQuizTemplateDialogWidget({super.key});

  @override
  State<SelectQuizTemplateDialogWidget> createState() => _SelectQuizTemplateDialogWidgetState();
}

class _SelectQuizTemplateDialogWidgetState extends State<SelectQuizTemplateDialogWidget> {
  final List<ConfigEntityDifficulties> difficultieList = [];
  List<ManageQuizTemplateEntity> questionDataList = <ManageQuizTemplateEntity>[];
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    getQuizData();
  }

  // Future<void> getConfig() async{
  //   ConfigEntity? configData = await ConfigRequest.getConfig();
  //   if(configData == null) return;
  //   List<ConfigEntityDifficulties?>? difficulties = configData.difficulties;
  //   if(difficulties == null) return;
  //   difficultieList.clear();
  //   for(int i = 0; i < difficulties.length; i++){
  //     ConfigEntityDifficulties? item = difficulties[i];
  //     if(item == null) continue;
  //     difficultieList.add(item);
  //   }

  //   if(mounted) setState(() {});
  // }

  Future<void> getQuizData() async{
    List<ManageQuizTemplateEntity>? res = await ManageQuizTemplateRequest.getQuizTemplateList();
    if(res == null) return;
    questionDataList = res;
    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DialogBoxWidget(
      title: "选择题目模版",
      width: 1400.wMin,
      define: "确定",
      onCancel: () => Get.back(),
      onDefine: () {
        if(selectedIndex == -1) {
          ToastUtils.showToast(text: "请选择题目模版");
          return;
        }
        Get.back(result: questionDataList[selectedIndex]);
      },
      child: Container(
        height: 800.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: GridView.builder(
          itemCount: questionDataList.length,
          padding: EdgeInsets.all(24.wMin),
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16.wMin,
            crossAxisSpacing: 16.wMin,
            childAspectRatio: 376 / 325,
          ),
          itemBuilder: (context, index) {
            return _SelectQuizTemplateDialogQuizWidget(
              data: questionDataList[index],
              selected: selectedIndex == index,
              onTap: () {
                selectedIndex = index;
                if(mounted) setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}

class _SelectQuizTemplateDialogQuizWidget extends StatefulWidget {
  final ManageQuizTemplateEntity data;
  final bool selected;
  final void Function()? onTap;
  const _SelectQuizTemplateDialogQuizWidget({required this.data, this.onTap, required this.selected});

  @override
  State<_SelectQuizTemplateDialogQuizWidget> createState() => __SelectQuizTemplateDialogQuizWidgetState();
}

class __SelectQuizTemplateDialogQuizWidgetState extends State<_SelectQuizTemplateDialogQuizWidget> with AutomaticKeepAliveClientMixin{

  void showTips(BuildContext ctx) {
    BotToast.showAttachedWidget(
      targetContext: ctx,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection: PreferDirection.bottomCenter,
      verticalOffset: 4.wMin,
      attachedBuilder: (cancelFunc) {
        return Container(
          padding: EdgeInsets.all(16.wMin),
          constraints: BoxConstraints(
            minWidth: 200.wMin,
            maxWidth: 900.wMin,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceQuaternary.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          ),
          child: Container(
              margin: EdgeInsets.only(top: 8.wMin),
              child: Text(
                widget.data.template?.description??"",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TapScaleWidget(
      sclae: 1.02,
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 6.wMin, horizontal: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: const Color(0xff22293C),
          border: Border.all(width: 0.5.wMin, color: const Color(0xff4B5268)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.wMin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.data.template?.name??"",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: const Color(0xffEBEFF5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.wMin),
                    child: SvgPicture.asset(
                      widget.selected ? "assets/svg/manage/icon_radio.svg" : "assets/svg/manage/icon_unradio.svg", 
                      width: 24.wMin,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (ctx) {
                      return MouseRegion(
                        onEnter: (event) {
                          showTips(ctx);
                        },
                        onExit: (event) {
                          BotToast.cleanAll();
                        },
                        child: TapScaleWidget(
                          onTap: Platform.isMacOS || Platform.isWindows || Platform.isLinux
                              ? null
                              : () {
                                  showTips(ctx);
                                },
                          sclae: 1,
                          child: Text(
                            widget.data.template?.description??"",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: const Color(0xffACB4C0),
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                  const Spacer(),
                  QuizPublicQuizWidget(
                    borderRadius: 12.wMin,
                    data: widget.data.exercise,
                  ),
                ],
              ),
            ),
            
      
          ],
        ),
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}