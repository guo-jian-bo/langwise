
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../../../../utils/utils.dart';

/// 弹窗内的本地草稿组，只服务于当前编辑态。
class ZhenxieEditCompareGroupDraftItem {
  final String key;
  final Map<String, int?> sentenceIdMap;
  final Map<String, PatternBlueprintSentenceBriefEntity?> sentenceStructMap;

  ZhenxieEditCompareGroupDraftItem({
    required this.key,
    required this.sentenceIdMap,
    required this.sentenceStructMap,
  });
}

/// 绑定句子 ID 子弹窗的返回结果。
class ZhenxieEditCompareGroupBindIdResult {
  final Map<String, int> sentenceIdMap;

  ZhenxieEditCompareGroupBindIdResult({
    required this.sentenceIdMap,
  });
}

/// 编辑对照组弹窗
class ZhenxieEditCompareGroupDialog{
  static Future<void> show({
    required BuildContext context,
    required SentencePatternCompareEntity detailData,
  }) async{
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return EditCompareGroupDialogWidget(detailData: detailData);
      },
    );
  }

  /// 绑定句子ID弹窗
  static Future<ZhenxieEditCompareGroupBindIdResult?> showBindSentenceIdDialog({
    required BuildContext context,
    required List<SentencePatternCompareMemberEntity?> memberList,
  }) async{
    return await showCupertinoDialog<ZhenxieEditCompareGroupBindIdResult?>(
      context: context,
      builder: (context) {
        return ZhenxieEditCompareGroupBindIdDialog(memberList: memberList);
      },
    );
  }

  /// AI 创建选择菜单
  static Future<AiCreateMenu?> showAiCreateMenu({
    required BuildContext context,
  }) async{
    return await showCupertinoDialog<AiCreateMenu?>(
      context: context,
      builder: (context) {
        return ZhenxieEditCompareGroupAiCreateMenuDialogWidget();
      },
    );
  }

}

class EditCompareGroupDialogWidget extends StatefulWidget {
  /// 详情页传入的对照详情，用于初始化草稿和后续请求。
  final SentencePatternCompareEntity detailData;
  const EditCompareGroupDialogWidget({super.key, required this.detailData});

  @override
  State<EditCompareGroupDialogWidget> createState() => _EditCompareGroupDialogWidgetState();
}

class _EditCompareGroupDialogWidgetState extends State<EditCompareGroupDialogWidget> {
  /// 弹窗内持有的最新详情数据，MQTT 回调后会用它刷新列表。
  late SentencePatternCompareEntity _detailData;

  /// 当前弹窗里的本地对照组草稿列表。
  final List<ZhenxieEditCompareGroupDraftItem> _draftList = [];

  /// 候选句池先预留空实现，后续接真实数据源。
  final Map<String, List<PatternBlueprintSentenceBriefEntity?>> _sentenceCandidatePoolMap = {};

  /// 当前句型对照下的壳列表，作为每组草稿的固定结构。
  List<SentencePatternCompareMemberEntity?> get _memberList => _detailData.memberList ?? [];

  StreamSubscription<PushMessageServiceEnitiy>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _detailData = widget.detailData;
    _initDraftList();
    loadSentenceCandidatePool();

