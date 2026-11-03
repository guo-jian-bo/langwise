/// 图片审核详情控制器
///
/// 功能描述：支持对知识点关联的图片进行审核、评分和多维度筛选
///
/// 开始审核按钮逻辑：
/// 当点击开始审核按钮时，自动查找并选中下一个未审核的图片，并显示审核对话框
/// 1. 从当前选中的词性和释义开始查找第一个未审核的图片
/// 2. 如果当前释义下没有未审核图片，则查找当前词性下的下一个释义
/// 3. 如果当前词性下所有释义都已审核完成，则跳过这个词性，查找下一个词性
/// 4. 跳过所有已经完全审核过的释义，只关注有未审核图片的释义
/// 5. 如果所有词性的所有释义都已审核完成，则显示提示信息
///
/// 审核顺序逻辑（由控制器实现）：
///    - 当前释义内图片审核：从选中图片开始，按索引顺序向后审核未审核图片
///    - 释义间切换逻辑：当前释义审核完成后，自动切换到下一个有未审核图片的释义
///    - 跳过所有图片已审核完成的释义，只关注有未审核图片的释义
///    - 词性间切换逻辑：当前词性下选中的释义及以后的释义的未审核图片都审核完成后，自动切换到下一个词性
///    - 全局循环检查：最后一个词性下的未审核释义的图片审核成功后，会从词性数组开始重新检索是否还有未审核的词性、释义、图片，有则继续执行审核逻辑
///
/// 主要职责：
/// 1. 数据管理：加载并维护知识点、词性、释义和图片数据
/// 2. 审核逻辑：实现图片审核、评分和自动切换到下一张图片
/// 3. 交互流程：处理图片导航、UI状态更新和完成提示
/// 4. 与ImageReviewDialog协作：提供审核上下文并处理审核结果
///
/// 主要方法：
/// - startReview(): 开始审核按钮逻辑，自动查找未审核图片
/// - reviewImage(): 对图片进行评分并返回下一个审核项
/// - findNextReviewItem(): 查找下一个需要审核的项目
/// - selectPos()/selectGloss(): 选择词性和释义
///
/// 状态管理：使用 ImageModerationDetailState 和 GetX 响应式编程

import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'state.dart';

/// 下一个审核项元组类
class NextReviewItem {
  /// 下一个词性
  final PosGroup? pos;

  /// 下一个释义
  final GlossItem? gloss;

  /// 下一个图片
  final ImageItem? image;

  /// 是否所有图片都已审核完成
  final bool isAllReviewed;

  const NextReviewItem({
    this.pos,
    this.gloss,
    this.image,
    this.isAllReviewed = false,
  });
}

class ImageModerationDetailController extends GetxController {
  /// 单例访问器
  static ImageModerationDetailController get to => Get.find<ImageModerationDetailController>();

  /// 状态对象
  final ImageModerationDetailState state = ImageModerationDetailState();

  String? _contentType, _content;

  int? _userId;

  ImageModerationType imageModerationType = ImageModerationType.normal;

  // 正在提交审核
  bool _isSubmitting = false;

  /// 是否是单个用户
  bool get _isUser => imageModerationType == ImageModerationType.normal;

  @override
  void onInit() {
    super.onInit();
    _contentType = Get.arguments?["contentType"];
    _content = Get.arguments?["content"];
    _userId = Get.arguments?["userId"];
    if (Get.arguments?["imageModerationType"] == null || Get.arguments?["imageModerationType"] == 0) {
      imageModerationType = ImageModerationType.normal;
    } else {
      imageModerationType = ImageModerationType.review;
    }
    print("$runtimeType, ${Get.arguments}");
    fetchReviewImageDetail();
    fetchStyles();
  }

  // 获取数据
  void fetchReviewImageDetail() {
    if (imageModerationType == ImageModerationType.normal) {
      fetchUserReviewImageDetail();
    } else {
      fetchAdminReviewImageDetail();
    }
  }

