import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../theme/theme.dart';
import 'commons.dart';

class ManageSelectSemanticDialog {

  static Future<List<EnKnowledgeEntitySemantics>?> show({
    required BuildContext context,
    required List<EnKnowledgeEntitySemantics?>? semantics,
  }) async {
    return await showCupertinoDialog<List<EnKnowledgeEntitySemantics>?>(
      context: context, 
      builder: (context) {
        return ManageSelectSemanticDialogWidget(semantics: semantics);
      },
    );
  }

}


class ManageSelectSemanticDialogWidget extends StatefulWidget {
  final List<EnKnowledgeEntitySemantics?>? semantics;
  const ManageSelectSemanticDialogWidget({super.key, this.semantics});

  @override
  State<ManageSelectSemanticDialogWidget> createState() => _ManageSelectSemanticDialogWidgetState();
}

class _ManageSelectSemanticDialogWidgetState extends State<ManageSelectSemanticDialogWidget> {

  /// 选择的语义列表
  List<EnKnowledgeEntitySemantics> selectedSemantics = [];

  bool _isSelected(EnKnowledgeEntitySemantics? data) {
    if (data?.uid == null) return false;
    return selectedSemantics.any((item) => item.uid == data!.uid);
  }

  void _toggleSelected(EnKnowledgeEntitySemantics? data) {
    if (data?.uid == null) return;

    final bool selected = _isSelected(data);
    if (selected) {
      selectedSemantics.removeWhere((item) => item.uid == data!.uid);
    } else {
      selectedSemantics.add(data!);
    }
    if (mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "选择语义",
      width: 1400.wMin,
      onCancel: () => Get.back(),
      onConfirm: () {
        if(selectedSemantics.isEmpty) return ToastUtils.showToast(text: "请选择语义");
        Get.back(result: selectedSemantics);
      },
      child: SizedBox(
        height: 700.wMin,
        child: GridView.builder(
          padding: EdgeInsets.all(16.wMin),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16.wMin,
            crossAxisSpacing: 16.wMin,
            childAspectRatio: 432 / 188,
          ),
          itemCount: widget.semantics?.length,
          itemBuilder: (context, index) {
            return _buildItemWidget(widget.semantics?[index]);
          },
        ),
      ),
    );
  }



  Widget _buildItemWidget(EnKnowledgeEntitySemantics? data){
    String iconUnCheck = "assets/svg/manage/icon_uncheck_box.svg";
    String iconCheck = "assets/svg/manage/icon_check_box.svg";
    bool selected = _isSelected(data);

    return TapScaleWidget(
      onTap: () {
        _toggleSelected(data);
      },
      sclae: 1,
      borderRadius: 16.wMin,
      backColor: AppTheme.cSurfaceTertiary.color,
      child: Container(
        padding: EdgeInsets.all(10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: Colors.transparent,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
        ),
        child: Row(
          children: [

            AspectRatio(
              aspectRatio: 1,
              child: CachedImageWidget(
                data?.imageUrl??"",
                errorWidget: buildEmptyWidget(),
                placeholder: buildLoadingWidget(),
                fadeInDuration: Duration.zero,
              ),
            ),

            SizedBox(width: 6.wMin),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    spacing: 6.wMin,
                    children: [
                      ManageTagFS16Widget(
                        tag: "sid: ${data?.uid}",
                        bgColor: AppTheme.cSurfaceQuaternary.color,
                        fontColor: AppTheme.cTextSecondary.color,
                      ),
                      StatusTagDifficultyWidget(
                        difficulty: data?.difficulty,
                        language: "en",
                        fontSize: 14.wMin,
                        padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                      ),
                      const Spacer(),
                       SvgPicture.asset(
                        selected ? iconCheck : iconUnCheck,
                        width: 20.wMin,
                      ),
                    ],
                  ),

                  SizedBox(height: 6.wMin),

                  ...List.generate(data?.gloss?.length??0, (index){
                    return SelectableText(
                      data?.gloss?[index]?.text??"",
                      style: TextStyle(
                        fontSize: index == 0 ? 20.wMin : 18.wMin,
                        color: AppTheme.cTextPrimary.color.withValues(alpha: index == 0 ? 1 : 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }


}
