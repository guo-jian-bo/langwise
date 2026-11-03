import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../routes/routes.dart';
import '../../../../enums/enums.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../../../../utils/toast_utils.dart';

class ManagePermissionCreateOption {
  final int id;
  final String name;
  const ManagePermissionCreateOption({required this.id, required this.name});
}

class ManagePermissionCreateGroup {
  final String title;
  final List<ManagePermissionCreateOption> options;
  const ManagePermissionCreateGroup({required this.title, required this.options});
}

class ManagePermissionCreateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManagePermissionCreateController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_PERMISSION_CREATE;

  @override
  String get breadcrumbTitle => '新建员工';

  int? userId;
  final RxBool isEnable = true.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  final RxList<ManagePermissionCreateOption> roleOptions = <ManagePermissionCreateOption>[].obs;
  final RxSet<int> selectedRoleIds = <int>{}.obs;
  final RxString positionText = ''.obs;

  final Rx<ManageUserRoleGruopEnum> selectedAdminGroup = ManageUserRoleGruopEnum.CHANNEL.obs;

  final RxSet<int> selectedChannelIds = <int>{}.obs;
  final RxSet<int> selectedNotifyTemplateIds = <int>{}.obs;

  final RxList<ManagePermissionCreateGroup> channelGroups = <ManagePermissionCreateGroup>[].obs;

  final RxList<ManagePermissionCreateGroup> notifyTemplateGroups = <ManagePermissionCreateGroup>[].obs;

  List<ManageChannelEntity> _channelList = <ManageChannelEntity>[];

  bool get isEdit => userId != null;

  Set<int> _buildInitChannelIds(List<ManagePermissionChannelItemEntity>? channels) {
    final Set<int> ids = (channels ?? []).map((item) => item.uid).whereType<int>().toSet();
    if (_channelList.isEmpty) return ids;
    final List<String> codes = (channels ?? [])
        .where((item) => item.uid == null)
        .map((item) => item.channel?.trim() ?? '')
        .where((code) => code.isNotEmpty)
        .toList();
    if (codes.isEmpty) return ids;

    final Map<String, int> childCodeToUid = <String, int>{};
    final Map<String, Set<int>> parentCodeToChildUids = <String, Set<int>>{};
    for (final ManageChannelEntity parent in _channelList) {
      final String parentCode = parent.code?.trim() ?? '';
      final List<ManageChannelEntityChildren> children = parent.children ?? <ManageChannelEntityChildren>[];
      for (final ManageChannelEntityChildren child in children) {
        final String childCode = child.code?.trim() ?? '';
        if (child.uid != null && childCode.isNotEmpty) {
          childCodeToUid[childCode] = child.uid!;
        }
        if (child.uid != null && parentCode.isNotEmpty) {
          parentCodeToChildUids[parentCode] ??= <int>{};
          parentCodeToChildUids[parentCode]!.add(child.uid!);
        }
      }
    }

    for (final String code in codes) {
      final int? uid = childCodeToUid[code];
      if (uid != null) {
        ids.add(uid);
        continue;
      }
      final Set<int>? childUids = parentCodeToChildUids[code];
      if (childUids != null && childUids.isNotEmpty) {
        ids.addAll(childUids);
      }
    }
    return ids;
  }

  void setSelectedRoleIds(Set<int> ids) {
    selectedRoleIds
      ..clear()
      ..addAll(ids);
    positionText.value = _buildPositionText();
  }

  void toggleRoleId(int id) {
    if (selectedRoleIds.contains(id)) {
      selectedRoleIds.remove(id);
    } else {
      selectedRoleIds.add(id);
    }
    positionText.value = _buildPositionText();
  }

  String _buildPositionText() {
    final List<String> names = roleOptions
        .where((item) => selectedRoleIds.contains(item.id))
        .map((item) => item.name)
        .where((value) => value.trim().isNotEmpty)
        .toList();
    return names.join(' ');
  }

  void toggleChannel(int id) {
    if (selectedChannelIds.contains(id)) {
      selectedChannelIds.remove(id);
    } else {
      selectedChannelIds.add(id);
    }
  }

  void selectAllChannels() {
    selectedChannelIds
      ..clear()
      ..addAll(channelGroups.expand((e) => e.options).map((e) => e.id));
  }

  void clearChannels() {
    selectedChannelIds.clear();
  }

  void toggleNotifyTemplate(int id) {
    if (selectedNotifyTemplateIds.contains(id)) {
      selectedNotifyTemplateIds.remove(id);
    } else {
      selectedNotifyTemplateIds.add(id);
    }
  }

  void selectAllNotifyTemplates() {
    selectedNotifyTemplateIds
      ..clear()
      ..addAll(notifyTemplateGroups.expand((e) => e.options).map((e) => e.id));
  }

  void clearNotifyTemplates() {
    selectedNotifyTemplateIds.clear();
  }

  void setSelectedAdminGroup(ManageUserRoleGruopEnum value) {
    selectedAdminGroup.value = value;
  }

  Map<String, dynamic>? _buildReqData({
    bool validate = true,
    String? access,
  }) {
    final int? inputUserId = int.tryParse(userIdController.text.trim());
    if (validate && inputUserId == null) {
      ToastUtils.showToast(text: '请填写用户ID');
      return null;
    }
    userId = inputUserId ?? userId;
    if (userId == null) {
      ToastUtils.showToast(text: '用户ID为空');
      return null;
    }
    if (validate && nameController.text.trim().isEmpty) {
      ToastUtils.showToast(text: '请填写姓名');
      return null;
    }
    if (validate && selectedRoleIds.isEmpty) {
      ToastUtils.showToast(text: '请选择岗位');
      return null;
    }
    return {
      "userId": userId,
      "realName": nameController.text.trim(),
      "adminGroup": selectedAdminGroup.value.value,
      "channelRoleIds": selectedRoleIds.toList(),
      "access": access ?? (isEnable.value ? AccessEnum.NORMAL.value : AccessEnum.INTERNAL.value),
      "channelIds": selectedChannelIds.toList(),
      "notifyTemplateIds": selectedNotifyTemplateIds.toList(),
    };
  }

  Future<void> onCreate() async {
    final Map<String, dynamic>? data = _buildReqData();
    if (data == null) return;
    try {
      ToastUtils.showLoading();
      if (isEdit) {
        final ManagePermissionUserEntity? entity = await AccountConsoleRequest.editManagePermissionUser(
          userId: userId!,
          data: data,
        );
        if (entity == null) return;
        ToastUtils.showToast(text: '保存成功', type: ToastType.success);
        Get.back(result: entity);
        return;
      }
      final bool success = await AccountConsoleRequest.createManagePermissionUser(data: data);
      if (!success) return;
      ToastUtils.showToast(text: '创建成功', type: ToastType.success);
      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onDeleteEmployee(BuildContext context) async {
    if (!isEdit) return;
    final bool? askRes = await AskDialog.showUserCancelAsk(
      context: context,
      title: "确认删除",
      content: "确认删除该员工吗？",
    );
    if (askRes != true) return;
    final Map<String, dynamic>? data = _buildReqData(
      validate: false,
      access: AccessEnum.DELETED.value,
    );
    if (data == null) return;
    try {
      ToastUtils.showLoading();
      final ManagePermissionUserEntity? entity = await AccountConsoleRequest.editManagePermissionUser(
        userId: userId!,
        data: data,
      );
      if (entity == null) return;
      ToastUtils.showToast(text: '删除成功', type: ToastType.success);
      Get.back(result: -1);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    final dynamic args = Get.arguments;
    if (args is Map) {
      if (args['roleOptions'] is List) {
        roleOptions.value = (args['roleOptions'] as List)
            .map((item) => ManagePermissionCreateOption(
                  id: int.tryParse(item['id']?.toString() ?? '') ?? (item['id'] is int ? item['id'] as int : 0),
                  name: item['name']?.toString() ?? '',
                ))
            .where((item) => item.id > 0 && item.name.trim().isNotEmpty)
            .toList();
      }
      if (args['channelList'] is List<ManageChannelEntity>) {
        _channelList = args['channelList'] as List<ManageChannelEntity>;
        channelGroups.value = _channelList.map((channel) {
          final List<ManagePermissionCreateOption> options = (channel.children ?? [])
              .where((child) => child.uid != null && (child.name ?? '').trim().isNotEmpty)
              .map((child) => ManagePermissionCreateOption(
                    id: child.uid!,
                    name: child.name ?? '',
                  ))
              .toList();
          return ManagePermissionCreateGroup(
            title: channel.name ?? '未命名渠道',
            options: options,
          );
        }).where((group) => group.options.isNotEmpty).toList();
      }
      if (args['notifyTemplateGroups'] is List) {
        final List<GroupNotifyTempEntityEntityList> groups = (args['notifyTemplateGroups'] as List)
            .map((item) {
              if (item is GroupNotifyTempEntityEntityList) return item;
              if (item is Map) {
                return GroupNotifyTempEntityEntityList.fromJson(item.cast<String, dynamic>());
              }
              return null;
            })
            .whereType<GroupNotifyTempEntityEntityList>()
            .toList();
        if (groups.isNotEmpty) {
          notifyTemplateGroups.value = groups.map((group) {
            final List<ManagePermissionCreateOption> options = (group.templates ?? [])
                .whereType<NotifyTempEntity>()
                .where((item) => item.uid != null && (item.name ?? '').trim().isNotEmpty)
                .map((item) => ManagePermissionCreateOption(
                      id: item.uid!,
                      name: item.name ?? '',
                    ))
                .toList();
            return ManagePermissionCreateGroup(
              title: (group.title ?? '').trim().isNotEmpty ? group.title!.trim() : '通知模板',
              options: options,
            );
          }).where((group) => group.options.isNotEmpty).toList();
        }
      }
      if (notifyTemplateGroups.isEmpty && args['notifyTemplateList'] is List<NotifyTempEntity>) {
        notifyTemplateGroups.value = [
          ManagePermissionCreateGroup(
            title: '通知模板',
            options: (args['notifyTemplateList'] as List<NotifyTempEntity>)
                .where((item) => item.uid != null && (item.name ?? '').trim().isNotEmpty)
                .map((item) => ManagePermissionCreateOption(
                      id: item.uid!,
                      name: item.name ?? '',
                    ))
                .toList(),
          ),
        ].where((group) => group.options.isNotEmpty).toList();
      }
      if (args['permissionUser'] is ManagePermissionUserEntity) {
        final ManagePermissionUserEntity user = args['permissionUser'];
        userId = user.userId;
        userIdController.text = '${user.userId ?? ''}';
        nameController.text = user.realName ?? user.userName ?? '';
        isEnable.value = user.access == AccessEnum.NORMAL.value;
        selectedAdminGroup.value = ManageUserRoleGruopEnum.fromValue(user.adminGroup) ?? ManageUserRoleGruopEnum.CHANNEL;
        final Set<int> initRoleIds = {
          ...?user.roleIds,
        };
        setSelectedRoleIds(initRoleIds);
        selectedNotifyTemplateIds
          ..clear()
          ..addAll((user.notifyTemplates ?? []).map((item) => item.uid).whereType<int>());
        selectedChannelIds
          ..clear()
          ..addAll(_buildInitChannelIds(user.channels));
      }
    }
    if (isEdit && selectedRoleIds.isEmpty && roleOptions.isNotEmpty) {
      setSelectedRoleIds({roleOptions.first.id});
    }
    if (positionText.value.isEmpty) {
      positionText.value = _buildPositionText();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    userIdController.dispose();
    super.onClose();
  }
}
