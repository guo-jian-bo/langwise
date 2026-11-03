import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/cron_builder_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/manage_new_crowd_controller.dart';

class ManageUserTagCreateDialog {
  static Future<bool?> show({
    required BuildContext context,
  }) async {
    return await showDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ManageUserTagCreateDialogWidget(),
    );
  }
}

class ManageUserTagCreateDialogWidget extends StatefulWidget {
  const ManageUserTagCreateDialogWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return ManageUserTagCreateDialogWidgetState();
  }
}

class ManageUserTagCreateDialogWidgetState extends State<ManageUserTagCreateDialogWidget> {
  static const Color _bg = Color(0xFF22293C);
  static const Color _panel = Color(0xFF0B1221);
  static const Color _panel2 = Color(0xFF0E172A);
  static const Color _border = Color(0x1FFFFFFF);
  static const Color _text = Color(0xFFEBEEF3);
  static const Color _text2 = Color(0xFFACB4C0);
  static const Color _primary = Color(0xFF2388FF);

  // final ManageUserEditorController editor = Get.find<ManageUserEditorController>();
  // late final ManageUserController userController = editor.userController;

  late final Rx<TagTriggerTypeEnum> tmpTagType;
  late final Rx<ActivateTimeEnum> tmpActivateTime;
  late final Rx<ActivityTagDurationType> tmpDurationType;
  late final TextEditingController tmpDurationCtrl;

  TagTypeEnum _tagType = TagTypeEnum.FILTER;
  ActivateTimeEnum _activateTime = ActivateTimeEnum.TIMELIMIT;

  @override
  void initState() {
    super.initState();
    // tmpTagType = editor.tagTriggerType.value.obs;
    // _tagType = editor.tagType.value;
    // tmpActivateTime = editor.activateTime.value.obs;
    // tmpDurationType = editor.durationType.value.obs;
    // tmpDurationCtrl = TextEditingController(text: editor.duration.value.toString());
  }

  @override
  void dispose() {
    tmpDurationCtrl.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.wMin),
      child: Text(
        required ? '$text *' : text,
        style: TextStyle(color: _text, fontSize: 13.wMin, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBox({required Widget child, double? height}) {
    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 10.wMin),
      decoration: BoxDecoration(
        color: _panel2,
        borderRadius: BorderRadius.circular(10.wMin),
        border: Border.all(color: _border, width: 1.wMin),
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? hint,
    bool enabled = true,
    int? maxLines,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      style: TextStyle(color: _text, fontSize: 13.wMin),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintText: hint,
        hintStyle: TextStyle(color: _text2, fontSize: 13.wMin),
      ),
    );
  }

  Widget _tagTypeDropdown() {
    String label(TagTriggerTypeEnum v) {
      switch (v) {
        case TagTriggerTypeEnum.onetime:
          return '一次性';
        case TagTriggerTypeEnum.manual:
          return '手动执行';
        case TagTriggerTypeEnum.realtime:
          return '实时触发';
        case TagTriggerTypeEnum.scheduled:
          return '定时批量';
      }
    }

    final items = TagTriggerTypeEnum.values
        .map(
          (e) => DropdownMenuItem<TagTriggerTypeEnum>(
            value: e,
            child: Text(label(e), style: TextStyle(color: _text, fontSize: 13.wMin)),
          ),
        )
        .toList();

    return Obx(() {
      return DropdownButtonHideUnderline(
        child: DropdownButton<TagTriggerTypeEnum>(
          value: tmpTagType.value,
          dropdownColor: _panel,
          items: items,
          isDense: true,
          iconEnabledColor: _text2,
          onChanged: (v) {
            if (v == null) return;
            tmpTagType.value = v;
            setState(() {});
          },
        ),
      );
    });
  }

  Widget _durationTypeDropdown() {
    String label(ActivityTagDurationType v) {
      switch (v) {
        case ActivityTagDurationType.day:
          return '日';
        case ActivityTagDurationType.week:
          return '星期';
        case ActivityTagDurationType.month:
          return '月';
        case ActivityTagDurationType.quarter:
          return '季';
        case ActivityTagDurationType.year:
          return '年';
      }
    }

    final items = ActivityTagDurationType.values
        .map(
          (e) => DropdownMenuItem<ActivityTagDurationType>(
            value: e,
            child: Text(label(e), style: TextStyle(color: _text, fontSize: 13.wMin)),
          ),
        )
        .toList();

    return Obx(() {
      return DropdownButtonHideUnderline(
        child: DropdownButton<ActivityTagDurationType>(
          value: tmpDurationType.value,
          dropdownColor: _panel,
          items: items,
          isDense: true,
          iconEnabledColor: _text2,
          onChanged: (v) {
            if (v == null) return;
            tmpDurationType.value = v;
            setState(() {});
          },
        ),
      );
    });
  }

