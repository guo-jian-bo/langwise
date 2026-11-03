import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/manage_subscribe_entity.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/https/subscribe.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/manage_page_registry.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_subscribe_binding.dart';
import '../controllers/manage_subscribe_controller.dart';
import 'subscribe_pushsetting_dialog.dart';

class ManageSubscribeView extends GetView<ManageSubscribeController> {
  final String tagText;
  const ManageSubscribeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SUBSCRIBE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSubscribeView(tagText: tag),
      binding: ManageSubscribeBinding(tag: tag),
      routeName: Routes.MANAGE_SUBSCRIBE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: tagText,
      builder: (_) {
        return ManageScaffold(
          backgroundColor: const Color(0xFF050916),
          body: Obx(() => SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: RefreshIndicator(
                    onRefresh: controller.refreshList,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100 && notification is ScrollEndNotification) {
                          controller.getSubscribeList();
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 32.wMin, top: 32.wMin, bottom: 266.wMin),
                          alignment: Alignment.topCenter,
                          child: Wrap(
                            spacing: 24.wMin,
                            runSpacing: 32.wMin,
                            children: List.generate(controller.collections.length, (index) {
                              var item = controller.collections[index];
                              return _cardItem(context, item);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(bottom: 0, child: _searchBar()),
              ],
            ),
          )),
        );
      },
    );
  }

  Widget _cardItem(BuildContext context, ManageSubscribeEntity item) {
    String enTheme = "";
    if (item.themeName!.gloss != null) {
      for (final e in item.themeName!.gloss!) {
        if (e.lang == 'en') {
          enTheme = e.text ?? "";
          break;
        }
      }
    }

    String zhTheme = "";
    if (item.themeName!.gloss != null) {
      for (final e in item.themeName!.gloss!) {
        if (e.lang == 'zh') {
          zhTheme = e.text ?? "";
          break;
        }
      }
    }

    return Container(
      width: 372.wMin,
      height: 506.wMin,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(color: const Color(0x19213DCC), borderRadius: BorderRadius.circular(16.wMin)),
      child: Column(children: [
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.wMin),
            child: SizedBox(
              width: 340.wMin,
              height: 340.wMin,
              child: CachedImageWidget(
                item.avatarUrl ?? "",
                errorWidget: buildEmptyWidget(),
                placeholder: buildLoadingWidget(),
                fadeInDuration: Duration.zero,
              ),
            ),
          ),
          Container(
            width: 340.wMin,
            height: 340.wMin,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.6, 1], colors: [const Color(0x00000000), const Color(0xFF000000).withOpacity(0.7)]),
            ),
          ),
          Positioned(
            bottom: 16.wMin,
            left: 16.wMin,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(zhTheme, style: TextStyle(fontSize: 32.wMin, color: Colors.white)),
              Text(
                enTheme,
                style: TextStyle(fontSize: 18.wMin, color: Colors.white),
              )
            ]),
          ),
          Positioned(
            left: 10.wMin,
            top: 10.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8.wMin),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFF131617).withAlpha(64), backgroundBlendMode: BlendMode.overlay),
                  child: Text(getZhName(item.genreName!.gloss!),
                      style: TextStyle(fontSize: 14.wMin, shadows: [Shadow(blurRadius: 4.wMin, color: const Color(0x1A000000), offset: Offset(0, 2.wMin))], color: Colors.white)),
                ),
                SizedBox(height: 8.wMin),
                if (item.startNum! > 0)
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8.wMin),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFFFF781F)),
                    child: Text('正在生成任务${item.startNum}个', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                  ),
                if (item.finishNum! > 0)
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 8.wMin),
                    padding: EdgeInsets.all(8.wMin),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFFFF781F)),
                    child: Text('待审核文章${item.finishNum}篇', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                  ),
                if (item.audioStartNum! > 0)
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 8.wMin),
                    padding: EdgeInsets.all(8.wMin),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFF2388FF)),
                    child: Text('正在生成音频${item.audioStartNum}个', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                  ),
                if (item.audioFinishNum! > 0)
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 8.wMin),
                    padding: EdgeInsets.all(8.wMin),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFF2388FF)),
                    child: Text('待审核音频${item.audioFinishNum}个', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 10.wMin,
            top: 10.wMin,
            child: Column(
              children: [
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.contentCollectionUpdateAvatar],
                  margin: EdgeInsets.only(bottom: 10.wMin),
                  child: GestureDetector(
                    onTap: () {
                      controller.clearKeys();
                      _showUpdateImagesDialog(context, item);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8.wMin),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0x8019213D)),
                      child: Text('替换封面', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                    ),
                  ),
                ),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.contentCollectionUpdatePushType],
                  margin: EdgeInsets.only(bottom: 10.wMin),
                  child: GestureDetector(
                    onTap: () {
                      SubscribePushSettingDialog.show(collectionId: item.collectionId!, context: context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8.wMin),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0x8019213D)),
                      child: Text('更改推送方式', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
        SizedBox(height: 8.wMin),
        Container(
          width: 340.wMin,
          height: 78.wMin,
          decoration: BoxDecoration(color: const Color(0xFF22293C), borderRadius: BorderRadius.circular(8.wMin)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '${item.size}',
                  style: TextStyle(fontSize: 24.wMin, color: Colors.white),
                ),
                SizedBox(height: 2.wMin),
                Text(
                  '总文章',
                  style: TextStyle(fontSize: 14.wMin, color: Colors.white),
                )
              ]),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '${item.accessSize}',
                  style: TextStyle(fontSize: 24.wMin, color: Colors.white),
                ),
                SizedBox(height: 2.wMin),
                Text(
                  '已上架',
                  style: TextStyle(fontSize: 14.wMin, color: Colors.white),
                )
              ]),
            ],
          ),
        ),
        SizedBox(height: 8.wMin),
        Row(children: [
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enRevealsCreate],
            child: Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    // 跳转到创建内容页面
                    ManagePageRegistry.jumpTo(
                      Routes.MANAGE_SUBSCRIBE_CREATE,
                      arguments: {
                        'id': item.collectionId,
                        'themeZh': zhTheme,
                        'themeEn': enTheme,
                        'description': item.description,
                        'links': item.references,
                      },
                    ).then((v) {
                      if (v == true) {
                        controller.refreshList();
                      }
                    });
                  },
                  child: Container(
                    height: 40.wMin,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: const Color(0xFF2388FF)),
                    alignment: Alignment.center,
                    child: Text(
                      '创建',
                      style: TextStyle(fontSize: 14.wMin, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.wMin),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enRevealsPageGroupEnReveals],
            child: Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    // 跳转到文章列表页面
                    ManagePageRegistry.jumpTo(
                      Routes.MANAGE_SUBSCRIBE_LISTCARD,
                      arguments: {
                        'collectionId': item.collectionId,
                        'themeZh': zhTheme,
                        'themeEn': enTheme,
                        'description': item.description,
                        'links': item.references,
                      },
                    ).then((_) {
                      controller.refreshList();
                    });
                  },
                  child: Container(
                    height: 40.wMin,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: const Color(0xFF63DE77)),
                    alignment: Alignment.center,
                    child: Text(
                      '查看',
                      style: TextStyle(fontSize: 14.wMin, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ])
      ]),
    );
  }

  Widget _searchBar() {
    return Obx(() => Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 800.wMin,
        height: 80.wMin,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(36.wMin), color: Colors.black87, border: Border.all(color: const Color(0xFF4B5268))),
        child: Row(children: [
          SizedBox(width: 12.wMin),
          const Icon(
            Icons.search,
            color: Colors.white,
          ),
          SizedBox(width: 12.wMin),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onSubmitted: (v) {
                controller.refreshList();
              },
              onChanged: (v) {
                controller.theme.value = v;
              },
              decoration: const InputDecoration(hintText: '搜索主题...', border: InputBorder.none),
            ),
          ),
          SizedBox(width: 36.wMin),
        ]),
      ),
      SizedBox(height: 20.wMin),
      Container(
        width: 800.wMin,
        height: 80.wMin,
        padding: EdgeInsets.symmetric(vertical: 10.wMin),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(36.wMin), color: Colors.black87, border: Border.all(color: const Color(0xFF4B5268))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 12.wMin),
            Expanded(
              child: ListView(
                shrinkWrap: false,
                scrollDirection: Axis.horizontal,
                children: List.generate(controller.genres.length, (e) {
                  var barItem = controller.genres[e];
                  String txt = getZhName(barItem.name!);
                  return GestureDetector(
                    onTap: () {
                      if (controller.selectedIndex.value == e) {
                        controller.selectedIndex.value = -1;
                        controller.genre.value = '';
                      } else {
                        controller.selectedIndex.value = e;
                        controller.genre.value = getEnName(barItem.name!);
                      }
                      controller.refreshList();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 16.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36.wMin),
                        color: controller.selectedIndex.value == e ? const Color(0xFF0EA5E9) : AppTheme.cSurfaceTertiary.color,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            txt,
                            style: TextStyle(color: controller.selectedIndex.value == e ? Colors.white : AppTheme.cTextTertiary.color),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 24.wMin),
          ],
        ),
      ),
      SizedBox(height: 20.wMin),
    ]));
  }

  String getZhName(List items) {
    String str = "";
    for (final e in items) {
      if (e?.lang == 'zh') {
        str = e?.text ?? "";
        break;
      }
    }
    return str;
  }

  String getEnName(List items) {
    String str = "";
    for (final e in items) {
      if (e?.lang == 'en') {
        str = e?.text ?? "";
        break;
      }
    }
    return str;
  }

  void _showUpdateImagesDialog(BuildContext context, ManageSubscribeEntity item) {
    String? coverPreviewPath;
    String? bannerPreviewPath;
    bool isBannerNetWork = true;
    bool isCoverNetWork = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 720.wMin,
              padding: EdgeInsets.all(24.wMin),
              decoration: BoxDecoration(
                color: const Color(0xFF050916),
                borderRadius: BorderRadius.circular(16.wMin),
                border: Border.all(color: const Color(0xFF444B5F), width: 1.wMin),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  Widget buildCard({
                    required String title,
                    String? desc,
                    String? tip,
                    bool isNetwork = false,
                    required String? path,
                    required double imageHeight,
                    required VoidCallback onReplace,
                  }) {
                    return Container(
                      padding: EdgeInsets.all(16.wMin),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2234),
                        borderRadius: BorderRadius.circular(12.wMin),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                          ),
                          SizedBox(height: 8.wMin),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.wMin),
                                child: Container(
                                  color: const Color(0xFF22293C),
                                  width: 260.wMin,
                                  height: imageHeight,
                                  child: path == null
                                      ? Icon(
                                          Icons.image_outlined,
                                          size: 48.wMin,
                                          color: const Color(0xFFBAC0CC),
                                        )
                                      : isNetwork
                                          ? CachedImageWidget(path)
                                          : Image.file(File(path)),
                                ),
                              ),
                              SizedBox(width: 16.wMin),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16.wMin),
                                    SizedBox(
                                      width: 80.wMin,
                                      height: 40.wMin,
                                      child: GestureDetector(
                                        onTap: () {
                                          onReplace();
                                        },
                                        child: Container(
                                          width: 80.wMin,
                                          height: 40.wMin,
                                          decoration: BoxDecoration(color: const Color(0xFF353E5C), borderRadius: BorderRadius.circular(6.wMin)),
                                          alignment: Alignment.center,
                                          child: Text('更换', style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFACB4C0))),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '编辑封面设置',
                            style: TextStyle(fontSize: 18.wMin, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: Icon(
                              Icons.close,
                              size: 20.wMin,
                              color: const Color(0xFFBAC0CC),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.wMin),
                      buildCard(
                        title: '订阅详情卡片封面',
                        desc: '当前尺寸：720x236px',
                        tip: '格式支持：jpg, png',
                        path: bannerPreviewPath ?? item.taskAvatarUrl,
                        isNetwork: isBannerNetWork,
                        imageHeight: 120.wMin,
                        onReplace: () async {
                          final String? path = await controller.onAddBanner(dialogContext);
                          if (path != null) {
                            setState(() {
                              isBannerNetWork = false;
                              bannerPreviewPath = path;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16.wMin),
                      buildCard(
                        title: '专题卡片封面',
                        desc: '当前尺寸:340x340px',
                        tip: '格式支持：jpg, png',
                        path: coverPreviewPath ?? item.avatarUrl,
                        isNetwork: isCoverNetWork,
                        imageHeight: 260.wMin,
                        onReplace: () async {
                          final String? path = await controller.onAddCover(dialogContext);
                          if (path != null) {
                            setState(() {
                              isCoverNetWork = false;
                              coverPreviewPath = path;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 24.wMin),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
                              decoration: BoxDecoration(
                                color: const Color(0xFF465070),
                                borderRadius: BorderRadius.circular(6.wMin),
                              ),
                              alignment: Alignment.center,
                              child: Text('取消', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (coverPreviewPath == null && bannerPreviewPath == null) return;
                              await SubscribeRequest.updateCollectionAvatar(
                                collectionId: item.collectionId ?? 0,
                                avatar: controller.coverKey ?? '',
                                taskAvatar: controller.bannerKey ?? '',
                              );

                              Get.back();
                              await controller.refreshList();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2388FF),
                                borderRadius: BorderRadius.circular(6.wMin),
                              ),
                              alignment: Alignment.center,
                              child: Text('确认保存', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