    _messageSubscription = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.PARADIGM_CREATE_GROUP], 
      onData: (value){
        refreshSingleData();
      },
    );
    
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  /// 单独刷新制定数据
  Future<void> refreshSingleData() async{
    if(_detailData.nid == null) return;
    try {
      Map<String, dynamic> reqData = {
        "nid": _detailData.nid!,
      };
      ListResponseEntity<SentencePatternCompareEntity>? list = await LanguageConsoleRequest.querySentencePatternCompareList(
        data: reqData,
      );
      if(list == null) return;
      if(list.datas == null) return;
      List<SentencePatternCompareEntity> datas = list.datas??[];

      for (var j = 0; j < datas.length; j++) {
        if(_detailData.nid == datas[j].nid){
          _detailData = datas[j];
          _initDraftList();
          _sentenceCandidatePoolMap.clear();
          await loadSentenceCandidatePool();
          if (mounted) setState(() {});
          break;
        }
      }
    } catch (_) {}
  }

  /// 打开弹窗时用已有对照组初始化本地草稿；没有数据时补一条空白组。
  void _initDraftList() {
    _draftList.clear();
    final List<SentencePatternCompareSentenceRealizationSetEntity?> setList = [
      ...(_detailData.realizationSetList ?? <SentencePatternCompareSentenceRealizationSetEntity?>[]),
    ];
    setList.removeWhere((element) => element == null);
    setList.sort((a, b) => (b?.order ?? 0).compareTo(a?.order ?? 0));
    for (final element in setList) {
      if (element == null) continue;
      _draftList.add(_buildDraftItemFromSet(element));
    }
    if (_draftList.isEmpty) {
      _draftList.add(_createBlankDraftItem());
    }
  }

  ZhenxieEditCompareGroupDraftItem _buildDraftItemFromSet(SentencePatternCompareSentenceRealizationSetEntity set) {
    final Map<String, int?> sentenceIdMap = {};
    final Map<String, PatternBlueprintSentenceBriefEntity?> sentenceStructMap = {};
    for (final member in _memberList) {
      final String valueNid = member?.valueNid ?? '';
      if (valueNid.isEmpty) continue;
      sentenceIdMap[valueNid] = null;
      sentenceStructMap[valueNid] = null;
    }
    final bindingList = set.bindingList?.isNotEmpty == true ? set.bindingList : set.bindings;
    for (final binding in bindingList ?? []) {
      final String valueNid = binding?.valueNid ?? '';
      if (valueNid.isEmpty) continue;
      sentenceIdMap[valueNid] = binding?.sentenceId;
      sentenceStructMap[valueNid] = binding?.sentenceStruct;
    }
    return ZhenxieEditCompareGroupDraftItem(
      key: 'set-${set.order ?? 0}-${DateTime.now().microsecondsSinceEpoch}',
      sentenceIdMap: sentenceIdMap,
      sentenceStructMap: sentenceStructMap,
    );
  }

  /// 创建一条空白草稿组，保证每个壳都有对应的可编辑位置。
  ZhenxieEditCompareGroupDraftItem _createBlankDraftItem() {
    final Map<String, int?> sentenceIdMap = {};
    final Map<String, PatternBlueprintSentenceBriefEntity?> sentenceStructMap = {};
    for (final member in _memberList) {
      final String valueNid = member?.valueNid ?? '';
      if (valueNid.isEmpty) continue;
      sentenceIdMap[valueNid] = null;
      sentenceStructMap[valueNid] = null;
    }
    return ZhenxieEditCompareGroupDraftItem(
      key: 'new-${DateTime.now().microsecondsSinceEpoch}',
      sentenceIdMap: sentenceIdMap,
      sentenceStructMap: sentenceStructMap,
    );
  }

  /// 把本地草稿重新转回保存用的 set 结构，并按当前顺序重算 order。
  List<SentencePatternCompareSentenceRealizationSetEntity> _buildDraftSetPayloadList() {
    final List<SentencePatternCompareSentenceRealizationSetEntity> result = [];
    for (int index = 0; index < _draftList.length; index++) {
      final draft = _draftList[index];
      final List<SentencePatternCompareSentenceBindingEntity> bindingList = [];
      bool isComplete = true;
      for (final member in _memberList) {
        final String valueNid = member?.valueNid ?? '';
        if (valueNid.isEmpty) continue;
        final int? sentenceId = draft.sentenceIdMap[valueNid];
        if (sentenceId == null) {
          isComplete = false;
          break;
        }
        bindingList.add(SentencePatternCompareSentenceBindingEntity(
          valueNid: valueNid,
          sentenceId: sentenceId,
          sentenceStruct: draft.sentenceStructMap[valueNid],
        ));
      }
      if (!isComplete || bindingList.isEmpty) continue;
      result.add(SentencePatternCompareSentenceRealizationSetEntity(
        order: (_draftList.length - index) * 10,
        bindingList: bindingList,
      ));
    }
    return result;
  }

  /// 生成壳标题，优先显示本地化名称，其次回退到 patternNid。
  String _getMemberLabel(SentencePatternCompareMemberEntity? member) {
    final String valueLabel = LearningLangUtils.getLocalLang(member?.valueLabel?.name)?.text ?? member?.valueNid ?? '';
    final String patternName = LearningLangUtils.getLocalLang(member?.realizationInfo?.pattern?.name)?.text ?? '';
    final String patternNid = member?.realizationInfo?.patternNid ?? member?.realization?.patternNid ?? '';
    if (patternName.isNotEmpty) return '$valueLabel · $patternName';
    if (patternNid.isNotEmpty) return '$valueLabel · $patternNid';
    return valueLabel;
  }

  /// 获取当前壳已选句子的回显文案，优先展示句子内容。
  String _getSelectedSentenceTitle({
    required ZhenxieEditCompareGroupDraftItem draft,
    required SentencePatternCompareMemberEntity? member,
  }) {
    final String valueNid = member?.valueNid ?? '';
    final int? sentenceId = draft.sentenceIdMap[valueNid];
    final PatternBlueprintSentenceBriefEntity? sentenceStruct = draft.sentenceStructMap[valueNid];
    if ((sentenceStruct?.content ?? '').isNotEmpty) return sentenceStruct?.content ?? '';
    if (sentenceId != null) return '#$sentenceId';
    return '';
  }

  /// 生成当前壳的下拉选项，并兜住“已选值不在候选池中”的回显场景。
  List<IconDropdownCheckData<int>> _buildSentenceOptionList({
    required ZhenxieEditCompareGroupDraftItem draft,
    required SentencePatternCompareMemberEntity? member,
  }) {
    final String valueNid = member?.valueNid ?? '';
    final int? selectedSentenceId = draft.sentenceIdMap[valueNid];
    final PatternBlueprintSentenceBriefEntity? selectedSentenceStruct = draft.sentenceStructMap[valueNid];
    final List<IconDropdownCheckData<int>> options = [];
    final List<PatternBlueprintSentenceBriefEntity?> pool = _sentenceCandidatePoolMap[valueNid] ?? [];
    for (final item in pool) {
      final int? sentenceId = item?.sentenceId;
      if (sentenceId == null) continue;
      options.add(IconDropdownCheckData(
        title: item?.content ?? '#$sentenceId',
        value: sentenceId,
      ));
    }
    final bool hasSelected = options.any((element) => element.value == selectedSentenceId);
    if (selectedSentenceId != null && !hasSelected) {
      options.insert(0, IconDropdownCheckData(
        title: selectedSentenceStruct?.content ?? '#$selectedSentenceId',
        value: selectedSentenceId,
      ));
    }
    return options;
  }

  /// 更新某个草稿组下某个壳的选句结果，并同步已选句结构信息。
  void _updateDraftSelection({
    required String draftKey,
    required String valueNid,
    required int? sentenceId,
  }) {
    final int draftIndex = _draftList.indexWhere((element) => element.key == draftKey);
    if (draftIndex == -1) return;
    final List<PatternBlueprintSentenceBriefEntity?> pool = _sentenceCandidatePoolMap[valueNid] ?? [];
    PatternBlueprintSentenceBriefEntity? sentenceStruct;
    if (sentenceId != null) {
      final int optionIndex = pool.indexWhere((element) => element?.sentenceId == sentenceId);
      if (optionIndex != -1) sentenceStruct = pool[optionIndex];
    }
    _draftList[draftIndex].sentenceIdMap[valueNid] = sentenceId;
    _draftList[draftIndex].sentenceStructMap[valueNid] = sentenceStruct;
    if (mounted) setState(() {});
  }

  /// 删除指定草稿组；如果删空则补回一条空白组，避免弹窗无可编辑内容。
  void _removeDraftItem(String key) {
    _draftList.removeWhere((element) => element.key == key);
    if (_draftList.isEmpty) {
      _draftList.add(_createBlankDraftItem());
    }
    if (mounted) setState(() {});
  }
  
  /// 统一处理“添加对照组”菜单点击，分发到绑定 ID、AI 创建或空白组逻辑。
  Future<void> showAddMenu(int index) async{
    if(index == 0){
      // 绑定句子 ID
      await bindSentenceId();
    }else if(index == 1){
      // AI 创建
      AiCreateMenu? res = await ZhenxieEditCompareGroupDialog.showAiCreateMenu(
        context: context,
      );
      if(res == null) return;
      if(res == AiCreateMenu.matchFirst){
        await aiCheckAndCreate();
      }else if(res == AiCreateMenu.createNew){
        await aiCreate();
      }
    }else if(index == 2){
      // 仅新增空白草稿行（本地）
      addBlankRow();
    }
  }

  ///绑定句子 ID 弹窗
  Future<void> bindSentenceId() async{
    final ZhenxieEditCompareGroupBindIdResult? res = await ZhenxieEditCompareGroupDialog.showBindSentenceIdDialog(
      context: context,
      memberList: _memberList,
    );
    if (res == null) return;
    await requestBindSentenceIds(sentenceIdMap: res.sentenceIdMap);
    final Map<String, int?> sentenceIdMap = {};
    final Map<String, PatternBlueprintSentenceBriefEntity?> sentenceStructMap = {};
    for (final entry in res.sentenceIdMap.entries) {
      sentenceIdMap[entry.key] = entry.value;
      sentenceStructMap[entry.key] = null;
    }
    _draftList.insert(0, ZhenxieEditCompareGroupDraftItem(
      key: 'bind-${DateTime.now().microsecondsSinceEpoch}',
      sentenceIdMap: sentenceIdMap,
      sentenceStructMap: sentenceStructMap,
    ));
    if (mounted) setState(() {});
  }

  /// AI先查库再创建
  Future<void> aiCheckAndCreate() async{
    await requestAiCreate(matchFirst: true);
  }

  /// AI全新创建
  Future<void> aiCreate() async{
    await requestAiCreate(matchFirst: false);
  }

  /// 仅新增空白草稿行（本地）
  Future<void> addBlankRow() async{
    _draftList.add(_createBlankDraftItem());
    if (mounted) setState(() {});
  }

  /// 候选池获取入口，当前先留空。
  Future<void> loadSentenceCandidatePool() async {
    for (final member in _memberList) {
      final String valueNid = member?.valueNid ?? '';
      if (valueNid.isEmpty || member == null) continue;
      _sentenceCandidatePoolMap[valueNid] = await fetchSentenceCandidateList(member: member);
    }
    if (mounted) setState(() {});
  }

  /// 按 member 获取候选句列表，当前先留空。
  Future<List<PatternBlueprintSentenceBriefEntity?>> fetchSentenceCandidateList({
    required SentencePatternCompareMemberEntity member,
  }) async {
    return [];
  }

  /// 绑定句子 ID 请求入口，当前先留空。
  Future<void> requestBindSentenceIds({
    required Map<String, int> sentenceIdMap,
  }) async {}

  /// 保存请求入口，当前先留空。
  Future<void> saveCompareGroups() async {
    final List<SentencePatternCompareSentenceRealizationSetEntity> saveData = _buildDraftSetPayloadList();
    if (saveData.isEmpty) {
      ToastUtils.showToast(text: "暂无可保存的完整对照组", type: ToastType.error);
      return;
    }
  }

  /// AI 创建请求。
  Future<void> requestAiCreate({
    required bool matchFirst,
  }) async {
    if (_detailData.nid == null) return;
    try {
      ToastUtils.showLoading();
      final resp = await LanguageConsoleRequest.createSentencePatternCompareAiTask(
        nid: _detailData.nid!,
        data: {
          "matchFirst": matchFirst,
        },
      );
      if (resp == null) return;
      ToastUtils.showToast(
        text: resp.status == "started" ? "AI 创建任务已开始" : (resp.message ?? "AI 创建已提交"),
        type: ToastType.success,
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "编辑对照组",
      width: 1000.wMin,
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 950.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            SizedBox(height: 12.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            Expanded(child: _buildListWidget()),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderThin.color,
            ),
            SizedBox(height: 12.wMin),
            _buildButtonsWidget(),
            SizedBox(height: 24.wMin),
          ],
        ),
      ),
    );
  }

  /// 顶部提示文案。
   Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Text(
        "每组须为每个壳各挑一句；上方组展示优先",
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      ),
    );
  }

  /// 底部操作区，包含新增、取消和保存按钮。
  Widget _buildButtonsWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Builder(
            builder: (ctx) {
              return IconDropdownMenuWidget(
                onTap: (data, index) {
                  showAddMenu(index);
                },
                items: [
                  IconDropdownIconData(title: "绑定句子ID"),
                  IconDropdownIconData(title: "AI创建"),
                  IconDropdownIconData(title: "仅新增空白草稿行（本地）"),
                ],
                width: 350.wMin,
                child: ButtonWidget(
                  text: "添加对照组",
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  height: 56.wMin,
                  borderRadius: 8.wMin,
                  color: AppTheme.cSurfaceLayerElevated.color,
                  fontColor: AppTheme.cTextSecondary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  leftIcon: SvgPicture.asset(
                    "assets/svg/public/icon_add.svg",
                    width: 28.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                  ),
                ),
              );
            }
          ),
          const Spacer(),
          ButtonWidget(
            text: "取消",
            width: 112.wMin,
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            fontColor: AppTheme.cTextSecondary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              Get.back();
            },
          ),
          SizedBox(width: 12.wMin),
          ButtonWidget(
            text: "保存",
            width: 112.wMin,
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.8),
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: saveCompareGroups,
          ),
        ],
      ),
    );
  }


  /// 对照组列表区域，按本地草稿数量渲染。
  Widget _buildListWidget(){
    return ListView.separated(
      itemCount: _draftList.length,
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      separatorBuilder: (context, index) => SizedBox(height: 12.wMin),
      itemBuilder: (context, index) {
        return _buildItemWidget(_draftList[index], index);
      },
    );
  }

  /// 单个对照组卡片，内部按 memberList 渲染每个壳的选句行。
  Widget _buildItemWidget(ZhenxieEditCompareGroupDraftItem draft, int index){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "对照组 ${index + 1}",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              const Spacer(),
              TapScaleWidget(
                onTap: () => _removeDraftItem(draft.key),
                sclae: 1.03,
                child: Container(
                  padding: EdgeInsets.all(6.wMin),
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_delete.svg",
                    width: 24.wMin,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_memberList.length, (memberIndex) {
              final member = _memberList[memberIndex];
              return Container(
                margin: EdgeInsets.only(top: memberIndex == 0 ? 0 : 16.wMin),
                child: _buildItemSelectWidget(draft: draft, member: member),
              );
            }),
          ),
        ],
      ),
    );
  }


  /// 单个壳的选句区域，负责标题、已选回显和下拉选择。
  Widget _buildItemSelectWidget({
    required ZhenxieEditCompareGroupDraftItem draft,
    required SentencePatternCompareMemberEntity? member,
  }){
    final String valueNid = member?.valueNid ?? '';
    final int? selectedSentenceId = draft.sentenceIdMap[valueNid];
    final List<IconDropdownCheckData<int>> items = _buildSentenceOptionList(draft: draft, member: member);
    final String selectedSentenceTitle = _getSelectedSentenceTitle(draft: draft, member: member);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getMemberLabel(member),
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        if (selectedSentenceTitle.isNotEmpty) ...[
          SizedBox(height: 4.wMin),
          Text(
            selectedSentenceTitle,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
        SizedBox(height: 8.wMin),
        IconDropdownSelectWidget(
          height: 52.wMin,
          borderRadius: BorderRadius.circular(8.wMin),
          hintText: "请选择",
          hintStyle: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
          valueStyle: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
          items: items,
          selectValue: selectedSentenceId,
          onChanged: (data, index) {
            _updateDraftSelection(
              draftKey: draft.key,
              valueNid: valueNid,
              sentenceId: data.value,
            );
          },
        ),
      ],
    );
  }
}


