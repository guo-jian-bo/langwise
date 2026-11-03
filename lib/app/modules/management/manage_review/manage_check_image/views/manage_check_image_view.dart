import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/manage_auth_box_widget.dart';
import '../../../common/manage_scaffold.dart';
import '../../../utils/manage_auth_utils.dart';
import '../bindings/manage_check_image_binding.dart';
import '../controllers/manage_check_image_controller.dart';

class ManageCheckImageView extends GetView<ManageCheckImageController> {
  final String tagText;
  const ManageCheckImageView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CHECK_IMAGE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCheckImageView(tagText: tag),
      binding: ManageCheckImageBinding(tag: tag),
      routeName: Routes.MANAGE_CHECK_IMAGE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      title: "审核图片",
      body: Obx(() {
        if (controller.isLoading.value) return Container();
        return Container(
          padding: EdgeInsets.only(
            left: 24.wMin,
            right: 24.wMin,
            top: 16.wMin,
          ),
          child: Column(
            children: [
              SizedBox(height: 54.wMin, child: toolBar()),
              SizedBox(height: 16.wMin),
              Expanded(
                child: Obx(() {
                  if (controller.checkList.isNotEmpty) {
                    return ListView.builder(
                       padding: EdgeInsets.only(bottom: 120.wMin),
                      itemCount: controller.checkList.length,
                      itemBuilder: (ctx, idx) {
                        return _itemView(idx);
                      },
                    );
                  }
                  if (controller.allCheckList.isNotEmpty || controller.taskIds.isNotEmpty) {
                    return Center(
                      child: Text(
                        "暂无数据",
                        style: TextStyle(
                          color: AppTheme.cTextPrimary.color,
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return _moreWidget();
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _itemView(int idx) {
    return Obx(() {
      var item = controller.checkList[idx];
      final int taskId = item.taskId ?? 0;
      final selectedIndex = controller.getSelectedImageIndex(item);
      bool userIsOfficial = UserStore.to.rolePermissions.value.isOfficial;
      final imageUrls = item.images?.map((e) => e.imageUrl ?? '').where((e) => e.isNotEmpty).toList() ?? <String>[];
      return Container(
        key: ValueKey<int>(taskId),
        padding: EdgeInsets.all(12.wMin),
        margin: EdgeInsets.only(bottom: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10.wMin),
                  child: Row(
                    children: [
                      chipItem(const Color(0xCCF97316), item.typeTitle ?? '', Colors.white),
                      SizedBox(width: 6.wMin),
                      // if (item.difficulty != null && item.difficulty?.min != null)
                      //   chipItem(StatusUtils.getDifficultyBackgroundColor(item.difficulty?.min).color1, controller.difficultyList[item.difficulty?.min ?? 0], Colors.white),
                      // if (item.difficulty != null && item.difficulty?.min != item.difficulty?.max)
                      //   Row(
                      //     children: [
                      //       Padding(
                      //         padding: EdgeInsets.symmetric(horizontal: 4.wMin),
                      //         child: Text('-', style: TextStyle(color: AppTheme.cInverseTextLight.color)),
                      //       ),
                      //       chipItem(StatusUtils.getDifficultyBackgroundColor(item.difficulty?.max).color1, controller.difficultyList[item.difficulty?.max ?? 0], Colors.white),
                      //     ],
                      //   ),
                      if (item.posTitle != null) chipItem(const Color(0x1A14B8A6), item.posTitle ?? '', AppTheme.cTextPrimary.color),
                      // Container(decoration: BoxDecoration(color: Color(0xFF767E95)), width: 2.wMin, height: 16.wMin, margin: EdgeInsets.symmetric(horizontal: 12.wMin)),
                    ],
                  ),
                ),
                Expanded(
                  child: SelectableText(
                    item.content ?? '',
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 32.wMin,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.wMin),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: '${item.taskId}'));
                      ToastUtils.showToast(text: 'ID复制成功', type: ToastType.success);
                    },
                    child: chipItem(
                      AppTheme.cSurfaceQuaternary,
                      'id:${item.taskId}',
                      AppTheme.cTextPrimary.color,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 6.wMin),
            if ((item.definition ?? '').isNotEmpty || (item.description ?? "").isNotEmpty)
              Row(
                children: [
                  Text(item.definition ?? '', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 18.wMin)),
                  if ((item.definition ?? '').isNotEmpty && (item.description ?? "").isNotEmpty) SizedBox(width: 8.wMin),
                  if ((item.definition ?? '').isNotEmpty && (item.description ?? "").isNotEmpty) Container(height: 3.wMin, color: AppTheme.cTextTertiary.color.withValues(alpha: .6), width: 40.wMin),
                  if ((item.description ?? "").isNotEmpty) SizedBox(width: 8.wMin),
                  Text(item.description ?? '', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 18.wMin)),
                ],
              ),
            if ((item.definition ?? '').isNotEmpty || (item.description ?? "").isNotEmpty) SizedBox(height: 16.wMin),
            Row(children: [
              if (item.styleTitle != null)
                Padding(
                  padding: EdgeInsets.only(right: 6.wMin),
                  child: chipItem(const Color(0xCC1DA1F2), item.styleTitle ?? '', Colors.white),
                ),
              if (item.localeTitle != null) chipItem(const Color(0x59353E5C), item.localeTitle ?? '', Colors.white),
            ]),
            SizedBox(height: 16.wMin),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: GridView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1, crossAxisSpacing: 16.wMin, mainAxisSpacing: 16.wMin),
                      children: item.images?.asMap().keys.map((e) {
                            var mImage = item.images?[e];
                            final bool isSelected = selectedIndex == e;
                            final bool isHovered = (controller.getHoveredImageIndex(item) == e);
                            final imgUrl = mImage?.imageUrl ?? '';
                            return GestureDetector(
                              onTap: () {
                                controller.setSelectedImageIndex(item, e);
                              },
                              child: MouseRegion(
                                onEnter: (_) => controller.setHoveredImageIndex(item, e),
                                onExit: (_) => controller.setHoveredImageIndex(item, null),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.wMin),
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFF44AF5C) : (isHovered ? const Color(0xFF2388FF) : Colors.transparent),
                                            width: 4.wMin,
                                            strokeAlign: BorderSide.strokeAlignOutside,
                                          ),
                                        ),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.wMin),
                                            child: Image.network(
                                              imgUrl,
                                              errorBuilder: (ctx, e, stack) => buildEmptyWidget(),
                                            )),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16.wMin,
                                      top: 11.wMin,
                                      child: Container(
                                        width: 40.wMin,
                                        height: 40.wMin,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.35),
                                          shape: BoxShape.circle,
                                        ),
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            controller.setSelectedImageIndex(item, e);
                                          },
                                          child: Center(
                                            child: isSelected
                                                ? SvgPicture.asset(
                                                    'assets/svg/public/check_box_green.svg',
                                                    width: 27.wMin,
                                                    height: 27.wMin,
                                                  )
                                                : Container(
                                                    width: 27.wMin,
                                                    height: 27.wMin,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.white),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10.wMin,
                                      bottom: 10.wMin,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          if (imageUrls.isEmpty) return;
                                          final openIndex = imageUrls.indexOf(imgUrl);
                                          ShowBigImageDialog.show(
                                            context: Get.context!,
                                            imageUrls: imageUrls,
                                            index: openIndex >= 0 ? openIndex : 0,
                                          );
                                        },
                                        child: Container(
                                          width: 34.wMin,
                                          height: 34.wMin,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.45),
                                            borderRadius: BorderRadius.circular(8.wMin),
                                          ),
                                          child: Icon(
                                            Icons.zoom_out_map,
                                            color: Colors.white,
                                            size: 18.wMin,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList() ??
                          []),
                ),
                SizedBox(width: 19.wMin),
                Column(
                  children: [
                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.contentReviewImageTaskFail],
                      child: GestureDetector(
                        onTap: () {
                          controller.deleteTask(item);
                        },
                        child: Container(
                          height: 43.wMin,
                          width: 105.wMin,
                          margin: EdgeInsets.only(bottom: 24.wMin),
                          decoration: BoxDecoration(color: Color(0xFFE11D48), borderRadius: BorderRadius.circular(4.wMin)),
                          alignment: Alignment.center,
                          child: Text(
                            '删除任务',
                            style: TextStyle(color: Colors.white, fontSize: 16.wMin),
                          ),
                        ),
                      ),
                    ),
                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.contentReviewImageRegenerateV2],
                      child: GestureDetector(
                        onTap: () {
                          controller.reGenerateImage(item);
                        },
                        child: Container(
                          height: 43.wMin,
                          width: 105.wMin,
                          decoration: BoxDecoration(color: Color(0xFFFF781F), borderRadius: BorderRadius.circular(4.wMin)),
                          alignment: Alignment.center,
                          child: Text(
                            '重新生成图片',
                            style: TextStyle(color: Colors.white, fontSize: 12.wMin),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !userIsOfficial,
                      child: Container(
                        margin: EdgeInsets.only(top: 24.wMin),
                        child: GestureDetector(
                          onTap: () {
                            controller.abandonTask(item);
                          },
                          child: Container(
                            height: 43.wMin,
                            width: 105.wMin,
                            decoration: BoxDecoration(color: Color(0xFFE11D48), borderRadius: BorderRadius.circular(4.wMin)),
                            alignment: Alignment.center,
                            child: Text(
                              '放弃',
                              style: TextStyle(color: Colors.white, fontSize: 16.wMin),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.wMin),
                    GestureDetector(
                      onTap: () {
                        controller.auditPass(item);
                      },
                      child: Container(
                        height: 43.wMin,
                        width: 105.wMin,
                        decoration: BoxDecoration(color: Color(0xFF44AF5C), borderRadius: BorderRadius.circular(4.wMin)),
                        alignment: Alignment.center,
                        child: Text(
                          '审核通过',
                          style: TextStyle(color: Colors.white, fontSize: 16.wMin),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.contentReviewLoadPromptV3],
              margin: EdgeInsets.only(top: 32.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '生成提示词（Prompt）',
                    style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 18.wMin),
                  ),
                  SizedBox(height: 8.wMin),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Obx(
                        () {
                          bool isLoading = controller.isPromptLoading(item);
                          if (isLoading) {
                            return Container(
                              height: 133.wMin,
                              decoration: BoxDecoration(
                                color: const Color(0xFF353E5C),
                                borderRadius: BorderRadius.circular(6.wMin),
                              ),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            );
                          }
                          final txtCtrl = controller.getPromptController(item);
                          return DraggableTextField(
                            key: ValueKey<String>('prompt_$taskId'),
                            controller: txtCtrl,
                            height: 133.wMin,
                          );
                        },
                      )),
                      SizedBox(width: 16.wMin),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (controller.isPromptLoading(item)) return;
                              controller.reGeneratePrompt(item);
                            },
                            child: Container(
                              height: 43.wMin,
                              width: 105.wMin,
                              decoration: BoxDecoration(
                                color: controller.isPromptLoading(item) ? const Color(0xFF353E5C) : const Color(0xFFFF781F),
                                borderRadius: BorderRadius.circular(4.wMin),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '重新生成prompt',
                                style: TextStyle(color: controller.isPromptLoading(item) ? Colors.grey : Colors.white, fontSize: 12.wMin),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget chipItem(Color bgColor, String txt, Color txtColor) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        height: 24.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.wMin),
          color: bgColor,
        ),
        child: Text(txt, style: TextStyle(color: txtColor, fontSize: 16.wMin)));
  }

  Widget _moreWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/svg/public/not_data.svg',
          width: 320.wMin,
          height: 320.wMin,
        ),
        Text(
          '没有待审核的图片',
          style: TextStyle(
            color: AppTheme.cTextPrimary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '所有图片都已审核完成',
          style: TextStyle(
            color: AppTheme.cTextSecondary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 44.wMin),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            controller.auditMore();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.wMin),
              color: const Color(0xFF2388FF),
            ),
            width: 122.wMin,
            height: 43.wMin,
            alignment: Alignment.center,
            child: Text('再审核一批', style: TextStyle(color: Colors.white, fontSize: 18.wMin)),
          ),
        )
      ],
    );
  }

