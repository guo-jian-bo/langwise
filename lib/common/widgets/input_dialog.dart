import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class InputDialog {
  static Future<String?> show({
    required BuildContext context,
    String? title,
    String? content,
    String? hintText,
    String? inputDesc,
    String? realName,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    bool required = true,
    String? confirmText = "确认",
  }) async {
    return await showCupertinoDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return InputDialogWidget(
          title: title,
          content: content,
          hintText: hintText,
          inputDesc: inputDesc,
          realName: realName,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          required: required,
          confirmText: confirmText,
        );
      },
    );
  }
}

class InputDialogWidget extends StatefulWidget {
  final String? title;
  final String? content;
  final String? hintText;
  final String? inputDesc;
  final String? realName;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool required;
  final String? confirmText;

  const InputDialogWidget({
    super.key,
    this.title,
    this.content,
    this.hintText,
    this.inputDesc,
    this.realName,
    this.maxLength,
    this.inputFormatters,
    this.keyboardType,
    this.required = true,
    this.confirmText = "确认",
  });

  @override
  State<InputDialogWidget> createState() => _InputDialogWidgetState();
}

class _InputDialogWidgetState extends State<InputDialogWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.realName?.trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: 800.wMin,
                padding: EdgeInsets.all(40.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  color: AppTheme.cBgSecondary,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: widget.title != null,
                      child: Text(
                        widget.title ?? "",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    Visibility(
                      visible: widget.content != null,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.content ?? "",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cTextSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    CardInputWidget(
                      controller: controller,
                      hintText: widget.hintText,
                      maxLength: widget.maxLength,
                      inputFormatters: widget.inputFormatters,
                      keyboardType: widget.keyboardType,
                      onClean: () {
                        controller.clear();
                      },
                    ),
                    Visibility(
                      visible: widget.inputDesc != null,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 8.wMin),
                        child: Text(
                          widget.inputDesc ?? "",
                          style: TextStyle(
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextTertiary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 48.wMin),
                    Row(
                      spacing: 18.wMin,
                      children: [
                        Expanded(
                          child: ButtonWidget(
                            text: "取消",
                            height: 56.wMin,
                            fontColor: AppTheme.cTextPrimary,
                            fontSize: 24.wMin,
                            color: AppTheme.cBgTertiary,
                            fontWeight: FontWeight.w600,
                            borderRadius: 8.wMin,
                            sclae: 1.02,
                            onTap: OptimizeUtils.noneThrottle(() {
                              Navigator.of(context).pop();
                            }, 200),
                          ),
                        ),
                        Expanded(
                          child: ButtonWidget(
                            text: widget.confirmText ?? "确认",
                            height: 56.wMin,
                            fontColor: AppTheme.cStaticWhite,
                            fontSize: 24.wMin,
                            color: AppTheme.cBgBrand,
                            borderRadius: 8.wMin,
                            fontWeight: FontWeight.w600,
                            sclae: 1.02,
                            onTap: OptimizeUtils.noneThrottle(() {
                              if (controller.text.trim().isEmpty && widget.required) {
                                ToastUtils.showToast(text: "请输入内容");
                                return;
                              }
                              Navigator.of(context).pop(controller.text.trim());
                            }, 200),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16.wMin,
                top: 16.wMin,
                child: TapScaleWidget(
                  sclae: 1.05,
                  onTap: () => Get.back(),
                  child: Container(
                    width: 48.wMin,
                    height: 48.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceTertiary.color,
                      border: Border.all(width: 1.wMin, color: AppTheme.cBorderDefault.color),
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/x.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
