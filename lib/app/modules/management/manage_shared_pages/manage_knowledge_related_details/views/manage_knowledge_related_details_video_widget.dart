
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/stores/user.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../controllers/manage_knowledge_related_details_controller.dart';

class ManageLnowledgeRelatedDetailsVideoWidget extends StatelessWidget {
  final String controllerTag;
  const ManageLnowledgeRelatedDetailsVideoWidget({super.key, required this.controllerTag});

  ManageKnowledgeRelatedDetailsController get controller =>  Get.find<ManageKnowledgeRelatedDetailsController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            _buildVideoTypeList(),
            Expanded(child: _buildVideoListWidget(context)),
          ],
        ),

        Obx((){
          if(!controller.loading.value){
            return const SizedBox.shrink();
          }
          return Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            child: const CircularProgressIndicator(),
          );
        }),

      ],
    );
  }



  /// 视频分类列表
  Widget _buildVideoTypeList() {
    return Container(
      width: 280.wMin,
      padding: EdgeInsets.only(top: 24.wMin),
      decoration: BoxDecoration(
        color: const Color(0xff19213D).withValues(alpha: 0.6),
        border: Border(
          right: BorderSide(
            color: const Color(0xff353E5C),
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.wMin,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            child: Text(
              "视频列表",
              style: TextStyle(
                fontSize: 18.wMin,
                color: const Color(0xffFFFFFF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: 24.wMin,
                left: 24.wMin,
                right: 24.wMin,
              ),
              child: Obx((){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10.wMin,
                  children: [
                    TapScaleWidget(
                      onTap: () {
                        controller.changeVideoClass(-1);
                      },
                      sclae: 1.01,
                      child: Container(
                        height: 40.wMin,
                        padding: EdgeInsets.all(6.wMin),
                        decoration: BoxDecoration(
                          color: controller.videoSelectStyleId.value == -1 ? const Color(0xFF2388FF) : const Color(0xFF353E5C),
                          borderRadius: BorderRadius.circular(8.wMin),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "全部",
                              style: TextStyle(
                                color: controller.videoSelectStyleId.value == -1 ? Colors.white : Colors.white70, 
                                fontSize: 18.wMin,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              height: 28.wMin,
                              width: 28.wMin,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, 
                                color: controller.videoSelectStyleId.value == -1 ? const Color(0xFF19213D) : Colors.transparent,
                              ),
                              child: Text(
                                controller.videoCount.value.toString(),
                                style: TextStyle(color: Colors.white, fontSize: 14.wMin),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...List.generate(controller.videoList.length, (index){
                      return _buildVideoTypeGroupListWidget(controller.videoList[index]);
                    }),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTypeGroupListWidget(EnKnowledgeVideoEntityStyleGroups group){
    List<EnKnowledgeVideoEntityStyleGroupsCountryGroups?> countryGroups = group.countryGroups??[];

    int count = 0;
    for(var item in countryGroups){
      if(item == null) continue;
      count += item.videoCount??0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.wMin),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.styleTitle??"",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),

              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),

              SizedBox(width: 10.wMin),
              
            ],
          ),
        ),

        Column(
          spacing: 6.wMin,
          children: List.generate(countryGroups.length, (index){
            return _buildVideoTypeGroupListItemWidget(countryGroups[index]);
          }),
        ),

      ],
    );
  }

  Widget _buildVideoTypeGroupListItemWidget(EnKnowledgeVideoEntityStyleGroupsCountryGroups? item){
    bool selected = controller.videoSelectStyleId.value == item?.styleId;
    return TapScaleWidget(
      onTap: () {
        controller.changeVideoClass(item?.styleId);
      },
      sclae: 1.01,
      child: Container(
        height: 40.wMin,
        padding: EdgeInsets.all(6.wMin),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2388FF) : const Color(0xFF353E5C),
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 20.wMin,
              child: CachedImageWidget(
                item?.iconUrl??"",
                placeholder: buildEmptyWidget(),
                errorWidget: buildEmptyWidget(),
              ),
            ),
            SizedBox(width: 4.wMin),
            Text(
              item?.country??"",
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70, 
                fontSize: 18.wMin,
              ),
            ),
            const Spacer(),
            Container(
              height: 28.wMin,
              width: 28.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? const Color(0xFF19213D) : Colors.transparent),
              child: Text(
                '${item?.videoCount ?? (item?.videos?.length ?? 0)}',
                style: TextStyle(color: Colors.white, fontSize: 14.wMin),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoListWidget(BuildContext context){

    return Obx((){
      return Stack(
        children: [

          GridView.builder(
            padding: EdgeInsets.all(38.wMin) + EdgeInsets.only(bottom: 100.wMin),
            itemCount: controller.videoShowList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 24.wMin,
              mainAxisSpacing: 24.wMin,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              return _buildVideoListItemWidget(context, controller.videoShowList[index]);
            },
          ),

          Positioned(
            right: 16.wMin,
            bottom: 16.wMin,
            child: _buildBottomButtonsWidget(context),
          ),

        ],
      );
    });
  }


  Widget _buildBottomButtonsWidget(BuildContext context){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: UserStore.to.rolePermissions.value.userIsVideoReviewer || UserStore.to.rolePermissions.value.userIsVideoSuperReviewer,
          child: ButtonWidget(
            text: "审核视频 (${controller.pendingVideoReviewCount.value}个)",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            height: 56.wMin,
            borderRadius: 4.wMin,
            color: AppTheme.cSurfaceWarning.color,
            fontSize: 18.wMin,
            sclae: 1.05,
            onTap: () {
              controller.toReviewVideo();
            },
          ),
        ),

        Visibility(
          visible: UserStore.to.rolePermissions.value.userIsAssReviewer || UserStore.to.rolePermissions.value.userIsAssSuperReviewer,
          child: Container(
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "待审核字幕 ${controller.assPendingReviewIds.length} 个",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 56.wMin,
              borderRadius: 4.wMin,
              color: AppTheme.cSurfaceWarning.color,
              fontSize: 18.wMin,
              sclae: 1.05,
              onTap: () {
                controller.toReviewVideoAss();
              },
            ),
          ),
        ),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.videoReviewGenerateFrameStart, ManageAuthCode.videoReviewGenerateStartEndFrames],
          isAny: true,
          margin: EdgeInsets.only(left: 12.wMin),
          child: ButtonWidget(
            text: "新建视频",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            height: 56.wMin,
            borderRadius: 4.wMin,
            color: AppTheme.cSurfaceInfo.color,
            fontSize: 18.wMin,
            sclae: 1.05,
            onTap: () {
              controller.crtateVideoDialog(context);
            },
          ),
        ),

      ],
    );
  }



  Widget _buildVideoListItemWidget(BuildContext context, EnKnowledgeVideoEntityStyleGroupsCountryGroupsVideos data){
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.wMin),
      child: Stack(
        alignment: Alignment.center,
        children: [

          Positioned.fill(
            child: TapScaleWidget(
              onTap: () {
                controller.toVideoDetils(data.videoRelationId);
              },
              sclae: 1,
              child: CachedImageWidget(
                data.firstImageUrl??"",
                errorWidget: buildEmptyWidget(),
                placeholder: buildLoadingWidget(),
                fadeInDuration: Duration.zero,
              ),
            ),
          ),

          IgnorePointer(
            ignoring: true,
            child: Container(
              width: 80.wMin,
              height: 80.wMin,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 46.wMin,
              ),
            ),
          ),

          Positioned(
            top: 6.wMin,
            left: 6.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ManageTagFS16Widget(
                  tag: data.styleTitle,
                  fontColor: Colors.white,
                  bgColor: const Color(0xff1DA1F2).withValues(alpha: 0.8),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4.wMin),
                  padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.wMin),
                    color: const Color(0xCC393F5A),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22.wMin,
                        child: CachedImageWidget(
                          data.iconUrl ?? "",
                          errorWidget: buildEmptyWidget(),
                          placeholder: buildEmptyWidget(),
                        ),
                      ),
                      SizedBox(width: 4.wMin),
                      Text(
                        data.localeTitle ?? '',
                        style: TextStyle(color: Colors.white, fontSize: 16.wMin),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.wMin),
                ManageTagFS16Widget(
                  tag: "id:${data.videoId??''}",
                  fontColor: Colors.white,
                  bgColor: const Color(0xCC393F5A),
                ),
                Visibility(
                  visible: data.prompt != null,
                  child: Container(
                    margin: EdgeInsets.only(top: 4.wMin),
                    child: ButtonWidget(
                      text: "prompt",
                      borderRadius: 4.wMin,
                      height: 28.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                      fontSize: 16.wMin,
                      sclae: 1.05,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Material(
                                type: MaterialType.transparency,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      width: 800.wMin,
                                      padding: EdgeInsets.all(24.wMin),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1D1D1D),
                                        borderRadius: BorderRadius.circular(12.wMin),
                                      ),
                                      child: SelectableText(
                                        data.prompt ?? '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.wMin,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 4.wMin),
                  padding: EdgeInsets.all(2.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.wMin),
                    color: Colors.black.withValues(alpha: 0.9),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${data.duration??0}s",
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 4.wMin),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.wMin),
                          color: AppTheme.cSurfaceInfo.color.withValues(alpha: 0.9),
                        ),
                        child: Text(
                          "${data.startSeconds??0}s - ${data.endSeconds??0}s",
                          style: TextStyle(
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          Positioned(
            top: 6.wMin,
            right: 6.wMin,
            child: Row(
              children: [
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.videoReviewVideoTakedown],
                  child: _buildMiniActionButton(
                    title: '下架',
                    color: const Color(0xFFFF2D46),
                    onTap: () {
                      controller.downVideo(context, data.videoRelationId);
                    },
                  ),
                ),

                TapScaleWidget(
                  onTap: () {
                    controller.toVideoDetils(data.videoRelationId);
                  },
                  sclae: 1.1,
                  child: Container(
                    margin: EdgeInsets.only(left: 10.wMin),
                    width: 36.wMin,
                    height: 36.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.wMin),
                      color: AppTheme.cInverseOverlay2.color,
                      border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                    ),
                    child: SvgPicture.asset(
                      data.locked == true ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                      width: 18.wMin,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 6.wMin,
            bottom: 6.wMin,
            child: ManageAssStatusWidget(
              assState: data.assState,
              assTranslateState: data.assTranslateState,
              videoId: data.videoId,
              assId: data.assId,
              onRefresh: () {
                controller.fetchVideoData();
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildMiniActionButton({required String title, required Color color, required VoidCallback onTap}) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4.wMin)),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }


}