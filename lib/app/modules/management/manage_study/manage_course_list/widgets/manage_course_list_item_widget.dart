import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageCourseListItemWidget extends StatelessWidget {
  final int index;
  final CourseResponseEntity data;
  final VoidCallback? onTap;
  final void Function(Widget child)? onLongSecondaryTap;

  const ManageCourseListItemWidget({
    super.key,
    required this.index,
    required this.data,
    this.onTap,
    this.onLongSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleLongRightWidget(
      sclae: 0.95,
      key: data.globalKey,
      onLongSecondaryTap: onLongSecondaryTap != null
          ? (a, d) {
              onLongSecondaryTap!(bodyWidget());
            }
          : null,
      onTap: onTap,
      child: bodyWidget(),
    );
  }

  Widget bodyWidget() {
    return Hero(
      tag: "manageCourseListItem$index",
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(5.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(
              color: const Color(0xFF414864),
              width: 1.wMin,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1D233B),
                Color(0xFF191F36),
              ],
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CachedImageWidget(data.coverUrl ?? '',
                      width: 140.wMin,
                      height: 140.wMin,
                      fit: BoxFit.contain,
                      placeholder: buildImage(
                        Assets.managerOfficialCourseCover,
                        width: 140.wMin,
                        height: 140.wMin,
                      ),
                      errorWidget: buildImage(Assets.managerOfficialCourseCover,
                          width: 140.wMin,
                          height: 140.wMin,
                          fit: BoxFit.contain)),
                  Positioned(
                      left: 5.wMin,
                      top: 5.wMin,
                      child: Container(
                        alignment: Alignment.center,
                        height: 24.wMin,
                        padding: EdgeInsets.only(left: 12.wMin, right: 12.wMin),
                        decoration: BoxDecoration(
                          color: data.newStatus.color,
                          borderRadius: BorderRadius.circular(4.wMin),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(data.newStatus.title,
                            style: TextStyle(
                                fontSize: 14.wMin,
                                color: const Color(0xffEBEFF5),
                                fontWeight: FontWeight.w400,
                                height: 1.0)),
                      ))
                ],
              ),
              Gaps.getWidth(12.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.name ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: const Color(0xffEDF0F4),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Gaps.getHeight(4.wMin),
                    Text(
                      "修改时间：${data.newUpdate}",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15.wMin,
                        color: const Color(0xff9BA5B5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Gaps.getHeight(4.wMin),
                    Text(
                      "语言: ${data.newLanguage}",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15.wMin,
                        color: const Color(0xff9BA5B5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Gaps.getHeight(4.wMin),
                    Text(
                      "来源: ${data.scopeName}",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15.wMin,
                        color: const Color(0xff9BA5B5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Gaps.getHeight(4.wMin),
                    Text(
                      "作者: ${data.vendorName}",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15.wMin,
                        color: const Color(0xff9BA5B5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Gaps.getHeight(4.wMin),
                    Row(
                      children: [
                        StatusTagDifficultyWidget(
                          difficulty: data.minDifficulty,
                          language: data.language,
                        ),
                        SizedBox(width: 5.wMin),
                        Text(
                          "-",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: const Color(0xff697179),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 5.wMin),
                        StatusTagDifficultyWidget(
                          difficulty: data.maxDifficulty,
                          language: data.language,
                        ),
                      ],
                    ),
                    Gaps.getHeight(4.wMin),
                    Text(
                      "${data.unitNormalCnt ?? 0} / ${data.unitTotal ?? 0} 单元",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15.wMin,
                        color: const Color(0xffEBEEF3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