  // 获取用户端图片审核详情
  void fetchUserReviewImageDetail() async {
    if (ObjectUtil.isEmpty(_content) || ObjectUtil.isEmpty(_contentType)) {
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await ImageUtil.detail(
          config: RequestConfig(data: {
        "contentType": _contentType,
        "content": _content,
      }, requireToken: true));
      state.selectedKnowledgePoint = response.data;
      _updateFilterCounts();

      // 默认选中第一个词性
      if (state.hasContentPosList) {
        selectPos(state.contentPosList[0]);
      }

      // 默认选中“所有风格”和“所有地区”
      if (state.getStyleOptions().isNotEmpty) {
        selectStyle(0, state.getStyleOptions()[0]);
      }

      if (state.getLocaleOptions().isNotEmpty) {
        selectLocale(0, state.getLocaleOptions()[0]);
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "审核详情失败");
    } catch (e) {
      print("图片审核详情异常e: $e");
      ToastUtils.showToast(text: "审核详情失败");
    } finally {
      ToastUtils.hideLoading();
      _initData();
    }
  }

  // 获取管理端图片审核详情
  void fetchAdminReviewImageDetail() async {
    if (ObjectUtil.isEmpty(_content) || ObjectUtil.isEmpty(_contentType)) {
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await AdminUtil.detail(
          config: RequestConfig(data: {
        "contentType": _contentType,
        "content": _content,
      }, requireToken: true));
      state.selectedKnowledgePoint = response.data;
      _updateFilterCounts();

      // 默认选中第一个词性
      if (state.hasContentPosList) {
        selectPos(state.contentPosList[0]);
      }

      // 默认选中“所有风格”和“所有地区”
      if (state.getStyleOptions().isNotEmpty) {
        selectStyle(0, state.getStyleOptions()[0]);
      }

      if (state.getLocaleOptions().isNotEmpty) {
        selectLocale(0, state.getLocaleOptions()[0]);
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "审核详情失败");
    } catch (e) {
      print("图片审核详情异常e: $e");
      ToastUtils.showToast(text: "审核详情失败");
    } finally {
      ToastUtils.hideLoading();
      _initData();
    }
  }

  /// 图片风格/地区
  void fetchStyles() async {
    try {
      final response = await ImageUtil.styles(config: RequestConfig(requireToken: true));
      state.styles = response.data?.list ?? [];
    } catch (e) {
      print("图片风格异常e: $e");
    } finally {
      _initData();
    }
  }

  /// 更新筛选项的数量
  void _updateFilterCounts() {
    if (!state.hasSelectedKnowledgePoint) return;

    final allImages = state.selectedKnowledgePoint!.getAllImages();
    // 使用needsReview属性判断是否需要审核
    final unreviewed = allImages.where((img) => img.needsReview).toList();
    // 已审核的图片应该是不需要审核的图片
    final reviewed = allImages.where((img) => !img.needsReview).toList();

    // 更新筛选器计数
    state.filterItems[0]['count'] = allImages.length;
    state.filterItems[1]['count'] = unreviewed.length;
    state.filterItems[2]['count'] = reviewed.length;

    // 强制更新UI
    update(['filter_section']);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(["image_moderation_detail"]);
  }

  /// 检查是否有选中的图片
  bool hasSelectedImages() {
    if (!state.hasContentPosList) return false;
    for (final posGroup in state.contentPosList) {
      for (final gloss in posGroup.semanticList) {
        for (final image in gloss.images) {
          if (image.isSelected) {
            return true; // 找到选中的图片，立即返回true
          }
        }
      }
    }

    return false; // 没有找到选中的图片
  }

  /// 选择筛选项
  /// @param index 0-全部图片，1-未审核，2-已审核
  void selectFilter(int index) {
    if (state.selectedFilterIndex == index) return;
    state.selectedFilterIndex = index;

    // 根据筛选项设置当前筛选状态
    switch (index) {
      case 0: // 全部图片
        state.filterStatus = null;
        break;
      case 1: // 未审核
        state.filterStatus = 0; // imageScore == 0 或 null
        break;
      case 2: // 已审核
        state.filterStatus = 1; // imageScore > 0
        break;
    }

    // 更新UI
    _initData();
  }

  /// 选择图片
  void selectImage(ImageItem image) {
    state.selectedImage = image;
    _initData();
  }

  /// 显示图片审核对话框
  void onShowImageReviewDialog(BuildContext context, ImageItem image) {
    // 选中图片
    selectImage(image);

    final gloss = state.getCurrentGloss();

    ImageReviewDialog.show(
      context: context,
      image: image,
      selectedKnowledgePoint: state.selectedKnowledgePoint,
      selectedPos: state.selectedPos,
      selectedGloss: gloss,
      isUser: _isUser,
      onClose: closeDetails,
      onReview: reviewImage,
    );
  }

  /// 关闭详情面板
  void closeDetails() {
    state.selectedImage = null;
    _initData();
  }

