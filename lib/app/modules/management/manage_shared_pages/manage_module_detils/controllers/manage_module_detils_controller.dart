import 'dart:async';

import 'package:api/entities/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../dialog/manage_edit_unit/view.dart';
import '../../../dialog/manage_edit_lesson/view.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../../../utils/utils.dart';

class ManageModuleDetilsController extends GetxController with GetTickerProviderStateMixin, ManageBreadcrumbMixin {
  final String tag;
  ManageModuleDetilsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_MODULE_DETILS;

  @override
  String get breadcrumbTitle => _moduleName ?? '模块详情';

  TabController? tabController;
  final RxList<NewUnitResponseEntity> unitTabList = <NewUnitResponseEntity>[].obs;

  int tabCurrentIndex = 0;

  final GlobalKey sortGlobalKey = GlobalKey();

  int? _moduleId, _unitUid;
  String? _unitId;
  String? _moduleName, _language;

  // 从单元列表过来, 隐藏新增单元控件
  bool isFromUnit = false;
  bool get isHideHeader => isFromUnit;

  final Rx<ModuleResponseEntity?> moduleResponseEntity = Rx<ModuleResponseEntity?>(null);

  final Rx<ImageStyleConfigV2ResponseData?> styleConfigV2 = Rx<ImageStyleConfigV2ResponseData?>(null);

  /// 模块封面图片待审核数量
  final RxInt moduleReviewImageCount = RxInt(0);

  StreamSubscription<PushMessageServiceEnitiy>? _messageSub;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    final arguments = Get.arguments;
    _moduleId = arguments?["moduleId"];
    _moduleName = arguments?["moduleName"];
    _language = arguments?["language"];
    _unitUid = arguments?["unitUid"];
    _unitId = arguments?["unitId"] ?? '';
    isFromUnit = arguments?["isFromUnit"] ?? false;

    onFetchData();

    fetchStyleConfigV2();

