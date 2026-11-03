import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../utils/utils.dart';
import 'city_pickers_widget.dart';
import 'tap_scale_widget.dart';

class CityCascadePickerWidget extends StatefulWidget {
  final String? initDistrictCode;
  final Function(CityPickersData data)? onConfirm;

  const CityCascadePickerWidget({super.key, this.initDistrictCode, this.onConfirm});

  @override
  State<CityCascadePickerWidget> createState() => _CityCascadePickerWidgetState();

  static Future<void> showDialogPicker({
    required BuildContext context,
    String? initDistrictCode,
    required ValueChanged<CityPickersData> onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return _CityCascadePickerDialog(
          initDistrictCode: initDistrictCode,
          onConfirm: onConfirm,
        );
      },
    );
  }
}

class _CityCascadePickerWidgetState extends State<CityCascadePickerWidget> {
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _syncDisplayText();
  }

  @override
  void didUpdateWidget(covariant CityCascadePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initDistrictCode != widget.initDistrictCode) {
      _syncDisplayText();
    }
  }

  void _syncDisplayText() {
    try {
      if (widget.initDistrictCode == null || widget.initDistrictCode == '') {
        _displayText = '';
        if (mounted) setState(() {});
        return;
      }
      final util = CityPickers.utils();
      final result = util.getAreaResultByCode(widget.initDistrictCode!);
      final province = result.provinceName ?? '';
      final city = result.cityName ?? '';
      final district = result.areaName ?? '';
      _displayText = '$province $city $district'.trim();
      if (mounted) setState(() {});
    } catch (_) {
      _displayText = '';
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      sclae: 1,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        CityCascadePickerWidget.showDialogPicker(
          context: context,
          initDistrictCode: widget.initDistrictCode,
          onConfirm: (data) {
            _displayText = data.citys;
            if (mounted) setState(() {});
            widget.onConfirm?.call(data);
          },
        );
      },
      child: Container(
        height: 74.wMin,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTertiary.color,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                _displayText.isEmpty ? '请选择省份/城市/区县' : _displayText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: _displayText.isEmpty ? AppTheme.cTextTertiary.color : AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SvgPicture.asset("assets/svg/public/icon_arrow_down.svg", width: 32.wMin, height: 32.wMin, colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn)),
          ],
        ),
      ),
    );
  }
}

class _CityCascadePickerDialog extends StatefulWidget {
  final String? initDistrictCode;
  final ValueChanged<CityPickersData> onConfirm;

  const _CityCascadePickerDialog({required this.initDistrictCode, required this.onConfirm});

  @override
  State<_CityCascadePickerDialog> createState() => _CityCascadePickerDialogState();
}

class _CityCascadePickerDialogState extends State<_CityCascadePickerDialog> {
  final CityPickerUtil _util = CityPickers.utils();

  late final List<_CityNode> _provinces;
  List<_CityNode> _cities = const [];
  List<_CityNode> _districts = const [];

  _CityNode? _selectedProvince;
  _CityNode? _selectedCity;
  _CityNode? _selectedDistrict;

  @override
  void initState() {
    super.initState();

    _provinces = _util.provincesData.entries.map((e) => _CityNode(code: e.key, name: e.value)).toList();

    _initFromCode();
  }

