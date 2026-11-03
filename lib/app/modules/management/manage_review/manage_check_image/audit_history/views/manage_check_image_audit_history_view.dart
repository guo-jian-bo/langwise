import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_auth_box_widget.dart';
import '../../../../common/manage_scaffold.dart';
import '../../../../utils/manage_auth_utils.dart';
import '../bindings/manage_check_image_audit_history_binding.dart';
import '../controllers/manage_check_image_audit_history_controller.dart';

class ManageCheckImageAuditHistoryView extends GetView<ManageCheckImageAuditHistoryController> {
  final String tagText;
  const ManageCheckImageAuditHistoryView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CHECK_IMAGE_AUDIT_HISTORY}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCheckImageAuditHistoryView(tagText: tag),
      binding: ManageCheckImageAuditHistoryBinding(tag: tag),
      routeName: Routes.MANAGE_CHECK_IMAGE_AUDIT_HISTORY,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      title: "审核历史",
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.only(
            left: 24.wMin,
            right: 24.wMin,
            top: 16.wMin,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 54.wMin,
                child: Row(
                  children: [
                    // tabBar(),
                    _toolBar(context),
                    const Spacer(),
                    _paginationBar(),
                    // SizedBox(width: 12.wMin),
                    // Visibility(
                    //   child: Container(
                    //       alignment: Alignment.center,
                    //       height: 54.wMin,
                    //       padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    //       decoration: BoxDecoration(color: const Color(0xFF353E5C), borderRadius: BorderRadius.circular(6.wMin)),
                    //       child: Text(
                    //         '管理员',
                    //         style: TextStyle(color: Colors.white, fontSize: 19.wMin),
                    //       ),
                    //     ),
                    // ),
                  ],
                ),
              ),
              Visibility(
                visible: controller.fromAdmin,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.wMin),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '审核员',
                            style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 20.wMin),
                          ),
                          SizedBox(width: 12.wMin),
                          Container(
                            height: 54.wMin,
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                            decoration: BoxDecoration(
                              color: AppTheme.cSurfaceSecondary.color,
                              borderRadius: BorderRadius.circular(6.wMin),
                              border: Border.all(color: AppTheme.cBorderPrimary.color),
                            ),
                            child: Obx(
                              () {
                                final value = controller.selectedReviewerUserId.value ?? -1;
                                return DropdownButton<int>(
                                  value: value,
                                  dropdownColor: AppTheme.cSurfaceSecondary.color,
                                  underline: const SizedBox.shrink(),
                                  iconEnabledColor: AppTheme.cTextPrimary.color,
                                  iconSize: 20.wMin,
                                  padding: EdgeInsets.zero,
                                  style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 20.wMin),
                                  items: controller.reviewers.map((e) {
                                    return DropdownMenuItem<int>(
                                      value: e.userId,
                                      child: Text(e.userName),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    controller.setReviewerUserId(v);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      ManageAuthBoxWidget(
                        authCodes: const [ManageAuthCode.contentReviewImageAuditStatistics],
                        margin: EdgeInsets.only(left: 16.wMin),
                        child: GestureDetector(
                          onTap: () {
                            controller.showAuditStatistics();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 54.wMin,
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                            decoration: BoxDecoration(color: const Color(0xFF353E5C), borderRadius: BorderRadius.circular(6.wMin)),
                            child: Text('查看统计', style: TextStyle(color: Colors.white, fontSize: 20.wMin)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.wMin),
              Expanded(
                child: ListView.builder(
                   padding: EdgeInsets.only(bottom: 120.wMin),
                  itemCount: controller.list.length,
                  itemBuilder: (ctx, idx) {
                    return _itemView(idx);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _toolBar(BuildContext context) {
    return Row(
      children: [
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
          onSubmitted: (String value) {
            controller.currentPage.value = 1;
            controller.pageJumpController.text = '1';
            controller.fetchList();
          },
        ),
        SizedBox(width: 16.wMin),
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () {
              DateTimePickerUtils.showStartEndCalender(
                  context: context,
                  minDate: DateTime(2024, 11, 18),
                  maxDate: DateTime.now(),
                  initialStartDate: controller.startDate.value,
                  initialEndDate: controller.endDate.value,
                  onTap: (startDate, endDate) {
                    var _startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
                    var _endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
                    controller.setDate(mStartDate: _startDate, mEndDate: _endDate);
                  });
            },
            child: Container(
                alignment: Alignment.center,
                height: 54.wMin,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfaceSecondary.color,
                  border: Border.all(
                    color: AppTheme.cBorderPrimary.color,
                    width: 1.wMin,
                  ),
                ),
                child: Row(
                  children: [
                    Text('${controller.formatDateLabel(controller.startDate.value)}~${controller.formatDateLabel(controller.endDate.value)}',
                        style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 19.wMin)),
                    if (controller.startDate.value != null && controller.endDate.value != null) ...[
                      SizedBox(width: 8.wMin),
                      GestureDetector(
                        onTap: () {
                          controller.clearDateRange();
                        },
                        child: SvgPicture.asset('assets/svg/public/icon_clean.svg', width: 27.wMin, height: 27.wMin),
                      )
                    ],
                  ],
                )),
          );
        }),
        SizedBox(width: 16.wMin),
      ],
    );
  }

  Widget _paginationBar() {
    return Obx(() {
      final int pageSize = controller.pageSize.value;
      final int current = controller.currentPage.value;
      final int totalPages = controller.totalPages;
      final List<int> pages = controller.buildVisiblePages();

      return Row(
        children: [
          Container(
            height: 54.wMin,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary.color,
              borderRadius: BorderRadius.circular(4.wMin),
            ),
            child: Text(
              '共${controller.totalCount.value}条记录',
              style: TextStyle(fontSize: 20.wMin, color: AppTheme.cTextPrimary.color),
            ),
          ),
          SizedBox(width: 8.wMin),
          Container(
            height: 54.wMin,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary.color,
              borderRadius: BorderRadius.circular(4.wMin),
            ),
            child: DropdownButton<int>(
              value: pageSize,
              dropdownColor: AppTheme.cSurfaceSecondary.color,
              underline: const SizedBox.shrink(),
              iconEnabledColor: AppTheme.cTextPrimary.color,
              iconSize: 20.wMin,
              padding: EdgeInsets.zero,
              style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 20.wMin),
              items: const [5, 10, 15, 20].map((e) {
                return DropdownMenuItem<int>(
                  value: e,
                  child: Text('$e条/页'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.changePageSize(value);
                }
              },
            ),
          ),
          SizedBox(width: 8.wMin),
          _pageButton(
            label: '<',
            enabled: current > 1,
            isActive: false,
            onTap: controller.goPrevPage,
          ),
          ..._buildPageButtons(pages, current),
          _pageButton(
            label: '>',
            enabled: current < totalPages,
            isActive: false,
            onTap: controller.goNextPage,
          ),
          SizedBox(width: 12.wMin),
          Text('前往', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 20.wMin)),
          SizedBox(width: 2.wMin),
          SizedBox(
            width: 45.wMin,
            child: TextField(
              controller: controller.pageJumpController,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 20.wMin),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 12.wMin),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final int? page = int.tryParse(value);
                if (page != null) {
                  controller.goToPage(page);
                }
              },
            ),
          ),
          SizedBox(width: 2.wMin),
          Text('页', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 20.wMin)),
        ],
      );
    });
  }

  Widget _pageButton({
    required String label,
    required bool enabled,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color bg = isActive ? AppTheme.cSurfaceQuaternary.color : AppTheme.cSurfaceSecondary.color;
    final Color fg = enabled ? AppTheme.cTextPrimary.color : AppTheme.cTextTertiary.color;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.wMin),
        alignment: Alignment.center,
        height: 54.wMin,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6.wMin),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 20.wMin, color: fg),
        ),
      ),
    );
  }

  List<Widget> _buildPageButtons(List<int> pages, int current) {
    final List<Widget> widgets = [];
    for (int i = 0; i < pages.length; i++) {
      final int page = pages[i];

      if (i > 0 && pages[i] - pages[i - 1] > 1) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.wMin),
            child: Text(
              '...',
              style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 20.wMin),
            ),
          ),
        );
      }

      widgets.add(
        _pageButton(
          label: '$page',
          enabled: true,
          isActive: page == current,
          onTap: () => controller.goToPage(page),
        ),
      );
    }
    return widgets;
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

  Widget _itemView(int idx) {
    return Obx(() {
      final item = controller.list[idx];
      final bool isEditing = controller.isEditing(item);
      final int selectedIndex = controller.getSelectedImageIndex(item);

      return Container(
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
                      Container(
                        child: chipItem(const Color(0xCCF97316), item.typeTitle ?? '', Colors.white),
                      ),
                      SizedBox(width: 6.wMin),
                      // if (item.difficulty != null && item.difficulty?.min != null)
                      //   chipItem(
                      //     StatusUtils.getDifficultyBackgroundColor(item.difficulty?.min).color1,
                      //     controller.difficultyList[item.difficulty?.min ?? 0],
                      //     Colors.white,
                      //   ),
                      if (item.posTitle != null)
                        chipItem(
                          const Color(0x1A14B8A6),
                          item.posTitle ?? '',
                          AppTheme.cTextPrimary.color,
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 6.wMin),
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
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                        height: 24.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.wMin),
                          color: item.status == 'checked' ? const Color(0xFF63DE77) : const Color(0xFFE54858),
                        ),
                        child: Text(item.status == 'checked' ? '通过' : '失败', style: TextStyle(color: Colors.white, fontSize: 14.wMin))),
                    SizedBox(width: 6.wMin),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: item.taskId.toString()));
                        ToastUtils.showToast(text: 'ID复制成功', type: ToastType.success);
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.wMin),
                            color: AppTheme.cSurfaceTertiary.color,
                          ),
                          child: Text("id:${item.taskId}", style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 18.wMin))),
                    ),
                    SizedBox(width: 24.wMin),
                    Text(
                      "审核时间：${DateFormatUtil.formatStrtoStr(item.checked ?? '', newPattern: 'yyyy-MM-dd HH:mm')}",
                      style: TextStyle(
                        color: AppTheme.cSurfaceWarning.color,
                        fontSize: 18.wMin,
                      ),
                    ),
                    SizedBox(width: 24.wMin),
                    Text(
                      "审核员：${item.userName}",
                      style: TextStyle(color: AppTheme.cSurfaceWarning.color, fontSize: 18.wMin),
                    ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.wMin),
            if ((item.definition ?? '').isNotEmpty || (item.description ?? "").isNotEmpty)
              Row(
                children: [
                  Text(item.definition ?? '', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 18.wMin)),
                  if ((item.definition ?? '').isNotEmpty) SizedBox(width: 8.wMin),
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
            if ((item.images?.isNotEmpty ?? false))
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: GridView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1,
                        crossAxisSpacing: 16.wMin,
                        mainAxisSpacing: 16.wMin,
                      ),
                      children: item.images?.asMap().keys.map((e) {
                            final img = item.images?[e];
                            final bool selected = selectedIndex == e;
                            final bool isHovered = isEditing && (controller.getHoveredImageIndex(item) == e);
                            final imgUrl = img?.imageUrl ?? '';
                            final imageUrls = item.images?.map((e) => e.imageUrl ?? '').where((e) => e.isNotEmpty).toList() ?? <String>[];
                            return GestureDetector(
                              onTap: () {
                                if (!isEditing) return;
                                controller.setSelectedImageIndex(item, e);
                              },
                              child: MouseRegion(
                                onEnter: (_) {
                                  if (!isEditing) return;
                                  controller.setHoveredImageIndex(item, e);
                                },
                                onExit: (_) {
                                  if (!isEditing) return;
                                  controller.setHoveredImageIndex(item, null);
                                },
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                        child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.wMin),
                                        border: Border.all(
                                          color: selected ? const Color(0xFF44AF5C) : (isHovered ? const Color(0xFF2388FF) : Colors.transparent),
                                          width: 4.wMin,
                                          strokeAlign: BorderSide.strokeAlignOutside,
                                        ),
                                      ),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.wMin),
                                          child: Image.network(imgUrl, errorBuilder: (context, error, stackTrace) => buildEmptyWidget())),
                                    )),
                                    Positioned(
                                      left: 16.wMin,
                                      top: 11.wMin,
                                      child: Container(
                                        width: 40.wMin,
                                        height: 40.wMin,
                                        decoration: BoxDecoration(
                                          color: selected || isEditing ? Colors.black.withOpacity(0.35) : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            if (!isEditing) return;
                                            controller.setSelectedImageIndex(item, e);
                                          },
                                          child: Center(
                                            child: selected
                                                ? SvgPicture.asset(
                                                    'assets/svg/custom_course/icon_check_ok_circle.svg',
                                                    width: 36.wMin,
                                                    height: 36.wMin,
                                                  )
                                                : isEditing
                                                    ? Container(
                                                        width: 27.wMin,
                                                        height: 27.wMin,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          border: Border.all(color: Colors.white),
                                                        ),
                                                      )
                                                    : Container(),
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
                                          ShowBigResourceDialog.showImage(
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
                          [],
                    ),
                  ),
                  SizedBox(width: 19.wMin),
                  Column(
                    children: [
                      if (!isEditing)
                        GestureDetector(
                          onTap: () {
                            controller.enterEditMode(item);
                          },
                          child: Container(
                            height: 43.wMin,
                            width: 105.wMin,
                            decoration: BoxDecoration(color: Color(0xFF2388FF), borderRadius: BorderRadius.circular(4.wMin)),
                            alignment: Alignment.center,
                            child: Text(
                              '重新审核',
                              style: TextStyle(color: Colors.white, fontSize: 16.wMin),
                            ),
                          ),
                        )
                      else ...[
                        ManageAuthBoxWidget(
                          authCodes: const [ManageAuthCode.contentReviewImageCreate],
                          child: GestureDetector(
                            onTap: () {
                              controller.reGenerateImage(item);
                            },
                            child: Container(
                              height: 48.wMin,
                              width: 105.wMin,
                              decoration: BoxDecoration(color: Color(0xFFFF781F), borderRadius: BorderRadius.circular(4.wMin)),
                              alignment: Alignment.center,
                              child: Text(
                                '重新生成prompt和图片',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 12.wMin),
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
                      ]
                    ],
                  ),
                ],
              ),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.contentReviewImageRegenerateV2],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.wMin),
                  Text(
                    '生成提示词（Prompt）',
                    style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 18.wMin),
                  ),
                  SizedBox(height: 8.wMin),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: controller.isPromptLoading(item)
                            ? Container(
                                height: 133.wMin,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF353E5C),
                                  borderRadius: BorderRadius.circular(6.wMin),
                                ),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              )
                            : DraggableTextField(
                                controller: controller.getPromptController(item),
                                height: 133.wMin,
                              ),
                      ),
                      SizedBox(width: 16.wMin),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (controller.isPromptLoading(item)) return;
                              controller.reGeneratePrompt(item);
                            },
                            child: Container(
                              height: 48.wMin,
                              width: 105.wMin,
                              decoration: BoxDecoration(
                                color: controller.isPromptLoading(item) ? const Color(0xFF353E5C) : const Color(0xFFFF781F),
                                borderRadius: BorderRadius.circular(4.wMin),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '根据promt重新生成图片',
                                textAlign: TextAlign.center,
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
      child: Text(txt, style: TextStyle(color: txtColor, fontSize: 16.wMin)),
    );
  }
}
