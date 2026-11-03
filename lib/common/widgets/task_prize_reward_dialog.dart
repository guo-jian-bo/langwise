import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/activity_console_task_prize_detail_entity.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/date_format_util.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class TaskPrizeRewardDialog {
  static Future<void> show({
    required BuildContext context,
    required List<TaskItem> items,
    String title = '奖励明细',
  }) async {
    if (items.isEmpty) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return _TaskPrizeRewardDialogWidget(
          title: title,
          items: items,
        );
      },
    );
  }
}

class _TaskPrizeRewardDialogWidget extends StatelessWidget {
  final String title;
  final List<TaskItem> items;

  const _TaskPrizeRewardDialogWidget({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 720.wMin,
              padding: EdgeInsets.fromLTRB(32.wMin, 28.wMin, 32.wMin, 24.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: AppTheme.cSurfaceSecondary.color,
                border: Border.all(width: 1.wMin, color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40.wMin,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  SizedBox(height: 20.wMin),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceTertiary.color,
                      borderRadius: BorderRadius.circular(20.wMin),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                      itemBuilder: (ctx, index) {
                        return _PrizeItemView(item: items[index]);
                      },
                    ),
                  ),
                  SizedBox(height: 22.wMin),
                  ButtonWidget(
                    text: '知道了',
                    height: 52.wMin,
                    width: 100.wMin,
                    borderRadius: 999.wMin,
                    color: AppTheme.cTextBrand.color,
                    fontColor: AppTheme.cInverseTextLight,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    sclae: 1.01,
                    onTap: () => Get.back(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrizeItemView extends StatelessWidget {
  final TaskItem item;

  const _PrizeItemView({required this.item});

  bool get _isCoupons {
    final t = (item.type ?? '');
    return t == 'COUPON';
  }

  @override
  Widget build(BuildContext context) {
    final numText = item.num == null ? '-' : '${item.num}';
    final typeText= item.type=='COUPON'?'兑换码':item.type=='POINTS'?'学点':'乃币';
    final timeText = DateFormatUtil.formatStrtoStr(item.updated.toString(), newPattern: 'yyyy-MM-dd');
    final valueText = item.value == null ? '-' : '${item.value}';
    final codes = (item.values ?? const <String>[]).where((e) => e.trim().isNotEmpty).toList();

    Widget buildRow(String k, String v) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.wMin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150.wMin,
              child: Text(
                k,
                style: TextStyle(
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ),
            Expanded(
              child: Text(
                v,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildRow('奖励类型',typeText),
          buildRow('发放时间', timeText),
          buildRow('数量', numText),
          if (!_isCoupons) buildRow('数值', valueText),
          if (_isCoupons) ...[
            if (codes.isNotEmpty) ...[
              SizedBox(height: 6.wMin),
              Row(
                children: [
                  SizedBox(
                    width: 150.wMin,
                    child: Text(
                      '兑换码',
                      style: TextStyle(
                        fontSize: 22.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8.wMin,
                        runSpacing: 8.wMin,
                        children: codes
                            .map(
                              (c) => TapScaleWidget(
                                onTap: (){
                                  Clipboard.setData(ClipboardData(text: c));
                                  ToastUtils.showToast(text: '复制成功',type: ToastType.success);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10.wMin),
                                    border: Border.all(width: 1.wMin, color: Colors.white.withValues(alpha: 0.08)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        c,
                                        style: TextStyle(
                                          fontSize: 22.wMin,
                                          color: AppTheme.cTextPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 10.wMin),
                                      Icon(Icons.copy, size: 22.wMin,color: AppTheme.cTextPrimary)
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ],
      ),
    );
  }
}
