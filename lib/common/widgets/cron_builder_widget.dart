import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

enum CronBuilderMode {
  everyNMinutes,
  hourly,
  daily,
  weekly,
  monthly,
  advanced,
}

class CronBuilderWidget extends StatefulWidget {
  final String? initialCron;
  final ValueChanged<String> onChanged;

  const CronBuilderWidget({
    super.key,
    this.initialCron,
    required this.onChanged,
  });

  @override
  State<CronBuilderWidget> createState() => _CronBuilderWidgetState();
}

class _CronBuilderWidgetState extends State<CronBuilderWidget> {
  CronBuilderMode _mode = CronBuilderMode.everyNMinutes;

  final TextEditingController _advancedCtrl = TextEditingController();

  int _everyMinutes = 5;
  int _hour = 0;
  int _minute = 0;
  int _weekday = 1; // 1-7
  int _dayOfMonth = 1; // 1-31

  @override
  void initState() {
    super.initState();
    _advancedCtrl.text = widget.initialCron ?? '';
    _emit();
  }

  @override
  void dispose() {
    _advancedCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final cron = _buildCron();
    widget.onChanged(cron);
  }

  String _buildCron() {
    if (_mode == CronBuilderMode.advanced) {
      return _advancedCtrl.text.trim();
    }

    final sec = '0';
    switch (_mode) {
      case CronBuilderMode.everyNMinutes:
        return '$sec */$_everyMinutes * * * *';
      case CronBuilderMode.hourly:
        return '$sec $_minute * * * *';
      case CronBuilderMode.daily:
        return '$sec $_minute $_hour * * *';
      case CronBuilderMode.weekly:
        return '$sec $_minute $_hour * * $_weekday';
      case CronBuilderMode.monthly:
        return '$sec $_minute $_hour $_dayOfMonth * *';
      case CronBuilderMode.advanced:
        return _advancedCtrl.text.trim();
    }
  }

  List<DropdownMenuItem<CronBuilderMode>> _modeItems() {
    return const <MapEntry<CronBuilderMode, String>>[
      MapEntry(CronBuilderMode.everyNMinutes, '每 N 分钟'),
      MapEntry(CronBuilderMode.hourly, '每小时（指定分钟）'),
      MapEntry(CronBuilderMode.daily, '每天（指定时间）'),
      MapEntry(CronBuilderMode.weekly, '每周（指定星期+时间）'),
      MapEntry(CronBuilderMode.monthly, '每月（指定日期+时间）'),
      MapEntry(CronBuilderMode.advanced, '高级（手动输入）'),
    ].map((e) {
      return DropdownMenuItem<CronBuilderMode>(
        value: e.key,
        child: Text(e.value, style: TextStyle(fontSize: 12.wMin)),
      );
    }).toList();
  }

