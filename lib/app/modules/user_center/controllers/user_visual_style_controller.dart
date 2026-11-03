import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';

class UserVisualStyleController extends GetxController {
  final String tagText;
  UserVisualStyleController({required this.tagText});

  final ConfigController configController = Get.find<ConfigController>();

  final Rx<TeamStyleEntity> teamStyleData = TeamStyleEntity().obs;

  /// 风格列表
  final RxList<TeamStyleEntityStyleItems> styleList = <TeamStyleEntityStyleItems>[].obs;

  /// 当前视觉模式
  final Rx<ResourceTypeEnum> resourceType = ResourceTypeEnum.image.obs;

  /// 当前主风格
  final RxString mainStyleCode = "".obs;

  /// 当前是否开启混搭
  final RxBool isMediaMix = false.obs;

  /// 当前混搭风格集合
  final RxList<String> mixStyleCodeList = <String>[].obs;

  /// 获取视觉风格
  Future<void> getStyleList() async {
    try {
      await configController.getUserStyleList();
      TeamStyleEntity data = configController.originalStyleData.value;
      teamStyleData.value = data;

      styleList.clear();
      List<TeamStyleEntityStyleItems?> styleItems = data.styleItems ?? [];
      for (int i = 0; i < styleItems.length; i++) {
        if (styleItems[i] == null) continue;
        styleList.add(styleItems[i]!);
      }

      resourceType.value = data.mediaModeUse == 1 ? ResourceTypeEnum.video : ResourceTypeEnum.image;
      if (resourceType.value == ResourceTypeEnum.video && getAvailableStyleList(type: ResourceTypeEnum.video).isEmpty) {
        resourceType.value = ResourceTypeEnum.image;
      }

      mainStyleCode.value = data.mainStyleUse ?? "";
      isMediaMix.value = data.isMediaMix == true;

      mixStyleCodeList.clear();
      List<String?> imageStyleUses = data.imageStyleUses ?? [];
      for (int i = 0; i < imageStyleUses.length; i++) {
        String? code = imageStyleUses[i];
        if (code == null || code.isEmpty || mixStyleCodeList.contains(code)) continue;
        mixStyleCodeList.add(code);
      }

      List<TeamStyleEntityStyleItems> availableStyleList = getAvailableStyleList();
      if (availableStyleList.isEmpty) return;

      bool mainStyleValid = false;
      for (int i = 0; i < availableStyleList.length; i++) {
        if (availableStyleList[i].style == mainStyleCode.value) {
          mainStyleValid = true;
        }
      }
      if (!mainStyleValid) {
        mainStyleCode.value = availableStyleList.first.style ?? "";
      }
      _sanitizeMixStyleCodeList();
    } catch (_) {}
  }

  /// 当前模式下可用的风格列表
  List<TeamStyleEntityStyleItems> getAvailableStyleList({ResourceTypeEnum? type}) {
    ResourceTypeEnum targetType = type ?? resourceType.value;
    List<TeamStyleEntityStyleItems> availableStyleList = [];
    for (int i = 0; i < styleList.length; i++) {
      TeamStyleEntityStyleItems item = styleList[i];
      bool isAvailable = targetType == ResourceTypeEnum.video ? item.videoStatus == 1 : item.imageStatus == 1;
      if (isAvailable) {
        availableStyleList.add(item);
      }
    }
    return availableStyleList;
  }

  List<String> _getAvailableStyleCodeList({ResourceTypeEnum? type}) {
    List<String> availableStyleCodeList = [];
    List<TeamStyleEntityStyleItems> availableStyleList = getAvailableStyleList(type: type);
    for (int i = 0; i < availableStyleList.length; i++) {
      String? styleCode = availableStyleList[i].style;
      if (styleCode == null || styleCode.isEmpty || availableStyleCodeList.contains(styleCode)) continue;
      availableStyleCodeList.add(styleCode);
    }
    return availableStyleCodeList;
  }

