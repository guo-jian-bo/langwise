
import 'package:flutter/material.dart';

import '../../../../../../../common/entities/entities.dart';

class ManageSubChannelModel {
  /// 二级渠道名称 输入框
  TextEditingController subChannelNameController;
  
  /// 备注 输入框
  TextEditingController remarkController;
  /// 二级渠道code 输入框
  TextEditingController subChannelCodeController;

  /// 是否启用 切换按钮
  bool isEnable;

  /// 负责人id
  int? ownerId;

  /// 负责人名称
  String? ownerName;

  ManageChannelEntityChildren? child;

  /// key
  GlobalKey key;

  ManageSubChannelModel({
    required this.subChannelNameController,
    required this.remarkController,
    required this.subChannelCodeController,
    this.isEnable = true,
    this.ownerId,
    this.ownerName,
    this.child,
    required this.key,
  });
}
