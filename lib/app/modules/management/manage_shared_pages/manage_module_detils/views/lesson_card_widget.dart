import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../controllers/manage_module_detils_controller.dart';

class LessonCardWidget extends StatefulWidget {
  final int index;
  final LessonResponseEntity lessonEntity;
  final int? unitId;
  final int songGenerateType;
  final int remixTextGenerateType;
  final bool? planned;
  final bool? sentenceGenerated;
  final Function(int, LessonResponseEntity) onTap;
  final Function(int, LessonResponseEntity) onManageLessonTopicTap;

  // 添加操作按钮点击回调
  final Function(BuildContext, GlobalKey, LessonResponseEntity, int)? onActionTap;

  // 新管理端使用tag控制器，需要传入控制器实例
  final ManageModuleDetilsController controller;

  const LessonCardWidget({
    super.key,
    required this.index,
    required this.lessonEntity,
    required this.onTap,
    required this.unitId,
    this.planned,
    this.sentenceGenerated,
    this.remixTextGenerateType = 0,
    this.onActionTap,
    required this.onManageLessonTopicTap,
    this.songGenerateType = 0,
    required this.controller,
  });

  @override
  State<LessonCardWidget> createState() => _LessonCardWidgetState();
}

class _LessonCardWidgetState extends State<LessonCardWidget> with SafeSetStateMixin {
  // 使用getter确保每次访问都获取最新的props
  // 无需手动同步，减少bug风险
  // 获取当前的lessonEntity，确保始终使用最新值
  LessonResponseEntity get _lessonEntity => widget.lessonEntity;

