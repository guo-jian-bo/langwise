import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_multi_select_widget.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget_2.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/manage_ipa_input_widget.dart';

class AssociateSemanticWidget extends StatelessWidget {
  final int index;
  final AssociateSemanticCell data;
  final ValueChanged<int> onDelete;

  /// 语言选择回调，参数为：选中的值、选中的下标、组件的下标
  final Function(String, int, int) onSelectLanguage;

  /// 口音选择回调
  final Function(List<int>, int) onSelectNationals;

  /// 类型选择回调
  final Function(String, int, int) onSelectRelationShipType;

  /// 备注更改回调
  final Function(String, int) onRemarkChanged;

  /// 语言选项列表
  final List<String> languageOptions;

  /// 口音选项列表
  final List<String> accentOptions;

  /// 关联类型选项列表
  final List<String> typeOptions;

  const AssociateSemanticWidget({
    super.key,
    required this.index,
    required this.data,
    required this.onDelete,
    required this.languageOptions,
    required this.accentOptions,
    required this.typeOptions,
    required this.onSelectLanguage,
    required this.onSelectNationals,
    required this.onSelectRelationShipType,
    required this.onRemarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // 语义ID输入框
            Expanded(
              child: ManageIPAInputWidget(
                title: "语义ID",
                height: 50.wh,
                hintText: '请输入语义ID',
                required: true,
                readOnly: true,
                controller: data.semanticIdController,
              ),
              flex: 1,
            ),
            Gaps.getWidth(12.ww),
            // 语言选择
            Expanded(
              child: ManageSelectWidget2(
                title: "语言",
                height: 50.wh,
                readOnly: false,
                hintText: '选择语言',
                value: data.languageText,
                options: languageOptions,
                onChanged: (String value, int i) {
                  onSelectLanguage.call(value, i, index);
                },
              ),
              flex: 1,
            ),

            Gaps.getWidth(12.ww),

            // 口音选择
            Expanded(
              child: ManageMultiSelectWidget(
                title: "口音",
                height: 50.wh,
                readOnly: false,
                hintText: '选择口音',
                options: accentOptions,
                // 使用模型方法获取口音值
                selectedValues: data.getNationalsValues(accentOptions),
                onChanged: (List<int> indexes) {
                  onSelectNationals.call(indexes, index);
                },
              ),
              flex: 1,
            ),
          ],
        ),
        Gaps.getHeight(12.ww),
        Row(
          children: [
            // 关联类型选择
            Expanded(
              child: ManageSelectWidget2(
                title: "关联类型",
                height: 50.wh,
                hintText: '请选择类型',
                required: true,
                readOnly: false,
                value: data.relationShipText,
                options: typeOptions,
                onChanged: (String value, int i) {
                  onSelectRelationShipType.call(value, i, index);
                },
              ),
              flex: 1,
            ),
            Gaps.getWidth(12.ww),
            // 备注
            Expanded(
              child: ManageIPAInputWidget(
                title: "备注",
                height: 50.wh,
                hintText: '请输入备注',
                required: true,
                readOnly: false,
                controller: data.remarkController,
                onChanged: (value) {
                  onRemarkChanged.call(value, index);
                },
              ),
              flex: 1,
            ),
            Gaps.getWidth(12.ww),
            Expanded(
              child: _buildDeleteWidget(),
              flex: 1,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDeleteWidget() {
    return TapScaleWidget(
      onTap: () {
        onDelete.call(index);
      },
      child: Container(
        key: const ValueKey('associateSemanticDelete'),
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

  bool get enableDeleted => index != 0;
}

class AssociateSemanticCell {
  final String uuid; // 唯一标识

  final TextEditingController semanticIdController;
  final String? language;
  final List<int> nationals; // 口音列表
  final EnEntitySemantics? entitySemantics;
  final String? relationShip; // 关联类型
  final TextEditingController remarkController; // 备注控制器

  AssociateSemanticCell(
      {String? uuid,
      TextEditingController? semanticIdController,
      this.language,
      List<int>? nationals,
      this.entitySemantics,
      this.relationShip,
      TextEditingController? remarkController})
      : uuid = uuid ?? const Uuid().v6(),
        semanticIdController = semanticIdController ?? TextEditingController(),
        remarkController = remarkController ?? TextEditingController(),
        nationals = nationals ?? [];

  AssociateSemanticCell copyWith({
    String? uuid,
    TextEditingController? semanticIdController,
    String? language,
    List<int>? nationals,
    EnEntitySemantics? entitySemantics,
    String? relationShip,
    TextEditingController? remarkController,
  }) {
    return AssociateSemanticCell(
        uuid: uuid ?? this.uuid,
        language: language ?? this.language,
        nationals: nationals ?? this.nationals,
        semanticIdController: semanticIdController ?? this.semanticIdController,
        entitySemantics: entitySemantics ?? this.entitySemantics,
        relationShip: relationShip ?? this.relationShip,
        remarkController: remarkController ?? this.remarkController);
  }

  /// 将口音索引转换为对应的口音值列表
  /// [options] 口音选项列表
  /// 返回有效的口音值列表，用于组件的selectedValues属性
  List<String>? getNationalsValues(List<String> options) {
    if (nationals.isEmpty) return null;
    return nationals
        .map((index) => index < options.length ? options[index] : '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // 转换为JSON便于提交
  Map<String, dynamic> toJson() => {
        "semanticId": semanticIdController.text.trim(),
        "relationShip": relationShip,
        "language": language,
        "note": remarkController.text.trim(),
        "nationals": nationals.isNotEmpty ? nationals : null,
      };

  // 是否编辑状态/是否有必填字段未填写
  bool get isEditing =>
      // 检查ID是否存在
      semanticIdController.text.trim().isEmpty ||
      // 检查语言是否选择
      language == null ||
      // 检查关联类型是否选择
      relationShip == null ||
      // 检查关联口音是否选择
      nationals.isEmpty ||
      // 检查备注是否填写
      remarkController.text.trim().isEmpty;

  // 语言
  String get languageText {
    String text = '';
    try {
      if (language != null) {
        int index = -1;
        for (int i = 0; i < CommonUtil.languageKeys.length; i++) {
          if (language == CommonUtil.languageKeys[i]) {
            index = i;
            break;
          }
        }

        text = CommonUtil.languageValues[index];
      }
    } catch (e) {
      print('---语言e:$e---');
    }

    return text;
  }

  // 关联类型文本
  String get relationShipText {
    String text = '';
    try {
      if (relationShip != null) {
        int index = -1;
        for (int i = 0; i < CommonUtil.semanticTypeKeys.length; i++) {
          if (relationShip == CommonUtil.semanticTypeKeys[i]) {
            index = i;
            break;
          }
        }

        text = CommonUtil.semanticTypeValues[index];
      }
    } catch (e) {
      print('---关联类型文本e:$e---');
    }

    return text;
  }

  @override
  String toString() {
    return 'AssociateSemanticCell{\n'
        '  uuid: $uuid,\n'
        '  semanticId: ${semanticIdController.text},\n'
        '  language: $language,\n'
        '  nationals: $nationals,\n'
        '  entitySemantics: ${entitySemantics?.uid},\n'
        '  relationShip: $relationShip,\n'
        '  remark: ${remarkController.text},\n'
        '  isEditing: $isEditing\n'
        '}';
  }
}
