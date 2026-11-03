import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/commons.dart';

class ManageUnitGrammarTargetDetailsDialogs {
  static Future<List<int>?> showMatchPreviewDialog({
    required List<ManageUnitGrammarMatchCandidateEntity> matches,
  }) async {
    return await Get.dialog<List<int>?>(
      _ManageUnitGrammarMatchPreviewDialog(matches: matches),
      barrierDismissible: false,
    );
  }

  static Future<int?> showCreateCountDialog({
    required String title,
    required String description,
    required int min,
    required int max,
    String confirmText = '生成',
  }) async {
    return await Get.dialog<int?>(
      _ManageUnitGrammarCreateCountDialog(
        title: title,
        description: description,
        min: min,
        max: max,
        confirmText: confirmText,
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> showGeneratingHintDialog() async {
    await Get.dialog<void>(
      ManageDialogBoxWidget(
        title: '后台生成中',
        width: 720.wMin,
        confirmText: '我知道了',
        onConfirm: () {
          Get.back();
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(24.wMin, 8.wMin, 24.wMin, 20.wMin),
          child: Text(
            '大约 5 分钟。完成后句子会出现在代表句里。',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

class _ManageUnitGrammarMatchPreviewDialog extends StatefulWidget {
  final List<ManageUnitGrammarMatchCandidateEntity> matches;

  const _ManageUnitGrammarMatchPreviewDialog({
    required this.matches,
  });

  @override
  State<_ManageUnitGrammarMatchPreviewDialog> createState() =>
      _ManageUnitGrammarMatchPreviewDialogState();
}

class _ManageUnitGrammarMatchPreviewDialogState
    extends State<_ManageUnitGrammarMatchPreviewDialog> {
  final Set<int> _selectedIds = <int>{};

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: '库里扫到的句子',
      width: 1200.wMin,
      confirmText: '保存选中',
      onCancel: () {
        Get.back();
      },
      onConfirm: () {
        if (_selectedIds.isEmpty) {
          ToastUtils.showManageToast(text: '请至少选择 1 句');
          return;
        }
        Get.back(result: _selectedIds.toList());
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(24.wMin, 4.wMin, 24.wMin, 16.wMin),
        constraints: BoxConstraints(
          maxHeight: 720.wMin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '硬验通过的语料候选。分数是词汇契合，不是语法分。',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SizedBox(height: 16.wMin),
            Expanded(
              child: widget.matches.isEmpty
                  ? Center(
                      child: Text(
                        '没有扫到过硬验的句子。',
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: widget.matches.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.wMin),
                      itemBuilder: (context, index) {
                        final item = widget.matches[index];
                        final int sentenceUid = item.sentenceUid ?? -1;
                        final bool selected = _selectedIds.contains(sentenceUid);
                        return TapScaleWidget(
                          sclae: 1.0,
                          onTap: sentenceUid <= 0
                              ? null
                              : () {
                                  setState(() {
                                    if (selected) {
                                      _selectedIds.remove(sentenceUid);
                                    } else {
                                      _selectedIds.add(sentenceUid);
                                    }
                                  });
                                },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.wMin,
                              vertical: 12.wMin,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.wMin),
                              color: AppTheme.cSurfaceLayerBase.color,
                              border: Border.all(
                                width: 0.8.wMin,
                                color: selected
                                    ? AppTheme.cDifficultyBackgroundColor22.color
                                        .withValues(alpha: 0.35)
                                    : AppTheme.cBorderThin.color,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: selected,
                                  onChanged: sentenceUid <= 0
                                      ? null
                                      : (_) {
                                          setState(() {
                                            if (selected) {
                                              _selectedIds.remove(sentenceUid);
                                            } else {
                                              _selectedIds.add(sentenceUid);
                                            }
                                          });
                                        },
                                ),
                                SizedBox(width: 8.wMin),
                                Expanded(
                                  child: Text(
                                    item.content ?? '',
                                    style: TextStyle(
                                      fontSize: 18.wMin,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.cTextPrimary.color,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.wMin),
                                Text(
                                  (item.score ?? 0).toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    fontWeight: FontWeight.w500,
                                    color: (item.score ?? 0) == 0
                                        ? AppTheme.cTextTertiary.color
                                        : const Color(0xff22D3EE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 12.wMin),
            Text(
              '已选 ${_selectedIds.length} 句',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageUnitGrammarCreateCountDialog extends StatefulWidget {
  final String title;
  final String description;
  final int min;
  final int max;
  final String confirmText;

  const _ManageUnitGrammarCreateCountDialog({
    required this.title,
    required this.description,
    required this.min,
    required this.max,
    required this.confirmText,
  });

  @override
  State<_ManageUnitGrammarCreateCountDialog> createState() =>
      _ManageUnitGrammarCreateCountDialogState();
}

class _ManageUnitGrammarCreateCountDialogState
    extends State<_ManageUnitGrammarCreateCountDialog> {
  late int count;

  @override
  void initState() {
    super.initState();
    count = widget.min;
  }

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: widget.title,
      width: 760.wMin,
      confirmText: widget.confirmText,
      onCancel: () {
        Get.back();
      },
      onConfirm: () {
        Get.back(result: count);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(24.wMin, 8.wMin, 24.wMin, 20.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SizedBox(height: 20.wMin),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepButton(
                  icon: Icons.remove_rounded,
                  enabled: count > widget.min,
                  onTap: () {
                    if (count <= widget.min) return;
                    setState(() {
                      count -= 1;
                    });
                  },
                ),
                SizedBox(width: 16.wMin),
                Container(
                  width: 120.wMin,
                  height: 56.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cSurfaceLayerBase.color,
                    border: Border.all(
                      width: 0.8.wMin,
                      color: AppTheme.cBorderThin.color,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                ),
                SizedBox(width: 16.wMin),
                _buildStepButton(
                  icon: Icons.add_rounded,
                  enabled: count < widget.max,
                  onTap: () {
                    if (count >= widget.max) return;
                    setState(() {
                      count += 1;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      sclae: enabled ? 1.03 : 1.0,
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44.wMin,
        height: 44.wMin,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? AppTheme.cSurfaceLayerBase2.color
              : AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            width: 0.8.wMin,
            color: enabled
                ? AppTheme.cBorderThin.color
                : AppTheme.cBorderTranslucentThin.color,
          ),
        ),
        child: Icon(
          icon,
          size: 22.wMin,
          color: enabled
              ? AppTheme.cTextPrimary.color
              : AppTheme.cTextTertiary.color,
        ),
      ),
    );
  }
}
