import 'package:flutter/material.dart';

class WordInflectionChipStyle {
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final bool dashed;

  const WordInflectionChipStyle({
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
    this.dashed = false,
  });
}

class WordInflectionMeta {
  static const List<String> nounSlots = ["base", "possessive", "plural", "possessive_plural"];
  static const List<String> degreeSlots = ["base", "comparative", "superlative"];
  static const List<String> verbSlots = [
    "third_person_singular",
    "present_participle",
    "base",
    "past_simple",
    "past_participle",
  ];

  static const Map<String, String> posLabels = {
    "NOUN": "名词",
    "VERB": "动词",
    "ADJECTIVE": "形容词",
    "ADVERB": "副词",
    "PRONOUN": "代词",
    "DETERMINER": "限定词",
    "NUMERAL": "数词",
    "MODAL_VERB": "情态动词",
    "AUXILIARY_VERB": "助动词",
  };

  static const Map<String, String> slotLabels = {
    "base": "原型",
    "plural": "复数",
    "possessive": "单数所有格",
    "possessive_plural": "复数所有格",
    "third_person_singular": "第三人称单数",
    "present_participle": "现在分词 / 动名词",
    "past_simple": "过去式",
    "past_participle": "过去分词",
    "comparative": "比较级",
    "superlative": "最高级",
  };

  static const Map<String, String> grammaticalTypeLabels = {
    "countable_noun": "可数名词",
    "uncountable_noun": "不可数名词",
    "plural_noun_no_singular": "仅复数名词",
    "singular_noun_plural_verb": "单数名词（配复数动词）",
    "gradable_adjective": "可分级形容词",
    "non_gradable_adjective": "不可分级形容词",
    "gradable_adverb": "可分级副词",
    "non_gradable_adverb": "不可分级副词",
    "transitive_verb": "及物动词",
    "ditransitive_verb": "双及物动词",
    "intransitive_verb": "不及物动词",
    "linking_verb": "系动词",
    "auxiliary_verb": "助动词",
    "be_auxiliary_verb": "be 助动词",
    "do_auxiliary_verb": "do 助动词",
    "have_auxiliary_verb": "have 助动词",
    "modal_verb": "情态动词",
    "can_modal_verb": "can 类情态动词",
    "could_modal_verb": "could 类情态动词",
    "should_modal_verb": "should 类情态动词",
    "will_modal_verb": "will 类情态动词",
    "determiner": "限定词",
    "pronoun": "代词",
    "cardinal_numeral": "基数词",
    "ordinal_numeral": "序数词",
  };

  static String getPosLabel(String? pos) {
    if (pos == null || pos.isEmpty) return '';
    return posLabels[pos] ?? pos;
  }

  static String getSlotLabel(String? typeNid) {
    if (typeNid == null || typeNid.isEmpty) return '';
    return slotLabels[typeNid] ?? typeNid;
  }

  static String getGrammaticalTypeLabel(String? nid) {
    if (nid == null || nid.isEmpty) return '';
    return grammaticalTypeLabels[nid] ?? nid;
  }

  static Color getPosColor(String? pos) {
    switch (pos) {
      case "NOUN":
        return const Color(0xFF14B8A6);
      case "VERB":
        return const Color(0xFFF59E0B);
      case "ADJECTIVE":
        return const Color(0xFF84CC16);
      case "ADVERB":
        return const Color(0xFF06B6D4);
      case "MODAL_VERB":
      case "AUXILIARY_VERB":
        return const Color(0xFFF97316);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  static WordInflectionChipStyle getPosChipStyle(String? pos) {
    Color color = getPosColor(pos);
    return WordInflectionChipStyle(
      textColor: color,
      bgColor: color.withValues(alpha: 0.12),
      borderColor: color.withValues(alpha: 0.26),
    );
  }

  static WordInflectionChipStyle getGrammaticalChipStyle(String? nid, {String? fallbackPos}) {
    String value = nid ?? '';
    Color color = _getGrammaticalColor(value, fallbackPos: fallbackPos);
    bool dashed = _isShutTag(value);
    double bgAlpha = dashed ? 0.06 : 0.12;
    double borderAlpha = dashed ? 0.22 : 0.24;
    return WordInflectionChipStyle(
      textColor: dashed ? color.withValues(alpha: 0.8) : color,
      bgColor: color.withValues(alpha: bgAlpha),
      borderColor: color.withValues(alpha: borderAlpha),
      dashed: dashed,
    );
  }

  static List<String> getParadigmSlots(String? pos) {
    switch (pos) {
      case "NOUN":
        return nounSlots;
      case "ADJECTIVE":
      case "ADVERB":
        return degreeSlots;
      case "VERB":
        return verbSlots;
      default:
        return ["base"];
    }
  }

  static bool useVerbGridLayout(List<String> surfaces, String? pos) {
    if (pos != "VERB") return false;
    return surfaces.toSet().length > 5;
  }

  static Color _getGrammaticalColor(String value, {String? fallbackPos}) {
    if (value == "determiner" || value == "pronoun" || value.contains("numeral")) {
      return const Color(0xFFF3F4F6);
    }
    if (value.contains("modal") || value.contains("auxiliary")) {
      return getPosColor("AUXILIARY_VERB");
    }
    if (value.contains("noun")) {
      return getPosColor("NOUN");
    }
    if (value.contains("adjective")) {
      return getPosColor("ADJECTIVE");
    }
    if (value.contains("adverb")) {
      return getPosColor("ADVERB");
    }
    if (value.contains("verb")) {
      return getPosColor("VERB");
    }
    return getPosColor(fallbackPos);
  }

  static bool _isShutTag(String value) {
    return value.contains("uncountable") || value.startsWith("non_gradable_");
  }
}
