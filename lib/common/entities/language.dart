import 'json.dart';

class PosResponseEntity with JsonSerializableMixin {
  final String? pos;
  final String? abbr;
  final String? title;

  PosResponseEntity({
    this.pos,
    this.abbr,
    this.title,
  });

  factory PosResponseEntity.fromJson(Map<String, dynamic> json) {
    return PosResponseEntity(
      pos: json["pos"],
      abbr: json["abbr"],
      title: json["title"],
    );
  }

  @override
  Map<String, dynamic> toJson() => {"pos": pos, "abbr": abbr, "title": title};

  @override
  String toString() {
    return 'PosResponseEntity('
        'pos: $pos, '
        'abbr: $abbr, '
        'title: $title)';
  }
}

class FormResponseEntity with JsonSerializableMixin {
  final String? form;
  final String? title;

  FormResponseEntity({
    this.form,
    this.title,
  });

  factory FormResponseEntity.fromJson(Map<String, dynamic> json) {
    return FormResponseEntity(
      form: json["form"],
      title: json["title"],
    );
  }

  @override
  Map<String, dynamic> toJson() => {"form": form, "title": title};

  @override
  String toString() {
    return 'FormResponseEntity('
        'form: $form, '
        'title: $title)';
  }
}
