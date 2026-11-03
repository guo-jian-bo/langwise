import 'dart:io';

import 'package:api/api.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/static/static_data.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../generated/assets.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../../utils/utils.dart';
import '../../../common/manage_public_widget.dart';
import '../../../common/manage_select_option_widget.dart';
import '../../../common/manage_title_input_widget.dart';

class ManagePhonicsEditCourseDialog{

  static Future<bool> show({
    required BuildContext context,
    required CourseResponseEntity course,
  }) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManagePhonicsEditCourseDialogWidget(
          course: course,
        );
      },
    );

    return res ?? false;
  }

}

class ManagePhonicsEditCourseDialogWidget extends StatefulWidget {
  final CourseResponseEntity course;

  const ManagePhonicsEditCourseDialogWidget({super.key, required this.course});

  @override
  State<ManagePhonicsEditCourseDialogWidget> createState() => _ManagePhonicsEditCourseDialogWidgetState();
}

class _ManagePhonicsEditCourseDialogWidgetState extends State<ManagePhonicsEditCourseDialogWidget> {

  final GlobalKey containerKey = GlobalKey();

  int selectedIndex = 0;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  int createSelectLanguageIndex = 0;

  String? coverKey;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.course.name ?? "";
    descriptionController.text = widget.course.description ?? "";
    if (widget.course.language != null) {
      for (int i = 0; i < StaticData.languageList.length; i++) {
        if (StaticData.languageList[i].value == widget.course.language) {
          createSelectLanguageIndex = i;
          break;
        }
      }
    }
    coverKey = widget.course.cover;
  }

  Future<void> onEditCourseReq(int? uid, {String? access, String? des, String? name, String? cover}) async {
    if (uid == null) return;
    try {
      ToastUtils.showLoading();
      final response = await CourseUtil.edit(
        uid: uid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"description": des, "name": name, "cover": cover},
        ),
      );
      if (response.data != null) {
        Get.back(result: true);
        ToastUtils.showManageToast(text: "修改成功");
      } else {
        ToastUtils.showManageToast(text: response.message ?? "修改失败");
      }
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message ?? "修改失败");
    } catch (e) {
      ToastUtils.showManageToast(text: "修改失败");
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onSubmit() async {
    final String name = nameController.text.trim();
    if (ObjectUtil.isEmpty(name)) {
      ToastUtils.showManageToast(text: "请输入课程名", containerKey: containerKey);
      return;
    }


    if (coverKey == null) {
      ToastUtils.showManageToast(text: "请添加封面", containerKey: containerKey);
      return;
    }

    await onEditCourseReq(
      widget.course.uid,
      access: widget.course.access,
      des: descriptionController.text.trim(),
      name: name,
      cover: coverKey,
    );
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

      OssUpdateResponseEntity? uploadResponseEntity = await OssUploadFileUtils.uploadManageFile(
        filePath: file.path,
      );

      if (uploadResponseEntity == null) {
        return null;
      }

      if (uploadResponseEntity.key == null) {
        ToastUtils.showManageToast(text: "上传失败", containerKey: containerKey);
        return null;
      }
      coverKey = uploadResponseEntity.key ?? '';
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
      title: "编辑课程",
      width: 1000.wMin,
      child: Container(
        key: containerKey,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            ManageSelectWidget(
              title: "语言",
              hintText: '请选择语言',
              readOnly: true,
              required: true,
              value: StaticData.languageList[createSelectLanguageIndex].name,
              options: StaticData.languageList.map((e) => e.name).toList(),
            ),
            SizedBox(height: 24.wMin),
            ManageTitleInputWidget(
              title: "课程描述",
              hintText: '请输入课程描述',
              controller: descriptionController,
            ),
            Gaps.getHeight(24.wh),
            ManageAddCover(
              width: 250.wMin,
              height: 250.wMin,
              icon: Assets.managerAdd,
              filePath: widget.course.coverUrl,
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

}
