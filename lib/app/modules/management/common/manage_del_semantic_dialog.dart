
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';
import 'commons.dart';

enum ManageDelSemanticEnum{
  word,
  database,
}

/// 删除语义的选择
class ManageDelSemanticDialog{

  static Future<ManageDelSemanticEnum?> show({
    required BuildContext context,
    required int sid,
    required String content,
  }) async{
    return await showCupertinoDialog<ManageDelSemanticEnum?>(
      context: context,
      builder: (context) {
        return ManageDelSemanticDialogWidget(sid: sid, content: content);
      },
    );
  }

}

class ManageDelSemanticDialogWidget extends StatefulWidget {
  final int sid;
  final String content;
  const ManageDelSemanticDialogWidget({super.key, required this.sid, required this.content});

  @override
  State<ManageDelSemanticDialogWidget> createState() => _ManageDelSemanticDialogWidgetState();
}

class _ManageDelSemanticDialogWidgetState extends State<ManageDelSemanticDialogWidget> {

  ManageDelSemanticEnum selectType = ManageDelSemanticEnum.word;


  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "确认删除语义 (sid: ${widget.sid})",
      width: 900.wMin,
      onCancel: () => Get.back(),
      confirmText: "确认删除",
      confirmColor: AppTheme.cSurfaceError.color,
      onConfirm: () {
        Get.back(result: selectType);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            Text(
              "选择删除方式",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
        
            SizedBox(height: 12.wMin),
            _buildTypeItemWidget(ManageDelSemanticEnum.word),
            SizedBox(height: 16.wMin),
            _buildTypeItemWidget(ManageDelSemanticEnum.database),
            SizedBox(height: 12.wMin),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeItemWidget(ManageDelSemanticEnum type){

    String title = "仅从当前单词中移除";
    String desc = '该语义将不再出现在 "${widget.content}" 中，但保留在数据库中。';
    if(type == ManageDelSemanticEnum.database){
      title = "从数据库中彻底删除";
      desc = "注意：此操作将删除该语义及其所有释义、图片、题目，此操作不可撤销。";
    }

    return TapScaleWidget(
      onTap: () {
        selectType = type;
        if(mounted) setState(() {});
      },
      sclae: 1,
      borderRadius: 12.wMin,
      backColor: AppTheme.cSurfaceError.color.withValues(alpha: 0.1),
      child: Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            width: 2.wMin,
            color: selectType == type ? AppTheme.cSurfaceError.color : AppTheme.cBorderPrimary.color,
          ),
        ),
        child: Row(
          children: [
            
            SvgPicture.asset(
              selectType == type ? "assets/svg/manage/icon_exact_match.svg" : "assets/svg/manage/icon_unradio.svg",
              width: 28.wMin,
              colorFilter: selectType == type ? ColorFilter.mode(
                AppTheme.cSurfaceError.color, 
                BlendMode.srcIn,
              ) : null,
            ),
            
            SizedBox(width: 12.wMin),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10.wMin),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }

}