    _messageSub = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.MESSAGE_IMAGE_TASK], 
      whereBackPage: true,
      onData: (value){
        getReviewImage("COURSE_MODULE", _moduleId).then((value){
          moduleReviewImageCount.value = value;
        });
      },
    );
  }

  // 获取数据
  void onFetchData({bool isRefresh = false, int unitIndex = 0}) async{
    if (isFromUnit) {
      _onFetchLessonList(isRefresh: isRefresh);
    } else {
      _onFetchPages(isRefresh: isRefresh, unitIndex: unitIndex);
    }
    moduleReviewImageCount.value = await getReviewImage("COURSE_MODULE", moduleId);
  }

  void _onFetchPages({bool isRefresh = false, int unitIndex = 0}) async {
    if (_moduleId == null) {
      ToastUtils.showManageToast(text: "moduleId为空");
      return;
    }

    try {
      final response = await ModuleUtil.unitLessons(
        uid: _moduleId.toString(),
        config: RequestConfig(requireToken: true),
      );

      final List<NewUnitResponseEntity> unitEntities = response.data?.courseUnitList ?? [];
      moduleResponseEntity.value = response.data?.courseModuleInfo;

      for (var unit in unitEntities) {
        unit.lessonDTOList?.add(getAddLessonButton());
      }

      unitTabList.value = unitEntities;
      

      if (unitTabList.isNotEmpty) {
        final int? targetUnitUid = int.tryParse(_unitId ?? '');
        if (targetUnitUid != null) {
          final int idx = unitTabList.indexWhere((e) => e.uid == targetUnitUid);
          if (idx >= 0) {
            tabCurrentIndex = idx;
            getReviewImage("COURSE_UNIT", targetUnitUid).then((value){
              unitTabList[tabCurrentIndex].coverReviewImageCount = value;
            });
          }
        }else{
          getReviewImage("COURSE_UNIT", unitTabList[unitIndex].uid).then((value){
            unitTabList[unitIndex].coverReviewImageCount = value;
            unitTabList.refresh();
          });
        }

        if (tabCurrentIndex < 0) tabCurrentIndex = 0;
        if (tabCurrentIndex >= unitTabList.length) tabCurrentIndex = 0;
        tabController?.dispose();
        tabController = TabController(
          initialIndex: tabCurrentIndex,
          vsync: this,
          length: unitTabList.length,
        );
        addTabListener();
      }
      unitTabList.refresh();
    } catch (e) {
      ToastUtils.showManageToast(text: "查询单元课时列表失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> fetchStyleConfigV2() async {
    if (styleConfigV2.value != null) return;

    try {
      final config = RequestConfig(
        requireToken: true,
        data: const {},
        parameters: const {},
      );
      final res = await ImageUtil.stylesV2(config: config);
      if (res.data == null) return;
      styleConfigV2.value = res.data;
    } catch (_) {
      return;
    }
  }

  /// 查询待审核图片数量
  Future<int> getReviewImage(String type, int? uid) async{
    if(uid == null) return 0;
    var response = await ContentReviewImageUtil.reviewedList(subContent: {'type': type, 'uid': uid});
    if(response == null) return 0;
    return response.data?.list?.length??0;
  }

  /// 跳转至审核图片页面
  Future<void> toReviewPage(String type, int? uid, int count) async{
    if(count == 0) return ToastUtils.showToast(text: "暂无待审核图片");
    if(uid == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_CHECK_IMAGE,
      arguments: {
        "subContent": {
          "type": type,
          "uid": uid,
        },
      },
    );
    onFetchData();
  }


  /// 新建模块图片
  Future<void> createModuleImage(BuildContext context, String type, int? uid) async {
    if (uid == null) return;
    final config = styleConfigV2.value;
    if (config == null) {
      ToastUtils.showToast(text: '风格配置加载中');
      return;
    }

    final res = await ImageConvertCreateDialog.show(
      context: context,
      title: '新建图片',
      mode: ImageConvertCreateDialogMode.create,
      data: config,
      initialNumberOfImages: 4,
    );
    if (res == null) return;
    if (res.tabIndex == 0) {
      if(!ManageAuthUtils.isAuth(ManageAuthCode.contentReviewImageCreate)) return;
      await createNewImageWithSelection(styleIds: res.styleIds, numberOfImages: res.numberOfImages, type: type, uid: uid);
    } else {
      if(!ManageAuthUtils.isAuth(ManageAuthCode.contentReviewImageCreateByPrompt)) return;
      await createNewImageWithPrompt(styleIds: res.styleIds, numberOfImages: res.numberOfImages, prompt: res.prompt, type: type, uid: uid);
    }
  }

  Future<void> createNewImageWithPrompt({required List<int> styleIds, required int numberOfImages, required String prompt, required String type, required int uid}) async {
    if (styleIds.isEmpty) {
      ToastUtils.showToast(text: "请选择风格");
      return;
    }

    if (prompt.isEmpty) {
      ToastUtils.showToast(text: '请填写提示词');
      return;
    }
    final n = numberOfImages <= 0 ? 1 : numberOfImages;

    final res = await ContentReviewImageUtil.createImageByPrompt(styleIds, n, type, null, uid, prompt);
    if (res == null) {
      ToastUtils.showToast(text: '新建失败');
      return;
    }
    ToastUtils.showToast(text: '新建成功', type: ToastType.success);
  }

  Future<void> createNewImageWithSelection({
    required List<int> styleIds,
    required int numberOfImages,
    required String type,
    required int uid,
  }) async {
    if (styleIds.isEmpty) {
      ToastUtils.showToast(text: "请选择风格");
      return;
    }

    final n = numberOfImages <= 0 ? 1 : numberOfImages;

    final res = await ContentReviewImageUtil.createImage(styleIds: styleIds, numberOfImages: n, type: type, semanticId: null, uid: uid);
    if (res == null) {
      ToastUtils.showToast(text: '新建失败');
      return;
    }
    ToastUtils.showToast(text: '新建成功', type: ToastType.success);
  }

  void _onFetchLessonList({bool isRefresh = false}) async {
    if (_unitUid == null) {
      ToastUtils.showManageToast(text: "unitUid为空");
      return;
    }

    try {
      final response = await UnitUtil.lessonList(
        unitId: _unitUid,
        config: RequestConfig(requireToken: true),
      );
      if (response.data != null) {
        response.data!.lessonDTOList?.add(getAddLessonButton());
        response.data?.coverReviewImageCount = await getReviewImage("COURSE_UNIT", _unitUid);
        unitTabList.value = [response.data!];
        unitTabList.refresh();
        if (unitTabList.isNotEmpty) {
          tabController?.dispose();
          tabController = TabController(
            initialIndex: tabCurrentIndex,
            vsync: this,
            length: unitTabList.length,
          );
          addTabListener();
        }
      } else {
        ToastUtils.showManageToast(text: response.message ?? "单元课时列表失败");
      }

       

    } catch (e) {
      ToastUtils.showManageToast(text: "单元课时列表失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void addTabListener() {
    tabController?.addListener(() {
      tabCurrentIndex = tabController?.index ?? 0;
      print(tabCurrentIndex);
      onFetchData(isRefresh: true, unitIndex: tabCurrentIndex);

      // getReviewImage("COURSE_UNIT", unitTabList[tabCurrentIndex].uid).then((value){
      //   unitTabList[tabCurrentIndex].coverReviewImageCount = value;
      //   unitTabList.refresh();
      // });
    });
  }

  // 添加单元
  Future<void> toAddUnit(BuildContext context) async {
    final NewUnitResponseEntity<LessonResponseEntity>? value = await AddUnitDialog.show(
      context: context,
      moduleId: _moduleId,
      language: _language,
      hidsDifficulty: moduleResponseEntity.value?.specialty == SpecialtyEnum.EN_PHONICS,
    );
    if (value != null) {
      unitTabList.add(value);
      unitTabList.refresh();
      updateUnitList(isAddUnit: true);
      final know = await onAddKnowledge(context, value);
      if (know) {
        _onCreateLesson(context, value);
      }
    }
  }

  void updateUnitList({bool isAddUnit = false}) {
    if (unitTabList.isEmpty) return;
    while (tabCurrentIndex > unitTabList.length - 1) {
      tabCurrentIndex--;
    }

    if (isAddUnit) {
      tabCurrentIndex = unitTabList.length - 1;
    }
    tabController?.dispose();
    tabController = TabController(
      vsync: this,
      length: unitTabList.length,
      initialIndex: tabCurrentIndex,
    );
    addTabListener();
  }

  /// 显示排序弹窗
  void showSort(BuildContext context) {
    final List<SortPopupEntity> list = unitTabList.map((e) => SortPopupEntity(e.name ?? '')).toList();
    SortPopupWindow.show(
      context: context,
      globalKey: sortGlobalKey,
      list: list,
      onReorder: (oldIndex, newIndex) {
        final NewUnitResponseEntity row = unitTabList.removeAt(oldIndex);
        unitTabList.insert(newIndex, row);
        updateUnitList();
        onSortLevel();
      },
      onDel: (index) async {
        
        final NewUnitResponseEntity row = unitTabList[index];
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

  // 管理知识点列表
  Future<bool> onAddKnowledge(BuildContext context, NewUnitResponseEntity unitEntity) async {
    dynamic res = await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_TARGET,
      arguments: {
        "moduleId": _moduleId,
        "unitId": unitEntity.uid,
        "isAdminPage": true,
        "language": _language,
      },
    );
    if (res != true) return false;
    onFetchData(isRefresh: true);
    return true;
  }

  // 编辑单元
  void onEditUnit(int unitIndex, NewUnitResponseEntity unitEntity) {
    ManageEditUnitDialog.show(
      context: Get.context!,
      unitEntity: unitEntity,
      hidsDifficulty: moduleResponseEntity.value?.specialty == SpecialtyEnum.EN_PHONICS,
    )?.then((value) {
      if (value != null) {
        unitTabList[unitIndex] = unitEntity.copyWith(
          name: value.name,
          description: value.description,
          difficultyLevel: value.difficultyLevel,
          difficulty: value.difficulty,
          access: value.access,
        );
        unitTabList.refresh();
        updateUnitList();
        CourseUpdateStore.to.notifyUnitUpdated();
      }
    });
  }

  // 删除单元
  Future<bool> onDeleteLevel(int unitIndex) async {
    bool isDel = false;
    if (_moduleId == null) {
      ToastUtils.showManageToast(text: "_moduleId为空");
      return isDel;
    }

    final List<NewUnitResponseEntity> oldLevels = [...unitTabList];
    oldLevels.removeAt(unitIndex);
    final List<int> ids = oldLevels.map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "单元不能为空");
      return isDel;
    }

    try {
      final response = await ModuleUtil.edit(
        uid: _moduleId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"unitIds": ids},
        ),
      );
      if (response.data != null) {
        unitTabList.removeAt(unitIndex);
        updateUnitList();
        ToastUtils.showManageToast(text: "删除单元成功");
        isDel = true;
      } else {
        ToastUtils.showManageToast(text: response.message ?? "删除单元失败");
        isDel = false;
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "删除单元失败");
      if (kDebugMode) {
        print(e.toString());
      }
      isDel = false;
    }

    return isDel;
  }

  // 单元排序
  void onSortLevel() async {
    if (_moduleId == null) {
      ToastUtils.showManageToast(text: "moduleId为空");
      return;
    }

    final List<int> ids = [...unitTabList].map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "单元Id为空");
      return;
    }

    try {
      final response = await ModuleUtil.edit(
        uid: _moduleId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"unitIds": ids},
        ),
      );
      if (response.data != null) {
        ToastUtils.showManageToast(text: "单元排序成功");
      } else {
        ToastUtils.showManageToast(text: "单元排序失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "等级排序失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /// 跳转至添加Lesson页面
  Future<void> createLesson(BuildContext context, NewUnitResponseEntity unitEntity) async {
    if (!unitEntity.hasKnowledgeCount) {
      final value = await onAddKnowledge(context, unitEntity);
      if (value) {
        _onCreateLesson(context, unitEntity);
      }
    } else {
      _onCreateLesson(context, unitEntity);
    }
  }

  void _onCreateLesson(BuildContext context, NewUnitResponseEntity unitEntity) async {
    final ManageLessonTemplateEntityDatas? res = await SelectLessonTemplateDialog.show(
      context: context,
      difficultyLevel: unitEntity.difficultyLevel,
      language: _language,
    );
    if (res == null) return;
    try {
      ToastUtils.showLoading();
      final LessonResponseEntity? lessonCreateRes = await ModuleUtil.createLesson(
        unitEntity.language,
        unitEntity.uid,
        res.uid,
        name: res.name,
        description: res.description,
      );
      ToastUtils.hideLoading();
      if (lessonCreateRes == null) {
        ToastUtils.showManageToast(text: "创建课时失败");
        return;
      }

      int testIndex = -1;
      if (unitEntity.lessonDTOList != null) {
        for (int i = 0; i < unitEntity.lessonDTOList!.length; i++) {
          if (unitEntity.lessonDTOList![i].isUnitTEST) {
            testIndex = i;
            break;
          }
        }
      }

      if (testIndex != -1) {
        unitEntity.lessonDTOList?.insert(testIndex, lessonCreateRes);
      } else {
        unitEntity.lessonDTOList?.add(lessonCreateRes);
      }

      unitTabList.refresh();
      pushToCreateQuizPage(unitEntity, lessonCreateRes);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 编辑课时
  void toEditLesson(BuildContext context, int lessonIndex, LessonResponseEntity targetLessonEntity, {required NewUnitResponseEntity unitEntity}) {
    if (!targetLessonEntity.isAbleEdit) {
      ToastUtils.showManageToast(text: "禁止编辑");
      return;
    }
    ManageEditLesson.show(context: context, lessonEntity: targetLessonEntity)?.then((value) {
      if (value != null) {
        unitEntity.lessonDTOList?[lessonIndex] = targetLessonEntity.copyWith(
          name: value.name,
          description: value.description,
        );
        unitTabList.refresh();
      }
    });
  }

  // 删除课时
  void onDeleteLesson(BuildContext context, int lessonIndex, LessonResponseEntity targetLessonEntity, {required NewUnitResponseEntity unitEntity}) async {
    if (!targetLessonEntity.isAbleEdit) {
      ToastUtils.showManageToast(text: "禁止删除");
      return;
    }

    final bool ask = await AskDialog.show(
      context: context,
      showLastCountdown: true,
      title: "温馨提示",
      content: "确定要删除${targetLessonEntity.name}吗？",
    );
    if (!ask) return;

    final List oldLessons = [...unitEntity.lessonDTOList ?? []].where((element) => element != targetLessonEntity).toList();
    final List ids = oldLessons.map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "课时不能为空");
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.edit(
        uid: unitEntity.uid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"lessonIds": ids},
        ),
      );
      if (response?.data != null) {
        unitEntity.lessonDTOList?.removeAt(lessonIndex);
        unitTabList.refresh();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void pushToCreateQuizPage(NewUnitResponseEntity? unitData, LessonResponseEntity? lessonData) async {
    if (unitData == null || lessonData == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SELECT_QUZI_KNOWLEDGE,
      arguments: {
        "lessonTemplateId": lessonData.lessonTemplateId,
        "unitId": unitData.uid,
        "moduleId": _moduleId,
        "difficultyMin": unitData.difficulty?.min,
        "difficultyMax": unitData.difficulty?.max,
        "language": unitData.language,
        "lessonId": lessonData.uid,
      },
    );
    onFetchData(isRefresh: true);
  }

  // 获取模块ID
  int? get moduleId => _moduleId;

  // 单元目标
  Future<void> toUnitTarget(NewUnitResponseEntity unitEntity, LessonResponseEntity lessonEntity) async {
    if (lessonEntity.isUnitTARGET) {
      if (!ManageAuthUtils.isAuth(ManageAuthCode.unitKnowledgeList)) {
        ToastUtils.showManageToast(text: "无权限");
        return;
      }

      await TagRoutes.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_TARGET,
        arguments: {
          "moduleId": _moduleId,
          "unitId": unitEntity.uid,
          "isAdminPage": true,
          "language": _language,
        },
      );

      onFetchData(isRefresh: true);
    } else if (lessonEntity.isUnitTEST) {
      // 单元测试暂不处理
    } else {
      if (!ManageAuthUtils.isAuth(ManageAuthCode.lessonExerciseList)) {
        ToastUtils.showManageToast(text: "无权限");
        return;
      }
      await ManagePageRegistry.jumpTo(
        Routes.MANAGE_QUIZ_LIST,
        arguments: {
          "lessonId": lessonEntity.uid,
          "moduleId": _moduleId,
        },
      );
      onFetchData(isRefresh: true);
    }
  }

  /// 处理课时排序
  Future<void> onReorderLesson(NewUnitResponseEntity unitEntity, int oldIndex, int newIndex) async {
    try {
      final List lessonDTOList = unitEntity.lessonDTOList ?? [];
      if (oldIndex < 0 || oldIndex >= lessonDTOList.length || newIndex < 0 || newIndex > lessonDTOList.length) {
        return;
      }

      final movedLesson = lessonDTOList[oldIndex];
      if (movedLesson.isUnitTARGET == true || movedLesson.isUnitTEST == true || movedLesson.isAddButton == true) {
        ToastUtils.showManageToast(text: "目标型和测试型课时不能调整顺序");
        return;
      }

      final row = lessonDTOList.removeAt(oldIndex);
      lessonDTOList.insert(newIndex, row);

      final response = await UnitUtil.edit(
        uid: unitEntity.uid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            "lessonIds": lessonDTOList
                .cast<LessonResponseEntity>()
                .map((element) => element.uid)
                .where((element) => element != -1)
                .toList()
          },
        ),
      );

      if (response?.data != null) {
        unitTabList.refresh();
        ToastUtils.showManageToast(text: "排序成功");
      } else {
        ToastUtils.showManageToast(text: response?.message ?? "排序失败");
      }
    } catch (e) {
      if (kDebugMode) {
        print("课时排序错误: $e");
      }
      ToastUtils.showManageToast(text: "排序失败");
    }
  }

  LessonResponseEntity getAddLessonButton() => LessonResponseEntity(uid: -1, ableEdit: false, type: "ADD_BUTTON");

  Future<void> generateAudio() async {
    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateAudio(
        moduleId: _moduleId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateUnitPlan(int unitId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要生成单元计划？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateUnitPlan(
        unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateSentence(int unitId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要生成句子？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateSentence(
        unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateLessonPlan(int unitId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要生成课时计划？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateLessonPlan(
        unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateLessonTitle(int unitId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要生成课时题目？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      List lessonIds = [];
      for (var uint in unitTabList) {
        if (uint.uid == unitId) {
          uint.lessonDTOList?.forEach((element) {
            if (element.type == "LEARN_PRACTICE") {
              lessonIds.add(element.uid);
            }
          });
          break;
        }
      }

      final response = await UnitUtil.generateLessonTitle(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"lessonIds": lessonIds},
        ),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateLessonArticle(int unitId) async {
    final result = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS_GENERATE_ARTICLE,
      arguments: {
        'moduleId': _moduleId,
        'unitId': unitId,
      },
    );
    if (result ?? false) {
      onFetchData(isRefresh: true);
    }
  }

  Future<void> generateLessonSong(int unitId) async {
    final result = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_GENERAL_SONG_PAGE,
      arguments: {'unitId': unitId},
    );
    if (result ?? false) {
      onFetchData(isRefresh: true);
    }
  }

  Future<void> generateOneLessonTitle(int unitId, int lessonId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要重新生成题目？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateLessonTitle(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            "lessonIds": [lessonId.toString()]
          },
        ),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> refreshOneLessonPlan(int unitId, int lessonId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要刷新课时计划？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.refreshLessonPlan(
        unitId: unitId.toString(),
        lessonId: lessonId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    tabController?.dispose();
    tabController = null;
    unitTabList.clear();
    _moduleId = null;
    _messageSub?.cancel();
    super.onClose();
  }
}
