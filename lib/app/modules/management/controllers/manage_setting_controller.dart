import 'package:get/get.dart';
import 'package:lib_common/common.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/values/values.dart';

class ManageSettingController extends GetxController{

  static ManageSettingController get to => Get.find<ManageSettingController>();
  

  final Rx<ResourceTypeEnum> defaultResources = ResourceTypeEnum.image.obs;

  final Rx<StyleImageEntity> defaultStyle = StyleImageEntity().obs;

  /// 所有风格列表
  final RxList<StyleImageEntity> styleList = <StyleImageEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initResources();
    _initDefaultStyle();
  }


  

  /// 获取风格列表
  Future<List<StyleImageEntity>> getStyleList() async{
    if(styleList.isEmpty){
      await _getStyleData();
    }
    return styleList;
  }


  /// 获取默认风格id
  Future<int?> getDefaultStyleId() async{
    if(defaultStyle.value.uid == null){
      await _initDefaultStyle();
    }
    return defaultStyle.value.uid;
  }


  /// 切换资源
  void switchResources(ResourceTypeEnum type){
    defaultResources.value = type;
    StorageUtil().setString(MANAGE_DEFAULT_RESOURCES, type.value);
  }

  /// 切换风格
  void switchStyle(StyleImageEntity? style){
    if(style == null) return;
    defaultStyle.value = style;
    if(style.uid == null) return;
    StorageUtil().setInt(MANAGE_DEFAULT_STYLE_ID, style.uid!);
  }

  /// 初始化默认资源类型
  Future<void> _initResources() async{
    String resources = StorageUtil().getString(MANAGE_DEFAULT_RESOURCES);
    if(resources.isNotEmpty) {
      defaultResources.value = ResourceTypeEnum.fromRawValue(resources);
    }
  }


  /// 初始化默认的风格
  Future<void> _initDefaultStyle() async{
    if(defaultStyle.value.uid != null) return;
    if(styleList.isEmpty){
      await _getStyleData();
    }
    if(styleList.isEmpty) return;
    int? styleId = StorageUtil().getInt(MANAGE_DEFAULT_STYLE_ID);
    styleId ??= styleList.first.uid;
    StyleImageEntity? local = styleList.firstWhereOrNull((e) => e.uid == styleId);
    if(local == null) return;
    defaultStyle.value = local;
  }


  /// 获取风格列表
  Future<void> _getStyleData() async{
    try {
      Map<String, dynamic> parameters = {
        "language": "en",
      };
      List<StyleImageEntity>? res = await LanguageUtil.getStyleListLanguage(parameters: parameters);
      if(res == null) return;
      styleList.value = res;
    } finally{}
  }

}