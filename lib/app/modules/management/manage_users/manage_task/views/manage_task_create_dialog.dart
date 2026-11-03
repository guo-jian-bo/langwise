import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_multi_select_widget.dart';
import 'package:langwise/common/entities/activity_console_task_entities.dart';
import 'package:langwise/common/entities/activity_tags_entities.dart';
import 'package:langwise/common/entities/prize.dart';
import 'package:langwise/common/https/activity_tags.dart';
import 'package:langwise/common/https/activity_console_task.dart';
import 'package:langwise/common/https/prize.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manifest.g.dart';
import 'package:ui_essentials/ui_essentials.dart';

class StepModel {
  TextEditingController stepCodeController;
  TextEditingController stepNameController;
  TextEditingController roleKeyController;
  TextEditingController guideTextController;
  TextEditingController pagePathController;
  TextEditingController widgetIdController;
  String prizeText;
  TextEditingController prizeTitle;
  TextEditingController prizeDes;
  TextEditingController cntController;
  bool canSkip;
  bool onlyTip;

  StepModel(
    this.stepCodeController,
    this.stepNameController,
    this.roleKeyController,
    this.guideTextController,
    this.pagePathController,
    this.widgetIdController,
    this.prizeText,
    this.prizeTitle,
    this.prizeDes,
    this.cntController,
    this.canSkip,
    this.onlyTip,
  );
}

class ManageTaskCreateDialog {
  static Future<bool?> show({
    required BuildContext context,
  }) async {
    return await showDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ManageTaskCreateDialogWidget(),
    );
  }
}

class ManageTaskCreateDialogWidget extends StatefulWidget {
  const ManageTaskCreateDialogWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ManageTaskCreateDialogWidgetState();
  }
}

class ManageTaskCreateDialogWidgetState extends State<ManageTaskCreateDialogWidget> {
  static const Color _bg = Color(0xFF22293C);
  static const Color _panel = Color(0xFF0B1221);
  static const Color _panel2 = Color(0xFF0E172A);
  static const Color _border = Color(0x1FFFFFFF);
  static const Color _text = Color(0xFFEBEEF3);
  static const Color _text2 = Color(0xFFACB4C0);
  static const Color _primary = Color(0xFF2388FF);

  late List<StepModel> steps = [];

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _subTitleCtrl = TextEditingController();
  final TextEditingController _desCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _priorityCtrl = TextEditingController();

  final TextEditingController _visibleTagsCtrl = TextEditingController();
  final TextEditingController _permissionTagsCtrl = TextEditingController();
  final TextEditingController _excludeTagsCtrl = TextEditingController();
  final TextEditingController _blackTagsCtrl = TextEditingController();
  final TextEditingController _startAtCtrl = TextEditingController();
  final TextEditingController _endAtCtrl = TextEditingController();

  final TextEditingController _maxCompleteCtrl = TextEditingController(text: '1');
  final TextEditingController _cooldownDaysCtrl = TextEditingController(text: '0');

  DateTime? _startAt;
  DateTime? _endAt;

  final Set<String> _visibleTagCodes = <String>{};
  final Set<String> _excludeTagCodes = <String>{};
  final Set<String> _permissionTagCodes = <String>{};
  final Set<String> _blackTagCodes = <String>{};

  static const Map<String, String> _visibleTagTypeOptions = <String, String>{
    'OR': 'OR（任一命中）',
    'AND': 'AND（全部命中）',
  };

  String _visibleTagType = 'OR';
  String _permissionTagType = 'OR';

  bool _hideAfterComplete = true;
  bool _hideAfterExpire = true;

  static const Map<bool, String> _boolOptions = <bool, String>{
    false: '否',
    true: '是',
  };

  bool _isStrongHint = false;
  bool _isCompleteTag = true;

  List<ActivityTagItemEntity> _completeTagOptions = <ActivityTagItemEntity>[];
  List<String> _completeTagSelectedCodes = <String>[];

  Map<String, String> _taskTypeOptions = const <String, String>{};
  Map<String, String> _groupModeOptions = const <String, String>{};
  Map<String, String> _cooldownTimeTypeOptions = const <String, String>{};
  Map<String, String> _executePeriodTypeOptions = const <String, String>{};

  String _taskType = 'STEP';
  String _executePeriodType = 'EXECUTEONCE';
  String _groupMode = 'SEQUENTIAL';
  String _cooldownTimeType = 'DAY';
  String _taskGroup = '';
  List<TaskGroupItem> _taskGroupOptions = [];
  List<PrizeItem> _prizeOptions = [];

