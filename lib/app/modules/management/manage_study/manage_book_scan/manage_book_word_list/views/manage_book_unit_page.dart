import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import '../controller.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:uuid/uuid.dart';

class ManageUnitManager {
  static Future<void>? show(
      {required BuildContext context,
      final Function(UnitResponseEntity)? onCancelTap,
      final Function(Map<String, dynamic>)? onCreateTap}) {
    return Get.dialog<void>(
      Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff040712).withValues(alpha: 0.8),
        child: UnconstrainedBox(
          alignment: Alignment.center,
          child: ManageUnitPage(
            onCancelTap: onCancelTap,
            onCreateTap: onCreateTap,
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      return value;
    });
  }
}

class ManageUnitPage extends StatefulWidget {
  final Function(UnitResponseEntity)? onCancelTap;
  final Function(Map<String, dynamic>)? onCreateTap;

  const ManageUnitPage({
    super.key,
    this.onCancelTap,
    this.onCreateTap,
  });

  @override
  State<ManageUnitPage> createState() => _ManageUnitPageState();
}

class _ManageUnitPageState extends State<ManageUnitPage> with SafeSetStateMixin {
  final List<EditableUnit> _units = [];

  late AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    _onFetchSimpleUnits();
  }

  void _onFetchSimpleUnits() async {
    final List<UnitResponseEntity> _simpleUnits = await Get.find<ManageBookWordListController>().onFetchSimpleUnits();
    safeSetState(() {
      for (final UnitResponseEntity unitResponseEntity in _simpleUnits) {
        _units.add(EditableUnit(
            uid: unitResponseEntity.unitId, name: unitResponseEntity.unitName, isEditing: false, isNet: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 720.ww,
        height: 516.wh,
        alignment: Alignment.center,
        padding: EdgeInsets.all(24.ww),
        decoration: BoxDecoration(
          color: const Color(0xff181B25),
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
        ),
        child: Column(
          children: [
            ManageTitleWidget(
              title: '编辑单元',
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
            if (_units.isNotEmpty)
              Expanded(
                child: AnimatedReorderableListView(
                    key: const PageStorageKey("ManageUnitPageList"),
                    controller: _scrollController,
                    // 去掉默认的右边编辑按钮
                    buildDefaultDragHandles: false,
                    enableSwap: false,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    enterTransition: [SlideInDown()],
                    exitTransition: [SlideInUp()],
                    insertDuration: const Duration(milliseconds: 200),
                    removeDuration: const Duration(milliseconds: 200),
                    dragStartDelay: const Duration(milliseconds: 200),
                    proxyDecorator: proxyDecorator,
                    lockedItems: _anyEditing() ? _units : <EditableUnit>[],
                    onReorder: _onReorder,
                    items: _units,
                    itemBuilder: (BuildContext context, int index) {
                      final unit = _units[index];
                      return UnitItemWidget(
                        key: PageStorageKey(unit.uniqueId),
                        unit: unit,
                        index: index,
                        scrollController: _scrollController,
                        onEditToggle: _toggleEditMode,
                        onSubmitEdit: _submitEdit,
                      );
                    },
                    isSameItem: (a, b) => a.uniqueId == b.uniqueId),
              ),
            Gaps.getHeight(10.wh),
            _buildAddUnitWidget(),
            if (_units.isEmpty) const Spacer(),
            Gaps.getHeight(10.wh),
            _buildBottomWidget()
          ],
        ),
      ),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0,
          color: const Color(0xff23283D),
          borderRadius: BorderRadius.circular(6.wMin),
          child: child,
        );
      },
      child: child,
    );
  }

  void _onReorder(int oldIndex, int newIndex) async {
    safeSetState(() {
      final EditableUnit row = _units.removeAt(oldIndex);
      _units.insert(newIndex, row);
    });

    try {
      await Get.find<ManageBookWordListController>().onSortUnits(_units.map((element) => element.uid!).toList());
    } catch (e) {
      print("排序异常e:$e");
    }
  }

  Widget _buildAddUnitWidget() {
    return Builder(builder: (BuildContext context) {
      return TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() async {
          _addUnit();
        }, 100),
        sclae: 1.03,
        child: DottedBorder(
          radius: Radius.circular(10.wMin),
          borderType: BorderType.RRect,
          padding: EdgeInsets.zero,
          color: const Color(0xff4B5268),
          dashPattern: const [4, 2],
          child: SizedBox(
            width: double.infinity,
            height: 40.wh,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildImage(Assets.managerFilterAdd, width: 18.wMax, height: 18.wMax),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _toggleEditMode(EditableUnit unit) {
    safeSetState(() {
      unit.isEditing = !unit.isEditing;
      if (!unit.isEditing) {
        unit.controller.text = unit.name ?? '';
      }
    });
  }

  // 创建单元
  void _submitEdit(EditableUnit unit) async {
    final newName = unit.controller.text.trim();
    if (newName.isEmpty) {
      ToastUtils.showManageToast(text: '单元名不能为空');
      return;
    }

    if (unit.hasCreated) {
      // 编辑
      try {
        final NewUnitResponseEntity? unitResponseEntity =
            await Get.find<ManageBookWordListController>().onEditUnit(uid: unit.uid!, name: newName);
        if (unitResponseEntity != null) {
          safeSetState(() {
            unit.name = unitResponseEntity.name;
            unit.uid = unitResponseEntity.uid;
            unit.language = unitResponseEntity.language;
            unit.isEditing = false;
          });
        }
      } catch (e) {
        ToastUtils.showManageToast(text: e.toString());
      }
    } else {
      // 创建
      try {
        final NewUnitResponseEntity? unitResponseEntity = await Get.find<ManageBookWordListController>()
            .onCreateUnit(name: newName, createSelectLanguageIndex: unit.createSelectLanguageIndex);
        if (unitResponseEntity != null) {
          safeSetState(() {
            unit.name = unitResponseEntity.name;
            unit.uid = unitResponseEntity.uid;
            unit.language = unitResponseEntity.language;
            unit.isEditing = false;
          });
        }
      } catch (e) {
        ToastUtils.showManageToast(text: e.toString());
      }
    }
  }

  // 添加单元
  void _addUnit() {
    try {
      if (_units.isEmpty) {
        safeSetState(() {
          _units.add(EditableUnit(isEditing: true));
        });
      } else {
        // 有正在编辑状态
        if (!_anyEditing()) {
          // 使用WidgetsBinding.instance.addPostFrameCallback确保在下一帧渲染完成后再添加新单元
          // 避免在当前布局过程中修改状态导致的动画问题
          WidgetsBinding.instance.addPostFrameCallback((_) {
            safeSetState(() {
              _units.add(EditableUnit());
            });
            _scrollToCounter();
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
            text: "关闭",
            width: 80.ww,
            height: 40.wh,
            color: const Color(0xff353E5C),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
            onTap: OptimizeUtils.noneThrottle(() {
              Get.back();
            }, 200))
      ],
    );
  }

  // 新增检查编辑状态的方法
  bool _anyEditing() {
    return _units.any((unit) => unit.isEditing);
  }

  Future _scrollToCounter() async {
    await _scrollController.scrollToIndex(_units.length - 1, preferPosition: AutoScrollPosition.end);
  }

  @override
  void dispose() {
    for (var unit in _units) {
      unit.controller.dispose();
    }
    _units.clear();
    super.dispose();
  }
}

// 单元项组件，负责单元项的显示和交互，使用AutomaticKeepAliveClientMixin缓存页面
class UnitItemWidget extends StatefulWidget {
  final EditableUnit unit;
  final int index;
  final AutoScrollController scrollController;
  final Function(EditableUnit) onEditToggle;
  final Function(EditableUnit) onSubmitEdit;

  const UnitItemWidget({
    Key? key,
    required this.unit,
    required this.index,
    required this.scrollController,
    required this.onEditToggle,
    required this.onSubmitEdit,
  }) : super(key: key);

  @override
  State<UnitItemWidget> createState() => _UnitItemWidgetState();
}

class _UnitItemWidgetState extends State<UnitItemWidget> with AutomaticKeepAliveClientMixin, SafeSetStateMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // 必须调用super.build
    super.build(context);

    return AutoScrollTag(
      key: ValueKey(widget.unit.uniqueId),
      controller: widget.scrollController,
      index: widget.index,
      child: Container(
        padding: EdgeInsets.only(left: 10.ww, right: 10.ww, top: 6.wh, bottom: 6.wh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: Colors.transparent,
          border: Border.all(
            width: 0.wMin,
            color: Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset("assets/svg/manage/icon_drag.svg", width: 24.wMin, height: 24.wMin),
            Gaps.getWidth(8.ww),
            Expanded(
                child: ManageTitleInputWidget(
              title: "",
              hintText: '请输入单元名',
              height: 40.wh,
              controller: widget.unit.controller,
              readOnly: !widget.unit.isEditing,
            )),
            if (!widget.unit.isNet) Gaps.getWidth(16.ww),
            if (!widget.unit.isNet)
              Expanded(
                  child: ManageSelectWidget(
                title: "",
                hintText: '请选择语言',
                value: widget.unit.createLanguageTitle,
                readOnly: widget.unit.hasCreated,
                height: 40.wh,
                options: CommonUtil.languageValues,
                onChanged: (String value, int index) {
                  safeSetState(() {
                    widget.unit.setCreateLanguage(index);
                  });
                },
              )),
            Gaps.getWidth(16.ww),
            _buildActionButton()
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return widget.unit.isEditing
        ? ManageButton(
            text: "确认",
            width: 64.ww,
            height: 40.wh,
            color: const Color(0xff353E5C),
            style: TextStyle(
              fontSize: 12.wMin,
              color: const Color(0xffACB4C0),
            ),
            onTap: OptimizeUtils.noneThrottle(() {
              widget.onSubmitEdit(widget.unit);
            }, 200),
          )
        : Container(
            width: 64.ww,
            height: 40.wh,
            padding: EdgeInsets.only(left: 22.ww, right: 22.ww, top: 12.wh, bottom: 12.wh),
            child: TapScaleWidget(
                child: buildImage(
                  Assets.managerEdit,
                ),
                onTap: () {
                  widget.onEditToggle(widget.unit);
                }),
          );
  }
}

class EditableUnit {
  int? uid;
  String? name;
  String? language;

  // 是否编辑状态/默认正在编辑
  bool isEditing;
  TextEditingController controller;
  int createSelectLanguageIndex;

  // 是否网络数据(默认不是)
  bool isNet;

  String uniqueId;

  EditableUnit({
    this.uid,
    this.name,
    this.language,
    this.isEditing = true,
    this.isNet = false,
  })  : controller = TextEditingController(text: name),
        createSelectLanguageIndex = -1,
        uniqueId = const Uuid().v6();

  bool get hasCreated => uid != null;

  // 手动创建模板/设置语言
  void setCreateLanguage(int index) {
    createSelectLanguageIndex = index;
  }

  // 语言title
  String get createLanguageTitle {
    String title = '';
    try {
      title = CommonUtil.languageValues[createSelectLanguageIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }
}