  void _sanitizeMixStyleCodeList({ResourceTypeEnum? type}) {
    List<String> availableStyleCodeList = _getAvailableStyleCodeList(type: type);
    mixStyleCodeList.removeWhere((code) => !availableStyleCodeList.contains(code));
    if (mainStyleCode.value.isNotEmpty &&
        availableStyleCodeList.contains(mainStyleCode.value) &&
        !mixStyleCodeList.contains(mainStyleCode.value)) {
      mixStyleCodeList.add(mainStyleCode.value);
    }
  }

  /// 当前主风格预览
  TeamStyleEntityStyleItems? getMainStyleItem() {
    for (int i = 0; i < styleList.length; i++) {
      if (styleList[i].style == mainStyleCode.value) {
        return styleList[i];
      }
    }
    return null;
  }

  /// 当前模式下是否可用
  bool isStyleAvailable(TeamStyleEntityStyleItems item, {ResourceTypeEnum? type}) {
    ResourceTypeEnum targetType = type ?? resourceType.value;
    return targetType == ResourceTypeEnum.video ? item.videoStatus == 1 : item.imageStatus == 1;
  }

  /// 切换模式
  Future<void> switchMode(ResourceTypeEnum type) async {
    if (type == resourceType.value) return;
    List<TeamStyleEntityStyleItems> availableStyleList = getAvailableStyleList(type: type);
    if (availableStyleList.isEmpty) {
      return ToastUtils.showToast(text: type == ResourceTypeEnum.video ? "当前暂无可用视频风格" : "当前暂无可用图片风格");
    }

    resourceType.value = type;
    List<String> validCodeList = _getAvailableStyleCodeList(type: type);

    if (!validCodeList.contains(mainStyleCode.value)) {
      mainStyleCode.value = validCodeList.first;
    }
    _sanitizeMixStyleCodeList(type: type);
    await confirmUsage();
  }

  /// 选择主风格
  Future<void> selectMainStyle(TeamStyleEntityStyleItems data) async {
    String? styleCode = data.style;
    if (styleCode == null || styleCode.isEmpty) return;
    if (!isStyleAvailable(data)) {
      return ToastUtils.showToast(text: data.statusHint ?? "当前风格暂不可用");
    }
    if (mainStyleCode.value == styleCode) return;
    mainStyleCode.value = styleCode;
    if (!mixStyleCodeList.contains(styleCode)) {
      mixStyleCodeList.add(styleCode);
    }
    await confirmUsage();
  }

  /// 切换混搭开关
  Future<void> switchMediaMix(bool value) async {
    if (isMediaMix.value == value) return;
    isMediaMix.value = value;
    if (mainStyleCode.value.isNotEmpty && !mixStyleCodeList.contains(mainStyleCode.value)) {
      mixStyleCodeList.add(mainStyleCode.value);
    }
    await confirmUsage();
  }

  /// 选择/取消混搭风格
  Future<void> toggleMixStyle(TeamStyleEntityStyleItems data) async {
    String? styleCode = data.style;
    if (styleCode == null || styleCode.isEmpty) return;
    if (!isStyleAvailable(data)) {
      return ToastUtils.showToast(text: data.statusHint ?? "当前风格暂不可用");
    }
    if (styleCode == mainStyleCode.value) return;
    if (mixStyleCodeList.contains(styleCode)) {
      mixStyleCodeList.remove(styleCode);
    } else {
      mixStyleCodeList.add(styleCode);
    }
    await confirmUsage();
  }

  /// 确认使用
  Future<void> confirmUsage() async {
    if (mainStyleCode.value.isEmpty) return ToastUtils.showToast(text: "请选择主风格");
    _sanitizeMixStyleCodeList();

    try {
      Map<String, dynamic> reqData = {
        "mediaModeUse": resourceType.value == ResourceTypeEnum.image ? 0 : 1,
        "mainStyleUse": mainStyleCode.value,
        "isMediaMix": isMediaMix.value,
        "imageStyleUses": mixStyleCodeList.toList(),
      };
      bool res = await AccountUtil.teamConfigStyleEdit(reqData);
      if (!res) return;
      await getStyleList();
      configController.initUserStyleList();
    } finally {}
  }
}
