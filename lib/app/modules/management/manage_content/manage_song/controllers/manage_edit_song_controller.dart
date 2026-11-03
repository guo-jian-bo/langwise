import 'package:api/entities/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:common_utils/common_utils.dart' as common;
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';
import '../../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';

class ManageEditSongController extends GetxController {
  final EnKnowledgeEntity entity;

  ManageEditSongController(this.entity);

  /// 标题
  final TextEditingController titleController = TextEditingController();

  /// 内容
  final TextEditingController contentController = TextEditingController();

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  // 获取上下架状态显示名称
  String get newAccessName {
    if (selectAccessIndex == -1) return "";
    return StaticData.getOnOffShelfForCreateOrEditNames[selectAccessIndex];
  }

  /// 上传按钮状态标志
  bool get uploadButtonFlag => (titleController.text.trim().isNotEmpty && contentController.text.trim().isNotEmpty && (selectAccessIndex != -1));

  final GlobalKey dialogKey = GlobalKey();
  final CancelToken cancelToken = CancelToken();

  @override
  void onInit() {
    super.onInit();
    _initFormData();
    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initFormData() {
    // 初始化表单数据
    titleController.text = entity.title ?? '';
    contentController.text = entity.lyrics ?? '';

    // 初始化上下架状态
    final int accessIndex = StaticData.onOffShelfForCreateOrEdit.indexWhere((element) => element.value == entity.access);
    selectAccessIndex = accessIndex >= 0 ? accessIndex : 0;
  }

  void _onListener() {
    titleController.addListener(() {
      _initData();
    });
    contentController.addListener(() {
      _initData();
    });
  }

  void _initData() {
    update(['manage_edit_song']);
  }

  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
    _initData();
  }

  // 编辑歌曲
  void onEditSong() async {
    try {
      final String title = titleController.text.trim();
      if (common.ObjectUtil.isEmpty(title)) {
        ToastUtils.showManageToast(text: "请填写标题", containerKey: dialogKey);
        return;
      }

      final String lyrics = contentController.text.trim();
      if (common.ObjectUtil.isEmpty(lyrics)) {
        ToastUtils.showManageToast(text: "请填写歌词", containerKey: dialogKey);
        return;
      }

      if (selectAccessIndex == -1) {
        ToastUtils.showManageToast(text: "请选择上架状态", containerKey: dialogKey);
        return;
      }

      var response = await ManageEnglishContentManagementSongRequest.editSong(
          uid: entity.uid.toString(),
          config: RequestConfig(data: {
            "title": title,
            "lyrics": lyrics,
            "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
          }, requireToken: true, cancelToken: cancelToken));

      if (response != null) {
        Get.back(result: response);
      }
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: "编辑歌曲失败", type: ManageToastType.error);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
