import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/static/static_data.dart';
import '../../../../../../common/widgets/dropdown_widget.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/manage_all_coures_sort.dart';
import '../../../common/manage_all_course_filter.dart';
import '../../../dialog/manage_specialized_course_create_dialog.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../views/manage_phonics_edit_course_dialog.dart';

class ManagePhonicsCourseController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManagePhonicsCourseController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_PHONICS_COURSE;

  @override
  String get breadcrumbTitle => '自然拼读课';

  final ScrollController scrollController = ScrollController();
  bool loading = false;

  /// 筛选- 语言/上架状态/主播(默认英语/官方)
  ManageAllCourseFilterResult? filterResult = ManageAllCourseFilterResult(
    languages: [StaticDataEntity(name: "英语", value: StaticData.english)],
    authorList: [StaticDataEntity(name: "官方", value: "OFFICIAL")],
  );

  // 排序
  List<StaticDataEntity> sortList = [
    StaticDataEntity(name: "UID", value: "uid"),
    StaticDataEntity(name: "创建时间", value: "created"),
  ];

  SortDialogResult staticDataEntity = SortDialogResult(selectBasisIndex: 1, selectSortIndex: 1);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController uidController = TextEditingController();

  final RxList<CourseResponseEntity> courses = <CourseResponseEntity>[].obs;

  /// 总数据量
  int totalCount = 0;
  // 每页请求的数量
  final int limit = 30;
  // 列表加载数据
  int offset = 0;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    refreshData();

    scrollController.addListener(() {

      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 && !scrollController.position.outOfRange) {
        if(courses.length < totalCount && !loading){
          loading = true;
          offset += limit;
          getPhonicsCourseList();
        }
      }
    });

  }

  /// 刷新
  Future<void> refreshData() async {
    offset = 0;
    totalCount = 0;
    courses.clear();
    await getPhonicsCourseList();
  }

  Future<void> getPhonicsCourseList() async {
    Map<String, dynamic> parameters = {
      "offset": offset,
      "limit": limit,
    };
    if (staticDataEntity.sort != null && staticDataEntity.basis != null) {
      parameters["order"] = "${staticDataEntity.sort?.value ?? ''}${staticDataEntity.basis?.value ?? ''}";
    } else {
      parameters["order"] = "-created";
    }

    Map<String, dynamic> reqData = {
      "specialty": SpecialtyEnum.EN_PHONICS, // 专项课
    };
    if (nameController.text.trim().isNotEmpty) {
      reqData["name"] = null;
    }
    if (uidController.text.trim().isNotEmpty) {
      // 以逗号或空格拆分UID字符串
      List<String> uids = uidController.text.trim().split(RegExp(r'[,\s]+'));
      reqData['uid'] = uids;
    }
    if ((filterResult?.languages ?? []).isNotEmpty) {
      reqData["language"] = filterResult!.languages!.map((e) => e.value).toList();
    }
    if (filterResult?.offShelf?.value != null) {
      reqData["access"] = filterResult?.offShelf?.value;
    }
    if ((filterResult?.authorList ?? []).isNotEmpty) {
      reqData["scope"] = filterResult!.authorList!.map((e) => e.value).toList();
    }
    try {
      final response = await CourseUtil.fetchCourses(config: RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: reqData,
      ));
      courses.addAll(response.data?.datas ?? []);
      totalCount = response.data?.count ?? 0;
    } catch (_) {} finally {
      loading = false;
    }
  }

  /// 添加课程弹窗
  Future<void> addCourse(BuildContext context) async {
    bool? isSuccess = await ManageSpecializedCourseCreateDialog.show(
      context: context,
    );
    if (isSuccess == true) {
      refreshData();
    }
  }

  /// 排序弹窗
  Future<void> sortCourse(BuildContext context) async {
    SortDialog.show(
      context: context,
      basisList: sortList,
      init: staticDataEntity,
      onSort: (data) {
        staticDataEntity = data;
        refreshData();
      },
    );
  }

  /// 筛选弹窗
  Future<void> filterCourse(BuildContext context) async {
    ManageAllCourseFilter.show(
      context: context,
      initFilterResult: filterResult,
      onSure: (result) {
        filterResult = result;
        refreshData();
      },
    );
  }

  Future<void> onLongSecondaryTap(CourseResponseEntity model, BuildContext context, Widget? child) async {
    final List<DropdownPopData> dropDownList = [
      DropdownPopData(name: "上架", index: 0),
      DropdownPopData(name: "下架", index: 1),
      DropdownPopData(name: "排序", index: 2),
      DropdownPopData(name: "复制ID", index: 4),
      DropdownPopData(name: "编辑", index: 5),
    ];

    DropdownPopData? data = await DropdownPop.show(
      context: context,
      globalKey: model.globalKey,
      child: child,
      list: dropDownList,
      menuItemWidth: 210.wMin,
    );
    if (data == null) return;
    if (data.index == 0 || data.index == 1) {
      onEditCourseReq(model.uid, access: (data.index == 0) ? "NORMAL" : "INTERNAL");
    } else if (data.index == 2) {
      onShowSort(context, model.uid);
    } if (data.index == 4) {
      onCopyId(model);
    } else if (data.index == 5) {
      onEditCourse(context, model);
    }
  }

  /// 编辑课程
  Future<void> onEditCourse(BuildContext context, CourseResponseEntity model) async {
    bool? isSuccess = await ManagePhonicsEditCourseDialog.show(
      context: context,
      course: model,
    );
    if (isSuccess == true) {
      refreshData();
    }
  }

  // 复制ID
  Future<void> onCopyId(CourseResponseEntity model) async{
    await Clipboard.setData(ClipboardData(text: model.uid?.toString() ?? ''));
    ToastUtils.showManageToast(text: "复制成功", type: ManageToastType.defaultType);
  }

  /// 排序
  Future<void> onShowSort(BuildContext context, int? uid) async {
    if (uid == null) return;
    String? res = await ManageAllCouresSort.show(context: context);
    if (res == null) return;
    try {
      final response = await CourseUtil.order(
        uid: uid.toString(), 
        config: RequestConfig(requireToken: true, parameters: {"index": res}),
      );
      if (response.data != null) {
        refreshData();
      } else {
        ToastUtils.showManageToast(text: "课程排序失败");
      }
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message ?? "修改失败");
    } catch (e) {
      ToastUtils.showManageToast(text: "修改失败");
    }
  }

  Future<void> onEditCourseReq(int? uid, {String? access, String? des, String? name, String? cover}) async {
    if (uid == null) return;
    try {
      ToastUtils.showLoading();
      final response = await CourseUtil.edit(
        uid: uid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"access": access, "description": des, "name": name, "cover": cover},
        ),
      );
      if (response.data != null) {
        refreshData();
        ToastUtils.showManageToast(text: "修改成功");
      } else {
        ToastUtils.showManageToast(text: response.message ?? "修改失败");
      }
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message ?? "修改失败");
    } catch (e) {
      ToastUtils.showManageToast(text: "修改失败");
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 跳转至课程详情
  Future<void> toCourseDetail(CourseResponseEntity course) async {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_ALL_COURSES_DETILS,
      arguments: {
        "name": course.name ?? '', 
        "uid": course.uid, 
        "language": course.language,
      },
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.dispose();
  }
}
