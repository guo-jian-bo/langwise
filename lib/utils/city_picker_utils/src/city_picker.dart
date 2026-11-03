import 'dart:core';


import '../../utils.dart';
import '../meta/province.dart' as meta;

/// ios city pickers
/// provide config height, initLocation and so on
///
/// Sample:flutter format
/// ```
/// await CityPicker.showPicker(
///   location: String,
///   height: double
/// );
///
/// ```

class CityPickers {
  /// static original city data for this plugin
  static Map<String, dynamic> metaCities = meta.citiesData;

  /// static original province data for this plugin
  static Map<String, String> metaProvinces = meta.provincesData;

  static utils(
      {Map<String, String>? provinceData, Map<String, dynamic>? citiesData}) {
    return CityPickerUtil(
      provincesData: provinceData ?? CityPickers.metaProvinces,
      citiesData: citiesData ?? CityPickers.metaCities,
    );
  }
}