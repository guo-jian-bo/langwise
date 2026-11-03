import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/widgets/zhenxie_widgets/word_inflection/word_inflection_meta.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';

class ManageWordInflectionDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tag;
  ManageWordInflectionDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD_INFLECTION_DETAILS;

  @override
  String get breadcrumbTitle => '曲折变化详情';

  String? familyKey;
  int? semanticId;
  bool isUserSide = false;

  final Rx<WordInflectionDetailEntity> detail = WordInflectionDetailEntity().obs;

  final RxnInt selectedSemanticId = RxnInt();

  final RxBool isLoading = false.obs;

  final RxSet<String> createdSlotKeys = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      familyKey = Get.arguments["familyKey"];
      semanticId = int.tryParse(Get.arguments["semanticId"]?.toString() ?? '');
      final dynamic isUserSideValue = Get.arguments["isUserSide"];
      isUserSide = isUserSideValue == true || isUserSideValue?.toString() == 'true';
    }
    initBreadcrumb(tag);
    getDetails();
  }

  Future<void> getDetails() async {
    if (familyKey == null || familyKey?.isEmpty == true) return;
    if (isUserSide && semanticId == null) return;
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      WordInflectionDetailEntity? res;
      if (isUserSide) {
        res = await ElementsRequest.getWordInflectionDetail(
          familyKey: familyKey!,
          semanticId: semanticId!,
        );
      } else {
        res = await LanguageConsoleRequest.queryWordInflectionDetail(familyKey!);
      }
      if (res == null) return;
      detail.value = res;
      List<WordInflectionDetailSemanticEntity> semantics = getSemanticList();
      if (semantics.isNotEmpty) {
        int? initialSemanticId;
        if (semanticId != null) {
          for (int i = 0; i < semantics.length; i++) {
            if (semantics[i].semanticId == semanticId) {
              initialSemanticId = semantics[i].semanticId;
              break;
            }
          }
        }
        selectedSemanticId.value = initialSemanticId ?? semantics.first.semanticId;
      }
      updateBreadcrumbTitle("${res.lemma ?? ''} · 曲折变化");
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  void selectSemantic(int? semanticId) {
    selectedSemanticId.value = semanticId;
  }

  List<WordInflectionDetailSemanticEntity> getSemanticList() {
    return detail.value.semantics?.whereType<WordInflectionDetailSemanticEntity>().toList() ?? [];
  }

  WordInflectionDetailParadigmEntity? getCurrentParadigm() {
    List<WordInflectionDetailParadigmEntity> paradigms =
        detail.value.paradigms?.whereType<WordInflectionDetailParadigmEntity>().toList() ?? [];
    if (paradigms.isEmpty) return null;

    int? semanticId = selectedSemanticId.value;
    if (semanticId != null) {
      for (int i = 0; i < paradigms.length; i++) {
        List<int?> semanticIds = paradigms[i].semanticIds ?? [];
        if (semanticIds.contains(semanticId)) {
          return paradigms[i];
        }
      }
    }

    for (int i = 0; i < paradigms.length; i++) {
      List<int?> semanticIds = paradigms[i].semanticIds ?? [];
      if (semanticIds.isEmpty) {
        return paradigms[i];
      }
    }
    return paradigms.first;
  }

  List<String> getCurrentGrammaticalTypeNids() {
    WordInflectionDetailParadigmEntity? paradigm = getCurrentParadigm();
    List<String> values = paradigm?.grammaticalTypeNids?.whereType<String>().toList() ?? [];
    if (values.isNotEmpty) return values;
    return detail.value.grammaticalTypeNids?.whereType<String>().toList() ?? [];
  }

  List<WordInflectionDetailSlotEntity> getCurrentDisplaySlots() {
    WordInflectionDetailParadigmEntity? paradigm = getCurrentParadigm();
    if (paradigm == null) return [];

    String pos = detail.value.pos ?? '';
    List<WordInflectionDetailSlotEntity> sourceSlots =
        paradigm.slots?.whereType<WordInflectionDetailSlotEntity>().toList() ?? [];
    if (pos == "VERB" && WordInflectionMeta.useVerbGridLayout(_getDistinctSurfaces(sourceSlots), pos)) {
      return _buildVerbGridSlots(sourceSlots);
    }

    List<String> visibleTypeNids = WordInflectionMeta.getParadigmSlots(pos);
    List<String> allowedTypeNids = paradigm.allowedInflectionTypeNids?.whereType<String>().toList() ?? [];

    List<WordInflectionDetailSlotEntity> displaySlots = [];
    for (int i = 0; i < visibleTypeNids.length; i++) {
      String typeNid = visibleTypeNids[i];
      WordInflectionDetailSlotEntity? slot = _findPrimarySlot(sourceSlots, typeNid);
      if (slot != null) {
        displaySlots.add(_applyCreatedState(slot));
        continue;
      }
      if (typeNid != "base" && !allowedTypeNids.contains(typeNid)) {
        displaySlots.add(_buildUnavailableSlot(typeNid));
        continue;
      }
      displaySlots.add(_buildMissingSlot(typeNid));
    }

    if (pos == "NOUN") {
      displaySlots = _remapPluraliaTantumSlots(displaySlots);
      displaySlots = _applyNounSyncretism(displaySlots);
    }
    return displaySlots;
  }

  List<WordInflectionDetailSlotEntity> _buildVerbGridSlots(List<WordInflectionDetailSlotEntity> sourceSlots) {
    List<WordInflectionDetailSlotEntity> values = [];
    Set<String> seen = {};
    List<String> orderedTypeNids = WordInflectionMeta.verbSlots;
    for (int i = 0; i < orderedTypeNids.length; i++) {
      String typeNid = orderedTypeNids[i];
      List<WordInflectionDetailSlotEntity> current = sourceSlots.where((e) => e.typeNid == typeNid).toList();
      current.sort((a, b) => (b.isPrimary == true ? 1 : 0) - (a.isPrimary == true ? 1 : 0));
      for (int j = 0; j < current.length; j++) {
        String surface = current[j].content ?? current[j].surface ?? '';
        String key = "$typeNid::$surface";
        if (seen.contains(key)) continue;
        seen.add(key);
        values.add(_applyCreatedState(current[j]));
      }
    }
    return values;
  }

  int getLinkedCount() {
    int count = 0;
    List<WordInflectionDetailSlotEntity> slots = getCurrentDisplaySlots();
    for (int i = 0; i < slots.length; i++) {
      if (slots[i].kind == "linked") {
        count++;
      }
    }
    return count;
  }

  int getMissingCount() {
    int count = 0;
    List<WordInflectionDetailSlotEntity> slots = getCurrentDisplaySlots();
    for (int i = 0; i < slots.length; i++) {
      if (slots[i].kind == "missing") {
        if (isSlotCreated(slots[i])) continue;
        count++;
      }
    }
    return count;
  }

  void createSlotLocally(WordInflectionDetailSlotEntity slot) {
    if (slot.kind != "missing") return;
    String key = getSlotCreateKey(slot);
    if (key.isEmpty || createdSlotKeys.contains(key)) return;
    createdSlotKeys.add(key);
    String actionText = slot.contentType == "EN_PHRASE" ? "短语" : "词";
    ToastUtils.showManageToast(text: "已本地创建$actionText：${slot.surface ?? slot.content ?? ''}");
  }

  bool isSlotCreated(WordInflectionDetailSlotEntity slot) {
    if (slot.created == true) return true;
    String key = getSlotCreateKey(slot);
    if (key.isEmpty) return false;
    return createdSlotKeys.contains(key);
  }

  String getCreateActionLabel(WordInflectionDetailSlotEntity slot) {
    return slot.contentType == "EN_PHRASE" ? "创建短语" : "创建词";
  }

  String getSlotCreateKey(WordInflectionDetailSlotEntity slot) {
    String typeNid = slot.typeNid ?? '';
    String surface = slot.surface ?? slot.content ?? '';
    if (typeNid.isEmpty || surface.isEmpty) return '';
    return "$typeNid::$surface";
  }

  WordInflectionDetailSlotEntity? _findPrimarySlot(List<WordInflectionDetailSlotEntity> slots, String typeNid) {
    List<WordInflectionDetailSlotEntity> current = [];
    for (int i = 0; i < slots.length; i++) {
      if (slots[i].typeNid == typeNid) {
        current.add(slots[i]);
      }
    }
    if (current.isEmpty) return null;
    for (int i = 0; i < current.length; i++) {
      if (current[i].isPrimary == true) {
        return current[i];
      }
    }
    return current.first;
  }

  WordInflectionDetailSlotEntity _buildUnavailableSlot(String typeNid) {
    return WordInflectionDetailSlotEntity(
      typeNid: typeNid,
      kind: "unavailable",
      contentType: "EN_WORD",
      isPrimary: true,
      variants: [],
    );
  }

  WordInflectionDetailSlotEntity _buildMissingSlot(String typeNid) {
    return WordInflectionDetailSlotEntity(
      typeNid: typeNid,
      kind: "missing",
      contentType: "EN_WORD",
      isPrimary: true,
      variants: [],
    );
  }

  WordInflectionDetailSlotEntity _applyCreatedState(WordInflectionDetailSlotEntity slot) {
    if (slot.kind != "missing") return slot;
    bool created = isSlotCreated(slot);
    if (created == (slot.created == true)) return slot;
    return WordInflectionDetailSlotEntity(
      typeNid: slot.typeNid,
      kind: slot.kind,
      contentId: slot.contentId,
      contentType: slot.contentType,
      contentCard: slot.contentCard,
      content: slot.content,
      surface: slot.surface,
      descriptions: slot.descriptions,
      variants: slot.variants,
      syncretismLabel: slot.syncretismLabel,
      created: created,
      isPrimary: slot.isPrimary,
    );
  }

  List<WordInflectionDetailSlotEntity> _remapPluraliaTantumSlots(List<WordInflectionDetailSlotEntity> slots) {
    List<String> grammaticalTypeNids = getCurrentGrammaticalTypeNids();
    if (!grammaticalTypeNids.contains("plural_noun_no_singular")) {
      return slots;
    }

    Map<String, WordInflectionDetailSlotEntity> map = {};
    for (int i = 0; i < slots.length; i++) {
      if ((slots[i].typeNid ?? '').isNotEmpty) {
        map[slots[i].typeNid ?? ''] = slots[i];
      }
    }

    String pluralSurface = map["plural"]?.surface ?? map["plural"]?.content ?? '';
    String baseSurface = map["base"]?.surface ?? map["base"]?.content ?? '';
    if (pluralSurface.isEmpty && baseSurface.isNotEmpty) {
      map["plural"] = WordInflectionDetailSlotEntity(
        typeNid: "plural",
        kind: map["base"]?.kind,
        contentId: map["base"]?.contentId,
        contentType: map["base"]?.contentType,
        contentCard: map["base"]?.contentCard,
        content: map["base"]?.content,
        surface: map["base"]?.surface,
        descriptions: map["base"]?.descriptions,
        variants: map["base"]?.variants,
        syncretismLabel: map["base"]?.syncretismLabel,
        created: map["base"]?.created,
        isPrimary: map["base"]?.isPrimary,
      );
    }

    map["base"] = _buildUnavailableSlot("base");
    map["possessive"] = _buildUnavailableSlot("possessive");
    return WordInflectionMeta.nounSlots.map((typeNid) => map[typeNid] ?? _buildUnavailableSlot(typeNid)).toList();
  }

  List<WordInflectionDetailSlotEntity> _applyNounSyncretism(List<WordInflectionDetailSlotEntity> slots) {
    Map<String, WordInflectionDetailSlotEntity> map = {};
    for (int i = 0; i < slots.length; i++) {
      if ((slots[i].typeNid ?? '').isNotEmpty) {
        map[slots[i].typeNid ?? ''] = slots[i];
      }
    }
    _applySyncretismLabel(map, "base", "plural");
    _applySyncretismLabel(map, "possessive", "possessive_plural");
    return WordInflectionMeta.nounSlots.map((typeNid) => map[typeNid] ?? _buildUnavailableSlot(typeNid)).toList();
  }

  void _applySyncretismLabel(Map<String, WordInflectionDetailSlotEntity> map, String left, String right) {
    String leftSurface = (map[left]?.content ?? map[left]?.surface ?? '').trim().toLowerCase();
    String rightSurface = (map[right]?.content ?? map[right]?.surface ?? '').trim().toLowerCase();
    if (leftSurface.isEmpty || rightSurface.isEmpty || leftSurface != rightSurface) return;
    if (map[left]?.kind == "unavailable" || map[right]?.kind == "unavailable") return;
    map[left] = _copySlotWithSyncretism(map[left], "单复数同形");
    map[right] = _copySlotWithSyncretism(map[right], "单复数同形");
  }

  WordInflectionDetailSlotEntity _copySlotWithSyncretism(WordInflectionDetailSlotEntity? slot, String label) {
    return WordInflectionDetailSlotEntity(
      typeNid: slot?.typeNid,
      kind: slot?.kind,
      contentId: slot?.contentId,
      contentType: slot?.contentType,
      contentCard: slot?.contentCard,
      content: slot?.content,
      surface: slot?.surface,
      descriptions: slot?.descriptions,
      variants: slot?.variants,
      syncretismLabel: label,
      created: slot?.created,
      isPrimary: slot?.isPrimary,
    );
  }

  List<String> _getDistinctSurfaces(List<WordInflectionDetailSlotEntity> slots) {
    List<String> values = [];
    for (int i = 0; i < slots.length; i++) {
      String surface = slots[i].content ?? slots[i].surface ?? '';
      if (surface.isNotEmpty && !values.contains(surface)) {
        values.add(surface);
      }
    }
    return values;
  }
}
