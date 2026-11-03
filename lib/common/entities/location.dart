class LocationResponseEntity {
  final String country;
  final String province;
  final String? city;
  final String? district;
  final String addressCode;

  LocationResponseEntity({
    required this.country,
    required this.province,
    this.city,
    this.district,
    required this.addressCode,
  });

  factory LocationResponseEntity.fromJson(Map<String, dynamic> json) {
    return LocationResponseEntity(
      country: json['country'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      addressCode: json['addressCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'province': province,
      'city': city,
      'district': district,
      'addressCode': addressCode,
    };
  }
}
