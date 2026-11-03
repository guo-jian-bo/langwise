import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_content_input_widget.dart';
import 'package:quiz_play/models/quiz_model.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageEditQuizOptionInterpretationDialog {
  static Future<List<QuizModelOptionsExplanation?>?> show({
    required BuildContext context,
    String? title,
    List<QuizModelOptionsExplanation?>? explanationList,
  }) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => ManageEditQuizOptionInterpretationDialogWidget(
        title: title,
        explanationList: explanationList,
      ),
    );
  }
}

class ManageEditQuizOptionInterpretationDialogWidget extends StatefulWidget {
  final String? title;
  final List<QuizModelOptionsExplanation?>? explanationList;
  const ManageEditQuizOptionInterpretationDialogWidget({super.key, required this.title, required this.explanationList});

  @override
  State<ManageEditQuizOptionInterpretationDialogWidget> createState() => _ManageEditQuizOptionInterpretationDialogWidgetState();
}

class _ManageEditQuizOptionInterpretationDialogWidgetState extends State<ManageEditQuizOptionInterpretationDialogWidget> {
  List<TextEditingController> textFieldList = [];
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.explanationList!.length; i++) {
      textFieldList.add(TextEditingController(text: widget.explanationList![i]?.text ?? ''));
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < textFieldList.length; i++) {
      textFieldList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.ww, vertical: 30.wh),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(
              color: const Color(0xff444B5F),
              width: 1.wMin, // 边框宽度
            ),
            color: const Color(0xff181B25),
          ),
          width: 700.ww,
          height: 900.wh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '编辑${widget.title ?? ''}的解析',
                style: TextStyle(fontSize: 20.wMin, color: Colors.white),
              ),
              SizedBox(height: 20.wMin),
              Expanded(
                child: _buildContentWidget(),
              ),
              SizedBox(height: 30.wMin),
              _buildBottomWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.wMin, vertical: 15.wMin),
      decoration: BoxDecoration(
        color: const Color(0xFF23253A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '语言 (${widget.explanationList?.length ?? 0})',
              style: TextStyle(fontSize: 20.wMin, color: Colors.white),
            ),
            ...widget.explanationList!.map((e) => _buildTextFieldWidget(e)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWidget(QuizModelOptionsExplanation? item) {
    int index = widget.explanationList!.indexOf(item);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              item?.lang ?? '',
              style: TextStyle(fontSize: 20.wMin, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        ManageContentInputWidget(
          hintText: '请填写解析',
          required: true,
          controller: textFieldList[index],
          height: 160.wh,
          maxLines: 500,
          padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 12.ww),
          onChanged: (value) {
            widget.explanationList![index]?.text = value;
          },
        ),
        SizedBox(height: 30.wMin),
      ],
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
          borderColor: const Color(0xff666F8D),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 15.wMin),
        ManageButton(
          text: "保存更改",
          width: 80.ww,
          height: 40.wh,
          color: const Color(0xff2388FF),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 14.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back(result: widget.explanationList);
          },
        ),
      ],
    );
  }
}
