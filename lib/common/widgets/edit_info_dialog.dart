import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 编辑课程信息弹框组件
/// 提供三个编辑选项：新增其他年级课程、添加新教材、编辑课程信息
class EditCourseInfoDialog extends StatelessWidget {
  /// 新增其他年级课程回调
  final VoidCallback? onAddOtherGradeCourse;

  /// 在当前年级课程中添加新教材回调
  final VoidCallback? onAddNewMaterial;

  /// 编辑当前年级课程信息回调
  final VoidCallback? onEditCurrentCourseInfo;

  const EditCourseInfoDialog({
    Key? key,
    this.onAddOtherGradeCourse,
    this.onAddNewMaterial,
    this.onEditCurrentCourseInfo,
  }) : super(key: key);

  /// 显示编辑课程信息弹框
  static Future<void> show({
    VoidCallback? onAddOtherGradeCourse,
    VoidCallback? onAddNewMaterial,
    VoidCallback? onEditCurrentCourseInfo,
  }) {
    return Get.dialog(
      EditCourseInfoDialog(
        onAddOtherGradeCourse: onAddOtherGradeCourse,
        onAddNewMaterial: onAddNewMaterial,
        onEditCurrentCourseInfo: onEditCurrentCourseInfo,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 727.ww,
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary,
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          padding: EdgeInsets.only(left: 40.ww, top: 16.wh, right: 40.ww, bottom: 40.ww),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建弹框头部
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '编辑信息',
          style: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 28.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
        TapScaleWidget(
          sclae: 1.05,
          onTap: () => Get.back(),
          child: Container(
            width: 42.wMin,
            height: 42.wMin,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cBgActive,
            ),
            child: SvgPicture.asset(
              Assets.publicX,
              width: 24.wMin,
              height: 24.wMin,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建弹框内容
  Widget _buildContent() {
    return Column(
      children: [
        Gaps.getHeight(24.wh),
        _buildOptionItem(
          icon: Assets.customCourseIconAddLevel,
          title: '新增其他年级课程',
          onTap: () {
            Get.back();
            onAddOtherGradeCourse?.call();
          },
        ),
        Gaps.getHeight(24.wh),
        _buildOptionItem(
          icon: Assets.customCourseIconAddBook,
          title: '在当前年级课程中添加新教材',
          onTap: () {
            Get.back();
            onAddNewMaterial?.call();
          },
        ),
        Gaps.getHeight(24.wh),
        _buildOptionItem(
          icon: Assets.customCourseIconCourseEdit,
          title: '编辑当前年级课程信息',
          onTap: () {
            Get.back();
            onEditCurrentCourseInfo?.call();
          },
        ),
      ],
    );
  }

  /// 构建选项项目
  Widget _buildOptionItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: OptimizeUtils.noneThrottle(() {
        onTap.call();
      }, 500),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.wMin),
          border: Border.all(
            color: const Color(0xFF303335),
            width: 2.wMin,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
              decoration: BoxDecoration(
                color: const Color(0xFF26292A),
                borderRadius: BorderRadius.circular(5.wMin),
              ),
              child: SvgPicture.asset(
                icon,
                width: 32.ww,
                height: 32.ww,
              ),
            ),
            Gaps.getWidth(12.ww),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Gaps.getWidth(12.ww),
            SvgPicture.asset(
              Assets.customCourseIconCaredRight,
              width: 32.wMin,
              height: 32.wMin,
            ),
          ],
        ),
      ),
    );
  }
}
