import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget_2.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:ui_essentials/ui_essentials.dart';

class DescriptionCellWidget extends StatelessWidget {
  final int index;
  final DescriptionCell data;
  final ValueChanged<int> onDelete;

  /// 语法结构选择回调，参数为：选中的值、选中的下标、组件的下标
  final Function(String, int, int) onSelectLanguage;

  /// 语言选项列表
  final List<String> languageOptions;

  const DescriptionCellWidget({
    super.key,
    required this.index,
    required this.data,
    required this.onDelete,
    required this.languageOptions,
    required this.onSelectLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ManageSelectWidget2(
          title: "语言",
          width: 137.ww,
          height: 50.wh,
          readOnly: false,
          hintText: '',
          value: data.languageText,
          options: languageOptions,
          onChanged: (String value, int i) {
            // 传递选中的值、选中的下标、组件的下标
            onSelectLanguage.call(value, i, index);
          },
        ),
        Gaps.getWidth(12.ww),
        Expanded(
          child: ManageTitleInputWidget(
            title: "",
            hintText: '请输入描述',
            required: true,
            readOnly: false,
            height: 50.wh,
            controller: data.descriptionController,
          ),
        ),
        if (enableDeleted) Gaps.getWidth(12.ww),
        if (enableDeleted) _buildDeleteWidget(),
      ],
    );
  }

  Widget _buildDeleteWidget() {
    return TapScaleWidget(
      onTap: () {
        onDelete.call(index);
      },
      child: Container(
        key: const ValueKey('descriptionSelectDelete'),
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

  bool get enableDeleted => index != 0;
}

class DescriptionCell {
  final String uuid; // 唯一标识

  final TextEditingController descriptionController;
  final String? language;

  DescriptionCell({String? uuid, TextEditingController? descriptionController, this.language})
      : uuid = uuid ?? const Uuid().v6(),
        descriptionController = descriptionController ?? TextEditingController();

  DescriptionCell copyWith({String? uuid, TextEditingController? descriptionController, String? language}) {
    return DescriptionCell(
        uuid: uuid ?? this.uuid,
        language: language ?? this.language,
        descriptionController: descriptionController ?? this.descriptionController);
  }

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

  // 转换为JSON便于提交
  Map<String, dynamic> toJson() => {"lang": language, "text": descriptionController.text};

// 是否编辑状态/默认正在编辑
  bool get isEditing => ObjectUtil.isEmpty(language) || descriptionController.text.isEmpty;
}
