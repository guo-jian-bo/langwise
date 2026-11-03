import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../generated/assets.dart';

class ManagePhonicsCourseItemWidget extends StatelessWidget {
  final CourseResponseEntity course;
  const ManagePhonicsCourseItemWidget({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: const Color(0xFF414864), // 边框颜色，模拟 `border: 1px solid #414864`
          width: 1.wMin, // 边框宽度
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter, // 渐变从顶部开始
          end: Alignment.bottomCenter, // 渐变到底部
          colors: [
            Color(0xFF1D233B), // 渐变颜色 #1D233B
            Color(0xFF191F36), // 渐变颜色 #191F36
          ],
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CachedImageWidget(
                course.coverUrl ?? '',
                width: 140.wMin,
                height: 140.wMin,
                fit: BoxFit.contain,
                placeholder: _buildEmptyImage(),
                errorWidget: _buildEmptyImage(),
              ),
              Positioned(
                left: 5.wMin,
                top: 5.wMin,
                child: Container(
                  alignment: Alignment.center,
                  height: 24.wMin,
                  padding: EdgeInsets.only(left: 12.wMin, right: 12.wMin),
                  decoration: BoxDecoration(
                    color: course.newStatus.color,
                    borderRadius: BorderRadius.circular(4.wMin),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05), // 阴影颜色，模拟 `rgba(0, 0, 0, 0.05)`
                        offset: const Offset(0, 1), // 设置阴影的偏移
                        blurRadius: 2, // 阴影的模糊半径
                        spreadRadius: 0, // 阴影的扩展半径
                      ),
                    ],
                  ),
                  child: Text(
                    course.newStatus.title,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: const Color(0xffEBEFF5),
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  course.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: const Color(0xffEDF0F4),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.wMin),
                _buildTextWidget("修改时间：${course.newUpdate}"),
                SizedBox(height: 4.wMin),
                _buildTextWidget("语言：${course.newLanguage}"),
                SizedBox(height: 4.wMin),
                _buildTextWidget("来源：${course.scopeName ?? ''}"),
                SizedBox(height: 4.wMin),
                _buildTextWidget("作者：${course.vendorName ?? ''}"),
                SizedBox(height: 4.wMin),
                Row(
                  children: [
                    StatusTagDifficultyWidget(
                      difficulty: course.minDifficulty,
                      language: course.language,
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
                      difficulty: course.maxDifficulty,
                      language: course.language,
                    ),
                  ],
                ),
                SizedBox(height: 4.wMin),
                Text(
                  "${course.unitNormalCnt ?? 0} / ${course.unitTotal ?? 0} 单元",
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
    );
  }

  Widget _buildTextWidget(String text) {
    return Text(
      text,
      maxLines: 1,
      style: TextStyle(
        fontSize: 15.wMin,
        color: const Color(0xff9BA5B5),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// 为空状态下的图片
  Widget _buildEmptyImage() {
    return buildImage(
      Assets.managerOfficialCourseCover,
      width: 140.wMin,
      height: 140.wMin,
      fit: BoxFit.contain,
    );
  }
}
