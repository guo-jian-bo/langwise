import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/activity_tags_entities.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/commons.dart';
import '../bindings/manage_new_crowd_detail_binding.dart';
import '../controllers/manage_new_crowd_detail_controller.dart';

class ManageNewCrowdDetailView extends GetView<ManageNewCrowdDetailController> {
  final String tagText;
  const ManageNewCrowdDetailView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（兼容 ManagePageRegistry）
  static Future<T?> to<T>({dynamic arguments}) async {
    final args = arguments is Map ? arguments : <String, dynamic>{};
    final tag = '${Routes.MANAGE_NEW_CROWD_DETAIL}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageNewCrowdDetailView(tagText: tag),
      binding: ManageNewCrowdDetailBinding(tag: tag),
      routeName: Routes.MANAGE_NEW_CROWD_DETAIL,
      arguments: {
        'tag': args['tag'],
        'parentTag': args['parentTag'],
      },
      preventDuplicates: false,
    );
  }

  static const Color _bg = Color(0xFF050916);
  static const Color _panel = Color(0xFF0B1221);
  static const Color _panel2 = Color(0xFF0E172A);
  static const Color _border = Color(0x1FFFFFFF);
  static const Color _text = Color(0xFFEBEEF3);
  static const Color _text2 = Color(0xFFACB4C0);

  @override
  Widget build(BuildContext context) {
    final ActivityTagItemEntity tagEntity = controller.tagEntity;
    final title = (tagEntity.name?.toString().trim().isNotEmpty ?? false) ? tagEntity.name! : (tagEntity.code ?? '-');

    return ManageScaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('人群详情', style: TextStyle(color: Colors.white, fontSize: 24.wMin, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: controller.back,
        ),
        centerTitle: false,
      ),
      body: Container(
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: _text, fontSize: 18.wMin, fontWeight: FontWeight.w600)),
                  SizedBox(height: 10.wMin),
                  Text('code：${tagEntity.code ?? '-'}', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                  SizedBox(height: 6.wMin),
                  Text('tagTriggerType：${tagEntity.tagTriggerType ?? '-'}', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                  SizedBox(height: 6.wMin),
                  Text('activateTime：${tagEntity.activateType ?? '-'}', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                  SizedBox(height: 6.wMin),
                  Text('duration：${tagEntity.duration ?? '-'}  durationType：${tagEntity.durationType ?? '-'}', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                  SizedBox(height: 6.wMin),
                  Text('cron：${tagEntity.cron ?? '-'}', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                  SizedBox(height: 6.wMin),
                  Text('remark：${tagEntity.remark ?? '-'}', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                ],
              ),
            ),
            SizedBox(height: 16.wMin),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.wMin),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(12.wMin),
                  border: Border.all(color: _border, width: 1.wMin),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('tagCondition (DSL)', style: TextStyle(color: _text, fontSize: 14.wMin, fontWeight: FontWeight.w600)),
                    SizedBox(height: 10.wMin),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.wMin),
                        decoration: BoxDecoration(
                          color: _panel2,
                          borderRadius: BorderRadius.circular(10.wMin),
                          border: Border.all(color: _border, width: 1.wMin),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            controller.tagConditionJson,
                            style: TextStyle(color: _text2, fontSize: 11.wMin, height: 1.25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
