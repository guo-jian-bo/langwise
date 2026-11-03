import 'package:get/get.dart';
import 'package:lib_common/common.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/values/values.dart';

class ManageSettingController extends GetxController{

  static ManageSettingController get to => Get.find<ManageSettingController>();
  

  final Rx<ResourceTypeEnum> defaultResources = ResourceTypeEnum.image.obs;


  /// 风格数据
  Map<String, List<ImageStyleConfigV2Item>> styleData = {};
  /// 选中的画风
  final RxString selectedStyleKey = ''.obs;
  /// 选中的地区code
  final RxString selectedStyleAreaCode = ''.obs;
  /// 当前选中的styleId
  final RxInt selectedStyleId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    _initResources();
    _getStyleGroup();
  }


  /// 获取默认风格id
  Future<int?> getDefaultStyleId() async{
    await _getStyleGroup();
    return selectedStyleId.value;
  }

  /// 切换资源
  void switchResources(ResourceTypeEnum type){
    defaultResources.value = type;
    StorageUtil().setString(MANAGE_DEFAULT_RESOURCES, type.value);
  }

  /// 初始化默认资源类型
  Future<void> _initResources() async{
    String resources = StorageUtil().getString(MANAGE_DEFAULT_RESOURCES);
    if(resources.isNotEmpty) {
      defaultResources.value = ResourceTypeEnum.fromRawValue(resources);
    }
  }

  /// 获取当前风格的code
  String? getCurrentStyleCode() {
    return styleData[selectedStyleKey.value]?.firstWhereOrNull((e) => e.locale == selectedStyleAreaCode.value)?.style;
  }

  /// 获取当前地区的名称
  String? getCurrentStyleAreaName() {
    return styleData[selectedStyleKey.value]?.firstWhereOrNull((e) => e.locale == selectedStyleAreaCode.value)?.localeTitle;
  }

  /// 获取风格地区列表
  Future<List<ImageStyleConfigV2Item>> getStyleAreaList() async{
    await _getStyleGroup();
    return styleData[selectedStyleKey.value] ?? [];
  }

  /// 获取风格列表
  Future<List<String>> getStyleKeyList() async{
    await _getStyleGroup();
    return styleData.keys.toList();
  }

  /// 获取风格分组
  Future<void> _getStyleGroup() async{
    if(styleData.isNotEmpty) return;
    try {
      ImageStyleConfigV2ResponseData? res = await LanguageUtil.getStyleListV2();
      if(res == null) return;
      styleData = res.groups;
      if(styleData.isNotEmpty){
        selectedStyleKey.value = styleData.keys.first;
        selectedStyleAreaCode.value = styleData[selectedStyleKey.value]?.first.locale ?? "";

        int? styleId = StorageUtil().getInt(MANAGE_DEFAULT_STYLE_ID);
        styleId ??= styleData[selectedStyleKey.value]?.first.uid ?? -1;
        selectedStyleId.value = styleId;
      }

    } catch (_) {}
  }

  /// 根据风格code 和 地区code 设置styleid
  void setStyleIdByStyleKeyAndAreaCode(String? styleKey, String? areaCode){
    if(styleKey == null || areaCode == null) return;
    selectedStyleKey.value = styleKey;
    selectedStyleAreaCode.value = areaCode;
    List<ImageStyleConfigV2Item> areaList = styleData[styleKey] ?? [];
    int? styleId = areaList.firstWhereOrNull((e) => e.locale == areaCode)?.uid;
    selectedStyleId.value = styleId ?? -1;
    if(selectedStyleId.value != -1){
      StorageUtil().setInt(MANAGE_DEFAULT_STYLE_ID, selectedStyleId.value);
    }
  }

  /// 根据风格code获取地区列表
  Future<List<ImageStyleConfigV2Item>> getStyleAreaListByStyleKey(String styleKey) async{
    await _getStyleGroup();
    return styleData[styleKey] ?? [];
  }


  /// 获取风格列表
  // Future<void> _getStyleData() async{
  //   try {
  //     Map<String, dynamic> parameters = {
  //       "language": "en",
  //     };
  //     List<StyleImageEntity>? res = await LanguageUtil.getStyleListLanguage(parameters: parameters);
  //     if(res == null) return;
  //     styleList.value = res;
  //   } finally{}
  // }

}