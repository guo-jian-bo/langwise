import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/theme/theme.dart';

import '../controllers/membership_card_manage_code_manage_controller.dart';
import '../models/membership_card_manage_code_manage_model.dart';

class MembershipCardManageCodeManageDialog {
  static show({
    required BuildContext context,
    required MembershipCardManageCodeManageModel item,
    required String tagText,
  }) async {
    return showCupertinoDialog(
      context: context,
      builder: (context) => MembershipCardManageCodeManageDialogWidget(
        item: item,
        tagText: tagText,
      ),
    );
  }
}

class MembershipCardManageCodeManageDialogWidget extends StatefulWidget {
  final MembershipCardManageCodeManageModel item;
  final String tagText;
  const MembershipCardManageCodeManageDialogWidget({
    super.key,
    required this.item,
    required this.tagText,
  });

  @override
  State<MembershipCardManageCodeManageDialogWidget> createState() => _MembershipCardManageCodeManageDialogWidgetState();
}

class _MembershipCardManageCodeManageDialogWidgetState extends State<MembershipCardManageCodeManageDialogWidget> {
  late final MembershipCardManageCodeManageController controller;
  late TextEditingController textFieldController;

  @override
  void initState() {
    controller = Get.find<MembershipCardManageCodeManageController>(tag: widget.tagText);
    textFieldController = TextEditingController(text: widget.item.remarks ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.cOverlayBackground.color,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.wMin, vertical: 30.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: AppTheme.cBgSecondary,
              ),
              width: 540.wMin,
              height: 500.wMin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "复制激活码",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.wMin),
                  Row(
                    children: [
                      Text(
                        "会员级别",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${widget.item.vipType??''}会员卡",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.wMin),
                  Row(
                    children: [
                      Text(
                        "激活码",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.item.code ?? '',
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.wMin),
                  Text(
                    "备注",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 20.wMin),
                  Container(
                    height: 50.wMin,
                    padding: EdgeInsets.only(left: 15.wMin, right: 10.wMin),
                    decoration: BoxDecoration(
                      color: AppTheme.cMemberCardSearchBackground,
                      borderRadius: BorderRadius.circular(6.wMin),
                      border: Border.all(
                        color: AppTheme.cMemberCardInactiveBackground,
                        width: 2.wMin,
                      ),
                    ),
                    child: TextField(
                      controller: textFieldController,
                      maxLength: 100,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        counterText: "",
                        hintText: "请输入备注（选填）",
                        hintStyle: const TextStyle(color: AppTheme.cQuizDefaultBackground),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          top: 13.wMin,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildBottomWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      children: [
        Expanded(
          child: ManageButton(
            text: "取消",
            height: 50.wMin,
            color: AppTheme.cBgQuaternary,
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            onTap: () {
              Get.back();
            },
          ),
        ),
        SizedBox(width: 20.wMin),
        Expanded(
          child: ManageButton(
            text: "复制",
            height: 50.wMin,
            color: AppTheme.cBgBrand,
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            onTap: () {
              String note = textFieldController.text.trim();
              if (note.isEmpty) {
                note = '';
              }
              controller.addNote(widget.item.uid!, note);
              Clipboard.setData(ClipboardData(text: widget.item.code ?? ''));
              ToastUtils.showManageToast(text: '已复制激活码');
              Get.back();
            },
          ),
        ),
      ],
    );
  }
}
