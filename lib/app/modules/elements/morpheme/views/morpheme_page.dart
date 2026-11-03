import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/lock_utils.dart';
import '../../common/elements_card_groove.dart';
import '../bindings/morpheme_binding.dart';
import '../controllers/morpheme_controller.dart';

class MorphemePage extends StatefulWidget {
  final String tagText;
  const MorphemePage({
    super.key,
    this.tagText = Routes.DICTIONARY_MORPHEME,
  });

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return Get.to<T>(
      () => MorphemePage(tagText: tag),
      binding: MorphemeBinding(tagText: tag),
      routeName: Routes.DICTIONARY_MORPHEME,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  State<MorphemePage> createState() => _MorphemePageState();
}

class _MorphemePageState extends State<MorphemePage> {
  late final MorphemeController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MorphemeController>(tag: widget.tagText)) {
      MorphemeBinding(tagText: widget.tagText).dependencies();
    }
    controller = Get.find<MorphemeController>(tag: widget.tagText);
  }

  @override
  void dispose() {
    if (Get.isRegistered<MorphemeController>(tag: widget.tagText)) {
      Get.delete<MorphemeController>(tag: widget.tagText, force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Obx(() {
          final bool hasLock =
              controller.rights.value.isLock || controller.rights.value.isNoRights;
          return Column(
            children: [
              _buildHeader(hasLock: hasLock),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: hasLock,
                        child: _buildBody(context, bottomInset: bottomInset),
                      ),
                    ),
                    Positioned(
                      left: 16.wMin,
                      right: 16.wMin,
                      bottom: bottomInset + 20.wMin,
                      child: IgnorePointer(
                        ignoring: hasLock,
                        child: _buildBottomBar(context),
                      ),
                    ),
                    if (hasLock)
                      Positioned.fill(
                        child: LockOverlayWidget(
                          rights: controller.rights.value,
                          showBack: false,
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader({required bool hasLock}) {
    return BreadcrumbWidget(
      actionWidget: IgnorePointer(
        ignoring: hasLock,
        child: Obx(() {
          final String? helpVideoUrl = controller.currentHelpVideoUrl;
          if ((helpVideoUrl ?? '').isEmpty) return const SizedBox();
          return HelpIVideoIconWidget(
            helpVideoUrl: helpVideoUrl,
            size: 40.wMin,
          );
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context, {required double bottomInset}) {
    if (controller.isLoading.value && controller.datas.isEmpty) {
      return const SizedBox();
    }
    if (controller.isNotData.value) {
      return const NotDataWidget(message: '这里还没有词素卡片哦');
    }
    return RefreshIndicator(
      onRefresh: () => controller.refreshList(showLoading: false),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 1000.wMin) {
            controller.loadMore();
          }
          return false;
        },
        child: GridView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.datas.length,
          padding: EdgeInsets.only(
            top: 12.wMin,
            bottom: 120.wMin + bottomInset,
            left: 90.wMin,
            right: 90.wMin,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 24.wMin,
            crossAxisSpacing: 24.wMin,
            childAspectRatio: 346 / 546,
          ),
          itemBuilder: (context, index) {
            return ElementsCardGroove(
              index: index,
              data: controller.datas[index],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return FilterStripWidget(
      width: MediaQuery.of(context).size.width - 32.wMin,
      searchs: {
        'content': FilterSearchsData(
          controller: controller.searchController,
          title: '搜索词素',
          hintText: controller.currentSearchHintText,
        ),
      },
      onSearch: controller.submitSearch,
      onReset: (_, __) {
        controller.searchController.clear();
        controller.submitSearch();
      },
    );
  }
}