  @override
  void initState() {
    super.initState();
    _loadTypeOptions();
    _loadGroupList();
    _loadPrizeList();
    _loadCompleteTags();
  }

  Future<void> _loadCompleteTags() async {
    final res = await ActivityTagsUtil.tagsPage(offset: 0, limit: 200, body: const <String, dynamic>{'tagType': 'TASK'});
    final data = res?.data?.datas ?? <ActivityTagItemEntity>[];
    if (!mounted) return;
    setState(() {
      _completeTagOptions = data;
      _completeTagSelectedCodes = _completeTagSelectedCodes.where((e) => data.any((t) => t.code == e)).toList();
    });
  }

  Future<void> _loadPrizeList() async {
    final res = await PrizeRequest.getPrizeList();
    final data = res?.list ?? [];
    if (!mounted) return;
    setState(() {
      _prizeOptions = data;
    });
  }

  Future<void> _loadGroupList() async {
    final res = await ActivityConsoleTaskRequest.fetchGroupList();
    final data = res?.list ?? [];
    if (!mounted) return;
    setState(() {
      if (data.isEmpty) {
        _taskGroupOptions = [];
        _taskGroup = '';
        return;
      }
      _taskGroupOptions = data;
      _taskGroup = data.first.uid.toString();
    });
  }

  Future<void> _loadTypeOptions() async {
    final res = await ActivityConsoleTaskRequest.typeList(data: const <String, dynamic>{});
    final data = res?.data;
    if (data == null) return;

    final taskTypeOptions = data.taskType ?? const <String, String>{};
    final groupModeOptions = data.groupMode ?? const <String, String>{};
    final cooldownTimeTypeOptions = data.cooldownTimeType ?? const <String, String>{};
    final executePeriodTypeOptions = data.executePeriodType ?? const <String, String>{};

    if (!mounted) return;
    setState(() {
      _taskTypeOptions = taskTypeOptions;
      _groupModeOptions = groupModeOptions;
      _cooldownTimeTypeOptions = cooldownTimeTypeOptions;
      _executePeriodTypeOptions = executePeriodTypeOptions;

      if (_taskTypeOptions.isNotEmpty && !_taskTypeOptions.containsKey(_taskType)) {
        _taskType = _taskTypeOptions.keys.first;
      }

      if (_executePeriodTypeOptions.isNotEmpty && !_executePeriodTypeOptions.containsKey(_executePeriodType)) {
        _executePeriodType = _executePeriodTypeOptions.keys.first;
      }
      if (_groupModeOptions.isNotEmpty && !_groupModeOptions.containsKey(_groupMode)) {
        _groupMode = _groupModeOptions.keys.first;
      }
      if (_cooldownTimeTypeOptions.isNotEmpty && !_cooldownTimeTypeOptions.containsKey(_cooldownTimeType)) {
        _cooldownTimeType = _cooldownTimeTypeOptions.keys.first;
      }
    });
  }

