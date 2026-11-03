import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/manage_content/manage_audio_subtitle_editor/controllers/manage_audio_subtitle_editor_controller.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class BackWidget extends StatelessWidget {
  final String? title;
  final Color? fontColor;
  final double? fontSize;
  final String? fontFamily;
  final double? titleMaxWidth;
  final Color? backIconColor;
  final void Function()? onTap;
  // 新增：是否显示边框（默认不显示）
  final bool showBorder;
  // 边框相关配置（仅在showBorder为true时生效）
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? tapSize;
  final double? iconSize;

  const BackWidget({
    super.key,
    this.title,
    this.fontColor,
    this.fontSize,
    this.titleMaxWidth,
    this.fontFamily,
    this.backIconColor,
    this.onTap,
    // 核心新增：是否显示边框，默认值为false
    this.showBorder = false,
    // 边框参数默认值（可根据设计调整）
    this.borderColor = AppTheme.cTextPrimary,
    this.borderWidth = 1,
    this.borderRadius = 99,
    this.tapSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // 外层Container：根据showBorder控制是否渲染边框
    return Row(
      children: [
        Container(
            margin: showBorder ? EdgeInsets.only(bottom: 24.wMin) : EdgeInsets.zero,

            // 仅显示边框时添加内边距，避免内容贴边框
            padding: showBorder ? EdgeInsets.only(right: 24.wMin) : EdgeInsets.zero,
            // 核心：条件渲染边框样式
            decoration: showBorder
                ? BoxDecoration(
                    border: Border.all(
                      color: borderColor!.withValues(alpha: 0.15),
                      width: borderWidth!.wMin,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(borderRadius!.wMin),
                    color: Colors.transparent,
                  )
                : null, // 不显示边框时，decoration设为null（无样式）
            // 原有Row内容
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TapScaleWidget(
                  onTap: onTap ??
                      () async {
                        try {
                          ManageAudioSubtitleEditorController.markAllAudioEditorsLeavingPage();
                          await ManageAudioSubtitleEditorController.stopAllAudioEditors();
                        } catch (_) {}
                        Get.back();
                      },
                  sclae: 1.1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: (tapSize ?? 64).wMin,
                        height: (tapSize ?? 64).wMin,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_arrow_back.svg",
                          width: (iconSize ?? 40).wMin,
                          height: (iconSize ?? 40).wMin,
                          colorFilter: backIconColor != null ? ColorFilter.mode(backIconColor!, BlendMode.srcIn) : null,
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                    ],
                  ),
                ),
                Visibility(
                  visible: title != null && title != "",
                  child: Container(
                    margin: EdgeInsets.only(left: 8.wMin),
                    constraints: BoxConstraints(
                      maxWidth: titleMaxWidth ?? double.infinity,
                    ),
                    child: Text(
                      title ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize ?? 28.wMin,
                        color: fontColor ?? AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
