
import 'package:flutter/material.dart';

import '../../../../../../../common/entities/entities.dart';

class ManageScriptGroupingModel{
  ManageScriptGroupingEntity? data;

  // uid
  TextEditingController uidInput;

  /// order
  TextEditingController orderInput;

  /// 中文名称
  TextEditingController zhNameInput;

  /// 英文名称
  TextEditingController enNameInput;

  /// category
  TextEditingController categoryInput;

  /// 中文描述
  TextEditingController zhDescInput;
  
  /// 英文描述
  TextEditingController enDescInput;

  ManageScriptGroupingModel({
    this.data,
    required this.uidInput,
    required this.orderInput,
    required this.zhNameInput,
    required this.enNameInput,
    required this.categoryInput,
    required this.zhDescInput,
    required this.enDescInput,
  });

}