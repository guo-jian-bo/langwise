import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'controller.dart';
import 'state.dart';

class ImageModerationListPage extends StatelessWidget {
  const ImageModerationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageModerationListController>(
      id: ImageModerationListState.myReviewsId,
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppTheme.cBgPrimary,
          body: SafeArea(
              left: true,
              top: true,
              right: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackWidget(
                    title: '',
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 16.ww, right: 16.ww),
                      child: Text(
                        '我的审核列表',
                        style: TextStyle(
                          color: AppTheme.cTextPrimary,
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Gaps.getHeight(16.wh),
                  controller.state.myReviews.isEmpty
                      ? Center(
                          child: Text(
                            "当前无数据",
                            style: TextStyle(
                              color: AppTheme.cTextSecondary,
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Expanded(
                          child: EasyRefresh(
                          triggerAxis: Axis.vertical,
                          controller: controller.refreshController,
                          child: GridView.builder(
                            padding: EdgeInsets.only(left: 16.ww, right: 16.ww),
                            scrollDirection: Axis.vertical,
                            controller: controller.scrollController,
                            itemCount: controller.state.myReviews.length,
                            itemBuilder: (context, index) {
                              final item = controller.state.myReviews[index];
                              return ImageModerationWidget(
                                item: item,
                                index: index,
                                onTap: (int i, KnowledgePoint k) {
                                  controller.toKnowledgePointDetail(k);
                                },
                              );
                            },
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10.wMin,
                              mainAxisSpacing: 10.wh,
                              childAspectRatio: 368.ww / 128.wh,
                            ),
                          ),
                          onRefresh: () {
                            controller.onRefresh();
                          },
                          onLoad: () {
                            controller.onLoadMore();
                          },
                        ))
                ],
              )),
        );
      },
    );
  }
}
