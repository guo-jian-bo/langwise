
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/stores/stores.dart';
import '../../../../routes/routes.dart';
import '../../models/manage_auth_menu_model.dart';
import '../../utils/manage_breadcrumb_utils.dart';
import '../../utils/manage_page_registry.dart';

class ManageReviewController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewController({required this.tag});

  final RxList<ManageAuthMenuModel> managePeviewList = <ManageAuthMenuModel>[].obs;
  

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW;
  
  @override
  String get breadcrumbTitle => '审核';


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    initAuth();
  }

  void initAuth(){
    managePeviewList.clear();

    RolePermissionsEntity rolePermissions = UserStore.to.rolePermissions.value;

    if(rolePermissions.userIsImageReviewer){
      managePeviewList.add(ManageAuthMenuModel(
        name: "审核图片",
        subtitle: "从内容安全到画面品质的全流程审核",
        authCode: "",
        route: Routes.MANAGE_CHECK_IMAGE,
      ));
    }

    if(rolePermissions.userIsExerciseReviewer){
      String route = Routes.PRACTICE_QUESTIONS_REVIEW;

      if(rolePermissions.isOfficial){
        // 如果是管理员 跳转至列表页面
        route = Routes.MANAGE_REVIEW_EXERCISES;
      }

      managePeviewList.add(ManageAuthMenuModel(
        name: "审核题目",
        subtitle: "内容与质量双重审核，构建优质题库",
        authCode: "",
        route: route,
      ));
    }

    if(rolePermissions.userIsVideoReviewer){
      managePeviewList.add(ManageAuthMenuModel(
        name: "审核视频",
        subtitle: "从内容安全到画面品质的全流程审核",
        authCode: "",
        route: Routes.MANAGE_REVIEW_VIDEO,
      ));
    }

  }

  void toPage(ManageAuthMenuModel data){
    if(data.route.isEmpty) return;
    if(data.route == Routes.PRACTICE_QUESTIONS_REVIEW){
      Get.toNamed(data.route);
      return;
    }
    ManagePageRegistry.jumpTo(data.route);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
