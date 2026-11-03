import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'package:uuid/uuid.dart';

class ImageStyleConfigV2ResponseData {
  final Map<String, List<ImageStyleConfigV2Item>> groups;

  const ImageStyleConfigV2ResponseData({
    required this.groups,
  });

  factory ImageStyleConfigV2ResponseData.fromJson(dynamic json) {
    final Map<String, List<ImageStyleConfigV2Item>> groups = {};

    if (json is Map) {
      json.forEach((key, value) {
        if (value is List) {
          final list = <ImageStyleConfigV2Item>[];
          for (final e in value) {
            if (e is Map<String, dynamic>) {
              list.add(ImageStyleConfigV2Item.fromJson(e));
            }
          }
          groups[key.toString()] = list;
        }
      });
    }

    return ImageStyleConfigV2ResponseData(groups: groups);
  }

  Map<String, dynamic> toJson() {
    return groups.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()));
  }
}

class ImageStyleConfigV2Item extends Dessert {
  final String uniqueId;
  final List<String>? iconUrls;
  final String? style;
  final String? styleTitle;
  final String? locale;
  final String? localeTitle;
  final String? vipType;
  final int? rightsId;
  final List<String>? imageUrl;
  final num? order;

  ImageStyleConfigV2Item({
    String? uniqueId,
    this.iconUrls,
    this.style,
    this.styleTitle,
    this.locale,
    this.localeTitle,
    this.vipType,
    this.rightsId,
    this.imageUrl,
    this.order,
    required int uid,
  })  : uniqueId = uniqueId ?? _generateUniqueId(),
        globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid);

  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  final GlobalKey globalKey;

  factory ImageStyleConfigV2Item.fromJson(Map<String, dynamic> json) {
    List<String>? iconUrls;
    final rawIconUrls = json['iconUrls'];
    if (rawIconUrls is List) {
      iconUrls = rawIconUrls.map((e) => e.toString()).toList();
    }

    List<String>? imageUrl;
    final rawImageUrl = json['imageUrl'];
    if (rawImageUrl is List) {
      imageUrl = rawImageUrl.map((e) => e.toString()).toList();
    }

    return ImageStyleConfigV2Item(
      uniqueId: json['uniqueId']?.toString(),
      uid: json['uid'] is num ? (json['uid'] as num).toInt() : int.tryParse(json['uid']?.toString() ?? '') ?? 0,
      iconUrls: iconUrls,
      style: json['style']?.toString(),
      styleTitle: json['styleTitle']?.toString(),
      locale: json['locale']?.toString(),
      localeTitle: json['localeTitle']?.toString(),
      vipType: json['vipType']?.toString(),
      rightsId: json['rightsId'] is num ? (json['rightsId'] as num).toInt() : int.tryParse(json['rightsId']?.toString() ?? ''),
      imageUrl: imageUrl,
      order: json['order'] is num ? (json['order'] as num) : num.tryParse(json['order']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniqueId': uniqueId,
      'uid': uid,
      'iconUrls': iconUrls,
      'style': style,
      'styleTitle': styleTitle,
      'locale': locale,
      'localeTitle': localeTitle,
      'vipType': vipType,
      'rightsId': rightsId,
      'imageUrl': imageUrl,
      'order': order,
    };
  }

  @override
  int get hashCode => uniqueId.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageStyleConfigV2Item && other.uniqueId == uniqueId;
  }
}
