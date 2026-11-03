import 'package:flutter/material.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';

class InvitationListModel {
  
  final GlobalKey key;
  /// 是否激活
  final bool isActive;

  final ReferralAwardListTypeEnum awardTypeEnum;

  final ReferralAwardEntityNodes data;
  
  InvitationListModel({
    required this.key, 
    this.isActive = false, 
    required this.data, 
    required this.awardTypeEnum
  });

}