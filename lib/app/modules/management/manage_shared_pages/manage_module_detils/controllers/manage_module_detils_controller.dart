import 'dart:async';
import 'dart:io';

import 'package:api/entities/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/manage_select_knowledge_table/view.dart';
import '../../../dialog/manage_edit_lesson/view.dart';
import '../../../dialog/manage_edit_unit/view.dart';
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
  final ScrollController scrollController = ScrollController();
  final ScrollController unitTabScrollController = ScrollController();
  final GlobalKey unitTabViewportKey = GlobalKey();
  final RxInt activeUnitId = (-1).obs;

  int tabCurrentIndex = 0;
  bool _isRebuildingTabController = false;
  bool _hasAppliedInitialUnitTab = false;
  bool _programmaticScrolling = false;

  final GlobalKey sortGlobalKey = GlobalKey();
  final List<GlobalKey> _unitSectionKeys = <GlobalKey>[];
  final List<GlobalKey> _unitTabKeys = <GlobalKey>[];
  final Map<int, int> _unitIndexById = <int, int>{};

  static const int lessonGridCrossAxisCount = 7;
  static const int unitMiddlePanelHeight = 196;

  int? _moduleId, _unitUid;
  String? _unitId;
  String? _moduleName, _language;

  // 从单元列表过来, 隐藏新增单元控件
  bool isFromUnit = false;
  bool get isHideHeader => isFromUnit;

  final Rx<ModuleResponseEntity?> moduleResponseEntity = Rx<ModuleResponseEntity?>(null);

  final Rx<ImageStyleConfigV2ResponseData?> styleConfigV2 = Rx<ImageStyleConfigV2ResponseData?>(null);

  StreamSubscription<PushMessageServiceEnitiy>? _messageSub;
  Timer? _mqttRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    scrollController.addListener(_syncActiveUnitByScroll);

    final arguments = Get.arguments;
    final Map args = arguments is Map ? arguments : const {};
    _moduleId = _parseInt(args["moduleId"]);
    _moduleName = args["moduleName"]?.toString();
    _language = args["language"]?.toString();
    _unitUid = _parseInt(args["unitUid"]);
    _unitId = args["unitId"]?.toString() ?? '';
    isFromUnit = _parseBool(args["isFromUnit"]);

    onFetchData();

    fetchStyleConfigV2();

    _messageSub = MqttNotificationMessage.instance.listenByCode(
      codes: [
        MqttMessageServicesCode.MESSAGE_UNIT_PLAN,
        MqttMessageServicesCode.MESSAGE_UNIT_SENTENCE,
        MqttMessageServicesCode.MESSAGE_UNIT_LESSON_EXERCISE,
        MqttMessageServicesCode.MESSAGE_UNIT_LESSON_PLAN,
        MqttMessageServicesCode.MESSAGE_REMIX_CREATE,
        MqttMessageServicesCode.MESSAGE_SONG_CREATE,
        MqttMessageServicesCode.MESSAGE_UNIT_GRAMMAR,
      ],
      whereBackPage: true,
      onData: (value) {
        _refreshByMqttCode(value.message.code);
      },
    );
  }

  void _refreshByMqttCode(String? code) {
    if (code == MqttMessageServicesCode.MESSAGE_UNIT_PLAN ||
        code == MqttMessageServicesCode.MESSAGE_UNIT_SENTENCE ||
        code == MqttMessageServicesCode.MESSAGE_UNIT_LESSON_PLAN ||
        code == MqttMessageServicesCode.MESSAGE_UNIT_LESSON_EXERCISE ||
        code == MqttMessageServicesCode.MESSAGE_REMIX_CREATE ||
        code == MqttMessageServicesCode.MESSAGE_SONG_CREATE ||
        code == MqttMessageServicesCode.MESSAGE_UNIT_GRAMMAR)
         {
      _scheduleRefreshByMqtt();
    }
  }

  void _scheduleRefreshByMqtt() {
    _mqttRefreshTimer?.cancel();
    _mqttRefreshTimer = Timer(const Duration(milliseconds: 500), () {
      if (isClosed) return;
      onFetchData(isRefresh: true, unitIndex: tabCurrentIndex);
    });
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final s = value.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  // 获取数据
  void onFetchData({bool isRefresh = false, int unitIndex = 0}) async{
    if (isFromUnit) {
      _onFetchLessonList(isRefresh: isRefresh);
    } else {
      _onFetchPages(isRefresh: isRefresh, unitIndex: unitIndex);
    }
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
      _rebuildUnitIndexMap();
      
      if (unitTabList.isNotEmpty) {
        int nextTabIndex = _normalizeTabIndex(tabCurrentIndex, unitTabList.length);
        final int fallbackIndex = _normalizeTabIndex(unitIndex, unitTabList.length);
        bool shouldScrollToInitialUnit = false;
        if (tabCurrentIndex < 0 || tabCurrentIndex >= unitTabList.length) {
          nextTabIndex = fallbackIndex;
        }

        final int? targetUnitUid = _hasAppliedInitialUnitTab ? null : int.tryParse(_unitId ?? '');
        if (targetUnitUid != null) {
          final int idx = unitTabList.indexWhere((e) => e.uid == targetUnitUid);
          if (idx >= 0) {
            nextTabIndex = idx;
            shouldScrollToInitialUnit = true;
          }
        }
        _hasAppliedInitialUnitTab = true;

        tabCurrentIndex = _normalizeTabIndex(nextTabIndex, unitTabList.length);
        _setActiveUnit(unitTabList[tabCurrentIndex].uid, center: false);
        _rebuildTabController();
        if (shouldScrollToInitialUnit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isClosed) return;
            _programmaticScrolling = true;
            unawaited(_scrollToUnitSectionByIndex(tabCurrentIndex));
          });
        }
        unawaited(_refreshCurrentUnitReviewImage());
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
        _rebuildUnitIndexMap();
        unitTabList.refresh();
        if (unitTabList.isNotEmpty) {
          _setActiveUnit(unitTabList.first.uid, center: false);
          _rebuildTabController();
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

  int _normalizeTabIndex(int index, int length) {
    if (length <= 0) return 0;
    if (index < 0) return 0;
    if (index >= length) return length - 1;
    return index;
  }

  Future<void> _refreshCurrentUnitReviewImage() async {
    if (unitTabList.isEmpty) return;
    final int currentIndex = _normalizeTabIndex(tabCurrentIndex, unitTabList.length);
    final int currentUnitUid = unitTabList[currentIndex].uid;
    final int count = await getReviewImage("COURSE_UNIT", currentUnitUid);
    if (currentIndex >= unitTabList.length) return;
    if (unitTabList[currentIndex].uid != currentUnitUid) return;
    unitTabList[currentIndex].coverReviewImageCount = count;
    unitTabList.refresh();
  }

  void _rebuildTabController() {
    if (unitTabList.isEmpty) {
      tabController?.dispose();
      tabController = null;
      return;
    }
    tabCurrentIndex = _normalizeTabIndex(tabCurrentIndex, unitTabList.length);
    _isRebuildingTabController = true;
    tabController?.removeListener(_handleTabChange);
    tabController?.dispose();
    tabController = TabController(
      initialIndex: tabCurrentIndex,
      vsync: this,
      length: unitTabList.length,
    );
    tabController?.addListener(_handleTabChange);
    _isRebuildingTabController = false;
  }

  void _handleTabChange() {
    final TabController? controller = tabController;
    if (controller == null || _isRebuildingTabController || controller.indexIsChanging) return;
    final int nextIndex = controller.index;
    if (nextIndex == tabCurrentIndex) return;
    tabCurrentIndex = nextIndex;
    onFetchData(isRefresh: true, unitIndex: nextIndex);
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
    _rebuildUnitIndexMap();
    _setActiveUnit(unitTabList[tabCurrentIndex].uid, center: false);
    _rebuildTabController();
  }

  void rebuildUnitIndexMap() {
    _rebuildUnitIndexMap();
  }

  GlobalKey getUnitTabKey(int index) {
    if (index < 0) return GlobalKey();
    while (_unitTabKeys.length <= index) {
      _unitTabKeys.add(GlobalKey());
    }
    return _unitTabKeys[index];
  }

  GlobalKey getUnitSectionKey(int index) {
    if (index < 0) return GlobalKey();
    while (_unitSectionKeys.length <= index) {
      _unitSectionKeys.add(GlobalKey());
    }
    return _unitSectionKeys[index];
  }

  Future<void> scrollToUnitIndex(int index) async {
    if (index < 0 || index >= unitTabList.length) return;
    tabCurrentIndex = index;
    _setActiveUnit(unitTabList[index].uid);
    _programmaticScrolling = true;
    await _scrollToUnitSectionByIndex(index);
  }

  void _rebuildUnitIndexMap() {
    _unitIndexById.clear();
    if (_unitTabKeys.length != unitTabList.length || _unitSectionKeys.length != unitTabList.length) {
      _unitTabKeys
        ..clear()
        ..addAll(List.generate(unitTabList.length, (_) => GlobalKey()));
      _unitSectionKeys
        ..clear()
        ..addAll(List.generate(unitTabList.length, (_) => GlobalKey()));
    }
    for (int i = 0; i < unitTabList.length; i++) {
      _unitIndexById[unitTabList[i].uid] = i;
    }
    if (unitTabList.isEmpty) {
      activeUnitId.value = -1;
      tabCurrentIndex = 0;
      return;
    }
    tabCurrentIndex = _normalizeTabIndex(tabCurrentIndex, unitTabList.length);
    final int currentUnitId = unitTabList[tabCurrentIndex].uid;
    if (activeUnitId.value == -1 || !_unitIndexById.containsKey(activeUnitId.value)) {
      activeUnitId.value = currentUnitId;
    }
  }

  void _setActiveUnit(int? unitId, {bool center = true}) {
    if (unitId == null) return;
    if (activeUnitId.value != unitId) {
      activeUnitId.value = unitId;
    }
    final int? index = _unitIndexById[unitId];
    if (index != null) {
      tabCurrentIndex = index;
    }
    if (!center) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerActiveUnitTabIfNeeded(unitId);
    });
  }

  void _centerActiveUnitTabIfNeeded(int unitId) {
    if (isClosed || !unitTabScrollController.hasClients) return;
    final int? index = _unitIndexById[unitId];
    if (index == null || index < 0 || index >= _unitTabKeys.length) return;
    final BuildContext? itemContext = _unitTabKeys[index].currentContext;
    final BuildContext? viewportContext = unitTabViewportKey.currentContext;
    if (itemContext == null || viewportContext == null) return;
    final RenderObject? itemRenderObject = itemContext.findRenderObject();
    final RenderObject? viewportRenderObject = viewportContext.findRenderObject();
    if (itemRenderObject is! RenderBox || viewportRenderObject is! RenderBox) return;
    if (!itemRenderObject.attached || !viewportRenderObject.attached) return;
    final Offset offset = itemRenderObject.localToGlobal(Offset.zero, ancestor: viewportRenderObject);
    final double itemLeft = offset.dx;
    final double itemRight = itemLeft + itemRenderObject.size.width;
    final double viewportWidth = viewportRenderObject.size.width;
    final double edgePadding = 12.wMin;
    final bool isOutOfView = itemLeft < edgePadding || itemRight > viewportWidth - edgePadding;
    if (!isOutOfView) return;
    final double targetOffset =
        unitTabScrollController.offset + itemLeft - ((viewportWidth - itemRenderObject.size.width) / 2);
    final double maxOffset = unitTabScrollController.position.maxScrollExtent;
    unitTabScrollController.animateTo(
      targetOffset.clamp(0.0, maxOffset),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _syncActiveUnitByScroll() {
    if (_programmaticScrolling) return;
    if (unitTabList.isEmpty || !scrollController.hasClients) return;
    final double probeOffset = scrollController.offset + 60.wMin;
    int safeIndex = 0;
    for (int i = 0; i < unitTabList.length; i++) {
      final double? sectionOffset = _getUnitSectionOffset(i);
      if (sectionOffset == null) continue;
      if (sectionOffset <= probeOffset) {
        safeIndex = i;
        continue;
      }
      break;
    }
    _setActiveUnit(unitTabList[safeIndex].uid);
  }

  double? _getUnitSectionOffset(int index) {
    if (!scrollController.hasClients) return null;
    final double? estimatedOffset = _estimateUnitSectionOffset(index);
    if (index < 0 || index >= _unitSectionKeys.length) return estimatedOffset;
    final BuildContext? ctx = _unitSectionKeys[index].currentContext;
    if (ctx == null || !ctx.mounted) return estimatedOffset;
    final RenderObject? renderObject = ctx.findRenderObject();
    if (renderObject == null || !renderObject.attached) return estimatedOffset;
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
    return viewport.getOffsetToReveal(renderObject, 0).offset;
  }

  double? _estimateUnitSectionOffset(int index) {
    if (index < 0 || index >= unitTabList.length) return null;
    double offset = 24.wMin;
    for (int i = 0; i < index; i++) {
      offset += _estimateUnitSectionHeight(unitTabList[i], isFirst: i == 0);
    }
    final double dividerHeight = index == 0 ? 0 : 1;
    final double topPadding = index == 0 ? 0 : 22.wMin;
    offset += dividerHeight + topPadding;
    return offset;
  }

  double _estimateUnitSectionHeight(
    NewUnitResponseEntity unit, {
    required bool isFirst,
  }) {
    final int lessonCount = _buildDisplayLessons(unit).length;
    final int rowCount =
        lessonCount == 0 ? 0 : ((lessonCount + lessonGridCrossAxisCount - 1) ~/ lessonGridCrossAxisCount);
    final double gridHeight = rowCount == 0 ? 0 : (rowCount * 360.wMin) + ((rowCount - 1) * 10.wMin);
    final double dividerHeight = isFirst ? 0 : 1;
    final double topPadding = isFirst ? 0 : 22.wMin;
    return dividerHeight +
        topPadding +
        72.wMin +
        18.wMin +
        unitMiddlePanelHeight.wMin +
        18.wMin +
        gridHeight +
        40.wMin;
  }

  List<LessonResponseEntity> buildDisplayLessons(NewUnitResponseEntity unit) {
    return _buildDisplayLessons(unit);
  }

  List<LessonResponseEntity> _buildDisplayLessons(NewUnitResponseEntity unit) {
    final List<LessonResponseEntity> lessons = unit.lessonDTOList?.cast<LessonResponseEntity>() ?? const <LessonResponseEntity>[];
    return lessons.where((e) => !e.isUnitTARGET && !e.isUnitTEST && !e.isAddButton).toList();
  }

  Future<void> _scrollToUnitSectionByIndex(int index, {int retry = 0}) async {
    if (!scrollController.hasClients || index < 0 || index >= unitTabList.length) {
      _finishProgrammaticScroll();
      return;
    }
    final double? targetOffset = _getUnitSectionOffset(index);
    if (targetOffset == null) {
      if (retry >= 8) {
        _finishProgrammaticScroll();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToUnitSectionByIndex(index, retry: retry + 1);
      });
      return;
    }
    final double maxOffset = scrollController.position.maxScrollExtent;
    await scrollController
        .animateTo(
          targetOffset.clamp(0.0, maxOffset),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isClosed || !scrollController.hasClients) {
              _finishProgrammaticScroll();
              return;
            }
            final double? calibratedOffset = _getUnitSectionOffset(index);
            if (calibratedOffset == null) {
              _finishProgrammaticScroll();
              return;
            }
            final double newMaxOffset = scrollController.position.maxScrollExtent;
            final double diff = (scrollController.offset - calibratedOffset).abs();
            if (diff > 2.wMin) {
              scrollController.jumpTo(calibratedOffset.clamp(0.0, newMaxOffset));
            }
            _finishProgrammaticScroll();
          });
        });
  }

  void _finishProgrammaticScroll() {
    Future.delayed(const Duration(milliseconds: 80), () {
      _programmaticScrolling = false;
      _syncActiveUnitByScroll();
    });
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
    // dynamic res = await TagRoutes.toNamed(
    //   Routes.OFFICIAL_COURSE_DETAILS_TARGET,
    //   arguments: {
    //     "moduleId": _moduleId,
    //     "unitId": unitEntity.uid,
    //     "isAdminPage": true,
    //     "language": _language,
    //   },
    // );
    dynamic res = await TagRoutes.toNamed(
      Routes.COURSE_UNIT_TARGET,
      arguments: {
        "moduleId": _moduleId,
        "unitId": unitEntity.uid,
        "language": _language,
        "isManagement": true,
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

  Future<bool> onSaveUnitSort(
    List<NewUnitResponseEntity<LessonResponseEntity>> units,
  ) async {
    if (_moduleId == null) {
      ToastUtils.showManageToast(text: "moduleId为空");
      return false;
    }

    final List<int> ids = units.map((element) => element.uid).whereType<int>().toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "单元Id为空");
      return false;
    }

    ToastUtils.showLoading();
    try {
      final response = await ModuleUtil.edit(
        uid: _moduleId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"unitIds": ids},
        ),
      );
      if (response.data == null) {
        ToastUtils.showManageToast(text: response.message ?? "单元排序失败");
        return false;
      }
      unitTabList.assignAll(units);
      updateUnitList();
      CourseUpdateStore.to.notifyUnitUpdated();
      ToastUtils.showManageToast(text: response.message ?? "单元排序成功");
      return true;
    } catch (e) {
      ToastUtils.showManageToast(text: "单元排序失败");
      if (kDebugMode) {
        print(e.toString());
      }
      return false;
    } finally {
      ToastUtils.hideLoading();
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
  Future<void> toUnitTarget(NewUnitResponseEntity unitEntity, LessonResponseEntity? lessonEntity) async {
    if (lessonEntity?.isUnitTARGET == true || lessonEntity == null) {
      if (!ManageAuthUtils.isAuth(ManageAuthCode.unitKnowledgeList)) {
        ToastUtils.showManageToast(text: "无权限");
        return;
      }

      // await TagRoutes.toNamed(
      //   Routes.OFFICIAL_COURSE_DETAILS_TARGET,
      //   arguments: {
      //     "moduleId": _moduleId,
      //     "unitId": unitEntity.uid,
      //     "isAdminPage": true,
      //     "language": _language,
      //   },
      // );

      await TagRoutes.toNamed(
        Routes.COURSE_UNIT_TARGET,
        arguments: {
          "moduleId": moduleId,
          "unitId": unitEntity.uid,
          "language": _language,
          "isManagement": true,
        },
      );

      onFetchData(isRefresh: true);
    } else if (lessonEntity.isUnitTEST == true) {
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
          "unitId": unitEntity.uid,
          "lessonTemplateId": lessonEntity.lessonTemplateId,
          "difficultyMin": unitEntity.difficulty?.min,
          "difficultyMax": unitEntity.difficulty?.max,
          "language": unitEntity.language,
        },
      );
      onFetchData(isRefresh: true);
    }
  }

  Future<void> toUnitTargetKnowledgeType(NewUnitResponseEntity unitEntity, CourseUnitTargetEnum type) async {
    if (!ManageAuthUtils.isAuth(ManageAuthCode.unitKnowledgeList)) {
      ToastUtils.showManageToast(text: "无权限");
      return;
    }

    // await TagRoutes.toNamed(
    //   Routes.OFFICIAL_COURSE_DETAILS_TARGET,
    //   arguments: {
    //     "moduleId": _moduleId,
    //     "unitId": unitEntity.uid,
    //     "isAdminPage": true,
    //     "language": _language,
    //     "initialKnowledgeType": type.value,
    //   },
    // );

    await TagRoutes.toNamed(
      Routes.COURSE_UNIT_TARGET,
      arguments: {
        "moduleId": _moduleId,
        "unitId": unitEntity.uid,
        "language": _language,
        "initialKnowledgeType": type.rawValue,
        "isManagement": true,
      },
    );

    onFetchData(isRefresh: true);
  }

  Future<void> onRelateArticle(NewUnitResponseEntity unitEntity) async {
    if (!ManageAuthUtils.isAuth(ManageAuthCode.unitKnowledgeAdd)) {
      ToastUtils.showManageToast(text: "无权限");
      return;
    }

    try {
      final BuildContext? context = Get.context;
      if (context == null) return;

      final List<BaseKnowledge>? values = await ManageSelectKnowledgeTableManager.show(
        context: context,
        defaultDessert: [],
        language: _language,
        showSelectKnowledgeAddButton: true,
        currentKnowledgeType: KnowledgeTypeEnum.EN_TEXT,
      );
      if (values == null || values.isEmpty) return;

      final List<Knowledge> newLs = <Knowledge>[];
      for (int i = 0; i < values.length; i++) {
        final BaseKnowledge entity = values[i];
        if (entity is EnTextEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.content,
            contentId: entity.uid,
            definition: entity.title,
            imageUrl: entity.imageUrl,
            audioUrl: entity.audioUrl,
            language: entity.language,
          ));
        }
      }
      if (newLs.isEmpty) return;

      ToastUtils.showLoading();
      final response = await KnowledgeUtil.add(
        unitId: unitEntity.uid,
        config: RequestConfig(
          requireToken: true,
          parameters: {"moduleId": _moduleId},
          data: newLs.map((element) => element.toJson()).toList(),
        ),
      );
      if (response.code == HttpStatus.ok) {
        ToastUtils.showManageToast(text: '关联文章成功');
      } else {
        ToastUtils.showManageToast(text: response.message ?? '关联文章失败');
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
      onFetchData(isRefresh: true);
    }
  }

  Future<void> onRelateSong(NewUnitResponseEntity unitEntity) async {
    if (!ManageAuthUtils.isAuth(ManageAuthCode.unitKnowledgeAdd)) {
      ToastUtils.showManageToast(text: "无权限");
      return;
    }

    try {
      final Map<String, List<String>> presetFilters = {
        "contentType": ["EN_SONG"],
      };
      final NewUnitResponseEntityDifficulty? difficulty = unitEntity.difficulty;
      if (difficulty != null) {
        int? min = difficulty.min;
        int? max = difficulty.max;
        if (min != null && max != null) {
          if (min > max) {
            final int temp = min;
            min = max;
            max = temp;
          }
          presetFilters["difficulty"] = <String>[
            for (int i = min; i <= max; i++) i.toString(),
          ];
        } else if (min != null || max != null) {
          presetFilters["difficulty"] = <String>[(min ?? max).toString()];
        }
      }

      final dynamic result = await TagRoutes.toNamed(
        Routes.INTELLIGENT_SEARCH,
        arguments: {
          "moduleId": _moduleId,
          "unitId": unitEntity.uid,
          "isSelectable": true,
          "presetFilters": presetFilters,
          if ((unitEntity.description ?? "").trim().isNotEmpty) "searchHint": unitEntity.description,
        },
      );
      if (result is! List || result.isEmpty) return;

      final List<Knowledge> newLs = <Knowledge>[];
      for (int i = 0; i < result.length; i++) {
        if (result[i] is! Map) continue;
        final KnowledgeCommonEntityListContent content = KnowledgeCommonEntityListContent.fromJson(
          Map<String, dynamic>.from(result[i] as Map),
        );
        if (content.uid == null || content.type == null) continue;
        newLs.add(Knowledge(
          uid: content.uid ?? 0,
          contentType: content.type,
          contentId: content.uid,
        ));
      }
      if (newLs.isEmpty) return;

      ToastUtils.showLoading();
      final response = await KnowledgeUtil.add(
        unitId: unitEntity.uid,
        config: RequestConfig(
          requireToken: true,
          parameters: {"moduleId": _moduleId},
          data: newLs.map((element) => element.toJson()).toList(),
        ),
      );
      if (response.code == HttpStatus.ok) {
        ToastUtils.showManageToast(text: '关联歌曲成功');
      } else {
        ToastUtils.showManageToast(text: response.message ?? '关联歌曲失败');
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
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

  Future<void> openUnitGrammarHub(NewUnitResponseEntity unit) async {
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIT_GRAMMAR_HUB,
      arguments: {
        'moduleId': _moduleId,
        'unitId': unit.uid,
      },
    );
  }

  Future<void> runUnitGrammarAnalyze(NewUnitResponseEntity unit) async {
    final int currentUnitId = unit.uid;

    final bool isRegenerate = unit.grammarAnalyzed == 2;
    if (unit.grammarAnalyzed == 1) return;

    if (isRegenerate) {
      final bool askRes = await AskDialog.showUserAsk(
        context: Get.context!,
        content: '重新生成会覆盖当前大纲与 Target，并清空后续产线进度，确认继续吗？',
        cancel: '取消',
        define: '确认',
      );
      if (!askRes) return;
    }

    ToastUtils.showLoading();
    try {
      final response = await UnitUtil.generateUnitGrammar(
        unitId: currentUnitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: isRegenerate ? {'updateExists': true} : const {},
        ),
      );
      if (response?.code != 200) return;
      ToastUtils.showManageToast(text: response?.message ?? '操作成功');
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
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
    scrollController.removeListener(_syncActiveUnitByScroll);
    scrollController.dispose();
    unitTabScrollController.dispose();
    tabController?.removeListener(_handleTabChange);
    tabController?.dispose();
    tabController = null;
    _mqttRefreshTimer?.cancel();
    unitTabList.clear();
    _moduleId = null;
    _messageSub?.cancel();
    super.onClose();
  }
}
