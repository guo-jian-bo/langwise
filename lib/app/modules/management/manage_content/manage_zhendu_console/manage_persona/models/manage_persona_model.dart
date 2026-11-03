
import 'package:flutter/material.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../enums/manage_zhendu_enums.dart';

class ManagePersonaModel{

  MangePersonaEntity? data;

  /// nid
  TextEditingController nidInput;

  /// scope
  ManageZhenduPersonaScopeEnum? scope;

  /// 中文名称
  TextEditingController zhNameInput;

  /// 中文 dialect
  TextEditingController? zhDialectInput;

  /// 英文名称
  TextEditingController enNameInput;

  /// 英文 dialect
  TextEditingController? enDialectInput;

  /// gender
  ManageZhenduGenderEnum? gender;

  ///species
  TextEditingController speciesInput;

  /// scopeRefId
  TextEditingController scopeRefIdInput;

  /// locale
  ManageZhenduLocaleEnum? locale;

  /// personality
  TextEditingController personalityInput;

  /// appearance
  TextEditingController appearanceInput;

  /// tags
  TextEditingController tagsInput;

  /// 角色变体
  List<ManagePersonaVariantModel> variants;

  ManagePersonaModel({
    this.data,
    required this.nidInput,
    this.scope,
    required this.zhNameInput,
    required this.zhDialectInput,
    required this.enNameInput,
    required this.enDialectInput,
    this.gender,
    required this.speciesInput,
    required this.scopeRefIdInput,
    this.locale,
    required this.personalityInput,
    required this.appearanceInput,
    required this.tagsInput,
    required this.variants,
  });

}


class ManagePersonaVariantModel{

  MangePersonaEntityVariants? data;

  /// nid
  TextEditingController nidInput;

  /// 变体名称
  TextEditingController variantNameInput;

  /// age_group
  ManageZhenduAgeGroupEnum? ageGroup;

  /// speed_offset
  TextEditingController speedOffsetInput;

  /// 中文描述
  TextEditingController zhDescInput;
  
  /// 英文描述
  TextEditingController enDescInput;

  /// 设定图
  /// setting diagram

  ManagePersonaVariantModel({
    this.data,
    required this.nidInput,
    required this.variantNameInput,
    this.ageGroup,
    required this.speedOffsetInput,
    required this.zhDescInput,
    required this.enDescInput,
  });

}

