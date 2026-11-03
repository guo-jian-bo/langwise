
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';

class ManageVisualImportSceneImageDialog{
  static Future<void> show({
    required BuildContext context,
    required int projectId,
    required ManageVisualProjectEntitySceneRelations data,
  }) async{
    
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageVisualImportSceneImageDialogWidget(
          projectId: projectId,
          data: data,
        );
      },
    );

  }
}

class ManageVisualImportSceneImageDialogWidget extends StatefulWidget {
  final int projectId;
  final ManageVisualProjectEntitySceneRelations data;
  const ManageVisualImportSceneImageDialogWidget({super.key, required this.projectId, required this.data});

  @override
  State<ManageVisualImportSceneImageDialogWidget> createState() => _ManageVisualImportSceneImageDialogWidgetState();
}

class _ManageVisualImportSceneImageDialogWidgetState extends State<ManageVisualImportSceneImageDialogWidget> {

  bool _dragging = false;

  String? _selectedFilePath;

  /// 裁剪百分比
  int _clipPercent = 2;


  /// 点击选择图片
  Future<void> _selectImage() async{
    File? file = await ImagePickerUtils.pickImage(context);
    if(file == null) return;
    _selectedFilePath = file.path;
    if(mounted) setState(() {});
  }
  

  /// 确认导入
  Future<void> confirmImport() async{
    if(_selectedFilePath == null) return ToastUtils.showToast(text: "请选择图片");
    try {
      ToastUtils.showLoading();

      OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile( 
        filePath: _selectedFilePath!,
        fileModule: OssFileManageModule.scriptTmp,
        fileType: OssFileManageType.image,
      );
      if (record == null) return;

      Map<String, dynamic> reqData = {
        "projectId": widget.projectId,
        "sceneId": widget.data.sceneId,
        "promptId": widget.data.promptId,
        "sheetImageKey": record.key,
        "marginRatio": _clipPercent,
      };
      bool res = await LanguageConsoleDramaRequest.visualUpdateSceneImage(data: reqData);
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
      title: "导入分镜表图片 · Scene ${widget.data.index??''} - ${widget.data.sceneTitle??""}",
      width: 900.wMin,
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

            _buildClipInfoWidget(),
        
          ],
        ),
      ),
    );
  }


  Widget _buildIdsWidget(){
    return SelectableText(
      "scene_uid: ${widget.data.sceneId??""} · prompt_uid: ${widget.data.promptId??""}",
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
           onTap: () {
            _selectImage();
          },
          sclae: 1.005,
          backColor: AppTheme.cSurfaceTertiary.color,
          borderRadius: 16.wMin,
          child: DottedBorder(
            padding: EdgeInsets.all(1.wMin),
            radius: Radius.circular(14.wMin),
            color: _dragging ? AppTheme.cBorderBrand.color : AppTheme.cBorderSecondary.color,
            strokeWidth: 2.wMin,
            dashPattern: const [5, 3],
            borderType: BorderType.RRect,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.wMin),
              child: Container(
                width: double.infinity,
                color: _dragging ? AppTheme.cSurfaceTertiary.color : Colors.transparent,
                child: _selectedFilePath == null ? _buildUploadBoxWidget() : _buildUploadFileImageWidget(),
              ),
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
          "点击${Platform.isMacOS || Platform.isWindows ? '' : '或拖拽'}上传四宫格分镜图",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 6.wMin),
        Text(
          "支持 .webp / .png / .jpg，尺寸必须为16:9，分辨率3920*2160 以上",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadFileImageWidget(){
    if(_selectedFilePath == null) return Container();
    return Image.file(
      File(_selectedFilePath!),
      fit: BoxFit.contain,
    );
  }


  Widget _buildClipInfoWidget(){
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
              spacing: 6.wMin,
              children: [

                Text(
                  "裁切边框安全边距",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "margin_ratio：裁切时每侧裁掉的安全边距百分比",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),

              ],
            ),
          ),

          SizedBox(width: 10.wMin),

          TapScaleWidget(
            onTap: () {
              
              if(_clipPercent > 0) _clipPercent--;
              if(mounted) setState(() {});

            },
            sclae: 1.03,
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: AppTheme.cSurfaceQuaternary.color,
              ),
              child: Icon(
                Icons.remove,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ),

          Container(
            width: 100.wMin,
            alignment: Alignment.center,
            child: Text(
              "$_clipPercent%",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          TapScaleWidget(
            onTap: () {
              if(_clipPercent < 20) _clipPercent++;
              if(mounted) setState(() {});
            },
            sclae: 1.03,
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: AppTheme.cSurfaceQuaternary.color,
              ),
              child: Icon(
                Icons.add,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ),

        ],
      ),
    );
  }


}