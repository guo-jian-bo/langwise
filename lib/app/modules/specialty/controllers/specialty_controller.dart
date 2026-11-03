import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/home_card_code.dart';
import '../../../../common/https/https.dart';
import '../../../../utils/utils.dart';
import '../model/speciaity_default_phonics_model.dart';
import '../../../../common/entities/speciaity_phonics_model.dart';

class SpecialtyController extends GetxController
    with GetTickerProviderStateMixin, RoutesBreadcrumbMixin {
  final String tagText;
  SpecialtyController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.SPECIALTY;

  @override
  String get breadcrumbTitle => '专项';

  static bool hasAliveInstance = false;

  /// 首页请求错误状态
  /// -1=未请求 0=成功 1=无网络 2=请求超时 3=服务器请求异常(代表服务器回null) 4=空(代表服务器回的是空) 5=未知异常
  final RxInt homeReqError = (-1).obs;

  ///全部数据
  final RxList<HomeCardEntityItems> cardEntityItems =
      <HomeCardEntityItems>[].obs;

  /// 已经加入的发音课数据
  final RxList<SpeciaityPhonicsModel> phonicsDatas =
      <SpeciaityPhonicsModel>[].obs;
  TabController? phonicsTabController;
  final RxInt phonicsTabIndex = 0.obs;

  /// 默认显示的课程 循环轮播的展示课程
  final RxList<SpeciaityDefaultPhonicsModel> defaultPhonicsDatas =
      <SpeciaityDefaultPhonicsModel>[].obs;
  TabController? defaultPhonicsTabController;
  final RxInt defaultPhonicsTabIndex = 0.obs;
  final RxInt phonicsEntryVersion = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    hasAliveInstance = true;
    initHomeCardList();
  }

  Future<void> initHomeCardList() async {
    if (LockUtils.checkExperienceAppStorage()) return;

    try {
      if (!(await ConnectivityUtil.checkConnectivity())) {
        homeReqError.value = 1;
        return;
      }

      HomeCardEntity? homeCardEntity = await SpecialtyRequest.getHomeCardList();
      if (homeCardEntity == null) {
        homeReqError.value = 3;
        return;
      }
      List<HomeCardEntityItems?>? items = homeCardEntity.items;
      if (items == null) {
        homeReqError.value = 4;
        return;
      }

      cardEntityItems.clear();
      for (var item in items) {
        if (item == null) continue;
        cardEntityItems.add(item);
      }

      if (cardEntityItems.isEmpty) {
        homeReqError.value = 4;
      } else {
        homeReqError.value = 0;
      }

      for (int i = 0; i < cardEntityItems.length; i++) {
        if (cardEntityItems[i].code == HomeCardCode.phonicsInitCourse) {
          initDefaultPhonics(cardEntityItems[i]);
        } else if (cardEntityItems[i].code == HomeCardCode.phonicsCourse) {
          initPhonics(cardEntityItems[i]);
        }
      }
      if (homeReqError.value == 0) {
        phonicsEntryVersion.value++;
      }
    } on DioException catch (e) {
      DioExceptionType dioExceptionType =
          DioExceptionUtils.handleDioException(e);
      if (dioExceptionType == DioExceptionType.connectionTimeout ||
          dioExceptionType == DioExceptionType.sendTimeout ||
          dioExceptionType == DioExceptionType.receiveTimeout) {
        homeReqError.value = 2;
      } else {
        homeReqError.value = 3;
      }
    } catch (_) {
      homeReqError.value = 5;
    }
  }

  /// 初始化默认发音课数据
  void initDefaultPhonics(HomeCardEntityItems data) {
    try {
      List? list = data.list;
      if (list == null) return;
      defaultPhonicsDatas.clear();
      for (var item in list) {
        if (item == null) continue;
        SpeciaityDefaultPhonicsModel model =
            SpeciaityDefaultPhonicsModel.fromJson(item);
        defaultPhonicsDatas.add(model);
      }

      defaultPhonicsTabController =
          TabController(length: defaultPhonicsDatas.length, vsync: this);
      defaultPhonicsTabController?.addListener(() {
        defaultPhonicsTabIndex.value = defaultPhonicsTabController?.index ?? 0;
      });
    } catch (_) {}
  }

  /// 初始化发音课
  Future<void> initPhonics(HomeCardEntityItems data) async {
    try {
      List? list = data.list;
      if (list == null) return;
      phonicsDatas.clear();
      for (var item in list) {
        if (item == null) continue;
        phonicsDatas.add(SpeciaityPhonicsModel.fromJson(item));
      }

      phonicsTabController =
          TabController(length: phonicsDatas.length, vsync: this);
      phonicsTabController?.addListener(() {
        phonicsTabIndex.value = phonicsTabController?.index ?? 0;
      });
    } catch (_) {}
  }

  int? get defaultPhonicsCourseId {
    for (final item in phonicsDatas) {
      final int? courseId = item.data?.courseId;
      if (courseId != null) return courseId;
    }
    for (final item in defaultPhonicsDatas) {
      for (final module in item.data?.moduleInfoList ?? const []) {
        final int? courseId = module?.courseId;
        if (courseId != null) return courseId;
      }
    }
    return null;
  }

  /// 根据code跳转页面
  Future<void> toPageByCode(
      HomeCardEntityItems data, BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;

    if (await LockUtils.checkLock(data.rights, context)) return;

    PushMessageEntity jumpData = PushMessageEntity(
      jump: data.jump,
      category: JumpPageUtils.userType,
    );
    await JumpPageUtils.jumpPage(jumpData);
    initHomeCardList();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    hasAliveInstance = false;
    try {
      phonicsTabController?.dispose();
    } catch (_) {}
    super.onClose();
  }
}
