class CustomCourseManagePhotosModel {
  final int? uid;
  final int? index;
  final int? size;
  String? key;
  String? imageUrl;

  CustomCourseManagePhotosModel({
    this.uid,
    this.key,
    this.size,
    this.index,
    this.imageUrl,
  });

  factory CustomCourseManagePhotosModel.fromJson(Map<String, dynamic> json) {
    return CustomCourseManagePhotosModel(
      uid: json['uid'],
      key: json['key'],
      size: json['size'],
      index: json['index'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'key': key,
      'size': size,
      'index': index,
      'imageUrl': imageUrl,
    };
  }
}
