/// 图片审核控制器
///
/// 功能概述：
/// 图片审核是一个独立功能模块，用于审核系统中的图片资源，确保图片内容符合要求。
/// 该功能需要同时在主APP和管理端的嵌套路由中使用，且两者之间的状态需要隔离。
///
import 'package:api/entities/entities.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'index.dart';

class ImageModerationController extends GetxController {
  /// 获取控制器实例
  static ImageModerationController get to {
    if (!Get.isRegistered<ImageModerationController>()) {
      Get.put(ImageModerationController());
    }
    return Get.find<ImageModerationController>();
  }

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  /// 状态对象
  final state = ImageModerationState();

  /// 初始化
  @override
  void onInit() {
    super.onInit();

    // 获取统计数据
    fetchStatistics();

    // 正常加载数据
    fetchImages();

    // 用户审核列表
    onRefresh();
  }

  /// 获取统计数据
  void fetchStatistics() async {
    try {
      final response = await ImageUtil.userReviewInfo(config: RequestConfig(requireToken: true));
      state.reviewerStatsEntity = response.data;
      update([ImageModerationState.statisticsId]);
    } catch (e) {
      print("获取统计数据异常e: $e");
    }
  }

  // 知识点列表
  void fetchImages() async {
    if (state.isLoading) return;

    state.isLoading = true;
    // 设置数据来源为非搜索
    state.isFromSearch = false;

    try {
      final response = await ImageUtil.fetchImages(
          config: RequestConfig(
        requireToken: true,
      ));
      // 设置知识点列表
      state.knowledgePoints = response.data?.list ?? [];
    } catch (e) {
      print("图片审核列表异常e: $e");
    }

    state.isLoading = false;
    update([ImageModerationState.knowledgeListId]);
  }

  // 搜索知识点列表
  void searchImages() async {
    if (state.isLoading) return;

    state.isLoading = true;
    // 设置数据来源为搜索
    state.isFromSearch = true;

    try {
      final response = await ImageUtil.serach(
          config: RequestConfig(
        requireToken: true,
        data: state.searchTerm,
      ));
      // 设置知识点列表
      state.knowledgePoints = response.data?.list ?? [];
    } catch (e) {
      print("搜索知识点列表异常e: $e");
    } finally {
      state.isLoading = false;
      update([ImageModerationState.knowledgeListId]);
    }

    if (state.knowledgePoints.isEmpty || state.searchTerm.isEmpty) {
      // 如果为空,拉取列表数据
      fetchImages();
    }
  }

  /// 查看更多
  void toMore() {
    Get.toNamed(Routes.IMAGE_MODERATION_LIST)?.then(_handleDetailPageReturn);
  }

  /// 知识点详情
  ///
  /// 跳转到知识点详情页面进行图片审核
  /// [knowledgePoint] 需要审核的知识点
  /// [isFromUser] 是否来自用户审核列表，如果是则跳过审核状态检查
  void toKnowledgePointDetail(KnowledgePoint knowledgePoint, {bool isFromUser = false}) {
    // 审核中的知识点只有自己创建的才可以访问
    if (!isFromUser &&
        !knowledgePoint.reviewStatus.isPending &&
        !(knowledgePoint.oneself != null && knowledgePoint.oneself!)) {
      ToastUtils.showToast(text: "其他用户正在审核中");
      return;
    }

    // 跳转到详情页
    Get.toNamed(Routes.IMAGE_MODERATION_DETAIL, arguments: {
      "contentType": knowledgePoint.contentType,
      "content": knowledgePoint.content,
      "imageModerationType": 0,
    })?.then(_handleDetailPageReturn);
  }

  /// 处理详情页返回的回调
  /// 根据数据来源决定刷新方式
  void _handleDetailPageReturn(dynamic value) {
    // 根据数据来源决定刷新方式
    if (state.isFromSearch) {
      // 如果数据来自搜索且搜索关键词不为空，则调用搜索方法刷新
      searchImages();
    } else {
      // 否则调用正常加载数据方法
      fetchImages();
    }

    // 用户审核列表始终需要刷新
    onRefresh();

    // 刷新统计数据
    fetchStatistics();
  }

  // 获取用户审核列表
  void onRefresh() async {
    try {
      state.offset = 0;
      final response = await ImageUtil.userReviewImages(
          config: RequestConfig(
              parameters: {"offset": state.offset, "limit": state.limit, "order": "-order"},
              data: state.statusFilter.label,
              requireToken: true));
      state.myReviews = response.data?.datas ?? [];
      refreshController.finishRefresh();
    } catch (e) {
      print("图片审核列表异常e: $e");
      refreshController.finishRefresh(IndicatorResult.fail);
    } finally {
      update([ImageModerationState.myReviewsId]);
    }
  }

  /// 加载更多数据
  void onLoadMore() async {
    try {
      state.offset = state.offset + state.limit;

      final response = await ImageUtil.userReviewImages(
          config: RequestConfig(
              parameters: {"offset": state.offset, "limit": state.limit, "order": "-order"},
              data: state.statusFilter.label,
              requireToken: true));
      state.myReviews.addAll(response.data?.datas ?? []);
      if ((response.data?.count ?? 0) > state.myReviews.length) {
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
      update([ImageModerationState.myReviewsId]);
    }
  }

  /// 设置状态筛选
  void setStatusFilter(ReviewStatus status) {
    if (state.statusFilter == status) return;

    state.statusFilter = status;
    onRefresh();
    update([ImageModerationState.knowledgeListId]);
  }

  /// 设置搜索关键词
  void setSearchTerm(String term, {bool isSubmit = false}) {
    state.searchTerm = term;
    if (isSubmit) {
      searchImages();
    }
  }

  /// 显示排行榜弹框
  void toShowRankingDialog(BuildContext context) {
    // 显示排行榜弹框
    RankingDialog.show(
      context: context,
      title: '审核排行榜',
    );
  }

  // 管理
  void toAdmin() {
    Get.toNamed(Routes.IMAGE_MODERATION_ADMIN)?.then((value) {
      _handleDetailPageReturn(value);
    });
  }
}
