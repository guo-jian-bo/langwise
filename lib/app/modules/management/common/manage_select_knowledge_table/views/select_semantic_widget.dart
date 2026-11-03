import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class SelectSemanticManager {
  static Future<void>? show(
      {required BuildContext context,
      required List<EnEntitySemantics> semantics,
      final Function(List<EnEntitySemantics>)? onCancelTap,
      final Function(List<EnEntitySemantics>)? onOkTap}) {
    return Get.dialog<void>(
      Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff040712).withValues(alpha: 0.8),
        child: UnconstrainedBox(
          alignment: Alignment.center,
          child: SelectSemanticWidget(
            semantics: semantics,
            onCancelTap: onCancelTap,
            onOkTap: onOkTap,
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      print('---选择语义弹框消失---');
      return value;
    });
  }
}

class SelectSemanticWidget extends StatefulWidget {
  final List<EnEntitySemantics> semantics;
  final Function(List<EnEntitySemantics> semantics)? onCancelTap;
  final Function(List<EnEntitySemantics> semantics)? onOkTap;

  const SelectSemanticWidget({super.key, required this.semantics, this.onCancelTap, this.onOkTap});

  @override
  State<SelectSemanticWidget> createState() => SelectSemanticWidgetState();
}

class SelectSemanticWidgetState extends State<SelectSemanticWidget> with SafeSetStateMixin {
  List<EnEntitySemantics> _semantics = [];

  EnEntitySemantics? _selectedSemantics;

  @override
  void initState() {
    super.initState();
    // 上一次选中的语义
    _selectedSemantics = widget.semantics.firstWhereOrNull((element) => (element.isSelected));
    // 深拷贝
    _semantics = widget.semantics.map((e) => e.copyWith(isSelected: false)).toList();

    // 记录选中
    for (EnEntitySemantics e in _semantics) {
      if (_selectedSemantics != null && e == _selectedSemantics) {
        e.isSelected = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 1378.ww,
        height: 720.wh,
        alignment: Alignment.center,
        padding: EdgeInsets.all(24.ww),
        decoration: BoxDecoration(
          color: const Color(0xff181B25),
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ManageTitleWidget(
              title: '选择语义',
              textStyle: TextStyle(
                fontSize: 16.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
              onCloseTap: () {
                Get.back();
              },
            ),
            Gaps.getHeight(32.wh),
            Expanded(
              child: AnimationLimiter(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // 每行5列
                      crossAxisCount: 3,
                      // 行间距
                      mainAxisSpacing: 16.wMin,
                      // 列间距
                      crossAxisSpacing: 16.wMin,
                      // 子组件宽高比
                      childAspectRatio: 432 / 188),
                  itemCount: _semantics.length,
                  addAutomaticKeepAlives: true,
                  itemBuilder: (context, index) {
                    final oldEntity = _semantics[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 350),
                      columnCount: _semantics.length,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: CombinedSemanticsWidget( 
                              // 使用数据唯一标识而非index
                              key: ValueKey(oldEntity.uid),
                              index: index,
                              entitySemantics: oldEntity,
                              displayMode: "card",
                              onSelectTap: (int i, EnEntitySemantics entity) {
                                for (var element in _semantics) {
                                  element.isSelected = false;
                                }

                                safeSetState(() {
                                  entity.isSelected = !entity.isSelected;
                                });
                              }),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Gaps.getHeight(24.wh),
            _buildBottomWidget(),
            Gaps.getHeight(24.wh),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff767E95),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 11.ww),
        ManageButton(
            text: "添加${selectRow.length}个知识点",
            height: 40.wh,
            padding: EdgeInsets.only(left: 16.ww, right: 16.ww),
            color: selectRow.isNotEmpty ? const Color(0xff2388FF) : const Color(0xff353E5C),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: selectRow.isNotEmpty ? const Color(0xffEBEFF5) : const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
            onTap: OptimizeUtils.noneThrottle(() {
              Get.back();
              widget.onOkTap?.call([..._semantics]);
            }, 200))
      ],
    );
  }

  List<EnEntitySemantics> get selectRow {
    return _semantics.where((element) => element.isSelected).toList();
  }
}
