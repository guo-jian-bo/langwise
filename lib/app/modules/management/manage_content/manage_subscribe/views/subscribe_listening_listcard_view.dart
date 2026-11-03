import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/article_entity.dart';
import 'package:langwise/common/entities/manage_subscribe_entity.dart';
import 'package:langwise/common/entities/theme_style_entity.dart';
import 'package:langwise/common/entities/unit_knowledge_points_entity.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../common/commons.dart';
import '../../../common/knowledge_video_tool_buttons_widget.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../utils/utils.dart';
import '../bindings/subscribe_listening_listcard_binding.dart';
import '../controllers/subscribe_listening_listcard_controller.dart';
import 'subscribe_originarticle_dialog.dart';

class SubscribeListeningListcardView extends GetView<SubscribeListeningListcardController> {
  final String tagText;
  const SubscribeListeningListcardView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SUBSCRIBE_LISTCARD}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      SubscribeListeningListcardView(tagText: tag),
      binding: SubscribeListeningListcardBinding(tag: tag),
      routeName: Routes.MANAGE_SUBSCRIBE_LISTCARD,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) {
        return Obx(() {
          return ManageScaffold(
            onRefresh: () => controller.initData(),
            resizeToAvoidBottomInset: true,
            backgroundColor: const Color(0xff050916),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildTitleWidget(context),
                      Gaps.getHeight(15.wh),
                      _buildHeader(),
                      Gaps.getHeight(15.wh),
                      Expanded(child: _buildExpandableSection()),
                    ],
                  ),
                  Positioned(
                    right: 10.wMin,
                    bottom: 200.wMin,
                    child: ManageListToolButtonWidget(
                      isExpand: controller.isAllExpand.value,
                      onExpand: controller.onAllExpand,
                      onSubmit: controller.initData,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildExpandableSection() {
    var groupData = controller.revealData.value.enGroupRevealContents;
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: 200.wMin,
        left: 130.wMin,
        right: 130.wMin,
      ),
      itemCount: groupData?.datas?.length ?? 0,
      itemBuilder: (context, index) {
        return Obx(() {
          final bool isExpanded = controller.expandedIndexSet.contains(index);
          var data = groupData?.datas?[index];
          if (data == null) return const SizedBox.shrink();

          final List<ArticleEntity> contents = data.contentDTOS ?? <ArticleEntity>[];

          final int audioStartTrueCount = contents.where((e) => e.isAudioStart == true).length;
          final int audioStartFalseCount = contents.where((e) => e.isAudioStart == false).length;

          final int audioStatusNullCount = contents.where((e) => e.audioStatus == null).length;
          final int audioStatusStartCount = contents.where((e) => e.audioStatus == 'AUDIO_START').length;
          final int audioStatusFinishCount = contents.where((e) => e.audioStatus == 'AUDIO_FINISH').length;
          final int audioStatusReviewCount = contents.where((e) => e.audioStatus == 'AUDIO_REVIEW').length;
          final int publishedCount = contents.where((e) => e.isLaunch ?? false).length;
          final int unpublishedCount = contents.where((e) => !(e.isLaunch ?? false)).length;
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10.wMin),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (isExpanded) {
                      controller.expandedIndexSet.remove(index);
                    } else {
                      controller.expandedIndexSet.add(index);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF26292A),
                      borderRadius: BorderRadius.circular(12.wMin),
                    ),
                    padding: EdgeInsets.all(24.wMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SelectableText(
                              format(data.group ?? ''),
                              style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                            SizedBox(width: 16.wMin),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 11.wMin),
                                decoration: BoxDecoration(color: const Color(0xFF353E5C), borderRadius: BorderRadius.circular(4.wMin)),
                                child: Text('${data.contentDTOS?.length ?? 0}篇文章',
                                    style: TextStyle(
                                      fontSize: 18.wMin,
                                      color: const Color(0xFFBAC0CC),
                                    ))),
                            SizedBox(width: 16.wMin),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 11.wMin),
                                decoration: BoxDecoration(color: const Color(0x1FFF781F), borderRadius: BorderRadius.circular(4.wMin)),
                                child: Text('未上架$unpublishedCount篇',
                                    style: TextStyle(
                                      fontSize: 18.wMin,
                                      color: const Color(0xFFFF781F),
                                    ))),
                            SizedBox(width: 16.wMin),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 11.wMin),
                                decoration: BoxDecoration(color: const Color(0x1F63DE77), borderRadius: BorderRadius.circular(4.wMin)),
                                child: Text('已上架$publishedCount篇',
                                    style: TextStyle(
                                      fontSize: 18.wMin,
                                      color: const Color(0xFF63DE77),
                                    ))),
                            SizedBox(width: 16.wMin),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF353E5C),
                                borderRadius: BorderRadius.circular(4.wMin),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 11.wMin),
                              child: Text(
                                contents.first.calendarType == null
                                    ? "未设置推送时间"
                                    : contents.first.calendarType == "IMMEDIATELY"
                                        ? '立即推送'
                                        : contents.first.calendarType == "LUNAR"
                                            ? '农历:${_formatPublishDate(contents.first.publishedDate)}'
                                            : '公历:${_formatPublishDate(contents.first.publishedDate)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                              ),
                            ),
                            const Spacer(),
                            ManageAuthBoxWidget(
                              authCodes: const [ManageAuthCode.enRevealsCreate],
                              margin: EdgeInsets.only(right: 16.wMin),
                              child: GestureDetector(
                                onTap: () {
                                  controller.createWithOriginInfo(data, data.contentDTOS!.first);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 11.wMin),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.wMin),
                                    color: const Color(0x2E2388FF),
                                  ),
                                  child: Row(children: [
                                    SvgPicture.asset('assets/svg/public/home_not_plan.svg', width: 20.wMin, height: 20.wMin),
                                    SizedBox(width: 3.wMin),
                                    Text(
                                      '创建文章',
                                      style: TextStyle(fontSize: 18.wMin, fontWeight: FontWeight.w400, color: const Color(0xFF2388FF)),
                                    )
                                  ]),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (data.contentDTOS == null || data.contentDTOS!.isEmpty) return;
                                SubscribeOriginArticleDialog.show(context: context, articleEntity: data.contentDTOS!.first);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 11.wMin),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.wMin),
                                  color: const Color(0x2E2388FF),
                                ),
                                child: Row(children: [
                                  SvgPicture.asset('assets/svg/manage/icon_origin_article.svg', width: 20.wMin, height: 20.wMin),
                                  SizedBox(width: 3.wMin),
                                  Text(
                                    '查看原文',
                                    style: TextStyle(fontSize: 18.wMin, fontWeight: FontWeight.w400, color: const Color(0xFF2388FF)),
                                  )
                                ]),
                              ),
                            ),
                            SizedBox(width: 16.wMin),
                            ManageAuthBoxWidget(
                              authCodes: const [ManageAuthCode.enRevealsGroupUpdateContent],
                              child: GestureDetector(
                                onTap: () {
                                  if (data.contentDTOS == null || data.contentDTOS!.isEmpty) return;
                                  ArticleEntity item = data.contentDTOS!.first;
                                  if (item.publishedDate == null || item.calendarType == null) {
                                    controller.setPublishTime(0, item.group ?? '', DateTime.now(), item.isLaunch ?? false);
                                  } else {
                                    var date = DateTime.tryParse(item.publishedDate ?? '');
                                    controller.setPublishTime(
                                        item.calendarType == "IMMEDIATELY"
                                            ? 0
                                            : item.calendarType == "GREGORIAN"
                                                ? 1
                                                : 2,
                                        item.group ?? '',
                                        date ?? DateTime.now(),
                                        item.isLaunch ?? false);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 11.wMin),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.wMin),
                                    color: const Color(0x2E2388FF),
                                  ),
                                  child: Row(children: [
                                    SvgPicture.asset('assets/svg/manage/icon_batch_publish.svg', width: 20.wMin, height: 20.wMin),
                                    SizedBox(width: 3.wMin),
                                    Text(
                                      '批量推送及上架',
                                      style: TextStyle(fontSize: 18.wMin, fontWeight: FontWeight.w400, color: const Color(0xFF2388FF)),
                                    )
                                  ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.wMin),
                        Row(
                          children: [
                            SizedBox(
                                width: 454.wMin,
                                child: Text(
                                  '来源: ${data.contentDTOS?.first.sourceUrl ?? ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 18.wMin, color: const Color(0xFF767E95)),
                                )),
                            SizedBox(width: 15.wMin),
                            GestureDetector(
                                onTap: () async {
                                  if (data.contentDTOS?.first.sourceUrl == null) return;
                                  await launchUrl(Uri.parse(data.contentDTOS!.first.sourceUrl!), mode: LaunchMode.externalApplication);
                                },
                                child: Text('打开链接',
                                    style: TextStyle(
                                        fontSize: 20.wMin, decoration: TextDecoration.underline, decorationColor: const Color(0xFFBAC0CC), color: const Color(0xFFBAC0CC)))),
                            SizedBox(width: 8.wMin),
                            GestureDetector(
                                onTap: () {
                                  if (data.contentDTOS?.first.sourceUrl == null) return;
                                  Clipboard.setData(ClipboardData(text: data.contentDTOS!.first.sourceUrl!)).then((_) {
                                    ToastUtils.showToast(text: '复制成功', type: ToastType.success);
                                  });
                                },
                                child: Text('复制链接',
                                    style: TextStyle(
                                        fontSize: 20.wMin, decoration: TextDecoration.underline, decorationColor: const Color(0xFFBAC0CC), color: const Color(0xFFBAC0CC)))),
                          ],
                        ),
                        SizedBox(height: 8.wMin),
                        Row(
                          children: [
                            Text('2025/12/17 00:00:40', style: TextStyle(fontSize: 18.wMin, color: const Color(0xFF767E95))),
                            const Spacer(),
                            Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x1FFF781F),
                                  borderRadius: BorderRadius.circular(4.wMin),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
                                child: Text(
                                  "文章待审核:$audioStartFalseCount",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.wMin, color: const Color(0xFFFF781F)),
                                )),
                            SizedBox(width: 8.wMin),
                            Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x1F63DE77),
                                  borderRadius: BorderRadius.circular(4.wMin),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
                                child: Text(
                                  "文章已审核:$audioStartTrueCount",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.wMin, color: const Color(0xFF63DE77)),
                                )),
                            SizedBox(width: 8.wMin),
                            Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF353E5C),
                                  borderRadius: BorderRadius.circular(4.wMin),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
                                child: Text(
                                  '未生成音频:$audioStatusNullCount',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.wMin, color: const Color(0xFFFFFFFF)),
                                )),
                            SizedBox(width: 8.wMin),
                            Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x1F2388FF),
                                  borderRadius: BorderRadius.circular(4.wMin),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
                                child: Text(
                                  "音频生成中:$audioStatusStartCount",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.wMin, color: const Color(0xFF2388FF)),
                                )),
                            SizedBox(width: 8.wMin),
                            Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x1F2388FF),
                                  borderRadius: BorderRadius.circular(4.wMin),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
                                child: Text(
                                  "音频待审核:$audioStatusFinishCount",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.wMin, color: const Color(0xFFFF781F)),
                                )),
                            SizedBox(width: 8.wMin),
                            Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x1F63DE77),
                                  borderRadius: BorderRadius.circular(4.wMin),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
                                child: Text(
                                  "音频已审核:$audioStatusReviewCount",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.wMin, color: const Color(0xFF63DE77)),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: Container(),
                  secondChild: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.wMin),
                    child: _expansionItem(data, data.contentDTOS ?? <ArticleEntity>[]),
                  ),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _expansionItem(ManageSubscribeGroupRevealItem? data, List<ArticleEntity> items) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 754 / 210,
        mainAxisSpacing: 20.wMin,
        crossAxisSpacing: 20.wMin,
      ),
      itemBuilder: (context, gridIndex) {
        var cardData = items[gridIndex];
        return subCard(data, cardData, items, context);
      },
    );
  }

  Widget subCard(ManageSubscribeGroupRevealItem? data, ArticleEntity item, List<ArticleEntity> items, BuildContext context) {
    return Obx(() {
      final ManageSettingController settingController = Get.find<ManageSettingController>();

      String? imageUrl = item.relationImage?.imageUrl;
      if (settingController.defaultResources.value == ResourceTypeEnum.video) {
        imageUrl = item.relationVideo?.firstImageUrl;
      }

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF26292A),
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TapScaleWidget(
                    onTap: () {
                      if (settingController.defaultResources.value == ResourceTypeEnum.video) {
                        ShowBigResourceDialog.showVideo(
                          context: context,
                          relationVideo: item.relationVideo,
                        );
                      } else {
                        if (imageUrl == null) return;
                        ShowBigResourceDialog.showImage(
                          context: context,
                          imageUrls: [imageUrl],
                        );
                      }
                    },
                    sclae: 1,
                    child: CachedImageWidget(
                      imageUrl ?? '',
                      errorWidget: buildEmptyWidget(),
                      placeholder: buildLoadingWidget(),
                    ),
                  ),
                  Visibility(
                    visible: settingController.defaultResources.value == ResourceTypeEnum.video && imageUrl != null,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        width: 80.wMin,
                        height: 80.wMin,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 42.wMin,
                              ),
                            ),
                            Positioned(
                              bottom: 2.wMin,
                              child: Text(
                                "${item.relationVideo?.duration ?? 0}s",
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10.wMin,
                    bottom: 10.wMin,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 1.wMin),
                      decoration: BoxDecoration(color: item.isLaunch ?? false ? const Color(0xFF63DE77) : const Color(0xFFE11D48)),
                      child: Text(item.isLaunch ?? false ? '上架' : '下架', style: TextStyle(color: Colors.white, fontSize: 18.wMin)),
                    ),
                  ),
                  Positioned(
                    left: 10.wMin,
                    top: 10.wMin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: item.contentId.toString())).then((_) {
                              ToastUtils.showToast(text: '复制成功', type: ToastType.success);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 1.wMin),
                            decoration: BoxDecoration(color: const Color(0xCC141828), borderRadius: BorderRadius.circular(5.wMin)),
                            child: Text("id:${item.contentId}", style: TextStyle(color: Colors.white, fontSize: 18.wMin)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 4.wMin,
                    top: 4.wMin,
                    child: KnowledgeVideoToolVuttonsWidget(
                      uid: item.contentId,
                      type: "EN_REVEAL",
                      relationImage: item.relationImage,
                      relationVideo: item.relationVideo,
                      onRefresh: () {
                        controller.initData();
                      },
                    ),
                  ),
                  Positioned(
                    left: 4.wMin,
                    bottom: 4.wMin,
                    child: Visibility(
                      visible: settingController.defaultResources.value == ResourceTypeEnum.video && imageUrl != null,
                      child: ManageAssStatusWidget(
                        assState: item.relationVideo?.assState,
                        assTranslateState: item.relationVideo?.assTranslateState,
                        videoId: item.relationVideo?.videoId,
                        assId: item.relationVideo?.assId,
                        onRefresh: () {
                          controller.initData();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.wMin),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(0, 8.wMin, 8.wMin, 8.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 3.5.wMin, horizontal: 8.wMin),
                                decoration:
                                    BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: StatusUtils.getDifficultyBackgroundColor(item.difficulty!['max']).color2),
                                child: Text(controller.difficultyList[item.difficulty['max']],
                                    style: TextStyle(color: AppTheme.cInverseTextLight, fontSize: 18.wMin, fontWeight: FontWeight.w500)),
                              ),
                              SizedBox(width: 6.wMin),
                              _headTag(controller.revealData.value.contentCollection?.themeStyle ?? [], getGrene(controller.revealData.value.revealThemeName ?? [], 'zh')),
                              SizedBox(width: 6.wMin),
                              _headTag(controller.revealData.value.contentCollection?.genreStyle ?? [], getGrene(controller.revealData.value.revealGenreName ?? [], 'zh')),
                              SizedBox(width: 6.wMin),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 3.5.wMin, horizontal: 8.wMin),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFF353E5C)),
                                child: Text("字数: ${item.wordCount}", style: TextStyle(fontSize: 18.wMin, color: Colors.white)),
                              ),
                              const Spacer(),
                              ManageAuthBoxWidget(
                                authCodes: const [
                                  ManageAuthCode.enRevealsDelect,
                                ],
                                child: GestureDetector(
                                    onTap: () {
                                      controller.deleteArticle(item.contentId, item.title ?? "");
                                    },
                                    child: SvgPicture.asset('assets/svg/public/icon_delete.svg',
                                        colorFilter: ColorFilter.mode(AppTheme.cFeedbackErrorIcon, BlendMode.srcIn), width: 32.wMin, height: 32.wMin)),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.wMin),
                          Text(
                            '${item.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          // Text(
                          //   item.content ?? '',
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: TextStyle(
                          //     fontSize: 18.wMin,
                          //     fontWeight: FontWeight.w400,
                          //     color: const Color(0xFFACB5BC),
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          // ),
                          // SizedBox(height: 8.wMin),
                          SizedBox(
                            height: 24.wMin,
                            child: _statusBar(item),
                          ),
                          SizedBox(height: 8.wMin),
                          ManageEnKnowledgeAudioListWidget(
                            audioList: item.audioList,
                            contentType: "EN_REVEAL",
                            contentId: item.contentId,
                            onRefreshServiceData: controller.initData,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  _operators(context, data, item, items)
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _headTag(List<ThemeTextStyleEntity> txtStyle, String txt) {
    final themeText = StyleUtils.getCurrentThemeText(txtStyle);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.5.wMin, horizontal: 8.wMin),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: ColorUtils.parseColor(themeText?.backgroundColor)),
      child: Text(txt, style: TextStyle(fontSize: 18.wMin, color: ColorUtils.parseColor(themeText?.color))),
    );
  }

  Widget _statusBar(ArticleEntity item) {
    return Row(children: [
      Container(
          decoration: BoxDecoration(
            color: item.isAudioStart ?? false ? const Color(0x1F63DE77) : const Color(0x1FFF781F),
            borderRadius: BorderRadius.circular(4.wMin),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
          child: Text(
            item.isAudioStart ?? false ? "文章已审核" : "文章待审核",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.wMin, color: item.isAudioStart ?? false ? const Color(0xFF63DE77) : const Color(0xFFFF781F)),
          )),
      SizedBox(width: 4.wMin),
      Container(
          decoration: BoxDecoration(
            color: item.audioStatus == null
                ? const Color(0xFF353E5C)
                : item.audioStatus == "AUDIO_START"
                    ? const Color(0x1F2388FF)
                    : item.audioStatus == "AUDIO_FINISH"
                        ? const Color(0x1FFF781F)
                        : const Color(0x1F63DE77),
            borderRadius: BorderRadius.circular(4.wMin),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
          child: Text(
            item.audioStatus == null
                ? '未生成音频'
                : item.audioStatus == "AUDIO_START"
                    ? "音频生成中"
                    : item.audioStatus == "AUDIO_FINISH"
                        ? "音频待审核"
                        : "音频已审核",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12.wMin,
                color: item.audioStatus == null
                    ? const Color(0xFFFFFFFF)
                    : item.audioStatus == "AUDIO_START"
                        ? const Color(0xFF2388FF)
                        : item.audioStatus == "AUDIO_FINISH"
                            ? const Color(0xFFFF781F)
                            : const Color(0xFF63DE77)),
          )),
      SizedBox(width: 4.wMin),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF353E5C),
          borderRadius: BorderRadius.circular(4.wMin),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
        child: Text(
          item.calendarType == null
              ? "未设置推送时间"
              : item.calendarType == "IMMEDIATELY"
                  ? '立即推送'
                  : item.calendarType == "LUNAR"
                      ? '农历:${_formatPublishDate(item.publishedDate)}'
                      : '公历:${_formatPublishDate(item.publishedDate)}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.wMin, color: Colors.white),
        ),
      ),
      SizedBox(width: 4.wMin),
      Container(
        decoration: BoxDecoration(
          color: (item.normalExerciseNum ?? 0) == 0 ? const Color(0xFF353E5C) : const Color(0x1FFF781F),
          borderRadius: BorderRadius.circular(4.wMin),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
        child: Text(
          "已上架${item.normalExerciseNum ?? 0}题",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.wMin,
            color: (item.normalExerciseNum ?? 0) == 0 ? Colors.white : const Color(0xFF63DE77),
          ),
        ),
      ),
    ]);
  }

  Widget _operators(BuildContext context, ManageSubscribeGroupRevealItem? data, ArticleEntity article, List<ArticleEntity> items) {
    final ManageSettingController settingController = Get.find<ManageSettingController>();

    return Obx(() {
      return Row(
        children: [
          Visibility(
            visible: settingController.defaultResources.value == ResourceTypeEnum.image,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.enContentSemanticList, ManageAuthCode.adminContentReviewKnowledgeImages],
              margin: EdgeInsets.only(right: 6.wMin),
              child: _btn('图片', () {
                var knowledge = UnitKnowledgePointsEntityKnowledgeList(
                  uid: article.contentId,
                  contentId: article.contentId,
                  contentType: "EN_REVEAL",
                  semanticId: 0,
                );
                controller.adminEditImageFunction(knowledge);
              }),
            ),
          ),
          Visibility(
            visible: settingController.defaultResources.value == ResourceTypeEnum.video,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.enContentSemanticList, ManageAuthCode.videoReviewKnowledgeVideos],
              margin: EdgeInsets.only(right: 6.wMin),
              child: _btn('视频', () {
                var knowledge = UnitKnowledgePointsEntityKnowledgeList(
                  uid: article.contentId,
                  contentId: article.contentId,
                  contentType: "EN_REVEAL",
                  semanticId: 0,
                );
                controller.adminEditImageFunction(knowledge, quizOrImage: 2);
              }),
            ),
          ),
          ManageAuthBoxWidget(
            authCodes: const [
              ManageAuthCode.enContentSemanticList,
              ManageAuthCode.exerciseTypeList,
              ManageAuthCode.exercisePage,
            ],
            margin: EdgeInsets.only(right: 6.wMin),
            child: _btn('题目', () {
              var knowledge = UnitKnowledgePointsEntityKnowledgeList(
                uid: article.contentId,
                contentId: article.contentId,
                contentType: "EN_REVEAL",
                semanticId: 0,
              );
              controller.adminEditImageFunction(knowledge, quizOrImage: 0);
            }),
          ),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enRevealsEdit],
            margin: EdgeInsets.only(right: 6.wMin),
            child: _btn('文章', () {
              controller.editArticle(context, article);
            }),
          ),
          _btn('提示词', () {
              controller.showPrompt(context, article);
            }),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.audioExpressQuery],
            child: _btn('音频', () {
              var audioList = article.audioExpressionList?.toList() ?? [];
              if (audioList.length > 2) {
                audioList = audioList.sublist(0, 2);
              }
              controller.toAudioEditPage(audioList, 0, "EN_REVEAL");
            }),
          ),
          const Spacer(),
          _btn('播放', () {
            var params = [];
            for (var reveal in items) {
              params.add({"contentId": reveal.contentId, "contentType": "EN_REVEAL"});
            }
            /// 是否是管理端的标识 随机UUID
            String traceAdminHeader = const Uuid().v4();

            TagRoutes.toNamed(
              Routes.LISTEN_AND_READ,
              arguments: {
                "contentId": article.contentId,
                "contentType": "EN_REVEAL",
                "contents": params,
                "traceAdminHeader": traceAdminHeader,
              },
            );
          }, needArrow: true)
        ],
      );
    });
  }

  Widget _btn(String txt, Function() onTap, {bool needArrow = false}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(99.wMin), color: const Color(0x33FFFFFF)),
          padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
          child: Row(
            children: [
              Text(txt, style: TextStyle(color: Colors.white, fontSize: 18.wMin)),
              if (needArrow)
                SvgPicture.asset('assets/svg/user_center/icon_chevron_right1.svg',
                    width: 20.wMin, height: 20.wMin, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn))
            ],
          )),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gaps.getHeight(20.wh),
        Row(
          children: [
            Gaps.getWidth(24.ww),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.enRevealsCreate],
              child: TopTabBarWidget(
                index: 0,
                title: '添加',
                leftIcon: Assets.manageIconAdd,
                isSelected: false,
                onTap: (int index) {
                  controller.add();
                },
              ),
            ),
            Gaps.getWidth(12.ww),
            Builder(builder: (sortContext) {
              return TopTabBarWidget(
                index: 1,
                title: '排序',
                leftIcon: Assets.manageIconSort,
                isSelected: false,
                onTap: (int index) {
                  controller.sortCourse(sortContext);
                },
              );
            }),
            Gaps.getWidth(12.ww),
            Builder(builder: (filterContext) {
              return TopTabBarWidget(
                index: 2,
                title: '筛选',
                leftIcon: Assets.manageIconFilter,
                rightIcon: Assets.manageIconArrowDown,
                isSelected: false,
                onTap: (int index) {
                  controller.showFilter(filterContext);
                },
              );
            }),
            const Spacer(),
            _toggle(),
            SizedBox(width: 12.ww),
            GestureDetector(
              onTap: () {
                controller.showContentChecked();
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8.wMin),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFFFF781F)),
                child: Text('待审核文章${controller.checkedContentNum}篇', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
              ),
            ),
            SizedBox(width: 12.ww),
            GestureDetector(
              onTap: () {
                controller.showAudioChecked();
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8.wMin),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFF2388FF)),
                child: Text('待审核音频${controller.checkedAudioNum.value}个', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
              ),
            ),
            Gaps.getWidth(24.ww),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        SizedBox(width: 24.ww),
        SearchWidget(
          width: 160.ww,
          height: 42.wh,
          hintText: 'uid',
          onChanged: (String value) {
            controller.onSetId(value);
          },
          onSubmitted: (String value) {
            controller.onSetId(value, isSubmit: true);
          },
        ),
        Gaps.getWidth(12.ww),
        SearchWidget(
          width: 260.ww,
          height: 42.wh,
          hintText: '文章标题',
          onChanged: (String value) {
            controller.onSetName(value);
          },
          onSubmitted: (String value) {
            controller.onSetName(value, isSubmit: true);
          },
        ),
        Gaps.getWidth(12.ww),
        SearchWidget(
          width: 260.ww,
          height: 42.wh,
          hintText: '分组标题',
          onChanged: (String value) {
            controller.onSetGroup(value);
          },
          onSubmitted: (String value) {
            controller.onSetGroup(value, isSubmit: true);
          },
        ),
        Gaps.getWidth(12.ww),
        SearchWidget(
          width: 260.ww,
          height: 42.wh,
          controller: controller.collectionIdController,
          hintText: '专栏ID',
          onChanged: (String value) {
            controller.onSetCollectionId(value);
          },
          onSubmitted: (String value) {
            controller.onSetCollectionId(value, isSubmit: true);
          },
        ),
        const Spacer(),
        Obx(() {
          final int pageSize = controller.pageSize.value;
          final int current = controller.currentPage.value;
          final int totalPages = controller.totalPages;
          final List<int> pages = controller.buildVisiblePages();

          return Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                decoration: BoxDecoration(
                  color: const Color(0xFF26292A),
                  borderRadius: BorderRadius.circular(4.wMin),
                ),
                child: DropdownButton<int>(
                  value: pageSize,
                  dropdownColor: const Color(0xFF26292A),
                  underline: const SizedBox.shrink(),
                  iconEnabledColor: Colors.white,
                  isDense: true,
                  iconSize: 14.wMin,
                  style: TextStyle(color: Colors.white, fontSize: 14.wMin),
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
              ..._buildPageButtons(pages, current, controller),
              _pageButton(
                label: '>',
                enabled: current < totalPages,
                isActive: false,
                onTap: controller.goNextPage,
              ),
              SizedBox(width: 12.wMin),
              Text('前往', style: TextStyle(color: Colors.white, fontSize: 14.wMin)),
              SizedBox(width: 2.wMin),
              SizedBox(
                width: 45.wMin,
                child: TextField(
                  controller: controller.pageJumpController,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14.wMin),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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
              Text('页', style: TextStyle(color: Colors.white, fontSize: 14.wMin)),
            ],
          );
        }),
        SizedBox(width: 24.ww)
      ],
    );
  }

  Widget _pageButton({
    required String label,
    required bool enabled,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color bg = isActive ? const Color(0xFF38405F) : const Color(0xFF26292A);
    final Color fg = enabled ? Colors.white : const Color(0xFF4B5563);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.wMin),
        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6.wMin),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 14.wMin, color: fg),
        ),
      ),
    );
  }

  List<Widget> _buildPageButtons(
    List<int> pages,
    int current,
    SubscribeListeningListcardController controller,
  ) {
    final List<Widget> widgets = [];
    for (int i = 0; i < pages.length; i++) {
      final int page = pages[i];

      if (i > 0 && pages[i] - pages[i - 1] > 1) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.wMin),
            child: Text(
              '...',
              style: TextStyle(color: Colors.white, fontSize: 14.wMin),
            ),
          ),
        );
      }

      widgets.add(
        _pageButton(
          label: page.toString(),
          enabled: true,
          isActive: page == current,
          onTap: () => controller.goToPage(page),
        ),
      );
    }
    return widgets;
  }

  Widget _toggle() {
    return Row(children: [
      GestureDetector(
        onTap: () {
          if (controller.revealData.value.enGroupRevealContents == null) return;
          controller.expandedIndexSet
            ..clear()
            ..addAll(List.generate(controller.revealData.value.enGroupRevealContents!.datas!.length, (index) => index));
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: const Color(0xFF26292A),
          ),
          child: Text(
            '全部展开',
            style: TextStyle(fontSize: 14.wMin, color: Colors.white),
          ),
        ),
      ),
      SizedBox(width: 8.ww),
      GestureDetector(
        onTap: () {
          controller.expandedIndexSet.clear();
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: const Color(0xFF26292A),
          ),
          child: Text(
            '全部收起',
            style: TextStyle(fontSize: 14.wMin, color: Colors.white),
          ),
        ),
      )
    ]);
  }

  String getGrene(List<ManageSubscribeNameItem> item, String condition, {bool ignore = false}) {
    var systemCondition = LangPreference.fromRawValue(UserStore.to.userInfo.value.config?.extensionConfig!.translationType ?? '').langCode;
    if (systemCondition.isNotEmpty && !ignore) {
      condition = systemCondition;
    }
    for (var glossItem in item) {
      if (glossItem.lang == condition) {
        return glossItem.text!;
      }
    }
    return '';
  }

  String _formatPublishDate(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    final dt = DateTime.tryParse(value);
    if (dt == null) {
      return value;
    }
    final String mm = dt.month.toString().padLeft(2, '0');
    final String dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd';
  }

  String format(String s) {
    final parts = s.split('_');
    if (parts.length <= 1) return s;
    final kept = parts.sublist(0, parts.length - 1);

    String cap(String x) => x.isEmpty ? x : x[0].toUpperCase() + x.substring(1);

    return kept.map(cap).join(' ');
  }
}
