
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';

class CityPickersData {
  /// 省市区
  final String citys;
  /// 区县code
  final String districtCode;

  CityPickersData({
    required this.citys,
    required this.districtCode,
  });
}

class CityPickersWidget extends StatefulWidget {
  final String? initDistrictCode;
  final Function(CityPickersData data)? onConfirm;
  const CityPickersWidget({super.key, this.initDistrictCode, this.onConfirm});

  @override
  State<CityPickersWidget> createState() => _CityPickersWidgetState();
}

class _CityPickersWidgetState extends State<CityPickersWidget> {

  CityPickerUtil cityPickerUtils = CityPickers.utils();

  List<IconDropdownCheckData<String>> provincesData = [];
  List<IconDropdownCheckData<String>> citiesData = [];
  List<IconDropdownCheckData<String>> districtsData = [];

  
  String province = "";
  String city = "";
  String district = "";

  String provinceCode = "";
  String cityCode = "";
  String districtCode = "";

  int provinceIndex = -1;
  int cityIndex = -1;
  int districtIndex = -1;

  @override
  void initState() {
    super.initState();
    getProvincesData();
    init();
  }

  @override
  void didUpdateWidget(covariant CityPickersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.initDistrictCode != widget.initDistrictCode){
      init();
    }
  }

  void init(){
    try {
      if(widget.initDistrictCode == null || widget.initDistrictCode == "") return;
      Result result = cityPickerUtils.getAreaResultByCode(widget.initDistrictCode!);
      province = result.provinceName??"";
      city = result.cityName??"";
      district = result.areaName??"";
      provinceCode = result.provinceId??"";
      cityCode = result.cityId??"";
      districtCode = result.areaId??"";
      

      Map<String, dynamic> cities = cityPickerUtils.citiesData;
      Map<String, Map<String, dynamic>>? cityMap = cities[provinceCode];
      if(cityMap == null) return;
      citiesData = cityMap.entries.map((e) => IconDropdownCheckData(title: e.value['name']??'', value: e.key)).toList();
      Map<String, Map<String, dynamic>>? districtMap = cities[cityCode];
      if(districtMap == null) return;
      districtsData = districtMap.entries.map((e) => IconDropdownCheckData(title: e.value['name']??'', value: e.key)).toList();
      provinceIndex = provincesData.indexWhere((e) => e.value == provinceCode);
      cityIndex = citiesData.indexWhere((e) => e.value == cityCode);
      districtIndex = districtsData.indexWhere((e) => e.value == districtCode);
    } catch (e) {
      print("初始化城市组件错误:$e");
    }
  }

  void getProvincesData(){
    Map<String, String> provinces = cityPickerUtils.provincesData;
    provincesData = provinces.entries.map((e) => IconDropdownCheckData(title: e.value, value: e.key)).toList();
  }

  Future<void> selectProvince(IconDropdownCheckData<dynamic> data, int index) async {
    if(provinceIndex != index){
      city = "";
      district = "";
      cityCode = "";
      districtCode = "";
      cityIndex = -1;
      districtIndex = -1;
      citiesData.clear();
    }

    provinceIndex = index;
    province = data.title;
    provinceCode = data.value;

    Map<String, dynamic> cities = cityPickerUtils.citiesData;
    Map<String, Map<String, dynamic>> cityMap = cities[provinceCode];
    citiesData = cityMap.entries.map((e) => IconDropdownCheckData(title: e.value['name']??'', value: e.key)).toList();
    if(mounted) setState(() {});

    widget.onConfirm?.call(CityPickersData(
      citys: "$province $city $district",
      districtCode: districtCode,
    ));
  }

  Future<void> selectCity(IconDropdownCheckData<dynamic> data, int index) async {
    if(cityIndex != index){
      district = "";
      districtCode = "";
      districtIndex = -1;
      districtsData.clear();
    }

    cityIndex = index;
    city = data.title;
    cityCode = data.value;

    Map<String, dynamic> cities = cityPickerUtils.citiesData;
    Map<String, Map<String, dynamic>>? districtMap = cities[cityCode];
    if(districtMap == null) return;
    districtsData = districtMap.entries.map((e) => IconDropdownCheckData(title: e.value['name']??'', value: e.key)).toList();
    if(mounted) setState(() {});
    widget.onConfirm?.call(CityPickersData(
      citys: "$province $city $district",
      districtCode: districtCode,
    ));
  }

  Future<void> selectDistrict(IconDropdownCheckData<dynamic> data, int index) async {
    districtIndex = index;
    district = data.title;
    districtCode = data.value;
    if(mounted) setState(() {});
    widget.onConfirm?.call(CityPickersData(
      citys: "$province $city $district",
      districtCode: districtCode,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        spacing: 12.wMin,
        children: [
          Expanded(
            child: IconDropdownCheckWidget(
              items: provincesData, 
              sclae: 1.02,
              selectIndex: provinceIndex,
              onTap: selectProvince,
              child: _buildItemWidget("省份", province),
            ),
          ),
          Expanded(
            child: IconDropdownCheckWidget(
              items: citiesData, 
              sclae: 1.02,
              selectIndex: cityIndex,
              onTap: selectCity,
              child: _buildItemWidget("城市", city),
            ),
          ),
          Expanded(
            child: IconDropdownCheckWidget(
              items: districtsData, 
              sclae: 1.02,
              selectIndex: districtIndex,
              onTap: selectDistrict,
              child: _buildItemWidget("区/县", district),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(String hit, String value) {
    return Container(
      height: 64.wMin,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
      ),
      child: Row(
        children: [
          Visibility(
            visible: value.isEmpty,
            child: Expanded(
              child: Text(
                hit,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Visibility(
            visible: value.isNotEmpty,
            child: Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SvgPicture.asset(
            "assets/svg/public/icon_arrow_down.svg",
            width: 24.wMin,
            height: 24.wMin,
          ),
        ],
      ),
    );
  }
}