  void _initFromCode() {
    try {
      if (widget.initDistrictCode == null || widget.initDistrictCode == '') return;

      final result = _util.getAreaResultByCode(widget.initDistrictCode!);
      final pCode = result.provinceId ?? '';
      final cCode = result.cityId ?? '';
      final dCode = result.areaId ?? '';

      final p = _provinces.firstWhereOrNull((e) => e.code == pCode);
      if (p != null) {
        _selectedProvince = p;
        _cities = _loadChildren(p.code);
      }

      final c = _cities.firstWhereOrNull((e) => e.code == cCode);
      if (c != null) {
        _selectedCity = c;
        _districts = _loadChildren(c.code);
      }

      final d = _districts.firstWhereOrNull((e) => e.code == dCode);
      if (d != null) {
        _selectedDistrict = d;
      }

      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  List<_CityNode> _loadChildren(String parentCode) {
    final Map<String, dynamic> cities = _util.citiesData;
    final Map<String, Map<String, dynamic>>? map = cities[parentCode];
    if (map == null) return const [];
    return map.entries.map((e) => _CityNode(code: e.key, name: e.value['name'] ?? '')).toList();
  }

  void _selectProvince(_CityNode n) {
    if (_selectedProvince?.code == n.code) return;
    setState(() {
      _selectedProvince = n;
      _selectedCity = null;
      _selectedDistrict = null;
      _cities = _loadChildren(n.code);
      _districts = const [];
    });
  }

  void _selectCity(_CityNode n) {
    if (_selectedCity?.code == n.code) return;
    setState(() {
      _selectedCity = n;
      _selectedDistrict = null;
      _districts = _loadChildren(n.code);
    });
  }

  void _selectDistrict(_CityNode n) {
    setState(() {
      _selectedDistrict = n;
    });

    final province = _selectedProvince?.name ?? '';
    final city = _selectedCity?.name ?? '';
    final district = _selectedDistrict?.name ?? '';
    final citys = '$province $city $district'.trim();

    widget.onConfirm(
      CityPickersData(
        citys: citys,
        districtCode: n.code,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.cSurfaceSecondary.color;
    final panel = AppTheme.cSurfaceSecondary.color;
    final divider = AppTheme.cBorderSecondary.color;
    final selectedBg = AppTheme.cSurfaceInfo.color;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          width: 1260.wMin,
          height: 796.wMin,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.2), width: 1.wMin),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 92.wMin,
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.wMin)),
                      border: Border(
                        bottom: BorderSide(color: divider, width: 1.wMin),
                      ),
                    ),
                    child: Center(
                            child: Text(
                              '选择地区',
                              style: TextStyle(
                                color: AppTheme.cTextPrimary.color,
                                fontSize: 32.wMin,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.wMin)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CityColumn(
                              title: '省份',
                              items: _provinces,
                              selectedCode: _selectedProvince?.code,
                              selectedBg: selectedBg,
                              divider: divider,
                              showChevron: true,
                              onTap: _selectProvince,
                            ),
                          ),
                          Container(width: 1.wMin, color: divider),
                          Expanded(
                            child: _CityColumn(
                              title: '城市',
                              items: _cities,
                              selectedCode: _selectedCity?.code,
                              selectedBg: selectedBg,
                              divider: divider,
                              showChevron: true,
                              emptyHint: '请选择省份',
                              onTap: _selectedProvince == null ? null : _selectCity,
                            ),
                          ),
                          Container(width: 1.wMin, color: divider),
                          Expanded(
                            child: _CityColumn(
                              title: '区县',
                              items: _districts,
                              selectedCode: _selectedDistrict?.code,
                              selectedBg: selectedBg,
                              divider: divider,
                              showChevron: false,
                              emptyHint: '请选择城市',
                              onTap: _selectedCity == null ? null : _selectDistrict,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 5.wMin,
                right: 5.wMin,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40.wMin,
                    height: 40.wMin,
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceTertiary.color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.close, size: 24.wMin, color: AppTheme.cTextTertiary.color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityColumn extends StatelessWidget {
  final String title;
  final List<_CityNode> items;
  final String? selectedCode;
  final Color selectedBg;
  final Color divider;
  final bool showChevron;
  final String? emptyHint;
  final ValueChanged<_CityNode>? onTap;

  const _CityColumn({
    required this.title,
    required this.items,
    required this.selectedCode,
    required this.selectedBg,
    required this.divider,
    required this.showChevron,
    this.emptyHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56.wMin,
          padding: EdgeInsets.symmetric(horizontal: 20.wMin),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.cTextTertiary.color,
              fontSize: 22.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    emptyHint ?? '',
                    style: TextStyle(
                      color: AppTheme.cTextTertiary.color,
                      fontSize: 22.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Scrollbar(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final it = items[index];
                      final selected = it.code == selectedCode;
                      return InkWell(
                        onTap: onTap == null ? null : () => onTap!(it),
                        child: Container(
                          height: 56.wMin,
                          padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                          color: selected ? selectedBg : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  it.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: selected ? Colors.white : AppTheme.cTextPrimary.color,
                                    fontSize: 22.wMin,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (showChevron)
                                Icon(
                                  Icons.chevron_right,
                                  size: 20.wMin,
                                  color: selected ? Colors.white : AppTheme.cTextTertiary.color,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _CityNode {
  final String code;
  final String name;

  const _CityNode({required this.code, required this.name});
}