  /// 设置状态筛选
  void setStatusFilter(ReviewStatus status) {
    if (state.statusFilter == status) return;

    state.statusFilter = status;
    _initData();
  }

  /// 选择词性
  void selectPos(PosGroup pos) {
    if (state.selectedPos == pos) return;
    state.selectedPos = pos;

    // 选择该词性下的第一个释义
    final glosses = state.getCurrentGlosses();
    if (glosses.isNotEmpty) {
      state.selectedGloss = glosses[0];
    } else {
      state.selectedGloss = null;
    }

    _initData();
  }

  /// 选择释义
  void selectGloss(GlossItem gloss) {
    state.selectedGloss = gloss;
    _initData();
  }

  /// 审核图片
  /// 对图片进行评分并处理审核结果
  /// @param image 当前审核的图片
  /// @param stars 评分星级
  /// @param pos 当前选中的词性
  /// @param gloss 当前选中的释义
  /// @return 返回下一个需要审核的项目（词性、释义、图片）
  NextReviewItem reviewImage(ImageItem image, int stars, PosGroup? pos, GlossItem? gloss) {
    if (!state.hasSelectedKnowledgePoint) {
      return const NextReviewItem(isAllReviewed: true);
    }

    // 查找并更新图片
    final allImages = state.getAllImages();
    final imageIndex = allImages.indexWhere((element) => element == image);

    if (imageIndex == -1) {
      return NextReviewItem(pos: pos, gloss: gloss, image: image);
    }

    // 更新图片状态
    final updatedImage = allImages[imageIndex].copyWith(
      imageScore: stars,
    );

    // 更新图片列表
    updateImageInKnowledgePoint(updatedImage);

    // 更新筛选器计数
    _updateFilterCounts();

    // 刷新状态
    _initData();

    // 查找下一个需要审核的图片
    return findNextReviewItem(image, pos, gloss);
  }

  /// 查找下一个需要审核的项目
  /// @param currentImage 当前图片
  /// @param currentPos 当前词性
  /// @param currentGloss 当前释义
  /// @return 返回下一个需要审核的项目
  NextReviewItem findNextReviewItem(ImageItem currentImage, PosGroup? currentPos, GlossItem? currentGloss) {
    // 如果没有选中知识点，返回审核完成
    if (!state.hasSelectedKnowledgePoint) {
      return const NextReviewItem(isAllReviewed: true);
    }

    final allPosList = state.contentPosList;

    // 1. 当前释义内图片审核：从选中图片开始，按索引顺序向后审核未审核图片
    if (currentGloss != null) {
      // 获取当前释义中的所有图片，保持原始顺序
      final glossImages = currentGloss.images;

      // 找到当前图片在释义图片列表中的索引
      final currentImageIndex = glossImages.indexWhere((img) => img == currentImage);

      if (currentImageIndex != -1) {
        // 从当前图片的下一个索引开始向后查找未审核的图片
        for (int i = currentImageIndex + 1; i < glossImages.length; i++) {
          final nextImage = glossImages[i];
          if (nextImage.needsReview) {
            return NextReviewItem(
              pos: currentPos,
              gloss: currentGloss,
              image: nextImage,
            );
          }
        }
      }

      // 如果当前图片后面没有未审核的图片，应该进入下一个释义的审核，不应该再从头开始查找当前图片之前的未审核图片
    }

    // 2. 释义间切换逻辑：当前释义审核完成后，自动切换到下一个有未审核图片的释义
    if (currentPos != null) {
      final currentPosGlosses = state.getCurrentGlosses();
      int startGlossIndex = 0;

      if (currentGloss != null) {
        startGlossIndex = currentPosGlosses.indexWhere((g) => g == currentGloss);
        if (startGlossIndex >= 0) startGlossIndex++; // 从下一个释义开始
      }

      // 3. 跳过所有图片已审核完成的释义，只关注有未审核图片的释义
      for (int i = startGlossIndex; i < currentPosGlosses.length; i++) {
        final nextGloss = currentPosGlosses[i];
        final nextGlossImages = nextGloss.images.where((img) => img.needsReview).toList();

        if (nextGlossImages.isNotEmpty) {
          // 更新选中释义
          selectGloss(nextGloss);
          return NextReviewItem(
            pos: currentPos,
            gloss: nextGloss,
            image: nextGlossImages.first,
          );
        }
      }
    }

    // 4. 词性间切换逻辑：当前词性下选中的释义及以后的释义的未审核图片都审核完成后，自动切换到下一个词性
    int startPosIndex = 0;
    if (currentPos != null) {
      startPosIndex = allPosList.indexWhere((p) => p == currentPos);
      if (startPosIndex >= 0) startPosIndex++; // 从下一个词性开始
    }

    // 从当前词性之后查找
    NextReviewItem? nextItem = findNextItemInPosList(allPosList, startPosIndex, allPosList.length);
    if (nextItem != null) {
      // 更新选中词性和释义
      if (nextItem.pos != null) {
        selectPos(nextItem.pos!);
      }
      if (nextItem.gloss != null) {
        selectGloss(nextItem.gloss!);
      }
      return nextItem;
    }

    // 5. 全局循环检查：最后一个词性下的未审核释义的图片审核成功后，会从词性数组开始重新检索
    // 如果已经到达最后一个词性，从头开始重新检查是否还有未审核的词性、释义、图片
    if (startPosIndex > 0) {
      // 如果不是从头开始的，则从头开始重新检查
      nextItem = findNextItemInPosList(allPosList, 0, startPosIndex);
      if (nextItem != null) {
        // 更新选中词性和释义
        if (nextItem.pos != null) {
          selectPos(nextItem.pos!);
        }
        if (nextItem.gloss != null) {
          selectGloss(nextItem.gloss!);
        }
        return nextItem;
      }
    }

    // 所有图片已审核完成
    return const NextReviewItem(isAllReviewed: true);
  }

