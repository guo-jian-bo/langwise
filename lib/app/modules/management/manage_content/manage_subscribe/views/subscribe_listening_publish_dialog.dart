import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/common/entities/article_entity.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class SubscribeListeningPublishDialog {
  static Future<bool?> show({
    required BuildContext context,
    required ArticleEntity articleEntity,
    required int collectionId,
  }) async {
    return await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) => _SubscribeListeningPublishDialogWidget(
        entity: articleEntity,
        collectionId: collectionId,
      ),
    );
  }
}

class _SubscribeListeningPublishDialogWidget extends StatefulWidget {
  final ArticleEntity entity;
  final int collectionId;

  const _SubscribeListeningPublishDialogWidget({
    required this.entity,
    required this.collectionId,
  });

  @override
  State<_SubscribeListeningPublishDialogWidget> createState() => _SubscribeListeningPublishDialogWidgetState();
}

class _SubscribeListeningPublishDialogWidgetState extends State<_SubscribeListeningPublishDialogWidget> {
  late String _content;
  late String _title;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController fontSizeController = TextEditingController();
  bool _isSubmit = false;

  @override
  void initState() {
    super.initState();
    _content = widget.entity.lyrics ?? '';
    _title = widget.entity.title ?? '';
    titleController.text = _title;
    contentController.text = _content;
    fontSizeController.text = '$fontSize';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
        body: Center(
          child: Container(
            width: 1080.ww,
            height: 980.wh,
            padding: EdgeInsets.symmetric(vertical: 24.wh),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                border: Border.all(
                  color: const Color(0xff444B5F),
                  width: 1.wMin,
                ),
                color: AppTheme.cSurfaceSecondary),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gaps.getHeight(15.wh),
                Row(
                  children: [
                    SizedBox(width: 24.ww),
                    SvgPicture.asset('assets/svg/user_center/icon_preference_study.svg', width: 46.wMin, height: 46.wMin),
                    SizedBox(width: 16.wMin),
                    Text(
                      '编辑文章内容',
                      style: TextStyle(fontSize: 28.wMin, color: Colors.white),
                    ),
                    const Spacer(),
                    GestureDetector(onTap: () => Get.back(), child: SvgPicture.asset('assets/svg/public/x.svg', width: 46.wMin, height: 46.wMin)),
                    SizedBox(width: 24.ww),
                  ],
                ),
                Gaps.getHeight(15.wh),
                Divider(height: 1.wMin, color: AppTheme.cBorderSecondary.color),
                Gaps.getHeight(20.wh),
                _buildContentWidget(context),
                const Spacer(),
                _buildBottomWidget(),
              ],
            ),
          ),
        ),
      );
    });
  }

  int fontSize = 28;

  /// 主视图
  Widget _buildContentWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  TextSpan(text: '文章标题', style: TextStyle(color: AppTheme.cTextQuaternary.color)),
                ],
              ),
            ),
            SizedBox(height: 8.wMin),
            SizedBox(
              height: 100.wMin,
              child: TextField(
                controller: titleController,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(fontSize: 32.wMin, color: Colors.white),
                decoration: InputDecoration(
                  hintText: '输入标题',
                  fillColor: const Color(0xFF393F5A).withOpacity(.35),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24.wMin,
                    vertical: 16.wMin,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 16.wMin,
                    color: Colors.white54,
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.wMin),
                    borderSide: const BorderSide(color: Color(0xFF4B5268)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.wMin),
                    borderSide: const BorderSide(color: Color(0xFF2388FF)),
                  ),
                ),
              ),
            ),
            Gaps.getHeight(24.wh),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      const TextSpan(
                        text: '* ',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      TextSpan(text: '文章内容', style: TextStyle(color: AppTheme.cTextQuaternary.color)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '字体大小:',
                  style: TextStyle(fontSize: 28.wMin, color: AppTheme.cTextQuaternary.color),
                ),
                GestureDetector(
                    onTap: () {
                      if (fontSize < 14) return;
                      fontSize -= 2;
                      setState(() {
                        fontSizeController.text = '$fontSize';
                      });
                    },
                    child: Container(
                        height: 44.wMin,
                        width: 44.wMin,
                        margin: EdgeInsets.symmetric(horizontal: 8.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.wMin),
                          color: const Color(0xFF353E5C),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/svg/user_center/icon_ninus.svg',
                          color: AppTheme.cTextTertiary,
                        ))),
                SizedBox(
                  width: 30.wMin,
                  child: TextField(
                      controller: fontSizeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null) return;
                        setState(() {
                          fontSize = parsed;
                        });
                      },
                      onSubmitted: (value) {}),
                ),
                GestureDetector(
                    onTap: () {
                      fontSize += 2;
                      setState(() {
                        fontSizeController.text = '$fontSize';
                      });
                    },
                    child: Container(
                        height: 44.wMin,
                        width: 44.wMin,
                        margin: EdgeInsets.symmetric(horizontal: 8.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.wMin),
                          color: const Color(0xFF353E5C),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/svg/user_center/icon_plus.svg',
                          color: AppTheme.cTextTertiary,
                        ))),
                SizedBox(width: 24.wMin),
              ],
            ),
            SizedBox(height: 24.wMin),
            SizedBox(
              height: 480.wMin,
              child: TextField(
                expands: true,
                controller: contentController,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(fontSize: fontSize.wMin, color: Colors.white),
                decoration: InputDecoration(
                  hintText: '在此粘贴或输入原文内容',
                  fillColor: const Color(0xFF393F5A).withOpacity(.35),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.wMin,
                    vertical: 16.wMin,
                  ),
                  hintStyle: TextStyle(
                    fontSize: fontSize.wMin,
                    color: Colors.white54,
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.wMin),
                    borderSide: const BorderSide(color: Color(0xFF4B5268)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.wMin),
                    borderSide: const BorderSide(color: Color(0xFF2388FF)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      children: [
        SizedBox(width: 24.wMin),
        ManageButton(
          text: "核心知识点",
          padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 16.wh),
          color: const Color(0xFF767E95),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 22.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          onTap: () {
            //todo:
          },
        ),
        const Spacer(),
        ManageButton(
          text: "取消",
          padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 16.wh),
          color: AppTheme.cSurfaceTertiary,
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 22.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 11.ww),
        ManageButton(
          text: "仅保存",
          padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 16.wh),
          color: AppTheme.cSurfaceQuaternary,
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 22.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          onTap: () async {
            save();
          },
        ),
        SizedBox(width: 11.ww),
        ManageButton(
          text: "保存并生成音频",
          padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 16.wh),
          color: const Color(0xff2388FF),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 22.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          onTap: () async {
            save(isGenAudio: true);
          },
        ),
        SizedBox(width: 24.wMin),
      ],
    );
  }

  Future<void> save({bool isGenAudio = false}) async {
    var data = {
      "collectionId": widget.collectionId,
      "contentId": widget.entity.contentId,
      "title": titleController.text,
      "lyrics": contentController.text,
      "contentType": "EN_REVEAL",
      "isGenAudio": isGenAudio
    };
    if (_isSubmit) {
      return;
    }
    _isSubmit = true;
    var res = await SubscribeRequest.editReveal(data);
    _isSubmit = false;
    if (res) {
      Get.back(result: res);
    }
  }
}
