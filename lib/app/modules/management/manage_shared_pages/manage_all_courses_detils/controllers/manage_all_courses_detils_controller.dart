import 'package:api/entities/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../routes/routes.dart';
import '../../../dialog/manage_create_relevance_level/view.dart';
import '../../../dialog/manage_create_relevance_module/view.dart';
import '../../../dialog/manage_phonics_create_module_dialog.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../../../dialog/manage_edit_level/view.dart';
import '../../../dialog/manage_edit_module/view.dart';
import '../../../utils/utils.dart';

class ManageAllCoursesDetilsController extends GetxController with GetTickerProviderStateMixin, ManageBreadcrumbMixin {
  final String tag;
  ManageAllCoursesDetilsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_ALL_COURSES_DETILS;

  @override
  String get breadcrumbTitle => '课程详情';

  TabController? tabController;

  CourseResponseEntity? courseInfo;
  final RxList<LevelResponseEntity> levelTabList = <LevelResponseEntity>[].obs;
  int tabCurrentIndex = 0;

  final GlobalKey sortGlobalKey = GlobalKey();

  int? _courseOrLevelUid;
  String? _language;

  // 从等级列表过来, 隐藏新增单元控件
  bool isFromLevel = false;
  bool get isHideHeader => isFromLevel;

  Worker? _moduleUpdateWorker;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    // 监听单元更新通知，当有单元更新时刷新模块列表数据
    final courseUpdateStore = CourseUpdateStore.to;
    _moduleUpdateWorker = ever(courseUpdateStore.needRefreshModuleList, (needRefresh) {
      if (needRefresh) {
        _onFetchData();
        courseUpdateStore.moduleListRefreshed();
      }
    });

    final arguments = Get.arguments;
    _courseOrLevelUid = arguments?["uid"];
    _language = arguments?["language"];
    isFromLevel = arguments?["isFromLevel"] ?? false;