  /// 在指定范围的词性列表中查找下一个需要审核的项目
  /// @param posList 词性列表
  /// @param startIndex 开始索引
  /// @param endIndex 结束索引
  /// @return 返回下一个需要审核的项目，如果没有则返回 null
  NextReviewItem? findNextItemInPosList(List<PosGroup> posList, int startIndex, int endIndex) {
    for (int i = startIndex; i < endIndex && i < posList.length; i++) {
      final nextPos = posList[i];

      for (final nextGloss in nextPos.semanticList) {
        final nextGlossImages = nextGloss.images.where((img) => img.needsReview).toList();

        if (nextGlossImages.isNotEmpty) {
          return NextReviewItem(
            pos: nextPos,
            gloss: nextGloss,
            image: nextGlossImages.first,
          );
        }
      }
    }

    return null;
  }

  /// 更新知识点中的图片
  void updateImageInKnowledgePoint(ImageItem updatedImage) {
    if (!state.hasContentPosList) {
      return;
    }

    // 遍历所有词性组和释义，查找并更新图片
    for (final posGroup in state.contentPosList) {
      for (final gloss in posGroup.semanticList) {
        final imageIndex = gloss.images.indexWhere((element) => element == updatedImage);
        if (imageIndex != -1) {
          // 更新图片
          gloss.images[imageIndex] = updatedImage;
          return;
        }
      }
    }
  }

  /// 选择风格
  void selectStyle(int index, ImageFilterOption style) {
    state.selectedStyle = style;
    _initData();
  }

  /// 选择地区
  void selectLocale(int index, ImageFilterOption locale) {
    state.selectedLocale = locale;
    _initData();
  }

  /// 开始审核按钮逻辑实现
  /// 详见文件头部的完整说明
  void startReview(BuildContext context) {
    // 首先检查是否有选中的知识点
    if (!state.hasSelectedKnowledgePoint) {
      ToastUtils.showToast(text: "暂无可审核图片");
      return;
    }

    // 获取当前选中的词性和释义
    final currentPos = state.selectedPos;
    final currentGloss = state.selectedGloss;

    // 如果没有选中的词性或释义，则选中第一个
    if (currentPos == null && state.hasContentPosList) {
      selectPos(state.contentPosList[0]);
    }

    // 查找下一个需要审核的项目
    NextReviewItem nextItem;

    if (currentGloss != null) {
      // 从当前释义中查找未审核的图片
      final unreviewed = currentGloss.images.where((img) => img.needsReview).toList();

      if (unreviewed.isNotEmpty) {
        // 如果当前释义中有未审核的图片，直接显示审核对话框
        onShowImageReviewDialog(context, unreviewed.first);
        return;
      }
    }

    // 如果当前释义中没有未审核的图片，或者没有选中释义
    // 查找下一个需要审核的项目
    // 创建一个虚拟图片作为当前图片，因为我们只关心词性和释义的切换
    final dummyImage = ImageItem(imageId: -1);
    nextItem = findNextReviewItem(dummyImage, state.selectedPos, state.selectedGloss);

    if (nextItem.isAllReviewed) {
      // 所有图片都已审核完成
      ToastUtils.showToast(text: "所有图片已审核完成");
      return;
    }

    // 更新选中状态
    if (nextItem.pos != null && nextItem.pos != state.selectedPos) {
      selectPos(nextItem.pos!);
    }

    if (nextItem.gloss != null && nextItem.gloss != state.selectedGloss) {
      selectGloss(nextItem.gloss!);
    }

    // 显示审核对话框
    if (nextItem.image != null) {
      onShowImageReviewDialog(context, nextItem.image!);
    }
  }

