

import 'dart:io';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/manage_content/manage_zhendu_console/common/manage_zhendu_widgets.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../common/commons.dart';
import '../models/manage_vocal_timbre_model.dart';

/// 人声音色 上传音频
class ManageAddDialectTimberUpdateAudioDialog{
  static Future<ManageVocalTimbreEntityAudioRefsAudio?> show({
    required BuildContext context,
    required ManageVocalTimbreModel data,
    required ManageVocalDialectTimbreModel timbre,
  }) async{

    return await showCupertinoDialog<ManageVocalTimbreEntityAudioRefsAudio?>(
      context: context,
      builder: (context) {
        return ManageAddDialectTimberUpdateAudioDialogWidget(
          data: data,
          timbre: timbre,
        );
      },
    );
  }
}

class ManageAddDialectTimberUpdateAudioDialogWidget extends StatefulWidget {
  final ManageVocalTimbreModel data;
  final ManageVocalDialectTimbreModel timbre;
  const ManageAddDialectTimberUpdateAudioDialogWidget({super.key, required this.data, required this.timbre});

  @override
  State<ManageAddDialectTimberUpdateAudioDialogWidget> createState() => _ManageAddDialectTimberUpdateAudioDialogWidgetState();
}

class _ManageAddDialectTimberUpdateAudioDialogWidgetState extends State<ManageAddDialectTimberUpdateAudioDialogWidget> {
  final AudioPlayerEx audioPlayer = AudioPlayerEx();

  final TextEditingController linesController = TextEditingController();

  String? audioFilePath;
  String? audioFileName;

  @override
  void initState(){
    super.initState();
    linesController.text = widget.timbre.audioTextInput.text;
  }



  Future<void> uploadAudio() async{
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result == null) return;
    audioFilePath = result.files.single.path!;
    audioFileName = result.files.single.name;
    if(mounted) setState(() {});
  }


  /// 确认上传
  Future<void> confirm() async{
    if(linesController.text.isEmpty){
      return ToastUtils.showToast(text: "填写上传音频实际对应的台词内容。");
    }
    if(audioFilePath == null){
      return ToastUtils.showToast(text: "请上传音频");
    }

    try {
      ToastUtils.showLoading();

      OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile(
        filePath: audioFilePath!,
        fileModule: OssFileManageModule.actor,
        fileType: OssFileManageType.track,
      );
    if (record == null) return;

      await audioPlayer.setSource(DeviceFileSource(audioFilePath!));
      Duration? duration = await audioPlayer.getDuration();
      String seconds = DateFormatUtil.millisecondsToSecondsWithDecimal(duration?.inMilliseconds??0);

      int size = await File(audioFilePath!).length();

      Map<String, dynamic> reqData = {
        "timbreUid": widget.data.data?.uid,
        "dialect": widget.timbre.data?.dialect,
        "md5": record.md5,
        "fileKey": record.key,
        "duration": seconds,
        "size": size,
        "audio_text": linesController.text,
      };
      ManageVocalTimbreEntityAudioRefsAudio? res = await LanguageConsoleDramaRequest.uploadVocalTimbreAudio(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "上传成功", type: ToastType.success);
      Get.back(result: res);
    } finally{
      ToastUtils.hideLoading();
    }
  }



  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "上传参考音频",
      width: 800.wMin,
      confirmText: "确认上传",
      confirmColor: const Color(0xffFB923C),
      onConfirm: () {
        confirm();
      },
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildInfoWidget(),

            SizedBox(height: 16.wMin),

            _buildLinesWidget(),

            SizedBox(height: 16.wMin),

            _buildUpdateButtonWidget(),
            
          ],
        ),
      ),
    );
  }


  Widget _buildInfoWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.wMin,
              children: [
                _buildInfoItemWidget("voice_timbre_nid", widget.data.data?.nid??""),
                _buildInfoItemWidget("dialect", widget.timbre.dialect),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.wMin,
              children: [
                _buildInfoItemWidget("voice_timbre_uid", widget.data.data?.uid?.toString()??""),
                _buildInfoItemWidget("language", widget.timbre.dialect.split("-")[0]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItemWidget(String name, String value){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
            fontSize: 18.wMin,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
            fontSize: 20.wMin,
          ),
        ),
      ],
    );
  }


  Widget _buildLinesWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "1. 输入台词",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
              fontSize: 20.wMin,
            ),
          ),
          Text(
            "填写上传音频实际对应的台词内容。",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
              fontSize: 18.wMin,
            ),
          ),
          SizedBox(height: 10.wMin),
          ManageZhenduInputHeightWidget(
            hintText: "填写上传音频实际对应的台词内容。",
            height: 200.wMin,
            maxLines: 10,
            controller: linesController,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButtonWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "2. 上传",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
              fontSize: 20.wMin,
            ),
          ),
          SizedBox(height: 10.wMin),
          Row(
            spacing: 12.wMin,
            children: [
              ButtonWidget(
                text: "上传音频",
                width: 200.wMin,
                height: 44.wMin,
                borderRadius: 8.wMin,
                color: AppTheme.cFeedbackWarningBackground.color,
                fontColor: AppTheme.cFeedbackWarningText.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackWarningBorder.color),
                sclae: 1.03,
                onTap: () {
                  uploadAudio();
                },
              ),

              Expanded(
                child: Text(
                  audioFileName??"",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary.color,
                    fontSize: 20.wMin,
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
  

}