class ZhenxieEditCompareGroupBindIdDialog extends StatefulWidget {
  /// 当前句型对照下的壳列表，用于动态生成 ID 输入框。
  final List<SentencePatternCompareMemberEntity?> memberList;
  const ZhenxieEditCompareGroupBindIdDialog({super.key, required this.memberList});

  @override
  State<ZhenxieEditCompareGroupBindIdDialog> createState() => _EditCompareGroupBindIdDialogState();
}

class _EditCompareGroupBindIdDialogState extends State<ZhenxieEditCompareGroupBindIdDialog> {
  /// 每个壳对应一个输入控制器，提交时统一校验并组装返回值。
  final Map<String, TextEditingController> _controllerMap = {};

  @override
  void initState() {
    super.initState();
    for (final member in widget.memberList) {
      final String valueNid = member?.valueNid ?? '';
      if (valueNid.isEmpty) continue;
      _controllerMap[valueNid] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllerMap.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 生成输入框标题，和主弹窗中的壳标题保持一致。
  String _getMemberLabel(SentencePatternCompareMemberEntity? member) {
    final String valueLabel = LearningLangUtils.getLocalLang(member?.valueLabel?.name)?.text ?? member?.valueNid ?? '';
    final String patternName = LearningLangUtils.getLocalLang(member?.realizationInfo?.pattern?.name)?.text ?? '';
    final String patternNid = member?.realizationInfo?.patternNid ?? member?.realization?.patternNid ?? '';
    if (patternName.isNotEmpty) return '$valueLabel · $patternName';
    if (patternNid.isNotEmpty) return '$valueLabel · $patternNid';
    return valueLabel;
  }

  /// 校验所有句子 ID 输入，成功后把结果回传给主弹窗。
  void _submit() {
    final Map<String, int> sentenceIdMap = {};
    for (final member in widget.memberList) {
      final String valueNid = member?.valueNid ?? '';
      if (valueNid.isEmpty) continue;
      final String raw = _controllerMap[valueNid]?.text.trim() ?? '';
      final int? sentenceId = int.tryParse(raw);
      if (raw.isEmpty || sentenceId == null || sentenceId <= 0) {
        ToastUtils.showToast(
          text: "请为「${_getMemberLabel(member)}」填写合法句子 ID",
          type: ToastType.error,
        );
        return;
      }
      sentenceIdMap[valueNid] = sentenceId;
    }
    Get.back(result: ZhenxieEditCompareGroupBindIdResult(sentenceIdMap: sentenceIdMap));
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "绑定句子 ID",
      width: 1000.wMin,
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 600.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            Expanded(child: _buildContentWidget()),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderThin.color,
            ),
            SizedBox(height: 12.wMin),
            _buildButtonsWidget(),
            SizedBox(height: 24.wMin),
          ],
        ),
      ),
    );
  }

  /// 绑定 ID 的内容区，按壳动态生成数字输入框。
  Widget _buildContentWidget(){
    return SingleChildScrollView(
      padding: EdgeInsets.all(32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24.wMin,
        children: List.generate(widget.memberList.length, (index) {
          final member = widget.memberList[index];
          final String valueNid = member?.valueNid ?? '';
          return ManageNumberInputWidget(
            controller: _controllerMap[valueNid],
            title: _getMemberLabel(member),
            hintText: "句子 ID（en_sentences.uid）",
            isInt: true,
            minValue: 1,
          );
        }),
      ),
    );
  }

  /// 绑定 ID 弹窗底部按钮区。
  Widget _buildButtonsWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          ButtonWidget(
            text: "取消",
            width: 112.wMin,
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            fontColor: AppTheme.cTextSecondary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              Get.back();
            },
          ),
          SizedBox(width: 12.wMin),
          ButtonWidget(
            text: "校验并加入草稿",
            width: 220.wMin,
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.8),
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: _submit,
          ),
        ],
      ),
    );
  }

}

