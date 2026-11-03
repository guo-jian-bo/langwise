class LanguageEntity {
  final String? flag;
  final String? title;
  final bool isSelected;

  const LanguageEntity({this.flag, this.title, this.isSelected = false});

  LanguageEntity copyWith({String? flag, String? title, bool? isSelected}) {
    return LanguageEntity(
        flag: flag ?? this.flag, title: title ?? this.title, isSelected: isSelected ?? this.isSelected);
  }

  @override
  String toString() {
    return "LanguageEntity=>{flag: $flag,title: $title,isSelected: $isSelected}";
  }

  @override
  int get hashCode => Object.hash(flag, title);

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType && other is LanguageEntity && flag == other.flag && title == other.title;
}
