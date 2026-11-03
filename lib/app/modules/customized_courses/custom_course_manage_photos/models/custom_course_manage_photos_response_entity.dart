import 'custom_course_manage_photos_model.dart';

class CustomCourseManagePhotosResponseEntity {
  final int? uid;
  final String? title;
  final String? cover;
  final String? coverUrl;
  final String? subject;
  final List<CustomCourseManagePhotosModel>? bookPageList;

  CustomCourseManagePhotosResponseEntity({
    this.uid,
    this.title,
    this.cover,
    this.coverUrl,
    this.subject,
    this.bookPageList,
  });

  factory CustomCourseManagePhotosResponseEntity.fromJson(Map<String, dynamic> json) {
    return CustomCourseManagePhotosResponseEntity(
      uid: json['uid'],
      title: json['title'],
      cover: json['cover'],
      coverUrl: json['coverUrl'],
      subject: json['subject'],
      bookPageList: json['bookPageList'] != null
          ? List<CustomCourseManagePhotosModel>.from(
              json['bookPageList'].map((x) => CustomCourseManagePhotosModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'title': title,
      'cover': cover,
      'coverUrl': coverUrl,
      'subject': subject,
      'bookPageList': bookPageList,
    };
  }
}
