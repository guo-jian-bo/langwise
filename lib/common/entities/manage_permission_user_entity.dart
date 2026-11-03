import '../../app/modules/management/enums/enums.dart';

class ManagePermissionChannelItemEntity {
  int? uid;
  String? channel;
  String? name;

  ManagePermissionChannelItemEntity({
    this.uid,
    this.channel,
    this.name,
  });

  ManagePermissionChannelItemEntity.fromJson(Map<String, dynamic> json) {
    uid = ManagePermissionUserEntity._parseInt(json['uid']);
    channel = json['channel']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['channel'] = channel;
    data['name'] = name;
    return data;
  }
}

class ManagePermissionNotifyTemplateItemEntity {
  int? uid;
  String? name;

  ManagePermissionNotifyTemplateItemEntity({
    this.uid,
    this.name,
  });

  ManagePermissionNotifyTemplateItemEntity.fromJson(Map<String, dynamic> json) {
    uid = ManagePermissionUserEntity._parseInt(json['uid']);
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    return data;
  }
}

class ManagePermissionUserEntity {
  int? uid;
  int? userId;
  int? roleId;
  String? roleName;
  String? realName;
  int? departmentId;
  String? departmentName;
  List<int>? roleIds;
  List<String>? roleNames;
  List<int>? impersonateRoles;
  List<String>? impersonateRoleNames;
  String? adminGroup;
  String? userType;
  String? userName;
  String? access;
  String? created;
  String? updated;
  String? phoneNumber;
  String? phoneMasked;
  List<ManagePermissionChannelItemEntity>? channels;
  List<ManagePermissionNotifyTemplateItemEntity>? notifyTemplates;

  ManageUserRoleGruopEnum? get adminGroupEnum => ManageUserRoleGruopEnum.fromValue(adminGroup);

  ManagePermissionUserEntity({
    this.uid,
    this.userId,
    this.roleId,
    this.roleName,
    this.realName,
    this.departmentId,
    this.departmentName,
    this.roleIds,
    this.roleNames,
    this.impersonateRoles,
    this.impersonateRoleNames,
    this.adminGroup,
    this.userType,
    this.userName,
    this.access,
    this.created,
    this.updated,
    this.phoneNumber,
    this.phoneMasked,
    this.channels,
    this.notifyTemplates,
  });

  ManagePermissionUserEntity.fromJson(Map<String, dynamic> json) {
    uid = _parseInt(json['uid']);
    userId = _parseInt(json['userId']);
    roleId = _parseInt(json['roleId']);
    roleName = json['roleName']?.toString();
    realName = json['realName']?.toString();
    departmentId = _parseInt(json['departmentId']);
    departmentName = json['departmentName']?.toString();
    roleIds = _parseIntList(json['roleIds']);
    roleNames = _parseStringList(json['roleNames']);
    impersonateRoles = _parseIntList(json['impersonateRoles']);
    impersonateRoleNames = _parseStringList(json['impersonateRoleNames']);
    adminGroup = json['adminGroup']?.toString();
    userType = json['userType']?.toString();
    userName = json['userName']?.toString();
    access = json['access']?.toString();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
    phoneNumber = json['phoneNumber']?.toString();
    phoneMasked = json['phoneMasked']?.toString();
    if (json['channels'] is List) {
      channels = (json['channels'] as List)
          .map((item) => ManagePermissionChannelItemEntity.fromJson(item))
          .toList();
    }
    if (json['notifyTemplates'] is List) {
      notifyTemplates = (json['notifyTemplates'] as List)
          .map((item) => ManagePermissionNotifyTemplateItemEntity.fromJson(item))
          .toList();
    }
  }

  String get displayName {
    final String value = (realName ?? userName ?? '').trim();
    if (value.isNotEmpty) return value;
    if (userId != null) return '用户$userId';
    return '';
  }

  String get displayPhone {
    final String masked = (phoneMasked ?? '').trim();
    if (masked.isNotEmpty) return masked;
    return (phoneNumber ?? '').trim();
  }

  String get displayRoleName {
    final List<String> validRoleNames = (roleNames ?? []).where((e) => e.trim().isNotEmpty).toList();
    if (validRoleNames.isNotEmpty) return validRoleNames.first;
    return (roleName ?? '').trim();
  }

  int get channelCount => channels?.length ?? 0;

  int get notifyTemplateCount => notifyTemplates?.length ?? 0;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['userId'] = userId;
    data['roleId'] = roleId;
    data['roleName'] = roleName;
    data['realName'] = realName;
    data['departmentId'] = departmentId;
    data['departmentName'] = departmentName;
    data['roleIds'] = roleIds;
    data['roleNames'] = roleNames;
    data['impersonateRoles'] = impersonateRoles;
    data['impersonateRoleNames'] = impersonateRoleNames;
    data['adminGroup'] = adminGroup;
    data['userType'] = userType;
    data['userName'] = userName;
    data['access'] = access;
    data['created'] = created;
    data['updated'] = updated;
    data['phoneNumber'] = phoneNumber;
    data['phoneMasked'] = phoneMasked;
    if (channels != null) {
      data['channels'] = channels!.map((item) => item.toJson()).toList();
    }
    if (notifyTemplates != null) {
      data['notifyTemplates'] = notifyTemplates!.map((item) => item.toJson()).toList();
    }
    return data;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static List<int>? _parseIntList(dynamic value) {
    if (value is! List) return null;
    final List<int> result = value.map(_parseInt).whereType<int>().toList();
    return result;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value is! List) return null;
    final List<String> result = value.map((item) => item.toString()).toList();
    return result;
  }
}
