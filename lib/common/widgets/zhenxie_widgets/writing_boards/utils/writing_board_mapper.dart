
import '../../../../../utils/utils.dart';
import '../../../../entities/entities.dart';
import '../model/writing_board_data.dart';

/// 将任务详情转换成写作板统一渲染数据。
WritingBoardData mapTaskDetailsToWritingBoardData({
  required ZhenxieTaskDetailsEntity details,
  required List<ParagraphRhetoricalEntityList> paragraphRhetoricalList,
  String? selectBeatNid,
  WritingBoardContentSourceMacro contentSource = WritingBoardContentSourceMacro.task,
  WritingBoardEditPolicyMacro editPolicy = WritingBoardEditPolicyMacro.stageRule,
  bool showKnowledgeAnchors = false,
  bool isManagement = false,
}) {
  final contentSourceMacro = contentSource;
  final editPolicyMacro = editPolicy;
  final stage = details.stage;
  final frame = details.blueprint?.frame;
  final stageSlots = stage?.slots ?? const <ZhenxieTaskDetailsEntityStageSlot?>[];
  final visibleSlots = stageSlots.where((slot) => slot?.fill != 'hidden').toList();
  String? firstWritableBeatNid;
  for (final slot in visibleSlots) {
    if (slot?.fill != 'write' || slot?.beatNid?.isEmpty != false) continue;
    firstWritableBeatNid = slot!.beatNid!;
    break;
  }
  final firstVisibleBeatNid = visibleSlots.isNotEmpty ? visibleSlots.first?.beatNid : null;
  final defaultBeatNid = firstWritableBeatNid ?? firstVisibleBeatNid;
  final effectiveBeatNid = (selectBeatNid?.isNotEmpty ?? false) ? selectBeatNid : defaultBeatNid;
  final showHead = frame?.hasHead == true && stage?.headFill != null && stage?.headFill != 'hidden';
  final showTail = frame?.hasTail == true && stage?.tailFill != null && stage?.tailFill != 'hidden';
  final headEditable = _resolveFrameEditable(
    showSection: showHead,
    fill: stage?.headFill,
    editPolicyMacro: editPolicyMacro,
  );
  final tailEditable = _resolveFrameEditable(
    showSection: showTail,
    fill: stage?.tailFill,
    editPolicyMacro: editPolicyMacro,
  );
  final givenHeadText = _learningText(details.headText);
  final givenTailText = _learningText(details.tailText);
  final headLabel = _localizedText(frame?.headName);
  final steps = contentSourceMacro == WritingBoardContentSourceMacro.exemplar
      ? _buildExemplarSteps(
          details: details,
          paragraphRhetoricalList: paragraphRhetoricalList,
          visibleSlots: visibleSlots,
          effectiveBeatNid: effectiveBeatNid,
          editPolicyMacro: editPolicyMacro,
          isManagement: isManagement,
        )
      : _buildWritingSteps(
          details: details,
          paragraphRhetoricalList: paragraphRhetoricalList,
          visibleSlots: visibleSlots,
          effectiveBeatNid: effectiveBeatNid,
          editPolicyMacro: editPolicyMacro,
          isManagement: isManagement,
        );

  return WritingBoardData(
    skinNid: details.skinNid ?? details.blueprint?.skinNid,
    answerKind: stage?.answerKind ?? 'text',
    contentSource: contentSourceMacro,
    editPolicy: editPolicyMacro,
    showKnowledgeAnchors: showKnowledgeAnchors,
    showHead: showHead,
    showTail: showTail,
    headEditable: headEditable,
    tailEditable: tailEditable,
    headLabel: headLabel,
    tailLabel: _localizedText(frame?.tailName),
    headText: showHead
        ? _resolveFrameText(
            contentSourceMacro: contentSourceMacro,
            fill: stage?.headFill,
            interfaceText: givenHeadText,
          )
        : null,
    tailText: showTail
        ? _resolveFrameText(
            contentSourceMacro: contentSourceMacro,
            fill: stage?.tailFill,
            interfaceText: givenTailText,
          )
        : null,
    steps: steps,
    materials: _buildMaterials(details),
    mediaAnswer: _buildDraftMediaAnswer(details),
    exemplarMediaAnswer: _buildExemplarMediaAnswer(details),
  );
}

