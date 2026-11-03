import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 位置规则组件，类似于LearnCoreCellWidget，但只有一个输入框
class PositionRuleCellWidget extends StatelessWidget {
  final int index;
  final PositionRuleCell data;
  final ValueChanged<int> onDelete;

  const PositionRuleCellWidget({
    super.key,
    required this.index,
    required this.data,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ManageTitleInputWidget(
            title: "",
            hintText: '位置规则',
            required: true,
            readOnly: false,
            height: 50.wh,
            controller: data.ruleController,
          ),
        ),
        Gaps.getWidth(12.ww),
        _buildDeleteWidget(),
      ],
    );
  }

  Widget _buildDeleteWidget() {
    return TapScaleWidget(
      onTap: () {
        onDelete.call(index);
      },
      child: Container(
        key: const ValueKey('positionRuleDelete'),
        width: 106.ww,
        height: 50.wh,
        // 右侧间距
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          border: Border.all(
            color: const Color(0xff4B5268),
            width: 1.wMin,
          ),
          color: const Color(0xff353E5C),
        ),
        alignment: Alignment.center,
        child: Text(
          "删除",
          style: TextStyleExtension.ts_14_w400_BAC0CC,
        ),
      ),
    );
  }
}

/// 位置规则数据模型
class PositionRuleCell {
  final String uuid; // 唯一标识
  final TextEditingController ruleController;

  PositionRuleCell({String? uuid, TextEditingController? ruleController})
      : uuid = uuid ?? const Uuid().v6(),
        ruleController = ruleController ?? TextEditingController(text: '');

  PositionRuleCell copyWith({
    String? uuid,
    TextEditingController? ruleController,
  }) {
    return PositionRuleCell(
      uuid: uuid ?? this.uuid,
      ruleController: ruleController ?? this.ruleController,
    );
  }

  // 转换为JSON便于提交
  Map<String, dynamic> toJson() => {"rule": ruleController.text.trim()};

  String get newRuleString => ruleController.text.trim();
}
