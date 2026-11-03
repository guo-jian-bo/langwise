import 'package:flutter/material.dart';

import '../enum/elements_card_type.dart';
import 'unit_knowledge_points_entity.dart';

/// 下载弹窗使用的知识点分类模型。
class CourseDetailsTargetContentTypeModel {
  String title;
  List<CourseDetailsTargetContentTypeKnowledgeModel> knowledges;
  List<UnitKnowledgePointsEntityKnowledgeList> orgKnowledges;

  int columnCount;
  ElementsCardType type;

  CourseDetailsTargetContentTypeModel({
    required this.title,
    required this.knowledges,
    required this.orgKnowledges,
    required this.columnCount,
    required this.type,
  });
}

/// 下载弹窗使用的知识点项模型。
class CourseDetailsTargetContentTypeKnowledgeModel {
  UnitKnowledgePointsEntityKnowledgeList knowledge;
  GlobalKey key;

  CourseDetailsTargetContentTypeKnowledgeModel({
    required this.knowledge,
    required this.key,
  });
}
