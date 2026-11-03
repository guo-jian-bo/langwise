import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/audio_play_ui_widget.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../../enums/manage_zhendu_enums.dart';

/// 试听
class ManageVocalEmotionsAuditionDialog{
  static Future<void> show({
    required BuildContext context,
    required String emotionNid,
  }) async{
    
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageVocalEmotionsAuditionDialogWidget(emotionNid: emotionNid);
      },
    );

  }
}

class ManageVocalEmotionsAuditionDialogWidget extends StatefulWidget {
  final String emotionNid;
  const ManageVocalEmotionsAuditionDialogWidget({super.key, required this.emotionNid});

  @override
  State<ManageVocalEmotionsAuditionDialogWidget> createState() => _ManageVocalEmotionsAuditionDialogWidgetState();
}

class _ManageVocalEmotionsAuditionDialogWidgetState extends State<ManageVocalEmotionsAuditionDialogWidget> {

  List<IconDropdownCheckData<String>> dropdownList = [];
  /// 选择的 音色nid
  String? selectNid;

  /// 选择的dialect
  ManageZhenduDialectEnum? selectDialect;

  /// 试听文本
  final TextEditingController auditionTextController = TextEditingController();

  /// 生成条数
  int generateCount = 1;

  List<VocalEmotionsAuditionEntity> emotionsAuditionList = [];
  bool isGetLoading = false;
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    auditionTextController.text = "滚滚长江东逝水，浪花淘尽英雄。";
    getVocalTimbreList();
  }

  @override
  void dispose() {
    cancelToken.cancel();
    super.dispose();
  }

  

  /// 获取人声音色列表
  Future<void> getVocalTimbreList() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "limit": 1000,
        "offset": 0,
        "order": "-uid",
      };
      ListResponseEntity<ManageVocalTimbreEntity>? res = await LanguageConsoleDramaRequest.getVocalTimbreList(parameters: parameters);
      if(res == null) return;
      List<ManageVocalTimbreEntity> list = res.datas??[];
      for (var element in list) {
        String zhName = element.name?.firstWhereOrNull((element) => element?.lang == "zh")?.text??"";
        dropdownList.add(IconDropdownCheckData(
          title: zhName,
          value: element.nid,
        ));
      }
      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取音频试听列表 
  Future<void> getAudioList() async{
    if(selectNid == null) return ToastUtils.showToast(text: "请选择VoiceTimbre");
    if(selectDialect == null) return ToastUtils.showToast(text: "请选择dialect");
    if(auditionTextController.text.isEmpty) return ToastUtils.showToast(text: "请输入试听文本");
    if(isGetLoading) return ToastUtils.showToast(text: "正在生成中");

    try {
      isGetLoading = true;
      emotionsAuditionList.clear();
      if(mounted) setState(() {});
      Map<String, dynamic> reqData = {
        "timbreNid": selectNid,
        "dialect": selectDialect?.value,
        "text": auditionTextController.text,
        "emotionNid": widget.emotionNid,
        "numberOfVoices": generateCount,
      };
      List<VocalEmotionsAuditionEntity>? list = await LanguageConsoleDramaRequest.getEmotionsAuditionList(
        data: reqData,
        cancelToken: cancelToken,
      );
      if(list == null) return;
      emotionsAuditionList = list;
    } finally{
      isGetLoading = false;
      if(mounted) setState(() {});
    }
  }




  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "情绪试听",
      width: 1000.wMin,
      cancelText: "关闭",
      onCancel: () => Get.back(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        height: 640.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text(
              "当前情绪 `emotion_nid`：new-emotion-6",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),

            SizedBox(height: 10.wMin),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                  ),
                ),
                child: Row(
                  children: [
                    _buildConfigWidget(),
                    SizedBox(width: 16.wMin),
                    Container(width: 1.wMin, height: double.infinity, color: AppTheme.cBorderPrimary.color),
                    SizedBox(width: 16.wMin),
                    _buildAudioListWidget(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10.wMin),
        
          ],
        ),
      ),
    );
  }


  Widget _buildConfigWidget(){
    return Container(
      width: 400.wMin,
      padding: EdgeInsets.symmetric(vertical: 24.wMin),
      child: Column(
        children: [
          ManageZhenduDropdownWidget(
            title: "VoiceTimbre",
            hintText: "请选择",
            selectValue: selectNid,
            items: dropdownList,
            onChanged: (choiceData, index) {
              selectNid = choiceData.value;
              if(mounted) setState(() {});
            },
          ),
          SizedBox(height: 24.wMin),
          ManageZhenduDropdownWidget(
            title: "dialect",
            hintText: "请选择",
            selectValue: selectDialect,
            items: ManageZhenduDropdownEnums.dialects,
            onChanged: (choiceData, index) {
              selectDialect = choiceData.value;
              if(mounted) setState(() {});
            },
          ),
          SizedBox(height: 24.wMin),
          ManageZhenduInputHeightWidget(
            title: "试听文本",
            hintText: "试听文本",
            controller: auditionTextController,
            height: 150.wMin,
            maxLines: 5,
            onChanged: (value) {
              
            },
          ),
          SizedBox(height: 24.wMin),
          _buildSliderItemWidget(
            name: "生成条数",
            value: generateCount,
            onChanged: (value) {
              generateCount = value;
              if(mounted) setState(() {});
            },
          ),
          SizedBox(height: 24.wMin),
          ButtonWidget(
            text: "获取试听音频",
            height: 44.wMin,
            color: AppTheme.cSurfaceSuccess.color.withValues(alpha: isGetLoading ? 0.6 : 1),
            borderRadius: 8.wMin,
            fontSize: 20.wMin,
            sclae: 1.01,
            onTap: () {
              getAudioList();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItemWidget({
    required String name,
    required int value,
    void Function(int value)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 2.wMin),
            Text(
              name,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            const Spacer(),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8.wMin,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.wMin),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value.toDouble(),
            divisions: 3,
            min: 1,
            max: 4,
            activeColor: const Color(0xff00D492),
            inactiveColor: AppTheme.cSurfaceQuinary.color,
            onChanged: (value) {
              onChanged?.call(value.toInt());
            },
          ),
        ),
      ],
    );
  }


  Widget _buildAudioListWidget(){
    if(isGetLoading){
      return Expanded(
        child: Center(
          child: SpinKitFadingCircle(
            color: AppTheme.cBgBrand.color,
            size: 80.wMin,
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
        itemCount: emotionsAuditionList.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(10.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.wMin),
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: AudioPlayUiWidget(
              key: ValueKey(emotionsAuditionList[index].fileKey),
              audioUrl: emotionsAuditionList[index].audioUrl,
            ),
          );
        },
      ),
    );

  }



}