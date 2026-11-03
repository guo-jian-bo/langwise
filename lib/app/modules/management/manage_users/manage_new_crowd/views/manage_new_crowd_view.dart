import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/activity_tags_entities.dart';
import 'package:langwise/utils/date_format_util.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/commons.dart';
import '../bindings/manage_new_crowd_binding.dart';
import '../controllers/manage_new_crowd_controller.dart';
import '../../../utils/manage_page_registry.dart';

class ManageNewCrowdView extends GetView<ManageNewCrowdController> {
  final String tagText;
  const ManageNewCrowdView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_NEW_CROWD}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageNewCrowdView(tagText: tag),
      binding: ManageNewCrowdBinding(tag: tag),
      routeName: Routes.MANAGE_NEW_CROWD,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static const Color _bg = Color(0xFF050916);
  // static const Color _panel = Color(0xFF0B1221);
  static const Color _panel2 = Color(0xFF0E172A);
  static const Color _border = Color(0x1FFFFFFF);
  static const Color _primary = Color(0xFF2388FF);

  // Note: the original tag builder UI has been moved to ManageUserEditorView.

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: _bg,
      body: Container(
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '数据总览',
                    style: TextStyle(color: const Color(0xFFEDF0F4), fontSize: 18.wMin, fontWeight: FontWeight.w400),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await ManagePageRegistry.jumpTo(
                      Routes.MANAGE_NEW_CROWD_EDITOR,
                      arguments: {'tag': null, 'parentTag': tagText},
                    );
                  },
                  child: Container(
                    height: 40.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(8.wMin)),
                    alignment: Alignment.center,
                    child: Text('新增', style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.wMin),
            Obx(() {
              return Row(
                children: [
                  Expanded(child: _overviewCard(title: '总标签数', value: '${controller.remoteTagTotal.value}')),
                  SizedBox(width: 16.wMin),
                  Expanded(child: _overviewCard(title: '覆盖用户', value: '45,290')),
                  SizedBox(width: 16.wMin),
                  Expanded(child: _overviewCard(title: '常用属性标签', value: '14')),
                  SizedBox(width: 16.wMin),
                  Expanded(child: _overviewCard(title: '今日更新', value: '12')),
                ],
              );
            }),
            SizedBox(height: 24.wMin),
            Text('人群列表', style: TextStyle(color: const Color(0xFFEBEFF5), fontSize: 18.wMin, fontWeight: FontWeight.w400)),
            SizedBox(height: 24.wMin),
            Expanded(
              child: Obx(() {
                final list = controller.remoteTags;
                if (list.isEmpty) {
                  return Center(child: Text('暂无数据', style: TextStyle(color: Color(0xFF767E95), fontSize: 14.wMin)));
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24.wMin,
                    crossAxisSpacing: 24.wMin,
                    childAspectRatio: 776 / 284,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, index) {
                    final t = list[index];
                    return _groupCard(context, t);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewCard({required String title, required String value}) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(color: const Color(0xCC19213D), borderRadius: BorderRadius.circular(12.wMin)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: const Color(0xFFACB4C0), fontSize: 14.wMin)),
          SizedBox(height: 6.wMin),
          Text(value, style: TextStyle(color: const Color(0xFFEBEFF5), fontSize: 28.wMin, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _groupCard(BuildContext context, ActivityTagItemEntity tag) {
    final title = (tag.name?.toString().trim().isNotEmpty ?? false) ? tag.name! : (tag.code ?? '-');
    final uidText = (tag.uid ?? 23456).toString();
    final created = tag.created ?? '2026-01-05';
    final updated = tag.updated ?? '实时';
    final desc1 = '对这个标签的描述';
    // final desc2 = '最多两行文字';
    final memberCount = '3,502';
    final chips = const <String>['vip_type', 'vip_status', 'vip_status', 'vip_status', 'vip_status'];

    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(color: const Color(0x8019213D), borderRadius: BorderRadius.circular(12.wMin), border: Border.all(color: const Color(0x4D444B5F), width: 0.5.wMin)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFFEBEFF5), fontSize: 20.wMin, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(width: 4.wMin),
                    Container(
                        padding: EdgeInsets.all(4.wMin),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFF23283D)),
                        child: Text('UID：$uidText', style: TextStyle(color: const Color(0xFFBAC0CC), fontSize: 12.wMin))),
                  ],
                ),
              ),
              SvgPicture.asset('assets/svg/public/icon_delete.svg', width: 24.wMin, height: 24.wMin),
            ],
          ),
          SizedBox(height: 4.wMin),
          Text('创建时间:${DateFormatUtil.formatStrtoStr(created)}  更新时间:${DateFormatUtil.formatStrtoStr(updated)}', style: TextStyle(color: const Color(0xFF767E95), fontSize: 14.wMin)),
          SizedBox(height: 8.wMin),
          Divider(color: const Color(0xFF353E5C), thickness: 1.wMin,height: 0),
          SizedBox(height: 8.wMin),
          SizedBox(child: Text(desc1, style: TextStyle(color: const Color(0xFFBAC0CC), fontSize: 14.wMin),maxLines: 2,overflow: TextOverflow.ellipsis,)),
          SizedBox(height: 12.wMin),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF23283D),
              borderRadius: BorderRadius.circular(4.wMin),
            ),
              padding: EdgeInsets.all(6.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('关联属性', style: TextStyle(color: const Color(0xFF767E95), fontSize: 14.wMin)),
                SizedBox(height: 4.wMin),
                Wrap(
                  spacing: 4.wMin,
                  runSpacing: 4.wMin,
                  children: chips
                      .map(
                        (e) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 2.wMin),
                          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(2.wMin), border: Border.all(color: Color(0xFF4B5268), width: 0.5.wMin)),
                          child: Text(e, style: TextStyle(color: const Color(0xFFBAC0CC), fontSize: 11.wMin)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const Spacer(),
          Divider(color: const Color(0xFF353E5C), thickness: 1.wMin,height: 8.wMin),
          Row(
            children: [
              Text('覆盖人数：$memberCount', style: TextStyle(color: const Color(0xFF767E95), fontSize: 14.wMin)),
              const Spacer(),
              _miniButton(
                label: '详情',
                onTap: () async {
                  await ManagePageRegistry.jumpTo(
                    Routes.MANAGE_NEW_CROWD_DETAIL,
                    arguments: {'tag': tag, 'parentTag': tagText},
                  );
                },
              ),
              SizedBox(width: 10.wMin),
              _miniButton(
                label: '编辑',
                primary: true,
                onTap: () async {
                  await ManagePageRegistry.jumpTo(
                    Routes.MANAGE_NEW_CROWD_EDITOR,
                    arguments: {'tag': tag, 'parentTag': tagText},
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniButton({required String label, required VoidCallback onTap, bool primary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.wMin,
        width: 80.wMin,
        decoration: BoxDecoration(
          color: primary ? _primary : _panel2,
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(color: _border, width: 1.wMin),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: primary ? Colors.white : const Color(0xFFBAC0CC), fontSize: 12.wMin, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
