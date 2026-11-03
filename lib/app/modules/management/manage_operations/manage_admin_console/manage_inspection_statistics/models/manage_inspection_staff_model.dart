import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/enum/access_enum.dart';
import 'package:langwise/utils/date_format_util.dart';

class ManageInspectionStaffStatsModel {
  final int receiving;
  final int todayOperations;
  final int notifications;
  final int tickets;
  final int studentDataOps;

  const ManageInspectionStaffStatsModel({
    required this.receiving,
    required this.todayOperations,
    required this.notifications,
    required this.tickets,
    required this.studentDataOps,
  });
}

class ManageInspectionStaffModel {
  final int userId;
  final String id;
  final String name;
  final String phone;
  final String role;
  final List<String> roleNames;
  final String access;
  final bool isOnDuty;
  final DateTime? lastActiveAt;
  final List<String> tags;
  final ManageInspectionStaffStatsModel stats;

  const ManageInspectionStaffModel({
    required this.userId,
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.roleNames,
    required this.access,
    required this.isOnDuty,
    required this.lastActiveAt,
    required this.tags,
    required this.stats,
  });

  factory ManageInspectionStaffModel.fromEntity(ManageInspectionStaffAccountItemEntity entity) {
    final roleNames = entity.roleNames ?? const <String>[];
    return ManageInspectionStaffModel(
      userId: entity.userId!,
      id: '${entity.userId}',
      name: entity.staffName!,
      phone: 'ID ${entity.userId}',
      role: roleNames.join('、'),
      roleNames: roleNames,
      access: entity.access!,
      isOnDuty: entity.access == AccessEnum.NORMAL.value,
      lastActiveAt: DateFormatUtil.tryParseDate(entity.operationTime),
      tags: entity.receivedUserNames ?? const <String>[],
      stats: ManageInspectionStaffStatsModel(
        receiving: entity.receivedUserCount!,
        todayOperations: entity.todayOperationCount!,
        notifications: entity.notifySendCount!,
        tickets: entity.ticketHandleCount!,
        studentDataOps: 0,
      ),
    );
  }
}
