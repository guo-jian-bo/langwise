import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/utils/date_format_util.dart';

class ManageInspectionOperationRecordOperatorModel {
  final String id;
  final String name;
  final String phone;

  const ManageInspectionOperationRecordOperatorModel({
    required this.id,
    required this.name,
    required this.phone,
  });
}

class ManageInspectionOperationRecordModel {
  final String action;
  final String tag;
  final String category;
  final String title;
  final String desc;
  final DateTime time;
  final ManageInspectionOperationRecordOperatorModel operator;

  const ManageInspectionOperationRecordModel({
    required this.action,
    required this.tag,
    required this.category,
    required this.title,
    required this.desc,
    required this.time,
    required this.operator,
  });

  factory ManageInspectionOperationRecordModel.fromEntity(ManageInspectionHistoryEntity entity) {
    final actionText = _InspectionActionEnum.fromValue(entity.category).label;
    return ManageInspectionOperationRecordModel(
      action: actionText,
      tag: entity.categoryName!,
      category: entity.category!,
      title: entity.title!,
      desc: entity.content!,
      time: DateFormatUtil.tryParseDate(entity.created)!,
      operator: ManageInspectionOperationRecordOperatorModel(
        id: '${entity.userId}',
        name: entity.userName!,
        phone: entity.phoneMasked!,
      ),
    );
  }
}

enum _InspectionActionEnum {
  member('member', '学员数据'),
  receive('receive', '领取'),
  transfer('transfer', '转交'),
  ticket('ticket', '工单'),
  notify('notify', '通知'),
  view('view', '查看');

  final String value;
  final String label;

  const _InspectionActionEnum(this.value, this.label);

  static _InspectionActionEnum fromValue(String? value) {
    return _InspectionActionEnum.values.firstWhere(
      (item) => item.value == value,
      orElse: () => _InspectionActionEnum.view,
    );
  }
}
