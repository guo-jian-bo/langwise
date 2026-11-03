import 'package:api/entities/response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/membership_card_manage/controllers/membership_card_manage_controller.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_code_manage/views/new_code_dialog.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/delete_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';

import '../models/membership_card_manage_code_manage_model.dart';

class MembershipCardManageCodeManageController extends GetxController {
  final String tagText;
  MembershipCardManageCodeManageController({required this.tagText});

  RxInt currentIndex = 0.obs;
  RxInt filterIndex = (-1).obs;
  RxInt sort1Index = (-1).obs;
  RxInt sort2Index = (-1).obs;
  final ScrollController scrollController = ScrollController();
  final TextEditingController textFieldController = TextEditingController();

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  bool isRequesting = false;
  final CancelToken cancelToken = CancelToken();
  final RxList<MembershipCardManageCodeManageModel> codeList = <MembershipCardManageCodeManageModel>[].obs;
  // 每页请求的数量
  final int limit = 10;
  // 列表加载数据
  int offset = 0;
  // 总数据量
  int totalCount = 0;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    onRefresh();
  }

  @override
  dispose() {
    scrollController.dispose();
    textFieldController.dispose();
    refreshController.dispose();
    super.dispose();
  }

  /// 监听列表滑动，当滑动到距离底部一定距离时自动加载更多数据
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (totalCount > codeList.length && scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.9 && !isRequesting) {
        onLoadMore();
      }
    });
  }

  // 上拉加载更多
  Future<void> onLoadMore() async {
    if (isRequesting) return;

    int tempOffset = offset;
    ToastUtils.showLoading();

    int? order;
    if (sort1Index.value == 0) {
      order = 1;
    } else if (sort1Index.value == 1) {
      order = 2;
    } else if (sort1Index.value == 2) {
      order = 3;
    }

    int? liftOrder;
    if (sort2Index.value == 0) {
      liftOrder = 1;
    } else if (sort2Index.value == 1) {
      liftOrder = 2;
    }

    int? userId;
    if (textFieldController.text.isNotEmpty) {
      userId = int.tryParse(textFieldController.text);
    }

    int? status;
    if (filterIndex.value == 0) {
      status = 1;
    } else if (filterIndex.value == 1) {
      status = 2;
    } else if (filterIndex.value == 2) {
      status = 3;
    } else if (filterIndex.value == 3) {
      status = 4;
    }

    String? vipType;
    if (currentIndex.value == 1) {
      vipType = 'Plus';
    } else if (currentIndex.value == 2) {
      vipType = 'Pro';
    } else if (currentIndex.value == 3) {
      vipType = 'Max';
    } else if (currentIndex.value == 4) {
      vipType = 'Test';
    } else if (currentIndex.value == 5) {
      vipType = 'Seat';
    }

    try {
      isRequesting = true;
      tempOffset += limit;
      final ResponseEntity<MembershipCardManageCodeManageModelEntity>? res = await MembershipCardManageApi.codeManageList(
        parameters: {
          "offset": tempOffset,
          "limit": limit,
          "order": order,
          "liftOrder": liftOrder,
          "userId": userId,
          "status": status,
          "vipType": vipType,
        },
        data: {},
      );
      refreshController.finishLoad();
      if (res?.data == null) {
        tempOffset -= limit;
        return;
      }
      codeList.addAll(res?.data?.datas ?? []);
      totalCount = res?.data?.count ?? 0;
      if (codeList.length >= totalCount) {
        refreshController.finishLoad(IndicatorResult.noMore);
      }
    } catch (e) {
      tempOffset -= limit;
      refreshController.finishLoad(IndicatorResult.fail);
    } finally {
      offset = tempOffset;
      ToastUtils.hideLoading();
      isRequesting = false;
    }
  }

  // 下拉刷新
  Future<void> onRefresh() async {
    if (isRequesting) return;
    ToastUtils.showLoading();

    int? order;
    if (sort1Index.value == 0) {
      order = 1;
    } else if (sort1Index.value == 1) {
      order = 2;
    } else if (sort1Index.value == 2) {
      order = 3;
    }

    int? liftOrder;
    if (sort2Index.value == 0) {
      liftOrder = 1;
    } else if (sort2Index.value == 1) {
      liftOrder = 2;
    }

    String? userId;
    if (textFieldController.text.isNotEmpty) {
      userId = textFieldController.text;
    }

    int? status;
    if (filterIndex.value == 0) {
      status = 1;
    } else if (filterIndex.value == 1) {
      status = 2;
    } else if (filterIndex.value == 2) {
      status = 3;
    } else if (filterIndex.value == 3) {
      status = 4;
    }

    String? vipType;
    if (currentIndex.value == 1) {
      vipType = 'Plus';
    } else if (currentIndex.value == 2) {
      vipType = 'Pro';
    } else if (currentIndex.value == 3) {
      vipType = 'Max';
    } else if (currentIndex.value == 4) {
      vipType = 'Test';
    } else if (currentIndex.value == 5) {
      vipType = 'Seat';
    }

    try {
      isRequesting = true;
      offset = 0;
      codeList.clear();
      final ResponseEntity<MembershipCardManageCodeManageModelEntity>? res = await MembershipCardManageApi.codeManageList(
        parameters: {
          "offset": offset,
          "limit": limit,
          "order": order,
          "liftOrder": liftOrder,
          "activateUserId": userId,
          "status": status,
          "vipType": vipType,
        },
        data: {},
      );
      refreshController.finishRefresh();
      if (res?.data == null) {
        return;
      }
      codeList.addAll(res?.data?.datas ?? []);
      totalCount = res?.data?.count ?? 0;
    } catch (e) {
      refreshController.finishRefresh(IndicatorResult.fail);
    } finally {
      ToastUtils.hideLoading();
      isRequesting = false;
    }
  }

  /// 30天销毁退款
  Future<void> destroyRefund(MembershipCardManageCodeManageModel item) async {
    if(item.code == null) return;
    bool askRes = await DeleteDialog.show(
      context: Get.context!,
      title: "确认销毁退款？",
      subTitle: "30天未激活的会员卡销毁，退款会退回到账户中。",
      subContentList: item.revokeOrderPromptList??[],
      confirmText: "确认销毁",
    );
    if (!askRes) return;

    Map<String, dynamic> reqData = {

    };

    try {
      ToastUtils.showLoading();

      bool destroyRes = await MembershipCardManageApi.destroyRefund(item.code!, reqData);
      if (!destroyRes) return;
      

      await AskDialog.showUserAsk(
        context: Get.context!,
        content: "退款成功",
        define: "确认",
        showCancel: false,
      );

      if (isClosed) return;
      // 账户界面概览刷新数据
      if (Get.isRegistered<MembershipCardManageController>(tag: tagText)) {
        MembershipCardManageController membershipCardManageController =
            Get.find<MembershipCardManageController>(tag: tagText);
        await membershipCardManageController.initData();
      }

      //刷新数据
      onRefresh();

    } finally{
      ToastUtils.hideLoading();
    }

  }

  // 撤销激活
  Future<void> cancelActivate(MembershipCardManageCodeManageModel item) async {
    //确认框
    bool res = await DeleteDialog.show(
      context: Get.context!,
      title: "确认撤销激活？",
      subTitle: item.revokeOrderPrompt ?? "撤销后该会员卡将立即失效，用户将无法继续使用相关权益。退款会退回到账户中。",
      subContentList: item.revokeOrderPromptList??[],
      confirmText: "确认撤销",
    );
    if (!res) return;

    if (item.code == null) return;
    ToastUtils.showLoading();
    try {
      final ResponseEntity<MembershipCardCancelActivateEntity>? res = await MembershipCardManageApi.cancelActivate(item.code!);
      if (res == null) return;
      final data = res.data;
      if(data?.isNewCoupon??false){
        if(data!=null){
          showCupertinoDialog(context: Get.context!,builder: (context){
            return NewCodeDialogWidget(entity: data);
          });
        }
      }else{
      await AskDialog.showUserAsk(
        context: Get.context!,
        content: "退款成功",
        define: "确认",
        showCancel: false,
      );
      }


      // 账户界面概览刷新数据
      if (Get.isRegistered<MembershipCardManageController>(tag: tagText)) {
        if (isClosed) return;
        MembershipCardManageController membershipCardManageController =
            Get.find<MembershipCardManageController>(tag: tagText);
        await membershipCardManageController.initData();
      }

      //刷新数据
      onRefresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 添加备注
  Future<void> addNote(int salesCardId, String note) async {
    ToastUtils.showLoading();
    try {
      final ResponseEntity? res = await MembershipCardManageApi.addNote(
        data: {
          "salesCardId": salesCardId,
          "remarks": note,
        },
      );
      if (res == null) return;

      final index = codeList.indexWhere((item) => item.uid == salesCardId);
      if (index != -1) {
        codeList[index].remarks = note;
        codeList.refresh();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
