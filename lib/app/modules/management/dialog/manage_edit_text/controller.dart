import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart' as common;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditTextController extends BaseController {
  final EnKnowledgeEntity entity;

  ManageEditTextController(this.entity);

  /// 上传按钮状态标志
  bool get uploadButtonFlag => (titleController.text.trim().isNotEmpty && contentController.text.trim().isNotEmpty && (selectAccessIndex != -1));

  /// 标题
  final TextEditingController titleController = TextEditingController();

  /// 内容
  final TextEditingController contentController = TextEditingController();

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  final GlobalKey dialogKey = GlobalKey();

  // 获取上下架状态显示名称
  String get newAccessName {
    if (selectAccessIndex == -1) return "";
    return StaticData.getOnOffShelfForCreateOrEditNames[selectAccessIndex];
  }

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
    contentController.text = entity.content ?? '';

    // 初始化上下架状态
    final int accessIndex = StaticData.onOffShelfForCreateOrEdit.indexWhere((element) => element.value == entity.access);
    selectAccessIndex = accessIndex >= 0 ? accessIndex : 0;

  }

  void _initData() {
    update(['manage_edit_text']);
  }

  void _onListener() {
    titleController.addListener(() {
      _initData();
    });
    contentController.addListener(() {
      _initData();
    });
  }

  // 编辑文章
  void onEditText() async {
    try {
      final String title = titleController.text.trim();
      if (common.ObjectUtil.isEmpty(title)) {
        ToastUtils.showManageToast(text: "请填写标题", containerKey: dialogKey);
        return;
      }

      final String content = contentController.text.trim();
      if (common.ObjectUtil.isEmpty(content)) {
        ToastUtils.showManageToast(text: "请填写内容", containerKey: dialogKey);
        return;
      }

      if (selectAccessIndex == -1) {
        ToastUtils.showManageToast(text: "请选择上架状态", containerKey: dialogKey);
        return;
      }

      var response = await TextUtil.edit(
          uid: entity.uid.toString(),
          config: RequestConfig(data: {
            "title": title,
            "content": content,
            "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
          }, requireToken: true, cancelToken: cancelToken));

      if (response.data != null) {
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '编辑文章失败');
      }
    } on FormatException catch (e) {
      print("---编辑文章e: $e---");
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: "编辑文章失败", type: ManageToastType.error);
    }
  }


  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
    _initData();
  }


  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    cancelToken.cancel("取消编辑");
    super.onClose();
  }
}
