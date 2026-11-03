import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../models/manage_exercise_quiz_model.dart';


class QuizJsonDialog extends StatefulWidget {
  const QuizJsonDialog({
    super.key, 
    required this.item,
    required this.clientJson,
    required this.serviceJson,
    this.onShowQuiz,
  });

  final ManageExerciseQuizModel item;
  final Map<String, dynamic> clientJson;
  final Map<String, dynamic> serviceJson;
  final void Function(bool showClient)? onShowQuiz;

  static Future<void> show({
    required BuildContext context, 
    required ManageExerciseQuizModel item,
    required Map<String, dynamic> clientJson,
    required Map<String, dynamic> serviceJson,
    void Function(bool showClient)? onShowQuiz,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.wMin)),
          child: QuizJsonDialog(item: item, clientJson: clientJson, serviceJson: serviceJson, onShowQuiz: onShowQuiz),
        );
      },
    );
  }

  @override
  State<QuizJsonDialog> createState() => _QuizJsonDialogState();
}

class _QuizJsonDialogState extends State<QuizJsonDialog> {
  /// true: 前端(clientJson), false: 后端(serviceJson)
  bool _showClient = true;

  /// Json 展示模式：base / collapsible
  JsonViewType _viewType = JsonViewType.base;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1200.ww,
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            '题目Json',
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.wMin),
          // 顶部切换按钮行：左侧前端/后端，右侧 base/collapsible
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Row(
            children: [
              _buildToggleButton(true, '前端'),
              SizedBox(width: 12.wMin),
              _buildToggleButton(false, '后端'),
                ],
              ),
              Row(
                children: [
                  _buildViewTypeButton(JsonViewType.base, 'base'),
                  SizedBox(width: 12.wMin),
                  _buildViewTypeButton(JsonViewType.collapsible, 'collapsible'),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          // JSON 区域
          Container(
            width: 1200.ww,
            height: 600.wh,
            padding: EdgeInsets.all(12.wMin),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(8.wMin),
              border: Border.all(color: const Color(0xFF4B5563), width: 1.wMin),
            ),
            child: SingleChildScrollView(
              child: _buildJsonView(),
            ),
          ),
          SizedBox(height: 20.wMin),
          // 底部按钮：关闭 / 演示
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  '关闭',
                  style: TextStyle(fontSize: 16.wMin, color: Colors.white),
                ),
              ),
              SizedBox(width: 12.wMin),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2388FF),
                  padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 10.wMin),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  widget.onShowQuiz?.call(_showClient);
                },
                child: Text(
                  '演示',
                  style: TextStyle(fontSize: 16.wMin, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewTypeButton(JsonViewType type, String label) {
    final bool selected = _viewType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF10B981) : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20.wMin),
          border: Border.all(
            color: selected ? const Color(0xFF6EE7B7) : const Color(0xFF4B5563),
            width: 1.wMin,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.wMin,
            color: Colors.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(bool isClient, String label) {
    final bool selected = _showClient == isClient;
    return GestureDetector(
      onTap: () {
        setState(() {
          _showClient = isClient;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2388FF) : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20.wMin),
          border: Border.all(
            color: selected ? const Color(0xFF60A5FA) : const Color(0xFF4B5563),
            width: 1.wMin,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.wMin,
            color: Colors.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildJsonView() {
    final Map<dynamic, dynamic> rawJson = _showClient ? widget.clientJson : widget.serviceJson;
    final Map<String, dynamic> json = Map<String, dynamic>.from(rawJson);

    if (json.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(fontSize: 16.wMin, color: const Color(0xFF9CA3AF)),
        ),
      );
    }

    return JsonView.map(json,theme: JsonViewTheme(
      viewType: _viewType
    ),);
  }
}

