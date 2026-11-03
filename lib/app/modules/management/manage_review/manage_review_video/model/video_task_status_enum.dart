// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import '../../../../../../theme/theme.dart';

enum VideoTaskStatusEnum{
  all_pending_review("all_pending_review", "全部待审核", AppTheme.cInverseOverlay3, AppTheme.cInverseTextLight),
  start("start", "任务开始", AppTheme.cInverseOverlay3, AppTheme.cTextSecondary),
  image_generating("image_generating", "图片生成中", AppTheme.cSurfaceInfo, AppTheme.cInverseTextLight),
  image_checking("image_checking", "图片待审核", AppTheme.cSurfaceWarning, AppTheme.cInverseTextLight),
  video_generating("video_generating", "视频生成中", AppTheme.cSurfaceInfo, AppTheme.cInverseTextLight),
  finished("finished", "视频待审核", Color(0xFFA855F7), AppTheme.cInverseTextLight),
  checked("checked", "视频已审核", AppTheme.cSurfaceSuccess, AppTheme.cInverseTextLight),
  failed("failed", "视频生成失败", AppTheme.cSurfaceError, AppTheme.cInverseTextLight),
  abandoned("abandoned", "被放弃", AppTheme.cInverseOverlay3, AppTheme.cTextSecondary);

  final String value;
  final String name;
  final Color bg;
  final Color font;

  const VideoTaskStatusEnum(this.value, this.name, this.bg, this.font);

  static VideoTaskStatusEnum fromValue(String? value) {
    if (value == null) return all_pending_review;
    return VideoTaskStatusEnum.values.firstWhere((e) => e.value == value, orElse: () => all_pending_review);
  }
}