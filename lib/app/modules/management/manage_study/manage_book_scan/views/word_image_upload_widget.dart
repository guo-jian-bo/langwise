import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/word_image_card.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../index.dart';
import 'big_image_widget.dart';

class WordImageUploadManager {
  static Future<bool?> show({
    required BuildContext context,
    int? bookId,
    int? chapterId,
    bool editEnable = false,
    void Function(int index)? onTap,
  }) {
    return Get.dialog<bool?>(
      WordImageUploadWidget(
        bookId: bookId,
        chapterId: chapterId,
        editEnable: editEnable,
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      print('---内页管理弹框消失,value:$value---');
      return value;
    });
  }
}

class WordImageUploadWidget extends StatefulWidget {
  final int? bookId;
  final int? chapterId;
  final bool editEnable;

  const WordImageUploadWidget({super.key, this.bookId, this.chapterId, this.editEnable = false});

  @override
  State<WordImageUploadWidget> createState() => _WordImageUploadWidgetState();
}

class _WordImageUploadWidgetState extends State<WordImageUploadWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.bookId != null) {
      Get.find<ManageBookScanController>().onFetchBookPages(widget.bookId!, widget.chapterId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
      body: Center(
        child: Container(
          width: 1080.ww,
          height: 880.wh,
          padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(
              color: const Color(0xff444B5F),
              width: 1.wMin, // 边框宽度
            ),
            color: const Color(0xff181B25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ManageTitleWidget(
                title: "教材",
                onCloseTap: () {
                  Get.back();
                },
              ),
              Gaps.getHeight(27.wh),
              _buildWordImageWidget(),
              Gaps.getHeight(28.wh),
              _buildBottomWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// 单词表
  Widget _buildWordImageWidget() {
    return Container(
      height: 680.wh,
      padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.ww, vertical: 9.wh),
            height: 590.wh,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              border: Border.all(width: (0.5).wMin, color: const Color(0xff4B5268)),
              color: Colors.transparent,
            ),
            child: Obx(() {
              if (Get.find<ManageBookScanController>().state.scanImages.isEmpty) {
                return Center(
                  child: Text(
                    "暂无数据",
                    style: TextStyle(
                      color: const Color(0xffACB4C0),
                      fontSize: 12.wMin,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                );
              }

              return AnimationLimiter(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // 每行三列
                      crossAxisCount: 4,
                      // 列间距
                      crossAxisSpacing: 17.ww,
                      // 行间距
                      mainAxisSpacing: 34.wh,
                      // 子组件宽高比
                      childAspectRatio: 232 / 300),
                  itemCount: Get.find<ManageBookScanController>().state.scanImages.length,
                  itemBuilder: (context, index) {
                    final oldEntity = Get.find<ManageBookScanController>().state.scanImages[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 350),
                      columnCount: Get.find<ManageBookScanController>().state.scanImages.length,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: WordImageCardWidget(
                            // 使用数据唯一标识而非index
                            key: ValueKey(oldEntity.uniqueId),
                            index: index,
                            wordImageEntity: oldEntity,
                            onDeleteTap: (int i) {
                              Get.find<ManageBookScanController>().state.scanImages.removeAt(i);
                            },
                            onChanged: (int i, WordImageEntity entity) {
                              print("---回调页码index:${entity.index}---");
                              Get.find<ManageBookScanController>().state.scanImages[i] = entity;
                            },
                            onTap: (int i, WordImageEntity entity) {
                              ManageBigImageManager.show(context: context, entity: entity);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          /*
          Row(
            children: [
              TapScaleWidget(
                onTap: widget.editEnable
                    ? OptimizeUtils.noneThrottle(() {
                        Get.find<ManageBookScanController>().onAddCover();
                      }, 300)
                    : null,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(6.wMin),
                  padding: EdgeInsets.zero,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 2.wMin,
                  color: const Color(0xff4B5268),
                  dashPattern: const [5, 5],
                  child: SizedBox(
                    width: 160.ww,
                    height: 40.wh,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildImage(
                          Assets.managerAdd,
                          width: Dimens.dn_18.wh,
                          height: Dimens.dn_18.wh,
                        ),
                        Gaps.getWidth(Dimens.dn_10.ww),
                        Text(
                          '添加本地文件',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xffACB4C0),
                            fontSize: 12.wMin,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Gaps.getWidth(Dimens.dn_16.ww),
              TapScaleWidget(
                onTap: widget.editEnable
                    ? OptimizeUtils.noneThrottle(() {
                        Get.find<ManageBookScanController>().toScanWord(context, Get.find<ManageBookScanController>().targetBookId,
                            Get.find<ManageBookScanController>().targetChapterId,
                            editEnable: widget.editEnable, fromUploadPage: true);
                      }, 300)
                    : null,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(6.wMin),
                  padding: EdgeInsets.zero,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 2.wMin,
                  color: const Color(0xff4B5268),
                  dashPattern: const [5, 5],
                  child: SizedBox(
                    width: 160.ww,
                    height: 40.wh,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildImage(
                          Assets.managerCamera,
                          width: Dimens.dn_18.wh,
                          height: Dimens.dn_18.wh,
                        ),
                        Gaps.getWidth(Dimens.dn_10.ww),
                        Text(
                          '扫描词汇单词',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xffACB4C0),
                            fontSize: 12.wMin,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              TapScaleWidget(
                  onTap: widget.editEnable
                      ? OptimizeUtils.noneThrottle(() {
                          Get.find<ManageBookScanController>().onConfirm(analyze: true);
                        }, 300)
                      : null,
                  child: Container(
                    width: 160.ww,
                    height: 40.wh,
                    alignment: const Alignment(0, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color: const Color(0xff2388FF),
                    ),
                    child: Text(
                      '确认并分析信息',
                      style: TextStyle(
                        color: widget.editEnable
                            ? const Color(0xffEBEFF5)
                            : const Color(0xffEBEFF5).withValues(alpha: 0.5),
                        fontSize: 12.wMin,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                  ))
            ],
          ),
          */
        ],
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff767E95),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 11.ww),
        ManageButton(
            text: "确认",
            width: 80.ww,
            height: 40.wh,
            color: const Color(0xff353E5C),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: widget.editEnable ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
            onTap: widget.editEnable
                ? OptimizeUtils.noneThrottle(() {
                    Get.find<ManageBookScanController>().onConfirm();
                  }, 300)
                : null)
      ],
    );
  }
}
