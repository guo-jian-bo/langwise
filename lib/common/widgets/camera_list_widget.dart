import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:wise_camera/photo_capture.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../utils/utils.dart';
import 'widgets.dart';

class CameraListWidgetManager {
  static void show({
    required BuildContext context,
    required List<CameraDevice> devices,
    void Function(CameraDevice device)? onTap,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xff040712).withValues(alpha: 0.1),
          child: CameraListWidget(
            devices: devices,
            onTap: onTap,
          ),
        );
      },
    );
  }

  static Future<CameraDevice?> showUser({
    required BuildContext context,
    String title = "选择扫描摄像头",
    required List<CameraDevice> devices,
    void Function(CameraDevice device)? onTap,
  }) async {
    return await showCupertinoDialog<CameraDevice?>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xff040712).withValues(alpha: 0.1),
          child: CameraListUserWidget(
            devices: devices,
            onTap: onTap,
            title: title,
          ),
        );
      },
    );
  }
}

class CameraListUserWidget extends StatefulWidget {
  final List<CameraDevice> devices;
  final String title;
  final void Function(CameraDevice device)? onTap;

  const CameraListUserWidget({super.key, required this.devices, this.onTap, required this.title});

  @override
  State<CameraListUserWidget> createState() => _CameraListUserWidgetState();
}

class _CameraListUserWidgetState extends State<CameraListUserWidget> {
  int _index = -1;

  @override
  Widget build(BuildContext context) {
    return CardDialogBoxWidget(
      title: widget.title,
      onCancel: () => Get.back(),
      onConfirm: () {
        if (_index == -1) {
          ToastUtils.showToast(text: "请选择摄像头");
          return;
        }
        final CameraDevice newDevice = widget.devices[_index];
        widget.onTap?.call(newDevice);
        Get.back(result: newDevice);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 24.wMin),
        child: Column(
          spacing: 16.wMin,
          children: List.generate(widget.devices.length, (index) {
            return CardSelectRowBoxWidget(
              animationIndex: index,
              name: widget.devices[index].name ?? "",
              description: widget.devices[index].position ?? "",
              isSelected: _index == index,
              onTap: () {
                setState(() {
                  _index = index;
                });
              },
            );
          }),
        ),
      ),
    );
  }
}

class CameraListWidget extends StatefulWidget {
  final List<CameraDevice> devices;
  final void Function(CameraDevice device)? onTap;

  const CameraListWidget({super.key, required this.devices, this.onTap});

  @override
  State<CameraListWidget> createState() => _CameraListWidgetState();
}

class _CameraListWidgetState extends State<CameraListWidget> with SafeSetStateMixin {
  CameraDevice? _device;

  int _index = -1;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 560.ww,
          height: 320.wh,
          padding: EdgeInsets.all(24.ww),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: const Color(0xff23283D),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ManageTitleWidget(
                title: "选择扫描摄像头",
                textStyle: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffEBEEF3),
                ),
                onCloseTap: () {
                  Navigator.pop(context);
                },
              ),
              Gaps.getHeight(16.wh),
              // 使用Expanded包裹_buildCameraWidget
              Expanded(
                child: _buildCameraWidget(),
              ),
              Gaps.getHeight(16.wh),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ManageButton(
                    text: "取消",
                    width: 80.ww,
                    height: 40.wh,
                    borderColor: const Color(0xff666F8D),
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: const Color(0xffACB4C0),
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 11.ww),
                  ManageButton(
                    text: "确认",
                    width: 80.ww,
                    height: 40.wh,
                    color: _device == null ? const Color(0xff353E5C) : const Color(0xff2388FF),
                    borderColor: Colors.transparent,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: _device != null ? const Color(0xffEBEFF5) : const Color(0xffACB4C0),
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: _device == null
                        ? null
                        : OptimizeUtils.noneThrottle(() {
                            final CameraDevice newDevice = _device!;
                            Navigator.pop(context);
                            widget.onTap?.call(newDevice);
                          }, 200),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraWidget() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.wh),
      // 移除测试用的重复数据
      itemCount: widget.devices.length,
      itemBuilder: (context, index) {
        final element = widget.devices[index];
        return GestureDetector(
          onTap: () {
            safeSetState(() {
              _device = element;
              _index = index;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 24.ww, right: 24.ww, top: 12.wh, bottom: 12.wh),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: const Color(0xff141828).withValues(alpha: 0.8),
            ),
            margin: EdgeInsets.only(bottom: 12.wh),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${element.name}",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xffEBEEF3),
                    ),
                  ),
                ),
                Icon(
                  _index == index ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: _index == index ? const Color(0xff2388FF) : const Color(0xffBAC0CC),
                  size: 18.wMax,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _device = null;
    _index = -1;
  }
}
