import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/activity_tags_entities.dart';

import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../controllers/manage_new_crowd_controller.dart';

class ManageNewCrowdDetailController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageNewCrowdDetailController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_NEW_CROWD_DETAIL;

  @override
  String get breadcrumbTitle => '人群详情';

  late final ActivityTagItemEntity tagEntity;
  late final String tagConditionJson;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    final args = (Get.arguments ?? {}) as Map;
    final t = args['tag'];
    if (t is! ActivityTagItemEntity) {
      throw Exception('ManageNewCrowdDetailController requires ActivityTagItemEntity argument: tag');
    }
    tagEntity = t;

    final dsl = tagEntity.tagCondition ?? const <String, dynamic>{};
    tagConditionJson = const JsonEncoder.withIndent('  ').convert(dsl);

    // 如果需要关联父控制器，可以通过 parentTag 获取
    final parentTag = args['parentTag'] as String?;
    if (parentTag != null && Get.isRegistered<ManageNewCrowdController>(tag: parentTag)) {
      final parentController = Get.find<ManageNewCrowdController>(tag: parentTag);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await parentController.ensureInitialized();
        parentController.applyRemoteTag(tagEntity);
      });
    }
  }

  void back() {
    Get.back();
  }
}
