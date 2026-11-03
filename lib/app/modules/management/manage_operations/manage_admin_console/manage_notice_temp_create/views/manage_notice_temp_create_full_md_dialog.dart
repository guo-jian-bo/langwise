import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../enums/enums.dart';

class ManageNoticeTempCreateFullMdDialog{

  static Future<String?> show({
    required BuildContext context,
    required String markdownText,
    required NoticeContentTypeEnum noticeContentType,
  }) async{
    return await showDialog<String?>(
      context: context,
      builder: (context) {
        return ManageNoticeTempCreateFullMdDialogWidget(markdownText: markdownText, noticeContentType: noticeContentType);
      },
    );
  }

}

class ManageNoticeTempCreateFullMdDialogWidget extends StatefulWidget {
  final String markdownText;
  final NoticeContentTypeEnum noticeContentType;

  const ManageNoticeTempCreateFullMdDialogWidget({super.key, required this.markdownText, required this.noticeContentType});

  @override
  State<ManageNoticeTempCreateFullMdDialogWidget> createState() => _ManageNoticeTempCreateFullMdDialogWidgetState();
}

class _ManageNoticeTempCreateFullMdDialogWidgetState extends State<ManageNoticeTempCreateFullMdDialogWidget> {
  final TextEditingController markdownController = TextEditingController();
  String markdownPreview = "";

  @override
  void initState(){
    super.initState();
    markdownController.text = widget.markdownText;
    markdownPreview = widget.markdownText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Container(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).padding.left + 24.wMin,
          right: MediaQuery.of(context).padding.right + 24.wMin,
          top: MediaQuery.of(context).padding.top + 24.wMin,
        ),
        child: Row(
          children: [
            Expanded(child: _buildMdInputWidget()),
            SizedBox(width: 16.wMin),
            Expanded(child: _buildPreviewWidget()),
          ],
        ),
      ),
      bottomNavigationBar: _buildButtonsWidget(),
    );
  }

  Widget _buildButtonsWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 24.wMin),
      color: AppTheme.cBgPrimary.color,
      child: Row(
        children: [
          const Spacer(),
          ButtonWidget(
            text: "返回",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            borderRadius: 99,
            color: AppTheme.cSurfaceLayerElevated.color,
            fontColor: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
            fontSize: 24.wMin,
            sclae: 1.03,
            onTap: () {
              Get.back();
            },
          ),
          SizedBox(width: 24.wMin),
          ButtonWidget(
            text: "保存修改",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            borderRadius: 99,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            fontColor: AppTheme.cSurfaceBrand.color,
            fontWeight: FontWeight.w500,
            fontSize: 24.wMin,
            sclae: 1.03,
            onTap: () {
              Get.back(result: markdownController.text);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMdInputWidget(){
    OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.wMin),
      borderSide: BorderSide(
        color: AppTheme.cBorderNone.color,
        width: 1.wMin,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormTitleWidget(
          title: widget.noticeContentType == NoticeContentTypeEnum.md ? "Markdown 编辑" : "文本编辑", 
          isRequired: false,
        ),
        SizedBox(height: 8.wMin),
        Expanded(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: AppTheme.cBorderNone.color,
                width: 1.wMin,
              ),
            ),
            child: TextField(
              controller: markdownController,
              maxLines: null,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
              decoration: InputDecoration(
                hintText: widget.noticeContentType == NoticeContentTypeEnum.txt ? "请输入文本内容" :
                              '''##标题
正文段落，可以使用**加粗**
- 列表项 1
- 列表项 2''',
                hintStyle: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
                border: outlineInputBorder,
                focusedBorder: outlineInputBorder,
                disabledBorder: outlineInputBorder,
                enabledBorder: outlineInputBorder,
                focusedErrorBorder: outlineInputBorder,
              ),
              onChanged: (value){
                markdownPreview = value;
                if(mounted) setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormTitleWidget(title: "实时预览", isRequired: false),
        SizedBox(height: 8.wMin),
        Expanded(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: AppTheme.cBorderNone.color,
                width: 1.wMin,
              ),
            ),
            child: SingleChildScrollView(
              child: widget.noticeContentType == NoticeContentTypeEnum.md ? 
                AppMarkdownWidget(data: markdownPreview) : 
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
                  width: double.infinity,
                  child: Text(
                    markdownPreview,
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildFormTitleWidget({
    required String title,
    String? subTitle,
    bool isRequired = true,
  }){
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        Visibility(
          visible: isRequired,
          child: Text(
            "*",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cSurfaceError.color,
            ),
          ),
        ),
        const Spacer(),
        Visibility(
          visible: subTitle != null,
          child: Text(
            subTitle??"",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ),
      ],
    );
  }

}