  Widget tabBar() {
    return Row(
      children: controller.tabList.asMap().keys.map((e) {
        return GestureDetector(
          onTap: () {
            if (controller.tabIndex.value == e) return;
            controller.tabIndex.value = e;
          },
          child: AnimatedContainer(
            child: Text(controller.tabList[e], style: TextStyle(fontSize: 18.wMin, color: Colors.white)),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: controller.tabIndex.value == e ? Color(0xFF353E5C) : Colors.transparent,
              borderRadius: BorderRadius.circular(6.wMin),
            ),
            width: 67.wMin,
            height: 54.wMin,
            duration: const Duration(milliseconds: 220),
          ),
        );
      }).toList(),
    );
  }

  Widget toolBar() {
    return Row(spacing: 8.wMin, children: [
      SearchWidget(
        controller: controller.searchInput,
        width: 260.ww,
        height: 54.wh,
        fontSize: 21,
        iconSize: 24,
        hintText: '搜索知识点',
        color: AppTheme.cSurfaceSecondary.color,
        borderColor: AppTheme.cBorderPrimary.color,
        fontColor: AppTheme.cTextPrimary.color,
        onChanged: (String value) {
          controller.onSearchChanged(value);
        },
      ),
      const Spacer(),
      Container(
        child: Obx((){
          return Text(
            '${controller.allCheckList.length}个待审核',
            style: TextStyle(
              color: const Color(0xFFFF781F),
              fontSize: 19.wMin,
              fontWeight: FontWeight.w400,
            ),
          );
        }),
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        height: 54.wMin,
        alignment: Alignment.center,
      ),
      GestureDetector(
        onTap: () {
          controller.showAuditHistory();
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF353E5C),
            borderRadius: BorderRadius.circular(6.wMin),
          ),
          child: Text(
            '审核历史',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19.wMin,
            ),
          ),
          width: 108.wMin,
          height: 54.wMin,
          alignment: Alignment.center,
        ),
      ),
      ManageAuthBoxWidget(
        authCodes: const [ManageAuthCode.contentReviewImageAuditHistory],
        child: GestureDetector(
          onTap: () {
            controller.showAuditHistory(isAdmin: true);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            decoration: BoxDecoration(
              color: const Color(0xFF353E5C),
              borderRadius: BorderRadius.circular(6.wMin),
            ),
            child: Text(
              '管理员',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19.wMin,
              ),
            ),
            height: 54.wMin,
            alignment: Alignment.center,
          ),
        ),
      ),
    ]);
  }
}
