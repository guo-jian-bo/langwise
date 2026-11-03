

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fancy_tree_view2/flutter_fancy_tree_view2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/official_course_details.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../generated/assets.dart';
import '../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/official_course_details_controller.dart';

/// 编辑自定义课程弹窗
class EditCustomCoursesDialog{

  static Future<void> show({
    required BuildContext context,
    required int courseId,
  }) async{
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return EditCustomCoursesDialogWidget(courseId: courseId);
      },
    );
  }

}


class EditCustomCoursesDialogWidget extends StatefulWidget {
  final int courseId;
  const EditCustomCoursesDialogWidget({
    super.key,
    required this.courseId,
  });

  @override
  State<EditCustomCoursesDialogWidget> createState() => _EditCustomCoursesDialogWidgetState();
}

class _EditCustomCoursesDialogWidgetState extends State<EditCustomCoursesDialogWidget> {
  Node? root;
  TreeController<Node>? treeController;
  bool isInit = false;

  CustomizedCoursesLMEntityList? courseData;

  @override
  void initState() {
    super.initState();
    
    getCourseInfo();
  }

  @override
  void dispose() {
    treeController?.dispose();
    super.dispose();
  }

  /// 获取课程信息
  Future<void> getCourseInfo() async{
    isInit = false;
    treeController?.dispose();
    root = Node(id: 0, data: null, level: -1);
    if(mounted) setState(() {});

    try {
      ToastUtils.showLoading();
      CustomizedCoursesLMEntity? entity = await OfficialCourseDetailsRequest.getCourseInfo(widget.courseId);
      if(entity == null) return;
      List<CustomizedCoursesLMEntityList?> cList = entity.list??[];

      for(CustomizedCoursesLMEntityList? item in cList){
        if(item == null) continue;
        if(item.uid == widget.courseId){
          courseData = item;
          break;
        }
      }

      if(courseData == null) return;
      List<CustomizedCoursesLMEntityListLevelList?> lList = courseData!.levelList??[];

      for(CustomizedCoursesLMEntityListLevelList? lItem in lList){
        if(lItem?.uid == null) continue;

        Node levelNode = Node(id: lItem!.uid!, data: lItem, level: 0);

        List<CustomizedCoursesLMEntityListLevelListModuleList?> mList = lItem.moduleList??[];
        for(CustomizedCoursesLMEntityListLevelListModuleList? mItem in mList){
          if(mItem?.uid == null) continue;

          Node moduleNode = Node(id: mItem!.uid!, data: mItem, level: 1);
          levelNode.insertChild(levelNode._children.length, moduleNode);
        }

        root!._children.add(levelNode);
      }

      treeController = TreeController<Node>(
        roots: root!.children,
        childrenProvider: (Node node) => node.children,
        parentProvider: (Node node) => node.parent,
      );
      treeController?.expandAll();

      isInit = true;

      if(mounted) setState(() {});
      
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 编辑课程名称
  Future<void> editCourseName() async{
    String? resName = await InputDialog.show(
      context: context,
      title: "课程重命名",
      content: "新课程名称",
      hintText: "请输入课程名称",
      realName: courseData?.name,
      maxLength: 20,
    );
    if(resName == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "name": resName,
      };
      bool res = await OfficialCourseDetailsRequest.editCourse(widget.courseId, reqData);
      if(!res) return;
      courseData?.name = resName;
      if(Get.isRegistered<HomeController>()){
        Get.find<HomeController>().initHomeCardList();
      }
      if(Get.isRegistered<OfficialCourseDetailsController>()){
        Get.find<OfficialCourseDetailsController>().getModuleList(isLoading: false);
      }
      if(mounted) setState(() {});
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑等级名称
  Future<void> editLevelName(CustomizedCoursesLMEntityListLevelList data) async{
    if(data.uid == null) return;
    String? resName = await InputDialog.show(
      context: context,
      title: "等级重命名",
      content: "新等级名称",
      hintText: "请输入新等级名称",
      realName: data.name,
    );
    if(resName == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "name": resName,
      };
      bool res = await OfficialCourseDetailsRequest.editLevel(data.uid!, reqData);
      if(!res) return;
      data.name = resName;
      if(Get.isRegistered<HomeController>()){
        Get.find<HomeController>().initHomeCardList();
      }
      if(Get.isRegistered<OfficialCourseDetailsController>()){
        Get.find<OfficialCourseDetailsController>().getModuleList(isLoading: false);
      }
      if(mounted) setState(() {});
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除等级
  Future<void> deleteLevel(CustomizedCoursesLMEntityListLevelList data) async{
    if(data.uid == null) return;
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认删除当前等级吗？",
      showLastCountdown: true,
    );
    if(!askRes) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "courseId": widget.courseId,
      };
      bool res = await OfficialCourseDetailsRequest.levelStatusSwitch(data.uid!, parameters);
      if(!res) return;
      
      root?._children.removeWhere((element) => element.id == data.uid);
      treeController?.rebuild();

      if(Get.isRegistered<HomeController>()){
        await Get.find<HomeController>().initHomeCardList();
      }

      if(root?._children.isEmpty??false){
        Get.back();
        Get.back();
        return;
      }

      if(Get.isRegistered<OfficialCourseDetailsController>()){
        Get.find<OfficialCourseDetailsController>().otherDeleteLevelRefresh(data.uid);
      }

      if(mounted) setState(() {});
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑模块名称
  Future<void> editModuleName(CustomizedCoursesLMEntityListLevelListModuleList data) async{
    if(data.uid == null) return;
    String? resName = await InputDialog.show(
      context: context,
      title: "模块重命名",
      content: "新模块名称",
      hintText: "请输入新模块名称",
      realName: data.name,
    );
    if(resName == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "name": resName,
      };
      bool res = await OfficialCourseDetailsRequest.editModule(data.uid!, reqData);
      if(!res) return;
      data.name = resName;
      if(Get.isRegistered<HomeController>()){
        Get.find<HomeController>().initHomeCardList();
      }
      if(Get.isRegistered<OfficialCourseDetailsController>()){
        Get.find<OfficialCourseDetailsController>().getModuleList(isLoading: false);
      }
      if(mounted) setState(() {});
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 修改模块封面
  Future<void> editModuleCover(CustomizedCoursesLMEntityListLevelListModuleList data) async{
    if(data.uid == null) return;
    File? file = await ImagePickerUtils.selectPicture(context: context, withCircleUi: false, cropAspectRatio: 3 / 4);
    if(file == null) return;
    try {
      ToastUtils.showLoading();
      OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile(
        filePath: file.path,
      );
      
      if(record == null || record.url == null || record.key == null) return;
      String url = record.url!;
      String key = record.key!;
      Map<String, dynamic> reqData = {
        "cover": key,
      };
      bool res = await OfficialCourseDetailsRequest.editModule(data.uid!, reqData);
      if(!res) return;
      data.coverUrl = url;

      if(Get.isRegistered<HomeController>()){
        Get.find<HomeController>().initHomeCardList();
      }
      if(Get.isRegistered<OfficialCourseDetailsController>()){
        Get.find<OfficialCourseDetailsController>().getModuleList(isLoading: false);
      }
      if(mounted) setState(() {});
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除模块
  Future<void> deleteModule(TreeEntry<Node> entry, CustomizedCoursesLMEntityListLevelListModuleList data) async{
    if(data.uid == null) return;
    
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认删除当前模块吗？",
      showLastCountdown: true,
    );
    if(!askRes) return;
    try {
      ToastUtils.showLoading();
      bool res = await OfficialCourseDetailsRequest.moduleStatusSwitch(data.uid!);
      if(!res) return;

      root?._children.forEach((element) {
        element._children.removeWhere((element) => element.id == data.uid);
      });

      treeController?.rebuild();

      if(Get.isRegistered<HomeController>()){
        Get.find<HomeController>().initHomeCardList();
      }
      if(Get.isRegistered<OfficialCourseDetailsController>()){
        Get.find<OfficialCourseDetailsController>().otherDeleteModuleRefresh(data.uid);
      }
      
      if(mounted) setState(() {});
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);

    } finally{
      ToastUtils.hideLoading();
    }
  }


  void onNodeAcceptedLevel(TreeDragAndDropDetails<Node> details) {
    final Node draggedNode = details.draggedNode;
    final Node? targetNode = details.targetNode;
    // if(draggedNode.level == 1) return;
    
    details.mapDropPosition(
      whenAbove: () {
        if(draggedNode.level == 1) return;
        Node? newParent;
        int newIndex;
        newParent = root; // 使用虚拟根节点作为父节点
        
        // 获取拖拽节点和目标节点的当前索引
        int draggedIndex = root!._children.indexOf(draggedNode);
        int targetIndex = root!._children.indexOf(targetNode!);
        
        // 计算新索引：如果拖拽节点在目标节点之前，目标索引不变；否则目标索引需要减1
        if (draggedIndex < targetIndex) {
          newIndex = targetIndex - 1;
        } else {
          newIndex = targetIndex;
        }
        
        // 确保索引在有效范围内
        newIndex = newIndex.clamp(0, root!._children.length - 1);

        // 确保 newParent 不为 null
        if (newParent != null) {
          levelSort(draggedNode, newIndex);
        }
      },
      whenInside: () {
        if(draggedNode.level == 0) return;
        if(targetNode == null) return;
        moduleSort(draggedNode, targetNode, 0);
      },
      whenBelow: () {
        if(draggedNode.level == 1) return;
        Node? newParent;
        int newIndex;
        
        newParent = root; // 使用虚拟根节点作为父节点
        
        // 获取拖拽节点和目标节点的当前索引
        int draggedIndex = root!._children.indexOf(draggedNode);
        int targetIndex = root!._children.indexOf(targetNode!);
        
        // 计算新索引：如果拖拽节点在目标节点之前，新索引为目标索引；否则新索引为目标索引+1
        if (draggedIndex < targetIndex) {
          newIndex = targetIndex;
        } else {
          newIndex = targetIndex + 1;
        }
        
        // 确保索引在有效范围内
        newIndex = newIndex.clamp(0, root!._children.length - 1);
        
        // 确保 newParent 不为 null
        if (newParent != null) {
          levelSort(draggedNode, newIndex);
        }
      },
    );
  }

  /// 等级排序
  Future<void> levelSort(Node draggedNode, int newIndex) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "courseId": widget.courseId,
        "levelId": draggedNode.id,
        "target": newIndex,
      };
      bool res = await OfficialCourseDetailsRequest.sortLevelModule(reqData);
      if(!res) return;
      
      // 先从当前位置移除节点
      draggedNode._parent?._children.remove(draggedNode);
      draggedNode._parent = null;
      // 然后插入到新位置
      root!.insertChild(newIndex, draggedNode);
      treeController?.rebuild();

      if(Get.isRegistered<HomeController>()){
        Get.find<HomeController>().initHomeCardList();
      }

    } finally{
      ToastUtils.hideLoading();
    }

  }



  void onNodeAcceptedModule(TreeDragAndDropDetails<Node> details) {
    if(details.draggedNode.level == 0) return;  // 父节点不允许拖动到子节点
    
    final draggedNode = details.draggedNode;
    final targetNode = details.targetNode;
    
    details.mapDropPosition(
      whenAbove: () {
        // 模块拖拽到另一个模块上方
        if (targetNode.level == 1) {
          // 目标是模块，可以进行排序
          Node? newParent = targetNode._parent; // 获取目标模块的父节点（等级节点）
          if (newParent != null) {
            // 计算新索引：在目标模块之前插入
            int targetIndex = newParent._children.indexOf(targetNode);
            int draggedIndex = draggedNode._parent?._children.indexOf(draggedNode) ?? -1;
            
            int newIndex;
            // 如果是同一个父节点内移动
            if (draggedNode._parent == newParent && draggedIndex < targetIndex) {
              newIndex = targetIndex - 1;
            } else {
              newIndex = targetIndex;
            }
            
            newIndex = newIndex.clamp(0, newParent._children.length - 1);
            moduleSort(draggedNode, newParent, newIndex);
          }
        } else if (targetNode.level == 0) {
          // 目标是等级节点，将模块移动到该等级的第一个位置
          Node newParent = targetNode;
          moduleSort(draggedNode, newParent, 0);
        }
      },
      whenInside: () {
        // 模块拖拽到等级节点内部
        if (targetNode.level == 0) {
          // 目标是等级节点，将模块添加到该等级的末尾
          Node newParent = targetNode;
          int newIndex = newParent._children.length;
          moduleSort(draggedNode, newParent, newIndex);
        }
      },
      whenBelow: () {
        // 模块拖拽到另一个模块下方
        if (targetNode.level == 1) {
          // 目标是模块，可以进行排序
          Node? newParent = targetNode._parent; // 获取目标模块的父节点（等级节点）
          if (newParent != null) {
            // 计算新索引：在目标模块之后插入
            int targetIndex = newParent._children.indexOf(targetNode);
            int draggedIndex = draggedNode._parent?._children.indexOf(draggedNode) ?? -1;
            
            int newIndex;
            // 如果是同一个父节点内移动
            if (draggedNode._parent == newParent && draggedIndex < targetIndex) {
              newIndex = targetIndex;
            } else {
              newIndex = targetIndex + 1;
            }
            
            newIndex = newIndex.clamp(0, newParent._children.length);
            moduleSort(draggedNode, newParent, newIndex);
          }
        } else if (targetNode.level == 0) {
          // 目标是等级节点，将模块移动到该等级的末尾
          Node newParent = targetNode;
          int newIndex = newParent._children.length;
          moduleSort(draggedNode, newParent, newIndex);
        }
      },
    );
  }

  /// 模块排序
  Future<void> moduleSort(Node draggedNode, Node newParent, int newIndex) async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "courseId": widget.courseId,
        "moduleId": draggedNode.id, // 原本的模块id
        "levelId": draggedNode._parent?.id, // 原本的等级id（拖拽节点的父节点ID）
        "targetLevelId": newParent.id, // 目标等级id
        "target": newIndex + 1,
      };
      bool res = await OfficialCourseDetailsRequest.sortLevelModule(reqData);
      if (!res) return;