    _onFetchData();
  }

  // 获取数据
  void _onFetchData({bool isRefresh = false}) {
    if (isFromLevel) {
      // 从等级列表过来
      _onFetchModuleList(isRefresh: isRefresh);
    } else {
      // 从课程过来
      onFetchLevelModules();
    }
  }

  // 课程等级及模块查询
  void onFetchLevelModules() async {
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "uid为空");
      return;
    }

    try {
      final response = await CourseUtil.levelModules(
        uid: _courseOrLevelUid.toString(),
        config: RequestConfig(requireToken: true),
      );
      levelTabList.value = response.data?.courseLevelList ?? [];
      courseInfo = response.data?.courseInfo;
      if (levelTabList.isNotEmpty) {
        tabController = TabController(vsync: this, length: levelTabList.length);
        addTabListener();
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "查询课程等级及模块失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // 等级模块列表
  void _onFetchModuleList({bool isRefresh = false}) async {
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "levelUid为空");
      return;
    }

    try {
      final response = await LevelUtil.moduleList(
        levelId: _courseOrLevelUid,
        config: RequestConfig(requireToken: true),
      );
      if (response.data != null) {
        levelTabList.value = [response.data!];
        if (levelTabList.isNotEmpty) {
          tabController?.dispose();
          tabController = TabController(
            initialIndex: tabCurrentIndex,
            vsync: this,
            length: levelTabList.length,
          );
          addTabListener();
        }
      } else {
        ToastUtils.showManageToast(text: response.message ?? "等级模块列表失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "等级模块列表失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void addTabListener() {
    tabController?.addListener(() {
      tabCurrentIndex = tabController?.index ?? 0;
    });
  }

  // 添加级别
  Future<void> toAddLevel(BuildContext context) async {
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "uid为空");
      return;
    }

    ManageCreateRelevanceLevelManager.show(
      context: context,
      courseId: _courseOrLevelUid!,
      language: _language,
      disableAssociationLevel: courseInfo?.specialty == SpecialtyEnum.EN_PHONICS,
      disableCopyLevel: courseInfo?.specialty == SpecialtyEnum.EN_PHONICS,
      initCreateWay: courseInfo?.specialty == SpecialtyEnum.EN_PHONICS ? 2 : 0,
      dataDisableCallback: (LevelResponseEntity targetLevelEntity) {
        bool isDisable = false;
        for (final LevelResponseEntity responseEntity in levelTabList) {
          if (responseEntity.hashCode == targetLevelEntity.hashCode) {
            isDisable = true;
            break;
          }
        }
        return isDisable;
      },
    )?.then((List<LevelResponseEntity?>? value) {
      if (value != null) {
        final validLevels = value.whereType<LevelResponseEntity>();
        if (validLevels.isNotEmpty) {
          for (var level in validLevels) {
            final jsonData = level.toJson();
            final convertedLevel = LevelResponseEntity<ModuleResponseEntity<dynamic>>.fromJson(
              jsonData,
              fromJson: (json) => ModuleResponseEntity.fromJson(json),
            );
            levelTabList.add(convertedLevel);
          }
          updateLevelList(isAddLevel: true);
        }
      }
    });
  }

  // 默认当前下标
  void updateLevelList({bool isAddLevel = false}) {
    if (levelTabList.isEmpty) return;
    while (tabCurrentIndex > levelTabList.length - 1) {
      tabCurrentIndex--;
    }

    if (isAddLevel) {
      tabCurrentIndex = levelTabList.length - 1;
    }
    tabController?.dispose();
    tabController = TabController(
      vsync: this,
      length: levelTabList.length,
      initialIndex: tabCurrentIndex,
    );
    addTabListener();
  }

  /// 显示排序弹窗
  void showSort(BuildContext context) {
    if (levelTabList.isEmpty) return;
    final List<SortPopupEntity> list = levelTabList.map((e) => SortPopupEntity(e.name ?? '')).toList();

    SortPopupWindow.show(
      context: context,
      globalKey: sortGlobalKey,
      list: list,
      onReorder: (oldIndex, newIndex) {
        final LevelResponseEntity row = levelTabList.removeAt(oldIndex);
        levelTabList.insert(newIndex, row);
        updateLevelList();
        onSortLevel();
      },
      onDel: (index) async {
        final LevelResponseEntity row = levelTabList[index];
        final bool ask = await AskDialog.show(
          context: context,
          showLastCountdown: true,
          title: "温馨提示",
          content: "确定要删除${row.name}吗？",
        );
        if (ask) {
          return await onDeleteLevel(index);
        } else {
          return false;
        }
      },
    );
  }

  /// 跳转到模块详情
  Future<void> toModuleDetils(int? moduleId, String? moduleName, {required LevelResponseEntity levelEntity}) async {
    if(!ManageAuthUtils.isAuth(ManageAuthCode.courseModuleUnitLessonList)) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS,
      arguments: {
        "moduleId": moduleId,
        "moduleName": moduleName,
        "levelUid": levelEntity.uid,
        "language": _language,
      },
    );
    // 返回后刷新数据
    _onFetchData(isRefresh: true);
  }

  /// 添加模块
  Future<void> toAddModule(BuildContext context, List moduleDTOList, {required LevelResponseEntity levelEntity}) async {
    if (courseInfo?.specialty == SpecialtyEnum.EN_PHONICS) {

      // 创建自然拼读课程的模块
      List<ModuleResponseEntity<dynamic>?>? res = await ManagePhonicsCreateModuleDialog.show(
        context: context,
        language: _language,
        levelUid: levelEntity.uid,
      );
      if (res == null) return;
      if (res.isEmpty) return;
      final validModules = res.whereType<ModuleResponseEntity>();
      if (validModules.isEmpty) return;
      levelEntity.moduleDTOList?.addAll(validModules);
      levelTabList.refresh();
      return;
    }

    // 创建普通课程的模块
    ManageCreateRelevanceModuleManager.show(
      context: context,
      levelUid: levelEntity.uid,
      language: _language,
      dataDisableCallback: (ModuleResponseEntity targetModuleEntity) {
        bool isDisable = false;
        for (final ModuleResponseEntity responseEntity in moduleDTOList) {
          if (responseEntity.hashCode == targetModuleEntity.hashCode) {
            isDisable = true;
            break;
          }
        }
        return isDisable;
      },
    )?.then((List<ModuleResponseEntity?>? value) {
      if (value != null) {
        final validModules = value.whereType<ModuleResponseEntity>();
        if (validModules.isNotEmpty) {
          levelEntity.moduleDTOList?.addAll(validModules);
          levelTabList.refresh();
        }
      }
    });
  }

  // 编辑模块
  Future<void> onEditModule(BuildContext context, int index, ModuleResponseEntity module, {required LevelResponseEntity levelEntity}) async {
    if (courseInfo?.specialty == SpecialtyEnum.EN_PHONICS) {
      List<ModuleResponseEntity<dynamic>?>? res = await ManagePhonicsCreateModuleDialog.show(
        context: context,
        language: _language,
        levelUid: levelEntity.uid,
        module: module,
      );
      if (res == null) return;
      if (res.isEmpty) return;
      final validModules = res.whereType<ModuleResponseEntity>();
      if (validModules.isEmpty) return;
      levelEntity.moduleDTOList?[index] = validModules.first;
      levelTabList.refresh();
      return;
    }
    ManageEditModule.show(context: context, moduleEntity: module)?.then((value) {
      if (value != null) {
        levelEntity.moduleDTOList?[index] = value;
        levelTabList.refresh();
      }
    });
  }

  // 编辑等级
  void onEditLevel(int index, LevelResponseEntity levelEntity) {
    ManageEditLevel.show(context: Get.context!, levelEntity: levelEntity)?.then((value) {
      if (value != null) {
        levelTabList[index] = levelEntity.copyWith(
          name: value.name,
          description: value.description,
          access: value.access,
        );
        levelTabList.refresh();
        updateLevelList();
      }
    });
  }

  // 删除等级
  Future<bool> onDeleteLevel(int index) async {
    bool isDel = false;
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "uid为空");
      return isDel;
    }

    final List<LevelResponseEntity> oldLevels = [...levelTabList];
    oldLevels.removeAt(index);
    final List<int> ids = oldLevels.map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "等级不能为空");
      return isDel;
    }

    try {
      final response = await CourseUtil.edit(
        uid: _courseOrLevelUid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"levelIds": ids},
        ),
      );
      if (response.data != null) {
        levelTabList.removeAt(index);
        updateLevelList();
        ToastUtils.showManageToast(text: "删除等级成功");
        isDel = true;
      } else {
        ToastUtils.showManageToast(text: response.message ?? "删除等级失败");
        isDel = false;
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "删除等级失败");
      if (kDebugMode) {
        print(e.toString());
      }
      isDel = false;
    }

    return isDel;
  }

  // 删除等级下的模块
  void onDeleteModule(BuildContext context, int index, ModuleResponseEntity moduleEntity, {required LevelResponseEntity levelEntity}) async {
    final bool ask = await AskDialog.show(
      context: context,
      showLastCountdown: true,
      title: "温馨提示",
      content: "确定要删除${moduleEntity.name}吗？",
    );
    if (!ask) return;

    final List<ModuleResponseEntity> oldModules = [...levelEntity.moduleDTOList ?? []];
    oldModules.removeAt(index);

    final List<int> ids = oldModules.map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "模块不能为空");
      return;
    }

    try {
      final response = await LevelUtil.edit(
        uid: levelEntity.uid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"moduleIds": ids},
        ),
      );
      if (response.data != null) {
        levelEntity.moduleDTOList?.removeAt(index);
        levelTabList.refresh();
        ToastUtils.showManageToast(text: "删除模块成功");
      } else {
        ToastUtils.showManageToast(text: response.message ?? "删模块失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "删除模块失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // 等级排序
  void onSortLevel() async {
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "uid为空");
      return;
    }

    final List<int> ids = [...levelTabList].map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "等级不能为空");
      return;
    }

    try {
      final response = await CourseUtil.edit(
        uid: _courseOrLevelUid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"levelIds": ids},
        ),
      );
      if (response.data != null) {
        ToastUtils.showManageToast(text: "等级排序成功");
      } else {
        ToastUtils.showManageToast(text: "等级排序失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "等级排序失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  void onClose() {
    levelTabList.clear();
    tabController?.dispose();
    _moduleUpdateWorker?.dispose();
    _courseOrLevelUid = null;
    super.onClose();
  }
}
