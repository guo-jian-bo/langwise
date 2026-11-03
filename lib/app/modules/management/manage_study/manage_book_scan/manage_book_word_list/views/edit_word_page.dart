import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageEditWordManager {
  static Future<void>? show(
      {required BuildContext context,
      required UnitResponseEntity wordEntity,
      required int index,
      final Function(UnitResponseEntity)? onCancelTap,
      final Function(Map<String, dynamic>)? onCreateTap}) {
    return Get.dialog<void>(
      Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff040712).withValues(alpha: 0.8),
        child: UnconstrainedBox(
          alignment: Alignment.center,
          child: EditWordPage(
            wordEntity: wordEntity,
            index: index,
            onCancelTap: onCancelTap,
            onCreateTap: onCreateTap,
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

class EditWordPage extends StatefulWidget {
  final UnitResponseEntity wordEntity;
  final int index;
  final Function(UnitResponseEntity)? onCancelTap;
  final Function(Map<String, dynamic>)? onCreateTap;

  const EditWordPage({
    super.key,
    required this.wordEntity,
    required this.index,
    this.onCancelTap,
    this.onCreateTap,
  });

  @override
  State<EditWordPage> createState() => _EditWordPageState();
}

class _EditWordPageState extends State<EditWordPage> {
  final TextEditingController _lTextEditingController = TextEditingController();
  final TextEditingController _rTextEditingController = TextEditingController();

  String? _unitName, _wordTypeTitle;

  int _typeIndex = -1;

  bool get _hasType => _typeIndex != -1;

  // 词汇类型title
  final List<String> _allTypeTitles = KnowledgeType.values.map((element) => element.title).toList();

  // 词汇类型value
  final List<String> _allTypeValues = KnowledgeType.values.map((element) => element.value).toList();

  @override
  void initState() {
    super.initState();
    _unitName = widget.wordEntity.unitName;
    _allTypeTitles.removeLast();
    _allTypeValues.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 720.ww,
        height: 416.wh,
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(24.ww),
          decoration: BoxDecoration(
            color: const Color(0xff181B25),
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            physics: const ScrollPhysics(),
            child: Column(
              children: [
                ManageTitleWidget(
                  title: '词汇',
                  textStyle: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                  onCloseTap: () {
                    Get.back();
                    widget.onCancelTap?.call(widget.wordEntity);
                  },
                ),
                Gaps.getHeight(32.wh),
                Row(
                  children: [
                    Expanded(
                      child: ManageTitleInputWidget(
                        title: "英文",
                        hintText: '请输入英文',
                        controller: _lTextEditingController,
                        readOnly: false,
                      ),
                      flex: 1,
                    ),
                    Gaps.getWidth(32.ww),
                    Expanded(
                      child: ManageTitleInputWidget(
                        title: "释义",
                        hintText: '请输入释义',
                        controller: _rTextEditingController,
                        readOnly: false,
                      ),
                      flex: 1,
                    ),
                  ],
                ),
                Gaps.getHeight(32.wh),
                Row(
                  children: [
                    Expanded(
                      child: ManageSelectWidget(
                        title: "单元名",
                        hintText: '请选择单元',
                        value: _unitName,
                        readOnly: true,
                        options: [],
                      ),
                      flex: 1,
                    ),
                    Gaps.getWidth(32.ww),
                    Expanded(
                      child: ManageSelectWidget(
                        title: "词汇类型",
                        hintText: '请选择词汇类型',
                        value: _wordTypeTitle,
                        readOnly: false,
                        options: _allTypeTitles,
                        onChanged: (String value, int index) {
                          // 设置词汇类型
                          _typeIndex = index;
                        },
                      ),
                      flex: 1,
                    ),
                  ],
                ),
                Gaps.getHeight(60.wh),
                _buildBottomWidget()
              ],
            ),
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
            text: "创建",
            width: 80.ww,
            height: 40.wh,
            color: const Color(0xff353E5C),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
            onTap: OptimizeUtils.noneThrottle(() {
              final String content = _lTextEditingController.text.trim();
              if (content.isEmpty) {
                ToastUtils.showManageToast(text: '请填写英文');
                return;
              }

              final String definition = _rTextEditingController.text.trim();
              if (definition.isEmpty) {
                ToastUtils.showManageToast(text: '请填写释义');
                return;
              }

              if (!_hasType) {
                ToastUtils.showManageToast(text: '请选择词汇类型');
                return;
              }

              final Map<String, dynamic> body = {
                "unitId": widget.wordEntity.unitId,
                "content": content,
                "definition": definition,
                "contentType": _allTypeValues[_typeIndex],
                "index": widget.index
              };
              Get.back();
              widget.onCreateTap?.call(body);
            }, 200))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _lTextEditingController.dispose();
    _rTextEditingController.dispose();
  }
}