  // 获取控制器
  ManageModuleDetilsController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        widget.onTap.call(widget.index, _lessonEntity);
      },
      sclae: 1.03,
      child: Container(
        padding: EdgeInsets.only(top: 12.wMin, bottom: 12.wMin, left: 16.wMin, right: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: const Color(0xff19213D).withValues(alpha: 0.5),
          border: Border.all(width: 1.wMin, color: const Color(0xff444B5F).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xffFFFFFF).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Row(
                children: [
                  Gaps.getWidth(8.wMin),
                  _imageWidget(),
                  Gaps.getWidth(8.wMin),
                  Expanded(child: _lessonInfoWidget()),
                ],
              ),
            ),
            Gaps.getHeight(10.wMin),
            _bottomWidget(),
          ],
        ),
      ),
    );
  }

  Widget _imageWidget() {
    return Container(
      alignment: Alignment.center,
      width: 103.wMin,
      height: 103.wMin,
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          width: 5.wMin,
          color: const Color(0xffB3B5BE),
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xff3A3381),
          shape: BoxShape.circle,
        ),
        child: CachedImageWidget(
          width: 70.wMin,
          height: 82.wMin,
          fit: BoxFit.contain,
          _lessonEntity.coverUrl ?? '',
          errorWidget: Image.asset(
            Assets.officialCourseDetailsUnitObjectives,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _statusWidget() {
    if (_lessonEntity.isUnitTEST) {
      return const SizedBox.shrink();
    }
    if (!_lessonEntity.isUnitTARGET) {
      return Row(
        children: [
          Visibility(
            visible: _lessonEntity.planned ?? false,
            child: Container(
              alignment: Alignment.center,
              width: 110.wMin,
              height: 24.wMin,
              decoration: BoxDecoration(
                color: const Color(0xff17C964).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.wMin),
              ),
              child: Text(
                "课时计划已生成",
                style: TextStyle(
                  fontSize: 12.wMin,
                  color: const Color(0xff63DE77),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Gaps.getWidth(8.wMin),
          Visibility(
            visible: _lessonEntity.exerciseGenerateType == 2,
            child: Container(
              alignment: Alignment.center,
              width: 85.wMin,
              height: 24.wMin,
              decoration: BoxDecoration(
                //#
                color: const Color(0xff17C964).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.wMin),
              ),
              child: Text(
                "题目已生成",
                style: TextStyle(
                  fontSize: 12.wMin,
                  color: const Color(0xff63DE77),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Visibility(
                visible: widget.planned ?? false,
                child: Container(
                  alignment: Alignment.center,
                  width: 110.wMin,
                  height: 24.wMin,
                  decoration: BoxDecoration(
                    color: const Color(0xff17C964).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                  child: Text(
                    "单元计划已生成",
                    style: TextStyle(
                      fontSize: 12.wMin,
                      color: const Color(0xff63DE77),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Gaps.getWidth(8.wMin),
              Visibility(
                visible: widget.sentenceGenerated ?? false,
                child: Container(
                  alignment: Alignment.center,
                  width: 110.wMin,
                  height: 24.wMin,
                  decoration: BoxDecoration(
                    //#
                    color: const Color(0xff17C964).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                  child: Text(
                    "单元句子已生成",
                    style: TextStyle(
                      fontSize: 12.wMin,
                      color: const Color(0xff63DE77),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gaps.getHeight(8.wMin),
          Row(
            children: [
              Visibility(
                visible: widget.planned ?? false,
                child: Container(
                  alignment: Alignment.center,
                  width: 110.wMin,
                  height: 24.wMin,
                  decoration: BoxDecoration(
                    color: widget.remixTextGenerateType == -1 ? Colors.red : const Color(0xff17C964).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                  child: Text(
                    widget.remixTextGenerateType == 0
                        ? '未生成文章'
                        : widget.remixTextGenerateType == 1
                            ? "文章生成中"
                            : widget.remixTextGenerateType == 2
                                ? "文章已生成"
                                : "文章生成失败",
                    style: TextStyle(
                      fontSize: 12.wMin,
                      color: widget.remixTextGenerateType <= 1
                          ? const Color(0xff63DE77)
                          : widget.remixTextGenerateType == 2
                              ? const Color(0xff63DE77)
                              : Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ),
              ),
              Gaps.getWidth(8.wMin),
              Visibility(
                visible: widget.sentenceGenerated ?? false,
                child: Container(
                  alignment: Alignment.center,
                  width: 110.wMin,
                  height: 24.wMin,
                  decoration: BoxDecoration(
                    color: widget.songGenerateType == -1 ? Colors.red : const Color(0xff17C964).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                  child: Text(
                    widget.songGenerateType == 0
                        ? '未生成歌曲'
                        : widget.songGenerateType == 1
                            ? "歌曲生成中"
                            : widget.songGenerateType == 2
                                ? "歌曲已生成"
                                : "歌曲生成失败",
                    style: TextStyle(
                      fontSize: 12.wMin,
                      color: widget.songGenerateType <= 1
                          ? const Color(0xff63DE77)
                          : widget.songGenerateType == 2
                              ? const Color(0xff63DE77)
                              : Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _lessonInfoWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _lessonEntity.name ?? "",
              style: TextStyle(
                fontSize: 16.wMin,
                color: const Color(0xffEBEFF5),
                fontWeight: FontWeight.w500,
              ),
            ),
            ManageAuthBoxWidget(
              authCodes: const [
                ManageAuthCode.courseLessonEdit,
                ManageAuthCode.courseUnitEdit,
              ],
              isAny: true,
              child: TapScaleWidget(
                key: widget.lessonEntity.globalKey,
                onTap: () {
                  // 如果提供了外部操作回调，则使用外部回调
                  if (widget.onActionTap != null) {
                    widget.onActionTap!.call(context, widget.lessonEntity.globalKey, _lessonEntity, widget.index);
                  }
                },
                sclae: 1.03,
                child: Container(
                  padding: EdgeInsets.all(8.wMin),
                  color: Colors.transparent,
                  child: SvgPicture.asset(Assets.managerThreePoint, width: 24.wMin),
                ),
              ),
            ),
          ],
        ),
        _statusWidget(),
        Gaps.getHeight(8.wMin),
        Padding(
          padding: EdgeInsets.only(right: 5.wMin),
          child: Text(
            _lessonEntity.description ?? "",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            maxLines: 2,
            style: TextStyle(
              fontSize: 14.wMin,
              color: const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Gaps.getHeight(8.wMin),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _lessonEntity.isUnitTARGET
                ? Row(
                    children: [
                      const Spacer(),
                      ManageAuthBoxWidget(
                        authCodes: const [
                          ManageAuthCode.courseUnitTextRemix,
                        ],
                        child: ManageButton(
                          text: "生成文章",
                          width: 110.wMin,
                          height: 30.wMin,
                          color: const Color(0xff353E5C),
                          borderColor: Colors.transparent,
                          style: TextStyle(
                            fontSize: 14.wMin,
                            color: const Color(0xffEBEEF3),
                            fontWeight: FontWeight.w400,
                          ),
                          onTap: () async {
                            await _controller.generateLessonArticle(widget.unitId!);
                          },
                        ),
                      ),
                      Gaps.getWidth(8.wMin),
                      ManageAuthBoxWidget(
                        authCodes: const [
                          ManageAuthCode.courseUnitSongGenerate,
                        ],
                        child: ManageButton(
                          text: "生成歌曲",
                          width: 85.wMin,
                          height: 30.wMin,
                          color: const Color(0xff353E5C),
                          borderColor: Colors.transparent,
                          style: TextStyle(
                            fontSize: 14.wMin,
                            color: const Color(0xffEBEEF3),
                            fontWeight: FontWeight.w400,
                          ),
                          onTap: () async {
                            await _controller.generateLessonSong(widget.unitId!);
                          },
                        ),
                      ),
                      Gaps.getWidth(8.wMin),
                    ],
                  )
                : SizedBox(height: 30.wMin),
            SizedBox(
              height: 10.wMin,
            ),
          ],
        )
      ],
    );
  }

  Widget _bottomWidget() {
    if (_lessonEntity.isUnitTEST) {
      return SizedBox(
        height: 30.wMin,
      );
    }
    if (!_lessonEntity.isUnitTARGET) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ManageAuthBoxWidget(
                authCodes: const [
                  ManageAuthCode.bookUnitLessonRefresh,
                ],
                child: ManageButton(
                  text: "刷新课时计划",
                  width: 110.wMin,
                  height: 30.wMin,
                  color: const Color(0xff2388FF),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () async {
                    await _controller.refreshOneLessonPlan(widget.unitId!, _lessonEntity.uid);
                  },
                ),
              ),
              Gaps.getWidth(8.wMin),
              ManageAuthBoxWidget(
                authCodes: const [
                  ManageAuthCode.bookUnitLessonExercise,
                ],
                child: ManageButton(
                  text: "重新生成题目",
                  width: 110.wMin,
                  height: 30.wMin,
                  color: const Color(0xff2388FF),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () async {
                    await _controller.generateOneLessonTitle(widget.unitId!, _lessonEntity.uid);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              ManageAuthBoxWidget(
                authCodes: const [
                  ManageAuthCode.lessonExerciseList,
                ],
                child: Container(
                  alignment: Alignment.center,
                  width: 120.wMin,
                  height: 30.wMin,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: const Color(0xff2388FF),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ((_lessonEntity.exerciseCount ?? 0) == 0) ? "题目0" : "题目${_lessonEntity.exerciseNormalCount ?? 0}/${_lessonEntity.exerciseCount ?? 0} ",
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xff2388FF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: const Color(0xff2388FF),
                        size: 14.wMin,
                      ),
                    ],
                  ),
                ),
              ),
              Gaps.getWidth(8.wMin),
              ManageAuthBoxWidget(
                authCodes: const [
                  ManageAuthCode.exerciseV2Create,
                ],
                child: TapScaleWidget(
                  onTap: () {
                    // 单元目标(不跳转管理课时题目)
                    if (_lessonEntity.isUnitTARGET) {
                      return;
                    }
                    widget.onManageLessonTopicTap.call(widget.index, widget.lessonEntity);
                  },
                  sclae: 1.03,
                  child: Container(
                    alignment: Alignment.center,
                    width: 90.wMin,
                    height: 30.wMin,
                    decoration: BoxDecoration(
                      color: const Color(0xff2388FF),
                      borderRadius: BorderRadius.circular(6.wMin),
                    ),
                    child: Text(
                      "管理题目",
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ManageAuthBoxWidget(
                authCodes: const [
                  ManageAuthCode.bookUnitPlan,
                ],
                child: ManageButton(
                  text: "生成单元计划",
                  width: 110.wMin,
                  height: 30.wMin,
                  color: const Color(0xff353E5C),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () async {
                    await _controller.generateUnitPlan(widget.unitId!);
                  },
                ),
              ),
              Gaps.getWidth(8.wMin),
              ManageAuthBoxWidget(
                authCodes: const [
                  ManageAuthCode.bookUnitSentence,
                ],
                child: ManageButton(
                  text: "生成句子",
                  width: 85.wMin,
                  height: 30.wMin,
                  color: const Color(0xff353E5C),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () async {
                    await _controller.generateSentence(widget.unitId!);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              ManageAuthBoxWidget(
                authCodes: const [
                  ManageAuthCode.bookUnitLessonPlan
                ],
                child: ManageButton(
                  text: "生成课时计划",
                  width: 110.wMin,
                  height: 30.wMin,
                  color: const Color(0xff2388FF),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () async {
                    await _controller.generateLessonPlan(widget.unitId!);
                  },
                ),
              ),
              Gaps.getWidth(8.wMin),
              ManageAuthBoxWidget(
                authCodes: const [
                  ManageAuthCode.bookUnitLessonExercise,
                ],
                child: ManageButton(
                  text: "生成课时题目",
                  width: 110.wMin,
                  height: 30.wMin,
                  color: const Color(0xff2388FF),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () async {
                    await _controller.generateLessonTitle(widget.unitId!);
                  },
                ),
              ),
            ],
          )
        ],
      );
    }
  }
}
