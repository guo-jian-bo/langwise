import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:ui_essentials/ui_essentials.dart';

class LearnCoreCellWidget extends StatelessWidget {
  final int index;
  final LearnCoreCell data;
  final ValueChanged<int> onDelete;

  const LearnCoreCellWidget({
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
          hintText: '英文',
          required: true,
          readOnly: false,
          height: 50.wh,
          controller: data.enController,
        )),
        Gaps.getWidth(12.ww),
        Expanded(
            child: ManageTitleInputWidget(
          title: "",
          hintText: '中文',
          required: true,
          readOnly: false,
          height: 50.wh,
          controller: data.zhController,
        )),
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
        key: const ValueKey('learnSelectDelete'),
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

class LearnCoreCell {
  final String uuid; // 唯一标识
  final TextEditingController zhController;
  final TextEditingController enController;

  LearnCoreCell({String? uuid, TextEditingController? zhController, TextEditingController? enController})
      : uuid = uuid ?? const Uuid().v6(),
        zhController = zhController ?? TextEditingController(text: ''),
        enController = enController ?? TextEditingController(text: '');

  LearnCoreCell copyWith({
    String? uuid,
    bool? isEditing,
    TextEditingController? zhController,
    TextEditingController? enController,
  }) {
    return LearnCoreCell(
        uuid: uuid ?? this.uuid,
        zhController: zhController ?? this.zhController,
        enController: enController ?? this.enController);
  }

  // 转换为JSON便于提交
  Map<String, dynamic> toJson() => {"zh": zhController.text.trim(), "en": enController.text.trim()};
}