  add() {
    final defaultRoute = GuideManifest.routes.isNotEmpty ? GuideManifest.routes.first : '';
    final defaultAnchors = GuideManifest.anchorsByRoute[defaultRoute] ?? const <String>[];
    final defaultAnchor = defaultAnchors.isNotEmpty ? defaultAnchors.first : '';

    steps.add(
      StepModel(TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController(text: defaultRoute),
          TextEditingController(text: defaultAnchor), '', TextEditingController(), TextEditingController(), TextEditingController(), false, false),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _priorityCtrl.dispose();
    _visibleTagsCtrl.dispose();
    _excludeTagsCtrl.dispose();
    _startAtCtrl.dispose();
    _endAtCtrl.dispose();
    _maxCompleteCtrl.dispose();
    _cooldownDaysCtrl.dispose();
    for (final s in steps) {
      s.stepCodeController.dispose();
      s.stepNameController.dispose();
      s.roleKeyController.dispose();
      s.guideTextController.dispose();
      s.cntController.dispose();
    }
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initial = isStart ? (_startAt ?? DateTime.now()) : (_endAt ?? DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: _bg,
            colorScheme: const ColorScheme.dark(
              primary: _primary,
              surface: _bg,
              onSurface: _text,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: _bg,
            colorScheme: const ColorScheme.dark(
              primary: _primary,
              surface: _bg,
              onSurface: _text,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startAt = dt;
        _startAtCtrl.text = _formatDateTime(dt);
      } else {
        _endAt = dt;
        _endAtCtrl.text = _formatDateTime(dt);
      }
    });
  }

  void _setTagsText() {
    final visible = _visibleTagCodes.toList()..sort();
    final exclude = _excludeTagCodes.toList()..sort();
    final permission = _permissionTagCodes.toList()..sort();
    final black = _blackTagCodes.toList()..sort();
    _visibleTagsCtrl.text = visible.join(',');
    _excludeTagsCtrl.text = exclude.join(',');
    _permissionTagsCtrl.text = permission.join(',');
    _blackTagsCtrl.text = black.join(',');
  }

  Future<void> _openTagPicker({required int type}) async {
    final current = type==0 ? _visibleTagCodes : type==1?_excludeTagCodes:type==2?_permissionTagCodes:_blackTagCodes;
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) {
        final RxBool loading = true.obs;
        final RxList<ActivityTagItemEntity> tags = <ActivityTagItemEntity>[].obs;
        final TextEditingController keywordCtrl = TextEditingController();
        final RxString keyword = ''.obs;
        final Set<String> selected = <String>{...current};

        Future<void> load() async {
          loading.value = true;
          final res = await ActivityTagsUtil.tagsPage(offset: 0, limit: 200);
          final list = res?.data?.datas ?? <ActivityTagItemEntity>[];
          tags.assignAll(list);
          loading.value = false;
        }

        load();

        List<ActivityTagItemEntity> filtered(List<ActivityTagItemEntity> raw, String kw) {
          final k = kw.trim().toLowerCase();
          if (k.isEmpty) return raw;
          return raw.where((e) {
            final uid = e.uid?.toString() ?? '';
            final code = (e.code ?? '').toLowerCase();
            final name = (e.name ?? '').toLowerCase();
            return uid.contains(k) || code.contains(k) || name.contains(k);
          }).toList();
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: _bg,
              title: Text(type==0 ? '选择可见标签' :type==1? '选择排除标签':type==2?'选择权限标签':'选择黑名单标签', style: TextStyle(color: _text, fontSize: 14.wMin, fontWeight: FontWeight.w700)),
              content: SizedBox(
                width: 720.wMin,
                height: 520.wMin,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
                      decoration: BoxDecoration(
                        color: _panel2,
                        borderRadius: BorderRadius.circular(10.wMin),
                        border: Border.all(color: _border, width: 1.wMin),
                      ),
                      child: TextField(
                        controller: keywordCtrl,
                        style: TextStyle(color: _text, fontSize: 13.wMin),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: '搜索 UID / code / name',
                          hintStyle: TextStyle(color: _text2, fontSize: 13.wMin),
                        ),
                        onChanged: (v) => keyword.value = v,
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    Expanded(
                      child: Obx(() {
                        if (loading.value) {
                          return Center(child: SizedBox(width: 18.wMin, height: 18.wMin, child: const CircularProgressIndicator(strokeWidth: 2)));
                        }
                        final list = filtered(tags, keyword.value);
                        if (list.isEmpty) {
                          return Center(child: Text('暂无数据', style: TextStyle(color: _text2, fontSize: 12.wMin)));
                        }
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => Divider(height: 1.wMin, color: _border),
                          itemBuilder: (_, idx) {
                            final t = list[idx];
                            final uid = t.code;
                            if (uid == null) return const SizedBox.shrink();
                            final checked = selected.contains(uid);
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (checked) {
                                    selected.remove(uid);
                                  } else {
                                    selected.add(uid);
                                  }
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.wMin),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: checked,
                                      onChanged: (v) {
                                        setState(() {
                                          if (v == true) {
                                            selected.add(uid);
                                          } else {
                                            selected.remove(uid);
                                          }
                                        });
                                      },
                                      activeColor: _primary,
                                    ),
                                    SizedBox(width: 8.wMin),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${t.name ?? '-'}', style: TextStyle(color: _text, fontSize: 13.wMin, fontWeight: FontWeight.w600)),
                                          SizedBox(height: 4.wMin),
                                          Text('UID: $uid   CODE: ${t.code ?? '-'}', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    keywordCtrl.dispose();
                    Navigator.of(dialogContext).pop(null);
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    keywordCtrl.dispose();
                    Navigator.of(dialogContext).pop(<String>{...selected});
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;
    setState(() {
      if (type==0) {
        _visibleTagCodes
          ..clear()
          ..addAll(result);
      } else if (type==1) {
        _excludeTagCodes
          ..clear()
          ..addAll(result);
      }else if(type==2){
        _permissionTagCodes..clear()..addAll(result);
      }else{
        _blackTagCodes..clear()..addAll(result);
      }
      _setTagsText();
    });
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.wMin),
      child: Text(
        required ? '$text *' : text,
        style: TextStyle(color: _text, fontSize: 13.wMin, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBox({required Widget child, double? height}) {
    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 10.wMin),
      decoration: BoxDecoration(
        color: _panel2,
        borderRadius: BorderRadius.circular(10.wMin),
        border: Border.all(color: _border, width: 1.wMin),
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int? maxLines,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      style: TextStyle(color: _text, fontSize: 13.wMin),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: hint,
        hintStyle: TextStyle(color: _text2, fontSize: 13.wMin),
      ),
    );
  }

  Widget _buildDropdownBox({
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    String Function(String value)? labelBuilder,
  }) {
    if (options.isEmpty) {
      return _buildBox(
        child: Text('加载中', style: TextStyle(color: _text2, fontSize: 13.wMin)),
      );
    }

    final safeValue = options.contains(value) ? value : options.first;

    return _buildBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isDense: true,
          dropdownColor: _panel,
          iconEnabledColor: _text2,
          style: TextStyle(color: _text, fontSize: 13.wMin),
          items: options
              .map(
                (k) => DropdownMenuItem<String>(
                  value: k,
                  child: Text(labelBuilder?.call(k) ?? k, style: TextStyle(color: _text, fontSize: 13.wMin)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildBoolDropdownBox({required bool value, required ValueChanged<bool> onChanged}) {
    final keys = _boolOptions.keys.toList();
    final safeValue = keys.contains(value) ? value : keys.first;
    return _buildBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool>(
          value: safeValue,
          isDense: true,
          dropdownColor: _panel,
          iconEnabledColor: _text2,
          style: TextStyle(color: _text, fontSize: 13.wMin),
          items: keys
              .map(
                (k) => DropdownMenuItem<bool>(
                  value: k,
                  child: Text(_boolOptions[k] ?? k.toString(), style: TextStyle(color: _text, fontSize: 13.wMin)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildKeyDropdownBox({
    required String value,
    required Map<String, String> options,
    required ValueChanged<String> onChanged,
  }) {
    if (options.isEmpty) {
      return _buildBox(
        child: Text('加载中', style: TextStyle(color: _text2, fontSize: 13.wMin)),
      );
    }

    final keys = options.keys.toList();
    final safeValue = options.containsKey(value) ? value : keys.first;

    return _buildBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          dropdownColor: _panel,
          iconEnabledColor: _text2,
          isDense: true,
          style: TextStyle(color: _text, fontSize: 13.wMin),
          items: keys
              .map(
                (k) => DropdownMenuItem<String>(
                  value: k,
                  child: Text(options[k] ?? k, style: TextStyle(color: _text, fontSize: 13.wMin)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _stepCard(int idx, StepModel model) {
    final routeOptions = GuideManifest.routes;
    final currentRouteText = model.pagePathController.text;
    final selectedRoute = routeOptions.contains(currentRouteText) ? currentRouteText : (routeOptions.isNotEmpty ? routeOptions.first : '');

    final anchorOptions = GuideManifest.anchorsByRoute[selectedRoute] ?? const <String>[];
    final currentAnchorText = model.widgetIdController.text;
    final selectedAnchor = anchorOptions.contains(currentAnchorText) ? currentAnchorText : (anchorOptions.isNotEmpty ? anchorOptions.first : '');

    final routeLabels = GuideManifest.routeLabels;
    final anchorLabelsByRoute = GuideManifest.anchorLabelsByRoute;
    // bool showPrizeDetail = model.prizeText.isNotEmpty;

    if (selectedRoute != currentRouteText) {
      model.pagePathController.text = selectedRoute;
      model.widgetIdController.text = selectedAnchor;
    } else if (selectedAnchor != currentAnchorText) {
      model.widgetIdController.text = selectedAnchor;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.wMin),
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(color: _border, width: 1.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('步骤${idx + 1}', style: TextStyle(color: _text, fontSize: 13.wMin, fontWeight: FontWeight.w600)),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      steps.removeAt(idx);
                    });
                  },
                  child: SvgPicture.asset('assets/svg/public/icon_delete.svg', width: 20.wMin, height: 20.wMin)),
            ],
          ),
          SizedBox(height: 12.wMin),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('步骤名称', required: true),
                    _buildBox(
                      child: _buildTextField(controller: model.stepNameController, hint: '请输入步骤名称'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('规则键', required: true),
                    _buildBox(
                      child: _buildTextField(controller: model.roleKeyController, hint: '请输入规则键'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('页面路径', required: true),
                    _buildDropdownBox(
                      value: selectedRoute,
                      options: routeOptions,
                      labelBuilder: (v) {
                        final label = routeLabels[v];
                        if (label == null || label.isEmpty) return v;
                        return '$label ($v)';
                      },
                      onChanged: (v) {
                        setState(() {
                          model.pagePathController.text = v;
                          final anchors = GuideManifest.anchorsByRoute[v] ?? const <String>[];
                          model.widgetIdController.text = anchors.isNotEmpty ? anchors.first : '';
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('控件ID', required: true),
                    _buildDropdownBox(
                      value: selectedAnchor,
                      options: anchorOptions,
                      labelBuilder: (v) {
                        final label = anchorLabelsByRoute[selectedRoute]?[v];
                        if (label == null || label.isEmpty) return v;
                        return '$label ($v)';
                      },
                      onChanged: (v) {
                        setState(() {
                          model.widgetIdController.text = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          _buildLabel('引导文案'),
          _buildBox(
            child: _buildTextField(controller: model.guideTextController, hint: '请输入引导文案', maxLines: 2),
          ),
          SizedBox(height: 12.wMin),
          _buildLabel('步骤奖励'),
          Row(
            children: [
              Expanded(
                child: _buildDropdownBox(
                  value: model.prizeText,
                  options: ['', ..._prizeOptions.map((e) => e.uid.toString())],
                  labelBuilder: (v) {
                    if (v.isEmpty) return '无奖励';
                    PrizeItem? item;
                    for (final e in _prizeOptions) {
                      if (e.uid.toString() == v) {
                        item = e;
                        break;
                      }
                    }
                    final name = item?.name;
                    if (name == null || name.isEmpty) return v;
                    return '$name ($v)';
                  },
                  onChanged: (v) => setState(() {
                    if (v.isNotEmpty) {}
                    model.prizeText = v;
                  }),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          _buildLabel('奖励标题'),
          _buildBox(
            child: _buildTextField(controller: model.prizeTitle, hint: '请输入奖励标题'),
          ),
          SizedBox(height: 12.wMin),
          _buildLabel('奖励描述'),
          _buildBox(
            child: _buildTextField(controller: model.prizeDes, hint: '请输入奖励描述'),
          ),
          SizedBox(height: 12.wMin),
          Row(
            children: [
              SizedBox(
                width: 160.wMin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('可跳过'),
                    _buildBoolDropdownBox(value: model.canSkip, onChanged: (v) => setState(() => model.canSkip = v)),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 160.wMin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('仅提示'),
                    _buildBoolDropdownBox(value: model.onlyTip, onChanged: (v) => setState(() => model.onlyTip = v)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 980.wMin, maxHeight: 860.wMin),
          child: Container(
            width: 960.wMin,
            padding: EdgeInsets.all(22.wMin),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(color: _border, width: 1.wMin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('创建任务', style: TextStyle(color: _text, fontSize: 18.wMin, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    InkWell(
                      onTap: () => Get.back(),
                      child: Icon(Icons.close, color: _text2, size: 20.wMin),
                    ),
                  ],
                ),
                SizedBox(height: 14.wMin),
                Divider(height: 1.wMin, color: _border),
                SizedBox(height: 18.wMin),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('任务名称', required: true),
                                _buildBox(child: _buildTextField(controller: _nameCtrl, hint: '请输入任务名称')),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('任务编码', required: true),
                                _buildBox(child: _buildTextField(controller: _codeCtrl, hint: '请输入任务编码')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('任务副标题', required: true),
                                _buildBox(child: _buildTextField(controller: _subTitleCtrl, hint: '请输入任务副标题')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('任务描述', required: true),
                                _buildBox(child: _buildTextField(controller: _desCtrl, hint: '请输入任务描述')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('任务类型'),
                                _buildKeyDropdownBox(
                                  value: _taskType,
                                  options: _taskTypeOptions,
                                  onChanged: (v) => setState(() => _taskType = v),
                                )
                              ],
                            ),
                          ),
                          if (_taskType == 'STEP') SizedBox(width: 12.wMin),
                          if (_taskType == 'STEP')
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('分组模式'),
                                  _buildKeyDropdownBox(
                                    value: _groupMode,
                                    options: _groupModeOptions,
                                    onChanged: (v) => setState(() => _groupMode = v),
                                  )
                                ],
                              ),
                            ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('执行周期'),
                                _buildKeyDropdownBox(
                                  value: _executePeriodType,
                                  options: _executePeriodTypeOptions,
                                  onChanged: (v) => setState(() => _executePeriodType = v),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('任务分组'),
                            _buildDropdownBox(
                              value: _taskGroup,
                              options: _taskGroupOptions.map((e) => e.uid.toString()).toList(),
                              labelBuilder: (v) {
                                TaskGroupItem? item;
                                for (final e in _taskGroupOptions) {
                                  if (e.uid.toString() == v) {
                                    item = e;
                                    break;
                                  }
                                }
                                final name = item?.name;
                                if (name == null || name.isEmpty) return v;
                                return '$name';
                              },
                              onChanged: (v) => setState(() => _taskGroup = v),
                            ),
                          ])),
                        ],
                      ),
                      SizedBox(height: 16.wMin),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_buildLabel('优先级'), _buildBox(child: _buildTextField(controller: _priorityCtrl, hint: '请输入优先级', keyboardType: TextInputType.number))]),
                      SizedBox(height: 16.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('是否强提示'),
                                _buildBoolDropdownBox(value: _isStrongHint, onChanged: (v) => setState(() => _isStrongHint = v)),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('激活标签'),
                                _buildBoolDropdownBox(value: _isCompleteTag, onChanged: (v) => setState(() => _isCompleteTag = v)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.wMin),
                      if (_isCompleteTag) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('激活标签列表'),
                            ManageMultiSelectWidget(
                              title: '',
                              height: 50.wh,
                              readOnly: false,
                              hintText: '选择激活标签',
                              options: _completeTagOptions.map((e) => e.name ?? e.code?.toString() ?? '').where((e) => e.isNotEmpty).toList(),
                              selectedValues: _completeTagSelectedCodes
                                  .map((code) {
                                    final t = _completeTagOptions.firstWhereOrNull((e) => e.code == code);
                                    return t?.name ?? '';
                                  })
                                  .where((e) => e.isNotEmpty)
                                  .toList(),
                              onChanged: (indexes) {
                                final selected = <String>[];
                                for (final i in indexes) {
                                  if (i < 0 || i >= _completeTagOptions.length) continue;
                                  final code = _completeTagOptions[i].code;
                                  if (code != null) selected.add(code);
                                }
                                setState(() {
                                  _completeTagSelectedCodes = selected;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16.wMin),
                      ],
                      Row(
                        children: [
                          Text('任务步骤', style: TextStyle(color: _text, fontSize: 14.wMin, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          InkWell(
                            onTap: () => add(),
                            child: Container(
                              height: 32.wMin,
                              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                              decoration: BoxDecoration(
                                color: _panel2,
                                borderRadius: BorderRadius.circular(10.wMin),
                                border: Border.all(color: _border, width: 1.wMin),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, size: 16.wMin, color: _text),
                                  SizedBox(width: 6.wMin),
                                  Text('新增步骤', style: TextStyle(color: _text, fontSize: 12.wMin, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.wMin),
                      Container(
                        height: 400.wMin,
                        padding: EdgeInsets.all(12.wMin),
                        decoration: BoxDecoration(
                          color: _panel2,
                          borderRadius: BorderRadius.circular(12.wMin),
                          border: Border.all(color: _border, width: 1.wMin),
                        ),
                        child: steps.isEmpty
                            ? Center(child: Text('暂无步骤，请添加', style: TextStyle(color: _text2, fontSize: 12.wMin)))
                            : ListView.builder(
                                itemCount: steps.length,
                                itemBuilder: (ctx, idx) {
                                  final model = steps[idx];
                                  return _stepCard(idx, model);
                                },
                              ),
                      ),
                      SizedBox(height: 16.wMin),
                      Text('可见性与时间控制', style: TextStyle(color: Colors.white, fontSize: 18.wMin, fontWeight: FontWeight.w700)),
                      SizedBox(height: 12.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('可见标签'),
                                InkWell(
                                  onTap: () => _openTagPicker(type: 0),
                                  child: _buildBox(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(_visibleTagsCtrl.text.isEmpty ? '输入标签UID，逗号分隔' : _visibleTagsCtrl.text,
                                                style: TextStyle(color: _visibleTagsCtrl.text.isEmpty ? _text2 : _text, fontSize: 13.wMin))),
                                        Icon(Icons.keyboard_arrow_down, color: _text2, size: 18.wMin),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('可见标签类型'),
                                _buildKeyDropdownBox(
                                  value: _visibleTagType,
                                  options: _visibleTagTypeOptions,
                                  onChanged: (v) => setState(() => _visibleTagType = v),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('排除标签'),
                                InkWell(
                                  onTap: () => _openTagPicker(type: 1),
                                  child: _buildBox(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(_excludeTagsCtrl.text.isEmpty ? '输入标签UID，逗号分隔' : _excludeTagsCtrl.text,
                                                style: TextStyle(color: _excludeTagsCtrl.text.isEmpty ? _text2 : _text, fontSize: 13.wMin))),
                                        Icon(Icons.keyboard_arrow_down, color: _text2, size: 18.wMin),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('权限标签'),
                                InkWell(
                                  onTap: () => _openTagPicker(type: 2),
                                  child: _buildBox(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(_permissionTagsCtrl.text.isEmpty ? '输入标签UID，逗号分隔' : _permissionTagsCtrl.text,
                                                style: TextStyle(color: _permissionTagsCtrl.text.isEmpty ? _text2 : _text, fontSize: 13.wMin))),
                                        Icon(Icons.keyboard_arrow_down, color: _text2, size: 18.wMin),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('权限标签类型'),
                                _buildKeyDropdownBox(
                                  value: _permissionTagType,
                                  options: _visibleTagTypeOptions,
                                  onChanged: (v) => setState(() => _permissionTagType = v),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('黑名单标签'),
                                InkWell(
                                  onTap: () => _openTagPicker(type: 3),
                                  child: _buildBox(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(_blackTagsCtrl.text.isEmpty ? '输入标签UID，逗号分隔' : _blackTagsCtrl.text,
                                                style: TextStyle(color: _blackTagsCtrl.text.isEmpty ? _text2 : _text, fontSize: 13.wMin))),
                                        Icon(Icons.keyboard_arrow_down, color: _text2, size: 18.wMin),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('开始时间'),
                                InkWell(
                                  onTap: () => _pickDateTime(isStart: true),
                                  child: _buildBox(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(_startAtCtrl.text.isEmpty ? '年 / 月 / 日 --:--' : _startAtCtrl.text,
                                                style: TextStyle(color: _startAtCtrl.text.isEmpty ? _text2 : _text, fontSize: 13.wMin))),
                                        Icon(Icons.calendar_today_outlined, color: _text2, size: 16.wMin),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('结束时间'),
                                InkWell(
                                  onTap: () => _pickDateTime(isStart: false),
                                  child: _buildBox(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(_endAtCtrl.text.isEmpty ? '年 / 月 / 日 --:--' : _endAtCtrl.text,
                                                style: TextStyle(color: _endAtCtrl.text.isEmpty ? _text2 : _text, fontSize: 13.wMin))),
                                        Icon(Icons.calendar_today_outlined, color: _text2, size: 16.wMin),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('最大完成次数'),
                                _buildBox(child: _buildTextField(controller: _maxCompleteCtrl, hint: '1', keyboardType: TextInputType.number)),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('冷却时间'),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildBox(
                                        child: _buildTextField(controller: _cooldownDaysCtrl, hint: '0', keyboardType: TextInputType.number),
                                      ),
                                    ),
                                    SizedBox(width: 12.wMin),
                                    SizedBox(
                                      width: 160.wMin,
                                      child: _buildKeyDropdownBox(
                                        value: _cooldownTimeType,
                                        options: _cooldownTimeTypeOptions,
                                        onChanged: (v) => setState(() => _cooldownTimeType = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.wMin),
                      Row(
                        children: [
                          Checkbox(
                            value: _hideAfterComplete,
                            onChanged: (v) => setState(() => _hideAfterComplete = v ?? false),
                            activeColor: _primary,
                          ),
                          Text('完成后在列表中隐藏', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                          SizedBox(width: 18.wMin),
                          Checkbox(
                            value: _hideAfterExpire,
                            onChanged: (v) => setState(() => _hideAfterExpire = v ?? false),
                            activeColor: _primary,
                          ),
                          Text('过期后在列表中隐藏', style: TextStyle(color: _text2, fontSize: 12.wMin)),
                        ],
                      ),
                    ],
                  ),
                )),
                SizedBox(height: 14.wMin),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          height: 44.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _panel2,
                            borderRadius: BorderRadius.circular(10.wMin),
                            border: Border.all(color: _border, width: 1.wMin),
                          ),
                          child: Text('取消', style: TextStyle(color: _text, fontSize: 14.wMin, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.wMin),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          create();
                        },
                        child: Container(
                          height: 44.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(10.wMin),
                          ),
                          child: Text('确定创建', style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void create() {
    List<ActivityConsoleTaskStep> mSteps = [];
    if (steps.isNotEmpty) {
      for (int i = 0; i < steps.length; i++) {
        var s = steps[i];

        final path = s.pagePathController.text.trim();
        final widgetId = s.widgetIdController.text.trim();

        if (!GuideManifest.routes.contains(path)) {
          Get.snackbar('创建失败', '步骤${i + 1} 页面路径不在可选清单中: $path');
          return;
        }
        final validAnchors = GuideManifest.anchorsByRoute[path] ?? const <String>[];
        if (!validAnchors.contains(widgetId)) {
          Get.snackbar('创建失败', '步骤${i + 1} 控件ID不在该路由可选清单中: $widgetId');
          return;
        }

        if (i == 0) {
          mSteps.add(ActivityConsoleTaskStep(
            stepCode: s.stepCodeController.text,
            name: s.stepNameController.text,
            order: i + 1,
            guideText: s.guideTextController.text,
            ruleKey: s.roleKeyController.text,
            groupCode: 'PROFILE',
            path: path,
            widgetId: widgetId,
            tipOnly: s.onlyTip,
          ));
        } else {
          mSteps.add(ActivityConsoleTaskStep(
              stepCode: s.stepCodeController.text,
              name: s.stepNameController.text,
              order: i + 1,
              guideText: s.guideTextController.text,
              ruleKey: s.roleKeyController.text,
              groupCode: 'PROFILE',
              dependsOn: [mSteps[i - 1].stepCode],
              path: path,
              widgetId: widgetId,
              tipOnly: s.onlyTip));
        }

        mSteps[i].rewards =
            s.prizeText.isEmpty ? [] : [ActivityConsoleTaskPrizeConfig(prizeId: int.tryParse(s.prizeText), title: s.prizeTitle.text, description: s.prizeDes.text, count: 1)];
      }
    }
    var data = {
      'taskCode': _codeCtrl.text,
      'name': _nameCtrl.text,
      "executePeriodType": _executePeriodType,
      "description": _subTitleCtrl.text,
      "deputyDescription": _desCtrl.text,
      "taskType": _taskType,
      "groupCode": _taskGroup,
      "groupMode": _groupMode,
      "sequenceOrder": 1,
      'steps': mSteps,
      "stepMode": _groupMode,
      "completionPolicy": {"requireAllGroups": true, "requireAllRequiredSteps": true},
      "isStrongHint": _isStrongHint,
      "isCompleteTag": _isCompleteTag,
      "completeTags": _isCompleteTag ? _completeTagSelectedCodes : <String>[],
      "displayConfig": {
        "visibleTags": _visibleTagCodes.toList(),
        "visibleTagType": _visibleTagType,
        "visibleExcludeTags": _excludeTagCodes.toList(),
        "permissionTags": _permissionTagCodes.toList(),
        "permissionTagType": _permissionTagType,
        "permissionExcludeTags": _blackTagCodes.toList(),
        "hideIfCompleted": _hideAfterComplete,
        "hideIfExpired": _hideAfterExpire,
        "visibleValidFrom": _startAtCtrl.text,
        "visibleValidTo": _endAtCtrl.text,
      },
      "cooldownDays": _cooldownDaysCtrl.text,
      "maxCompletions": _maxCompleteCtrl.text,
      "priority": _priorityCtrl.text,
      "startDate": _startAtCtrl.text,
      "endDate": _endAtCtrl.text,
    };
    ActivityConsoleTaskRequest.create(data: data);
  }
}
