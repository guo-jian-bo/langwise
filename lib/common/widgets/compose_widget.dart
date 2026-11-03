import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ComposeCellWidget extends StatelessWidget {
  final int index;
  final ComposeCell data;
  final ValueChanged<int> onDelete;
  final Function(int, ComposeCell) onSelectKnowledge;

  const ComposeCellWidget({
    super.key,
    required this.index,
    required this.data,
    required this.onDelete,
    required this.onSelectKnowledge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: ManageTitleInputWidget(
          title: "",
          hintText: '知识点',
          required: true,
          readOnly: true,
          height: 50.wh,
          controller: data.knowledgeController,
        )),
        Gaps.getWidth(12.ww),
        ManageTitleInputWidget(
          title: "",
          hintText: '位置',
          required: true,
          readOnly: true,
          height: 50.wh,
          width: 160.ww,
          controller: data.positionController,
        ),
        Gaps.getWidth(12.ww),
        // 知识点选择
        _buildKnowledgeSelector(),
        Gaps.getWidth(12.ww),
        _buildDeleteWidget(),
      ],
    );
  }

  Widget _buildKnowledgeSelector() {
    return TapScaleWidget(
      onTap: () {
        onSelectKnowledge.call(index, data);
      },
      child: Container(
        key: const ValueKey('composeSelectKnowledge'),
        width: 160.ww,
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
          "选择知识点",
          style: TextStyleExtension.ts_14_w400_BAC0CC,
        ),
      ),
    );
  }

  Widget _buildDeleteWidget() {
    return TapScaleWidget(
      onTap: () {
        onDelete.call(index);
      },
      child: Container(
        key: const ValueKey('composeSelectDelete'),
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

class ComposeCell {
  final String uuid; // 唯一标识
  final String selectedKnowledge; // 选中的知识点
  final List<int?> position; // 位置序号
  // 是否编辑状态/默认正在编辑
  final bool isEditing;
  final TextEditingController knowledgeController;
  final TextEditingController positionController;
  final Knowledge? knowledge;

  ComposeCell(
      {String? uuid,
      this.selectedKnowledge = '',
      this.position = const [],
      this.isEditing = true,
      TextEditingController? knowledgeController,
      TextEditingController? positionController,
      this.knowledge})
      : uuid = uuid ?? const Uuid().v6(),
        knowledgeController = knowledgeController ?? TextEditingController(text: selectedKnowledge),
        positionController = positionController ?? TextEditingController(text: position.join(","));

  ComposeCell copyWith(
      {String? uuid,
      String? selectedKnowledge,
      List<int>? position,
      bool? isEditing,
      TextEditingController? knowledgeController,
      TextEditingController? positionController,
      Knowledge? knowledge}) {
    return ComposeCell(
        uuid: uuid ?? this.uuid,
        // 保留原值或覆盖新值
        selectedKnowledge: selectedKnowledge ?? this.selectedKnowledge,
        position: position ?? this.position,
        isEditing: isEditing ?? this.isEditing,
        knowledgeController: knowledgeController ?? this.knowledgeController
          ..text = selectedKnowledge ?? '',
        positionController: positionController ?? this.positionController
          ..text = (position ?? this.position).join(","),
        knowledge: knowledge ?? this.knowledge);
  }

  // 转换为JSON便于提交
  Map<String, dynamic> toJson() => {
        "content": knowledge?.content,
        "contentId": knowledge?.uid,
        "semanticId": knowledge?.semanticId,
        'positions': position
      };
}
