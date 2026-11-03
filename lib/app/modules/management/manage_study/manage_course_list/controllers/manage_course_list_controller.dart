import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_all_course_filter.dart';
import 'package:langwise/app/modules/management/dialog/manage_create_course/manage_create_course_dialog.dart';
import 'package:langwise/app/modules/management/dialog/manage_edit_course/manage_edit_course_dialog.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/dropdown_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageCourseListController extends BaseController with FilterMixin, ManageBreadcrumbMixin {
  final String tag;
  ManageCourseListController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_COURSE_LIST;

  @override
  String get breadcrumbTitle => '课程列表';

  final RxList<CourseResponseEntity> courses = <CourseResponseEntity>[].obs;

  final RxInt _filterIndex = 5.obs;

  set filterIndex(int value) => _filterIndex.value = value;

  int get filterIndex => _filterIndex.value;

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final ScrollController courseScrollController = ScrollController();

  ManageAllCourseFilterResult? filterResult = ManageAllCourseFilterResult(
      languages: [StaticDataEntity(name: "英语", value: StaticData.english)],
      authorList: [StaticDataEntity(name: "官方", value: "OFFICIAL")]);

  List<StaticDataEntity> sortList = [
    StaticDataEntity(name: "UID", value: "uid"),
    StaticDataEntity(name: "创建时间", value: "created"),
  ];

  SortDialogResult staticDataEntity = SortDialogResult(selectBasisIndex: 1, selectSortIndex: 1);

  Worker? _courseUpdateWorker;

  int totalCount = 0;

  bool get hasMoreData => totalCount > courses.length;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    _setupScrollListener();
    final courseUpdateStore = CourseUpdateStore.to;
    _courseUpdateWorker = ever(courseUpdateStore.needRefreshCourseList, (needRefresh) {
      if (needRefresh) {
        onRefresh();
        courseUpdateStore.courseListRefreshed();
      }
    });

    onRefresh();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(["manage_course_list"]);
  }

  void _setupScrollListener() {
    courseScrollController.addListener(() {
      if (courseScrollController.position.pixels >= courseScrollController.position.maxScrollExtent * 0.8 &&
          hasMoreData) {
        onLoadMore();
      }
    });
  }

  @override
  Future<void> onRefresh() async {
    try {
      String? order, access;
      if (staticDataEntity.sort != null && staticDataEntity.basis != null) {
        order = "${staticDataEntity.sort?.value ?? ''}${staticDataEntity.basis?.value ?? ''}";
      }

      List<String> language = [], author = [];

      if ((filterResult?.languages ?? []).isNotEmpty) {
        language = filterResult!.languages!.map((e) => e.value).toList();
      }

      if (filterResult?.offShelf?.value != null) {
        access = filterResult?.offShelf?.value;
      }

      if ((filterResult?.authorList ?? []).isNotEmpty) {
        author = filterResult!.authorList!.map((e) => e.value).toList();
      }

      order ??= "-created";

      Map<String, dynamic> data = {
        "uid": uids.isEmpty ? null : uids,
        "name": title,
        "language": language.isEmpty ? null : language,
        "scope": author.isEmpty ? null : author,
      };
      if (access != null) {
        data["access"] = access;
      }

      offset = 0;
      final response = await CourseUtil.fetchCourses(
          config: RequestConfig(
              requireToken: true,
              parameters: {"offset": offset, "limit": limit, "order": order},
              data: data,
              cancelToken: cancelToken));
      courses.value = response.data?.datas ?? [];
      totalCount = response.data?.count ?? 0;
      refreshController.finishRefresh();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      refreshController.finishRefresh(IndicatorResult.fail);
    } finally {
      _initData();
    }
  }

  Future<void> onLoadMore() async {
    try {
      offset = offset + limit;

      String? order, access;
      if (staticDataEntity.sort != null && staticDataEntity.basis != null) {
        order = "${staticDataEntity.sort?.value ?? ''}${staticDataEntity.basis?.value ?? ''}";
      }

      List<String> language = [], author = [];

      if ((filterResult?.languages ?? []).isNotEmpty) {
        language = filterResult!.languages!.map((e) => e.value).toList();
      }

      if (filterResult?.offShelf?.value != null) {
        access = filterResult?.offShelf?.value;
      }

      if ((filterResult?.authorList ?? []).isNotEmpty) {
        author = filterResult!.authorList!.map((e) => e.value).toList();
      }

      order ??= "-created";

      final response = await CourseUtil.fetchCourses(
          config: RequestConfig(
              requireToken: true,
              parameters: {"offset": offset, "limit": limit, "order": order},
              data: {
                "uid": uids.isEmpty ? null : uids,
                "name": title,
                "language": language.isEmpty ? null : language,
                "scope": author.isEmpty ? null : author,
                "access": access,
              },
              cancelToken: cancelToken));
      courses.addAll(response.data?.datas ?? []);
      totalCount = response.data?.count ?? 0;
      if (hasMoreData) {
        refreshController.finishLoad();
      } else {
        refreshController.finishLoad(IndicatorResult.noMore);
      }
    } catch (e) {
      refreshController.finishLoad(IndicatorResult.fail);
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  void onSort(String uid, String index) async {
    try {
      final response = await CourseUtil.order(
          uid: uid, config: RequestConfig(requireToken: true, parameters: {"index": index}, cancelToken: cancelToken));
      if (response.data != null) {
        onRefresh();
      } else {
        ToastUtils.showManageToast(text: "课程排序失败");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void onLongSecondaryTap(CourseResponseEntity model, BuildContext context, Widget? child) {
    final List<DropdownPopData> dropDownList = [
      if(ManageAuthUtils.isAuth(ManageAuthCode.courseEdit)) DropdownPopData(name: "上架", index: 0),
      if(ManageAuthUtils.isAuth(ManageAuthCode.courseEdit)) DropdownPopData(name: "下架", index: 1),
      if(ManageAuthUtils.isAuth(ManageAuthCode.courseOrder)) DropdownPopData(name: "排序", index: 2),
      DropdownPopData(name: "复制ID", index: 4),
      if(ManageAuthUtils.isAuth(ManageAuthCode.courseEdit)) DropdownPopData(name: "编辑描述", index: 5),
    ];

    DropdownPop.show(
            context: context, globalKey: model.globalKey, child: child, list: dropDownList, menuItemWidth: 210.ww)
        .then((data) {
      if (data == null) return;
      if (data.index == 0 || data.index == 1) {
        onEditCourse(model.uid?.toString() ?? '', access: (data.index == 0) ? "NORMAL" : "INTERNAL");
      } else if (data.index == 2) {
        showSort(context, model.uid);
      }
      if (data.index == 4) {
        onCopyId(model);
      } else if (data.index == 5) {
        onEditDes(model);
      }
    });
  }

  void add() {
    ManageCreateCourseManager.show(context: Get.context!)?.then((value) {
      if (value != null && value) {
        onRefresh();
      }
    });
  }

  void showFilter(BuildContext context) {
    ManageAllCourseFilter.show(
      context: context,
      initFilterResult: filterResult,
      onSure: (result) {
        filterResult = result;
        onRefresh();
      },
    );
  }

  Future<void> showSort(BuildContext context, int? uid) async {
    final String? resText = await onShowSort(context);
    if (ObjectUtil.isEmpty(resText)) return;
    onSort(uid.toString(), resText!);
  }

  void toSort(BuildContext context) {
    SortDialog.show(
      context: context,
      basisList: sortList,
      init: staticDataEntity,
      onSort: (data) {
        staticDataEntity = data;
        onRefresh();
      },
    );
  }

  Future<void> onCopyId(CourseResponseEntity model) async {
    await Clipboard.setData(ClipboardData(text: model.uid?.toString() ?? ''));
    ToastUtils.showManageToast(text: "复制成功", type: ManageToastType.defaultType);
  }

  void onEditCourse(String uid, {String? access, String? des, String? name, String? cover}) async {
    try {
      final response = await CourseUtil.edit(
          uid: uid,
          config: RequestConfig(
              requireToken: true,
              data: {"access": access, "description": des, "name": name, "cover": cover},
              cancelToken: cancelToken));
      if (response.data != null) {
        onRefresh();
        ToastUtils.showManageToast(text: "修改成功");
      } else {
        ToastUtils.showManageToast(text: response.message ?? "修改失败");
      }
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message ?? "修改失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "修改失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  void onEditDes(CourseResponseEntity model) {
    ManageEditCourse.show(context: Get.context!, courseEntity: model)?.then((value) {
      if (value != null && value.isNotEmpty) {
        onEditCourse(model.uid?.toString() ?? '', name: value['name'], cover: value['cover']);
      }
    });
  }

  void toAllCourseDetail(CourseResponseEntity courseEntity) {
    if(!ManageAuthUtils.isAuth(ManageAuthCode.courseLevelList)) return;
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_ALL_COURSES_DETILS,
      arguments: {
        "name": courseEntity.name ?? '',
        "uid": courseEntity.uid,
        "language": courseEntity.language,
      },
    );
  }

  @override
  void onClose() {
    _courseUpdateWorker?.dispose();
    courseScrollController.dispose();
    super.onClose();
  }
}
