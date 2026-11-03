import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../utils/utils.dart';
import '../values/values.dart';

/// 单元图片详情页面组件
///
/// 修改说明：
/// - _buildImageCarousel 方法现在使用 _unitImagePromptDetail 中的 images 属性
/// - 新增 unitImages getter 用于获取图片列表
/// - 使用 UnitImageItemWidget 组件处理 ImageItem 类型的图片显示
/// - 优化了图片选择和保存逻辑
class UnitImageDetailWidget extends StatefulWidget {
  final KnowledgeAdmerationDetail? knowledgeDetail;
  final ImageItem? selectedImage;
  final bool isNewImage;
  final ImageFilterOption? selectedStyleOption;

  const UnitImageDetailWidget({
    super.key,
    this.knowledgeDetail,
    this.selectedImage,
    this.isNewImage = false,
    this.selectedStyleOption,
  });

  /// 推送到图片详情页面
  ///
  /// [context] 上下文
  /// [selectedImage] 选中的图片
  /// [knowledgeDetail] 知识详情
  /// [isNewImage] 是否为新建图片
  /// [selectedStyleOption] 选中的风格选项（新建时使用）
  static Future<bool?> push({
    required BuildContext context,
    ImageItem? selectedImage,
    KnowledgeAdmerationDetail? knowledgeDetail,
    bool isNewImage = false,
    ImageFilterOption? selectedStyleOption,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        // 设置透明背景，使页面看起来像是浮动的
        opaque: false,
        // 设置过渡动画持续时间
        transitionDuration: const Duration(milliseconds: 300),
        // 设置页面构建器
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: color_1E2939,
            child: UnitImageDetailWidget(
              knowledgeDetail: knowledgeDetail,
              selectedImage: selectedImage,
              isNewImage: isNewImage,
              selectedStyleOption: selectedStyleOption,
            ),
          );
        },
        // 设置过渡动画
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<UnitImageDetailWidget> createState() => _UnitImageDetailWidgetState();
}

class _UnitImageDetailWidgetState extends State<UnitImageDetailWidget> with SafeSetStateMixin {
  // 状态变量
  int imageCount = 4;
  bool isRegenerating = false;

  final TextEditingController promptController = TextEditingController();
  final TextEditingController imageCountController = TextEditingController();

  UnitImagePromptDetail? _unitImagePromptDetail;

  /// 从 _unitImagePromptDetail 中提取的图片列表
  final List<ImageItem> unitImages = [];

  /// 从 _unitImagePromptDetail 中提取的历史图片列表（嵌套结构，按批次组织）
  final List<List<ImageItem>> historyImages = [];

  /// 从 _unitImagePromptDetail 中提取的历史ID列表
  final List<int> historyIds = [];

  /// 选中的历史记录索引
  int? _selectedHistoryIndex;

  /// 检查是否有选中的图片
  bool get hasSelectedImages => unitImages.any((image) => image.isSelected);

  /// 获取选中的图片列表
  List<ImageItem> get selectedImages => unitImages.where((image) => image.isSelected).toList();

  /// 获取选中图片的数量
  int get selectedImagesCount => selectedImages.length;

  /// 重新生成按钮悬停状态
  bool _isRegenerateHovered = false;

  /// 保存按钮悬停状态
  bool _isSaveHovered = false;

  final FocusNode _promptFocusNode = FocusNode();

  /// 计时器工具
  TimerUtil? _timerUtil;

  // 重新生成图片
  ImageRegenerationConfig? _imageRegenerationConfig;