  /// 进入批量审核模式
  void enterBatchMode() {
    // 首先检查是否有选中的知识点
    if (!state.hasSelectedKnowledgePoint) {
      ToastUtils.showToast(text: "暂无可审核图片");
      return;
    }

    state.isBatchMode = true;
    // 重置所有图片的选中状态
    resetAllImageSelections();
    update(["image_moderation_detail"]);
  }

  /// 退出批量审核模式
  void exitBatchMode() {
    // 首先检查是否有选中的知识点
    if (!state.hasSelectedKnowledgePoint) {
      ToastUtils.showToast(text: "暂无可审核图片");
      return;
    }
    state.isBatchMode = false;
    // 重置所有图片的选中状态
    resetAllImageSelections();
    update(["image_moderation_detail"]);
  }

  /// 重置所有图片的选中状态
  void resetAllImageSelections() {
    if (!state.hasContentPosList) {
      if (kDebugMode) {
        print('⚠️[ImageModerationDetailController]【resetAllImageSelections】内容词性列表为空');
      }
      return;
    }

    for (final posGroup in state.contentPosList) {
      for (final gloss in posGroup.semanticList) {
        for (int i = 0; i < gloss.images.length; i++) {
          final image = gloss.images[i];
          if (image.isSelected) {
            // 创建未选中状态的图片副本
            gloss.images[i] = image.copyWith(isSelected: false);
          }
        }
      }
    }

    _initData();
  }

  /// 切换图片选中状态
  void toggleImageSelection(ImageItem selectedImage) {
    // 非批量模式下不处理
    if (!state.isBatchMode) return;

    try {
      // 更新选中状态
      final ImageItem updatedImage = selectedImage.copyWith(isSelected: !selectedImage.isSelected);
      // 更新图片列表
      updateImageInKnowledgePoint(updatedImage);

      if (kDebugMode) {
        print(
            '🔄[$runtimeType]【toggleImageSelection】切换图片选中状态: ${selectedImage.imageId}, isSelected: ${updatedImage.isSelected}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🐞[$runtimeType]【toggleImageSelection】异常: $e');
      }
    } finally {
      _initData();
    }
  }

  /// 批量评分图片
  /// @param stars 评分星级（1-5）
  void batchRateImages(int stars) {
    // 检查是否处于批量模式
    if (!state.isBatchMode) {
      if (kDebugMode) {
        print('⚠️[$runtimeType]【batchRateImages】非批量模式，无法进行批量评分');
      }
      return;
    }

    // 如果正在提交，则不处理
    if (_isSubmitting) {
      if (kDebugMode) {
        print('⚠️[$runtimeType]【batchRateImages】正在提交中，请稍候');
      }
      return;
    }

    if (!state.hasContentPosList) {
      ToastUtils.showToast(text: "暂无评分的图片");
      return;
    }

    // 获取所有选中的图片
    List<ImageItem> selectedImages = [];

    for (final posGroup in state.contentPosList) {
      for (final gloss in posGroup.semanticList) {
        for (final image in gloss.images) {
          if (image.isSelected) {
            selectedImages.add(image);
          }
        }
      }
    }

    // 检查是否有选中的图片
    if (selectedImages.isEmpty) {
      ToastUtils.showToast(text: "请先选择需要评分的图片");
      return;
    }

    // 设置提交状态
    _isSubmitting = true;

    // 收集所有选中图片的ID
    List<String> imageIds = selectedImages.map((image) => image.imageId.toString()).toList();

    if (imageModerationType == ImageModerationType.normal) {
      onUserReview(imageIds: imageIds, imageScore: stars);
    } else {
      onAdminReview(imageIds: imageIds, imageScore: stars);
    }
  }

