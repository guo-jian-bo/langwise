import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'package:uuid/uuid.dart';

class ContentReviewReviewerEntity extends Dessert {
  final int userId;
  final String userName;

  ContentReviewReviewerEntity({
    required int uid,
    required this.userId,
    required this.userName,
    bool selected = false,
  }) : super(uid: uid, selected: selected);

  factory ContentReviewReviewerEntity.fromJson(Map<String, dynamic> json) {
    return ContentReviewReviewerEntity(
      uid: const Uuid().v4().hashCode,
      userId: json['userId'] is num ? (json['userId'] as num).toInt() : int.parse(json['userId'].toString()),
      userName: json['userName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ContentReviewReviewerEntity && other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);
}
