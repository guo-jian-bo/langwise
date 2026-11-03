import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'widgets.dart';

class AnchorPositionData {
  String name;
  dynamic value;
  GlobalKey key;

  AnchorPositionData({
    required this.name,
    required this.value,
    required this.key,
  });
}

class AnchorPositionWidget extends StatefulWidget {
  final List<AnchorPositionData> datas;
  final dynamic currentValue;
  final void Function(AnchorPositionData data, int index)? onIndexChanged;
  final Widget? menu;
  final TextEditingController? searchController;
  final String? hintText;
  final void Function()? onClearSearch;
  final void Function()? onSearch;
  const AnchorPositionWidget({
    super.key,
    required this.datas,
    this.currentValue,
    this.onIndexChanged,
    this.menu,
    this.searchController,
    this.hintText = "搜索",
    this.onClearSearch,
    this.onSearch,
  });

  @override
  State<AnchorPositionWidget> createState() => _AnchorPositionWidgetState();
}

class _AnchorPositionWidgetState extends State<AnchorPositionWidget> {
  @override
  Widget build(BuildContext context) {
    return PlatformBackdropFilterWidget(
      sigmaX: 8.wMin,
      sigmaY: 8.wMin,
      backgroundColor: AppTheme.cSurfaceSearchBackground.color,
      borderRadius: BorderRadius.circular(999),
      padding: EdgeInsets.all(12.wMin),
      border: Border.all(
        color: AppTheme.cBorderSubtle.color,
        width: 1.wMin,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLocalWidget(),
          Visibility(
            visible: widget.menu != null,
            child: Container(
              margin: EdgeInsets.only(left: 12.wMin),
              child: widget.menu,
            ),
          ),
          _buildSearchWidget(),
        ],
      ),
    );
  }

  Widget _buildLocalWidget(){
    return Row(
      spacing: 2.wMin,
      children: List.generate(widget.datas.length, (index) {
        return _buildLocalItemWidget(widget.datas[index], index);
      }),
    );
  }

  Widget _buildLocalItemWidget(AnchorPositionData data, int index){
    bool selected = data.value == widget.currentValue;
    return TapScaleWidget(
      onTap: () {
        widget.onIndexChanged?.call(data, index);
      },
      sclae: 1,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        height: 64.wMin,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : Colors.transparent,
            width: 1.wMin,
          ),
        ),
        child: Text(
          data.name,
          style: TextStyle(
            color: selected ? AppTheme.cSurfaceBrand.color : AppTheme.cTextTertiary.color,
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchWidget(){
    if(widget.onSearch == null) return SizedBox.shrink();
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderTertiary.color),
    );

    return Container(
      height: 64.wMin,
      width: 300.wMin,
      margin: EdgeInsets.only(left: 24.wMin),
      child: TextField(
        controller: widget.searchController,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextPrimary.color,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: AppTheme.cSurfaceSearchBackground.color,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.wMin),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.45),
          ),
          border: border,
          focusedBorder: border,
          disabledBorder: border,
          enabledBorder: border,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: (widget.searchController?.text.isNotEmpty ?? true) && widget.onClearSearch != null,
                child: TapScaleWidget(
                  onTap: () {
                    widget.searchController?.clear();
                    widget.onClearSearch?.call();
                  },
                  sclae: 1.01,
                  child: Container(
                    width: 38.wMin,
                    height: 38.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceLayerElevated2.color,
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/public/x.svg',
                      width: 24.wMin,
                      colorFilter: ColorFilter.mode(
                        AppTheme.cTextSecondary.color,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.wMin),
              Container(
                width: 1.wMin,
                height: 28.wMin,
                color: AppTheme.cBorderDark.color,
              ),
              TapScaleWidget(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  widget.onSearch?.call();
                },
                sclae: 1.03,
                child: Container(
                  height: 56.wMin,
                  width: 56.wMin - 1.wMin,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    'assets/svg/public/icon_search.svg',
                    width: 28.wMin,
                    colorFilter: ColorFilter.mode(
                      AppTheme.cTextPrimary.color,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        onChanged: (value) {
          if (mounted) setState(() {});
        },
        onSubmitted: (value) {
          widget.onSearch?.call();
        },
      ),
    );
  }

}