  /// 用户审核
  void onUserReview({required List imageIds, required int imageScore}) async {
    try {
      ToastUtils.showLoading();
      // 调用API提交评分
      final response = await ImageUtil.review(
          config: RequestConfig(data: {
        "content": state.selectedKnowledgePoint?.content,
        "contentType": state.selectedKnowledgePoint?.contentType,
        "imageIds": imageIds,
        "imageScore": imageScore,
      }, requireToken: true));

      if (ObjectUtil.isNotEmpty(response.data)) {
        // 批量评分成功后的处理
        for (final posGroup in state.contentPosList) {
          for (final gloss in posGroup.semanticList) {
            for (var i = 0; i < gloss.images.length; i++) {
              final image = gloss.images[i];
              if (image.isSelected) {
                // 更新图片状态：设置评分、取消选中
                gloss.images[i] = image.copyWith(
                  imageScore: imageScore,
                  isSelected: false,
                );
              }
            }
          }
        }

        // 更新筛选器计数
        _updateFilterCounts();

        // 显示评分结果提示
        ToastUtils.showToast(text: "审核成功");
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "审核失败");
    } catch (e) {
      ToastUtils.showToast(text: "审核失败");
    } finally {
      // 刷新UI，但不退出批量模式
      _initData();
      // 无论成功还是失败，最终都要重置提交状态
      _isSubmitting = false;
      ToastUtils.hideLoading();
    }
  }

  /// 管理审核
  void onAdminReview({required List imageIds, required int imageScore}) async {
    try {
      ToastUtils.showLoading();
      // 调用API提交评分
      final response = await AdminUtil.review(
          config: RequestConfig(data: {
        "content": state.selectedKnowledgePoint?.content,
        "contentType": state.selectedKnowledgePoint?.contentType,
        "imageIds": imageIds,
        "imageScore": imageScore,
        "userId": _userId,
      }, requireToken: true));
      if (ObjectUtil.isNotEmpty(response.data)) {
        // 批量评分成功后的处理
        for (final posGroup in state.contentPosList) {
          for (final gloss in posGroup.semanticList) {
            for (var i = 0; i < gloss.images.length; i++) {
              final image = gloss.images[i];
              if (image.isSelected) {
                // 更新图片状态：设置评分、取消选中
                gloss.images[i] = image.copyWith(
                  imageScore: imageScore,
                  isSelected: false,
                );
              }
            }
          }
        }

        // 更新筛选器计数
        _updateFilterCounts();

        // 显示评分结果提示
        ToastUtils.showToast(text: "审核成功", type: ToastType.success);
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "审核失败");
    } catch (e) {
      ToastUtils.showToast(text: "审核失败");
    } finally {
      // 刷新UI，但不退出批量模式
      _initData();
      // 无论成功还是失败，最终都要重置提交状态
      _isSubmitting = false;
      ToastUtils.hideLoading();
    }
  }

  /// 显示放弃审核确认弹框
  void showAbandonReviewDialog() {
    // 首先检查是否有选中的知识点
    if (!state.hasSelectedKnowledgePoint) {
      ToastUtils.showToast(text: "暂无可放弃审核图片");
      return;
    }

    AbandonReviewDialog.show(
      onConfirm: () {
        // 执行放弃审核操作
        onAbandonReview();
      },
    );
  }

  /// 放弃审核
  void onAbandonReview() async {
    // 如果没有内容，直接返回
    if (!state.hasContentPosList) {
      return;
    }

    try {
      ToastUtils.showLoading();
      // 调用API提交评分
      final response = await ImageUtil.abandonReview(
          config: RequestConfig(data: {
        "content": state.selectedKnowledgePoint?.content,
        "contentType": state.selectedKnowledgePoint?.contentType,
      }, requireToken: true));
      if (ObjectUtil.isNotEmpty(response.data)) {
        ToastUtils.showToast(text: "已经放弃审核", type: ToastType.success);
        Get.back();
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "放弃审核失败");
    } catch (e) {
      ToastUtils.showToast(text: "放弃审核失败");
    } finally {
      // 刷新UI，但不退出批量模式
      _initData();
      // 无论成功还是失败，最终都要重置提交状态
      _isSubmitting = false;
      ToastUtils.hideLoading();
    }
  }

  /// 资源释放
  @override
  void onClose() {
    super.onClose();
    // 清理资源
    state.clear();
  }
}
