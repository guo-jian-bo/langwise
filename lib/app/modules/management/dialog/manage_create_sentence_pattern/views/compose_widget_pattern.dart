import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget_2.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ComposeCellPatternWidget extends StatelessWidget {
  final int index;
  final ComposeCellPattern data;
  final ValueChanged<int> onDelete;
  final Function(int, int) onSelectKnowledgeStatus;

  /// 语法结构选择回调，参数为：选中的值、选中的下标、组件的下标
  final Function(String, int, int) onSelectGrammar;
  final Function(int, ComposeCellPattern) onSelectKnowledge;

  /// 语法结构选项列表
  final List<String> grammarOptions;

  const ComposeCellPatternWidget({
    super.key,
    required this.index,
    required this.data,
    required this.onDelete,
    required this.onSelectKnowledgeStatus,
    required this.onSelectKnowledge,
    required this.grammarOptions,
    required this.onSelectGrammar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧的“是否知识点”选择器，不参与翻转
        ManageSelectWidget2(
          title: "是否知识点",
          height: 50.wh,
          width: 204.ww,
          readOnly: false,
          hintText: '',
          value: CommonUtil.knowledgeOptions.first.title,
          options: CommonUtil.knowledgeOptions.map((element) => element.title).toList(),
          onChanged: (String value, int i) {
            onSelectKnowledgeStatus.call(i, index);
          },
        ),
        Gaps.getWidth(12.ww),

        // 中间部分使用翻转动画过渡
        Expanded(
          child: FlipAnimationWidget(
            isFlipped: data.isKnowledge,
            duration: const Duration(milliseconds: 300),
            direction: Axis.vertical,
            // 语法结构选择器（正面）
            frontWidget: ManageSelectWidget2(
              title: "语法结构",
              height: 50.wh,
              readOnly: false,
              hintText: '',
              value: data.grammar?.newTitle,
              options: grammarOptions,
              onChanged: (String value, int i) {
                // 传递选中的值、选中的下标、组件的下标
                onSelectGrammar.call(value, i, index);
              },
            ),
            // 知识点输入和选择器（背面）
            backWidget: Row(
              children: [
                Expanded(
                  child: ManageTitleInputWidget(
                    title: "",
                    hintText: '知识点',
                    required: true,
                    readOnly: true,
                    height: 50.wh,
                    controller: data.knowledgeController,
                  ),
                ),
                Gaps.getWidth(12.ww),
                _buildKnowledgeSelector(),
              ],
            ),
          ),
        ),

        Gaps.getWidth(12.ww),
        // 右侧的“删除”按钮，不参与翻转
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

class ComposeCellPattern {
  final String uuid; // 唯一标识
  final String selectedKnowledge; // 选中的知识点
  // 是否编辑状态/默认正在编辑
  final bool isEditing;

  // 是否知识点
  final bool isKnowledge;
  final TextEditingController knowledgeController;
  final Knowledge? knowledge;
  final ConfigEntityGrammar? grammar;

  ComposeCellPattern(
      {String? uuid,
      this.selectedKnowledge = '',
      this.isEditing = true,
      this.isKnowledge = false,
      TextEditingController? knowledgeController,
      this.knowledge,
      this.grammar})
      : uuid = uuid ?? const Uuid().v6(),
        knowledgeController = knowledgeController ?? TextEditingController(text: selectedKnowledge);

  ComposeCellPattern copyWith(
      {String? uuid,
      String? selectedKnowledge,
      bool? isEditing,
      bool? isKnowledge,
      TextEditingController? knowledgeController,
      Knowledge? knowledge,
      ConfigEntityGrammar? grammar}) {
    return ComposeCellPattern(
        uuid: uuid ?? this.uuid,
        // 保留原值或覆盖新值
        selectedKnowledge: selectedKnowledge ?? this.selectedKnowledge,
        isEditing: isEditing ?? this.isEditing,
        isKnowledge: isKnowledge ?? this.isKnowledge,
        knowledgeController: knowledgeController ?? this.knowledgeController
          ..text = selectedKnowledge ?? this.selectedKnowledge,
        knowledge: knowledge ?? this.knowledge,
        grammar: grammar ?? this.grammar);
  }

  // 转换为JSON便于提交
  Map<String, dynamic> toJson() => {
        "core": isKnowledge,
        "content": knowledge?.content,
        "contentId": knowledge?.uid,
        "contentType": knowledge?.contentType,
        "semanticId": knowledge?.semanticId,
        "component": grammar?.grammar,
      };
}
