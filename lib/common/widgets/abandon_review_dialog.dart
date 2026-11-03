import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../values/values.dart';

/// 放弃审核确认弹框
class AbandonReviewDialog extends StatelessWidget {
  /// 标题
  final String title;

  /// 警告文本
  final String warningText;

  /// 警告文本
  final String subText;

  /// 取消按钮文本
  final String cancelText;

  /// 确认按钮文本
  final String confirmText;

  /// 确认回调
  final VoidCallback? onConfirm;

  const AbandonReviewDialog({
    Key? key,
    this.title = '确认放弃审核',
    this.warningText = '放弃审核当前知识点后，当前知识点所有已审核的数据都会和它解绑。\n\n',
    this.subText = '只有当这个知识点自己不能把握的时候才放弃。',
    this.cancelText = '取消',
    this.confirmText = '确定',
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: color_1E2939,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.ww),
      ),
      child: Container(
        width: 450.ww,
        padding: EdgeInsets.only(left: 24.ww, right: 24.ww, top: 24.wh, bottom: 24.wh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  child: Icon(
                    Icons.close,
                    color: color_99A1AF,
                    size: 20.wMin,
                  ),
                  onTap: OptimizeUtils.noneThrottle(() {
                    Get.back();
                  }, 500),
                ),
              ],
            ),
            SizedBox(height: 16.wh),

            // 警告内容
            Container(
              padding: EdgeInsets.all(17.ww),
              decoration: BoxDecoration(
                color: color_82181A.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.wMin),
                border: Border.all(
                  color: color_C10007,
                  width: 1.wMin,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: color_FB2C36,
                    size: 20.wMin,
                  ),
                  SizedBox(width: 8.ww),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warningText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.wMin,
                            height: 1.5,
                          ),
                        ),
                        Gaps.getHeight(8.wh),
                        Text(
                          subText,
                          style: TextStyle(
                            color: color_FFA2A2,
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.wh),
            // 按钮区域
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 取消按钮
                TapScaleWidget(
                  onTap: OptimizeUtils.noneThrottle(() {
                    Get.back();
                  }, 500),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.ww,
                      vertical: 8.wh,
                    ),
                    decoration: BoxDecoration(
                      color: color_4A5565,
                      borderRadius: BorderRadius.circular(8.wMin),
                    ),
                    child: Text(
                      cancelText,
                      style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                SizedBox(width: 12.ww),
                // 确认按钮
                TapScaleWidget(
                  onTap: OptimizeUtils.noneThrottle(() {
                    Get.back();
                    onConfirm?.call();
                  }, 500),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.ww,
                      vertical: 8.wh,
                    ),
                    decoration: BoxDecoration(
                      color: color_E7000B,
                      borderRadius: BorderRadius.circular(8.wMin),
                    ),
                    child: Text(
                      confirmText,
                      style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示放弃审核确认弹框
  static Future<void> show({
    String title = '确认放弃审核',
    String warningText = '放弃审核当前知识点后，当前知识点所有已审核的数据都会和它解绑。',
    String cancelText = '取消',
    String confirmText = '确定',
    VoidCallback? onConfirm,
  }) {
    return Get.dialog(
      AbandonReviewDialog(
        title: title,
        warningText: warningText,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
      barrierDismissible: false,
    );
  }
}
