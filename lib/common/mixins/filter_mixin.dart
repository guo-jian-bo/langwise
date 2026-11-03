import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/modules/management/common/manage_all_coures_sort.dart';
import '../../app/modules/management/common/manage_all_course_filter.dart';

mixin FilterMixin on GetxController {
  /// 筛选
  void onShowFilter(BuildContext context,
      {List<int>? selectLanguageIndex,
      int? selectListingStatusIndex,
      List<int>? selectAuthorIndex,
      ManageAllCourseFilterListener? listener}) {
    // ManageAllCourseFilter.show(
    //     context: context,
    //     selectLanguageIndex: selectLanguageIndex ?? [],
    //     selectListingStatusIndex: selectListingStatusIndex ?? -1,
    //     selectAuthorIndex: selectAuthorIndex ?? [],
    //     listener: listener);
  }

  /// 排序
  Future<String?> onShowSort(BuildContext context) async {
    return await ManageAllCouresSort.show(context: context);
  }
}
