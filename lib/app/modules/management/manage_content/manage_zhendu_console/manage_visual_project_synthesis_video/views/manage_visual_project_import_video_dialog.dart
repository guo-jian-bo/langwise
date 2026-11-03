import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';


class ManageVisualProjectImportVideoDialog{

  static Future<bool> show({
    required BuildContext context,
    required int projectId,
  }) async{
    
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageVisualProjectImportVideoDialogWidget(
          projectId: projectId,
        );
      },
    );

    return res??false;

  }

}

class ManageVisualProjectImportVideoDialogWidget extends StatefulWidget {
  final int projectId;
  const ManageVisualProjectImportVideoDialogWidget({super.key, required this.projectId});

  @override
  State<ManageVisualProjectImportVideoDialogWidget> createState() => _ManageVisualProjectImportVideoDialogWidgetState();
}

class _ManageVisualProjectImportVideoDialogWidgetState extends State<ManageVisualProjectImportVideoDialogWidget> {

  bool _dragging = false;

  String? _selectedFilePath;

  final Player player = Player();
  late final VideoController videoController;

  @override
  void initState() {
    super.initState();
    videoController = VideoController(player);
  }

  @override
  void dispose(){
    player.dispose();
    super.dispose();
  }

  /// 点击选择图片
  Future<void> _selectVideo() async{
    FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'webm'],
    );
    if(file == null) return;
    if(file.files.isEmpty) return;
    _selectedFilePath = file.files.first.path;
    if(mounted) setState(() {});
    player.open(Media(_selectedFilePath!));
  }
  

  /// 确认导入
  Future<void> confirmImport() async{
    if(_selectedFilePath == null) return ToastUtils.showToast(text: "请选择视频");
    try {
      ToastUtils.showLoading();

      OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile( 
        filePath: _selectedFilePath!,
        fileModule: OssFileManageModule.scriptTmp,
        fileType: OssFileManageType.video,
      );
      if (record == null) return;

      Map<String, dynamic> reqData = {
        "projectId": widget.projectId,
        "videoKey": record.key,
      };
      bool res = await LanguageConsoleDramaRequest.visualImportVideo(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "上传成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "导入完整视频",
      width: 1000.wMin,
      cancelText: "关闭",
      onCancel: () => Get.back(),
      confirmText: "确认导入",
      onConfirm: () {
        confirmImport();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        height: 660.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildIdsWidget(),  

            SizedBox(height: 16.wMin),

            _buildUploadWidget(),

             SizedBox(height: 16.wMin),

             ButtonWidget(
              text: _selectedFilePath != null ? "重新选择视频" : "选择视频",
              padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
              borderRadius: 8.wMin,
              sclae: 1.01,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              fontColor: AppTheme.cSurfaceBrand.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
              fontSize: 20.wMin,
              onTap: OptimizeUtils.noneThrottle(() {
                _selectVideo();
              }, 300),
            ),


        
          ],
        ),
      ),
    );
  }

  Widget _buildIdsWidget(){
    return SelectableText(
      "上传外部剪辑的完整视频，系统将自动转码并保存",
      style: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextTertiary.color,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildUploadWidget(){
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DropTarget(
        onDragDone: (details) {
          if(details.files.isEmpty) return;
          _selectedFilePath = details.files.first.path;
          if(mounted) setState(() {});
          player.open(Media(_selectedFilePath!));
        },
        onDragEntered: (details) {
          _dragging = true;
          if (mounted) setState(() {});
        },
        onDragExited: (details) {
          _dragging = false;
          if (mounted) setState(() {});
        },
        child: TapScaleWidget(
           onTap: _selectedFilePath != null ? null : () {
            _selectVideo();
          },
          sclae: 1.005,
          backColor: AppTheme.cSurfaceTertiary.color,
          borderRadius: 16.wMin,
          child: DottedBorder(
            padding: EdgeInsets.all(1.wMin),
            color: _dragging ? AppTheme.cBorderBrand.color : AppTheme.cBorderSecondary.color,
            strokeWidth: 2.wMin,
            dashPattern: const [5, 3],
            borderType: BorderType.RRect,
            child: Container(
              width: double.infinity,
              color: _dragging ? AppTheme.cSurfaceTertiary.color : Colors.transparent,
              child: _selectedFilePath == null ? _buildUploadBoxWidget() : _buildUploadFileVideoWidget(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBoxWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload,
          size: 48.wMin,
          color: AppTheme.cTextTertiary.color,
        ),
        SizedBox(height: 10.wMin),
        Text(
          "点击${Platform.isMacOS || Platform.isWindows ? '' : '或拖拽'}上传完整视频",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 6.wMin),
        Text(
          "支持 .mp4 / .mov / .webm，建议分辨率 1920×1080 以上",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadFileVideoWidget(){
    if(_selectedFilePath == null) return Container();
    return Video(
      controller: videoController,
    );
  }


}