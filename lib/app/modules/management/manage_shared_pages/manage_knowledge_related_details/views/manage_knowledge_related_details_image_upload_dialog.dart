
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../generated/assets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../../utils/utils.dart';
import '../../../common/commons.dart';

/// 知识点上传图片
class ManageKnowledgeRelatedDetailsImageUploadDialog{

  static Future<bool> show({
    required BuildContext context,
    required String? type,
    required int? uid,
    required int? semanticId,
    List<int> initialSelectedStyleIds = const [],
  }) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageKnowledgeRelatedDetailsImageUploadDialogWidget(
          initialSelectedStyleIds: initialSelectedStyleIds,
          type: type,
          uid: uid,
          semanticId: semanticId,
        );
      },
    );
    return res??false;
  }

}

class ManageKnowledgeRelatedDetailsImageUploadDialogWidget extends StatefulWidget {
  final String? type;
  final int? uid;
  final int? semanticId;
  final List<int> initialSelectedStyleIds;
  const ManageKnowledgeRelatedDetailsImageUploadDialogWidget({
    super.key, 
    required this.initialSelectedStyleIds, 
    this.type, 
    this.uid, 
    this.semanticId,
  });

  @override
  State<ManageKnowledgeRelatedDetailsImageUploadDialogWidget> createState() => _ManageKnowledgeRelatedDetailsImageUploadDialogWidgetState();
}

class _ManageKnowledgeRelatedDetailsImageUploadDialogWidgetState extends State<ManageKnowledgeRelatedDetailsImageUploadDialogWidget> {

  final Set<int> _styleTabSelectedStyleIds = <int>{};

  /// 视频风格列表
  Map<String, List<ImageStyleConfigV2Item>> styleGroups = {};
  /// 选择的风格id列表
  Set<int> selectStyleIds = {};
  /// 分组展开列表
  Set<String> openGroups = {};

  /// 上传的图片文件
  String? selectFilePath;

  @override
  void initState() {
    super.initState();
    _styleTabSelectedStyleIds.addAll(widget.initialSelectedStyleIds);
    getStyleListV2();
  }

  Future<void> getStyleListV2() async{
    try {
      ToastUtils.showLoading();
      ImageStyleConfigV2ResponseData? res = await LanguageUtil.getStyleListV2();
      if(res == null) return;
      styleGroups = res.groups;
      
      openGroups.addAll(styleGroups.keys.toList());

      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  Future<void> selectImage() async{
    File? file = await ImagePickerUtils.selectPicture(
      context: context,
      compress: false,
    );
    if(file == null) return;
    selectFilePath = file.path;
    if(mounted) setState(() {});
  }


  /// 确定上传
  Future<void> confirmUpload() async{
    if(selectStyleIds.isEmpty) return ToastUtils.showToast(text: "请选择风格");
    if(selectFilePath == null) return ToastUtils.showToast(text: "请上传图片");

    try {
      ToastUtils.showLoading();
      OssUpdateResponseEntity? upload = await OssUploadFileUtils.uploadManageFile(
        filePath: selectFilePath!,
        fileModule: OssFileManageModule.knowledge,
      );
      if(upload == null) return;

      Map<String, dynamic> reqData = {
        "styleIds": selectStyleIds.toList(),
        "subContent": {
          "uid": widget.uid,
          "type": widget.type,
          "semanticId": widget.semanticId,
        },
        "imageKey": upload.key,
      };
      bool res = await LanguageConsoleRequest.knowledgeUploadImage(data: reqData);
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
      title: "上传图片",
      width: 800.wMin,
      onCancel: () => Get.back(),
      confirmText: "确认上传",
      onConfirm: () {
        confirmUpload();
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 16.wMin, left: 24.wMin, right: 24.wMin),
        width: double.infinity,
        height: 900.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
            SizedBox(height: 10.wMin),
            Text(
              "选择要上传的图片风格",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: _buildStyleListWidget(),
              ),
            ),
            Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
            _buildUploadWidget(),
            Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          ],
        ),
      ),
    );
  }

  /// 风格列表
  Widget _buildStyleListWidget(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.wMin),
      child: Column(
        spacing: 16.wMin,
        children: List.generate(styleGroups.keys.length, (index){

          return _buildStyleListGroupWidget(styleGroups.keys.toList()[index]);

        }),
      ),
    );
  }

  Widget _buildStyleListGroupWidget(String group){
    bool selected = openGroups.contains(group);

    List<ImageStyleConfigV2Item> list = styleGroups[group]??[];

    return Column(
      children: [

        TapScaleWidget(
          onTap: () {
            if(selected){
              openGroups.remove(group);
            }else{
              openGroups.add(group);
            }
            if(mounted) setState(() {});
          },
          sclae: 1,
          child: Container(
            height: 44.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: Row(
              children: [
                Text(
                  group,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: selected ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          secondChild: Container(width: double.infinity), 
          firstChild: Container(
            padding: EdgeInsets.symmetric(vertical: 8.wMin),
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6.wMin,
              runSpacing: 6.wMin,
              children: List.generate(list.length, (index){
                return _buildStyleListGroupItemWidget(list[index]);
              }),
            ),
          ), 
          crossFadeState: selected ? CrossFadeState.showFirst : CrossFadeState.showSecond, 
        ),



      ],
    );
  }

  Widget _buildStyleListGroupItemWidget(ImageStyleConfigV2Item style){
    bool isSelect = selectStyleIds.contains(style.uid);

    List<String> flagList = style.iconUrls??[];

    return TapScaleWidget(
      onTap: () {
        if(isSelect){
          selectStyleIds.remove(style.uid);
        }else{
          selectStyleIds.add(style.uid);
        }
        if(mounted) setState(() {});
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: AppTheme.cSurfaceTertiary.color,
          border: Border.all(
            width: 1.wMin,
            color: isSelect ? AppTheme.cBorderBrand.color : Colors.transparent,
          ),
        ),
        child: Row(
          spacing: 4.wMin,
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              spacing: 2.wMin,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(flagList.length, (index){
                return SizedBox(
                  width: 28.wMin,
                  child: CachedImageWidget(
                    flagList[index],
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildEmptyWidget(),
                  ),
                );
              }),
            ),

            Text(
              style.localeTitle??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildUploadWidget(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            "上传图片",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.wMin),

          TapScaleWidget(
            onTap: () {
              selectImage();
            },
            sclae: 1.01,
            child: _buildUploadAddWidget(),
          ),
          
        ],
      ),
    );
  }

  Widget _buildUploadAddWidget(){
    return Container(
      width: 250.wMin,
      height: 250.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary.color,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [

          Positioned.fill(
            child: Visibility(
              visible: selectFilePath != null,
              child: Image.file(
                File(selectFilePath??""),
                fit: BoxFit.contain,
              ),
            ),
          ),

          Visibility(
            visible: selectFilePath == null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  Assets.publicIconAdd,
                  width: 28.wMin,
                ),
                Text(
                  "点击上传",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary,
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