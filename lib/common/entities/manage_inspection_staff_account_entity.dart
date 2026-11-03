class ManageInspectionStaffAccountSummaryEntity {
  int? staffCount;
  int? receivedUserCount;
  int? todayOperationCount;
  int? notifySendCount;
  int? ticketHandleCount;

  ManageInspectionStaffAccountSummaryEntity({
    this.staffCount,
    this.receivedUserCount,
    this.todayOperationCount,
    this.notifySendCount,
    this.ticketHandleCount,
  });

  ManageInspectionStaffAccountSummaryEntity.fromJson(Map<String, dynamic> json) {
    staffCount = json['staffCount']?.toInt();
    receivedUserCount = json['receivedUserCount']?.toInt();
    todayOperationCount = json['todayOperationCount']?.toInt();
    notifySendCount = json['notifySendCount']?.toInt();
    ticketHandleCount = json['ticketHandleCount']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['staffCount'] = staffCount;
    data['receivedUserCount'] = receivedUserCount;
    data['todayOperationCount'] = todayOperationCount;
    data['notifySendCount'] = notifySendCount;
    data['ticketHandleCount'] = ticketHandleCount;
    return data;
  }
}

class ManageInspectionStaffAccountItemEntity {
  String? staffName;
  int? userId;
  List<int>? roleIds;
  List<String>? roleNames;
  String? access;
  List<String>? receivedUserNames;
  int? receivedUserCount;
  int? todayOperationCount;
  String? operationTime;
  int? notifySendCount;
  int? ticketHandleCount;

  ManageInspectionStaffAccountItemEntity({
    this.staffName,
    this.userId,
    this.roleIds,
    this.roleNames,
    this.access,
    this.receivedUserNames,
    this.receivedUserCount,
    this.todayOperationCount,
    this.operationTime,
    this.notifySendCount,
    this.ticketHandleCount,
  });

  ManageInspectionStaffAccountItemEntity.fromJson(Map<String, dynamic> json) {
    staffName = json['staffName']?.toString();
    userId = json['userId']?.toInt();
    if (json['roleIds'] != null) {
      roleIds = (json['roleIds'] as List).map((e) => (e as num).toInt()).toList();
    }
    if (json['roleNames'] != null) {
      roleNames = (json['roleNames'] as List).map((e) => e.toString()).toList();
    }
    access = json['access']?.toString();
    if (json['receivedUserNames'] != null) {
      receivedUserNames = (json['receivedUserNames'] as List).map((e) => e.toString()).toList();
    }
    receivedUserCount = json['receivedUserCount']?.toInt();
    todayOperationCount = json['todayOperationCount']?.toInt();
    operationTime = json['operationTime']?.toString();
    notifySendCount = json['notifySendCount']?.toInt();
    ticketHandleCount = json['ticketHandleCount']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['staffName'] = staffName;
    data['userId'] = userId;
    data['roleIds'] = roleIds;
    data['roleNames'] = roleNames;
    data['access'] = access;
    data['receivedUserNames'] = receivedUserNames;
    data['receivedUserCount'] = receivedUserCount;
    data['todayOperationCount'] = todayOperationCount;
    data['operationTime'] = operationTime;
    data['notifySendCount'] = notifySendCount;
    data['ticketHandleCount'] = ticketHandleCount;
    return data;
  }
}

class ManageInspectionStaffAccountPageEntity {
  int? offset;
  int? limit;
  int? count;
  List<ManageInspectionStaffAccountItemEntity>? datas;

  ManageInspectionStaffAccountPageEntity({
    this.offset,
    this.limit,
    this.count,
    this.datas,
  });

  ManageInspectionStaffAccountPageEntity.fromJson(Map<String, dynamic> json) {
    offset = json['offset']?.toInt();
    limit = json['limit']?.toInt();
    count = json['count']?.toInt();
    if (json['datas'] != null) {
      datas = (json['datas'] as List).map((e) => ManageInspectionStaffAccountItemEntity.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['offset'] = offset;
    data['limit'] = limit;
    data['count'] = count;
    data['datas'] = datas?.map((e) => e.toJson()).toList();
    return data;
  }
}

class ManageInspectionStaffAccountEntity {
  ManageInspectionStaffAccountSummaryEntity? summary;
  ManageInspectionStaffAccountPageEntity? page;

  ManageInspectionStaffAccountEntity({
    this.summary,
    this.page,
  });

  ManageInspectionStaffAccountEntity.fromJson(Map<String, dynamic> json) {
    summary = json['summary'] != null ? ManageInspectionStaffAccountSummaryEntity.fromJson(json['summary']) : null;
    page = json['page'] != null ? ManageInspectionStaffAccountPageEntity.fromJson(json['page']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['summary'] = summary?.toJson();
    data['page'] = page?.toJson();
    return data;
  }
}
