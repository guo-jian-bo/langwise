import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:langwise/app/modules/management/manage_content/manage_audio_subtitle_editor/controllers/manage_audio_subtitle_editor_controller.dart';

import '../../../routes/routes.dart';
import '../models/models.dart';
import '../utils/manage_breadcrumb_utils.dart';
import '../utils/manage_page_registry.dart';

class ManagementBreadcrumbController extends GetxController{
  /// 是否收起底部菜单栏
  final RxBool isBottomMenuCollapsed = false.obs;

  /// 页面书签 - 临时书签 后面想办法持久化
  final RxList<ManagePageBookmarkModel> _pageBookmarks = <ManagePageBookmarkModel>[].obs;

  /// 页面书签 - 临时书签 后面想办法持久化
  List<ManagePageBookmarkModel> get pageBookmarks => _pageBookmarks;
  

  /// 管理端面包屑
  final RxList<ManagementBreadcrumbItem> _manageBreadcrumbs = <ManagementBreadcrumbItem>[].obs;

  /// 管理端面包屑
  List<ManagementBreadcrumbItem> get breadcrumbs => _manageBreadcrumbs;

  /// 收起底部菜单栏
  void collapseBottomMenu(){
    isBottomMenuCollapsed.value = true;
  }

  /// 展开底部菜单栏
  void expandBottomMenu(){
    isBottomMenuCollapsed.value = false;
  }
  

  /// 点击面包屑返回
  Future<void> breadcrumbBack() async {
    ManageAudioSubtitleEditorController.markAllAudioEditorsLeavingPage();
    await _stopAudioEditorIfNeeded();
    if(ManageBreadcrumbUtils.isRootRoute()){
      await closeManage();
      return;
    }
    Get.back();
  }


  /// 退出管理端
  Future<void> closeManage() async {
    ManageAudioSubtitleEditorController.markAllAudioEditorsLeavingPage();
    await _stopAudioEditorIfNeeded();
    // 返回到应用主页面
    Get.until((r) => r.settings.name == Routes.MANAGEMENT);
    Get.back();
  }

  /// 增加管理端面包屑
  void addBreadcrumb(ManagementBreadcrumbItem item){
    _manageBreadcrumbs.add(item);
  }

  /// 根据id删除管理端面包屑
  void removeBreadcrumb(String id){
    _manageBreadcrumbs.removeWhere((element) => element.id == id);
  }


  /// 删除 page 之后的所有面包屑
  void removeBreadcrumbsAfterPage(String page){
    for(int i = _manageBreadcrumbs.length - 1; i >= 0; i--){
      if(_manageBreadcrumbs[i].route == page) break;
      _manageBreadcrumbs.removeAt(i);
    }
  }

  /// 清空面包屑并设置新的根面包屑
  void clearAndSetBreadcrumb(ManagementBreadcrumbItem item){
    _manageBreadcrumbs.clear();
    _manageBreadcrumbs.add(item);
  }

  /// 清空所有面包屑
  void clearAllBreadcrumb(){
    _manageBreadcrumbs.clear();
  }

  /// 更新面包屑
  void updateBreadcrumb(ManagementBreadcrumbItem item){
    int index = _manageBreadcrumbs.indexWhere((element) => element.id == item.id);
    if(index != -1){
      _manageBreadcrumbs[index] = item;
    }
  }


  /// 点击面包屑
  Future<void> onTapBreadcrumb(ManagementBreadcrumbItem item) async {
    if(item.disabled){
      return;
    }
    if(item.route == Routes.MANAGEMENT){
      return;
    }

    ManageAudioSubtitleEditorController.markAllAudioEditorsLeavingPage();
    await _stopAudioEditorIfNeeded();
    // 使用 Get.until 返回到指定路由
    Get.until((route) => route.settings.name == item.route);
  }


  /// 停止音频编辑器的音频播放（如果需要）
  Future<void> _stopAudioEditorIfNeeded() async {
    try {
      await ManageAudioSubtitleEditorController.stopAllAudioEditors();
    } catch (e) {
      debugPrint('[BreadcrumbController] 停止音频编辑器时出错: $e');
    }
  }


  /// 收藏此页面
  Future<void> collectPage(BuildContext context) async{
    String? res = await InputDialog.show(
      context: context,
      title: "收藏页面",
      content: "页面名称：${breadcrumbs.last.title}",
      hintText: "备注",
      maxLength: 50,
      required: false,
    );
    if(res == null) return;

    _pageBookmarks.add(ManagePageBookmarkModel(
      route: Get.currentRoute,
      name: breadcrumbs.last.title??"",
      remark: res,
      arguments: Get.arguments,
    ));

    ToastUtils.showToast(text: "已收藏", type: ToastType.success);
  }

  /// 修改收藏名称
  Future<void> editPageBookmark(BuildContext context, int index) async{
     String? res = await InputDialog.show(
      context: context,
      title: "修改备注",
      content: "备注",
      hintText: "请输入备注",
      maxLength: 50,
      required: false,
      realName: _pageBookmarks[index].remark,
    );
    if(res == null) return;
    _pageBookmarks[index].remark = res;
    _pageBookmarks.refresh();
    ToastUtils.showToast(text: "已修改", type: ToastType.success);
  }

  /// 删除收藏
  void removePageBookmark(int index){
    _pageBookmarks.removeAt(index);
  }

  /// 收藏跳转页面
  Future<void> jumpToPageBookmark(BuildContext context, int index) async{
    ManagePageBookmarkModel bookmark = _pageBookmarks[index];
    ManagePageRegistry.jumpTo(bookmark.route, arguments: bookmark.arguments);
  }
}
