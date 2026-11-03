import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/theme/theme.dart';

import '../controllers/membership_card_manage_generate_code_controller.dart';

class MembershipCardManageGenerateCodeDialog {
  static show({
    required BuildContext context,
    required Map<String, dynamic> item,
    required String tagText,
  }) async {
    return showCupertinoDialog(
      context: context,
      builder: (context) => MembershipCardManageGenerateCodeDialogWidget(
        item: item,
        tagText: tagText,
      ),
    );
  }
}

class MembershipCardManageGenerateCodeDialogWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final String tagText;
  const MembershipCardManageGenerateCodeDialogWidget({
    super.key,
    required this.item,
    required this.tagText,
  });

  @override
  State<MembershipCardManageGenerateCodeDialogWidget> createState() => _MembershipCardManageGenerateCodeDialogWidgetState();
}

class _MembershipCardManageGenerateCodeDialogWidgetState extends State<MembershipCardManageGenerateCodeDialogWidget> {
  late final MembershipCardManageGenerateCodeController controller;

  @override
  void initState() {
    controller = Get.find<MembershipCardManageGenerateCodeController>(tag: widget.tagText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String vipType = controller.vipList[controller.selectLevelIndex.value].vipType ?? 'Plus';
    Color vipColor = AppTheme.cTextPrimary;
    String numText = "";
    if (vipType == 'Plus') {
      vipColor = const Color(0xff38BDF8);
      numText = "${controller.additionalCardNum.value}名(含1名免费名额)";
    } else if (vipType == 'Pro') {
      vipColor = const Color(0xffC084FC);
      numText = "${controller.additionalCardNum.value}名(含1名免费名额)";
    } else if (vipType == 'Max') {
      vipColor = const Color(0xffFB923C);
      numText = "${controller.additionalCardNum.value}名(含1名免费名额)";
    } else if (vipType == '成员席位') {
      vipColor = const Color(0xff94A3B8);
      numText = "${controller.additionalCardNum.value}名";
    }

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.wMin, vertical: 30.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cBgSecondary,
          ),
          width: 600.wMin,
          height: 500.wMin,
          child: Column(
            children: [
              Text(
                "请确认以下会员卡信息",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 40.wMin),
              Row(
                children: [
                  Text(
                    "会员等级",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    controller.vipList[controller.selectLevelIndex.value].vipType ?? "",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: vipColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.wMin),
              Row(
                children: [
                  Text(
                    "学员数量",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    numText,
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: vipColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "使用时长",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    width: 20.wMin,
                  ),
                  Expanded(
                    child: Text(
                      "${controller.couponSupplyList[controller.selectTimeIndex.value].usageMonths ?? ''}个月(${controller.couponSupplyList[controller.selectTimeIndex.value].description ?? ''})",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: vipColor,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.wMin),
              Row(
                children: [
                  Text(
                    "会员费用",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${controller.settlementModel.value.priceStr ?? 0} 元",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: vipColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildBottomWidget(),
            ],
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
            text: "生成会员卡",
            height: 50.wMin,
            color: AppTheme.cBgBrand,
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            onTap: () {
              controller.generateCode();
              Get.back();
            },
          ),
        ),
      ],
    );
  }
}
