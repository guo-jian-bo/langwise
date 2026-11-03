import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controller.dart';

class ManageBatchEditUnitManager {
  static Future<void>? show(
      {required BuildContext context,
      final Function()? onCancelTap,
      final Function(Map<String, dynamic>)? onOkTap}) {
    return Get.dialog<void>(
      Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff040712).withValues(alpha: 0.8),
        child: UnconstrainedBox(
          alignment: Alignment.center,
          child: BatchEditUnitPage(
            onCancelTap: onCancelTap,
            onOkTap: onOkTap,
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      print('---批量编辑单词弹框消失---');
      return value;
    });
  }
}

class BatchEditUnitPage extends StatefulWidget {
  final Function()? onCancelTap;
  final Function(Map<String, dynamic>)? onOkTap;

  const BatchEditUnitPage({super.key, this.onCancelTap, this.onOkTap});

  @override
  State<BatchEditUnitPage> createState() => _BatchEditUnitPageState();
}

class _BatchEditUnitPageState extends State<BatchEditUnitPage> with SafeSetStateMixin {
  bool _isOk = false;

  UnitResponseEntity? _selectedUnitRes;

  List<UnitResponseEntity> _units = [];

  @override
  void initState() {
    super.initState();
    _onFetchSimpleUnits();
  }

  void _onFetchSimpleUnits() async {
    _units = await Get.find<ManageBookWordListController>().onFetchSimpleUnits();
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 560.ww,
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(24.ww),
          decoration: BoxDecoration(
            color: const Color(0xff181B25),
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
          ),
          child: Column(
            children: [
              ManageTitleWidget(
                title: '修改此内容',
                textStyle: TextStyle(
                  fontSize: 16.wMin,
                  color: const Color(0xffEBEEF3),
                  fontWeight: FontWeight.w400,
                ),
                onCloseTap: () {
                  Get.back();
                  widget.onCancelTap?.call();
                },
              ),
              Gaps.getHeight(32.wh),
              ManageSelectWidget(
                title: "单元",
                hintText: '请选择单元',
                readOnly: false,
                required: true,
                value: _selectedUnitRes?.unitName?.trim() ?? '',
                options: _units.map((element) => element.unitName ?? '').toList(),
                onChanged: (String value, int index) {
                  final UnitResponseEntity entity = _units[index];
                  safeSetState(() {
                    _selectedUnitRes = entity;
                    _isOk = (_selectedUnitRes?.unitName?.trim() ?? '').isNotEmpty;
                  });
                },
              ),
              Gaps.getHeight(32.wh),
              _buildBottomWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff767E95),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 11.ww),
        ManageButton(
            text: "确认",
            width: 80.ww,
            height: 40.wh,
            color: _isOk ? const Color(0xff2388FF) : const Color(0xff353E5C),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: _isOk ? const Color(0xffEBEFF5) : const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
            onTap: OptimizeUtils.noneThrottle(() {
              final String unitName = _selectedUnitRes?.unitName?.trim() ?? "";
              final int? unitId = _selectedUnitRes?.unitId;
              if (unitName.isEmpty) {
                ToastUtils.showManageToast(text: '请选择单元');
                return;
              }

              if (unitId == null) {
                ToastUtils.showManageToast(text: '请选择单元');
                return;
              }

              final Map<String, dynamic> body = {
                "unitId": unitId,
                "unitName": unitName,
              };
              Get.back();
              widget.onOkTap?.call(body);
            }, 200))
      ],
    );
  }
}
