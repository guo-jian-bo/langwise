import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/subscribe_and_listening_details/difficulty_choose_dialog.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/favourite_button.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../common/widgets/widgets.dart';
import '../../routes/routes.dart';
import 'bindings.dart';
import 'controller.dart';

class SubListenDetailsPage extends GetView<SubListenDetailsController> {
  final String tagText;
  const SubListenDetailsPage({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      SubListenDetailsPage(tagText: tag),
      binding: SubListenDetailsBinding(tagText: tag),
      routeName: Routes.APP_SUBSCRIBE_LISTENING_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppTheme.cSurfacePrimary.color,
          body: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.wMin + MediaQuery.of(context).padding.top),
                Row(children: [
                  SizedBox(width: 70.wMin),
                  GestureDetector(
                      onTap: () => Get.back(),
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                          width: 52.wMin,
                          height: 52.wMin,
                          alignment: Alignment.center,
                          child: SvgPicture.asset('assets/svg/public/icon_arrow_back.svg', width: 32.wMin, height: 32.wMin))),
                  SizedBox(width: 8.wMin),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
                    child: Text(controller.title.value, style: TextStyle(fontSize: 32.wMin, color: AppTheme.cTextPrimary.color)),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      _showDifficultyDialog(context);
                    },
                    child: Container(
                      height: 52.wMin,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: Color(0x14FFFFFF), border: Border.all(color: Color(0xFF5B6167))),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        SizedBox(width: 8.wMin),
                        Text('${controller.settingDifficulty.value == controller.userDifficulty.value ? '推荐' : ''}难度',
                            style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color)),
                        SizedBox(width: 4.wMin),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                            decoration: BoxDecoration(
                              color: StatusUtils.getCefrBackgroundColor(controller.difficultyList[controller.settingDifficulty.value]).color2,
                              borderRadius: BorderRadius.circular(4.wMin),
                            ),
                            child: Text(controller.difficultyList[controller.settingDifficulty.value], style: TextStyle(fontSize: 16.wMin, color: Colors.white))),
                        SizedBox(width: 4.wMin),
                        SvgPicture.asset(
                          'assets/svg/public/icon_w_arrow_right.svg',
                          width: 24.wMin,
                          height: 24.wMin,
                        ),
                        SizedBox(width: 8.wMin)
                      ]),
                    ),
                  ),
                  SizedBox(width: 70.wMin),
                ]),
                Padding(
                  padding: EdgeInsets.only(left: 70.wMin),
                  child: Text(controller.description.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 28.wMin, color: AppTheme.cTextTertiary.color)),
                ),
                SizedBox(height: 24.wMin),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.only(top: 40.wMin),
                    decoration: BoxDecoration(color: AppTheme.cBgPrimary.color, borderRadius: BorderRadius.vertical(top: Radius.circular(40.wMin))),
                    child: RefreshIndicator(
                      onRefresh: controller.refreshPage,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100 && notification is ScrollEndNotification) {
                            controller.loadPage();
                          }
                          return false;
                        },
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 16.wMin),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20.wMin,
                            crossAxisSpacing: 20.wMin,
                            childAspectRatio: 4,
                          ),
                          itemCount: controller.items.length,
                          itemBuilder: (context, index) {
                            final item = controller.items[index];
                            return _detailItem(item, index);
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _detailItem(UserRevealDetailItemEntity item, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.wMin),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceSecondary.color,
          border: Border.all(color: AppTheme.cBorderPrimary.color, strokeAlign: BorderSide.strokeAlignOutside),
        ),
        child: Row(
          children: [
            Container(
              height: double.infinity,
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildLeftTagThumb(item),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.wMin, 16.wMin, 0, 8.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                          decoration: BoxDecoration(color: Color(0xCCF97316), borderRadius: BorderRadius.circular(4.wMin)),
                          child: Text(
                            item.contentTypeTitle??'Reveal',
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cInverseTextLight.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.wMin),
                        if (item.difficulty!=null&&item.difficulty?.min != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                            margin: EdgeInsets.only(right: 4.wMin),
                            decoration: BoxDecoration(color: StatusUtils.getDifficultyBackgroundColor(item.difficulty!.min).color1, borderRadius: BorderRadius.circular(4.wMin)),
                            child: Text(
                              controller.dif[item.difficulty?.min]!,
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: AppTheme.cInverseTextLight.color,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        if (item.difficulty!=null&&item.difficulty!.max != item.difficulty!.min)
                          Row(
                            children: [
                              Text('-', style: TextStyle(color: AppTheme.cTextInverse.color)),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                                margin: EdgeInsets.only(left: 4.wMin, right: 4.wMin),
                                decoration:
                                    BoxDecoration(color: StatusUtils.getDifficultyBackgroundColor(item.difficulty!.max).color1, borderRadius: BorderRadius.circular(4.wMin)),
                                child: Text(
                                  controller.dif[item.difficulty?.max]!,
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    color: AppTheme.cTextInverse.color,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (item.tags != null && item.tags!.isNotEmpty)
                          Wrap(
                            spacing: 4.wMin,
                            children: item.tags!.map((tag) {
                              final themeText = StyleUtils.getCurrentThemeText(tag.style);
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.wMin,
                                  vertical: 4.wMin,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.wMin),
                                  color: ColorUtils.parseColor(themeText?.backgroundColor) ?? AppTheme.cTextInverse.color,
                                ),
                                child: Text(
                                  getGrene(tag.gloss ?? [], 'zh'),
                                  style: TextStyle(
                                    fontSize: (themeText?.fontsize ?? 16).wMin,
                                    color: ColorUtils.parseColor(themeText?.color) ?? AppTheme.cInverseTextLight.color,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        SizedBox(height: 16.wMin)
                      ],
                    ),
                    SizedBox(height: 24.wMin),
                    Text(item.title ?? '暂无内容', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color), maxLines: 1),
                    if (item.content != null)
                      Expanded(
                        child: Text(
                          item.content!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextTertiary.color,
                          ),
                        ),
                      ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FavouriteButton(
                          contentId: item.contentId ?? 0,
                          styleId: item.styleId,
                          dialect: item.dialect,
                          isFavourited: item.favourite ?? false,
                          playListId: 0,
                          contentType: item.contentType ?? "EN_REVEAL",
                          onRefresh: (needRefresh) {
                            if (needRefresh) {
                              controller.refreshPage();
                            }
                          },
                        ),
                        SizedBox(width: 16.wMin),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 16.wMin),
                  item.cardRights?.rights == 'NO_RIGHTS'
                      ? lockedWidget()
                      : (item.isRead ?? false)
                          ? isReadWidget()
                          : unlockWidget(),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      controller.readReveal(item, index);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.wMin),
                      height: 48.wMin,
                      padding: EdgeInsets.only(left: 16.wMin, right: 8.wMin),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.wMin),
                          color: item.cardRights?.rights == 'NO_RIGHTS' ? AppTheme.cFeedbackWarningBackground.color : AppTheme.cSurfaceQuaternary.color,
                          border: Border.all(
                              color: item.cardRights?.rights == 'NO_RIGHTS' ? AppTheme.cFeedbackWarningBackground.color : AppTheme.cBorderTertiary.color, width: 0.6.wMin)),
                      child: Row(
                        children: [
                          Text(item.cardRights?.rights == 'NO_RIGHTS' ? '去解锁' : '听读',
                              style: TextStyle(
                                  fontSize: 22.wMin,
                                  fontWeight: item.cardRights?.rights == 'NO_RIGHTS' ? FontWeight.w600 : FontWeight.w400,
                                  color: item.cardRights?.rights == 'NO_RIGHTS' ? AppTheme.cFeedbackWarningText : AppTheme.cTextPrimary.color)),
                          SizedBox(width: 2.wMin),
                          SvgPicture.asset('assets/svg/user_center/icon_chevron_right1.svg',
                              width: 20.wMin,
                              height: 20.wMin,
                              colorFilter: item.cardRights?.rights == 'NO_RIGHTS'
                                  ? ColorFilter.mode(AppTheme.cFeedbackWarningIcon.color, BlendMode.srcIn)
                                  : ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.wMin)
          ],
        ),
      ),
    );
  }

  //右上角难度弹窗
  void _showDifficultyDialog(BuildContext context) {
    DifficultyChooseDialog.show(context, 'sublisten', tagText: tagText);
  }

  Widget _buildLeftTagThumb(UserRevealDetailItemEntity item) {
    return Stack(
      children: [
        CachedImageWidget(
          item.imageUrl ?? '', errorWidget: buildEmptyWidget(), placeholder: buildLoadingWidget(), fadeInDuration: Duration.zero),
        if(item.isNewContent??false)Positioned(
            left: 10.wMin,
            top: 10.wMin,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: AppTheme.cSurfaceError),
              child: Text('new', style: TextStyle(fontSize: 22.wMin, fontWeight: FontWeight.w600, color: AppTheme.cInverseTextLight.color)),
            )),
      ],
    );
  }

  Widget isReadWidget() {
    return Container(
        height: 24.wMin,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(99.wMin), color: Color(0x3300BC7D)),
        child: Row(children: [
          SizedBox(width: 3.wMin),
          Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cFeedbackSuccessIcon.color),
              child: SvgPicture.asset('assets/svg/public/icon_check_w.svg', width: 18.wMin, height: 18.wMin)),
          SizedBox(width: 4.wMin),
          Text('已读', style: TextStyle(color: Color(0xFF00BC7D), fontSize: 16.wMin)),
          SizedBox(width: 8.wMin),
        ]));
  }

  Widget lockedWidget() {
    return Container(
        height: 24.wMin,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(99.wMin), color: AppTheme.cFeedbackWarningBackground.color),
        child: Row(children: [
          SizedBox(width: 8.wMin),
          SvgPicture.asset('assets/svg/public/icon_lock_solid.svg', width: 15.wMin, height: 18.wMin),
          SizedBox(width: 4.wMin),
          Text('未解锁', style: TextStyle(color: AppTheme.cFeedbackWarningText, fontSize: 16.wMin)),
          SizedBox(width: 8.wMin),
        ]));
  }

  Widget unlockWidget() {
    return Container(
        height: 24.wMin,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(99.wMin), color: AppTheme.cFeedbackInfoBackground.color),
        child: Row(children: [
          SizedBox(width: 3.wMin),
          Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cFeedbackInfoIcon.color),
              child: SvgPicture.asset('assets/svg/public/icon_check_w.svg', width: 18.wMin, height: 18.wMin)),
          SizedBox(width: 4.wMin),
          Text('已解锁', style: TextStyle(color: AppTheme.cFeedbackInfoText, fontSize: 16.wMin)),
          SizedBox(width: 8.wMin),
        ]));
  }

  String getGrene(List<ManageSubscribeNameItem> item, String condition) {
    var systemCondition = LangPreference.fromRawValue(UserStore.to.userInfo.value.config?.extensionConfig!.translationType ?? '').langCode;
    if (systemCondition.isNotEmpty) {
      condition = systemCondition;
    }
    for (var glossItem in item) {
      if (glossItem.lang == condition) {
        return glossItem.text!;
      }
    }
    return '';
  }
}
