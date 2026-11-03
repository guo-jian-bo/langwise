import 'package:api/entities/entities.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';

import 'index.dart';

class ImageModerationListController extends GetxController {
  /// 获取控制器实例
  static ImageModerationListController get to => Get.find<ImageModerationListController>();

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

  /// 状态对象
  final state = ImageModerationListState();

  /// 初始化
  @override
  void onInit() {
    super.onInit();

    // 设置滚动监听
    _setupScrollListener();

    // 用户审核列表
    onRefresh();
  }

  /// 设置滚动监听器
  ///
  /// 监听列表滑动，当滑动到距离底部一定距离时自动加载更多数据
  void _setupScrollListener() {
    scrollController.addListener(() {
      // 当滚动位置接近底部且还有更多数据时触发加载更多
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.8 && state.hasMoreData) {
        onLoadMore();
      }
    });
  }

  // 获取用户审核列表
  void onRefresh() async {
    try {
      state.offset = 0;

      final response = await ImageUtil.userReviewImages(
          config: RequestConfig(
              parameters: {"offset": state.offset, "limit": state.limit, "order": "-order"},
              data: null,
              requireToken: true));
      state.myReviews = response.data?.datas ?? [];
      state.totalCount = response.data?.count ?? 0;
      refreshController.finishRefresh();
    } catch (e) {
      print("图片审核列表异常e: $e");
      refreshController.finishRefresh(IndicatorResult.fail);
    } finally {
      update([ImageModerationListState.myReviewsId]);
    }
  }

  /// 加载更多数据
  void onLoadMore() async {
    try {
      state.offset = state.offset + state.limit;
      final response = await ImageUtil.userReviewImages(
          config: RequestConfig(
              parameters: {"offset": state.offset, "limit": state.limit, "order": "-order"},
              data: null,
              requireToken: true));
      state.myReviews.addAll(response.data?.datas ?? []);
      state.totalCount = response.data?.count ?? 0;
      if (state.hasMoreData) {
        // 标识加载更多完成
        refreshController.finishLoad();
      } else {
        // 标识没有更多数据
        refreshController.finishLoad(IndicatorResult.noMore);
      }
    } catch (e) {
      print("图片审核列表异常e: $e");
      refreshController.finishRefresh(IndicatorResult.fail);
    } finally {
      update([ImageModerationListState.myReviewsId]);
    }
  }

  /// 跳转知识点详情
  void toKnowledgePointDetail(KnowledgePoint knowledgePoint) {
    Get.toNamed(Routes.IMAGE_MODERATION_DETAIL, arguments: {
      "contentType": knowledgePoint.contentType,
      "content": knowledgePoint.content,
      "imageModerationType": 0,
    })?.then(_handleDetailPageReturn);
  }

  /// 处理详情页返回的回调
  /// 根据数据来源决定刷新方式
  void _handleDetailPageReturn(dynamic value) {
    // 用户审核列表始终需要刷新
    onRefresh();
  }

  @override
  void onClose() {
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }
}