List<WritingBoardStepData> _buildWritingSteps({
  required ZhenxieTaskDetailsEntity details,
  required List<ParagraphRhetoricalEntityList> paragraphRhetoricalList,
  required List<ZhenxieTaskDetailsEntityStageSlot?> visibleSlots,
  required String? effectiveBeatNid,
  required WritingBoardEditPolicyMacro editPolicyMacro,
  required bool isManagement,
}) {
  final steps = <WritingBoardStepData>[];
  for (final stageSlot in visibleSlots) {
    if (stageSlot == null || stageSlot.beatNid == null) continue;
    final beatNid = stageSlot.beatNid!;
    final rhetorical = _findBeat(paragraphRhetoricalList, beatNid);
    final allowedParagraph = _findAllowedParagraph(
      blueprintSlots: details.blueprint?.slots,
      stageSlot: stageSlot,
    );
    final member = _findMember(
      members: details.members,
      beatNid: beatNid,
      paragraphTypeNid: stageSlot.paragraphTypeNid,
    );
    final paragraph = _findParagraph(
      details.memberList,
      member?.paragraphId,
      beatNid: beatNid,
      paragraphTypeNid: stageSlot.paragraphTypeNid,
    );
    final fill = stageSlot.fill ?? '';
    final selected = effectiveBeatNid == beatNid;

    steps.add(
      WritingBoardStepData(
        beatNid: beatNid,
        beatLabel: _beatLabel(rhetorical?.name, beatNid),
        paragraphTypeNid: stageSlot.paragraphTypeNid,
        paragraphTypeName: _localizedText(allowedParagraph?.paragraphType?.name ?? stageSlot.paragraphType?.name),
        usageName: _localizedText(allowedParagraph?.usageName),
        usageDescription: _localizedText(allowedParagraph?.usageDescription),
        fill: fill,
        selected: selected,
        editable: _resolveStepEditable(
          editPolicyMacro: editPolicyMacro,
          fill: fill,
        ),
        hidden: false,
        canOpenStepDialog: isManagement || fill != 'write',
        focused: selected,
        beatColor: rhetorical?.currentThemeColor?.colorValue,
        beatTextColor: rhetorical?.currentThemeColor?.textColorValue,
        text: paragraph?.content ?? '',
        knowledgeAnchors: const [],
        placeholder: '写这一拍…',
        paragraphId: member?.paragraphId ?? paragraph?.paragraphId ?? paragraph?.uid,
      ),
    );
  }
  return steps;
}

List<WritingBoardStepData> _buildExemplarSteps({
  required ZhenxieTaskDetailsEntity details,
  required List<ParagraphRhetoricalEntityList> paragraphRhetoricalList,
  required List<ZhenxieTaskDetailsEntityStageSlot?> visibleSlots,
  required String? effectiveBeatNid,
  required WritingBoardEditPolicyMacro editPolicyMacro,
  required bool isManagement,
}) {
  final steps = <WritingBoardStepData>[];

  for (final stageSlot in visibleSlots) {
    if (stageSlot == null || stageSlot.beatNid?.isEmpty != false) continue;
    final beatNid = stageSlot.beatNid!;
    final rhetorical = _findBeat(paragraphRhetoricalList, beatNid);
    final member = _findMember(
      members: details.members,
      beatNid: beatNid,
      paragraphTypeNid: stageSlot.paragraphTypeNid,
    );
    final allowedParagraph = _findAllowedParagraph(
      blueprintSlots: details.blueprint?.slots,
      stageSlot: stageSlot,
    );
    final paragraph = _findParagraph(
      details.memberList,
      member?.paragraphId,
      beatNid: beatNid,
      paragraphTypeNid: stageSlot.paragraphTypeNid,
    );
    final selected = effectiveBeatNid == beatNid;

    steps.add(
      WritingBoardStepData(
        beatNid: beatNid,
        beatLabel: _beatLabel(rhetorical?.name, beatNid),
        paragraphTypeNid: stageSlot.paragraphTypeNid,
        paragraphTypeName: _localizedText(allowedParagraph?.paragraphType?.name ?? stageSlot.paragraphType?.name),
        usageName: _localizedText(allowedParagraph?.usageName),
        usageDescription: _localizedText(allowedParagraph?.usageDescription),
        fill: stageSlot.fill ?? 'given',
        selected: selected,
        editable: _resolveStepEditable(
          editPolicyMacro: editPolicyMacro,
          fill: stageSlot.fill,
        ),
        hidden: false,
        canOpenStepDialog: isManagement || paragraph != null,
        focused: selected,
        beatColor: rhetorical?.currentThemeColor?.colorValue,
        beatTextColor: rhetorical?.currentThemeColor?.textColorValue,
        text: paragraph?.content ?? '',
        knowledgeAnchors: paragraph?.anchors ?? const [],
        placeholder: '写这一拍…',
        paragraphId: member?.paragraphId ?? paragraph?.paragraphId ?? paragraph?.uid,
      ),
    );
  }
  return steps;
}

