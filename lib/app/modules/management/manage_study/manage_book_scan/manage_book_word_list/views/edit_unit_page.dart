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

class ManageEditUnitManager {
  static Future<void>? show(
      {required BuildContext context,
      required UnitResponseEntity defaultEntity,
      final Function(UnitResponseEntity)? onCancelTap,
      final Function(Map<String, dynamic>)? onOkTap}) {
    return Get.dialog<void>(
      Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff040712).withValues(alpha: 0.8),
        child: UnconstrainedBox(
          alignment: Alignment.center,
          child: EditUnitPage(
            defaultEntity: defaultEntity,
            onCancelTap: onCancelTap,
            onOkTap: onOkTap,
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      print('---编辑单词弹框消失---');
      return value;
    });
  }
}

class EditUnitPage extends StatefulWidget {
  final UnitResponseEntity defaultEntity;
  final Function(UnitResponseEntity)? onCancelTap;
  final Function(Map<String, dynamic>)? onOkTap;

  const EditUnitPage({super.key, required this.defaultEntity, this.onCancelTap, this.onOkTap});

  @override
  State<EditUnitPage> createState() => _EditUnitPageState();
}

class _EditUnitPageState extends State<EditUnitPage> with SafeSetStateMixin {
  bool _isOk = false;

  UnitResponseEntity? _selectedUnitRes;

  List<UnitResponseEntity> _units = [];

  @override
  void initState() {
    super.initState();
    _selectedUnitRes = widget.defaultEntity;
    _isOk = (_selectedUnitRes?.unitName?.trim() ?? '').isNotEmpty;
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
                  widget.onCancelTap?.call(widget.defaultEntity);
                },
              ),
              Gaps.getHeight(32.wh),
              ManageSelectWidget(
                title: "单元",
                hintText: '请选择单元',
                value: _selectedUnitRes?.unitName?.trim() ?? '',
                readOnly: false,
                required: true,
                options: _units.map((element) => element.unitName ?? '').toList(),
                onChanged: (String value, int index) {
                  final UnitResponseEntity entity = _units[index];
                  safeSetState(() {
                    _selectedUnitRes = entity;
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
                "oldUid": widget.defaultEntity.uid,
                "oldUnitId": widget.defaultEntity.unitId,
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
