import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/en_phrase_entity.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/entities/content_review_image_entities.dart';

import '../../../../../../common/stores/stores.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../dialog/dialogs.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_knowledge_related_details_binding.dart';
import '../controllers/manage_knowledge_related_details_controller.dart';
import 'manage_knowledge_related_details_exercise_widget.dart';
import 'manage_knowledge_related_details_video_widget.dart';

class ManageKnowledgeRelatedDetailsView extends GetView<ManageKnowledgeRelatedDetailsController> {
  final String tagText;
  const ManageKnowledgeRelatedDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageKnowledgeRelatedDetailsView(tagText: tag),
      binding: ManageKnowledgeRelatedDetailsBinding(tag: tag),
      routeName: Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ManageScaffold(
        appBar: AppBar(
          backgroundColor: const Color(0x8019213D),
          foregroundColor: const Color(0x8019213D),
          shadowColor: const Color(0x8019213D),
          surfaceTintColor: const Color(0x8019213D),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Obx(() {
            return Row(
              children: [
                SizedBox(width: 24.wMin),
                SelectableText(
                  controller.imagesData.value?.content ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 32.wMin),
                SelectableText(
                  'id：${controller.uid}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }),
        ),
        body: Obx(() {
          final semantics = controller.semantics;
          EnEntitySemantics? semanticsData;

          if (controller.selectedPosIndex.value < semantics.length) {
            semanticsData = semantics[controller.selectedPosIndex.value];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: controller.type == ElementsCardType.word.value || controller.type == ElementsCardType.phrase.value || controller.type == ElementsCardType.sentence.value,
                child: Container(
                  decoration: const BoxDecoration(color: Color(0x8019213D)),
                  padding: EdgeInsets.only(left: 32.wMin),
                  child: _buildPosTabs(semantics),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x8019213D),
                  border: Border(
                    bottom: BorderSide(width: 1.wMin, color: const Color(0xFF353E5C)),
                    top: BorderSide(width: 1.wMin, color: const Color(0xFF353E5C)),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 20.wMin, horizontal: 24.wMin),
                child: Row(
                  children: [
                    _buildSegmentSwitch(
                      questionCount: controller.exerciseCount.value,
                      imageCount: controller.imageCount.value,
                      videoCount: controller.videoCount.value,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        StatusTagDifficultyWidget(
                          difficulty: semanticsData?.difficulty,
                          language: semanticsData?.language ?? "en",
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                          height: 33.wMin,
                          alignment: Alignment.center,
                          fontSize: 16.wMin,
                        ),
                        SizedBox(width: 8.wMin),
                        ManageAuthBoxWidget(
                          authCodes: const [ManageAuthCode.unitKnowledgeCourseInfos],
                          child: TapScaleWidget(
                            sclae: 1,
                            onTap: () {
                              controller.openCourseList(semanticsData?.uid);
                            },
                            child: Row(
                              children: [
                                Visibility(
                                  visible: semanticsData?.in_course ?? false,
                                  child: Container(
                                    width: 27.wMin,
                                    height: 27.wMin,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                    child: SvgPicture.asset(
                                      'assets/svg/public/icon_check_w.svg',
                                      colorFilter: const ColorFilter.mode(Color(0xFF353E5C), BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.wMin),
                                Text(
                                  '在【${semanticsData?.in_course_cnt ?? 0}】课程',
                                  style: TextStyle(color: Colors.white, fontSize: 16.wMin),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 43.wMin),
                        Visibility(
                          visible: semanticsData?.uid != null && semanticsData?.uid != 0,
                          child: SelectableText(
                            'sid:  ${semanticsData?.uid ?? ''}',
                            style: TextStyle(color: Colors.white, fontSize: 16.wMin),
                          ),
                        ),
                        SizedBox(width: 43.wMin),
                        Visibility(
                          visible: controller.type == ElementsCardType.word.value ||
                              controller.type == ElementsCardType.phrase.value ||
                              controller.type == ElementsCardType.sentence.value,
                          child: ManageAuthBoxWidget(
                            authCodes: const [ManageAuthCode.enWordSemanticEdit],
                            child: TapScaleWidget(
                              onTap: () {
                                controller.editSemantic(context);
                              },
                              sclae: 1,
                              child: Container(
                                height: 54.wMin,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(11.wMin), color: const Color(0xFF353E5C)),
                                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                                child: Text("编辑语义", style: TextStyle(color: Colors.white, fontSize: 16.wMin)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.segmentIndex.value == 1) {
                    return _buildImagesWidget(context);
                  }else if(controller.segmentIndex.value == 2){
                    return ManageLnowledgeRelatedDetailsVideoWidget(controllerTag: tagText);
                  }
                  return ManageKnowledgeRelatedDetailsExerciseWidget(controllerTag: tagText);
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildImagesWidget(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = controller.imagesData.value;
      final styleGroups = data?.styleGroups ?? const <ContentReviewStyleGroup>[];
      return Stack(
        children: [
          Row(
            children: [
              SizedBox(
                width: 280.wMin,
                child: _buildLeftList(styleGroups),
              ),
              Expanded(
                child: _buildGrid(controller.currentImages),
              ),
            ],
          ),
          Positioned(
            right: 16.wMin,
            bottom: 16.wMin,
            child: Row(
              children: [
                Visibility(
                  visible: UserStore.to.rolePermissions.value.userIsImageReviewer || UserStore.to.rolePermissions.value.userIsImageSuperReviewer,
                  child: _buildCornerButton(
                    title: '待审核${controller.imagesData.value?.taskIds?.length ?? 0}个',
                    color: const Color(0xFFFF781F),
                    onTap: controller.openReviewedList,
                  ),
                ),
                SizedBox(width: 12.wMin),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.contentReviewImageCreate, ManageAuthCode.contentReviewImageCreateByPrompt],
                  child: _buildCornerButton(
                    title: '新建图片',
                    color: const Color(0xFF2388FF),
                    onTap: () async {
                      final config = controller.styleConfigV2.value;
                      if (config == null) {
                        ToastUtils.showToast(text: '风格配置加载中');
                        return;
                      }
                  
                      final res = await ImageConvertCreateDialog.show(
                        context: context,
                        title: '新建图片',
                        mode: ImageConvertCreateDialogMode.create,
                        data: config,
                        initialSelectedStyleIds: controller.currentSelectedStyleId == null ? const [] : [controller.currentSelectedStyleId!],
                        initialNumberOfImages: 4,
                      );
                      if (res == null) return;
                      if (res.tabIndex == 0) {
                        if(!ManageAuthUtils.isAuth(ManageAuthCode.contentReviewImageCreate)) return;
                        await controller.createNewImageWithSelection(styleIds: res.styleIds, numberOfImages: res.numberOfImages);
                      } else {
                        if(!ManageAuthUtils.isAuth(ManageAuthCode.contentReviewImageCreateByPrompt)) return;
                        await controller.createNewImageWithPrompt(styleIds: res.styleIds, numberOfImages: res.numberOfImages, prompt: res.prompt);
                      }
                    },
                  ),
                ),

                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.adminContentReviewImageUpload],
                  margin: EdgeInsets.only(left: 12.wMin),
                  child: _buildCornerButton(
                    title: '上传图片',
                    color: const Color(0xFF2388FF),
                    onTap: () async {
                      controller.imageUpload(context);
                    },
                  ),
                ),

              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPosTabs(List<EnEntitySemantics> semantics) {
    if (semantics.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 80.wMin,
      child: Obx(() {
        final selectedIndex = controller.selectedPosIndex.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: semantics.length,
          separatorBuilder: (_, __) => SizedBox(width: 20.wMin),
          itemBuilder: (context, index) {
            final item = semantics[index];
            final selected = index == selectedIndex;
            final title = (item.definition?.toString() ?? '').isNotEmpty ? (item.definition?.toString() ?? '') : item.uid.toString();
            return InkWell(
              onTap: () => controller.setSelectedPosIndex(index),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? const Color(0xff1e90ff) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: selected ? const Color(0xff1e90ff) : Colors.white,
                        fontSize: 18.wMin,
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TapScaleWidget(
                          onTap: () {
                            if(!ManageAuthUtils.isAuth(ManageAuthCode.unitKnowledgeCourseInfos)) return;
                            controller.openCourseList(item.uid);
                          },
                          sclae: 1.1,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                            color: Colors.transparent,
                            child: SvgPicture.asset(
                              'assets/svg/manage/yuyi.svg',
                              width: 24.wMin,
                              colorFilter: item.in_course ?? false ? null : const ColorFilter.mode(Color(0xFF767E95), BlendMode.srcIn),
                            ),
                          ),
                        ),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('题目', style: TextStyle(color: const Color(0xFFBAC0CC), fontSize: 16.wMin)),
                          SizedBox(width: 3.wMin),
                          Text('${item.exercise_cnt ?? 0}', style: TextStyle(color: Colors.white, fontSize: 16.wMin))
                        ]),
                        SizedBox(width: 12.wMin),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('图片', style: TextStyle(color: const Color(0xFFBAC0CC), fontSize: 16.wMin)),
                            SizedBox(width: 3.wMin),
                            Text('${item.image_cnt ?? 0}', style: TextStyle(color: Colors.white, fontSize: 16.wMin))
                          ],
                        ),
                        SizedBox(width: 12.wMin),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('视频', style: TextStyle(color: const Color(0xFFBAC0CC), fontSize: 16.wMin)),
                            SizedBox(width: 3.wMin),
                            Text('${item.video_cnt ?? 0}', style: TextStyle(color: Colors.white, fontSize: 16.wMin))
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildLeftList(List<ContentReviewStyleGroup> styleGroups) {
    if (styleGroups.isEmpty) {
      return Center(
        child: Text(
          '暂无分组',
          style: TextStyle(color: Colors.white70, fontSize: 14.wMin),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x8019213D),
        border: Border(right: BorderSide(width: 1.wMin, color: const Color(0xFF353E5C))),
      ),
      child: Obx(() {
        final selectedStyleIndex = controller.selectedStyleGroupIndex.value;
        final selectedCountryIndex = controller.selectedCountryGroupIndex.value;
        final total = styleGroups.fold<int>(0, (sum, sg) {
          final countries = sg.countryGroups ?? const <ContentReviewStyleCountryGroup>[];
          return sum +
              countries.fold<int>(0, (sum, cg) {
                final v = cg.imageCount ?? (cg.images?.length ?? 0);
                return sum + v;
              });
        });

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                controller.selectCountryGroup(styleIndex: -1, countryIndex: -1);
              },
              child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(32.wMin),
                  height: 41.wMin,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 6.wMin),
                  decoration: BoxDecoration(
                    color: selectedStyleIndex == -1 && selectedCountryIndex == -1 ? const Color(0xFF2388FF) : const Color(0xFF353E5C),
                    borderRadius: BorderRadius.circular(8.wMin),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('全部', style: TextStyle(color: Colors.white, fontSize: 16.wMin)),
                      Container(
                        height: 28.wMin,
                        width: 28.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: selectedStyleIndex == -1 && selectedCountryIndex == -1 ? const Color(0xFF19213D) : Colors.transparent),
                        child: Text(
                          '$total',
                          style: TextStyle(color: Colors.white, fontSize: 14.wMin),
                        ),
                      ),
                    ],
                  )),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(32.wMin, 0, 32.wMin, 32.wMin),
                itemCount: styleGroups.length,
                itemBuilder: (context, styleIndex) {
                  final sg = styleGroups[styleIndex];
                  final countries = sg.countryGroups ?? const <ContentReviewStyleCountryGroup>[];
                  final styleTitle = sg.styleTitle ?? sg.style ?? '';
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.wMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final total = countries.fold<int>(0, (sum, cg) {
                              final v = cg.imageCount ?? (cg.images?.length ?? 0);
                              return sum + v;
                            });

                            return Row(
                              children: [
                                SizedBox(width: 11.wMin),
                                Expanded(
                                  child: Text(
                                    styleTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Text(
                                  '$total张',
                                  style: TextStyle(color: const Color(0xFF767E95), fontSize: 16.wMin),
                                ),
                                SizedBox(width: 11.wMin)
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 11.wMin),
                        ...List.generate(countries.length, (countryIndex) {
                          final cg = countries[countryIndex];
                          final selected = (styleIndex == selectedStyleIndex) && (countryIndex == selectedCountryIndex);
                          return GestureDetector(
                            onTap: () => controller.selectCountryGroup(styleIndex: styleIndex, countryIndex: countryIndex),
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 11.wMin),
                              height: 41.wMin,
                              padding: EdgeInsets.all(6.wMin),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFF2388FF) : const Color(0xFF353E5C),
                                borderRadius: BorderRadius.circular(8.wMin),
                              ),
                              child: Row(
                                children: [
                                  Image.network(cg.iconUrl ?? '', errorBuilder: (ctx, _, StackTrace? trace) {
                                    return buildEmptyWidget();
                                  }, height: 22.wMin),
                                  SizedBox(width: 6.wMin),
                                  Expanded(
                                    child: Text(
                                      cg.country ?? '',
                                      style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 18.wMin),
                                    ),
                                  ),
                                  Container(
                                    height: 28.wMin,
                                    width: 28.wMin,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? const Color(0xFF19213D) : Colors.transparent),
                                    child: Text(
                                      '${cg.imageCount ?? (cg.images?.length ?? 0)}',
                                      style: TextStyle(color: Colors.white, fontSize: 14.wMin),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGrid(List<ContentReviewImage> images) {
    if (images.isEmpty) {
      return Center(
        child: Text(
          '暂无图片',
          style: TextStyle(color: Colors.white70, fontSize: 14.wMin),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(38.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 26.wMin,
        mainAxisSpacing: 26.wMin,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final img = images[index];
        final url = img.imageUrl ?? '';
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.wMin),
          child: Stack(
            children: [
              TapScaleWidget(
                onTap: () async{
                  bool res = await ManageLockBigImageDialog.show(
                    context: context, 
                    imageUrl: img.imageUrl,
                    relationImageId: img.semanticImageRelationId,
                    locked: img.locked,
                  );
                  if(!res) return;
                  controller.fetchImages();
                },
                sclae: 1,
                child: Image.network(
                  url,
                  errorBuilder: (context, error, stackTrace) {
                    return buildEmptyWidget();
                  },
                ),
              ),
              Positioned(
                left: 4.wMin,
                top: 4.wMin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(builder: (context) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (img.styleTitle != '')
                            Container(
                              margin: EdgeInsets.only(bottom: 6.wMin),
                              decoration: BoxDecoration(
                                color: const Color(0xCC1DA1F2),
                                borderRadius: BorderRadius.circular(4.wMin),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
                              child: Text(
                                img.styleTitle ?? '',
                                style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w600),
                              ),
                            ),
                          if (img.localeTitle != '')
                            Container(
                                margin: EdgeInsets.only(bottom: 8.wMin),
                                decoration: BoxDecoration(
                                  color: const Color(0xCC393F5A),
                                  borderRadius: BorderRadius.circular(4.wMin),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 22.wMin,
                                      child: Image.network(
                                        img.iconUrl ?? "",
                                        errorBuilder: (context, error, stackTrace) {
                                          return buildEmptyWidget();
                                        },
                                      ),
                                      
                                    ),
                                    SizedBox(width: 4.wMin),
                                    Text(
                                      img.localeTitle ?? '',
                                      style: TextStyle(color: Colors.white, fontSize: 12.wMin),
                                    ),
                                  ],
                                )),
                        ],
                      );
                    }),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xCC393F5A),
                        borderRadius: BorderRadius.circular(4.wMin),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
                      child: SelectableText(
                        "id: ${img.imageId?.toString() ?? ''}",
                        style: TextStyle(color: Colors.white, fontSize: 12.wMin),
                      ),
                    ),
                    SizedBox(height: 6.wMin),
                    Visibility(
                      visible: img.prompt != null,
                      child: ButtonWidget(
                        text: "prompt",
                        borderRadius: 4.wMin,
                        height: 28.wMin,
                        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                        fontSize: 12.wMin,
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
                                          img.prompt ?? '',
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
                  ],
                ),
              ),

              Positioned(
                right: 4.wMin,
                top: 4.wMin,
                child: Row(
                  children: [
                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.contentReviewImageTakedown],
                      child: _buildMiniActionButton(
                        title: '下架',
                        color: const Color(0xFFFF2D46),
                        onTap: () async {
                          await controller.takedownImage(context, img);
                        },
                      ),
                    ),
                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.contentReviewImageConvert],
                      margin: EdgeInsets.only(left: 8.wMin),
                      child: _buildMiniActionButton(
                        title: '转化',
                        color: const Color(0xFF9247FD),
                        onTap: () async {
                          final config = controller.styleConfigV2.value;
                          if (config == null) {
                            ToastUtils.showToast(text: '风格配置加载中');
                            return;
                          }
                      
                          final res = await ImageConvertCreateDialog.show(
                            context: context,
                            title: '转化风格-选择目标风格',
                            mode: ImageConvertCreateDialogMode.convert,
                            data: config,
                            initialNumberOfImages: 4,
                            disabledStyleIds: img.styleId == null ? const [] : [img.styleId!],
                          );
                          if (res == null) return;
                          await controller.convertImageWithSelection(
                            image: img,
                            styleIds: res.styleIds,
                            numberOfImages: res.numberOfImages,
                          );
                        },
                      ),
                    ),
                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.videoReviewGenerateFrameStart],
                      margin: EdgeInsets.only(left: 8.wMin),
                      child: _buildMiniActionButton(
                        title: '生成视频',
                        color: const Color(0xFF4ADE80),
                        onTap: () async {
                          controller.imageGeneratedVideo(context, img);
                        },
                      ),
                    ),
                    
                    ManageAuthBoxWidget(
                      authCodes: [ img.locked == true ? ManageAuthCode.contentReviewImageUnlock : ManageAuthCode.contentReviewImageLock],
                      margin: EdgeInsets.only(left: 8.wMin),
                      child: TapScaleWidget(
                        onTap: () async{
                          bool res = await ManageLockBigImageDialog.show(
                            context: context, 
                            imageUrl: img.imageUrl,
                            relationImageId: img.semanticImageRelationId,
                            locked: img.locked,
                          );
                          if(!res) return;
                          controller.fetchImages();
                        },
                        sclae: 1.1,
                        child: Container(
                          width: 36.wMin,
                          height: 36.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.wMin),
                            color: AppTheme.cInverseOverlay2.color,
                            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                          ),
                          child: SvgPicture.asset(
                            img.locked == true ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                            width: 24.wMin,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniActionButton({required String title, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
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

  Widget _buildCornerButton({required String title, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120.wMin,
        height: 56.wMin,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4.wMin)),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18.wMin, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildSegmentSwitch({required int questionCount, required int imageCount, required int videoCount}) {
    return Obx(() {
      final selected = controller.segmentIndex.value;
      return Container(
        height: 65.wMin,
        padding: EdgeInsets.all(5.wMin),
        decoration: BoxDecoration(
          color: const Color(0xFF353E5C),
          borderRadius: BorderRadius.circular(11.wMin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ManageAuthBoxWidget(
              authCodes: const [
                ManageAuthCode.exerciseTypeList,
                ManageAuthCode.exercisePage,
              ],
              child: Flexible(
                child: _buildSegmentItem(
                  title: '题目',
                  count: questionCount,
                  selected: selected == 0,
                  onTap: () => controller.setSegmentIndex(0),
                ),
              ),
            ),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.enContentSemanticList],
              child: Flexible(
                child: _buildSegmentItem(
                  title: '图片',
                  count: imageCount,
                  selected: selected == 1,
                  onTap: () => controller.setSegmentIndex(1),
                ),
              ),
            ),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.videoReviewKnowledgeVideos],
              child: Flexible(
                child: _buildSegmentItem(
                  title: '视频',
                  count: videoCount,
                  selected: selected == 2,
                  onTap: () => controller.setSegmentIndex(2),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSegmentItem({
    required String title,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final bg = selected ? const Color(0xFF2388FF) : Colors.transparent;
    final fg = selected ? Colors.white : const Color(0xFFACB4C0);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 54.wMin,
        width: 102.wMin,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(color: fg, fontSize: 14.wMin, fontWeight: FontWeight.w400)),
            SizedBox(width: 10.wMin),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.wMin),
              decoration: BoxDecoration(
                color: const Color(0x6619213D),
                borderRadius: BorderRadius.circular(99.wMin),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(color: fg, fontSize: 16.wMin, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