/// 根据编辑策略计算当前首尾结构是否允许输入。
bool _resolveFrameEditable({
  required bool showSection,
  required String? fill,
  required WritingBoardEditPolicyMacro editPolicyMacro,
}) {
  if (!showSection) return false;
  if (editPolicyMacro == WritingBoardEditPolicyMacro.forceEditable) return true;
  if (editPolicyMacro == WritingBoardEditPolicyMacro.readOnly) return false;
  return fill == 'write';
}

/// 根据内容来源和填充规则计算当前首尾结构显示文案。
String _resolveFrameText({
  required WritingBoardContentSourceMacro contentSourceMacro,
  required String? fill,
  required String interfaceText,
}) {
  if (contentSourceMacro == WritingBoardContentSourceMacro.exemplar) return interfaceText;
  if (fill == 'given') return interfaceText;
  return interfaceText;
}

/// 根据编辑策略计算当前正文拍位是否允许输入。
bool _resolveStepEditable({
  required WritingBoardEditPolicyMacro editPolicyMacro,
  required String? fill,
}) {
  if (editPolicyMacro == WritingBoardEditPolicyMacro.forceEditable) return true;
  if (editPolicyMacro == WritingBoardEditPolicyMacro.readOnly) return false;
  return fill == 'write';
}

ParagraphRhetoricalEntityList? _findBeat(
  List<ParagraphRhetoricalEntityList> list,
  String beatNid,
) {
  for (final item in list) {
    if (item.nid == beatNid) return item;
  }
  return null;
}

ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? _findAllowedParagraph({
  required List<ArticleBlueprintEntityBlueprintsSlots?>? blueprintSlots,
  required ZhenxieTaskDetailsEntityStageSlot stageSlot,
}) {
  for (final blueprintSlot in blueprintSlots ?? const <ArticleBlueprintEntityBlueprintsSlots?>[]) {
    if (blueprintSlot?.beatNid != stageSlot.beatNid) continue;
    for (final allowedParagraph in blueprintSlot?.allowedParagraphs ?? const <ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs?>[]) {
      if (allowedParagraph?.paragraphTypeNid == stageSlot.paragraphTypeNid) {
        return allowedParagraph;
      }
    }
    final allowedParagraphs = blueprintSlot?.allowedParagraphs;
    return allowedParagraphs != null && allowedParagraphs.isNotEmpty ? allowedParagraphs.first : null;
  }
  return null;
}

ZhenxieTaskDetailsEntityMember? _findMember({
  required List<ZhenxieTaskDetailsEntityMember?>? members,
  required String beatNid,
  String? paragraphTypeNid,
}) {
  ZhenxieTaskDetailsEntityMember? fallback;
  for (final member in members ?? const <ZhenxieTaskDetailsEntityMember?>[]) {
    if (member?.beatNid != beatNid) continue;
    fallback ??= member;
    if (paragraphTypeNid == null || member?.paragraphTypeNid == paragraphTypeNid) {
      return member;
    }
  }
  return fallback;
}

ZhenxieTaskDetailsEntityParagraphInstance? _findParagraph(
  List<ZhenxieTaskDetailsEntityParagraphInstance?>? memberList,
  int? paragraphId, {
  String? beatNid,
  String? paragraphTypeNid,
}) {
  ZhenxieTaskDetailsEntityParagraphInstance? fallback;
  for (final paragraph in memberList ?? const <ZhenxieTaskDetailsEntityParagraphInstance?>[]) {
    if (paragraphId != null && (paragraph?.uid == paragraphId || paragraph?.paragraphId == paragraphId)) {
      return paragraph;
    }
    if (beatNid != null && paragraph?.beatNid == beatNid) {
      fallback ??= paragraph;
      if (paragraphTypeNid == null || paragraph?.paragraphTypeNid == paragraphTypeNid) {
        return paragraph;
      }
    }
  }
  return fallback;
}

