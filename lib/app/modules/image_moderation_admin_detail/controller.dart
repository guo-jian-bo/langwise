/// 审核员详情页控制器
///
/// 功能描述：展示审核员详细信息和其审核的知识点列表
///
/// 主要职责：
/// 1. 数据管理：加载并维护审核员信息和知识点数据
/// 2. 搜索功能：根据关键词搜索知识点
/// 3. 排序功能：按审核日期或图片数量排序
/// 4. 筛选功能：按状态筛选知识点
///
/// 主要方法：
/// - fetchReviewerAndPoints(): 加载审核员信息和知识点数据
/// - setSearchTerm(): 设置搜索关键词
/// - setSort(): 设置排序字段和方向
/// - setStatusFilter(): 设置状态筛选
///
/// 状态管理：使用 ImageModerationAdminDetailState 和 GetX 响应式编程

import 'package:api/entities/entities.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

import 'state.dart';

class ImageModerationAdminDetailController extends GetxController {
  static ImageModerationAdminDetailController get to => Get.find<ImageModerationAdminDetailController>();

  /// 状态对象
  final ImageModerationAdminDetailState state = ImageModerationAdminDetailState();

  /// 刷新控制器
  final EasyRefreshController refreshController =
      EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

  int? _inspectorId;

  /// 是否是单个用户
  bool get isUser => _inspectorId != null;

  @override
  void onInit() {
    super.onInit();
    _inspectorId = Get.arguments?["inspectorId"];
    _setupScrollListener();
    fetchStatistics();
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

  /// 获取统计数据
  void fetchStatistics() async {
    try {
      ToastUtils.showLoading();
      final response = await AdminUtil.userReviewInfo(
          config: RequestConfig(
              parameters: _inspectorId != null ? {"inspectorId": _inspectorId} : null, requireToken: true));
      state.reviewer = response.data;
    } on FormatException catch (e) {
      print("获取统计数据异常e: $e");
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
      update(['image_moderation_admin_nickname', 'image_moderation_admin_detail']);
    }
  }

  /// 加载知识点数据（下拉刷新）
  Future<void> onRefresh() async {
    try {
      state.offset = 0;

      final Map<String, dynamic> parameters = {
        "offset": state.offset,
        "limit": state.limit,
      };

      // 构建order参数，根据排序字段和方向
      String? order;
      if (state.sortField.isNotEmpty) {
        if (state.sortField == 'reviewDate') {
          // reviewDate映射到updated字段
          order = state.sortDirection == 'desc' ? '-submitDate' : 'submitDate';
        } else if (state.sortField == 'imageCount') {
          order = state.sortDirection == 'desc' ? '-imageCount' : 'imageCount';
        }
      }

      // 默认排序
      order ??= '-submitDate';

      // 添加排序参数
      parameters['order'] = order;

      final Map<String, dynamic> body = {};

      if (_inspectorId != null) {
        body['userId'] = _inspectorId;
      }

      if (state.searchTerm.isNotEmpty) {
        body['content'] = state.searchTerm;
      }

      if (state.statusFilter != null) {
        body['status'] = state.statusFilter!.label;
      }

      final response =
          await AdminUtil.simplePoints(config: RequestConfig(parameters: parameters, data: body, requireToken: true));
      state.knowledgePoints = response.data?.datas ?? [];
      state.totalCount = response.data?.count ?? 0;
      refreshController.finishRefresh();
    } on FormatException catch (e) {
      if (kDebugMode) {
        print("获取知识点数据异常e: $e");
      }
      refreshController.finishRefresh(IndicatorResult.fail);
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      refreshController.finishRefresh(IndicatorResult.fail);
      ToastUtils.showToast(text: e.toString());
    } finally {
      update(['knowledge_points_list']);
    }
  }

  /// 加载更多知识点数据（上拉加载）
  Future<void> onLoadMore() async {
    try {
      state.offset = state.offset + state.limit;
      final Map<String, dynamic> parameters = {
        "offset": state.offset,
        "limit": state.limit,
      };

      // 构建order参数，根据排序字段和方向
      String? order;
      if (state.sortField.isNotEmpty) {
        if (state.sortField == 'reviewDate') {
          // reviewDate映射到submitDate字段
          order = state.sortDirection == 'desc' ? '-submitDate' : 'submitDate';
        } else if (state.sortField == 'imageCount') {
          order = state.sortDirection == 'desc' ? '-imageCount' : 'imageCount';
        }
      }

      // 默认排序
      order ??= '-submitDate';

      // 添加排序参数
      parameters['order'] = order;

      if (state.searchTerm.isNotEmpty) {
        parameters['content'] = state.searchTerm;
      }

      final Map<String, dynamic> body = {};

      if (_inspectorId != null) {
        body['userId'] = _inspectorId;
      }

      if (state.searchTerm.isNotEmpty) {
        body['content'] = state.searchTerm;
      }

      if (state.statusFilter != null) {
        body['status'] = state.statusFilter!.label;
      }

      final response =
          await AdminUtil.simplePoints(config: RequestConfig(parameters: parameters, data: body, requireToken: true));
      final newPoints = response.data?.datas ?? [];
      // 添加新数据
      state.knowledgePoints.addAll(newPoints);
      state.totalCount = response.data?.count ?? 0;

      if (state.hasMoreData) {
        // 标识加载更多完成
        refreshController.finishLoad();
      } else {
        // 标识没有更多数据
        refreshController.finishLoad(IndicatorResult.noMore);
      }
    } on FormatException catch (e) {
      if (kDebugMode) {
        print("加载更多知识点数据异常e: $e");
      }
      refreshController.finishLoad(IndicatorResult.fail);
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      refreshController.finishLoad(IndicatorResult.fail);
      ToastUtils.showToast(text: e.toString());
    } finally {
      update(['knowledge_points_list']);
    }
  }

  /// 设置搜索关键词
  void setSearchTerm(String term) {
    state.searchTerm = term;
    onRefresh();
  }

  /// 设置排序字段和方向
  void setSort(String field) {
    if (state.sortField == field) {
      state.sortDirection = state.sortDirection == 'asc' ? 'desc' : 'asc';
    } else {
      state.sortField = field;
      state.sortDirection = 'desc';
    }

    // 更新排序按钮组件
    update(['sort_buttons']);
    // 直接调用onRefresh重新加载数据，让后端处理排序
    onRefresh();
  }

  /// 设置状态筛选
  void setStatusFilter(ReviewStatus? status) {
    state.statusFilter = status;
    // 更新状态筛选组件
    update(['status_filter']);
    // 直接调用onRefresh重新加载数据，让后端处理状态筛选
    onRefresh();
  }

  /// 知识点详情
  void toKnowledgePointDetail(KnowledgePoint knowledgePoint) {
    Get.toNamed(Routes.IMAGE_MODERATION_DETAIL, arguments: {
      "contentType": knowledgePoint.contentType,
      "content": knowledgePoint.content,
      "imageModerationType": 1,
      "userId": knowledgePoint.userId
    })?.then((value) {
      fetchStatistics();
      onRefresh();
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
