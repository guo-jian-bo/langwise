
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/audio_play_ui_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';

class ManageAdjustToneBindingResult{
  String? timbreNid;

  ManageAdjustToneBindingResult({
    required this.timbreNid,
  });
}

/// 调整音色绑定
class ManageAdjustToneBindingDialog{

  static Future<ManageAdjustToneBindingResult?> show({
    required BuildContext context,
  }) async{
    return await showCupertinoDialog<ManageAdjustToneBindingResult?>(
      context: context,
      builder: (context) {
        return const ManageAdjustToneBindingDialogWidget();
      },
    );
  }

}

class ManageAdjustToneBindingDialogWidget extends StatefulWidget {
  const ManageAdjustToneBindingDialogWidget({super.key});

  @override
  State<ManageAdjustToneBindingDialogWidget> createState() => _ManageAdjustToneBindingDialogWidgetState();
}

class _ManageAdjustToneBindingDialogWidgetState extends State<ManageAdjustToneBindingDialogWidget> {

  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();
  List<ManageVocalTimbreEntity> timbreList = [];

  ManageVocalTimbreEntity? selectTimbre;

  @override
  void initState() {
    super.initState();
    getListData();
  }

  /// 获取列表数据
  Future<void> getListData() async{
    try {
      timbreList.clear();
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "limit": 1000,
        "offset": 0,
        "order": "-uid",
      };
      Map<String, dynamic> reqData = {};
      if(searchInput.text.isNotEmpty){
        reqData["keyword"] = searchInput.text;
      }
      ListResponseEntity<ManageVocalTimbreEntity>? res = await LanguageConsoleDramaRequest.getVocalTimbreList(parameters: parameters, data: reqData);
      if(res == null) return;
      timbreList = res.datas??[];
      if(mounted) setState(() {});
    } finally{
      
      ToastUtils.hideLoading();
    }
  }



  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "音色绑定",
      width: 1200.wMin,
      onCancel: () => Get.back(),
      confirmText: "确认",
      onConfirm: () {

        if(selectTimbre == null){
          return ToastUtils.showToast(text: "请选择音色");
        }

        ManageAdjustToneBindingResult result = ManageAdjustToneBindingResult(
          timbreNid: selectTimbre?.nid,
        );

        Get.back(result: result);

      },
      child: Container(
        height: 850.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        child: Column(
          children: [
            CardInputWidget(
              hintText: "搜索nid / 中文名称 / 标签",
              controller: searchInput,
              textInputAction: TextInputAction.search,
              height: 54.wMin,
              valueStyle: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
              hintStyle: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
              onSubmitted: (value) {
                getListData();
              },
            ),
            Expanded(
              child: ListView.separated(
                itemCount: timbreList.length,
                padding: EdgeInsets.symmetric(vertical: 20.wMin),
                separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
                itemBuilder: (context, index) {
                  return _buildListWidget(timbreList[index]);
                },
              ),
            ),
          ],
        ),
        // child: _buildInputsWidget(),
      ),
    );
  }

  Widget _buildListWidget(ManageVocalTimbreEntity data){

    String zhName = data.name?.firstWhereOrNull((element) => element?.lang == "zh")?.text??"";

    List<ManageVocalTimbreEntityAudioRefs?> audioRefs = data.audioRefs??[];

    return TapScaleWidget(
      onTap: () {
        selectTimbre = data;
        if(mounted) setState(() {});
      },
      sclae: 1,
      borderRadius: 14.wMin,
      backColor: AppTheme.cSurfaceSuccess.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            width: 1.wMin, 
            color: selectTimbre?.uid == data.uid ? AppTheme.cSurfaceSuccess.color : AppTheme.cBorderSecondary.color,
          ),
        ),
        child: Column(
          children: [
      
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.wMin)),
                color: AppTheme.cSurfaceTertiary.color,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
      
                  Text(
                    zhName,
                    style: TextStyle(
                      fontSize: 22.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    data.nid??"",
                    style: TextStyle(
                      fontSize: 22.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
      
                ],
              ),
            ),
      
            ListView.separated(
              itemCount: audioRefs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.wMin),
              separatorBuilder: (context, index) => SizedBox(height: 8.wMin),
              itemBuilder: (context, index) {
                return _buildDialectItemWidget(data, audioRefs[index]);
              },
            ),
      
          ],
        ),
      
      ),
    );
  }

  Widget _buildDialectItemWidget(ManageVocalTimbreEntity data, ManageVocalTimbreEntityAudioRefs? audio){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.wMin),
        border: Border.all(
          width: 1.wMin, 
          color: AppTheme.cBorderSecondary.color,
        ),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
    
          SizedBox(
            width: 400.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6.wMin,
              children: [
            
                Text(
                  audio?.dialect??"",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            
                Text(
                  audio?.description??"",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            
              ],
            ),
          ),
    
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6.wMin,
              children: [
    
                Container(
                  width: double.infinity,
                  height: 54.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
                    color: AppTheme.cSurfaceTertiary.color,
                  ),
                  child: Visibility(
                    visible: audio?.audio?.audioUrl != null,
                    child: AudioPlayUiWidget(
                      audioUrl: audio?.audio?.audioUrl,
                    ),
                  ),
                ),
    
                Text(
                  audio?.audioText??"",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
    
              ],
            ),
          ),
    
        ],
      ),
    );
  }


}