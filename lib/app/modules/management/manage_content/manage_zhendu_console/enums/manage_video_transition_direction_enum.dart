enum ManageVideoTransitionDirectionEnum {
  startToHighlight("start_to_highlight"),
  highlightToEnd("highlight_to_end");

  const ManageVideoTransitionDirectionEnum(this.value);

  final String value;

  static ManageVideoTransitionDirectionEnum? fromValue(String? value) {
    for (var item in ManageVideoTransitionDirectionEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}
