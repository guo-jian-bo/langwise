enum FocusKeyEnum {
  tense_marking("tense_marking", "时体标记"),
  time_adverbial("time_adverbial", "时间状语"),
  polarity_marking("polarity_marking", "肯否标记"),
  voice_marking("voice_marking", "语态标记");

  const FocusKeyEnum(this.value, this.label);

  final String value;
  final String label;

  static FocusKeyEnum? fromValue(String? value) {
    if(value == null) return null;
    for (var item in FocusKeyEnum.values) {
      if (item.value == value) return item;
    }
    return null;
  }

}