      // 先从当前位置移除节点
      draggedNode._parent?._children.remove(draggedNode);
      draggedNode._parent = null;
      // 然后插入到新位置
      newParent.insertChild(newIndex, draggedNode);
      treeController?.rebuild();
      if(Get.isRegistered<HomeController>()){
        Get.find<HomeController>().initHomeCardList();
      }
      if(Get.isRegistered<OfficialCourseDetailsController>()){
        Get.find<OfficialCourseDetailsController>().otherDeleteModuleRefresh(draggedNode.id);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 900.wMin,
          height: 937.wMin,
          
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary,
            borderRadius: BorderRadius.circular(16.wMin),
          ),
          child: Column(
            children: [
              SizedBox(height: 32.wMin),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                child: Column(
                  children: [
                    _buildTitle(),
                    _buildCourseInfo(),
                  ],
                ),
              ),
              Expanded(
                child: _buildLevelList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildTitle(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            "编辑当前课程信息",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TapScaleWidget(
          sclae: 1.05,
          onTap: () => Get.back(),
          child: Container(
            width: 42.wMin,
            height: 42.wMin,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cBgActive,
            ),
            child: SvgPicture.asset(
              "assets/svg/public/x.svg",
              width: 24.wMin,
              height: 24.wMin,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCourseInfo(){
    return Container(
      padding: EdgeInsets.only(top: 16.wMin),
      child: Row(
        spacing: 24.wMin,
        children: [
          Expanded(
            child: Text(
              courseData?.name??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TapScaleWidget(
            onTap: () {
              editCourseName();
            },
            sclae: 1.05,
            child: _buildEditIcon(),
          ),

        ],
      ),
    );
  }

  Widget _buildLevelList(){
    if(!isInit) return Container();
    return AnimatedTreeView<Node>(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 16.wMin),
      treeController: treeController!,
      nodeBuilder: (context, entry) {
        if(entry.level == 0){
          return _buildLevelItem(entry);
        }
        return _buildModItem(entry);
      },
    );
  }

    
  Widget _buildLevelItem(TreeEntry<Node> entry){

    final BorderSide borderSide = BorderSide(
      color: AppTheme.cBorderFocus.color,
      width: 1.wMin,
    );

    final BorderSide notBorderSide = BorderSide(
      color: Colors.transparent,
      width: 1.wMin,
    );

    CustomizedCoursesLMEntityListLevelList lItem = entry.node.data;
    return TreeDragTarget<Node>(
      node: entry.node,
      onNodeAccepted: onNodeAcceptedLevel,
      builder: (context, details) {

        Decoration decoration = BoxDecoration(
          border: Border.all(width: 1.wMin, color: Colors.transparent),
        );

        if (details != null) {
          decoration = BoxDecoration(
            border: details.mapDropPosition(
              whenAbove: () {
                if(details.draggedNode.level == 1){
                  return Border.all(width: 1.wMin, color: Colors.transparent);
                }
                return Border(top: borderSide, bottom: notBorderSide, left: notBorderSide, right: notBorderSide);
              },
              whenInside: () {
                if(details.draggedNode.level == 0){
                  return Border.all(width: 1.wMin, color: Colors.transparent);
                }
                return Border.fromBorderSide(borderSide);
              },
              whenBelow: () {
                if(details.draggedNode.level == 1){
                  return Border.all(width: 1.wMin, color: Colors.transparent);
                }
                return Border(bottom: borderSide, top: notBorderSide, left: notBorderSide, right: notBorderSide);
              }
            ),
          );
        }

        return AnimatedOpacity(
          opacity: entry.node.isMove ? 0.3 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            decoration: decoration,
            padding: EdgeInsets.symmetric(vertical: 8.wMin),
            child: Row(
              children: [
          
                TreeDraggable<Node>(
                  node: entry.node,
                  feedback: _buildLevelItemTitle(lItem.name??""),
                  child: _buildSortIcon(),
                  onDragStarted: () {
                    HapticFeedback.lightImpact();
                    entry.node.isMove = true;
                    if(mounted) setState(() {});
                  },
                  onDragEnd: (details) {
                    entry.node.isMove = false;
                    if(mounted) setState(() {});
                  },
                ),
                
                                
                Expanded(
                  child: TapScaleWidget(
                    onTap: () {
                      treeController?.toggleExpansion(entry.node);
                    },
                    sclae: 1,
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          _buildArrowIcon(entry),
                          Expanded(
                            child: Text(
                              lItem.name??"",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TapScaleWidget(
                  onTap: () {
                    editLevelName(lItem);
                  },
                  sclae: 1.05,
                  child: _buildEditIcon(),
                ),
                Container(width: 1.wMin, height: 16.wMin, color: AppTheme.cTextTertiary),
                TapScaleWidget(
                  onTap: () {
                    deleteLevel(lItem);
                  },
                  sclae: 1.05,
                  child: _buildDeleteIcon(),
                ),
              ],
            ),
          ),
        );
      },
    );
    
  }

  Widget _buildLevelItemTitle(String name){
    return Transform.translate(
      offset: Offset(-200.wMin, 0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 50.wMin,
          width: 500.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: AppTheme.cBgTertiary,
          ),
          child: Row(
            children: [
               _buildSortIcon(),
               Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModItem(TreeEntry<Node> entry){
    CustomizedCoursesLMEntityListLevelListModuleList mItem = entry.node.data;

    final BorderSide borderSide = BorderSide(
      color: AppTheme.cBorderFocus.color,
      width: 1.wMin,
    );

    final BorderSide notBorderSide = BorderSide(
      color: Colors.transparent,
      width: 1.wMin,
    );

    return TreeDragTarget<Node>(
      node: entry.node,
      onNodeAccepted: onNodeAcceptedModule,
      builder: (context, details) {
        Decoration decoration = BoxDecoration(
          border: Border.all(width: 1.wMin, color: Colors.transparent),
        );

        if (details != null) {
          decoration = BoxDecoration(
            border: details.mapDropPosition(
              whenAbove: () {
                if(details.draggedNode.level == 0){
                  return Border.all(width: 1.wMin, color: Colors.transparent);
                }
                return Border(top: borderSide, bottom: notBorderSide, left: notBorderSide, right: notBorderSide);
              },
              whenInside: () {
                return Border.all(width: 1.wMin, color: Colors.transparent);
              },
              whenBelow: () {
                if(details.draggedNode.level == 0){
                  return Border.all(width: 1.wMin, color: Colors.transparent);
                }
                return Border(bottom: borderSide, top: notBorderSide, left: notBorderSide, right: notBorderSide);
              }
            ),
          );
        }

        return AnimatedOpacity(
          opacity: entry.node.isMove ? 0.3 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            margin: EdgeInsets.only(left: 48.wMin, top: 8.wMin, bottom: 8.wMin),
            padding: EdgeInsets.symmetric(vertical: 8.wMin),
            decoration: decoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          
                TreeDraggable<Node>(
                  node: entry.node,
                  feedback: _buildModItemTitle(entry),
                  child: _buildSortIcon(),
                  onDragStarted: () {
                    HapticFeedback.lightImpact();
                    entry.node.isMove = true;
                    if(mounted) setState(() {});
                  },
                  onDragEnd: (details) {
                    entry.node.isMove = false;
                    if(mounted) setState(() {});
                  },
                ),
                
          
                SizedBox(width: 8.wMin),
                TapScaleWidget(
                  onTap: () {
                    editModuleCover(mItem);
                  },
                  sclae: 1.01,
                  child: SizedBox(
                    height: 180.wMin,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.wMin),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            CachedImageWidget(
                              mItem.coverUrl??"",
                              errorWidget: Image.asset(
                                "assets/images/custom_course/module_default.png",
                                fit: BoxFit.cover,
                              ),
                              placeholder: buildLoadingWidget(),
                              fit: BoxFit.cover,
                            ),
                            Visibility(
                              visible: mItem.customStatusInt != 1,
                              child: Container(
                                color: AppTheme.cBlackAlpha70,
                                alignment: Alignment.center,
                                child: Text(
                                  mItem.customStatusInt == 2 ? "生成失败" : "生成中",
                                  style: TextStyle(
                                    fontSize: 20.wMin,
                                    color: mItem.customStatusInt == 2 ? AppTheme.cFeedbackErrorText : AppTheme.cStaticWhite,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              color: AppTheme.cBlackAlpha50,
                              alignment: Alignment.center,
                              height: 32.wMin,
                              child: Text(
                                "修改",
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  color: AppTheme.cStaticWhite,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.wMin),
                Expanded(
                  child: Text(
                    mItem.name??"",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TapScaleWidget(
                      onTap: () {
                        editModuleName(mItem);
                      },
                      sclae: 1.05,
                      child: _buildEditIcon(),
                    ),
                    Container(width: 1.wMin, height: 16.wMin, color: AppTheme.cTextTertiary),
                    TapScaleWidget(
                      onTap: () {
                        deleteModule(entry, mItem);
                      },
                      sclae: 1.05,
                      child: _buildDeleteIcon(),
                    ),
                  ],
                ),
          
              ],
            ),
          ),
        );
      },
    );

    
  }

  Widget _buildModItemTitle(TreeEntry<Node> entry){
    CustomizedCoursesLMEntityListLevelListModuleList mItem = entry.node.data;
    return Transform.translate(
      offset: Offset(-200.wMin, 0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 650.wMin,
          height: 90.wMin,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: AppTheme.cBgTertiary,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSortIcon(),
              SizedBox(width: 8.wMin),
              SizedBox(
                height: 80.wMin,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.wMin),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: CachedImageWidget(
                      mItem.coverUrl??"",
                      errorWidget: buildEmptyWidget(),
                      placeholder: buildLoadingWidget(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.wMin),
              Expanded(
                child: Text(
                  mItem.name??"",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortIcon(){
    return Container(
      color: Colors.transparent,
      child: SvgPicture.asset(
        Assets.customCourseIconSixVertical,
        width: 32.wMin,
        colorFilter: const ColorFilter.mode(AppTheme.cTextTertiary, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildArrowIcon(TreeEntry<Node> entry){
    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      color: Colors.transparent,
      padding: EdgeInsets.all(8.wMin),
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 100),
        turns: entry.isExpanded ? 0 : -0.25,
        child: SvgPicture.asset(
          Assets.publicIconArrowDown ,
          width: 32.wMin,
          colorFilter: const ColorFilter.mode(AppTheme.cTextTertiary, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildEditIcon(){
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      child: SvgPicture.asset(
        Assets.customCourseIconBookInfoEdit,
        width: 32.wMin,
        height: 32.wMin,
      ),
    );
  }

  Widget _buildDeleteIcon(){
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      child: SvgPicture.asset(
        Assets.customCourseIconBookInfoTrash,
        width: 32.wMin,
        height: 32.wMin,
      ),
    );
  }



}


class Node {
  Node({
    required this.id,
    required this.data,
    required this.level,
    this.isMove = false,
    Iterable<Node>? children,
  }) : _children = <Node>[] {
    // 添加唯一性检查
    assert(id >= 0, 'Node id must be non-negative');
    
    if (children == null) return;

    for (final Node child in children) {
      child._parent = this;
      _children.add(child);
    }
  }

  final int id;
  final dynamic data;
  final int level;
  bool isMove;
  final List<Node> _children;

  Iterable<Node> get children => _children;
  bool get isLeaf => _children.isEmpty;

  Node? get parent => _parent;
  Node? _parent;

  int get index => _parent?._children.indexOf(this) ?? -1;

  void insertChild(int index, Node node) {
    // 先移除节点（如果它已经是当前节点的子节点）
    bool wasAlreadyChild = _children.contains(node);
    if (wasAlreadyChild) {
      _children.remove(node);
    }
    
    // 检查是否已存在相同id的其他节点
    if (_children.any((child) => child.id == node.id)) {
      print('Warning: Node with id ${node.id} already exists in children');
      // 如果之前移除了节点，需要重新添加回去
      if (wasAlreadyChild) {
        _children.add(node);
      }
      return;
    }

    // Adjust the index if necessary when dropping a node at the same parent
    if (node._parent == this && node.index >= 0 && node.index < index && !wasAlreadyChild) {
      index--;
    }

    // 确保节点从之前的父节点中移除并更新父节点引用
    if (!wasAlreadyChild) {
      node._parent?._children.remove(node);
    }
    node._parent = this;

    // 确保索引在有效范围内
    index = index.clamp(0, _children.length);
    
    _children.insert(index, node);
  }
}

extension on TreeDragAndDropDetails<Node> {
  /// Splits the target node's height in three and checks the vertical offset
  /// of the dragging node, applying the appropriate callback.
  T mapDropPosition<T>({
    required T Function() whenAbove,
    required T Function() whenInside,
    required T Function() whenBelow,
  }) {
    final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
    final double pointerVerticalOffset = dropPosition.dy;

    if (pointerVerticalOffset < oneThirdOfTotalHeight) {
      return whenAbove();
    } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
      return whenInside();
    } else {
      return whenBelow();
    }
  }
}