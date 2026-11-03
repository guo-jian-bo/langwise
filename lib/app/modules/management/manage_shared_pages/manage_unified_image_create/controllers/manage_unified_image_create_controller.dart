import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../routes/routes.dart';
import '../../../enums/enums.dart';
import '../../../manage_content/manage_zhendu_console/enums/manage_zhendu_enums.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../enums/manage_unified_image_create_enums.dart';
import '../views/manage_unified_image_create_size_dialog.dart';

class ManageUnifiedImageCreateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageUnifiedImageCreateController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIFIED_IMAGE_CREATE;

  @override
  String get breadcrumbTitle => '统一图片创建';

  // 传进来的参数
  /// 图片id列表 图片编辑时传
  List<int?>? imageIds;
  /// uid 必传
  int? uid;
  /// 类型 必传
  String? type;
  /// 语义id 有语义id时传
  int? semanticId;
  /// 角色设定图类型 创建角色设定图时传
  ManageZhenduPersonaViewEnum? viewType;
  /// 场景图片帧类型 修改场景分镜图时传 
  SceneStoryboardTypeEnum? sceneType;
  /// 视觉项目id 改场景分镜图时必传或者创建场景分镜图时必传
  int? visualProjectId;
  /// 风格id
  int? styleId;
  /// 提示词id
  int? promptId;
  /// 图片生成失败需要跳转的code
  String? jumpCode;
  /// 图片生成需要的路由参数
  Map<String, dynamic>? params;


  /// 图片详情
  final Rx<ManageCreateImageInfoEntity> imageDetail = ManageCreateImageInfoEntity().obs;

  /// 参考图片列表
  final RxList<ManageCreateImageInfoEntityImages> referenceImages = <ManageCreateImageInfoEntityImages>[].obs;

  /// 风格数据
  Map<String, List<ImageStyleConfigV2Item>> styleData = {};
  /// 图片风格列表
  final RxList<String> styleKeyList = <String>[].obs;
  /// 选中的画风
  final RxString selectedStyleKey = ''.obs;
  /// 图片风格地区列表
  final RxList<ImageStyleConfigV2Item> styleAreaList = <ImageStyleConfigV2Item>[].obs;
  /// 选中的地区code
  final RxString selectedStyleAreaCode = ''.obs;
  /// 当前选中的styleId
  final RxInt selectedStyleId = (-1).obs;

  /// 提示词输入框 - 文生图
  final TextEditingController promptTextController = TextEditingController();
  /// 提示词输入框 - 图片编辑
  final TextEditingController promptEditController = TextEditingController();
  /// 提示词输入框 - 复用提示词
  final TextEditingController promptReuseController = TextEditingController();
  /// 提示词输入框 - 转换风格
  final TextEditingController promptConvertStyleController = TextEditingController();


  /// 生成模式
  final Rx<GenerationModeEnum> generationMode = GenerationModeEnum.textToImage.obs;

  /// 模型模式
  final Rx<ModeModuleEnum> modeModule = ModeModuleEnum.auto.obs;

  /// 生成数量
  final RxInt generateCount = 4.obs;

  /// 图片比例
  final Rx<ImageAspectRatioEnums> aspectRatio = ImageAspectRatioEnums.ratio_1_1.obs;

  /// 图片质量
  final Rx<ImageQualityEnums> quality = ImageQualityEnums.quality_2048.obs;

  /// 图片原始宽高
  final Rx<Size> imageOrgSize = Size.zero.obs;

  /// 是否锁定尺寸选择
  final RxBool isLockSize = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      final dynamic rawImageIds = Get.arguments['imageIds'];
      if(rawImageIds is Iterable){
        imageIds = rawImageIds.whereType<int?>().toList();
      }

      jumpCode = Get.arguments['jumpCode'];

      final dynamic rawParams = Get.arguments['params'];
      if(rawParams is Map<String, dynamic>){
        params = rawParams;
      } else if(rawParams is Map){
        params = Map<String, dynamic>.from(rawParams);
      }

      uid = Get.arguments['uid'];
      type = Get.arguments['type'];
      semanticId = Get.arguments['semanticId'];
      String? viewTypeStr = Get.arguments['viewType'];
      if(viewTypeStr != null){
        viewType = ManageZhenduPersonaViewEnum.fromValue(viewTypeStr);
      } 
      String? sceneTypeStr = Get.arguments['sceneType'];
      if(sceneTypeStr != null){
        sceneType = SceneStoryboardTypeEnum.fromValue(sceneTypeStr);
      }

      visualProjectId = Get.arguments['visualProjectId'];
      promptId = Get.arguments['promptId'];
      styleId = Get.arguments['styleId'];
      selectedStyleId.value = styleId ?? -1;
      queryImageDetail();
    }
    queryImageStyleList();
  }

  /// 查询图片详情
  Future<void> queryImageDetail() async{
    // if(uid == null || type == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "subContent": {
          "uid": uid,
          "type": type,
          "semanticId": semanticId,
        }, 
        "imageIds": imageIds,
        "viewType": viewType?.value,
        "sceneType": sceneType?.value,
        "visualProjectId": visualProjectId,
        "styleId": styleId,
        "promptId": promptId,
      };
      ManageCreateImageInfoEntity? res = await LanguageConsoleRequest.queryCreateImageInfo(data: reqData);
      if(res == null) return;
      imageDetail.value = res;

      generationMode.value = GenerationModeEnum.fromValue(res.mode) ?? GenerationModeEnum.textToImage;

      String prompt = (imageDetail.value.prompt ?? "").replaceAll(r'\r\n', '\n').replaceAll(r'\n', '\n');
      promptReuseController.text = prompt;
      promptConvertStyleController.text = prompt;


      modeModule.value = ModeModuleEnum.fromValue(res.modelMode) ?? ModeModuleEnum.auto;
      generateCount.value = res.output?.numberOfImages ?? 4;
      Size orgSize = Size(res.output?.width?.toDouble() ?? 0, res.output?.height?.toDouble() ?? 0);
      imageOrgSize.value = orgSize;
      if(res.output?.width != null && res.output?.height != null){
        isLockSize.value = true;
      }
      
      aspectRatio.value = ImageAspectRatioUtils.getAspectRatio(orgSize) ?? ImageAspectRatioEnums.ratio_1_1;
      quality.value = ImageAspectRatioUtils.getQuality(orgSize) ?? ImageQualityEnums.quality_2048;

      referenceImages.value = res.images?.whereType<ManageCreateImageInfoEntityImages>().toList() ?? [];

      for (var element in referenceImages) {
        element.isDefault = true;
      }


    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 查询图片生成数量
  Future<void> getImageGenerateCount() async{
    try {
      Map<String, dynamic> reqData = {
        "subContent": {
          "uid": uid,
          "type": type,
          "semanticId": semanticId,
        }, 
        "imageIds": imageIds,
        "viewType": viewType?.value,
        "sceneType": sceneType?.value,
        "visualProjectId": visualProjectId,
        "styleId": styleId,
        "promptId": promptId,
        "mode": generationMode.value.value,
      };
      ManageCreateImageInfoEntity? res = await LanguageConsoleRequest.queryCreateImageInfo(data: reqData);
      if(res == null) return;
      generateCount.value = res.output?.numberOfImages ?? 4;
    } finally{
      
    }
  }

  /// 查询图片风格列表
  Future<void> queryImageStyleList() async{
    try {
      
      ImageStyleConfigV2ResponseData? res = await LanguageUtil.getStyleListV2();
      if(res == null) return;
      styleData = res.groups;
      styleAreaList.clear();
      styleKeyList.value = res.groups.keys.toList();

      if(styleId != null){
        styleData.forEach((key, value) {
          for (var item in value) {
            if(item.uid == styleId){
              styleAreaList.value = value;
              selectedStyleKey.value = key;
              selectedStyleAreaCode.value = item.locale ?? "";
              return;
            }
          }
        });
      }else{
        selectedStyleKey.value = styleKeyList.first;
        selectedStyleAreaCode.value = styleData[styleKeyList.first]?.first.locale ?? "";
        styleAreaList.value = styleData[styleKeyList.first] ?? [];
      }

      setSelectedStyleId();
      
    } finally{}
  }


  /// 选择图片 输入UID列表
  Future<void> selectImageUid(BuildContext context) async{
    String? inputRes = await InputDialog.show(
      context: context,
      title: "输入图片UID",
      hintText: "图片UID",
    );
    if(inputRes == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "imageId": inputRes,
      };
      ManageImageInfoEntity? res = await LanguageConsoleRequest.queryImageInfo(parameters: parameters);
      if(res == null) return;
      referenceImages.add(ManageCreateImageInfoEntityImages(
        imageId: res.imageId,
        imageUrl: res.imageUrl,
        md5: res.md5,
        isDefault: false,
      ));
      if(generationMode.value == GenerationModeEnum.textToImage){
        generationMode.value = GenerationModeEnum.imageEdit;
      }
      getImageGenerateCount();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 上传图片
  Future<void> uploadImage(BuildContext context) async{
    File? file = await ImagePickerUtils.pickImage(context);
    if(file == null) return;
    try {
      ToastUtils.showLoading();

      OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile( 
        filePath: file.path,
        fileModule: OssFileManageModule.scriptTmp,
        fileType: OssFileManageType.image,
      );
      if (record == null) return;

      Map<String, dynamic> reqData = {
        "imageKey": record.key,
        "styleIds": [selectedStyleId.value],
      };
      ManageImageInfoEntity? res = await LanguageConsoleRequest.saveImage(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "上传成功", type: ToastType.success);
      referenceImages.add(ManageCreateImageInfoEntityImages(
        imageId: res.imageId,
        imageUrl: res.imageUrl,
        md5: res.md5,
        isDefault: false,
      ));
      if(generationMode.value == GenerationModeEnum.textToImage){
        generationMode.value = GenerationModeEnum.imageEdit;
      }
      getImageGenerateCount();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除图片
  void deleteImage(int index){
    referenceImages.removeAt(index);
    // if(referenceImages.isEmpty){
    //   generationMode.value = GenerationModeEnum.textToImage;
    // }
    getImageGenerateCount();
  }


  /// 查看图片大图
  void showImageDetail(BuildContext context, int index){

    List<String> imageUrls = [];
    for(int i = 0; i < referenceImages.length; i++){
      ManageCreateImageInfoEntityImages item = referenceImages[i];
      if(item.imageUrl == null) continue;
      imageUrls.add(item.imageUrl!);
    }

    ShowBigResourceDialog.showImage(
      context: context,
      imageUrls: imageUrls,
      index: index,
    );
  }

  /// 切换生成模式
  void switchGenerationMode(GenerationModeEnum modeEnum){
    generationMode.value = modeEnum;
    getImageGenerateCount();
  }


  /// 切换画风
  void switchStyle(String styleKey){
    selectedStyleKey.value = styleKey;
    // 重新获取地区列表
    styleAreaList.value = styleData[styleKey] ?? [];

    // 如果列表内没有当前选择的地区，默认选择第一个
    bool isExist = styleAreaList.any((element) => element.locale == selectedStyleAreaCode.value);
    if(!isExist){
      selectedStyleAreaCode.value = styleAreaList.first.locale ?? "";
    }

    setSelectedStyleId();

  }

  /// 切换地区
  void switchArea(String areaCode){
    selectedStyleAreaCode.value = areaCode;
    setSelectedStyleId();
  }


  /// 根据stylekey 地区code set selectedStyleId
  void setSelectedStyleId(){
    styleData[selectedStyleKey.value]?.forEach((item) {
      if(item.locale == selectedStyleAreaCode.value){
        selectedStyleId.value = item.uid;
        return;
      }
    });

  }



  /// 切换模型模式
  void switchModeModule(ModeModuleEnum modeEnum){
    modeModule.value = modeEnum;
  }

  /// 选择尺寸
  void selectSize(BuildContext context){
    ManageUnifiedImageCreateSizeDialog.show(
      context: context,
      aspectRatio: aspectRatio.value,
      quality: quality.value,
      onChange: (r, q){
        aspectRatio.value = r;
        quality.value = q;

        imageOrgSize.value = ImageAspectRatioUtils.getImageSize(aspectRatio.value, quality.value);
      },
    );
   }



   /// 开始生成图片
   Future<void> startGenerateImage() async{
    if(generationMode.value == GenerationModeEnum.imageEdit){
      if(promptEditController.text.isEmpty){
        ToastUtils.showToast(text: "请输入 prompt");
        return;
      }
      if(referenceImages.isEmpty){
        ToastUtils.showToast(text: "最少需要一张参考图");
        return;
      }
    }

    String prompt = promptTextController.text;

    if(generationMode.value == GenerationModeEnum.textToImage){
      prompt = promptEditController.text;
    }else if(generationMode.value == GenerationModeEnum.imageEdit){
      prompt = promptEditController.text;
    }else if(generationMode.value == GenerationModeEnum.reusePrompt){
      prompt = promptReuseController.text;
    }else if(generationMode.value == GenerationModeEnum.convertStyle){
      prompt = promptConvertStyleController.text;
    }

    List<int> imageIds = [];

    for(int i = 0; i < referenceImages.length; i++){
      ManageCreateImageInfoEntityImages item = referenceImages[i];
      if(item.imageId == null) continue;
      imageIds.add(item.imageId!);
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "jumpCode": jumpCode,
        "params": params,
        "styleIds": [selectedStyleId.value],
        "numberofImages": generateCount.value,
        "width": imageOrgSize.value.width.toInt(),
        "height": imageOrgSize.value.height.toInt(),
        "subContent": {
          "uid": uid,
          "type": type,
          "semanticId": semanticId,
        }, 
        "mode": generationMode.value.value,
        "modelMode": modeModule.value.value,
        "imageIds": imageIds,
      };
      if(prompt.isNotEmpty){
        reqData['prompt'] = prompt;
      }
      if(viewType != null){
        reqData["viewType"] = viewType?.value;
      }
      if(sceneType != null){
        reqData["sceneType"] = sceneType?.value;
        if(sceneType == SceneStoryboardTypeEnum.storyboard_sheet && generationMode.value == GenerationModeEnum.reusePrompt){
          reqData['promptId'] = imageDetail.value.promptId;
        }
      }else{
        // 分镜图 不要传promptId
        reqData['promptId'] = imageDetail.value.promptId;
      }
      if(visualProjectId != null){
        reqData["visualProjectId"] = visualProjectId;
      }

      String? res = await LanguageConsoleRequest.createImageTask(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }


   }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
