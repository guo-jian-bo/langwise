import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/utils/elements_page_utils.dart';

class ZhenxieTaskMaterialsWidget extends StatefulWidget {
  final List<ElementsCardEntityDatas> knowledgePointsList;
  final List<CourseWriteTargetItemEntity> grammarTargetList;
  final bool isManagement;
  final ValueChanged<int>? onTapGrammarTarget;

  /// 资料
  const ZhenxieTaskMaterialsWidget({
    super.key,
    required this.knowledgePointsList,
    required this.grammarTargetList,
    this.isManagement = false,
    this.onTapGrammarTarget,
  });

  @override
  State<ZhenxieTaskMaterialsWidget> createState() => _ZhenxieTaskMaterialsWidgetState();
}

class _ZhenxieTaskMaterialsWidgetState extends State<ZhenxieTaskMaterialsWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.wMin),
            Text(
              "文章中请使用下面列表中的核心知识点",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
            SizedBox(height: 16.wMin),
            _buildKnowledgetListWidget(),
            SizedBox(height: 32.wMin),
            _buildSyntaxListWidget(),
            SizedBox(height: 32.wMin),
          ],
        ),
      ),
    );
  }

  /// 知识点列表
  Widget _buildKnowledgetListWidget() {
    if (widget.knowledgePointsList.isEmpty) {
      return Text(
        "本题不指定核心知识点",
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cZhenxieFontTertiary.color,
        ),
      );
    }
    return Wrap(
      spacing: 8.wMin,
      runSpacing: 8.wMin,
      children: List.generate(widget.knowledgePointsList.length, (index) {
        final data = widget.knowledgePointsList[index];
        String content = data.content ?? '';
        String? pos = data.pos;
        String? gloss = LearningLangUtils.getLocalLang(data.gloss)?.text;
        String showText = content;
        if (pos != null) {
          showText += " $pos";
        }
        if (gloss != null) {
          showText += " $gloss";
        }

        return TapScaleWidget(
          onTap: () {
            ElementsPageUtils.jumpElementsPage(
              contentId: data.contentId,
              contentType: data.contentType,
              semanticId: data.semanticId,
              content: data.content,
              styleId: null,
              dialect: null,
              isManagement: widget.isManagement,
            );
          },
          sclae: 1.01,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: AppTheme.cZhenxieBackgroundPrimary.color,
              border: Border.all(
                color: AppTheme.cZhenxieBorderPrimary.color,
                width: 0.8.wMin,
              ),
            ),
            child: Text(
              showText,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cZhenxieFontPrimary.color,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 语法点列表
  Widget _buildSyntaxListWidget() {
    if (widget.grammarTargetList.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "本题的语法点",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontTertiary.color,
          ),
        ),
        SizedBox(height: 16.wMin),
        Column(
          spacing: 12.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.grammarTargetList.length, (index) {
            return _buildSyntaxItemWidget(data: widget.grammarTargetList[index]);
          }),
        ),
      ],
    );
  }

  Widget _buildSyntaxItemWidget({
    required CourseWriteTargetItemEntity data,
  }) {
    return TapScaleWidget(
      onTap: () {
        if (data.uid == null || data.uid! <= 0) return;
        widget.onTapGrammarTarget?.call(data.uid!);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 0.8.wMin,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                LearningLangUtils.getLocalLang(data.title)?.text ?? LearningLangUtils.getLearningLang(data.title)?.text ?? '',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Visibility(
              visible: data.kindTitle?.isNotEmpty == true,
              child: Container(
                margin: EdgeInsets.only(left: 10.wMin),
                child: ButtonWidget(
                  text: data.kindTitle ?? '',
                  height: 34.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                  borderRadius: 99,
                  color: AppTheme.cZhenxieBackgroundPrimary.color,
                  border: Border.all(
                    color: AppTheme.cZhenxieBorderPrimary.color,
                    width: 0.8.wMin,
                  ),
                  fontColor: AppTheme.cZhenxieFontSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
