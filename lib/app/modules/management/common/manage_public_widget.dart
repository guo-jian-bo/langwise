import 'package:auto_size_text/auto_size_text.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import 'manage_button.dart';

class ManageBox extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ManageBox({super.key, required this.child, this.height, this.padding, this.borderRadius, this.margin});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: height,
      duration: const Duration(milliseconds: 100),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 16.wMin),
        color: const Color(0xff353E5C),
      ),
      child: child,
    );
  }
}

class ManageTitleWay extends StatelessWidget {
  final bool selected;
  final String name;
  final String info;
  final void Function()? onTap;
  final double sclae;
  final bool disable;

  /// 创建的方式
  const ManageTitleWay({
    super.key,
    this.selected = false,
    required this.name,
    required this.info,
    this.onTap,
    this.sclae = 1.03,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: disable ? 0.5 : 1.0,
        child: TapScaleWidget(
          onTap: disable ? null : onTap,
          sclae: sclae,
          child: AnimatedContainer(
            height: 87.wh,
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: const Color(0xff2E344E),
              border: Border.all(
                  width: 0.5.wMin,
                  color: selected ? const Color.fromRGBO(35, 136, 255, 0.65) : const Color(0xff666F8D)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: const Color(0xffEBEEF3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: selected ? const Color(0xff2388FF) : const Color(0xffBAC0CC),
                      size: 26.wMin,
                    ),
                  ],
                ),
                SizedBox(height: 8.wh),
                Expanded(
                  child: AutoSizeText(
                    info,
                    minFontSize: 4,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: const Color(0xffACB4C0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ManageImportWidget extends StatefulWidget {
  final void Function(String file)? onSelect;

  /// 上传进度 0-100
  final double uploadProgress;
  final void Function()? onClose;

  /// 下载 上传 模版
  const ManageImportWidget({
    super.key,
    this.onSelect,
    this.uploadProgress = 0,
    this.onClose,
  });

  @override
  State<ManageImportWidget> createState() => _ManageImportWidgetState();
}

class _ManageImportWidgetState extends State<ManageImportWidget> {
  bool _dragging = false;
  String fileName = "";

  void dragSelectFile(DropDoneDetails details) {
    fileName = details.files.first.name;
    if (mounted) setState(() {});
    widget.onSelect?.call(details.files.first.path);
  }

  Future<void> tapSelectFile() async {
    showCupertinoDialog(
      context: context,
      builder: (conetxt) => Container(),
    );
    if (mounted) setState(() {});
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      lockParentWindow: true,
      dialogTitle: "请选择要导入的文件",
    );
    print('---result:$result---');
    if (result == null) {
      Get.back();
      if (mounted) setState(() {});
      return;
    }
    String? path = result.files.single.path;
    if (path == null) {
      Get.back();
      if (mounted) setState(() {});
      return;
    }
    Get.back();
    fileName = result.files.single.name;
    if (mounted) setState(() {});
    widget.onSelect?.call(path);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: const Color.fromRGBO(20, 24, 40, 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "模版文件",
            style: TextStyle(
              fontSize: 16.wMin,
              color: const Color(0xffEBEFF5),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12.wh),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 8.wh),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: const Color(0xff23283D),
            ),
            child: Row(
              children: [
                SvgPicture.asset(Assets.manageIconTemplate, width: 32.ww),
                SizedBox(width: 6.ww),
                Text(
                  "模版文件1",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffACB4C0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                ManageButton(
                  text: "下载",
                  borderColor: Colors.transparent,
                  color: const Color(0xff2388FF),
                  width: 80.ww,
                  height: 32.wh,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.wh),
          Visibility(
            visible: fileName != "",
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 21.wh),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.wh, color: const Color(0xff666F8D)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "上传文件",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: const Color(0xffEBEFF5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.wh),
                  Container(
                    margin: EdgeInsets.only(bottom: 21.wh),
                    padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 12.wh),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: const Color(0xff23283D),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/svg/manage/icon_file.svg", width: 32.wh, height: 32.wh),
                        SizedBox(width: 8.ww),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: const Color(0xffACB4C0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Container(
                              height: 6.wh,
                              width: 322.ww,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.wMin),
                                color: const Color(0xff4B5268),
                              ),
                              child: Container(
                                height: 6.wh,
                                width: widget.uploadProgress / 100 * 322.ww,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.wMin),
                                  color: const Color(0xff666F8D),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 80.ww),
                        Text(
                          "86%",
                          style: TextStyle(
                            fontSize: 12.wMin,
                            color: const Color(0xffACB4C0),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TapScaleWidget(
                          onTap: () {
                            fileName = "";
                            if (mounted) setState(() {});
                            widget.onClose?.call();
                          },
                          child: Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.all(10.wMin),
                            child:
                                SvgPicture.asset("assets/svg/manage/icon_close.svg", width: 16.wh, height: 16.wh),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          DropTarget(
            onDragDone: dragSelectFile,
            onDragEntered: (details) {
              _dragging = true;
              if (mounted) setState(() {});
            },
            onDragExited: (details) {
              _dragging = false;
              if (mounted) setState(() {});
            },
            child: AnimatedScale(
              duration: const Duration(milliseconds: 100),
              scale: _dragging ? 1.02 : 1,
              child: TapScaleWidget(
                onTap: tapSelectFile,
                sclae: 1.02,
                child: DottedBorder(
                  radius: Radius.circular(8.wMin),
                  borderType: BorderType.RRect,
                  padding: EdgeInsets.zero,
                  color: const Color(0xffBAC0CC),
                  dashPattern: const [3, 3],
                  child: SizedBox(
                    width: double.infinity,
                    height: 138.wh,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/svg/manage/icon_file1.svg", width: 48.wh, height: 48.wh),
                        SizedBox(height: 16.wh),
                        Text(
                          "请先下载参考模版，按照参考模版打包压缩后上传",
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: const Color(0xffACB4C0),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ManageLearningLanguages extends StatelessWidget {
  final int selectedIndex;
  final void Function(int index)? onTap;

  /// 学习语言
  const ManageLearningLanguages({
    super.key,
    required this.selectedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildRadio(String name, int index) {
      return TapScaleWidget(
        onTap: () => onTap?.call(index),
        sclae: 1.1,
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectedIndex == index ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selectedIndex == index ? const Color(0xff2388FF) : const Color(0xffF0F2F5),
                size: 26.wMin,
              ),
              SizedBox(width: 4.ww),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: const Color(0xffEBEFF5),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ManageBox(
      padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 12.wh),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "学习语言",
              style: TextStyle(
                fontSize: 16.wMin,
                color: const Color(0xffACB4C0),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 6.wh),
            Wrap(
              spacing: 24.ww,
              runSpacing: 12.wh,
              children: [
                buildRadio("英语", 0),
                buildRadio("中文", 1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 添加封面
class ManageAddCover extends StatefulWidget {
  final String? title;
  final String? des;
  final String? icon;
  final String? filePath;
  final double? width;
  final double? height;
  final AsyncValueGetter<String?>? onTap;

  const ManageAddCover({super.key, this.title, this.des, this.icon, this.filePath, this.width, this.height, this.onTap});

  @override
  State<ManageAddCover> createState() => _ManageAddCoverState();
}

class _ManageAddCoverState extends State<ManageAddCover> with SafeSetStateMixin {
  String? _filePath;

  bool get hasFilePath => _filePath != null;

  @override
  void initState() {
    super.initState();
    _filePath = widget.filePath;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title ?? "封面",
              style: TextStyle(
                fontSize: 14.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
            Gaps.getHeight(12.wh),
            TapScaleWidget(
              onTap: OptimizeUtils.noneThrottle(() async {
                final String? filePath = await widget.onTap?.call();
                if (filePath != null) {
                  safeSetState(() {
                    _filePath = filePath;
                  });
                }
              }, 200),
              sclae: 1.03,
              child: _buildImageWidget(),
            )
          ],
        ));
  }

  Widget _buildImageWidget() {
    if (hasFilePath) {
      if (_filePath!.startsWith("http")) {
        return CachedImageWidget(_filePath!,
            width: widget.width ?? 174.ww,
            height: widget.height ?? 245.wh,
            placeholder: buildImage(
              Assets.managerOfficialCourseCover,
              width: widget.width ?? 174.ww,
              height: widget.height ?? 245.wh,
            ),
            errorWidget: buildImage(
              Assets.managerOfficialCourseCover, 
              width: widget.width ?? 174.ww, 
              height: widget.height ?? 245.wh, 
              fit: BoxFit.contain,
            ),
          );
      }

      return buildFileImage(_filePath!, width: widget.width ?? 174.ww, height: widget.height ?? 245.wh);
    }
    return DottedBorder(
      radius: Radius.circular(10.wMin),
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      color: const Color(0xff4B5268),
      dashPattern: const [4, 2],
      child: SizedBox(
        width: widget.width ?? 174.ww,
        height: widget.height ?? 245.wh,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) buildImage(widget.icon ?? '', width: 40.wMax, height: 40.wMax),
            SizedBox(height: 12.wh),
            Text(
              widget.des ?? "添加封面",
              style: TextStyle(
                fontSize: 12.wMin,
                color: const Color(0xffACB4C0),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