List<WritingBoardMaterialData> _buildMaterials(ZhenxieTaskDetailsEntity details) {
  final materials = <WritingBoardMaterialData>[];
  _appendMaterials(
    materials: materials,
    kind: 'image',
    urls: details.stemImageUrls,
    keys: details.stemImages,
  );
  _appendMaterials(
    materials: materials,
    kind: 'video',
    urls: details.stemVideoUrls,
    keys: details.stemVideos,
  );
  _appendMaterials(
    materials: materials,
    kind: 'audio',
    urls: details.stemAudioUrls,
    keys: details.stemAudios,
  );
  return materials;
}

void _appendMaterials({
  required List<WritingBoardMaterialData> materials,
  required String kind,
  List<String?>? urls,
  List<String?>? keys,
}) {
  final count = [urls?.length ?? 0, keys?.length ?? 0].reduce((value, element) => value > element ? value : element);
  for (int index = 0; index < count; index++) {
    final url = urls != null && index < urls.length ? urls[index] ?? '' : '';
    final key = keys != null && index < keys.length ? keys[index] : null;
    if (url.isEmpty && (key == null || key.isEmpty)) continue;
    materials.add(WritingBoardMaterialData(kind: kind, url: url, key: key));
  }
}

WritingBoardMediaAnswerData? _buildDraftMediaAnswer(ZhenxieTaskDetailsEntity details) {
  final answerKind = details.stage?.answerKind;
  if (answerKind == null || answerKind == 'text') return null;
  return WritingBoardMediaAnswerData(
    kind: answerKind,
    minCount: details.stage?.answerMinCount ?? 0,
    maxCount: details.stage?.answerMaxCount ?? 0,
    items: _buildMediaItems(
      keys: answerKind == 'image'
          ? details.answerImageKeys
          : answerKind == 'video'
              ? details.answerVideoKeys
              : details.answerAudioKeys,
      urls: answerKind == 'image'
          ? details.answerImageUrls
          : answerKind == 'video'
              ? details.answerVideoUrls
              : details.answerAudioUrls,
    ),
  );
}

WritingBoardMediaAnswerData? _buildExemplarMediaAnswer(ZhenxieTaskDetailsEntity details) {
  final answerKind = details.stage?.answerKind;
  if (answerKind == null || answerKind == 'text') return null;
  return WritingBoardMediaAnswerData(
    kind: answerKind,
    minCount: details.stage?.answerMinCount ?? 0,
    maxCount: details.stage?.answerMaxCount ?? 0,
    items: _buildMediaItems(
      keys: answerKind == 'image'
          ? details.answerImageKeys
          : answerKind == 'video'
              ? details.answerVideoKeys
              : details.answerAudioKeys,
      urls: answerKind == 'image'
          ? details.answerImageUrls
          : answerKind == 'video'
              ? details.answerVideoUrls
              : details.answerAudioUrls,
    ),
  );
}

List<WritingBoardMediaItemData> _buildMediaItems({
  List<String?>? keys,
  List<String?>? urls,
}) {
  final items = <WritingBoardMediaItemData>[];
  final count = [keys?.length ?? 0, urls?.length ?? 0].reduce((value, element) => value > element ? value : element);
  for (int index = 0; index < count; index++) {
    final key = keys != null && index < keys.length ? keys[index] : null;
    final url = urls != null && index < urls.length ? urls[index] : null;
    if ((key == null || key.isEmpty) && (url == null || url.isEmpty)) continue;
    items.add(WritingBoardMediaItemData(key: key, url: url));
  }
  return items;
}

String _localizedText(List<LanguageText?>? texts) {
  return LearningLangUtils.getLocalLang(texts)?.text ?? '';
}

String _learningText(List<LanguageText?>? texts) {
  return LearningLangUtils.getLearningLang(texts)?.text ?? '';
}

String _beatLabel(List<LanguageText?>? names, String beatNid) {
  final label = _localizedText(names);
  if (label.isEmpty) return beatNid;
  final firstPart = label.split('·').first.trim();
  return firstPart.isEmpty ? label : firstPart;
}