  Widget _numberField({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final ctrl = TextEditingController(text: value.toString());
    return SizedBox(
      width: 110.wMin,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final n = int.tryParse(v);
          if (n == null) return;
          if (n < min || n > max) return;
          onChanged(n);
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 10.wMin),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _cronPreview(String cron) {
    final parts = cron.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final valid = parts.length == 6;
    String label(int idx) => valid ? parts[idx] : '-';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10.wMin),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cron 预览', style: TextStyle(fontSize: 12.wMin, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.wMin),
          Wrap(
            spacing: 8.wMin,
            runSpacing: 8.wMin,
            children: [
              _chip('秒', label(0)),
              _chip('分', label(1)),
              _chip('时', label(2)),
              _chip('日', label(3)),
              _chip('月', label(4)),
              _chip('周', label(5)),
            ],
          ),
          SizedBox(height: 8.wMin),
          SelectableText(
            cron,
            style: TextStyle(fontSize: 11.wMin, color: const Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _chip(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Text('$title: $value', style: TextStyle(fontSize: 11.wMin)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cron = _buildCron();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<CronBuilderMode>(
          value: _mode,
          isDense: true,
          items: _modeItems(),
          style: const TextStyle(color: Colors.white),
          dropdownColor: Colors.black,
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _mode = v;
            });
            _emit();
          },
        ),
        SizedBox(height: 10.wMin),
        if (_mode == CronBuilderMode.everyNMinutes)
          Row(
            children: [
              Text('每', style: TextStyle(fontSize: 12.wMin, color: Colors.white)),
              SizedBox(width: 8.wMin),
              _numberField(
                value: _everyMinutes,
                min: 1,
                max: 59,
                onChanged: (n) {
                  setState(() {
                    _everyMinutes = n;
                  });
                  _emit();
                },
              ),
              SizedBox(width: 8.wMin),
              Text('分钟执行一次', style: TextStyle(fontSize: 12.wMin,color: Colors.white)),
            ],
          ),
        if (_mode == CronBuilderMode.hourly)
          Row(
            children: [
              Text('每小时第', style: TextStyle(fontSize: 12.wMin, color: Colors.white)),
              SizedBox(width: 8.wMin),
              _numberField(
                value: _minute,
                min: 0,
                max: 59,
                onChanged: (n) {
                  setState(() {
                    _minute = n;
                  });
                  _emit();
                },
              ),
              SizedBox(width: 8.wMin),
              Text('分钟触发', style: TextStyle(fontSize: 12.wMin, color: Colors.white)),
            ],
          ),
        if (_mode == CronBuilderMode.daily)
          Row(
            children: [
              Text('每天', style: TextStyle(fontSize: 12.wMin, color: Colors.white)),
              SizedBox(width: 8.wMin),
              _numberField(
                value: _hour,
                min: 0,
                max: 23,
                onChanged: (n) {
                  setState(() {
                    _hour = n;
                  });
                  _emit();
                },
              ),
              SizedBox(width: 8.wMin),
              Text(':', style: TextStyle(fontSize: 12.wMin, color: Colors.white)),
              SizedBox(width: 8.wMin),
              _numberField(
                value: _minute,
                min: 0,
                max: 59,
                onChanged: (n) {
                  setState(() {
                    _minute = n;
                  });
                  _emit();
                },
              ),
              SizedBox(width: 8.wMin),
              Text('触发', style: TextStyle(fontSize: 12.wMin, color: Colors.white)),
            ],
          ),
        if (_mode == CronBuilderMode.weekly)
          Row(
            children: [
              DropdownButton<int>(
                value: _weekday,
                dropdownColor: Colors.black,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('周一')),
                  DropdownMenuItem(value: 2, child: Text('周二')),
                  DropdownMenuItem(value: 3, child: Text('周三')),
                  DropdownMenuItem(value: 4, child: Text('周四')),
                  DropdownMenuItem(value: 5, child: Text('周五')),
                  DropdownMenuItem(value: 6, child: Text('周六')),
                  DropdownMenuItem(value: 7, child: Text('周日')),
                ],
                style: const TextStyle(color: Colors.white),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _weekday = v;
                  });
                  _emit();
                },
              ),
              SizedBox(width: 10.wMin),
              _numberField(
                value: _hour,
                min: 0,
                max: 23,
                onChanged: (n) {
                  setState(() {
                    _hour = n;
                  });
                  _emit();
                },
              ),
              SizedBox(width: 8.wMin),
              Text(':', style: TextStyle(fontSize: 12.wMin)),
              SizedBox(width: 8.wMin),
              _numberField(
                value: _minute,
                min: 0,
                max: 59,
                onChanged: (n) {
                  setState(() {
                    _minute = n;
                  });
                  _emit();
                },
              ),
            ],
          ),
        if (_mode == CronBuilderMode.monthly)
          Row(
            children: [
              Text('每月', style: TextStyle(fontSize: 12.wMin, color: Colors.white)),
              SizedBox(width: 8.wMin),
              _numberField(
                value: _dayOfMonth,
                min: 1,
                max: 31,
                onChanged: (n) {
                  setState(() {
                    _dayOfMonth = n;
                  });
                  _emit();
                },
              ),
              SizedBox(width: 8.wMin),
              Text('日', style: TextStyle(fontSize: 12.wMin, color: Colors.white)),
              SizedBox(width: 10.wMin),
              _numberField(
                value: _hour,
                min: 0,
                max: 23,
                onChanged: (n) {
                  setState(() {
                    _hour = n;
                  });
                  _emit();
                },
              ),
              SizedBox(width: 8.wMin),
              Text(':', style: TextStyle(fontSize: 12.wMin, color: Colors.white)),
              SizedBox(width: 8.wMin),
              _numberField(
                value: _minute,
                min: 0,
                max: 59,
                onChanged: (n) {
                  setState(() {
                    _minute = n;
                  });
                  _emit();
                },
              ),
            ],
          ),
        if (_mode == CronBuilderMode.advanced)
          TextField(
            controller: _advancedCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'cron（6 段：秒 分 时 日 月 周）'),
            onChanged: (_) => _emit(),
          ),
        SizedBox(height: 10.wMin),
        _cronPreview(cron),
      ],
    );
  }
}