  @override
  void initState() {
    super.initState();
    _promptFocusNode.addListener(() {
      safeSetState(() {});
    });
    // 初始化图片数量控制器
    imageCountController.text = imageCount.toString();
    // 初始化计时器
    _initTimer();
    // 调用知识点提示词接口
    _loadKnowledgePrompt();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF111827), // bg-gray-900
        body: Column(
          children: [
            // 顶部导航栏
            _buildTopNavigationBar(),
            // 主内容区域
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildTopNavigationBar() {
    return Container(
      color: color_1E2939,
      child: BackWidget(title: "${widget.knowledgeDetail?.content ?? ''} ${widget.isNewImage ? '新建图片' : '图片详情'}"),
    );
  }

  /// 构建主内容区域
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.wMin),
      child: Column(
        children: [
          // 图片轮播区域
          _buildImageCarousel(),
          Gaps.getHeight(24.wMin),
          // 操作控件区
          _buildControlsSection(),
          Gaps.getHeight(24.wMin),
          // 文字输入区
          _buildTextInputSection(),
          Gaps.getHeight(24.wMin),
          // 生成历史记录
          _buildGenerationHistory(),
        ],
      ),
    );
  }

  /// 构建图片轮播区域
  Widget _buildImageCarousel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2939), // bg-gray-800
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      padding: EdgeInsets.all(16.wMin),
      child: SizedBox(
        height: 304.wh,
        child: unitImages.isEmpty
            ? Center(
                child: Text(
                  '暂无图片数据',
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 14.wMin,
                  ),
                ),
              )
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: unitImages.length,
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) => SizedBox(width: 16.ww),
                itemBuilder: (context, index) {
                  final image = unitImages[index];
                  return UnitImageItemWidget(
                    image: image,
                    index: index,
                    onImageSelect: handleImageSelect,
                    onImageTap: (tappedImage, tappedIndex) => _handleImagePreview(tappedImage, tappedIndex),
                  );
                },
              ),
      ),
    );
  }

  /// 构建操作控件区域
  Widget _buildControlsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2939), // bg-gray-800
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        children: [
          // 图片数量控制
          Expanded(
            child: Row(
              children: [
                Text(
                  '生成图片数量:',
                  style: TextStyle(
                      color: const Color(0xFFD1D5DC), // text-gray-300
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400),
                ),
                Gaps.getWidth(3.wMin),
                SizedBox(
                  width: 150.wMin,
                  child: Slider(
                    value: imageCount.toDouble(),
                    activeColor: const Color(0xff2388FF),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    onChanged: (value) => handleSliderCountChange(value.toInt()),
                  ),
                ),
                Gaps.getWidth(3.ww),
                SizedBox(
                  width: 100.wMin,
                  child: TextField(
                    controller: imageCountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      final count = int.tryParse(value) ?? 1;
                      print("---😆😆生成图片数量value: $value,count: $count😆😆---");
                      handleImageCountChange(count);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF364153),
                      isDense: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.wMin),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(
                          fontSize: Dimens.dn_16.wMin,
                          height: 1.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFACB4C0),
                          textBaseline: TextBaseline.alphabetic),
                    ),
                    style: TextStyle(
                      fontSize: Dimens.dn_16.wMin,
                      height: 1.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xffEBEEF3),
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    cursorColor: const Color(0xFFACB4C0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 操作按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MouseRegion(
                onEnter: (_) => safeSetState(() => _isRegenerateHovered = true),
                onExit: (_) => safeSetState(() => _isRegenerateHovered = false),
                child: GestureDetector(
                  onTap: handleRegenerateImages,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.ww,
                      vertical: 8.wh,
                    ),
                    decoration: BoxDecoration(
                      color: _isRegenerateHovered ? const Color(0xff1976D2) : const Color(0xff2388FF),
                      borderRadius: BorderRadius.circular(8.wMin),
                    ),
                    child: Text(
                      '重新生成图片',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16.wMin),
                    ),
                  ),
                ),
              ),
              Gaps.getWidth(16.wMin),
              MouseRegion(
                onEnter: (_) => safeSetState(() => _isSaveHovered = true),
                onExit: (_) => safeSetState(() => _isSaveHovered = false),
                child: GestureDetector(
                  onTap: hasSelectedImages ? handleSaveSelectedImages : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.wMin,
                      vertical: 8.wMin,
                    ),
                    decoration: BoxDecoration(
                      color: _isSaveHovered ? const Color(0xff008A33) : const Color(0xff00A63E),
                      borderRadius: BorderRadius.circular(8.wMin),
                    ),
                    child: Text(
                      '保存选中图片 ($selectedImagesCount)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16.wMin),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建文字输入区域
  Widget _buildTextInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2939), // bg-gray-800
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      padding: EdgeInsets.all(16.wMin),
      child: TextField(
        controller: promptController,
        focusNode: _promptFocusNode,
        maxLines: 5,
        style: TextStyle(
            color: Colors.white, // text-gray-400
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: '这里显示prompt：',
          hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF), // text-gray-400
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400),
          filled: true,
          fillColor: const Color(0xFF364153),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.wMin),
            borderSide: BorderSide(color: const Color(0xff2388FF), width: 1.wMin),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.wMin),
            borderSide: BorderSide.none,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.wMin),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(12.wMin),
        ),
      ),
    );
  }

  /// 构建生成历史记录区域
  /// 按批次显示历史图片，默认显示每个批次的第一张图片
  Widget _buildGenerationHistory() {
    final historyBatches = historyImages;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2939),
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '生成历史',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gaps.getHeight(12.wMin),
          SizedBox(
            height: 212.wh,
            child: historyBatches.isEmpty
                ? Center(
                    child: Text(
                      '暂无历史生成记录',
                      style: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 14.wMin,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: historyBatches.length,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) => SizedBox(width: 16.wMin),
                    itemBuilder: (context, index) {
                      final batch = historyBatches[index];
                      // 默认显示每个批次的第一张图片
                      final firstImageInBatch = batch.isNotEmpty ? batch.first : null;

                      if (firstImageInBatch == null) {
                        return const SizedBox.shrink();
                      }

                      return HistoryItemWidget(
                        historyImage: firstImageInBatch,
                        isSelected: _selectedHistoryIndex == index,
                        index: index,
                        defaultPrompt: _unitImagePromptDetail?.prompt,
                        onSelected: (index) => _onHistoryItemSelected(index),
                        batchCount: batch.length, // 传递当前批次的图片数量
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 历史记录项选中回调
  ///
  /// [index] 选中的索引
  void _onHistoryItemSelected(int index) {
    safeSetState(() {
      // 实现单选：如果点击的是当前选中项，则取消选中；否则选中新项
      if (_selectedHistoryIndex == index) {
        _selectedHistoryIndex = null;
      } else {
        _selectedHistoryIndex = index;

        // 将选中的历史批次重置到unitImages
        if (index < historyImages.length) {
          final selectedBatch = historyImages[index];

          // 清空当前unitImages
          unitImages.clear();

          // 添加选中批次的所有图片
          unitImages.addAll(selectedBatch.map((img) => img.copyWith(isSelected: false)));
        }
      }
    });
  }

  /// 加载知识点提示词数据
  ///
  /// 调用AdminUtil.knowledgePrompt()获取图片提示词详情
  void _loadKnowledgePrompt() {
    // 根据 isNewImage 决定调用不同的 API
    if (widget.isNewImage) {
      _loadNewImagePrompt();
    } else {
      _loadExistingImagePrompt();
    }
  }

  ///
  /// 加载新建图片的提示词
  /// 调用AdminUtil.loadPrompt()获取新图片的提示词
  void _loadNewImagePrompt() async {
    ToastUtils.showLoading();

    try {
      // 获取风格ID：优先使用selectedStyleOption
      final response = await AdminUtil.loadPrompt(
        config: RequestConfig(requireToken: true, data: {
          'styleId': widget.selectedStyleOption?.uid,
          'subContent': widget.knowledgeDetail?.subContent?.toJson()
        }),
      );

      if (response.data == null) {
        throw response.message ?? "未知错误";
      }

      safeSetState(() {
        // 处理 loadPrompt 返回的数据
        final promptData = response.data!;

        _unitImagePromptDetail = promptData;

        // 设置提示词到输入框
        if (promptData.prompt != null && promptData.prompt!.trim().isNotEmpty) {
          promptController.text = promptData.prompt!;
        }

        print('新建图片提示词加载成功: ${promptData.toString()}');
      });
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  ///
  /// 加载现有图片的提示词详情
  /// 调用AdminUtil.knowledgePrompt()获取现有图片的提示词和相关数据
  void _loadExistingImagePrompt() async {
    ToastUtils.showLoading();

    try {
      final imageId = widget.selectedImage?.imageId;
      // 确保knowledge对象及其必要字段有效
      if (imageId == null) {
        throw '知识点数据无效';
      }

      final response = await AdminUtil.knowledgePrompt(
        imageUid: imageId,
        config: RequestConfig(requireToken: true, data: {
          'type': widget.knowledgeDetail?.subContent?.type,
          'uid': widget.knowledgeDetail?.subContent?.uid,
          'semanticId': widget.knowledgeDetail?.subContent?.semanticId,
        }),
      );

      if (response.data == null) {
        throw response.message ?? "未知错误";
      }

      safeSetState(() {
        // 处理返回的提示词数据
        final promptDetail = response.data!;
        _unitImagePromptDetail = promptDetail;

        // 更新unitImages列表
        unitImages.addAll(_unitImagePromptDetail?.images ?? []);

        // 如果有图片数据，默认选中第一张图片
        if (unitImages.isNotEmpty) {
          // 重置所有图片的选中状态
          for (var image in unitImages) {
            image.isSelected = false;
          }
          // 选中第一张图片
          unitImages.first.isSelected = true;
        }

        // 历史图片（嵌套结构，按批次组织）
        historyImages.addAll(_unitImagePromptDetail?.historyImages ?? []);

        // 历史ID列表
        historyIds.addAll(_unitImagePromptDetail?.historyIds ?? []);

        // 设置提示词到输入框
        if (promptDetail.prompt != null && promptDetail.prompt!.trim().isNotEmpty) {
          promptController.text = promptDetail.prompt!;
        }

        print('知识点提示词加载成功: ${promptDetail.toString()}');
      });
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 处理图片选择
  ///
  /// [image] 图片对象
  void handleImageSelect(ImageItem image) {
    safeSetState(() {
      // 切换选中状态：未选中的变为选中，选中的变为未选中
      image.isSelected = !image.isSelected;
    });
  }

  /// 处理图片预览
  ///
  /// [tappedImage] 被点击的图片对象
  /// [tappedIndex] 被点击的图片索引
  void _handleImagePreview(ImageItem tappedImage, int tappedIndex) {
    ImagePreviewWidget.show(
      context: context,
      images: unitImages,
      initialIndex: tappedIndex,
    );
  }

  /// 处理图片数量变更
  void handleSliderCountChange(int count) {
    safeSetState(() {
      imageCount = count.clamp(1, 8);
      imageCountController.text = imageCount.toString();
    });
  }

  void handleImageCountChange(int count) {
    safeSetState(() {
      imageCount = count.clamp(1, 8);
    });
    if (count > 8) {
      imageCountController.text = imageCount.toString();
    }
  }

  /// 处理重新生成图片
  ///
  /// 验证输入参数，调用API重新生成图片，并处理返回结果
  /// 成功时启动轮询定时器，失败时显示错误信息
  Future<void> handleRegenerateImages() async {
    // 验证输入参数
    if (promptController.text.trim().isEmpty) {
      ToastUtils.showManageToast(text: '请输入提示词');
      return;
    }

    if (imageCountController.text.isEmpty) {
      ToastUtils.showManageToast(text: '请输入图片生成数量');
      return;
    }

    final count = int.tryParse(imageCountController.text) ?? 0;

    if (count <= 0) {
      ToastUtils.showManageToast(text: '请输入图片生成数量');
      return;
    }

    if (isRegenerating) {
      return;
    }

    isRegenerating = true;

    _imageRegenerationConfig = null;

    try {
      ToastUtils.showLoading();

      // 根据选中图片是否有imageId来设置replace字段
      final bool hasImageId = selectedImages.isNotEmpty && selectedImages.any((image) => image.hasValidImageId);
      final response = await AdminUtil.regenerateImage(
        config: RequestConfig(
          data: {
            'imageCount': imageCount,
            'imageId': widget.selectedImage?.imageId,
            'styleId': _unitImagePromptDetail?.styleId,
            'prompt': promptController.text.trim(),
            'promptId': _unitImagePromptDetail?.promptId,
            'replace': hasImageId,
            'subContent': widget.knowledgeDetail!.subContent?.toJson(),
          },
          requireToken: true,
        ),
      );

      if (response.data == null) {
        throw "response.message ?? '图片重新生成失败'";
      }

      _handleRegenerationSuccess(response.data!);
    } on FormatException catch (e) {
      _handleRegenerationError('${e.source.message}');
    } catch (e) {
      _handleRegenerationError('图片重新生成失败：${e.toString()}');
    }
  }

  /// 处理重新生成成功的情况
  void _handleRegenerationSuccess(ImageRegenerationConfig data) {
    _imageRegenerationConfig = data;
    // 更新提示词输入框
    if (data.prompt != null && data.prompt!.trim().isNotEmpty) {
      promptController.text = data.prompt!;
    }
    _startTimer();
    print('图片重新生成成功，已启动轮询定时器');
  }

  /// 处理重新生成错误的情况
  void _handleRegenerationError(String errorMessage) {
    ToastUtils.hideLoading();
    isRegenerating = false;
    ToastUtils.showManageToast(
      text: errorMessage,
      type: ManageToastType.error,
    );
    print('图片重新生成失败：$errorMessage');
  }

  /// 处理保存选中图片
  ///
  /// 调用AdminUtil.saveImageReviewResult API保存选中的图片
  /// 参考_loadKnowledgePrompt的结果处理模式进行优化
  Future<void> handleSaveSelectedImages() async {
    // 检查是否有选中的图片
    if (!hasSelectedImages) {
      ToastUtils.showManageToast(
        text: '请选择一张图片',
        type: ManageToastType.defaultType,
      );
      return;
    }

    // 检查提示词输入框是否为空
    if (promptController.text.trim().isEmpty) {
      ToastUtils.showManageToast(
        text: '请输入提示词',
        type: ManageToastType.defaultType,
      );
      return;
    }

    try {
      ToastUtils.showLoading();

      // 调用保存图片审核结果API
      final response = await AdminUtil.saveImageReviewResult(
        config: RequestConfig(
          data: {
            'imageId': widget.selectedImage?.imageId,
            'styleId': _unitImagePromptDetail?.styleId,
            'prompt': promptController.text.trim(),
            'promptId': _unitImagePromptDetail?.promptId,
            'historyIds': historyIds,
            'savedImages': selectedImages.map((element) => element.toSaveResultJson()).toList(),
            'subContent': {
              'type': widget.knowledgeDetail?.subContent?.type,
              'uid': widget.knowledgeDetail?.subContent?.uid,
              'semanticId': widget.knowledgeDetail?.subContent?.semanticId,
            }
          },
          requireToken: true,
        ),
      );

      if (response.data == null) {
        throw response.message ?? "保存失败";
      }

      // 保存成功后的处理
      ToastUtils.showManageToast(
        text: '图片保存成功',
        type: ManageToastType.defaultType,
      );

      // 返回到知识点详情页，传递保存成功的图片对象
      Navigator.of(context).pop(true);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message ?? '保存图片失败',
        type: ManageToastType.error,
      );
    } catch (e) {
      ToastUtils.showManageToast(
        text: '保存图片失败：${e.toString()}',
        type: ManageToastType.error,
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 初始化计时器
  ///
  /// 创建一个每秒回调的计时器，用于定时更新UI或执行特定操作
  void _initTimer() {
    // 创建60秒的计时器
    _timerUtil = TimerUtil(mTotalTime: 60 * 1000);

    // 设置每秒回调
    _timerUtil?.setOnTimerTickCallback((int tick) {
      // tick 是剩余时间（毫秒）
      int remainingSeconds = tick ~/ 1000;

      // 在这里添加每秒执行的逻辑
      _onTimerTick(remainingSeconds);

      // 计时器结束时的处理
      if (remainingSeconds <= 0) {
        _stopTimer();
      }
    });
  }

  /// 每秒回调处理
  ///
  /// 定期检查图片重新生成任务的执行状态
  /// 检查图片重新生成结果的API调用
  Future<void> _checkRegenerationResult() async {
    // 早期返回：检查配置是否存在
    if (_imageRegenerationConfig == null) {
      _stopRegenerationProcess();
      return;
    }

    try {
      // 调用获取重新生成结果的API
      // 根据选中图片是否有imageId来设置replace字段
      final bool hasImageId = selectedImages.isNotEmpty && selectedImages.any((image) => image.hasValidImageId);
      final response = await AdminUtil.getRegenerateResult(
        config: RequestConfig(
          data: {
            'replace': hasImageId,
            'styleId': _unitImagePromptDetail?.styleId,
            'imageId': widget.selectedImage?.imageId,
            'taskId': _imageRegenerationConfig!.taskId,
            'promptId': _imageRegenerationConfig!.promptId,
            'prompt': _imageRegenerationConfig!.prompt,
            'subContent': widget.knowledgeDetail!.subContent?.toJson(),
          },
          requireToken: true,
        ),
      );

      // 早期返回：检查响应数据是否为空
      if (response.data == null) {
        throw response.message ?? '生成图片失败';
      }

      final regeneratedDetail = response.data!;

      // 检查状态是否为已生成完成
      if (regeneratedDetail.status != 'generated') {
        // 如果状态不是generated，继续轮询
        print('图片生成中，状态: ${regeneratedDetail.status ?? "unknown"}');
        return;
      }

      // 状态为generated，处理生成完成逻辑
      // 检查是否有新的图片数据
      if (regeneratedDetail.hasImages) {
        // 成功获取到新图片，更新UI
        unitImages.clear();
        unitImages.addAll(regeneratedDetail.images!);
        print('图片重新生成完成，获取到 ${regeneratedDetail.images!.length} 张新图片');
      }

      if (regeneratedDetail.hasHistoryImages) {
        // 更新历史记录（使用嵌套结构的历史图片列表）
        historyImages.clear();
        historyImages.addAll(regeneratedDetail.historyImages ?? []);

        print('图片重新生成完成，获取到 ${regeneratedDetail.images!.length} 张历史图片');
      }

      if (regeneratedDetail.hasHistoryIds) {
        // 更新历史ID列表
        historyIds.clear();
        historyIds.addAll(regeneratedDetail.historyIds ?? []);

        print('图片重新生成完成，获取到 ${regeneratedDetail.images!.length} 张历史图片');
      }

      safeSetState(() {
        // 重新生成图片成功,将之前选中的历史记录索引重置
        _selectedHistoryIndex = null;
      });

      ToastUtils.showManageToast(
        text: '图片重新生成成功',
        type: ManageToastType.defaultType,
      );
      // 停止重新生成流程
      _stopRegenerationProcess();
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      _stopRegenerationProcess();
    } catch (e) {
      print('检查重新生成结果时发生错误: $e');
      ToastUtils.showManageToast(text: e.toString());
      _stopRegenerationProcess();
    }
  }

  /// 计时器回调方法
  /// [remainingSeconds] 剩余秒数
  void _onTimerTick(int remainingSeconds) async {
    // 在这里实现每秒执行的逻辑
    print('计时器回调: 剩余 $remainingSeconds 秒');

    // 如果有重新生成配置且正在重新生成中，则检查生成结果
    await _checkRegenerationResult();

    // 如果时间已到，停止重新生成状态
    if (remainingSeconds <= 0) {
      ToastUtils.hideLoading();
      isRegenerating = false;
    }
  }

  /// 启动计时器
  ///
  /// 检查定时器是否已初始化，如果没有则先初始化再启动
  void _startTimer() {
    // 如果定时器未初始化，先进行初始化
    if (_timerUtil == null) {
      _initTimer();
    }
    _timerUtil?.startCountDown();
  }

  /// 停止重新生成流程
  ///
  /// 统一处理停止计数器和清理状态的逻辑
  void _stopRegenerationProcess() {
    _stopTimer();
    ToastUtils.hideLoading();
    isRegenerating = false;
  }

  /// 停止计时器
  void _stopTimer() {
    _timerUtil?.cancel();
    _timerUtil = null;
  }

  @override
  void dispose() {
    // 清理计时器资源
    _stopTimer();
    _promptFocusNode.dispose();
    promptController.dispose();
    imageCountController.dispose();
    super.dispose();
  }
}
