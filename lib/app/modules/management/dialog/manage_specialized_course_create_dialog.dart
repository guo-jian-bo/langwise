import 'dart:io';

import 'package:api/api.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/https/https.dart';
import '../../../../common/static/static_data.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../generated/assets.dart';
import '../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../utils/utils.dart';
import '../common/manage_public_widget.dart';
import '../common/manage_select_option_widget.dart';
import '../common/manage_title_input_widget.dart';

/// 专项课创建课程
class ManageSpecializedCourseCreateDialog {
  static Future<bool> show({
    required BuildContext context,
  }) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return const ManageSpecializedCourseCreateDialogWidget();
      },
    );

    return res ?? false;
  }
}

class ManageSpecializedCourseCreateDialogWidget extends StatefulWidget {
  const ManageSpecializedCourseCreateDialogWidget({
    super.key,
  });

  @override
  State<ManageSpecializedCourseCreateDialogWidget> createState() => _ManageSpecializedCourseCreateDialogWidgetState();
}

class _ManageSpecializedCourseCreateDialogWidgetState extends State<ManageSpecializedCourseCreateDialogWidget> {
  final GlobalKey containerKey = GlobalKey();

  /// 选择的创建类型
  StaticDataEntity selectSpecialty = StaticData.specialtyList[0];

  final TextEditingController nameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  int createSelectLanguageIndex = -1;

  String? coverKey;

  Future<void> onSubmit() async {
    final String name = nameController.text.trim();
    if (ObjectUtil.isEmpty(name)) {
      ToastUtils.showManageToast(text: "请输入课程名", containerKey: containerKey);
      return;
    }

    if (createSelectLanguageIndex == -1) {
      ToastUtils.showManageToast(text: "请选择语言", containerKey: containerKey);
      return;
    }
    if (coverKey == null) {
      ToastUtils.showManageToast(text: "请添加封面", containerKey: containerKey);
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await CourseUtil.create(
        config: RequestConfig(
          requireToken: true,
          data: {
            "name": name,
            "language": StaticData.languageList[createSelectLanguageIndex].value,
            "cover": coverKey,
            "description": descriptionController.text.trim(),
            "specialty": selectSpecialty.value,
          },
        ),
      );
      if (response.data != null) {
        ToastUtils.showManageToast(text: "创建课程成功", containerKey: containerKey);
        Get.back(result: true);
      } else {
        ToastUtils.showManageToast(text: "创建课程失败", containerKey: containerKey);
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "创建课程失败", containerKey: containerKey);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 添加封面
  Future<String?> onAddCover() async {
    showCupertinoDialog(
      context: Get.context!,
      builder: (_) => Container(),
    );

    final File? file = await ImagePickerUtils.pickImage(context);

    if (file == null) {
      Get.back();
      return null;
    }

    Get.back();

    try {
      ToastUtils.showLoading();

      OssUpdateResponseEntity? uploadResponse = await OssUploadFileUtils.uploadManageFile(filePath: file.path);
      if(uploadResponse == null) return null;

      coverKey = uploadResponse.key ?? '';
    } catch (e) {
      ToastUtils.showManageToast(text: "上传失败", containerKey: containerKey);
      return null;
    } finally {
      ToastUtils.hideLoading();
    }

    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return DialogBoxWidget(
      onCancel: () {
        Get.back();
      },
      onDefine: () {
        onSubmit();
      },
      title: "创建课程",
      width: 1000.wMin,
      child: Container(
        key: containerKey,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(StaticData.specialtyList.length, (index){
                  return _buildTitleTabItemWidget(StaticData.specialtyList[index]);
                }),
              ),
            ),
            SizedBox(height: 24.wMin),
            _buildFromWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildFromWidget() {
    return Container(
      height: 640.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ManageTitleInputWidget(
              title: "课程名",
              hintText: '请输入课程名',
              controller: nameController,
              required: true,
              maxLength: 20,
            ),
            SizedBox(height: 24.wMin),
            ManageTitleInputWidget(
              title: "课程描述",
              hintText: '请输入课程描述',
              controller: descriptionController,
            ),
            SizedBox(height: 24.wMin),
            ManageSelectWidget(
              title: "语言",
              hintText: '请选择语言',
              readOnly: false,
              required: true,
              options: StaticData.languageList.map((e) => e.name).toList(),
              onChanged: (String value, int index) {
                createSelectLanguageIndex = index;
                if (mounted) setState(() {});
              },
            ),
            SizedBox(height: 24.wMin),
            ManageAddCover(
              width: 250.wMin,
              height: 250.wMin,
              icon: Assets.managerAdd,
              onTap: () async {
                final String? path = await onAddCover();
                return path;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleTabItemWidget(StaticDataEntity data) {
    bool isSelected = selectSpecialty.value == data.value;
    return TapScaleWidget(
      onTap: () {
        setState(() {
          selectSpecialty = data;
        });
      },
      sclae: 1.01,
      child: AnimatedContainer(
        height: 87.wMin,
        width: 300.wMin,
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff2E344E),
          border: Border.all(width: 0.5.wMin, color: isSelected ? const Color.fromRGBO(35, 136, 255, 0.65) : const Color(0xff666F8D)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.name,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xff2388FF) : const Color(0xffBAC0CC),
                  size: 26.wMin,
                ),
              ],
            ),
            // SizedBox(height: 8.wh),
            // Expanded(
            //   child: AutoSizeText(
            //     info,
            //     minFontSize: 4,
            //     style: TextStyle(
            //       fontSize: 14.wMin,
            //       color: const Color(0xffACB4C0),
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
