

import 'package:flutter/material.dart';
import 'package:langwise/common/enum/elements_card_type.dart';

import '../../../../../common/entities/entities.dart';

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

class CourseDetailsTargetContentTypeKnowledgeModel {
  UnitKnowledgePointsEntityKnowledgeList knowledge;
  GlobalKey key;

  CourseDetailsTargetContentTypeKnowledgeModel({
    required this.knowledge,
    required this.key,
  });
}