  Widget _tagCategoryDropdown() {
    String label(TagTypeEnum v) {
      switch (v) {
        case TagTypeEnum.TASK:
          return '任务标签';
        case TagTypeEnum.FILTER:
          return '筛选标签';
      }
    }

    final items = TagTypeEnum.values
        .map(
          (e) => DropdownMenuItem<TagTypeEnum>(
            value: e,
            child: Text(label(e), style: TextStyle(color: _text, fontSize: 13.wMin)),
          ),
        )
        .toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton<TagTypeEnum>(
        value: _tagType,
        dropdownColor: _panel,
        items: items,
        isDense: true,
        iconEnabledColor: _text2,
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _tagType = v;
          });
        },
      ),
    );
  }

  Widget _activateTimeDropdown() {
    String label(ActivateTimeEnum v) {
      switch (v) {
        case ActivateTimeEnum.FOREVER:
          return '永久标签';
        case ActivateTimeEnum.TIMELIMIT:
          return '时限性';
      }
    }

    final items = ActivateTimeEnum.values
        .map(
          (e) => DropdownMenuItem<ActivateTimeEnum>(
            value: e,
            child: Text(label(e), style: TextStyle(color: _text, fontSize: 13.wMin)),
          ),
        )
        .toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton<ActivateTimeEnum>(
        value: _activateTime,
        dropdownColor: _panel,
        items: items,
        isDense: true,
        iconEnabledColor: _text2,
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _activateTime = v;
          });
        },
      ),
    );
  }

  void _onConfirm() {
    // editor.tagTriggerType.value = tmpTagType.value;
    // editor.tagType.value = _tagType;
    // editor.activateTime.value = _activateTime;
    // editor.durationType.value = tmpDurationType.value;
    // editor.duration.value = int.tryParse(tmpDurationCtrl.text.trim()) ?? 0;
    Navigator.of(context).pop(true);
  }

  void _onCancel() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final showTagTriggerType = _tagType != TagTypeEnum.TASK;
    final showDuration = _activateTime != ActivateTimeEnum.FOREVER;
    final needCron = showTagTriggerType && tmpTagType.value == TagTriggerTypeEnum.scheduled;

    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Container(
          width: 840.wMin,
          height: 900.wMin,
          padding: EdgeInsets.all(22.wMin),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(color: _border, width: 1.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('完成标签创建', style: TextStyle(color: _text, fontSize: 18.wMin, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          InkWell(
                            onTap: _onCancel,
                            child: Icon(Icons.close, color: _text2, size: 20.wMin),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.wMin),
                      Divider(height: 1.wMin, color: _border),
                      SizedBox(height: 18.wMin),
                      _buildLabel('标签名称', required: true),
                      _buildBox(
                        child: _buildTextField(
                          // controller: editor.nameCtrl,
                          hint: '请输入标签名称，不超过30字',
                        ),
                      ),
                      SizedBox(height: 16.wMin),
                      _buildLabel('业务描述'),
                      _buildBox(
                        height: 86.wMin,
                        child: _buildTextField(
                          // controller: editor.remarkCtrl,
                          hint: '描述业务用途...',
                          maxLines: 4,
                        ),
                      ),
                      SizedBox(height: 16.wMin),
                      _buildLabel('标签CODE'),
                      _buildBox(
                        child: _buildTextField(
                          // controller: editor.codeCtrl,
                          // enabled: !editor.isEdit,
                          // hint: editor.isEdit ? null : '请输入标签 CODE',
                        ),
                      ),
                      SizedBox(height: 16.wMin),
                      _buildLabel('激活时间'),
                      _buildBox(child: _activateTimeDropdown()),
                      if (showDuration) ...[
                        SizedBox(height: 16.wMin),
                        _buildLabel('有效期', required: true),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBox(
                                child: _buildTextField(
                                  controller: tmpDurationCtrl,
                                  keyboardType: TextInputType.number,
                                  hint: '请输入',
                                ),
                              ),
                            ),
                            SizedBox(width: 12.wMin),
                            Expanded(
                              child: _buildBox(
                                child: _durationTypeDropdown(),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 16.wMin),
                      _buildLabel('标签类别'),
                      _buildBox(child: _tagCategoryDropdown()),
                      if (showTagTriggerType) ...[
                        SizedBox(height: 16.wMin),
                        _buildLabel('执行类型'),
                        _buildBox(child: _tagTypeDropdown()),
                      ],
                      SizedBox(height: 12.wMin),
                      if (needCron) ...[
                        _buildLabel('定时策略'),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.wMin),
                          decoration: BoxDecoration(
                            color: _panel2,
                            borderRadius: BorderRadius.circular(10.wMin),
                            border: Border.all(color: _border, width: 1.wMin),
                          ),
                          child: CronBuilderWidget(
                            // initialCron: editor.cronCtrl.text.trim(),
                            onChanged: (cron) {
                              // editor.cronCtrl.text = cron;
                            },
                          ),
                        ),
                        SizedBox(height: 12.wMin),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 6.wMin),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _onCancel,
                      child: Container(
                        height: 44.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _panel2,
                          borderRadius: BorderRadius.circular(10.wMin),
                          border: Border.all(color: _border, width: 1.wMin),
                        ),
                        child: Text('取消', style: TextStyle(color: _text, fontSize: 14.wMin, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.wMin),
                  Expanded(
                    child: InkWell(
                      onTap: _onConfirm,
                      child: Container(
                        height: 44.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(10.wMin),
                        ),
                        child: Text('确定创建', style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
