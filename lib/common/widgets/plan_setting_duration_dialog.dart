import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'widgets.dart';

class PlanSettingDurationModel {
  String name;
  int minute;
  Color? color;

  PlanSettingDurationModel({required this.name, required this.minute, this.color});
}

/// 计划选择学习时长
class PlanSettingDurationDialog {
  static Future<int?> show({
    required BuildContext context,
    int? initMinute,
    int maxMinute = 60,
    int minMinute = 5,
    required List<PlanSettingDurationModel> durationList,
  }) async {
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return PlanSettingDurationDialogWidget(
          initMinute: initMinute,
          maxMinute: maxMinute,
          durationList: durationList,
          minMinute: minMinute,
        );
      },
    );
  }
}

class PlanSettingDurationDialogWidget extends StatefulWidget {
  final List<PlanSettingDurationModel> durationList;

  final int? initMinute;
  final int maxMinute;
  final int minMinute;

  const PlanSettingDurationDialogWidget({
    super.key,
    required this.durationList,
    this.initMinute,
    this.maxMinute = 60,
    this.minMinute = 5,
  });

  @override
  State<PlanSettingDurationDialogWidget> createState() => _PlanSettingDurationDialogWidgetState();
}

class _PlanSettingDurationDialogWidgetState extends State<PlanSettingDurationDialogWidget> {
  int selectIndex = -1;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initMinute != null) {
      selectIndex = widget.durationList.indexWhere((element) => element.minute == widget.initMinute);
      controller.text = widget.initMinute.toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.wMin),
      borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
    );

    return CardDialogBoxWidget(
      title: "设置每日学习时长",
      height: 370.wMin,
      onCancel: () => Get.back(),
      onConfirm: () {
        if (controller.text.isEmpty) {
          return ToastUtils.showToast(text: "请输入学习时长");
        }
        int? minute = int.tryParse(controller.text);
        if (minute == null) {
          return ToastUtils.showToast(text: "请输入正确的学习时长");
        }
        if (minute < widget.minMinute) {
          return ToastUtils.showToast(text: "至少${widget.minMinute}分钟");
        }
        if (minute > widget.maxMinute) {
          return ToastUtils.showToast(text: "最多${widget.maxMinute}分钟");
        }

        Get.back(result: minute);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          children: [
            SizedBox(height: 40.wMin),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 24.wMin,
              runSpacing: 24.wMin,
              children: List.generate(widget.durationList.length, (index) {
                return _buildRecommendWidget(widget.durationList[index], index);
              }),
            ),
            SizedBox(height: 32.wMin),
            Center(
              child: SizedBox(
                height: 72.wMin,
                width: 650.wMin,
                child: TextField(
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      int minute = int.parse(value);
                      if (minute > widget.maxMinute) {
                        controller.text = widget.maxMinute.toString();
                        minute = widget.maxMinute;
                        controller.selection = TextSelection.fromPosition(TextPosition(
                          offset: widget.maxMinute.toString().length,
                        ));
                      }
                      selectIndex = widget.durationList.indexWhere((element) => element.minute == minute);
                      if (mounted) setState(() {});
                    } else {
                      selectIndex = -1;
                      if (mounted) setState(() {});
                    }
                  },
                  controller: controller,
                  maxLength: widget.maxMinute.toString().length,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: "",
                    fillColor: AppTheme.cBgTertiary.color,
                    filled: true,
                    border: border,
                    focusedBorder: border,
                    enabledBorder: border,
                    disabledBorder: border,
                    hintText: "自定义时长（${widget.minMinute}-${widget.maxMinute}分钟）",
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    prefixIconConstraints: BoxConstraints(
                      maxWidth: 172.wMin,
                      minHeight: 72.wMin,
                    ),
                    prefixIcon: Container(
                        alignment: Alignment.center,
                        child: Text("点击手动修改",
                            style: TextStyle(
                              color: AppTheme.cTextDisabled.color,
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w400,
                            ))),
                    hintStyle: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                    suffixIconConstraints: BoxConstraints(
                      maxWidth: 172.wMin,
                      minHeight: 72.wMin,
                    ),
                    suffixIcon: Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 18.wMin),
                      child: Text(
                        "分钟",
                        style: TextStyle(
                          color: AppTheme.cTextDisabled.color,
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendWidget(PlanSettingDurationModel data, int index) {
    return Column(
      spacing: 8.wMin,
      children: [
        Text(
          data.name,
          style: TextStyle(
            color: data.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
        ButtonWidget(
          text: "${data.minute}分钟",
          width: 200.wMin,
          height: 60.wMin,
          borderRadius: 8.wMin,
          color: selectIndex == index ? AppTheme.cBgBrand.color : AppTheme.cBgTertiary.color,
          fontSize: 24.wMin,
          fontWeight: FontWeight.w600,
          fontColor: selectIndex == index ? AppTheme.cStaticWhite.color : AppTheme.cTextPrimary.color,
          sclae: 1.03,
          onTap: () {
            selectIndex = index;
            controller.text = data.minute.toString();
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }
}

/// 计划选择学习时长
class NewPlanSettingDurationDialog {
  static Future<int?> show({
    required BuildContext context,
    int? initMinute,
    int maxMinute = 60,
    int minMinute = 5,
    required PlanSettingDurationModel durationList,
  }) async {
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return NewPlanSettingDurationDialogWidget(
          initMinute: initMinute,
          maxMinute: maxMinute,
          durationList: durationList,
          minMinute: minMinute,
        );
      },
    );
  }
}

class NewPlanSettingDurationDialogWidget extends StatefulWidget {
  final PlanSettingDurationModel durationList;

  final int? initMinute;
  final int maxMinute;
  final int minMinute;

  const NewPlanSettingDurationDialogWidget({
    super.key,
    required this.durationList,
    this.initMinute,
    this.maxMinute = 60,
    this.minMinute = 5,
  });

  @override
  State<NewPlanSettingDurationDialogWidget> createState() => _NewPlanSettingDurationDialogWidgetState();
}

class _NewPlanSettingDurationDialogWidgetState extends State<NewPlanSettingDurationDialogWidget> {
  int type = 0;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initMinute != null) {
      type = widget.durationList.minute == widget.initMinute ? 0 : 1;
      if(type == 1){
        controller.text = widget.initMinute.toString();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: CardDialogBoxWidget(
      title: "设置每日学习时长",
      height: 410.wMin,
      onCancel: () => Get.back(),
      onConfirm: () {
        if (type == 0) {
          Get.back(result: widget.durationList.minute);
          return;
        }
        if (controller.text.isEmpty) {
          return ToastUtils.showToast(text: "请输入学习时长");
        }
        int? minute = int.tryParse(controller.text);
        if (minute == null) {
          return ToastUtils.showToast(text: "请输入正确的学习时长");
        }
        if (minute < widget.minMinute) {
          return ToastUtils.showToast(text: "至少${widget.minMinute}分钟");
        }
        if (minute > widget.maxMinute) {
          return ToastUtils.showToast(text: "最多${widget.maxMinute}分钟");
        }

        Get.back(result: minute);
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Column(
            children: [_buildOfficialRecommendWidget(), SizedBox(height: 16.wMin), _buildUserWidget()],
          ),
        )
    ));
  }

  /// 官方推荐
  Widget _buildOfficialRecommendWidget() {
    return TapScaleWidget(
      sclae: 1.008,
      onTap: () {
        type = 0;
        if (mounted) setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cBgTertiary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "官方推荐",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextBrand.color,
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(
                  type == 0 ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                  height: 32.wMin,
                ),
              ],
            ),
            SizedBox(height: 10.wMin),
            Text(
              "${widget.durationList.minute}分钟",
              style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserWidget() {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.wMin),
      borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
    );
    return TapScaleWidget(
      sclae: 1.008,
      onTap: () {
        type = 1;
        if (mounted) setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cBgTertiary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "自定义时长",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(
                  type == 1 ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                  height: 32.wMin,
                ),
              ],
            ),
            SizedBox(height: 10.wMin),
            Text(
              "范围${widget.minMinute}-${widget.maxMinute}分钟",
              style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            TextField(
              onChanged: (value) {
                int minute = int.parse(value);
                if (minute > widget.maxMinute) {
                  controller.text = widget.maxMinute.toString();
                  minute = widget.maxMinute;
                  controller.selection = TextSelection.fromPosition(TextPosition(
                    offset: widget.maxMinute.toString().length,
                  ));
                }
                if (mounted) setState(() {});
              },
              controller: controller,
              maxLength: widget.maxMinute.toString().length,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
              onTap: () {
                setState(() {
                  type = 1;
                });
              },
              decoration: InputDecoration(
                isDense: true,
                counterText: "",
                fillColor: AppTheme.cBgTertiary.color,
                filled: true,
                border: border,
                focusedBorder: border,
                enabledBorder: border,
                disabledBorder: border,
                hintText: "请输入时长",
                contentPadding: EdgeInsets.symmetric(horizontal: 16.wMin),
                hintStyle: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w400,
                ),
                suffixIconConstraints: BoxConstraints(
                  maxWidth: 172.wMin,
                  minHeight: 72.wMin,
                ),
                suffixIcon: Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 18.wMin),
                  child: Text(
                    "分钟",
                    style: TextStyle(
                      color: AppTheme.cTextDisabled.color,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
