import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:langwise/app/modules/management/common/manage_dropdown_widget.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import 'package:langwise/app/modules/management/dialog/manage_crop_image_dialog.dart';

class ManageQuizLabelPictureManualDialog{
  static Future<ManageQuizLabelPictureManualResult?> show({
    required BuildContext context,
  }) async{
    return await showCupertinoDialog<ManageQuizLabelPictureManualResult?>(
      context: context, 
      builder: (context) {
        return const ManageQuizLabelPictureManualDialogWidget(
        );
      },
    );
  }
}

class ManageQuizLabelPictureManualDialogWidget extends StatefulWidget {
  const ManageQuizLabelPictureManualDialogWidget({
    super.key, 
  });

  @override
  State<ManageQuizLabelPictureManualDialogWidget> createState() => _ManageQuizLabelPictureManualDialogWidgetState();
}

class _ManageQuizLabelPictureManualDialogWidgetState extends State<ManageQuizLabelPictureManualDialogWidget> {
  final GlobalKey dialogKey = GlobalKey();

  List<ConfigEntityImage> imageStyleList = [];

  int currentStyle = 0;

  String updateUrl = "";

  @override
  void initState() {
    super.initState();
    getImageStyleList();
  }

  void getImageStyleList(){
    List<ConfigEntityImage?>? styleList = Get.find<ConfigController>().appConfig.value.image;
    if(styleList == null) return;
    imageStyleList = styleList.whereType<ConfigEntityImage>().toList();
    if(mounted) setState(() {});
  }

  Future<void> selectImage() async{
    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(photo == null) return;
    if(!(await File(photo.path).exists())) return;
    String? cropFilePath = await ManageCropImageDialog.show(
      context: context, 
      imageFilePath: photo.path, 
    );
    if(cropFilePath == null || cropFilePath == "") return;

    try {
      ToastUtils.showLoading();

      OssUpdateResponseEntity? uploadResponse = await OssUploadFileUtils.uploadManageFile(filePath: cropFilePath);
      if(uploadResponse == null) return;

      updateUrl = uploadResponse.url??"";

    } finally{
      ToastUtils.hideLoading();
    }
    
    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    
    Widget buildImageWidget(){
      if(updateUrl == ""){
        return SvgPicture.asset(
          "assets/svg/manage/icon_image.svg",
          width: 205.wMin,
        );
      }
      return Image.network(
        updateUrl,
        fit: BoxFit.fill,
      );
    }


    return DialogBoxWidget(
      title: "上传图片",
      width: 1080.wMin,
      onCancel: () => Get.back(),
      define: "下一步",
      onDefine: () {
        if(updateUrl == ""){
          ToastUtils.showManageToast(text: "请选择图片", containerKey: dialogKey);
          return;
        }
        ManageQuizLabelPictureManualResult result = ManageQuizLabelPictureManualResult(
          url: updateUrl,
          style: imageStyleList[currentStyle],
        );
        Get.back(result: result);
      },
      child: Container(
        key: dialogKey,
        margin: EdgeInsets.symmetric(horizontal: 24.wMin),
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff22293C),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.wMin),
              child: Container(
                width: 480.wMin,
                height: 480.wMin,
                alignment: Alignment.center,
                color: const Color(0xff181B25),
                child: buildImageWidget(),
              ),
            ),
            SizedBox(width: 16.wMin),
            Expanded(
              child: Column(
                children: [
                  ManageDropdownWidget(
                    title: "图片风格",
                    valueMainAxisAlignment: MainAxisAlignment.spaceBetween,
                    selectedIndex: currentStyle,
                    values: imageStyleList.map((e){
                      return e.title??"";
                    }).toList(),
                    onChange: (index) {
                      currentStyle = index;
                      if(mounted) setState(() {});
                    },
                  ),
                  SizedBox(height: 16.wMin),
                  TapScaleWidget(
                    onTap: () => selectImage(),
                    sclae: 1.02,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: const Color(0xff353E5C),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/manage/icon_image_white.svg",
                            width: 24.wMin,
                          ),
                          SizedBox(width: 6.wMin),
                          Text(
                            "选择图片",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: const Color(0xffEBEFF5),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageQuizLabelPictureManualResult{
  final String url;
  final ConfigEntityImage style;
  ManageQuizLabelPictureManualResult({
    required this.url,
    required this.style,
  });
}