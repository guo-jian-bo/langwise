import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class TaskRewardDialog {
  static Future<bool?> show({
    BuildContext? context,
    required String title,
    String? subtitle,
    required String rewardTitle,
    String? rewardSubtitle,
    String? rewardCode,
    String buttonText = '立即领取',
    bool autoCopy = true,
    String? copyText,
    Future<void> Function()? onClaim,
    bool barrierDismissible = true,
  }) async {
    final ctx = context ?? Get.context;
    if (ctx == null) return null;

    return await showDialog<bool?>(
      context: ctx,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return _TaskRewardDialogWidget(
          title: title,
          subtitle: subtitle,
          rewardTitle: rewardTitle,
          rewardSubtitle: rewardSubtitle,
          rewardCode: rewardCode,
          buttonText: buttonText,
          autoCopy: autoCopy,
          copyText: copyText,
          onClaim: onClaim,
        );
      },
    );
  }
}

class _TaskRewardDialogWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String rewardTitle;
  final String? rewardSubtitle;
  final String? rewardCode;
  final String buttonText;
  final bool autoCopy;
  final String? copyText;
  final Future<void> Function()? onClaim;

  const _TaskRewardDialogWidget({
    required this.title,
    required this.subtitle,
    required this.rewardTitle,
    required this.rewardSubtitle,
    required this.rewardCode,
    required this.buttonText,
    required this.autoCopy,
    required this.copyText,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 840.wMin,
          padding: EdgeInsets.all(32.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.wMin),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E2A3A),
                Color(0xFF101826),
              ],
            ),
            border: Border.all(width: 1.wMin, color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.wMin),
              SizedBox(
                width: 140.wMin,
                height: 140.wMin,
                child: Icon(Icons.card_giftcard, size: 120.wMin, color: const Color(0xFFFFD45A)),
              ),
              SizedBox(height: 18.wMin),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44.wMin,
                  color: AppTheme.cInverseTextLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                SizedBox(height: 12.wMin),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26.wMin,
                    color: AppTheme.cTextQuaternary,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
              SizedBox(height: 24.wMin),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(22.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.wMin),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(width: 1.wMin, color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Column(
                  children: [
                    Text(
                      rewardTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40.wMin,
                        color: const Color(0xFFFFD45A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (rewardSubtitle != null && rewardSubtitle!.trim().isNotEmpty) ...[
                      SizedBox(height: 10.wMin),
                      Text(
                        rewardSubtitle!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextQuaternary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    if (rewardCode != null && rewardCode!.trim().isNotEmpty) ...[
                      SizedBox(height: 14.wMin),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 14.wMin),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12.wMin),
                          border: Border.all(width: 1.wMin, color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Text(
                          rewardCode!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 26.wMin),
              ButtonWidget(
                text: buttonText + (autoCopy ? '（自动复制）' : ''),
                height: 76.wMin,
                borderRadius: 20.wMin,
                color: const Color(0xFFFFD45A),
                fontColor: const Color(0xFF0B1221),
                fontSize: 30.wMin,
                fontWeight: FontWeight.w700,
                sclae: 1.02,
                onTap: () async {
                  final textToCopy = copyText ?? rewardCode;
                  if (autoCopy && textToCopy != null && textToCopy.trim().isNotEmpty) {
                    await Clipboard.setData(ClipboardData(text: textToCopy));
                    ToastUtils.showToast(text: '已复制', type: ToastType.success);
                  }
                  if (onClaim != null) {
                    await onClaim!();
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
              SizedBox(height: 12.wMin),
            ],
          ),
        ),
      ),
    );
  }
}