enum AiCreateMenu {
  /// 先查库再创建
  matchFirst,
  /// 全新创建
  createNew,
}

class ZhenxieEditCompareGroupAiCreateMenuDialogWidget extends StatefulWidget {
  const ZhenxieEditCompareGroupAiCreateMenuDialogWidget({super.key});

  @override
  State<ZhenxieEditCompareGroupAiCreateMenuDialogWidget> createState() => _EditCompareGroupAiCreateMenuDialogWidgetState();
}

class _EditCompareGroupAiCreateMenuDialogWidgetState extends State<ZhenxieEditCompareGroupAiCreateMenuDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "AI 创建",
      width: 600.wMin,
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            SizedBox(height: 24.wMin),
            _buildMeunWidget(),
            SizedBox(height: 24.wMin),
          ],
        ),
      ),
    );
  }

  /// AI 创建模式菜单。
  Widget _buildMeunWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24.wMin,
      children: [
        _buildMeunItemWidget(
          title: "先查库再创建",
          subTitle: "match_first=true（默认）",
          onTap: () {
            Get.back(result: AiCreateMenu.matchFirst);
          },
        ),
        _buildMeunItemWidget(
          title: "全新创建",
          subTitle: "match_first=false · 跳过语料播种",
          onTap: () {
            Get.back(result: AiCreateMenu.createNew);
          },
        ),
      ],
    );
  }

  /// 单个 AI 创建菜单项。
  Widget _buildMeunItemWidget({
    required String title,
    required String subTitle,
    void Function()? onTap,
  }){
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: AppTheme.cBorderSecondary.color,
            width: 1.wMin,
          ),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              subTitle,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
