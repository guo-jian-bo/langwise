
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class CopyTagWidget extends StatefulWidget {
  final String name;
  final String value;

  /// 是否禁用复制
  final bool isDisabled;

  /// 是否显示
  final bool isShow;

  /// 复制组件
  const CopyTagWidget({super.key, required this.name, required this.value, this.isDisabled = false, this.isShow = true});

  @override
  State<CopyTagWidget> createState() => _CopyTagWidgetState();
}

class _CopyTagWidgetState extends State<CopyTagWidget> {

  /// 是否显示‘已复制’ 文字
  bool showCopiedText = false;

  Future<void> copyText() async {
    if(showCopiedText) return;
    showCopiedText = true;
    if(mounted) setState(() {});
    await Clipboard.setData(ClipboardData(text: widget.value));
    await Future.delayed(Duration(seconds: 2));
    showCopiedText = false;
    if(mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    if(!widget.isShow) return Container();
    
    return TapScaleWidget(
      onTap: widget.isDisabled ? null : () {
        copyText();
      },
      sclae: 1.03,
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.12),
        border: Border.all(
          color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2.wMin,
        children: [
          Text(
            widget.name,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextBrand.color.withValues(alpha: 0.8),
            ),
          ),
          Text(
            showCopiedText ? "已复制" : widget.value,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextBrand.color,
            ),
          ),
        ],
      ),
    ),
    );
  }
}