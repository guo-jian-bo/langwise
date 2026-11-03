import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/common/entities/article_entity.dart';
import 'package:ui_essentials/ui_essentials.dart';

class SubscribeOriginArticleDialog {
  static Future<bool?> show({
    required BuildContext context,
    required ArticleEntity articleEntity,
  }) async {
    return await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) => _SubscribeOriginArticleDialogWidget(
        entity: articleEntity,
      ),
    );
  }
}

class _SubscribeOriginArticleDialogWidget extends StatefulWidget {
  final ArticleEntity entity;

  const _SubscribeOriginArticleDialogWidget({
    required this.entity,
  });

  @override
  State<_SubscribeOriginArticleDialogWidget> createState() => _SubscribeOriginArticleDialogWidgetState();
}

class _SubscribeOriginArticleDialogWidgetState extends State<_SubscribeOriginArticleDialogWidget> {
  @override
  void initState() {
    super.initState();
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
            padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              border: Border.all(
                color: const Color(0xff444B5F),
                width: 1.wMin,
              ),
              color: const Color(0xff181B25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gaps.getHeight(35.wh),
                _buildContentWidget(context),
                Gaps.getHeight(24.wh),
                _buildBottomWidget(),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 主视图
  Widget _buildContentWidget(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff22293C),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w600,
                ),
                children: const [
                  TextSpan(
                    text: '',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  TextSpan(text: '原文链接', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 24.wMin),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4B5268)), borderRadius: BorderRadius.circular(4.wMin)),
              child: SelectableText(
                widget.entity.sourceUrl ?? '没有链接',
                style: TextStyle(fontSize: 24.wMin, color: Colors.white),
              ),
            ),
            Gaps.getHeight(24.wh),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                    children: const [
                      TextSpan(
                        text: '',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      TextSpan(text: '原文内容', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 24.wMin),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4B5268)),
                  borderRadius: BorderRadius.circular(4.wMin),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                child: SelectableText(widget.entity.sourceContent ?? '', style: TextStyle(fontSize: 28.wMin, color: Colors.white)),
              ),
            ),
            Gaps.getHeight(24.wh),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "关闭",
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
          borderColor: const Color(0xff666F8D),
          style: TextStyle(
            fontSize: 16.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        )
      ],
    );
  }
}
