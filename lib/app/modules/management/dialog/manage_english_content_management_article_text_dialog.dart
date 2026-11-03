import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/common/entities/en_text_entity.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/status_tag_widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageEnglishContentManagementArticleTextDialog {
  static Future<void> show({
    required BuildContext context,
    required EnTextEntity item,
  }) async {
    return await showCupertinoDialog<void>(
      context: context,
      builder: (context) => ManageEnglishContentManagementArticleTextDialogWidget(item: item),
    );
  }
}

class ManageEnglishContentManagementArticleTextDialogWidget extends StatefulWidget {
  final EnTextEntity item;
  const ManageEnglishContentManagementArticleTextDialogWidget({super.key, required this.item});

  @override
  State<ManageEnglishContentManagementArticleTextDialogWidget> createState() => _ManageEnglishContentManagementArticleTextDialogWidgetState();
}

class _ManageEnglishContentManagementArticleTextDialogWidgetState extends State<ManageEnglishContentManagementArticleTextDialogWidget> {
  @override
  void initState() {
    super.initState();
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
          width: 1200.ww,
          height: 800.wh,
          child: Padding(
              padding: EdgeInsets.all(15.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title ?? '',
                    style: TextStyle(fontSize: 24.wMin, color: Colors.white),
                  ),
                  SizedBox(height: 20.wMin),
                  Row(
                    children: [
                      buildDifficultyWidget(),
                      SizedBox(width: 20.wMin),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(35, 136, 255, 0.30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '主题:${widget.item.theme ?? ''}',
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: const Color.fromRGBO(35, 136, 255, 1),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.wMin),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(99, 222, 119, 0.20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '体裁:${widget.item.genre ?? ''}',
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: const Color.fromRGBO(99, 222, 119, 1),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.wMin),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                        decoration: BoxDecoration(
                          color: const Color(0xFF767E95),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.item.knowledge?.length ?? 0}词',
                          style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.wMin),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20.wMin),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23253A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          widget.item.content ?? '',
                          style: TextStyle(fontSize: 24.wMin, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.wMin),
                  _buildBottomWidget(),
                ],
              )),
        ),
      ),
    );
  }

  Widget buildDifficultyWidget() {
    if (widget.item.difficulty?['min'] == widget.item.difficulty?['max']) {
      return StatusTagDifficultyWidget(
        difficulty: widget.item.difficulty?['min'],
        language: Get.find<ConfigController>().userSetting.value.learningLang,
      );
    }

    return Row(
      children: [
        StatusTagDifficultyWidget(
          difficulty: widget.item.difficulty?['min'],
          language: Get.find<ConfigController>().userSetting.value.learningLang,
        ),
        SizedBox(width: 5.wMin),
        Text(
          "-",
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xff697179),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 5.wMin),
        StatusTagDifficultyWidget(
          difficulty: widget.item.difficulty?['max'],
          language: Get.find<ConfigController>().userSetting.value.learningLang,
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy-MM-dd");
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '创建日期:${_formatDate(widget.item.created)}',
          style: TextStyle(fontSize: 16.wMin, color: Colors.white),
        ),
        ManageButton(
          text: "关闭",
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
            Get.back();
          },
        ),
      ],
    );
  }
}
